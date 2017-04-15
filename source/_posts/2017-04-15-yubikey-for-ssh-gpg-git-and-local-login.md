---
layout: post
title: YubiKey for SSH, Login, 2FA, GPG and Git Signing
category: Security
tags: ["YubiKey", "GPG", "SSH", "security", "GPG", "2FA", "GIT", "Authentication"]
year: 2017
month: 4
day: 15
published: true
summary: Using a single YubiKey for Two-Factor Auth, SSH login, GPG signing (GIT too) and to log into your computer
description: A little walk-through on how to effectively use a YubiKey for everyday security: GPG, SSH, Login, 2FA
tweet: 853287534465617920
---

<p>
    I've been using a
    <a href="https://www.yubico.com/products/yubikey-hardware/yubikey-neo/" target="_blank">
        YubiKey Neo
    </a>
    for a bit over two years now, but its usage was limited to
    <abbr title="Two Factor Authentication">2FA</abbr>
    and
    <abbr title="Universal Two Factor Authentication">U2F</abbr>.
</p>

<p>
    Last week, I received my new DELL XPS 15 9560, and since I am maintaining
    some high impact open source projects, I wanted the setup to be well secured.
</p>

<p>
    In addition to that, I caught a bad flu, and that gave me enough excuses
    to waste time in figuring things out.
</p>

<p>
    In this article, I'm going to describe what I did, and how you can reproduce
    my setup for your own safety as well as the one of people that trust you.
</p>

<h2>Yubi-WHAT?</h2>

<p>
    In first place, you should know that I am absolutely not a security expert:
    all I did was following the online tutorials that I found.
    I also am not a cryptography expert, and I am constantly dissatisfied with
    how the crypto community reduces everything into a
    <abbr title="Three Letter Acronym">TLA</abbr>,
    making even the simplest things impossible to understand for mere mortals.
</p>

<p>
    First, let's clarify what a YubiKey is.
</p>

<p>
    <img
        src="/img/posts/2017-04-15-yubikey-for-ssh-gpg-git-and-local-login/yoshi-yubikey.jpg"
        alt="A YubiKey Neo on a cat"
    />
</p>

<p>
    That thing is a YubiKey.
</p>

<p>
    What does it do?
</p>

<p>
    It's basically an USB key filled with crypto features.
    It also is (currently) impossible to make a physical copy of it,
    and it is not possible to extract information written to it.
</p>

<p>
    It can:
</p>

<ul>
    <li>
        Generate
        <abbr title="Hash Message Authentication Code">HMAC</abbr>
        hashes (kinda)
    </li>
    <li>
        Store
        <abbr title="Gnu Privacy Guard">GPG</abbr>
        private keys
    </li>
    <li>Act as a keyboard that generates time-based passwords</li>
    <li>Generate 2FA time-based login codes</li>
</ul>

<h2>What do we need?</h2>

<p>
    In order to follow this tutorial, you should have at least
    2 (two) YubiKey Neo or equivalent devices. This means that
    you will have to spend approximately USD 100: these things
    are quite expensive. You absolutely need a backup key,
    because all these security measures may lock you out of
    your systems if you lose or damage one.
</p>

<p>
    Our kickass setup will allow us to do a series of cool
    things related to daily development operations:
</p>

<ul>
    <li>Two Factor Authentication</li>
    <li>PAM Authentication (logging into your linux/mac PC)</li>
    <li>GPG mail and GIT commit signing/encrypting</li>
    <li><abbr title="Secure Shell">SSH</abbr> Authentication</li>
</ul>

<p>
    <img
        src="/img/posts/2017-04-15-yubikey-for-ssh-gpg-git-and-local-login/yubikey-features.jpg"
        alt="Covered YubiKey features"
    />
</p>

<p>
    I am not going to describe the procedures in detail,
    but just link them and describe what we are doing, and
    why.
</p>

<h2>Setting up NFC 2FA</h2>

<p>
    Simple NFC-based 2FA with authentication codes will
    be useful for most readers, even non-technical ones.
</p>

<p>
    What we are doing is simply seed the YubiKey with
    Google Authenticator codes, except that we will
    use the
    <a href="https://play.google.com/store/apps/details?id=com.yubico.yubioath&hl=en" target="_blank">
        Yubico Authenticator
    </a>.
    This will only work for the "primary" key (the one
    we will likely bring with us at all times).
</p>

<p>
    What we will have to do is basically:
</p>

<ol>
    <li>Install some Yubico utility to manage your Yubikey NEO</li>
    <li>
        Plug in your YubiKey and enable
        <abbr title="One Time Password">OTP</abbr>
        and U2F
    </li>
    <li>Install the Yubico Authenticator</li>
    <li>Seed your Yubikey with the 2FA code provided by a compatible website</li>
</ol>

<p>
    The setup steps are described in the official
    <a href="https://www.yubico.com/support/knowledge-base/categories/articles/how-to-use-your-yubikey-with-authenticator-codes/" target="_blank">
        Yubico website
    </a>.
</p>

<p>
    Once the YubiKey is configured with at least one
    <a href="https://twofactorauth.org/" target="_blank">
        website
    </a>
    that supports the "Google Authenticator" workflow,
    we should be able to:
</p>

<ol>
    <li>Open the Yubico Authenticator</li>
    <li>Tap the YubiKey against our phone's NFC sensor</li>
    <li>Use the generated authentication code</li>
</ol>

<p>
    <img
        src="/img/posts/2017-04-15-yubikey-for-ssh-gpg-git-and-local-login/2fa-codes.jpg"
        alt="Example Yubico Authenticator screen"
    />
</p>

<p>
    One very nice (and unclear, at first) advantage of
    having a YubiKey seeded with 2FA codes is that
    we can now generate 2FA codes on any phone, as long
    as we have our YubiKey with us.
</p>

<p>
    I already had to remote-lock and remote-erase a phone
    in the past, and losing the Google Authenticator settings
    is not fun. If you handle your YubiKey with care, you
    shouldn't have that problem anymore.
</p>

<p class="alert alert-success">
    Also, a YubiKey is water-proof: our 2017 phone probably isn't.
</p>

<h2>Setting up PAM authentication</h2>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span> this procedure
    can potentially lead us to lose <code>sudo</code>
    access from our account, as well as lock us out of our computer.
    I take no responsibility: try it in a
    <abbr title="Virtual Machine">VM</abbr>
    first, if you do not feel confident.
</p>

<p>
    We want to make sure that we can log into our personal
    computer or workstation only when we are physically sitting
    at it. This means that we need the YubiKey must be plugged
    in for a password authentication to succeed.
</p>

<p>
    Each login prompt, user password prompt or <code>sudo</code>
    command should require both our account password and our YubiKey.
</p>

<p>
    What we will have to do is basically:
</p>

<ol>
    <li>Install <code>libpam-yubico</code></li>
    <li>
        Enable some capabilities of our YubiKeys with
        <code>ykpersonalize</code>
    </li>
    <li>
        Generate an initial challenge file for each YubiKey (you
        bought at least 2, right?) with
        <code>ykpamcfg</code>
    </li>
    <li>Deploy the generated files in a root-only accessible path</li>
    <li>
        <span class="label label-warning">IMPORTANT</span>
        start a
        <code>sudo</code>
        session, and be ready to revert changes from there if things go wrong
    </li>
    <li>
        Configure
        <abbr title="Pluggable Authentication Modules">PAM</abbr>
        to also expect a challenge response from a YubiKey (reads:
        a recognized YubiKey must be plugged in when trying to
        authenticate)
    </li>
</ol>

<p>
    The steps to perform that are
    <a href="https://developers.yubico.com/yubico-pam/Authentication_Using_Challenge-Response.html" target="_blank">
        in the official Yubico tutorial
    </a>.
</p>

<p>
    If everything is done correctly, every prompt asking for our
    Linux/Mac account password should fail when no YubiKey is plugged
    in.
</p>

<p class="alert alert-info">
    <span class="label label-info">TIP:</span> configure the
    libpam-yubico integration in debug mode, as we will often
    have a "WTH?" reaction when authentication isn't working.
    That may happen if there are communication errors with the
    YubiKey.
</p>

<p>
    This setup has the advantage of locking out anyone trying to
    bruteforce our password, as well as stopping potentially malicious
    background programs from performing authentication or
    <code>sudo</code>
    commands while we aren't watching.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span> the point
    of this sort of setup is to guarantee that login can only
    happen with the physical person at the computer. If we want
    to go to the crapper, we lock lock computer, and bring our
    YubiKey with us.
</p>

<h2>Setting up GPG</h2>

<p>
    This is probably the messiest part of the setup, as a lot of
    CLI tool usage is required.
</p>

<p>
    Each YubiKey has the ability to store 3 separate keys for
    <i>signing</i>, <i>encrypting</i> and <i>authenticating</i>.
</p>

<p>
    We will therefore create a series of GPG keys:
</p>

<ol>
    <li>A GPG master key (if we don't already have a GPG key)</li>
    <li>
        A sub-key for signing (marked
        <code>[S]</code>
        in the gpg interactive console)
    </li>
    <li>
        A sub-key for encrypting (marked
        <code>[E]</code>
        in the gpg interactive console)
    </li>
    <li>
        A sub-key for authenticating (marked
        <code>[A]</code>
        in the gpg interactive console)
    </li>
    <li>
        Generate these 3 sub-keys for each YubiKey
        we have (3 keys per YubiKey)
    </li>
</ol>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span> as far as I know,
    the YubiKey Neo only supports RSA keys up to <code>2048</code> long.
    Do not use <code>4096</code> for the sub-key length unless we know
    that the key type supports it.
</p>

<p>
    After that, we will move the private keys to the YubiKeys
    with the <code>gpg</code> <code>keytocard</code> command.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span> the
    <code>keytocard</code> command is destructive. Once we moved
    a private key to a YubiKey, it is removed from our local
    machine, and it cannot be recovered. Be sure to only move
    the correct sub-keys.
</p>

<p class="alert alert-info">
    <span class="label label-info">NOTE:</span> being unable
    to recover the private sub-key is precisely the
    point of using a YubiKey: nobody can steal or misuse that
    keys, no malicious program can copy it, plus we can use
    it from any workstation.
</p>

<p>
    Also, we will need to set a
    <strong>PIN</strong>
    and an
    <strong>admin PIN</strong>.
    These defaults for these two are respectively
    <code>123456</code>
    and
    <code>12345678</code>.
    The
    <strong>PIN</strong>
    will be needed each time we plug in we YubiKey to use
    any of the private keys stored in it.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span>
    we only have
    <code>3</code>
    attempts for entering our PIN. Should we fail all
    attempts, then the YubiKey will be locked, and yweou
    will have to move new GPG sub-keys to it before being
    able to use it again. This prevents
    bruteforcing after physical theft.
</p>

<p>
    After our gpg sub-keys and PINs are written to the
    YubiKeys, let's make a couple of secure backups of our master
    gpg secret key. Then delete it from the computer  Keep
    just the public key.
</p>

<p>
    The master private gpg key should only be used to generate
    new sub-keys, if needed, or to revoke them, if we lose
    one or more of our physical devices.
</p>

<p>
    We should now be able to:
</p>

<ul>
    <li>
        Sign messages with the signing key stored in our
        YubiKey (only if plugged in) and its PIN
    </li>
    <li>
        Verify those messages with the master public key
    </li>
    <li>
        Encrypt messages with the master public key
    </li>
    <li>
        Decrypt messages with the encryption key stored in
        the YubiKey (only if plugged in) and its PIN
    </li>
</ul>

<p>
    The exact procedure to achieve all this is described
    in detail (with console output and examples) at
    <a href="https://github.com/drduh/YubiKey-Guide/tree/1ad37577db92726eadde4dc302a6f982ba7e82dc">
        drduh/YubiKey-Guide
    </a>.
</p>

<h2>GIT commit signing</h2>

<p>
    Now that we can sign messages using the GPG key stored
    in our YubiKey, usage with GIT becomes trivial:
</p>

<p>
    <code>git config --global user.signingkey=&lt;yubikey-signing-sub-key-id&gt;</code>
</p>

<p>
    We will now need to plug in our YubiKey and enter our
    PIN when signing a tag:
</p>

<p>
    <code>git tag -s this-is-a-signed-tag -m "foo"</code>
</p>

<p class="alert alert-success">
    Nobody can release software on our behalf without physical
    access to our YubiKey, as well as our YubiKey PIN.
</p>

<h2>Signing/Encrypting email messages</h2>

<p>
    In order to sign/encrypt emails, we will need to install
    <a href="https://www.mozilla.org/en-US/thunderbird/" target="_blank">
        Mozilla Thunderbird
    </a>
    and
    <a href="https://www.enigmail.net/index.php/en/" target="_blank">
        Enigmail
    </a>.
</p>

<p>
    The setup will crash a few times. I suggest going through the
    "advanced" settings, then actually selecting a signing/encryption
    key when trying to send a signed/encrypted message. Enigmail
    expects the key to be a file or similar, but this approach
    will allow us to just give it the private GPG key identifier.
</p>

<p>
    Sending mails is still a bit buggy: Thunderbird will ask for the
    pin 3 times, as if it failed to authenticate, but the third attempt
    will actually succeed. This behavior will be present in a number of
    prompts, not just within Thunderbird.
</p>

<p class="alert alert-success">
    <span class="label label-success">!</span>
    Nobody can read our encrypted emails, unless the YubiKey
    is plugged in. If our laptop is stolen, these secrets will be
    protected.
</p>

<h2>SSH authentication</h2>

<p>
    There is one GPG key that we didn't use yet:
    the authentication one.
</p>

<p>
    There is a (relatively) recent functionality of
    <code>gpg-agent</code>
    that allows it to behave as an
    <code>ssh-agent</code>.
</p>

<p>
    To make that work, we will simply kill all existing
    SSH and GPG agents:
</p>

~~~sh
sudo killall gpg-agent
sudo killall ssh-agent
# note: eval is used because the produced STDOUT is a bunch of ENV settings
eval $( gpg-agent --daemon --enable-ssh-support )
~~~

<p>
    Once we've done that, let's try running:
</p>

<p>
    <code>ssh-add -L</code>
</p>

<p>
    Assuming we don't have any local SSH keys, the output
    should be something like:
</p>

~~~
ocramius@ocramius-XPS-15-9560:~$ ssh-add -L
The agent has no identities.
~~~

<p>
    If we plug in our YubiKey and try again,
    the output will be:
</p>

~~~
ocramius@ocramius-XPS-15-9560:~$ ssh-add -L
ssh-rsa AAAAB3NzaC ... pdqtlwX6m1 cardno:000123457915
~~~

<p>
    MAGIC! <code>gpg-agent</code> is exposing the public GPG key as
    an SSH key.
</p>

<p>
    If we upload this public key to a server, and then
    try logging in with the YubiKey plugged in, we will
    be asked for the YubiKey PIN, and will then just be able
    to log in as usual.
</p>

<p class="alert alert-success">
    Nobody can log into our remote servers without having
    the physical key device.
</p>

<p class="alert alert-success">
    We can log into our remote servers from any computer
    that can run gpg-agent. Just always bring our YubiKey with
    ourselves.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">CAUTION:</span>
    Each YubiKey with an authentication gpg sub-key
    will produce a different public SSH key: we will
    need to seed our server with all the SSH public keys.
</p>

<p class="alert alert-info">
    <span class="label label-info">TIP:</span>
    consider using the YubiKey identifier (written on
    the back of the device) as the comment for the
    public SSH key, before storing it.
</p>

<p>
    Steps to set up <code>gpg-agent</code> for SSH authentication
    are also detailed in
    <a href="https://github.com/drduh/YubiKey-Guide/tree/1ad37577db92726eadde4dc302a6f982ba7e82dc">
        drduh/YubiKey-Guide
    </a>.
</p>

<p>
    Custom SSH keys are no longer needed: our GPG keys cover
    most usage scenarios.
</p>

<h2>Conclusion</h2>

<p>
    We now have at least 2 physical devices that give
    us access to very critical parts of our infrastructure,
    messaging, release systems and computers in general.
</p>

<p>
    At this point, I suggest keeping one always with ourselves,
    and treating it with extreme care. I made a custom
    <a href="https://www.thingiverse.com/thing:532575" target="_blank">
        3d-printed case for my YubiKey
    </a>, and then put it all together in my physical keychain:
</p>

<p>
    <img
        src="/img/posts/2017-04-15-yubikey-for-ssh-gpg-git-and-local-login/physical-keychain.jpg"
        alt="My physical keychain"
    />
</p>

<p>
    The backup key is to be kept in a secure location: while
    theft isn't a big threat with YubiKeys, getting locked
    out of all our systems is a problem. Make sure that you can
    always either recover a YubiKey or the master GPG key.
</p>
