---
layout: post
title: Delegator Factories in Zend Framework 2
category: PHP
tags: ["zf2", "zendframework2", "oop", "php"]
year: 2014
month: 3
day: 16
published: true
summary: Delegator Factories in Zend Framework 2
description: What are Delegator Factories? What are they good for? Why do I need them in my ZF2 apps?
tweet: 445250469188083713
---

<p>
    Last year, I
    <a href="https://github.com/zendframework/zf2/pull/4145" target="_blank">worked on a feature</a>
    for ZF2 called
    <a href="http://framework.zend.com/manual/2.3/en/modules/zend.service-manager.delegator-factories.html" target="_blank">
        "Delegator Service Factories"
    </a>, which was included in Zend Framework 2.2.0.
</p>
<p>
    It seems to me that many ZF2 developers either don't fully understand the feature,
    or do not know it.
</p>
<p>
    This article analyzes the feature in depth and tries to explain what these do, and why you may need them.
</p>

<hr/>

<h2>The Problem</h2>

<p>
    While working with <code>Zend\ServiceManager</code>, we often find ourselves in the need
    of overriding services provided by third-party modules that we use.
</p>

<p>
    Let's make a practical example and assume that we are using a <code>DbLoggingModule</code>.
    provided by a friendly open-source developer.
</p>

<p>
    The developer of <code>DbLoggingModule</code> provided us with an awesome service
    called <code>"DbLoggingModule\Logger"</code>, which is created by a service factory
    <code>DbLoggingModule\Factory\LoggerFactory</code>:
</p>


~~~php
<?php

class LoggerFactory implements FactoryInterface
{
    public function createService(ServiceLocatorInterface $sm)
    {
        $config = $sm->get('Config');
        $db     = new DB($config['db_logging']['dsn']);

        // more db configuration here

        $logger = new Logger($db);

        $logger->addFilter(new ErrorFilter());

        // more logger configuration here

        return $logger;
    }
}
~~~

<p>
    This is awesome and clean, but then we want to be able to log all errors by
    removing the pre-configured filters, or we want to add a formatter to our logger to add
    contextual information to the logged messages.
</p>

<p>
    This becomes tricky, since we now have to define our own factory for that logger:
</p>


~~~php
<?php

class MyLoggerFactory implements FactoryInterface
{
    public function createService(ServiceLocatorInterface $sl)
    {
        $config = $sl->get('Config');
        $db     = new DB($config['db_logging']['dsn']);

        // more db configuration here

        $logger = new Logger($db);

        // removing this: we don't filters
        // $logger->addFilter(new ErrorFilter());

        // this will add some context from the HTTP globals
        // ("eeew", but useful for our logged messages)
        $logger->addFormatter(new HttpRequestContextFormatter());

        // more logger configuration here

        return $logger;
    }
}
~~~

<p>
    This is fine, but our <code>MyLoggerFactory</code> <strong>duplicates a lot of code</strong> from
    <code>LoggerFactory</code>, and we now have to also strictly monitor any updates
    by the original developer of <code>DbLoggingModule</code>.
</p>

<p class="alert alert-danger">
    Code duplication is a huge problem, especially when we're localizing
    code from external dependencies.
</p>
<p>
    We can mitigate this issue by using an initializer instead:
</p>

~~~php
<?php

class MyLoggerInitializer implements InitializerInterface
{
    public function initialize($instance, ServiceLocatorInterface $sl)
    {
        if ($instance instanceof Logger) {
            $logger->clearFilters();
            $logger->addFormatter(new HttpRequestContextFormatter());
        }
    }
}
~~~

<p>
    This is a much cleaner approach, but there are major disadvantages as well:
</p>

<ul>
    <li>
        This initializer is being called <strong>once per each instantiated service</strong>,
        and that can lead to hundreds (seriously!) of useless method calls per request,
        and that for a single object that we wanted to change.
    </li>
    <li>
        <strong>All</strong> of our <code>Logger</code> instances are going to be affected
        by the change, and that is a big problem if we have more than one logger in the
        application.
    </li>
</ul>

<p class="alert alert-danger">
    That's pretty much <strong>technical debt</strong> that we are building up.
    We are being lazy, and we will pay for that if we go down this route.
</p>

<p>
    The solution for this particular problem is using "delegator factories".
</p>

<hr/>

<h2>What are delegator factories?</h2>

<p class="alert alert-success">
    A delegator factory is pretty much a wrapper around a real factory: it allows us
    to either replace the real service with a "delegate", or interact with an object
    produced by a factory before it is returned by the <code>Zend\ServiceManager</code>.
</p>

<p>
    In pseudo-code, a delegator-factory is doing following:
</p>

~~~javascript
service = delegatorFactory(factory());
~~~

<p>
    This is the interface for a delegator factory:
</p>

~~~php
<?php

namespace Zend\ServiceManager;

interface DelegatorFactoryInterface
{
    public function createDelegatorWithName(
        ServiceLocatorInterface $serviceLocator,
        $name,
        $requestedName,
        $callback
    );
}
~~~

<hr/>

<h2>Delegator Factories applied to the Logger problem</h2>

<p>
    This is how we would use it to modify our <code>"DbLoggingModule\Logger"</code> service:
</p>


~~~php
<?php

class LoggerDelegatorFactory implements DelegatorFactoryInterface
{
    public function createDelegatorWithName(
        ServiceLocatorInterface $serviceLocator,
        $name,
        $requestedName,
        $callback
    ) {
        $logger = $callback();

        $logger->clearFilters();
        $logger->addFormatter(new HttpRequestContextFormatter());

        return $logger;
    }
}
~~~

<p class="alert alert-info">
    <span class="label label-info">Note:</span> We are not using the first 3 parameters,
    which may be useful in different contexts (for example, when configuration is needed).
</p>

<p>
    We then add it to our service manager configuration to instruct the
    <code>Zend\ServiceManager</code> that we want our delegator factory to be used
    whenever the service <code>"DbLoggingModule\Logger"</code> is requested:
</p>

~~~php
<?php
return [
    'delegators' => [
        'DbLoggingModule\Logger' => [
            'LoggerDelegatorFactory',
            // can add more of these delegator factories here
        ],
    ],
];
~~~

<p>
    This will make the <code>Zend\ServiceManager</code> call the the
    <code>LoggerDelegatorFactory#createDelegatorWithName()</code> method
    whenever the service <code>"DbLoggingModule\Logger"</code> is instantiated,
    regardless if it is built via invokable, factory, peering service manager or
    abstract factory.
</p>

<p class="alert alert-info">
    <span class="label label-info">Hint:</span> You can define more of these delegator
    service factories for a single service, which allow you to override service
    instantiation logic in different modules and multiple
    times, leading to a very fine-grained configuration flexibility.
</p>

<p class="alert alert-info">
    <span class="label label-info">Hint:</span> Assuming that you want to completely replace the
    <code>"DbLoggingModule\Logger"</code> with your own custom implementation depending on
    context, you could also completely avoid using the provided <code>$callback</code>.
    This way, the original service won't even be instantiated.
</p>

<h2>On naming</h2>

<p>
    The name <q>delegator factory</q> is actually something I'm not happy with, since
    they are actually just wrappers around an existing factory.
</p>
<p class="alert alert-error">
    <span class="label label-warning">Warning:</span> Since I'm the first guy
    <a href="https://twitter.com/Ocramius/status/441673095662018561" target="_blank">to shout out at Laravel Facades</a>,
    I want to make it clear that the naming "Delegator Factory" is wrong, that
    it was my mistake, and I will likely fix it for ZendFramework 3.x.
</p>

<p>
    I initially designed these factories to solve a different problem, which is
    <a href="http://framework.zend.com/manual/2.3/en/modules/zend.service-manager.lazy-services.html" target="_blank">Lazy Services</a>.
</p>
<p>
    In the context of lazy services and decorators, the instance returned by these factories
    is indeed a
    "<a href="http://en.wikipedia.org/wiki/Delegation_pattern" target="_blank">delegate</a>",
    therefore I came up with the name "delegator factory".
</p>
<p>
    Only later on I realized that these factories are actually much more powerful than
    what I originally designed them for, therefore the "delegator factory" name became inadequate.
</p>

<hr/>

<h2>Conclusions</h2>

<p>
    Delegator factories are vital to any ZF2 hacker. Any developer working with <code>Zend\ServiceManager</code>
    should also be familiar with this functionality and its usage.
</p>

<p>
    Delegator factories are not a new concept. For instance, Pimple introduced this concept
    a while ago and (in a limited form): it is called
    "<a href="https://github.com/fabpot/Pimple#modifying-services-after-creation" target="_blank">extending a service</a>".
</p>

<p>
    The entire functionality was introduced by accident while I was working on an implementation of
    <a href="http://ocramius.github.io/blog/zf2-and-symfony-service-proxies-with-doctrine-proxies/" target="_blank">Lazy Services</a>,
    and they surely need a rename. This will not happen in Zend Framework 2.x.
</p>

<p>
    I hope this helps you with your day-to-day hacking around your ZF2 apps!
</p>
