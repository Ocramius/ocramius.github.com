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
        
        $this->sendTheRegistrationMail($user);
        
        return $user;
    }
    
    // ...
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

    public function __construct(DbConnection $db) 
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
    public function setDb(DbConnection $db)
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
        The <code>setDb</code> method is used to change the <code>DbConnection</code> at runtime, which seems
        to hide a different problem being solved: maybe we need a <code>MasterSlaveConnection</code> instead?
    </li>
    <li>
        The <code>setDb</code> method is not covered by the <code>RegistrationServiceInterface</code>, therefore
        we can only use it when we strictly couple our code with the <code>SwitchableDbRegistrationService</code>,
        which destroys the purpose of the contract itself in some contexts.
    </li>
    <li>
        The <code>setDb</code> switches dependencies at runtime, which may not be correctly
        handled by the <code>RegistrationService</code> logic in all cases, and may lead to bugs.
    </li>
    <li>
        Maybe the <code>setDb</code> method was introduced because of a bug in the original implementation: why
        was the fix provided this way? Is it an actual fix or does it only fix a symptom?
    </li>
</ul>

<p>
    There are more issues with the <code>setDb</code> example, but these are the most relevant ones for our purpose
    of explaining why <code>final</code> would have prevented this sort of situation upfront
</p>

<h4>4. Force the developer to shrink an object's public API</h4>

<p>
    Since classes with a lot of public methods are very likely to break the 
    <abbr title="Single Responsibility Principle">SRP</abbr>, it is often true that a developer will want to override
    specific API of those classes.
    Starting to make every new implementation <code>final</code> forces the developer to think about new APIs upfront,
    and about keeping them as small as possible.
</p>

<h4>5. A <code>final</code> class can always be made non-final</h4>

<p>
    Coding a new class as <code>final</code> also means that you can make it extensible at any point in time (if really
    required). No drawbacks, but you will have to explain your reasoning for such change to you and other team members,
    and that may lead to better solutions before anything gets merged.
</p>

<h5>6. Extension breaks encapsulation</h5>

<p>
    Unless the author of a class specifically designed it for extension, then you should consider it <code>final</code>
    even if it isn't. Extending a class breaks encapsulation, and can lead to unforseen consequences and/or 
    <abbr title="Backwards Compatibility">BC</abbr> breaks: think twice before using the <code>extends</code> keyword,
    or better, make your classes <code>final</code> and avoid others from having to think about it.
</p>
