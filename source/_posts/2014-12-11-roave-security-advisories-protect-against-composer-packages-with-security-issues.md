---
layout: post
title: Check Application Security against known Composer dependencies' Vulnerabilities
category: PHP
tags: ["php", "security", "composer", "packagist"]
year: 2014
month: 12
day: 11
published: true
summary: Prevent installation of composer packages with security vulnerabilities 
description: A new project that helps you avoid composer packages with known security issues/vulnerabilities
tweet: 
---

<p>
    Since it's almost christmas, it's also time to release a new project!
</p>

<p>
    The <a href="https://twitter.com/RoaveTeam" target="_blank">Roave Team</a> is pleased to announce the release of
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">roave/security-advisories</a>, a package
    that keeps known security issues out of your project.
</p>

<p>
    Before telling you more about it, go on and grab it:
</p>

~~~sh
mkdir roave-security-advisories-test
cd roave-security-advisories-test
curl -sS https://getcomposer.org/installer | php --

./composer.phar require roave/security-advisories:dev-master@DEV
~~~

<p>
    Now hold on: I will tell you what to do with it in a few.
</p>

<h4>Sooo... What is it?</h4>

<p>
    Last year, <a href="https://twitter.com/fabpot" target="_blank">Fabien Potencier</a> 
    <a href="http://fabien.potencier.org/article/67/don-t-use-php-libraries-with-known-security-issues" target="_blank">announced</a>
    the <a href="https://security.sensiolabs.org/" target="_blank">security.sensiolabs.org</a> project.
    This october, he 
    <a href="http://fabien.potencier.org/article/74/the-php-security-advisories-database" target="_blank">announced again</a> 
    that the project was being moved 
    <a href="https://github.com/FriendsOfPHP/security-advisories" target="_blank">to the open-source FriendsOfPHP organization</a>.
</p>

<p>
    While I liked the idea of being able to integrate security-issues checks with my 
    <abbr title="Continuous Integration">CI</abbr> system, I didn't like the fact that it was still possible to install
    and run harmful software before running those checks. I also didn't want to install and run an additional 
    CLI tool for something that composer could provide out of the box.
</p>

<p>
    That's when I had the idea of just compiling a list of <code>conflict</code> versions from 
    <a href="https://github.com/FriendsOfPHP/security-advisories" target="_blank"></a> into a composer
    <a href="https://getcomposer.org/doc/04-schema.md#type" target="_blank">metapackage</a>.
</p>

<p>
    This has various advantages:
</p>

<ul>
    <li>
        No files or actual dependencies are added to the project, since a "metapackage" does not provide 
        a vendor directory by itself
    </li>
    <li>
        Packages with security issues are filtered out during dependency resolution: they will not even be downloaded
    </li>
    <li>
        No more CLI tool to run separately, no more <abbr title="Continuous Integration">CI</abbr> setup steps
    </li>
    <li>
        No need to upgrade the tool separately
    </li>
    <li>
        No coupling or version constraints with to any dependency used by similar CLI-based alternatives
    </li>
</ul>

<p>
    That project eventually became 
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">roave/security-advisories</a>.
</p>

<h4>Try it out!</h4>

<p>
    Now that you installed <code>roave/security-advisories</code>, you can try out how it works:
</p>

~~~sh
cd roave-security-advisories-test

./composer.phar require symfony/symfony:2.5.2 # this will fail
./composer.phar require zendframework/zendframework:2.3.1 # this will fail
./composer.phar require symfony/symfony:~2.6 # works!
./composer.phar require zendframework/zendframework:~2.3 # works!
~~~

<p>
    Simple enough!
</p>

<h4>Why is there no tagged version?</h4>

<p>
    Because of how composer dependency resolution works, it is not possible to have more than one version of 
    <code>roave/security-advisories</code> other than <code>dev-master@DEV</code>. More about this is on the 
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">project page</a>
</p>

<hr/>

<h2>Fin</h2>
