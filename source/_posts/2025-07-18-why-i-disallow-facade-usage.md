---
layout: post
title: Why I disallow Laravel Facade usages
category: Security
tags: [ "PHP", "Laravel", "Facade", "Anti-Patterns" ]
year: 2025
month: 07
day: 18
published: true
summary: "Laravel Facades: why I disallow their usage in my software project"
description: A technical overview of why Facades are problematic from a software engineering point of view, and why I disallow them in my software projects
---

<p class="alert alert-warning">
    For non-Laravel developers: beware that this is not about the facade pattern.
</p>

<p>
    Recently, I had a heated discussion with a software developer: they approached me, asking
    me why I had flagged all usages of Laravel facades in a code review. 
</p>

<p>
    Laravel Facades are a pattern that has been deeply ingrained in the development practices of teams that
    solely design Laravel code, and they are mostly promoted in terms of <abbr title="developer experience">DX</abbr>,
    rather than technical merits.
</p>

<h2>The Example</h2>

<p>
    Following is a piece of code that uses a Laravel Facade to store some data in cache:
</p>

@TODO change this example to use a different facade: something that sends an email notification would be nice

~~~php
<?php

final class MyService implements SomeContract {
    public function doSomeHeavyWork(): Result
    {
        $result = $this->heavyLifting();

        Cache::put('a key', $result);

        return $result;
    }
    
    private function heavyLifting(): Result
    {
        // ... irrelevant ...
    }
}
~~~

<p>
    From an inexperienced observer's point of view, this code is relatively straightforward: it
    does some heavy work, it stores the information in a cache, then returns.
</p>

<h2>Problem 1: shared mutable state</h2>

~~~php
<?php

$service1 = new MyService();
$service2 = new MyService();

$result1 = $service1->doSomeHeavyWork();
$result2 = $service2->doSomeHeavyWork();
~~~

<p>
    @TODO we need a stronger example here: what's a good "whoops" example, like a checkout on the wrong banking coordinates?
</p>

<p>
    @TODO expose how this problem occurs especially when:
     * an application grows in size, accommodating for multiple service instances
     * tests: multiple services needed, one per test!
</p>

<h2>Problem 2: hidden dependencies</h2>

<p>
    A second problem occurs when running this code in isolation: assuming you have **only**
    autoloading configured, what will it do?
</p>

~~~php
<?php

require_once __DIR__ . '/vendor/autoload.php'

$service = new \My\Namespace\MyService();

$result = $service->doSomeHeavyWork(); // this will crash: the cache was never configured!
~~~

<p>
    This kind of crash is very similar to what you'd experience with the service location pattern: since
    you are deferring all instantiation to the point at which a dependency is effectively invoked, you
    may run in crashes due to a missed dependency.
</p>

<p>
    In addition to the disadvantages of service-location, you also have the hidden dependency of the facade's
    internal
    <a href="https://github.com/laravel/framework/blob/2c682e4eb531eae6439579f25d29429ecc0a66ca/src/Illuminate/Support/Facades/Facade.php#L20-L25">
        <code>static::$app</code>
    </a>.
</p>

<p>
    Your code cannot work until you've bootstrapped a Laravel application, which is a complex and heavy
    (performance-wise) operation.
</p>


<h2>Problem 2: framework dependencies added</h2>

<p>
    Another issue with our <code>MyService</code> is that we have widely expanded the contact surface with the
    framework: our code now depends on <code>illuminate/support</code>, and also on <code>illuminate/contracts</code>
    in order for it to function at basic level.
</p>

<p>
    This is both an issue of Laravel, which exposes a very bloated <code>illuminate/contracts</code> package, and
    of our code, since framework upgrades can now affect our ability to perform upgrades.
</p>

<p>
    Coming myself from the
    <a href="https://en.wikipedia.org/wiki/Domain-driven_design"><abbr title="Domain-Driven Design">DDD</abbr></a>
    community, isolating software dependencies is critical for the long-term maintenance of a system, and reducing
    the amount of dependencies is always a good idea, as it is entropy that will easily spin out of control.
</p>

<p>
    In this case, we wanted a cache, not the entire framework.
</p>

<h2>Problem 3: hidden complexity</h3>

<p>
    @TODO expose here how adding a facade introduces magic method calls, stack frames, static analysis complexity.
</p>

<p>
    @TODO expose concept of "simple" != "easy". Systems can be complex and easy, or harder to use, but simple.
</p>

<p>
    @TODO expose how the facade is "hidden API" - not all interactions with the object are exposed by the public
    class signature anymore, while constructor shows clear inputs/outputs.
</p>

<h2>The simple solution</h2>

<p>
    Here's our service re-implemented to make things simple and explicit:
</p>

~~~php
<?php

final class MyService implements SomeContract {
    public function __construct(private readonly SomeCache) {}
    public function doSomeHeavyWork(): Result
    {
        $result = $this->heavyLifting();

        $this->cache->put('a key', $result);

        return $result;
    }

    private function heavyLifting(): Result
    {
        // ... irrelevant ...
    }
}
~~~

<p>
    The above is a little more verbose, but follows very old and well-functioning
    <a href="https://www.youtube.com/watch?v=RlfLCWKxHJ0">dependency injection</a> rules.
</p>


<p>
    By adding 2 lines of code, we:
</p>

<ul>
    <li>make the shared state visible</li>
    <li>removes a framework dependency</li>
    <li>removes runtime crashes in case of misconfiguration</li>
    <li>allow multiple instances of a service to use different dependencies</li>
    <li>makes the dependency visible at reflection level (useful for dependency analysis tooling)</li>
</ul>

<p>
    Does the above solution have worse <abbr title="Developer Experience">DX</abbr>?
    Given all the listed advantages, I think it provides much better experience.
</p>

<p>
    You have to also remember that facades were designed and built in an age when auto-wiring dependency injection
    containers weren't common in PHP: the simpler approach may actually even be easier, when using the full framework.
</p>

<h2>But what about my test helpers?</h2>

<p>
    @TODO Laravel has MyFacade::spy() and MyFacade::mock() helpers - let's document those
</p>

~~~php
<?php

final class MyServiceTest extends \Illuminate\Foundation\Testing\TestCase {
    function test_something_is_being_done(): void
    {
        Cache::spy();
        
        Cache::shouldReceive('put')
            ->with('a key', 'a value');
        
        $service = new MyService();
        
        $result = $service->doSomeHeavyWork();
        
        // more assertions on $result
    }
}
~~~

<p>
    The above example swaps the facade underlying service location mechanism with a mock, and relies on an
    <a href="https://github.com/laravel/framework/blob/2c682e4eb531eae6439579f25d29429ecc0a66ca/src/Illuminate/Foundation/Testing/TestCase.php#L9-L21">
        extremely complex base test class
    </a> to do framework startup/cleanup operations.
</p>

<p>
    Here's the "simple" version instead:
</p>


~~~php
<?php

final class MyServiceTest extends \PHPUnit\Framework\TestCase {
    function test_something_is_being_done(): void
    {
        $cache = $this->createMock(Cache::class);
        
        $cache->expects(self::once())
            ->method('put')
            ->with('a key', 'a value');
        
        $service = new MyService($cache);
        
        $result = $service->doSomeHeavyWork();
        
        // more assertions on $result
    }
}
~~~

<p>
    Notice how we got rid of:
</p>

<ul>
    <li>the base test case class, which is no longer needed</li>
    <li>the facade global state: tests are now isolated in state by default</li>
    <li>the underlying mockery framework dependency, which was used by the facade internals</li>
</ul>

<p>
    Don't like using automatic mocks by PHPUnit? Bring your own!
</p>

~~~php
<?php

final class CacheSpy implements Cache
{
    /** @var array<string, mixed> */
    private array $recorded = [];
    function put(string $key, mixed $value) {
        $this->recorded[$key] = $value;
    }
}

// look! No testing framework either!
function my_test() {
    $cache = new CacheSpy()

    $service = new MyService($cache);

    $result = $service->doSomeHeavyWork();

    assert('a value' === $cache->recorded['a key']);

    // more assertions
}
~~~

<p>
    The above is obviously brought to extremes, but it highlights the added degrees of fredom that are introduced.
</p>

<p>
    Now imagine having to upgrade a test suite with 5000 tests, all depending on Facade spies
    and <code>Illuminate\Foundation\Testing\TestCase</code>: sounds fun? No? I had to do it, a few times,
    and I can also assure you it's not fun.
</p>

<h2>Disallowing facades</h2>

<p>
    From my point of view, Facades are technical debt, and of a particularly bad and sneaky kind.
</p>

<p>
    There is no reason to skip the extra legwork to keep a system simple: systems increase complexity
    over time by nature, and it is our job as software designers to keep it at bay.
</p>

<p>
    Introducing complexity for the sole purpose of some very questionable <abbr title="developer experience">DX</abbr>
    claims is therefore not acceptable, and is not something I accept in software systems that I manage.
</p>