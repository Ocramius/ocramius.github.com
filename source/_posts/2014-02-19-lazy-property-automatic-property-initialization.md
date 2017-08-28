---
layout: post
title: LazyProperty - Automatic property initialization for PHP
category: PHP
tags: ["php", "oop", "hacks"]
year: 2014
month: 02
day: 19
published: true
summary: LazyProperty - A library for automatic property initialization
description: A way to use PHP magic to actually make APIs simpler to use
tweet: 436184062487953408
---

<p>
    Yesterday, I worked on yet another interesting little experiment, which is called
    <a href="https://github.com/Ocramius/LazyProperty" target="_blank">
        LazyProperty
    </a>.
</p>


<h2>The problem with "lazy" properties</h2>

<p>
    The idea is very simple: avoid manually checking object properties to see if they were initialized.
</p>

<p>
    Let's make a simple example:
</p>

~~~php
<?php

class UserService
{
    // ...
    protected $userRepository;

    public function register($user)
    {
        // ...
        $this->getUserRepository()->add($user);
    }

    // ...

    protected function getUserRepository()
    {
        // we're not using DI here because of performance implications
        // developers often use a service locator for RAD here
        return $this->userRepository
            ?: $this->userRepository = new MemoryUserRepository();
    }
}
~~~

<hr/>

<p>
    This is a fairly simple approach, and it is perfectly fine to use it when we don't want to be forced
    to build the <code>MemoryUserRepository</code> instance for calls to API methods that don't use
    it.
</p>

<p>
    There is a problem though, which is that any direct access to <code>UserService#$userRepository</code>
    has to be avoided: all of the class' implementation as well as its subclasses have to rely on the
    protected getter in order to access the repository instance.
</p>

<p>
    For instance, the following code works only because of a lucky combination of events:
</p>

~~~php
<?php

class UserService
{
    // ...
    protected $userValidator;

    public function register($user)
    {
        $this->getUserRepository()->add($user);
    }

    public function login($userId)
    {
        // mind this - this is a mistake!
        $this->userRepository->find($userId);
        // ...
    }
}
~~~

~~~php
<?php

$user = build_user_somehow();

$userService->register($user);
$userService->login($user->getId());
~~~

<p>
    This code will run, but only because <code>UserService#register()</code> was called before
    <code>UserService#login()</code>.
</p>

<hr/>

<h2>Possible solutions</h2>

<p>
    The code in the examples exposes a silly bug, and it should be fixed by avoiding any property
    access to <code>UserService#$userRepository</code>.
</p>

<p>
    Moreover, implementors of subclasses will also experience the issue if they try accessing the
    un-initialized property. The fix for that is to just define
    <code>UserService#$userRepository</code> as <code>private</code> and being very defensive
    about its usage.
</p>

<p>
    These are all valid solutions, but we still don't get around using a protected getter in our
    class' scope, which I personally consider ugly.
</p>

<p>
    That's where I had this possibly crazy idea: making the property itself "lazy" and avoiding the
    getter call completely, making the getter an implementation detail.
</p>

<p>
    Let's see how this is done with the library:
</p>

~~~php
<?php

class UserService
{
    use \LazyProperty\LazyPropertiesTrait;

    protected $userRepository;

    public function __construct()
    {
        // ...
        // mind this - we are marking "userRepository" as lazy
        $this->initLazyProperties(['userRepository']);
    }

    public function register($user)
    {
        // ...
        // now use the property directly
        $this->userRepository->add($user);
        // ...
    }

    public function login($userId)
    {
        $this->userRepository->find($userId);
        // ...
    }

    protected function getUserRepository()
    {
        return $this->userRepository
            ?: $this->userRepository = new MemoryUserRepository();
    }
}
~~~

<p>
    By calling <code>LazyProperty\LazyPropertiesTrait#initLazyProperties()</code>, we've made sure
    that any access to the un-initialized <code>UserService#$userRepository</code> will actually
    trigger a call to <code>UserService#getUserRepository()</code>, and therefore initialize it.
</p>

<p>
    With that, we don't need to actually worry about calling the getter: both the getter call and
    property access will work the same way, which is pretty cool!
</p>

<hr/>

<h2>Under the hood</h2>

<p>
    What is going on? I'm simply exploiting an feature of the PHP language on which I've already
    blogged at <a href="https://ocramius.github.io/blog/intercepting-public-property-access-in-php/" target="_blank">
        Property Accessors in PHP Userland
    </a>.
</p>

<p>
    As a reference, here is the annotated body of <a href="https://github.com/Ocramius/LazyProperty/blob/fe60bd66455b6acf34fe0be25a83a625db6b2f88/src/LazyProperty/LazyPropertiesTrait.php#L37-L58" target="_blank">
        <code>LazyProperty\LazyPropertiesTrait#initLazyProperties()</code>
    </a>:
</p>

~~~php
<?php

private function initLazyProperties(array $lazyPropertyNames, $checkLazyGetters = true)
{
    foreach ($lazyPropertyNames as $lazyProperty) {

        // verify that a getter is available for the given lazy property
        if ($checkLazyGetters && ! method_exists($this, 'get' . $lazyProperty)) {
            throw MissingLazyPropertyGetterException::fromGetter($this, 'get' . $lazyProperty, $lazyProperty);
        }

        // record the properties that were defined as "lazy"
        $this->lazyPropertyAccessors[$lazyProperty] = false;

        // if the property is defined, then ignore it (we don't want to sensibly alter object state)
        if (! isset($this->$lazyProperty)) {
            // unset the property, this allows us to use magic getters
            unset($this->$lazyProperty);
        }
    }
}
~~~

<p>
    Quite simple! Nothing really incredible going on here. When is the property actually initialized?
</p>

<p>
    The other method defined by the trait is the <a href="https://github.com/Ocramius/LazyProperty/blob/fe60bd66455b6acf34fe0be25a83a625db6b2f88/src/LazyProperty/LazyPropertiesTrait.php#L60-L84" target="_blank">
        Magic getter <code>LazyProperty\LazyPropertiesTrait#__get()</code>
    </a>:
</p>

~~~php
<?php

// returning a reference is required,
// otherwise (for example) array properties accessed for writes will fail
public function & __get($name)
{
    // disallow access to non-existing properties
    if (! isset($this->lazyPropertyAccessors[$name])) {
        throw InvalidLazyProperty::nonExistingLazyProperty($this, $name);
    }

    // retrieve the object that is trying to access the lazy property
    $caller = debug_backtrace(DEBUG_BACKTRACE_PROVIDE_OBJECT)[1];

    // disallow access from invalid scope
    // basically reproduces property visibility in userland
    if (! isset($caller['object']) || $caller['object'] !== $this) {
        AccessScopeChecker::checkCallerScope($caller, $this, $name);
    }

    // set the property to `null` (disables notices)
    $this->$name = null;

    // initialize the property
    $this->$name = $this->{'get' . $name}();

    return $this->$name;
}
~~~

<hr/>

<h2>Conclusions</h2>

<p>
    This "hack" is simple, clean, easily tested and doesn't cause any problems.
    It works on PHP 5.4, 5.5, 5.6 and even on HHVM, which I wasn't expecting.
</p>

<p>
    Can you use it? Yes, why not? Do you need it? Usually not. Being defensive about usage of your
    APIs can actually avoid sloppy mistakes like the ones that I've described in the examples.
</p>

<p>
    Correctly annotating your properties with <code>/** @var Type|null */</code> also helps tools
    like <a href="https://github.com/scrutinizer-ci/php-analyzer" target="_blank">PHP Analyzer</a>
    in discovering such bugs via static analysis.
</p>

<p>
    Clean dependency injection and eventually proxying dependencies also produces better and easier
    testable results than explicit lazy-loading coded in your classes.
</p>

<p>
    The most interesting result in this experiment is that PHP yet again allows to implement
    language-level features in userland, which is awesome!
</p>

<p>
    Please let me know if you like this project by giving it a
    <a href="https://github.com/Ocramius/LazyProperty" target="_blank">star</a>, or just drop me a tweet if
    you think it can be enhanced!
</p>
        