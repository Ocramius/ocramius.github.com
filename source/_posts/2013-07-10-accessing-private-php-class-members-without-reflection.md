---
layout: post
title: Accessing private PHP class members without reflection
category: PHP
tags: ["php", "oop", "access", "property", "reflection", "private"]
year: 2013
month: 7
day: 10
published: true
summary: Getting access to private class members in PHP (without reflection)
description: A trick to use PHP 5.4 closure functionalities to get access to
tweet: 354936007868686337
---

<p>
    A couple of weeks ago I was working on a
    <a href="https://github.com/Ocramius/ProxyManager/issues/62" target="_blank">very tricky issue</a> on
    <a href="https://github.com/Ocramius/ProxyManager" target="_blank">ProxyManager</a>.
</p>
<p>
    The problem is simple: instantiating
    <a href="http://php.net/manual/en/class.reflectionclass.php" target="_blank">ReflectionClass</a> or
    <a href="http://php.net/manual/en/class.reflectionproperty.php" target="_blank">ReflectionProperty</a> is
    slow, and by slow, I mean <strong>really slow!</strong>
</p>
<p>
    The reason for this reasearch is that I'm trying to optimize a
    "<a href="http://framework.zend.com/manual/2.2/en/modules/zend.stdlib.hydrator.html" target="_blank">hydrator</a>"
    to work with larger data-sets by still keeping a low initialization overhead.
</p>

<hr/>

<h2>PHP 5.4 to the rescue!</h2>

<p>
    PHP 5.4 comes with a new API for Closures, which is
    <a href="http://php.net/manual/en/closure.bind.php" target="_blank"><code>Closure#bind()</code></a>.
</p>

<p>
    <code>Closure#bind()</code> basically allows you to get an instance of a closure with the scope of a given
    object or class. Neat! That's basically like adding APIs to existing objects!
</p>

<p>
    Let's break some OOP encapsulation to fit our needs.
</p>

<p>
    The techniques to access private members are already explained on the PHP manual, but I am going to make a
    simplified example anyway.
</p>
<p>
    Here's what you have to do to steal <code>Kitchen#yummy</code> from following object:
</p>

~~~php
<?php

class Kitchen
{
    private $yummy = 'cake';
}
~~~

<p>
    First of all, let's define a closure to read the property as if we had access to it:
</p>

~~~php
<?php

$sweetsThief = function (Kitchen $kitchen) {
    return $kitchen->yummy;
}
~~~

<p>
    Let's use it to steal some <code>yummy</code> stuff from the <code>Kitchen</code>:
</p>

~~~php
<?php

$kitchen = new Kitchen();

var_dump($sweetsThief($kitchen));
~~~

<p>
    Sadly, this <a href="http://3v4l.org/ET06l" target="_blank">will result</a> in <code>$sweetsThief</code>
    being caught with a fatal error that looks like following:
</p>

~~~php
Fatal error: Cannot access private property Kitchen::$yummy in [...] on line [...]
~~~

<p>
    Let's use <code>Closure#bind()</code> to make our thief smarter:
</p>

~~~php
<?php

$kitchen = new Kitchen();

// Closure::bind() actually creates a new instance of the closure
$sweetsThief = Closure::bind($sweetsThief, null, $kitchen);

var_dump($sweetsThief($kitchen));
~~~

<p>
    <a href="http://3v4l.org/2E2mr" target="_blank">Success</a>! We can now get to the <code>cake</code>!
</p>

<hr/>

<h2>Changing closure scope vs. Reflection: performance</h2>

<p>
    How does this technique compare with <code>ReflectionProperty#getValue()</code>? Is it actually faster?
</p>

<p>
    I've built a simple benchmark to profile the "setup" step for this trick over 100000 iterations:
</p>

~~~php
<?php

for ($i = 0; $i < 100000; $i += 1) {
    $sweetsThief = Closure::bind(function (Kitchen $kitchen) {
        return $kitchen->yummy;
    }, null, 'Kitchen');
}
~~~

~~~php
<?php

for ($i = 0; $i < 100000; $i += 1) {
    $sweetsThief = new ReflectionProperty('Kitchen', 'yummy');
    $sweetsThief->setAccessible(true);
}
~~~

<p>
    On a freshly compiled PHP 5.5 (Ubuntu 13.04 amd64 box), the fist script takes around
    <strong>0.325</strong> seconds to run, while the second one requires <strong>0.658</strong> seconds.
</p>

<p>
    <strong>Reflection is much slower</strong> here.
</p>

<p>
    That's completely un-interesting though, since nobody will ever instantiate 100000 reflection properties,
    or at least I cannot find a good reason to do that.
</p>

<p>
    What seems to be more interesting is how <strong>accessing properties</strong> compares. I've profiled
    that too:
</p>


~~~php
<?php

$kitchen = new Kitchen();

$sweetsThief = Closure::bind(function (Kitchen $kitchen) {
    return $kitchen->yummy;
}, null, 'Kitchen');

for ($i = 0; $i < 100000; $i += 1) {
    $sweetsThief($kitchen);
}
~~~

~~~php
<?php

$kitchen = new Kitchen();

$sweetsThief = new ReflectionProperty('Kitchen', 'yummy');
$sweetsThief->setAccessible(true);

for ($i = 0; $i < 100000; $i += 1) {
    $sweetsThief->getValue($kitchen);
}
~~~

<p>
    The first script took <strong>~ 0.110</strong> seconds to run, while the second one needed
    <strong>~ 0.199</strong> seconds!
</p>

<p>
    We are actually <strong>much faster than reflection</strong>! Impressive!
</p>

<hr/>

<h2>Accessing private class properties by reference</h2>

<p>
    There's actually one big advantage in using a Closure instead of ReflectionProperty, which is that you can
    now <a href="http://3v4l.org/W12Hf" target="_blank">retrieve a private property by reference</a>!
</p>

~~~php
<?php

$sweetsThief = Closure::bind(function & (Kitchen $kitchen) {
    return $kitchen->yummy;
}, null, $kitchen);


$cake = & $sweetsThief($kitchen);
$cake = 'lie';

var_dump('the cake is a ' . $sweetsThief($kitchen));
~~~

<hr/>

<h2>A generic property reader abstraction</h2>

<p>
    With all these new concepts we can write a very simplified accessor that allows us to read any property
    of any object:
</p>

~~~php
<?php

$reader = function & ($object, $property) {
    $value = & Closure::bind(function & () use ($property) {
        return $this->$property;
    }, $object, $object)->__invoke();

    return $value;
};

$kitchen = new Kitchen();
$cake    = & $reader($kitchen, 'cake');
$cake    = 'sorry, I ate it!';

var_dump($kitchen);
~~~

<p>
    Here's the <a href="http://3v4l.org/JE0eX" target="_blank">working example</a>.
</p>

<p>
    That's it: accessing any property, anywhere, and that even by reference! Success! We have broken the rules
    once again!
</p>

<p>
    I won't cover the "writing properties" part, nor handling inherited private properties,
    since that's just details of this basic trick that need more code and are un-interesting to us.
</p>

<hr/>

<h2>Conclusion</h2>

<p>
    Yet another time, PHP shows its best and worst aspects all together. It's a horrible language with a
    horrible syntax, but it allows us to write amazing code and to run around a huge number of language
    limitations by just providing new and awesome features at every release!
</p>

<p>
    I won't use this technique myself, but it was interesting to dive into it, and it will become useful again
    if I need to get references to private/protected class members in my crazy proxy projects.
</p>

<p>
    I should hereby add a disclaimer: <strong>use with caution!</strong>
</p>

<h2>Errata</h2>

<p>
    In the first version of the article that was published 2013-07-10, I actually stated that Reflection
    was faster: that's not true and is the result of a mistake that I made while running the tests, since
    I was running a PHP version with loads of extensions that were affecting the results.
</p>
<p>
    I have created a virtual machine with a clean 5.5 PHP build to get accurate results, which demonstrate
    that <strong>Reflection is actually slower than closures in every case</strong>.
</p>

<p>
    I also wrote a very small set of benchmarks that you may find
    <a href="https://github.com/Ocramius/ocramius.github.com/tree/master/benchmarks/2013-07-10-accessing-private-php-class-members-without-reflection" target="_blank">
    in the blog repository</a>
</p>
