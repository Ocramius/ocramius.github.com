/---
layout: post
title: Domain Validation vs Form Validation
category: Security
tags: ["PHP", "Security", "API Design", "DDD", "Hexagonal Design"]
year: 2018
month: 2
day: 8
published: true
summary: @TODO Domain Validation is a required execution path for our code, whereas Form Validation is not: let's figure out why
description: @TODO
tweet: @TODO
---
<p>
    Yesterday, I had a 
    <a href="https://twitter.com/_odino_/status/961356516514254848" data-todo-fixme-uri="">quite chatty discussion</a>
    about how to approach server-side validation in HTTP-based applications.
    <br/>
    The focus of the discussion was around <abbr title="Single Page Application">SPA</a> design,
    but this article will try to keep things even more simplified.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">DISCLAIMER:</span>
    this article is in <strong>no way</strong> suggesting to remove server-side validation.
    If your customers can open a debugger and modify information that is directly used by your core
    processes, you already lose. There is no such thing as <strong>"validating in the client"</strong>.
</p>

<p>
    For the sake of simplicity, we will design the familiar authentication domain in our examples:
</p>

<ul>
    <li>A user can register with a username and a password</li>
    <li>A user can log into the system</li>
</ul>

<p>
    In such a domain, we will likely design our core logic with following 
    repository and aggregate:
</p>

~~~php
<?php

namespace Authentication;

interface RegisteredUsers
{
    public function get(Username $username) : User;
    public function store(User $user) : void;
}
~~~

~~~php
<?php

namespace Authentication;

final class User
{
    private function __construct() { /* ... */ }
    public static function register(
        string $username,
        string $clearTextPassword,
        HashPassword $hashPassword
    ) : self {
        // ...
    }

    public function authenticate(
        string $clearTextPassword,
        VerifyPassword $verifyPassword
    ) : bool {
        // ...
    }
}
~~~


<p class="alert alert-info">
    <span class="label label-info">INFO:</span>
    If you never designed code this way, you may want to read about
    <a href="https://ocramius.github.io/blog/on-aggregates-and-external-context-interactions/">Aggregates and External Context Interactions</a>
</p>

<p>
    This is the kernel of our extremely simplistic domain.
    Still, some concepts are under-specified:
</p>

<ul>
    <li>Is an empty username valid?</li>
    <li>What characters are valid in a username?</li>
    <li>Is <code>Johann Gambolputty de von Ausfern- schplenden- schlitter- crasscrenbon- fried- digger- dingle- dangle- dongle- dungle- burstein- von- knacker- thrasher- apple- banger- horowitz- ticolensic- grander- knotty- spelltinkle- grandlich- grumblemeyer- spelterwasser- kurstlich- himbleeisen- bahnwagen- gutenabend- bitte- ein- nürnburger- bratwustle- gerspurten- mitz- weimache- luber- hundsfut- gumberaber- shönedanker- kalbsfleisch- mittler- aucher von Hautkopft of Ulm? </code> a valid username?</li>
    <li>Is an empty password sufficient?</li>
</ul>

<p>
    The answers to these questions is quite obvious to developers that implemented this same
    logic multiple times over the years, but they are still assumptions in our mental model.
    </br>
    Let's instead write them down: 
</p>

~~~php
<?php

namespace Authentication;

final class Username
{
    private function __construct() { /* ... */ }
    public static function fromEmailAddress(string $email) : self
    {
        // ...
    }
}
~~~

~~~php
<?php

namespace Authentication;

final class PlainTextPassword
{
    private function __construct() { /* ... */ }
    public static function fromPlainText(string $password) : self
    {
        // ...
    }
}
~~~

<p>
    That's better! We should also define some invariants:
</p>

~~~php
<?php

namespace Authentication;

use Authentication\Exception\NotAnEmailAddress;
use Authentication\Exception\EmailAddressTooLong;

final class Username
{
    private function __construct() { /* ... */ }
    public static function fromEmailAddress(string $email) : self
    {
        if (! is_email($email)) {
            throw NotAnEmailAddress::fromString($email);
        }

        if (strlen($email) > 200) {
            throw EmailAddressTooLong::fromString($email);
        }

        $instance = new self();

        $instance->email = $email;

        return $instance;
    }
}
~~~

<p>
    That solved a few problems, as we now know that we only accept <strong>sensible</strong>
    email addresses, and we also made it clear that in our system, the concept of <code>username</code>
    and <code>email</code> somehow overlap.
</p>

~~~php
<?php

namespace Authentication;

final class PlainTextPassword
{
    private function __construct() { /* ... */ }
    public static function fromPlainText(string $password) : self
    {
        if (strlen($password) < 8) {
            throw new PasswordTooShort();
        }

        $instance = new self();

        $instance->password = $password;

        return $instance;
    }
}
~~~

<p>
    Our system now rejects short passwords completely: that is a security constraint that
    we really need to define to prevent empty strings flying around and causing unexpected
    chaos.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">WARNING:</span>
    please do not add silly password policies other than a minimum length: it will lead
    simply lead to people typing in horrors <code>abc123!!</code>.
</p>

<p class="alert alert-warning">
    <span class="label label-warning">WARNING:</span>
    do <strong>NOT</strong> add the password to the thrown exception details, as exceptions
    are usually to be logged.
</p>

<p>
   We can now adapt our <code>User</code> aggregate to rely on these invariants:
</p>

~~~php
<?php

namespace Authentication;

final class User
{
    private function __construct() { /* ... */ }
    public static function register(
        Username $username,
        PlainTextPassword $password,
        HashPassword $hashPassword
    ) : self {
        // ...
    }

    public function authenticate(
        PlainTextPassword $password,
        VerifyPassword $verifyPassword
    ) : bool {
        // ...
    }
}
~~~

<p>
    So far, we added invariants for our <strong>values</strong>, but what about
    our context? Can two <code>User</code> instances with the same <code>Username</code>
    exist within our system? Absolutely not! We can fix this by combining a read model
    with our aggregate named constructor: 
</p>

~~~php
<?php

namespace Authentication;

interface UserExists
{
    public function __invoke(Username $username) : bool;
}
~~~


~~~php
<?php

namespace Authentication;

use Authentication\Exception\UserAlreadyRegistered;

final class User
{
    private function __construct() { /* ... */ }
    public static function register(
        Username $username,
        PlainTextPassword $password,
        HashPassword $hashPassword,
        UserExists $userExists
    ) : self {
        if ($userExists($username)) {
            throw UserAlreadyRegistered::fromUsername($username);
        }

        $instance = new self();

        $instance->username = $username;
        $instance->passwordHash = $hashPassword($password);

        return $instance;
    }

    public function authenticate(
        PlainTextPassword $password,
        VerifyPassword $verifyPassword
    ) : bool {
        return $verifyPassword($password, $this->passwordHash);
    }
}
~~~

<p>
    That's it: that's our simplistic authentication system, and you can use it in a CLI
    or HTTP application without any particular added validation needed. We will implement
    a naive application through <a href="@TODO">PSR-15</a> request handlers.
</p>

<p>
    Registration is as simple as this:
</p>

~~~php
<?php

namespace Frontend\Authentication;

use Authentication\User;
use Authentication\RegisteredUsers;
use Authentication\UserExists;
use Frontend\Support\Assert;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Zend\Diactoros\Response\TextResponse;

final class RegisterAction implements RequestHandlerInterface
{
    public function __construct(RegisteredUsers $users, UserExists $userExists, HashPassword $hashPassword)
    {
        $this->users        = $users;
        $this->userExists   = $userExists;
        $this->hashPassword = $hashPassword;
    }

    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        Assert::postRequest($request);

        $postData = $request->getParsedBody();

	$this->users->store(User::register(
            Username::fromEmailAddress($postData['email']),
            PlainTextPassword::fromPlainText($postData['password']),
            $this->hashPassword,
            $this->userExists
        ));

        return new TextResponse('Registered! We sent you some spam, and subscribed you to our 10000 SEM campaigns');
    }
}
~~~

<p>
    Login is also straightforward:
</p>

~~~php
<?php

namespace Frontend\Authentication;

use Authentication\User;
use Authentication\RegisteredUsers;
use Authentication\UserExists;
use Frontend\Support\Assert;
use Frontend\Support\SessionHelper;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Zend\Diactoros\Response\RedirectResponse;

final class LoginAction implements RequestHandlerInterface
{
    public function __construct(
        RegisteredUsers $users,
        UserExists $userExists,
        VerifyPassword $verifyPassword,
        SessionHelper $session
    ) {
        $this->users        = $users;
        $this->userExists   = $userExists;
        $this->verifyPassword = $verifyPassword;
        $this->sessionHelper = $sessionHelper;
    }

    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        Assert::postRequest($request);

        $postData = $request->getParsedBody();

        $username = Username::fromEmailAddress($postData['email']),

        if (! $this->userExists($username)) {
            return new RedirectResponse('/login?failed=true', 401);
        }

        $user = $this->users->get($username);

        if (! $user->authenticate(
            PlainTextPassword::fromPlainText($postData['password']),
            $this->verifyPassword
        )) {
            return new RedirectResponse('/login?failed=true', 401);
        }

        return $this->sessionHelper->addIdentityTo(new RedirectResponse('/dashboard', 200), $username);
    }
}
~~~

<h3>The point</h3>

<p>
    The point I am trying to make here is that we wrote an entire authentication
    component with no validation components involved.
</p>

<p>
    Try logging in with an invalid email: you will get a 500 error.
</p>

<p>
    Try logging in with an invalid password: you will get a 500 error.
</p>

<p>
    Try registering with an already existing user: you will get a 500 error.
</p>

<p>
    Is this always desirable? Of course not, but for simple value validation, plain HTML
    is more than sufficient:
</p>

~~~php
<?php

namespace Frontend\Authentication;

use Authentication\User;
use Authentication\RegisteredUsers;
use Authentication\UserExists;
use Frontend\Support\Assert;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Zend\Diactoros\Response\TextResponse;

final class RegisterFormAction implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        Assert::getRequest($request);

        return new HtmlResponse(
<<<'HTML'
<html>
    <head><title>All ur privacy are belong to us</title></head>
    <body>
        <form action="/register" method="post">
            <input type="email" id="email" maxlength="200"/>
            <input type="password" id="password" minlength="8"/>
            <input type="submit" value="That's it - I shit you not!"/>
        </form>
    </body>
</html>
HTML
        );
    }
}
~~~

<p>
    And that is <strong>sufficient</strong>.
</p>

<p>
    There is one thing we can't do in the frontend without some elaborate JS contraption,
    and since we don't want an elaborate JS contraption (nobody wants it, except those
    that seek the way to produce more work), we can simplify the <code>RegisterAction</code>
    by adding a check in it:
</p>

~~~php
<?php

namespace Frontend\Authentication;

use Authentication\User;
use Authentication\RegisteredUsers;
use Authentication\UserExists;
use Frontend\Support\Assert;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Zend\Diactoros\Response\RedirectResponse;
use Zend\Diactoros\Response\TextResponse;

final class RegisterAction implements RequestHandlerInterface
{
    public function __construct(RegisteredUsers $users, UserExists $userExists, HashPassword $hashPassword)
    {
        $this->users        = $users;
        $this->userExists   = $userExists;
        $this->hashPassword = $hashPassword;
    }

    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        Assert::postRequest($request);

        $postData = $request->getParsedBody();

        $username = Username::fromEmailAddress($postData['email']);

        if (($this->userExists)($username)) { // added this to make this "explode less"
            return new RedirectResponse('/register?username_taken=true', 422);
        }

	$this->users->store(User::register(
            Username::fromEmailAddress($postData['email']),
            PlainTextPassword::fromPlainText($postData['password']),
            $this->hashPassword,
            $this->userExists
        ));

        return new TextResponse('Registered! We sent you some spam, and subscribed you to our 10000 SEM campaigns');
    }
}
~~~

<p>
    I'll skip over how login would look like, because it would be the exact same thing
</p>

<h3>Domain validation over validation components</h3>

<p>
    As you've seen, the core domain was fully responsible for guaranteeing the security
    constraints. This should be the case in <strong>every business domain</strong>.
</p>

<p>
    What I usually do see in applications is a bunch of under-designed and complex code
    that glues together <code>zendframework/zend-form</code> or <code>symfony/form</code>
    into a nightmare of hidden and pseudo-magic constraints that implicitly leak into
    the logic of the application. 
</p>

<p>
    You know the drill: upgrade a dependency, and suddenly your core domain no longer works.
    Also, you cannot expose this domain through different endpoints (command line interface,
    worker queue, other cooperating domains, HTTP APIs, etc.) without having to replicate
    the entire constraints and validation in outer layers, leaving a lot of juicy information
    be found by (hopefully) pentesters.
</p>

<p>
    Therefore, <strong>if it is a decision, put it in the domain.</strong>
</p>

<p>
    This reasoning does not exclude that you can add server-side form validation to
    make  <abbr title="User Experience">UX</abbr> better, but you should strive for
    simplicity and for putting constraints in the domain, as that is your last and most
    important defense line against invalid, corrupted or malicious information.
</p>

<p>
    Everything else is pretty much secondary and "nice-to-have".
</p>

<h3>Advantages and disadvantages</h3>

<p>
    Putting data integrity and contextual validation in the domain has a few nice effects
    that do picking this way an absolute no-brainer:
</p>

<ul>
    <li>
        Format of the infformation is clearly expressed in domain terminology, which means
        that it acts as documentation. Remember kids: types are a fantastic replacement for
        a detailed documentation!
    </li>
    <li>
        Exceptions (and errors in general) usually go to the logs. This means that you will
        have some sort of overview of when and why form validation fails, or if somebody is
        simply violently crawling your pages.
    </li>
    <li>
        Errors produced by the domain are very specific, which means that they have a proper
        type (do not throw generic SPL exceptions, please!) and usually proper error messages,
        as well as a stack trace that doesn't come from the deep dungeons of a magic framework
        component.
    </li>
</ul>

<p>
    The main disadvantage of using this approach is that, when designing an API to be exposed
    over the network, all failures require manual translation into proper error messages.
    <br/>
    Differentiating between user errors and system errors is not always possible, and displaying
    the exception message cannot be done by default, because some degree of sensitive data may
    be contained in it.
    <br/>
    Therefore, when building a network-facing API layer designed for customers, you will have
    to plan an additional development phase in which you are covering all the unhappy paths.
    <br/>
    The good part of that is that this is completely optional for an
    <abbr title="Minimum Viable Product">MVP</abbr>.
</p>

<h3>Domain first, everything else afterwards</h3>

<p>
    To conclude, you should almost always design your applications with following priority in mind:
</p>

<ol>
    <li>
        Design data types upfront, assign them a type, enforce the type invariants
    </li>
    <li>
        Design contextual validation in the domain, as part of the business logic.
        It must be readable and explicit
    </li>
    <li>
        Design the entry point to your domain logic (HTTP controllers/actions/middleware/etc),
        let the unhappy paths crash spectacularly. A 500 error is <strong>good enough</strong>,
        and it will help you (from the logs) in figuring out what is important and what is not.
    </li>
    <li>
        Add validation constraints to the frontend. The simplest possible approach
        is sufficient. In this post, I used HTML5 form validation, and that's OK.
    </li>
    <li>
        Add server-side input validation where needed, where you'd prefer a nice error message
        over a crash.
    </li>
</ol>
