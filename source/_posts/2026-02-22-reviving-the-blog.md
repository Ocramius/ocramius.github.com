---
layout: post
title: Reviving the blog
category: Blog
tags: ["self-hosting", "nix", "php", "composer", "reproducible-builds", "fediverse", "mastodon", "blog", "embedded-website"]
year: 2026
month: 02
day: 22
published: true
summary: "Reviving the blog: putting more weight on self-hosting and owning my content"
description: I'm reviving this personal space, revamping its build processes, so that publishing on it is not as painful as it used to be :-)
---
<p>
    I'm back!
</p>

<p>
    The last time I blogged was in 2017: a lot has changed since then, and after a decade of ignoring blogging,
    I will attempt to put some regularity into it again.
</p>

<p>
    The times call for it: having a personal space that is really "<b>our own</b>" is extremely important,
    and it is as important as having something to read that is written by other humans, and not slop.
</p>

<p>
    I mainly stopped blogging for two reasons:
</p>

<ul>
    <li>
        Wordpress and similar tools are terrible, for rarely changing content.
        I'd rather <b>not</b> blog, than host a dynamic website just for serving static webpages
    </li>
    <li>
        My static site generation pipeline heavily relied on my workstation's software dependencies,
        which shifted continuously, breaking the website build at all times.
    </li>
</ul>

<h3>Stabilizing the build</h3>

<p class="alert alert-info">
    <span class="label label-info">Note:</span> This section describes the Nixification of the blog, done
    in <a href="https://github.com/Ocramius/ocramius.github.com/pull/132">this pull request</a>. You can
    skip this, if you prefer reading the <abbr title="Pull Request">PR</abbr> instead.
</p>

<p>
    The first thing to do is to get everything under control again.
</p>

<p>
    Since a few years back, I started heavily relying on <a href="https://nix.dev/">Nix</a>, a
    lazy functional language that is perfect to achieve reproducible builds and environments.
</p>

<p>
    At the time of this writing, this website is built via <a href="https://github.com/sculpin/sculpin">Sculpin</a>,
    a static website generator whose dependency upgrades I've neglected for far too long.
</p>

<p>
    In order to "freeze" the build in time, I used a <a href="https://nixos.wiki/wiki/flakes">Nix Flake</a> to
    pin all the dependencies down, preventing any further shifts in dependency versions:
</p>

~~~nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
 
  outputs = { self, nixpkgs, flake-utils, composer2nix, ... }@inputs: 
    flake-utils.lib.eachDefaultSystem (
      system: {
        packages = {
          # things that will stay extremely stable will go here
        };
      }
    ); 
}
~~~

<p>
    The above will "pin" dependencies such as <code>composer</code> or <code>php</code>,
    preventing them from drifting apart, unless a commit moves them.
    This is also thanks to the built-in <code>flake.lock</code> mechanism of Nix Flakes.
</p>

<p>
    Because Composer does not compute <b>content</b> hashes of PHP dependencies, NixOS
    cannot directly use <code>composer.json</code> and <code>composer.lock</code> to
    download dependencies: that is an obstruction to reproducible builds, and requires
    a little detour.
</p>

<p>
    Luckily, <a href="http://sandervanderburg.nl/">Sander van der Burg</a> built a very
    useful <a href="https://github.com/svanderburg/composer2nix">composer2nix</a> tool,
    which can be used to scan <code>composer.lock</code> entries, and compute their content
    hashes upfront:
</p>

~~~nix
{
  inputs = {
    # ...
    composer2nix = {
      url = "github:svanderburg/composer2nix";
      flake = false;
    };
  };
~~~

<p>
    As you can see, <code>composer2nix</code> is not a flake: we still manage to use it ourselves,
    to process <code>composer.lock</code> locally:
</p>

~~~nix
update-php-packages = pkgs.writeShellScriptBin "generate-composer-to-nix.sh" ''
  set -euxo pipefail
  TMPDIR="$(${pkgs.coreutils}/bin/mktemp -d)"
  trap 'rm -rf -- "$TMPDIR"' EXIT
  mkdir "$TMPDIR/src"
  mkdir "$TMPDIR/composer2nix"
  ${pkgs.coreutils}/bin/cp -r "${./app}" "$TMPDIR/src/app"
  ${pkgs.coreutils}/bin/cp -r "${composer2nix}/." "$TMPDIR/composer2nix"
  ${pkgs.coreutils}/bin/chmod -R +w "$TMPDIR/composer2nix"
  ${pkgs.php84Packages.composer}/bin/composer install --working-dir="$TMPDIR/composer2nix" --no-scripts --no-plugins
  ${pkgs.php}/bin/php $TMPDIR/composer2nix/bin/composer2nix --name=${website-name}
  ${pkgs.coreutils}/bin/rm -f default.nix
'';
~~~

<p>
    We can now run <code>nix run .#update-php-packages</code> to generate a very
    useful <code>php-packages.nix</code>, which will be used to produce our <code>vendor/</code>
    directory later on.
</p>

<p>
    The generated <code>php-packages.nix</code> looks a lot like this:
</p>

~~~nix
let
  packages = {
    "components/bootstrap" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-bootstrap-fca56bda4c5c40cb2a163a143e8e4271a6721492";
        src = fetchurl {
          url = "https://api.github.com/repos/components/bootstrap/zipball/fca56bda4c5c40cb2a163a143e8e4271a6721492";
          sha256 = "138fz0xp2z9ysgxfsnl7qqgh8qfnhv2bhvacmngnjqpkssz7jagx";
        };
      };
    };
    # ... and more
~~~

<p>
    With that, we can then prepare a stable installation of the website generator:
</p>

~~~nix
  # ...
  built-blog-assets = derivation {
    name    = "built-blog-assets";
    src     = with-autoloader; # an intermediate step I omitted in this blogpost: check the original PR for details
    builder = pkgs.writeShellScript "generate-blog-assets.sh" ''
      set -euxo pipefail
      ${pkgs.coreutils}/bin/cp -r $src/. $TMPDIR
      cd $TMPDIR
      ${pkgs.php}/bin/php vendor/bin/sculpin generate --env=prod
      ${pkgs.coreutils}/bin/cp -r $TMPDIR/output_prod $out
    '';
    inherit system;
  };
~~~

<p>
    Running <code>nix build .#built-blog-assets</code> now generates a <code>./result</code> directory
    with the full website contents, and we know it won't break unless we update <code>flake.lock</code>, yay!
</p>

<p>
    Let's publish these contents to Github Pages:
</p>

~~~nix
publish-to-github-pages = pkgs.writeShellScriptBin "publish-blog.sh" ''
  set -euxo pipefail
  TMPDIR="$(${pkgs.coreutils}/bin/mktemp -d)"
  trap 'rm -rf -- "$TMPDIR"' EXIT
  cd "$TMPDIR"
  ${pkgs.git}/bin/git clone git@github.com:Ocramius/ocramius.github.com.git .
  git checkout master
  ${pkgs.rsync}/bin/rsync --quiet --archive --filter="P .git*" --exclude=".*.sw*" --exclude=".*.un~" --delete "${built-blog-assets}/" ./
  git add -A :/
  git commit -a -m "Deploying sculpin-generated pages to \`master\` branch"
  git push origin HEAD
'';
~~~

<p>
    We can now run <code>nix run .#publish-to-github-pages</code> to deploy the website!
</p>

<h3>Self-hosting: a minimal container</h3>

<p>
    Since you are one of my smart readers, you probably already noticed how GitHub has been progressively
    enshittified by its umbilical cord with
    <a href="https://www.windowslatest.com/2026/01/13/windows-11-users-coin-microslop-as-ai-backlash-grows-and-even-a-browser-extension-that-renames-microsoft-to-microslop/">Microslop</a>.
</p>

<p>
    I plan to move the blog somewhere else soon-ish, so I already prepared an OCI container for it.
</p>

<p>
    Since I will deploy it myself, I want a container with no shell, no root user, no filesystem access.
</p>

<p>
    I stumbled upon
    <a href="https://github.com/mholt/caddy-embed/blob/a3908443d8bf78c61d0799f5e8854cf05db698b9/README.md">mholt/caddy-embed</a>,
    which embeds an entire static website into a single Go binary: perfect for my use-case.
</p>

<p>
    The Caddy docs suggest using <a href="https://github.com/caddyserver/xcaddy">XCaddy</a> for installing
    modules, but that is yet another build system that I don't want to have anything to do with.
    Instead, I cloned <code>caddy-embed</code>, and used
    <a href="https://wiki.nixos.org/wiki/Go">NixPkgs' Go build system</a> to embed my website into it:
</p>

~~~nix
  caddy-module-with-assets = derivation {
    name    = "caddy-module-with-assets";
    builder = pkgs.writeShellScript "generate-blog-assets.sh" ''
      set -euxo pipefail
      ${pkgs.coreutils}/bin/cp -r ${./caddy-embed/.} $out
      ${pkgs.coreutils}/bin/chmod +w $out/files/
      ${pkgs.coreutils}/bin/cp -rf ${built-blog-assets}/. $out/files/
    '';
    inherit system;
  };
  embedded-server = pkgs.buildGo126Module {
    name       = "embedded-server";
    src        = caddy-module-with-assets;
    # annoyingly, this will need to be manually updated at every `go.mod` change :-(
    vendorHash = "sha256-v0YXbAaftLLc+e8/w1xghW5OHRjT7Xi87KyLv1siGSc=";
  };
~~~

<p>
    Same as with PHP, I'm pretty confident that Nix won't break unless <code>flake.lock</code> changes.
</p>

<p>
    We can now bundle the built server into a docker container with a single <code>Caddyfile</code> attached.
    The following is effectively a <code>Dockerfile</code>, but reproducible and minimal:
</p>

~~~nix
runnable-container = pkgs.dockerTools.buildLayeredImage {
  name = website-name;
  tag  = "latest";
  
  contents = [
    (pkgs.writeTextDir "Caddyfile" (builtins.readFile ./caddy-embed/Caddyfile))
  ];

  config = {
    Cmd = [
      "${embedded-server}/bin/caddy-embed"
      "run"
    ];
  };
};
~~~

<p>
    We can now:
</p>

<ol>
    <li>build the container via <code>nix build .#runnable-container</code></li>
    <li>load the container via <code>cat ./result | docker load</code></li>
    <li>run it via <code>docker run --rm -ti -p8080:8080 ocramius.github.io:latest</code></li>
</ol>

<p>
    The running container uses ~40Mb of RAM to exist (consider that it has all of the website in memory),
    and a quick test with <a href="https://github.com/wg/wrk">wrk</a> showed that it can handle over
    60000 requests/second on my local machine.
</p>

~~~
❯ wrk -t 10 -d 30 -c 10  http://localhost:8080/
Running 30s test @ http://localhost:8080/
  10 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   165.35us   75.09us   3.91ms   90.49%
    Req/Sec     6.12k   365.53     7.05k    92.46%
  1833101 requests in 30.10s, 23.32GB read
Requests/sec:  60901.74
Transfer/sec:    793.44MB
~~~

<h3>Cleaning up the website</h3>

<p>
    While cleaning up the builds, I found some really horrible stuff that should've gone away much earlier:
</p>

<p>
    <b>Google Analytics</b>: kill it with fire! I'm not here to "convert visits": I'm here to help out
    my readers and make new connections.
    I am not a marketing department, and the privacy of my website visitors
    is more important than a website ticker that sends data to a US-based company.
</p>

<p>
    <b>Leftover JS/CSS</b>: the website had various external CDNs in use, with CSS and JS files that were
    not really in use anymore. Cleaning these up felt good, and also reduced the number of external sites
    to zero.
</p>

<p>
    <b>Navigation menu simplified</b>: this is a static website. An animated "burger menu" was certainly
    interesting a decade ago, but nowadays, it is just an annoying distraction, and extra navigation steps
    for visitors.
</p>

<p>
    <b>Disqus</b>: this used to be a useful way to embed a threaded comment section inside a static website,
    but it is no longer relevant to me, as it becomes an extra inbox to manage.
    Disqus was also cluttered with trackers, which should not be there.
</p>

<h3>Next steps?</h3>

<p>
    This first post is about "being able to blog again", but there's more to do.
</p>

<p>
    I certainly want to self-host things, having my blog under my own domain, rather than under
    <code>*.github.io</code>.
</p>

<p>
    I also want comments again, but they need to come from
    <a href="https://en.wikipedia.org/wiki/Fediverse">the Fediverse</a>, rather than being land-locked
    in a commenting platform.
    Other people <a href="https://blog.thms.uk/2023/02/mastodon-comments">have attempted</a> this, and
    I shall do it too.
</p>

<p>
    Perhaps I may remove that 3D avatar at the top of the page? It took a lot of time to write, with
    Blender, THREEJS, and it uses your video card to run: perhaps not the best energy-efficient choice
    for a static website, but I'm still emotionally attached to it.
</p>

<p>
    Also, this website is filled with reference information that no longer holds true: a decade has
    passed, and my OSS positions have vastly changed, and so will pages that describe what I do.
</p>

<p>
    Finally, I want it to be clear that this is a website by a human, for other humans: I will therefore
    start cryptographically signing my work, allowing others to decide whether they trust what I wrote
    myself, without a machine generating any of it.
</p>

<h3>And you?</h3>

<p>
    If you are still here and reading: thank you for passing by, dear fellow human.
</p>

<p>
    Hoping that this has inspired you a bit, I'm looking forward to seeing your own efforts to self-host
    your own website!
</p>