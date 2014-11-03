---
layout: post
title: Property Accessors in PHP Userland
category: PHP
tags: ["php", "oop", "access", "property accessors"]
year: 2013
month: 6
day: 30
published: true
summary: Implementing Property Accessors in PHP
description: A simple technique to use PHP's OOP implementation to intercept access to object public properties
tweet: 351660814790438913
---

<p>
    Some time ago many people were disappointed by the fact that
    <a href="https://wiki.php.net/rfc/propertygetsetsyntax-v1.2" target="_blank">PHP wasn't going to have
    property accessors</a>, which are a very cool feature and would have helped a lot in reducing
    boilerplate code in a lot of applications and frameworks.
</p>

<p>
    Last October I learned from
    <a href="https://twitter.com/lsmith" target="_blank">Lukas Smith</a>
    about a trick that he used to discover when a public property of an object was being accessed.
    <br/>
    He mainly used the trick that I'm going to show to handle lazy-loading within
    <a href="https://github.com/doctrine/phpcr-odm" target="_blank">PHPCR ODM</a>.
</p>

<p>
    The trick basically allows to implement property accessors in userland code by exploiting how PHP
    handles object properties internally.
</p>

<p>
    I never got back to writing a blogpost about it, but here it finally is!
</p>

<p>
    Here's a very simple example:
</p>

~~~php
<?php

class Foo
{
    public $publicProperty = 'baz';
}
~~~

<p>
    What we want is some way to know whenever somebody writes or reads property <code>$publicProperty</code>
    from our object.
</p>

<p>
    In order to do so, we can use a simple wrapper for our <code>Foo</code> object. Because we want to
    respect the <a title="Liskov Substitution Principle" href="http://en.wikipedia.org/wiki/Liskov_substitution_principle" target="_blank">LSP</a>,
    we have this wrapper extending <code>Foo</code>:
</p>

~~~php
<?php

class FooWrapper extends Foo
{
    public function __construct()
    {
        unset($this->publicProperty);
    }
}
~~~

<p>
    That's it so far! Let's try it out:
</p>

~~~php
<?php

$foo = new FooWrapper();

echo $foo->publicProperty;
~~~

<p>
    Weirdly, this <a href="http://3v4l.org/gRtoj" target="_blank">will produce</a>
    something like following:
</p>

<pre class="prettyprint linenums">Notice: Undefined property: FooWrapper::$publicProperty in [...]</pre>

<p>
    That basically means the property was not just set to <code>NULL</code>, but completely removed!
</p>

<p>
    Let's use this at our own advantage by tweaking <code>FooWrapper</code> a bit:
</p>

~~~php
<?php

class FooWrapper extends Foo
{
    private $wrapped;

    public function __construct(Foo $wrapped)
    {
        $this->wrapped = $wrapped;

        unset($this->publicProperty);
    }

    public function __get($name)
    {
        echo 'Getting property ' . $name . PHP_EOL;

        return $this->wrapped->$name;
    }

    public function __set($name, $value)
    {
        echo 'Setting property ' . $name . ' to ' . $value . PHP_EOL;

        return $this->wrapped->$name = $value;
    }
}
~~~
<p>
    And here again, let us try it out:
</p>

~~~php
<?php

$foo = new FooWrapper(new Foo());

echo $foo->publicProperty;
echo PHP_EOL;
echo $foo->publicProperty = 'test';
~~~

<p>
    This <a href="http://3v4l.org/mmMZU" target="_blank">will produce</a> following output:
</p>

~~~sh
Getting property publicProperty
baz
Setting property publicProperty to test
test
~~~

<p>
    Cool, huh? And the same works with <code>__isset</code> and <code>__unset</code> too!
</p>

<p>
    This doesn't really replace property accessors, but it gives us a way of protecting access to public
    properties via composition, inheritance and a bit of hacking.
</p>

<p>
    There's not many use cases for this right now, since you have to write a lot of boilerplate code for
    it to work correctly.
</p>
<p>
    It is worth mentioning that this logic has been used to make
    <a href="http://doctrine-project.org/" target="_blank">Doctrine 2.4</a> even more awesome.
    I also wrote a component called
    <a href="https://github.com/Ocramius/ProxyManager" target="_blank">ProxyManager</a>,
    which avoids you from writing all the boilerplate code over and over again, so check it out!
</p>

<p>
    Here's how the code from before rewritten using ProxyManager 0.4:
</p>

~~~php
<?php

use ProxyManager\Configuration;
use ProxyManager\Factory\AccessInterceptorValueHolderFactory as Factory;

require_once __DIR__ . '/vendor/autoload.php';

class Foo
{
    public $publicProperty = 'baz';
}

$config  = new Configuration();
$factory = new Factory($config);

$foo = $factory->createProxy(
    new Foo(),
    array(
        '__get' => function ($proxy, $instance, $method, $params) {
            echo 'Getting property ' . $params['name'] . PHP_EOL;
        },
        '__set' => function ($proxy, $instance, $method, $params) {
            echo 'Setting property ' . $params['name'] . ' to ' . $params['value'] . PHP_EOL;
        }
    )
);

echo $foo->publicProperty;
echo PHP_EOL;
echo $foo->publicProperty = 'test';
~~~

<p>
    Give it a try and drop me a line if you like it or hate it!
</p>
