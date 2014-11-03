---
layout: post
title: Fluent Interfaces are Evil
category: PHP
tags: ["php", "oop", "patterns"]
year: 2013
month: 11
day: 07
published: true
summary: Fluent Interfaces - what harm could they cause?
description: Fluent Interfaces break encapsulation, mocking, diffs and readability - be warned
tweet: 399854614503108608
---

<p>
    Today, I had again a discussion on IRC on why
    <a href="https://github.com/doctrine/doctrine2/blob/2.4/lib/Doctrine/ORM/EntityManager.php" target="_blank">
        Doctrine's EntityManager
    </a> doesn't (and won't) implement a fluent interface. Here are my thoughts on why that's the case.
</p>

<hr/>

<h2>Recap: What is a Fluent interface?</h2>

<p>
    A <a href="http://en.wikipedia.org/wiki/Fluent_interface" target="_blank">Fluent Interface</a>
    is an object oriented API that provides "more readable" code.
    <br/>
    In general, the template for a fluent interface can be like following:
</p>
~~~php
<?php

interface {InterfaceName}
{
    /** @return self */
    public function {MethodName}({Params});
}
~~~

<p>
    Obviously, PHP doesn't provide return type hints, which means that I limited myself to define a
    <code>/** @return self */</code>
    <a href="http://www.phpdoc.org/docs/latest/for-users/tags/return.html" target="_blank">docblock</a>.
</p>

<p>
    A fluent interface allows you to chain method calls, which results in less typed characters
    when applying multiple operations on the same object:
</p>

~~~php
<?php

$foo
    ->doBar()
    ->doBaz()
    ->setTaz('taz')
    ->otherCall()
    ->allTheThings();
~~~

<hr/>

<h2>When does a fluent interface make sense?</h2>

<p>
    Fluent interfaces make sense in some APIs, like the
    <a href="https://github.com/doctrine/doctrine2/blob/2.4/lib/Doctrine/ORM/EntityManager.php" target="_blank">
        QueryBuilder
    </a>, or in general builder objects, especially when it comes to putting together nodes into
    a hierarchical structure.
</p>

<p>
    Here's an example of good usage of a fluent interface:
</p>

~~~php
<?php

$queryBuilder
    ->select('u')
    ->from('User u')
    ->where('u.id = :identifier')
    ->orderBy('u.name', 'ASC')
    ->setParameter('identifier', 100);
~~~

<hr/>

<h2>What's the problem with fluent interfaces?</h2>

<p>
    I've identified some issues while working with fluent interfaces. Here they are listed in
    descending order of relevance:
</p>

<ol>
    <li>
        Fluent Interfaces break
        <a href="http://en.wikipedia.org/wiki/Encapsulation_%28object-oriented_programming%29" target="_blank">
            Encapsulation
        </a>
    </li>
    <li>Fluent Interfaces break Decorators (and sometimes Composition)</li>
    <li>Fluent Interfaces are harder to Mock</li>
    <li>Fluent Interfaces make diffs harder to read</li>
    <li>Fluent Interfaces are less readable (personal feeling)</li>
</ol>

<hr/>

<h2>Fluent Interfaces break Encapsulation</h2>

<p>
    The entire idea behind a fluent interface bases on an assumption:
</p>

<blockquote>
    In a Fluent Interface, the return value of a method will be the same instance on which the method was called.
</blockquote>

<p>
    First of all, "assuming" facts that are not safely constrained by the language is a mistake.
    <br/>
    Additionally, in OOP, you cannot rely on the identity of the returned value of an object, but just on its
    interface.
</p>

<p>
    What does that mean? Let's make an example with a <code>Counter</code> interface:
</p>

~~~php
<?php

interface Counter
{
    /** @return self */
    public function count();

    /** @return int */
    public function getCount();
}
~~~

<p>Here's a fluent implementation of the interface:</p>

~~~php
<?php

class FluentCounter implements Counter
{
    private $count = 0;

    public function count()
    {
        $this->count += 1;

        return $this;
    }

    public function getCount()
    {
        return $this->count;
    }
}
~~~

<p>
    Here's an Immutable implementation of the interface:
</p>

~~~php
<?php

class ImmutableCounter implements Counter
{
    private $count;

    public function __construct($count = 0)
    {
        $this->count = (int) $count;
    }

    public function count()
    {
        return new ImmutableCounter($this->count + 1);
    }

    public function getCount()
    {
        return $this->count;
    }
}
~~~

<p>
    Here is how you <a href="http://3v4l.org/l5rr0" target="_blank">use a <code>FluentCounter</code></a>:
</p>

~~~php
<?php

$counter = new FluentCounter();

echo $counter->count()->count()->count()->getCount(); // 3!
~~~

<p>
    Here is how you <a href="http://3v4l.org/AP62m" target="_blank">use an <code>ImmutableCounter</code></a>:
</p>

~~~php
<?php

$counter = new ImmutableCounter();

$counter = $counter->count()->count()->count();

echo $counter->getCount(); // 3!
~~~

<p>
    We managed to implement an immutable counter even though the author of <code>Counter</code> maybe
    assumed that all implementations should be mutable.
</p>
<p>
    The same can be seen in the opposite direction: interface author may want to have all implementations
    immutable, but then people implement a mutable version of it.
</p>
<p>
    Turns out that the only correct way of
    <a href="http://3v4l.org/fILUc" target="_blank">using such an interface</a>
    is the "immutable" way, so:
</p>

~~~php
<?php

$counter = $counter->count()->count()->count();

echo $counter->getCount(); // 3!
~~~

<p>
    This ensures that <code>FluentCounter#getCount()</code> works as expected, but obviously defeats the
    purpose of the fluent interface.
</p>

<p>
    On top of that, there is nothing that the author of <code>Counter</code> can do to enforce either one or
    the other way of implementing the contract, and that's a limitation of the language itself (and it's
    most probably for good!).
</p>

<p>
    None of the implementors/implementations are wrong. What is wrong here is the interface by trying to
    force implementation details, therefore breaking encapsulation.
</p>

<p>Wrapping it up:</p>

<ul>
    <li>In OOP, a contract cannot guarantee the identity of a method return value</li>
    <li>Therefore, In OOP, fluent interfaces cannot be guaranteed by a contract</li>
    <li>Assumptions not backed by a contract are wrong</li>
    <li>Following wrong assumptions leads to wrong results</li>
</ul>

<hr/>

<h2>Fluent Interfaces break Decorators (and Composition)</h2>

<p>
    As some of you may know, I'm putting a lot of effort in writing libraries that
    <a href="https://github.com/Ocramius/ProxyManager/" target="_blank">generate decorators and proxies</a>.
    <br/>
    While working on those, I came to a very complex use case where I needed to build a generic wrapper around
    an object.
</p>

<p>
    I'm picking the <code>Counter</code> example again:
</p>

~~~php
<?php

interface Counter
{
    /** @return self */
    public function count();

    /** @return int */
    public function getCount();
}
~~~

<p>
    Assuming that the implementor of the wrapper doesn't know anything about the implementations of this
    interface, he goes on and builds a wrapper.
</p>
<p>
    In this example, the implementor simply writes a wrapper that echoes every time one of the methods is called:
</p>

~~~php
<?php

class EchoingCounter implements Counter
{
    private $counter;

    public function __construct(Counter $counter)
    {
        $this->counter = $counter;
    }

    public function count()
    {
        echo __METHOD__ . "\n";

        return $this->counter->count();
    }

    public function getCount()
    {
        echo __METHOD__ . "\n";

        return $this->counter->getCount();
    }
}
~~~

<p>
    Let's <a href="http://3v4l.org/i5m5r" target="_blank">try it out with our fluent counter</a>:
</p>

~~~php
<?php

$counter = new EchoingCounter(new FluentCounter());

$counter = $counter->count()->count()->count()->count();

echo $counter->getCount();
~~~

<p>
    Noticed anything wrong? Yes, the string
    <strong><code>"EchoingCounter::count"</code> is echoed only once!</strong>
</p>

<p>
    That happens because we're just trusting the interface, so the <code>FluentCounter</code> instance
    gets "un-wrapped" when we call <code>EchoingCounter::count()</code>.
</p>

<p>
    Same happens when
    <a href="http://3v4l.org/bUMJ7" target="_blank">using the <code>ImmutableCounter</code></a>
</p>

~~~php
<?php

$counter = new EchoingCounter(new ImmutableCounter());

$counter = $counter->count()->count()->count()->count();

echo $counter->getCount();
~~~

<p>Same results. Let's try to fix them:</p>

~~~php
<?php

class EchoingCounter implements Counter
{
    private $counter;

    public function __construct(Counter $counter)
    {
        $this->counter = $counter;
    }

    public function count()
    {
        echo __METHOD__ . "\n";

        $this->counter->count();

        return $this;
    }

    public function getCount()
    {
        echo __METHOD__ . "\n";

        return $this->counter->getCount();
    }
}
~~~

<p>And now let's <a href="http://3v4l.org/AilJu" target="_blank">retry</a>:</p>

~~~php
<?php

$counter = new EchoingCounter(new FluentCounter());

$counter = $counter->count()->count()->count()->count();

echo $counter->getCount();
~~~

<p>
    Works! We now see the different <code>EchoingCounter::count</code> being echoed.
    <br/>
    What about the immutable implementation?
</p>

~~~php
<?php

$counter = new EchoingCounter(new ImmutableCounter());

// we're using the "SAFE" solution here
$counter = $counter->count()->count()->count()->count();

echo $counter->getCount();
~~~

<p>
    <a href="http://3v4l.org/FuX4X" target="_blank">Seems to work</a>, but if you look closely,
    the reported count is wrong. Now the wrapper is working, but not the real logic!
</p>

<p>
    Additionally, we cannot fix this with a generic solution.
    <br/>
    We don't know if the wrapped instance is supposed to return itself or a new instance.
    <br/>
    We <em>can</em> manually fix the wrapper with some assumptions though:
</p>

~~~php
<?php

class EchoingCounter implements Counter
{
    private $counter;

    public function __construct(Counter $counter)
    {
        $this->counter = $counter;
    }

    public function count()
    {
        echo __METHOD__ . "\n";

        $this->counter = $this->counter->count();

        return $this;
    }

    public function getCount()
    {
        echo __METHOD__ . "\n";

        return $this->counter->getCount();
    }
}
~~~

<p>
    As you can see, we have to manually patch the <code>count()</code> method, but then again, this breaks
    the case when the API is neither Immutable nor Fluent.
    <br/>
    Additionally, our wrapper is now opinionated about the usage of the <code>count()</code> method, and it is
    not possible to build a generic wrapper anymore.
</p>

<p>
    I conclude this section by simply stating that fluent interfaces are problematic for wrappers, and require
    a lot of assumptions to be catched by a human decision, which has to be done per-method, based on
    assumptions.
</p>

<hr/>

<h2>Fluent Interfaces are harder to Mock</h2>

<p>
    Mock classes (at least in PHPUnit) are
    <a href="http://en.wikipedia.org/wiki/Null_Object_pattern" target="_blank">null objects</a> by default,
    which means that all the return values of methods have to be manually defined:
</p>

~~~php
<?php

$counter = $this->getMock('Counter');

$counter
    ->expects($this->any())
    ->method('count')
    ->will($this->returnSelf());
~~~

<p>
    There are 2 major problems with this:
</p>

<ol>
    <li>All fluent methods need explicit mocking</li>
    <li>We are assuming that a fluent interface is implemented, whereas the implementation may be immutable (as shown before)</li>
</ol>

<p>
    That basically means that we have to code assumptions in our unit tests (bad, and hard to follow).
</p>

<p>
    Also, we have to make decisions on the implementation of a mocked object
</p>

<p>
    The correct way of mocking the <code>Counter</code> interface would be something like:
</p>

~~~php
<?php

$counter = $this->getMock('Counter');

$counter
    ->expects($this->any())
    ->method('count')
    ->will($this->returnValue($this->getMock('Counter')));
~~~

<p>
    As you can see, we can break our code by making the mock behave differently, but still respecting the
    interface. Additionally, we need to mock every fluent method regardless of the parameters or even when
    we don't have expectations on the API.
</p>

<p>
    That is a lot of work, and a lot of <strong>wrong</strong> work to be done.
</p>

<hr/>

<h2>Fluent Interfaces make diffs harder to read</h2>

<p>
    The problem with diffs is minor, but it's something that really
    <a href="http://knowyourmeme.com/memes/that-really-rustled-my-jimmies" target="_blank">rustles my jimmies</a>,
    especially because people abuse fluent interfaces to write giant chained method calls like:
</p>

~~~php
<?php

$foo
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
    ->addTab('tab');
~~~

<p>
    Let's assume that a line is changed in the middle of the chain:
</p>

~~~sh
$ diff -p left.txt right.txt
~~~

~~~diff
*** left.txt    Fri Nov  8 15:05:09 2013
--- right.txt   Fri Nov  8 15:05:22 2013
***************
*** 11,16 ****
--- 11,17 ----
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
+     ->addBaz('tab')
    ->addTab('tab')
    ->addBar('bar')
    ->addBaz('baz')
~~~

<p>
    Not really useful, huh? Where do we see the object this <code>addBaz()</code> is being called on?
</p>

<p>
    This may look like nitpicking, but it makes code reviews harder, and I personally do a lot of code reviews.
</p>

<hr/>

<h2>Fluent Interfaces are less readable</h2>

<p>
    This is a personal feeling, but when reading a fluent interface, I cannot recognize if what is going on
    is just a massive violation of the
    <a href="http://en.wikipedia.org/wiki/Law_of_Demeter" target="_blank">Law of Demeter</a>, or if we're
    dealing with the same object over and over again.
    <br/>
    I'm picking an obvious example to show where this may happen:
</p>

~~~php
<?php
return $queryBuilder
    ->select('u')
    ->from('User u')
    ->where('u.id = :identifier')
    ->orderBy('u.name', 'ASC')
    ->setFirstResult(5)
    ->setParameter('identifier', 100)
    ->getQuery()
    ->setMaxResults(10)
    ->getResult();
~~~

<p>
    This one is quite easy to follow: <code>getQuery()</code> and <code>getResult()</code> are returning
    different objects that have a different API.
    <br/>
    The problem occurs when a method does not look like a getter:
</p>


~~~php
<?php
return $someBuilder
    ->addThing('thing')
    ->addOtherThing('other thing')
    ->compile()
    ->write()
    ->execute()
    ->gimme();
~~~

<p>
    Which of these method calls is part of a fluent interface? Which is instead
    returning a different object? You can't really tell that...
</p>

<hr/>

<h2>Conclusion</h2>

<p>
    I know the article is titled <q>"Fluent Interfaces are Evil"</q>, but that doesn't mean it's an absolute.
</p>

<p>
    Fluent interfaces are useful and easy to read in <strong>some contexts</strong>.
    What I am showing here is a set of problems that raise when inheriting them or making every piece of your
    code fluent.
</p>

<p>
    I just want you to think carefully next time you want fluent interfaces in your libraries,
    especially about the downsides that I have just exposed.
</p>

<p>
    You must have a <strong>very good reason</strong> to implement a fluent interface, otherwise it's just
    a problem that you are possibly dragging into your codebase.
</p>