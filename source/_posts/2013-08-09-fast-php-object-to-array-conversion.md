---
layout: post
title: Fast PHP Object to Array conversion
category: PHP
tags: ["php", "oop"]
year: 2013
month: 08
day: 09
published: true
summary: Fast PHP Object to Array conversion
description: A simple way of converting PHP Objects to Arrays regardless of their API
tweet: 365823480769417216
---

<p>
    A couple of months ago, I found a forgotten feature of PHP itself.
</p>
<p>
    Apparently, it is possible to cast objects to arrays like following:
</p>

~~~php
<?php

class Foo
{
    public $bar = 'barValue';
}

$foo = new Foo();

$arrayFoo = (array) $foo;

var_dump($arrayFoo);
~~~
<p>
    This <a href="https://3v4l.org/dj6Ei" target="_blank">will produce</a> something like:
</p>

~~~php
array(1) {
    ["bar"]=> string(8) "barValue"
}
~~~

<h2>Private and Protected properties</h2>

<p>
    If we start adding private and protected properties to our <code>Foo</code> class, things get
    very interesting:
</p>


~~~php
<?php

class Foo
{
    public $bar = 'barValue';
    protected $baz = 'bazValue';
    private $tab = 'tabValue';
}

$foo = new Foo();

$arrayFoo = (array) $foo;

var_dump($arrayFoo);
~~~

<p>
    The output <a href="https://3v4l.org/vK1t6" target="_blank">will be</a> like following in this case:
</p>

~~~php
array(3) {
    ["bar"]=> string(8) "barValue"
    ["*baz"]=> string(8) "bazValue"
    ["Footab"]=> string(8) "tabValue"
}
~~~

<p>
    Weird, so <code>$baz</code> is copied to array key <code>'*baz'</code> and <code>$tab</code>
    is copied to <code>Footab</code>...
</p>
<p>Let's try accessing those keys:</p>

~~~php
<?php

var_dump($arrayFoo['*baz']);
var_dump($arrayFoo['Footab']);
~~~

<p>
    Something even more strange happens here:
    <a href="https://3v4l.org/JimNP" target="_blank">we get two notices</a>.
</p>

~~~php
Notice: Undefined index: *baz in [...] on line [...]
NULL

Notice: Undefined index: Footab in [...] on line [...]
NULL
~~~

<p>
    I actually spent some time trying to understand why this was happening, and even the debugger was failing
    me! Then I tried using
    <a href="https://secure.php.net/manual/en/function.var-export.php" target="_blank"><code>var_export</code></a>:
</p>


~~~php
<?php

var_export($arrayFoo);
~~~

<p>
    The <a href="https://3v4l.org/UQlb0" target="_blank">output</a> is quite interesting:
</p>

~~~php
array (
    'bar' => 'barValue',
    '' . "\0" . '*' . "\0" . 'baz' => 'bazValue',
    '' . "\0" . 'Foo' . "\0" . 'tab' => 'tabValue',
)
~~~

<p>
    Null characters are used as delimiters between the visibility scope of a particular property and its name!
</p>
<p>
    That's some really strange results, and they give us some insight on how PHP actually keeps us from
    accessing private and protected properties.
</p>

<h2>Direct property read attempt</h2>

<p>
    What happens if we try to directly access the <code>$foo</code> properties with this new trick?
</p>

~~~php
<?php

var_dump($foo->{"\0*\0baz"});
var_dump($foo->{"\0Foo\0tab"});
~~~

<p>
    Looks like the engine was patched after PHP 5.1 to fix this (un-documented break),
    since <a href="https://3v4l.org/e5hWG" target="_blank">we get a fatal</a>:
</p>

~~~php
Fatal error: Cannot access property started with '\0' in [...] on line [...]
~~~

<p>
    Too bad! That would have had interesting use cases. The change makes sense though, since we shouldn't
    modify internal state without explicitly using an API that cries out "I do things with your objects state!".
</p>

<h2>Some notes and suggestions</h2>

<ul>
    <li>
        This way of accessing properties via array conversion is quite useful when it actually makes sense to
        access object internal state. Don't use it otherwise.
    </li>
    <li>
        It is safe to use since an eventual behaviour change has to be documented. I provided a
        <a href="https://github.com/php/php-src/pull/358" target="_blank">test for PHP-SRC in a pull request</a>
        to protect this kind of usage.
    </li>
    <li>
        You should probably not re-map the private properties to simple names such as
        <code>baz</code>, since multiple inheritance levels may cause collisions in key names.
    </li>
    <li>
        You may have already noticed that I work a lot with internal object states: that doesn't mean that you
        should too.
    </li>
</ul>

<p>
    I'm currently writing a small library called
    <a href="https://github.com/Ocramius/GeneratedHydrator" target="_blank">GeneratedHydrator</a>
    to take advantage of this behaviour and the one that I described in my
    <a href="{{page.previous.url}}">previous blog post</a>. That should prevent you from doing this
    kind of dangerous things with PHP :-)
</p>
