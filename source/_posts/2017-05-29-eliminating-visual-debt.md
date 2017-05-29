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
