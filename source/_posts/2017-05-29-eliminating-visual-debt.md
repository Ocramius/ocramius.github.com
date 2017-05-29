---
layout: post
title: Eliminating Visual Debt
category: Security
tags: ["PHP", "Design", "Type Systems", "Visual Debt", "Sarcasm"]
year: 2017
month: 4
day: 15
published: true
summary: Visual debt is damaging our productivity and increasing maintenance load every day - let's delete it
description: Visual debt clutters the screen, increases code to be read and understood, makes us less productive and makes us focus on things that don't matter
tweet: 
---

<p>
    Today we're talking about <strong>Visual debt</strong> in our code.
</p>

<p>
    As an introduction, I suggest you to watch
    <a href="https://laracasts.com/series/php-bits/episodes/1" target="_blank">
        this short tutorial
    </a>
    about visual debt, in which
    <a href="https://twitter.com/jeffrey_way" target="_blank">@jeffrey_way</a>
    provides an overview of what visual debt is.
</p>

<p>
    The concept is simple: let's take the example from Laracasts and re-visit
    the steps taken to remove visual debt.
</p>


~~~php
interface EventInterface {
    public function listen(string $name, callable $handler) : void;
    public function fire(string $name) : bool;
}

final class Event implements EventInterface {
    protected $events = [];
    
    public function listen(string $name, callable $handler) : void
    {
        $this->events[$name][] = $handler;
    }
    
    public function fire(string $name) : bool
    {
        if (! array_key_exists($name, $this->events)) {
            return false;
        }
        
        foreach ($this->>events[$name] as $event) {
            $event();
        }
        
        return true;
    }
}

$event = new Event;

$event->listen('subscribed', function () {
    var_dump('handling it');
});

$event->listen('subscribed', function () {
    var_dump('handling it again');
});

$event->fire('subscribed');
~~~

<p>
    So far, so good.
</p>

<p>
    We have an event that obviously fires itself, a concrete
    implementation and a few subscribers
</p>

<p>
    Our code works, but it contains a lot of useless artifacts
    that do not really influence our ability to make it run.
</p>

<p>
    These artifacts are also distracting, moving our focus from
    the runtime to the declarative requirements of the code.
</p>

<p>
    Let's start removing the bits that aren't needed by starting
    from the method parameter and return type declarations:
</p>

~~~php
interface EventInterface {
    public function listen($name, $handler);
    public function fire($name);
}

final class Event implements EventInterface {
    protected $events = [];
    
    public function listen($name, $handler)
    {
        $this->events[$name][] = $handler;
    }
    
    public function fire($name)
    {
        if (! array_key_exists($name, $this->events)) {
            return false;
        }
        
        foreach ($this->>events[$name] as $event) {
            $event();
        }
        
        return true;
    }
}
~~~

<p>
    Our code is obvious, so the parameters don't need
    redundant declarations or type checks. Also, we are
    aware of our own implementation, so the runtime checks
    are not needed, as the code will work correctly as per
    manual or end to end testing. A quick read will also
    provide sufficient proof of correctness.
</p>

<p>
    Since the code is trivial and we know what we are doing
    when using it, we can remove also the contract that
    dictates the intended usage. Let's remove those
    `implements` and `interface` symbols.
</p>

~~~php
final class Event {
    protected $events = [];
    
    public function listen($name, $handler)
    {
        $this->events[$name][] = $handler;
    }
    
    public function fire($name)
    {
        if (! array_key_exists($name, $this->events)) {
            return false;
        }
        
        foreach ($this->>events[$name] as $event) {
            $event();
        }
        
        return true;
    }
}
~~~

<p>
    Removing the contract doesn't change the runtime
    behavior of our code, which is still technically
    correct. Consumers will also not need to worry
    about correctness when they use `Event`, as a
    quick skim over the implementation will reveal
    its intended usage.
</p>

<p>
    Also, since the code imposes no limitations on the
    consumer, who is responsible for the correctness
    of any code touching ours, we are not going to limit
    the usage of inheritance.
</p>

~~~php
class Event {
    // ... 
}
~~~

<p>
    That's as far as the video goes, with a note that
    the point is to "question everything".
</p>

<h2>Bringing it further</h2>

<p>
    Jeffrey then pushed this a bit further, saying that
    best practices don't exist, and people are pretty
    much copying stale discussions about coding approaches:
</p>

<div data-tweet-id="869265813857075200" class="twitter-tweet">
    @jeffrey_way: Best practices aren’t real. It’s just a
    group of people who copied what a handful of others did.
</div>

<p>
    According to that, I'm going to question the naming
    chosen for our code. Since the code is trivial and 
    understandable at first glance, we don't need to pick
    meaningful names for variables, methods and classes:
</p>

~~~php
class A {
    protected $a = [];
    
    public function a1($a1, $a2)
    {
        $this->events[$a1][] = $a2;
    }
    
    public function a2($a1)
    {
        if (! array_key_exists($a1, $this->a)) {
            return false;
        }
        
        foreach ($this->a[$a1] as $a) {
            $a();
        }
        
        return true;
    }
}
~~~

<p>
    This effectively removes our need to look at the
    code details, making the code more coincise and
    runtime-friendly. We're also saving some space
    in the PHP engine!
</p>

<p>
    Effectively, this shows us that
    there are upsides to this approach, as we move
    from read overhead to less engine overhead. We also
    stop obsessing after the details of our `Event`,
    as we already previously defined it, so we remember
    how to use it.
</p>

<p>
    Since our type is not really useful to our purposes,
    we can move back to dealing with the functional bits
    of our architecture as pointers to functions:
</p>

~~~php
function A () {
    $a = [];
    
    return [
        function ($a1, $a2) use (& $a) {
            $a[$a1][] = $a2;
        },
        function ($a1) use (& $a) {
            if (! array_key_exists($a1, $a)) {
                return false;
            }
            
            foreach ($a[$a1] as $a2) {
                $a2();
            }
            
            return true;
        },
    ];
}


$a = A();

$a[0]('subscribed', function () {
    var_dump('handling it');
});

$a[0]('subscribed', function () {
    var_dump('handling it again');
});

$a[1]('subscribed');
~~~

<p>
    This code is equivalent, and doesn't use any
    particularly fancy structures coming from the PHP
    language, such as classes. We are working
    towards reducing the learning and comprehension
    overhead.
</p>

<h2>Conclusion</h2>

<div data-tweet-id="869277621904912389" class="twitter-tweet">
    @PHPeeHaa: Question *everything*...
</div>

<p>
    If you haven't noticed before, this entire post
    is just
    <a href="https://www.youtube.com/watch?v=82CtZX9gmZ8" target="_blank">
        sarcasm.
    </a>
</p>

<p>
    Please don't do any of what is discussed above.
</p>

<p>
    Please don't accept what Jeffrey says in that video.
</p>

<p>
    Please do use type systems when they are available,
    they actually reduce visual debt.
</p>

<p>
    Please do use interfaces, as they reduce clutter,
    making things easier to follow from a consumer perspective.
</p>

<p>
    This is all you
    need to understand that `Event` mumbo-jumbo (which
    has broken naming, by the way, but this isn't an
    architecture workshop), no:
</p>

~~~php
interface EventInterface {
    public function listen($name, $handler);
    public function fire($name);
}
~~~

<p>
    Please do follow best practices. They work.
</p>