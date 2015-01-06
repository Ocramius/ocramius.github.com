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

