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

<h3>Why do I have to use <code>final</code>?</h3>

<p>
    There are numerous reasons to mark a class as <code>final</code>, and here I will be listing some of them.
</p>

<h4>1. Preventing massive inheritance chain of doom</h4> 

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
    This is, without any doubts, how you should <strong>NOT</strong> design your code. The approach described above is 
    usually adopted by developers who confuse <abbr title="Object Oriented Programming">OOP</abbr> with "<cite>a way 
    of solving problems via inheritance</cite>" ("inheritance-oriented-programming" maybe?).
</p>

<h4>2. Encouraging composition</h4>

<p>
    In general, preventing inheritance in a forceful way (by default) has the nice advantage of making developers 
    think more about composition, and less about stuffing functionality in existing code via inheritance (which, in my
    opinion, is a symptom of haste combined with feature creep).
</p>

<p>
    Take following naive example:
</p>

~~~php
<?php

class RegistrationService implements RegistrationServiceInterface
{
    public function registerUser(/* ... */) { /* ... */ }
}

class EmailingRegistrationService extends RegistrationService
{
    public function registerUser(/* ... */) 
    {
        $user = parent::registerUser(/* ... */);
        
        sendTheRegistrationMail($user);
        
        return $user;
    }
}
~~~

<p>
    By making the <code>RegistrationService</code> <code>final</code>, the idea behind 
    <code>EmailingRegistrationService</code> being a child-class of it is denied upfront, and silly mistakes as
    the previous one are easily avoided:
</p>


~~~php
<?php

class EmailingRegistrationService implements RegistrationServiceInterface
{
    public function __construct(RegistrationServiceInterface $mainRegistrationService) 
    {
        $this->mainRegistrationService = $mainRegistrationService;
    }

    public function registerUser(/* ... */) 
    {
        $user = $this->mainRegistrationService->registerUser(/* ... */);
        
        sendTheRegistrationMail($user);
        
        return $user;
    }
}
~~~