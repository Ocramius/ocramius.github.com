---
layout: post
title: Dependency Injection slowness solved by Doctrine Proxies
category: PHP
tags: zend zendframework zf2 symfony doctrine dependency injection service location proxies
year: 2012
month: 11
day: 19
published: true
summary: An explanation of how Doctrine Proxies work to enhance Zend Framework 2 and Symfony 2 services
tweet: 270851711395045377
---

<h2>Dependency Injection Containers and Performance</h2>

<p>
    <a href="http://en.wikipedia.org/wiki/Dependency_injection" target="_blank">Dependency Injection Containers</a>
    are a vital tool for developers of complex and modular applications.
    <br/>
    Using a Dependency Injection Container in your application brings you great benefits, allowing you to compose
    complex object graphs without compromises or unnecessary ugliness (i.e. static methods).
</p>
<p>
    By using a Dependency Injection Container you automatically gain some unlocked benefits:
</p>
<dl>
    <dt><strong>Absence of hardcoded dependencies</strong>:</dt>
    <dd>
        Your objects do not handle instantiation of their dependencies, so you have one less problem to handle.
    </dd>
    <dt><strong>Better separation of concerns</strong>:</dt>
        <dd>
            Splitting problems across multiple objects becomes easier as the container helps you gluing them all
            together.
        </dd>
    <dt><strong>Mocking is much easier</strong>:</dt>
    <dd>
        Since you compose your instances with other dependencies that solve
        small problems, mocking those objects becomes really easy, and so writing tests for your application.
    </dd>
</dl>
<p>
    But there is one major pitfall: since your objects do not handle instantiation of their dependencies anymore
    <strong>you are now building huge object graphs, even if you're not using all of those objects</strong>.
    <br/>
    Take for example the following code:
</p>

~~~php
<?php

class A {}

class B {}

class C {}

class D {
    public function __construct(A $a, B $b, C $c)
    {
        // ...
    }
}

class HelloWorld
{
    public function __construct(D $d)
    {
        // ...
    }

    public function sayHello()
    {
        return 'Hello World';
    }
}
~~~
<p>
    The example is obviously nonsense, but this actually happens in your MVC controllers, where you may have 3 or 4
    actions and none of them using all of the dependencies of the controller itself.
</p>
<p>
    As you notice, to call <code>HelloWorld#sayHello()</code> we are required to instantiate 5 objects:
    <code>A</code>, <code>B</code>, <code>C</code>, <code>D</code>, <code>HelloWorld</code>.
</p>
<p>
    While this is robust code that will hardly break if <code>A</code>, <code>B</code>, <code>C</code> and
    <code>D</code> are correctly unit-tested, we are obviously having performance issues.
    <br/>
    Those issues become particularly noticeable when one of these objects needs to allocate a lot of resources or
    to perform costly operations such as opening a file or a socket to a remote machine.
</p>
<p>
    Using pure dependency injection yields stability, but introduces performance drawbacks, especially in
    PHP, where the object graph is rebuilt on each dispatched request.
</p>

<hr/>

<p><br/></p>

<h2>Service Location (to the rescue?)</h2>

<p>
    To solve the performance issues, some may be tempted to start using a
    <a href="http://martinfowler.com/articles/injection.html#UsingAServiceLocator" target="_blank">Service Locator</a>
    within their services:
</p>
~~~php
<?php

class HelloWorld
{
    public function __construct(ServiceLocator $serviceLocator)
    {
        $this->serviceLocator = $serviceLocator;
    }

    public function sayHello()
    {
        return 'Hello World';
    }

    public function doSomethingWithD()
    {
        if ( ! $this->d) {
            $this->d = $this->serviceLocator->get('D');
        }

        $this->d->doSomething();
    }
}
~~~
<p>
    As you have noticed, this solves the performance issue by allowing us to retrieve an instance of <code>D</code>
    <strong>only when we really need it</strong>:
    <br/>
    performance!
</p>
<p>
    Anyway, by doing so we introduced some new problems:
</p>
<dl>
    <dt><strong>Our object cannot exist without a service locator</strong>:</dt>
    <dd>
        makes testability hard, since we will need to mock the service locator in order to test
        <code>HelloWorld</code>, and mocking a service locator is not so easy.
    </dd>
    <dt><strong>Our object depends on the implementation of the service locator</strong>:</dt>
    <dd>
        portability of our code is reduced, since it will work only with a specific service locator implementing the
        <code>ServiceLocator</code> contract.
    </dd>
    <dt><strong>Instantiation of dependencies moved to our code</strong>:</dt>
    <dd>
        instantiation of <code>D</code> should not be a problem solved by our code. We introduced it in our code
        now, so we must test it.
    </dd>
    <dt><strong>Hardcoded service name in our code</strong>:</dt>
    <dd>
        This makes our class very error prone if we don't write extensive integration tests each time we ship our
        code. Also, it makes our code incompatible with anything sharing the same
        <code>ServiceLocator</code> instance and requiring an instance named <code>'D'</code>, but with different
        expectations.
    </dd>
</dl>
<p>
    We solved a performance problem to introduce at least <strong>4 new ones!</strong>
    <br/>
    Not really nice, eh? Not at all.
</p>
<p>
    If you are already using service location, <strong>STOP DOING IT NOW</strong> and please read the rest of this
    post.
</p>

<p>
    There must be a <em>better</em> solution... After all, what we want to avoid is instantiating
    <code>A</code>, <code>B</code>, <code>C</code>, <code>D</code> alltogether if we aren't using them.
    <br/>
    Doesn't sound to be so hard!
</p>

<hr/>
<p><br/></p>

<h2>Doctrine Proxies to the rescue!</h2>
<p>
    The idea is not new, and <a href="http://pooteeweet.org/" target="_blank">Lukas Smith</a> already
    <a href="https://github.com/symfony/symfony/issues/5012" target="_blank">discussed it on the Symfony2 issue
    tracker</a>.
</p>
<p>
    Since I was already playing around with code generation for doctrine, I decided to implement those concepts
    with <strong>Doctrine Proxies</strong>.
</p>

<hr/>
<p><br/></p>

<h2>What are Doctrine Proxies?</h2>
<p>
    <a href="https://github.com/Ocramius/common/blob/DCOM-96/lib/Doctrine/Common/Proxy/Proxy.php"
    target="_blank">Doctrine Proxies</a> are a PHP implementation of the
    <a href="http://en.wikipedia.org/wiki/Proxy_pattern" target="_blank">proxy pattern</a> used to achieve
    <a href="http://www.martinfowler.com/eaaCatalog/lazyLoad.html" target="_blank">lazy loading</a> of objects from
    a persistent storage.
    <br/>
    Doctrine implements this pattern by having <strong>Virtual Proxies</strong> that behave like
    <strong>Ghost Objects</strong>.
</p>
<p>
    The concept behind proxies is quite simple: each time a method of the proxy is called, if the proxy is not
    initialized, initialization logic is triggered (which usually corresponds to filling its fields with data
    coming from a DB).
    <br/>
    After that, the original code that was supposed to be executed with that method call is run.
</p>
<p>
    This is achieved by Doctrine by generating a class that inherits from the original object and faking all of
    its public API and adding the required code to trigger lazy loading:
</p>
~~~php
<?php

class UserProxy extends User
{
    protected $initialized = false;

    public function getUsername()
    {
        if ( ! $this->initialized) {
            initialize($this);
        }

        return parent::getUsername();
    }
}
~~~
<p>
    The previous snippet is just a simplified example, and isn't very flexible, but as you may know, Doctrine is a
    set of libraries focusing on persistence of data, and the
    <a href="https://github.com/doctrine/common/blob/8b403cde97eaede30bd79acab4f18895fd5bdf27/lib/Doctrine/Common/Persistence/Proxy.php"
    target="_blank">first version of proxies</a> was highly focused on supporting the purpose of loading an object
    from a database.
</p>
<p>
    The implementation has been enhanced with <a href="https://github.com/doctrine/common/pull/168" target="_blank">
    a patch I'm working on</a>, now allowing many different uses of the proxy pattern. This is mainly possible
    because of <a href="http://php.net/manual/en/functions.anonymous.php" target="_blank">lambda functions</a>
    used as initialization logic holders:
</p>
~~~php
<?php

class UserProxy extends User
{
    /** @var Closure */
    protected $initializer;

    public function __setInitializer(Closure $initializer)
    {
        $this->initializer = $initializer;
    }

    public function getUsername()
    {
        if ($this->initializer !== null) {
            call_user_func($this->initializer);
        }

        return parent::getUsername();
    }
}
~~~
<p>
    Using a <a href="http://php.net/manual/en/class.closure.php" target="_blank">Closure</a> as an initializer
    now enables us to swap the initialization logic used for our proxy object. I won't get into details, but this
    is a requirement for our next step.
</p>

<hr/>
<p><br/></p>

<h2>Why proxies?</h2>

<p>
    Let's get back to the example with <code>A</code>, <code>B</code>, <code>C</code>, <code>D</code>,
    <code>HelloWorld</code>, but we'll introduce a proxy now:
</p>
~~~php
<?php

class A {}

class B {}

class C {}

class D
{
    public function __construct(A $a, B $b, C $c)
    {
        // ...
    }

    public function doSomething()
    {
        return 'Did something with ' . $this->a . ', ' . $this->b . ', ' . $this->c;
    }
}

class D_Proxy extends D
{
    private $serviceLocator;
    private $original;

    public function __construct(ServiceLocator $serviceLocator)
    {
        $this->serviceLocator = $serviceLocator;
    }

    private function initialize()
    {
        $this->initialized = true;
        $this->original    = $this->serviceLocator->get('D');
    }

    public function doSomething()
    {
        if ( ! $this->initialized) {
            $this->initialize();
        }

        return $this->original->doSomething();
    }
}

class HelloWorld
{
    public function __construct(D $d)
    {
        // ...
    }

    public function sayHello()
    {
        return 'Hello World';
    }

    public function doSomethingWithD()
    {
        return $this->d->doSomething();
    }
}
~~~

<p>
    Wait... What? Ok, let's slow this down a bit:
</p>
<ol>
    <li>
        You can now pass an instance of <code>D_Proxy</code> to <code>HelloWorld</code>. Since <code>D_Proxy</code>
        extends <code>D</code>, it respects the <a href="http://en.wikipedia.org/wiki/Liskov_substitution_principle"
        target="_blank">Liskov substitution principle</a>.
    </li>
    <li>
        The proxy is uninitialized, and it is empty (we have replaced its constructor).
    </li>
    <li>
        When <code>doSomething</code> is called on the proxy, the real instance of <code>D</code> is retrieved
        from a service locator, and put into the <code>original</code> property.
    </li>
    <li>
        The method call is proxied to <code>$this->original->doSomething();</code>.
    </li>
    <li>
        Since the original object is fully populated with instances of <code>A</code>, <code>B</code> and
        <code>C</code>, code works as expected.
    </li>
</ol>
<p>
    We successfully avoided instantiating <code>A</code>, <code>B</code>, <code>C</code> and <code>D</code> when
    calling <code>sayHello</code>! <em>Awesome!</em>
</p>

<p>
    But wait: didn't I just say that service location is evil?
</p>
<p>
    Yes it is, but <code>D_Proxy</code> is generated code (don't worry about how it is generated) and:
</p>
<ul>
    <li>
        Its code generation is based on how the dependency injection container defined that <code>D</code> should
        be instantiated, thus the hardcoded <code>'D'</code> within the proxy code comes from the current DIC
        definitions. This allows it to have our DIC handling collisions between service names, and hardcoded
        magic strings disappear from our code base.
    </li>
    <li>
        It abstracts the problem of lazy initialization of a service for us. The generated code doesn't need
        to be tested as that is something done by the implementor of the proxy generator (me).
    </li>
    <li>
        It has the same performance impact of introducing lazy initialization logic in our classes' methods (similar
        amount of system calls).
    </li>
    <li>
        Turning on or off proxies does not change the functionality provided by our applications. They're just
        a performance tweak. They do not affect how our logic is dispatched.
    </li>
    <li>
        Proxies actually allow cyclic dependencies. Since objects are lazily initialized, if <code>A</code> depends
        on <code>B</code>, and <code>B</code> depends on <code>A</code>, and one of those two is proxied, the lazy
        initialization mechanism will prevent us from triggering an infinite loop in our instantiation logic. This
        is actually a thing I didn't think of initially, but it turns out to be a nice and powerful side effect.
    </li>
</ul>

<hr/>

<h2>General usage directions</h2>
<p>
    Proxies also have some limitations though:
</p>

<dl>
    <dt><strong>Cannot benefit from the initializer pattern/setter injection</strong>:</dt>
    <dd>
        since any call to a proxy method that isn't its constructor would cause its initialization, setter injection
        cannot be used on a proxy, or it will basically render the underlying idea of performance tweak useless.
    </dd>
    <dt><strong>Cannot proxy dynamic services</strong>:</dt>
    <dd>
        you can apply this proxy pattern only when assuming that calling <code>$serviceLocator-&gt;get('D');</code>
        will actually return an instance of <code>D</code>. If the return type varies depending on i.e. environment
        variables, this code will break.
    </dd>
    <dt><strong>Must be synchronized</strong>:</dt>
    <dd>
        changing implementation of our services requires us to re-generate proxies so that they respect the contract
        of the service class. Since generated code in PHP is hard to put into a cache (because opcode caches cannot
        act on serialized data) we need to save proxies to predictable location in our system in order to autoload
        them and avoid generating them over and over. That also means that we have to delete them when we change our
        code, so that we can let the generator rewrite them.
    </dd>
    <dt><strong>Add constant overhead to method calls</strong>:</dt>
    <dd>
        If your object is lightweight, you may not need to proxy it, especially if its methods get called thousands
        of times.
    </dd>
</dl>

<hr/>
<p><br/></p>

<h2>Examples/benchmarks</h2>

<ul>
    <li>
        If you want to read further on the proxy implementation I proposed for Zend Framework 2 you can check the
        <a href="https://github.com/zendframework/zf2/pull/2995" target="_blank">corresponding pull request</a>.
    </li>
    <li>
        If you are interested in how proxy generation works in Doctrine, you can check
        <a href="https://github.com/doctrine/common/pull/168" target="_blank">my current work</a> on doctrine common.
    </li>
    <li>
        If performance is your concern, read about the results of the last PHPPeru hack day I had with cordoval in
        <a href="http://www.craftitonline.com/2012/11/lazy-load-services-and-do-not-inject-the-container-into-them/"
        target="_blank">his blog</a>.
    </li>
    <li>
        I am also starting work to implement this idea for Symfony 2 too. Not quite there yet :-)
    </li>
</ul>

<hr/>
<p><br/></p>

<h2>Conclusions</h2>

<p>
    I can conclude that the proxies are a good solution to solve the performance issues that are introduced by
    Dependency Injection Containers. They also allow us to completely get rid of service location and to focus
    on writing clean and robust classes that are easy to test.
</p>
<p>
    They surely add some hidden magic to our code, and I've been already told by <a href="http://mwop.net/" target="_blank">
    Matthew Weier 'o Phinney</a> that some newcomers may be confused by the additional calls they will in stack
    traces when looking at exceptions. Since proxies are an optional feature, I'm not really concerned about it.
</p>
<p>
    I also worked with <a href="http://www.craftitonline.com/2012/11/lazy-load-services-and-do-not-inject-the-container-into-them/"
    target="_blank">Luis Cordova</a> in organizing the topics for the last PHPPeru hack day, and the participants
    didn't have big problems in understanding the problems and solutions suggested by the proxy approach, so I'm
    quite confident about having it adopted in ZF2 and SF2 soon.
</p>
<p>
    Anyway, proxies are not a requirement to get our application working. They are just steroids for our services,
    and I'd surely suggest you to use them.
</p>
