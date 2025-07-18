---
layout: post
title: When to declare classes final
category: PHP
tags: ["php", "oop", "best practices"]
year: 2015
month: 01
day: 06
published: true
summary: When do I need to declare a class as final?
description: Declaring classes as final enhances our code quality and abstraction dramatically, but is it always correct?
tweet: 552547686134857728
---

<p>
    <strong>
        <abbr title="too long, didn't read">TL;DR</abbr>: 
        Make your classes always <code>final</code>, if they implement an interface, 
        and no other public methods are defined
    </strong>
</p>

<p>
    In the last month, I had a few discussions about the usage of the <code>final</code> marker on PHP classes.
</p>

<p>
    The pattern is recurrent:
</p>

<ol>
    <li>I ask for a newly introduced class to be declared as <code>final</code></li>
    <li>the author of the code is reluctant to this proposal, stating that <code>final</code> limits flexibility</li>
    <li>I have to explain that flexibility comes from good abstractions, and not from inheritance</li>
</ol>

<p>
    It is therefore clear that coders need a better explanation of <strong>when</strong> to use <code>final</code>, 
    and when to avoid it.
</p>

<p>
    There are 
    <a href="http://verraes.net/2014/05/final-classes-in-php/" target="_blank">many</a> 
    <a href="http://www.javaworld.com/article/2073649/core-java/why-extends-is-evil.html" target="_blank">other</a>
    <a href="http://stackoverflow.com/questions/137868/using-final-modifier-whenever-applicable-in-java" target="_blank">articles</a>
    about the subject, but this is mainly thought as a "quick reference" for those
    that will ask me the same questions in future.
</p>

<h3>When to use "final":</h3>

<p>
    <code>final</code> should be used <strong>whenever possible</strong>.
</p>

<h3>Why do I have to use <code>final</code>?</h3>

<p>
    There are numerous reasons to mark a class as <code>final</code>: I will list and describe those that are
    most relevant in my opinion.
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
    This is, without any doubts, how you should <strong>NOT</strong> design your code. 
</p>

<p>
    The approach described above is usually adopted by developers who confuse 
    <a href="http://c2.com/cgi/wiki?AlanKaysDefinitionOfObjectOriented" target="_blank">
        <abbr title="Object Oriented Programming">OOP</abbr>
    </a> with "<cite>a way of solving problems via inheritance</cite>"
    ("inheritance-oriented-programming", maybe?).
</p>

<h4>2. Encouraging composition</h4>

<p>
    In general, preventing inheritance in a forceful way (by default) has the nice advantage of making developers 
    think more about composition.
</p>
<p>
    There will be less stuffing functionality in existing code via inheritance, which, in my
    opinion, is a symptom of haste combined with 
    <a href="https://en.wikipedia.org/wiki/Feature_creep" target="_blank">feature creep</a>.
</p>

<p>
    Take the following naive example:
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
        
        $this->sendTheRegistrationMail($user);
        
        return $user;
    }
    
    // ...
}
~~~

<p>
    By making the <code>RegistrationService</code> <code>final</code>, the idea behind 
    <code>EmailingRegistrationService</code> being a child-class of it is denied upfront, and silly mistakes such 
    as the previously shown one are easily avoided:
</p>


~~~php
<?php

final class EmailingRegistrationService implements RegistrationServiceInterface
{
    public function __construct(RegistrationServiceInterface $mainRegistrationService) 
    {
        $this->mainRegistrationService = $mainRegistrationService;
    }

    public function registerUser(/* ... */) 
    {
        $user = $this->mainRegistrationService->registerUser(/* ... */);
        
        $this->sendTheRegistrationMail($user);
        
        return $user;
    }
    
    // ...
}
~~~

<h4>3. Force the developer to think about user public API</h4>

<p>
    Developers tend to use inheritance to add accessors and additional API to existing classes:
</p>

~~~php
<?php

class RegistrationService implements RegistrationServiceInterface
{
    protected $db;

    public function __construct(DbConnectionInterface $db) 
    {
        $this->db = $db;
    }

    public function registerUser(/* ... */) 
    {
        // ...
        
        $this->db->insert($userData);
        
        // ...
    }
}

class SwitchableDbRegistrationService extends RegistrationService
{
    public function setDb(DbConnectionInterface $db)
    {
        $this->db = $db;
    }
}
~~~

<p>
    This example shows a set of flaws in the thought-process that led to the 
    <code>SwitchableDbRegistrationService</code>:
</p>

<ul>
    <li>
        The <code>setDb</code> method is used to change the <code>DbConnectionInterface</code> at runtime, which seems
        to hide a different problem being solved: maybe we need a <code>MasterSlaveConnection</code> instead?
    </li>
    <li>
        The <code>setDb</code> method is not covered by the <code>RegistrationServiceInterface</code>, therefore
        we can only use it when we strictly couple our code with the <code>SwitchableDbRegistrationService</code>,
        which defeats the purpose of the contract itself in some contexts.
    </li>
    <li>
        The <code>setDb</code> method changes dependencies at runtime, and that may not be supported
        by the <code>RegistrationService</code> logic, and may as well lead to bugs.
    </li>
    <li>
        Maybe the <code>setDb</code> method was introduced because of a bug in the original implementation: why
        was the fix provided this way? Is it an actual fix or does it only fix a symptom?
    </li>
</ul>

<p>
    There are more issues with the <code>setDb</code> example, but these are the most relevant ones for our purpose
    of explaining why <code>final</code> would have prevented this sort of situation upfront.
</p>

<h4>4. Force the developer to shrink an object's public API</h4>

<p>
    Since classes with a lot of public methods are very likely to break the 
    <abbr title="Single Responsibility Principle">SRP</abbr>, it is often true that a developer will want to override
    specific API of those classes.
</p>

<p>
    Starting to make every new implementation <code>final</code> forces the developer to think about new APIs upfront,
    and about keeping them as small as possible.
</p>

<h4>5. A <code>final</code> class can always be made extensible</h4>

<p>
    Coding a new class as <code>final</code> also means that you can make it extensible at any point in time (if really
    required).
</p>

<p>
    No drawbacks, but you will have to explain your reasoning for such change to yourself and other members 
    in your team, and that discussion may lead to better solutions before anything gets merged.
</p>

<h4>6. <code>extends</code> breaks encapsulation</h4>

<p>
    Unless the author of a class specifically designed it for extension, then you should consider it <code>final</code>
    even if it isn't.
</p>

<p>
    Extending a class breaks encapsulation, and can lead to unforeseen consequences and/or 
    <abbr title="Backwards Compatibility">BC</abbr> breaks: think twice before using the <code>extends</code> keyword,
    or better, make your classes <code>final</code> and avoid others from having to think about it.
</p>

<h4>7. You don't need that flexibility</h4>

<p>
    One argument that I always have to counter is that <code>final</code> reduces flexibility of use of a codebase.
</p>

<p>
    My counter-argument is very simple: you don't need that flexibility.
</p>

<p>
    Why do you need it in first place?
    Why can't you write your own customized implementation of a contract?
    Why can't you use composition?
    Did you carefully think about the problem?
</p>

<p>
    If you still need to remove the <code>final</code> keyword from an implementation, then there may be some other 
    sort of code-smell involved.
</p>

<h4>8. You are free to change the code</h4>

<p>
    Once you made a class <code>final</code>, you can change it as much as it pleases you.
</p>

<p>
    Since encapsulation is guaranteed to be maintained, the only thing that you have to care about is that the public API.
</p>

<p>
    Now you are free to rewrite everything, as many times as you want.
</p>

<h3>When to <strong>avoid</strong> <code>final</code>:</h3>

<p>
    Final classes <strong>only work effectively under following assumptions</strong>:
</p>

<ol>
    <li>There is an abstraction (interface) that the final class implements</li>
    <li>All of the public API of the final class is part of that interface</li>
</ol>

<p>
    If one of these two pre-conditions is missing, then you will likely reach a point in time when you will make the
    class extensible, as your code is not truly relying on abstractions.
</p>

<p>
    An exception can be made if a particular class represents a set of constraints or concepts that are totally 
    immutable, inflexible and global to an entire system.
    A good example is a mathematical operation: <code>$calculator->sum($a, $b)</code> will unlikely change over time.
    In these cases, it is safe to assume that we can use the <code>final</code> keyword without an abstraction to 
    rely on first.
</p>

<p>
    Another case where you do not want to use the <code>final</code> keyword is on existing classes: that can only
    be done if you follow <a href="http://semver.org/" target="_blank">semver</a> and you bump the major version
    for the affected codebase.
</p>

<h3>Try it out!</h3>

<p>
    After having read this article, consider going back to your code, and if you never did so,
    adding your first <code>final</code> marker to a class that you are planning to implement.
</p>

<p>
    You will see the rest just getting in place as expected.
</p>
