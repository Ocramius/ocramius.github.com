---
layout: post
title: When to declare classes final
category: PHP
tags: ["php", "oop", "best practices"]
year: 2015
month: 1
day: 6
published: true
summary: When do I need to declare a class as final?
description: Declaring classes as final enhances our code quality and abstraction dramatically, but is it always correct?
tweet: 
---

<p>
    In the last month, I had a few discussions about the usage of the <code>final</code> marker on PHP classes.
</p>

<p>
    The pattern is recurrent:
</p>

<ol>
    <li>I ask for a newly introduced class to be declared <code>final</code></li>
    <li>the author of the code is reluctant, stating that <code>final</code> limits flexibility</li>
    <li>I have to explain that flexibility comes from good abstractions, and not from inheritance</li>
</ol>

<p>
    It is therefore clear that people need a better explanation of <strong>when</strong> to use <code>final</code>, 
    and when it has to be avoided.
</p>

<p>
    There are many other articles about the subject, but this is mainly thought as a "quick reference" for those
    that will ask me the same questions in future.
</p>

<h3>When to use <code>final</code>:</h3>

<p>
    <code>final</code> should be used <strong>whenever possible</strong>.
</p>

<p>
    Developers have the bad habit of fixing problems by providing specific subclasses of an existing (not adequate)
    solution. You probably saw it yourself with examples like following:
</p>

~~~php
<?php

class Db { /* ... */ }
class Core extends Db { /* ... */ }
class User extends Core { /* ... */ }
class Admin extends User { /* ... */ }
class Bot extends Admin { /* ... */ }
class BotThatDoesSpecialThings extends Bot { /* ... */ }
class PatchedBot extends BotThatDoesSpecialThings { /* ... */ }
~~~

<p>
    This is, without any doubts, how you should <strong>NOT</strong> design your code. This kind of approach is usually
    adopted by developers who confuse <abbr title="Object Oriented Programming">OOP</abbr> with "<cite>a way of solving 
    problems via inheritance</cite>" ("inheritance-oriented-programming" maybe?).
</p>



<p>
    In general, preventing inheritance in a forceful way has the nice advantage of making developers think more about
    composition.
</p>
