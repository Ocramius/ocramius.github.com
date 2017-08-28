---
layout: post
title: ProxyManager 2.0.0 release and expected 2.x lifetime
category: PHP
tags: ["php", "proxy"]
year: 2016
month: 1
day: 29
published: true
summary: ProxyManager 2.0.0 has been released, with the expected support schedule for 2.x
description: ProxyManager 2.0.0 is finally released, and an expected lifetime for the 2.x series is also attached!
tweet: 693368993881657344
---

<p style="align: center;">
    <img
        src="https://raw.githubusercontent.com/Ocramius/ProxyManager/2.0.0/proxy-manager.png"
        alt="ProxyManager"
        width="25%"
    />
</p>

<p>
    <a href="https://ocramius.github.io/ProxyManager" target="_blank">ProxyManager</a>
    <a href="https://github.com/Ocramius/ProxyManager/releases/tag/2.0.0" target="_blank">2.0.0</a>
    was finally released today!
</p>

<p>
    It took a bit more than a year to get here, but major improvements were included
    in this release, along with exclusive PHP 7 support.
</p>

<p>
    Most of the features that we planned to provide were indeed
    <a href="https://github.com/Ocramius/ProxyManager/blob/2.0.0/CHANGELOG.md#200" target="_blank">implemented into this release</a>.
</p>

<p>
    As a negative note, HHVM compatibility was not achieved, as HHVM is not yet compatible
    with PHP 7.0.x-compliant code.
</p>

<p>
    As of this release, ProxyManager 1.0.x switches to
    <a href="https://github.com/Ocramius/ProxyManager/blob/master/STABILITY.md#10x" target="_blank">security-only support</a>.
</p>

<h3>Planned maintenance schedule</h3>

<p>
    ProxyManager 2.x will be a maintenance-only release:
</p>

<ul>
    <li>
        I plan to fix bugs until <time datetime="2017-01-29">January 29, 2017</time>
    </li>
    <li>
        I plan to fix security issues until <time datetime="2018-01-29">January 29, 2018</time>
    </li>
</ul>

<p>
    No features are going to be added to ProxyManager 2.x: the current <code>master</code> branch will instead
    become the development branch for version <code>3.0.0</code>.
</p>

<p>
    Features for ProxyManager 3.0.0 are yet to be planned, but we reached exceptional code quality,
    complete test coverage and nice performance improvements with 2.0.0: the future is bright!
</p>

<h3>Thank you!</h3>

<p>
    And of course, a big <strong>"thank you"</strong> to all those who contributed to this release! 
</p>

<ul>
    <li><a href="https://github.com/samsonasik" target="_blank">Abdul Malik Ikhsan</a></li>
    <li><a href="https://github.com/vonalbert" target="_blank">Alberto Avon</a></li>
    <li><a href="https://github.com/malukenho" target="_blank">Jefersson Nathan</a></li>
    <li><a href="https://github.com/jbafford" target="_blank">John Bafford</a></li>
</ul>
