---
layout: post
title: "roave/security-advisories: Composer against Security Vulnerabilities"
category: PHP
tags: ["php", "security", "composer", "packagist"]
year: 2014
month: 12
day: 11
published: true
summary: Prevent installation of composer packages with security vulnerabilities 
description: A new project that helps you avoid composer packages with known security issues/vulnerabilities
tweet: 543064002461700096
---
<p><hr/></p>

<p>
    Since it's almost christmas, it's also time to release a new project!
</p>

<p>
    The <a href="https://twitter.com/RoaveTeam" target="_blank">Roave Team</a> is pleased to announce the release of
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">roave/security-advisories</a>, a package
    that keeps known security issues out of your project.
</p>

<p>
    Before telling you more, go grab it:
</p>

~~~sh
mkdir roave-security-advisories-test
cd roave-security-advisories-test
curl -sS https://getcomposer.org/installer | php --

./composer.phar require roave/security-advisories:dev-master
~~~

<p>
    Hold on: I will tell you what to do with it in a few.
</p>

<h3>What is it?</h3>

<p>
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">roave/security-advisories</a> is a composer
    package that prevents installation of packages with known security issues.
</p>

<h3>Yet another one?</h3>

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
    While I like the idea of integrating security checks with my 
    <abbr title="Continuous Integration">CI</abbr>, I don't like the fact that it is possible to install
    and run harmful software before those checks.
    <br/>
    I also don't want to install and run an additional CLI tool for something that composer can provide directly.
</p>

<p>
    That's why I had the idea of just compiling a list of <code>conflict</code> versions from 
    <a href="https://github.com/FriendsOfPHP/security-advisories" target="_blank"></a> into a composer
    <a href="https://getcomposer.org/doc/04-schema.md#type" target="_blank">metapackage</a>:
</p>

<iframe width="420" height="315" src="https://www.youtube.com/embed/QkjD3D5FgmE" frameborder="0" allowfullscreen></iframe>

<h3>Why?</h3>

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
        No coupling or version constraints with any dependencies used by similar CLI-based alternatives
    </li>
</ul>

<h3>Try it out!</h3>

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

<p>
    Please just note that this only works when adding new dependencies or when running <code>composer update</code>:
    security issues in your <code>composer.lock</code> cannot be checked with this technique.
</p>

<h3>Why is there no tagged version?</h3>

<p>
    Because of how composer dependency resolution works, it is not possible to have more than one version of 
    <code>roave/security-advisories</code> other than <code>dev-master</code>. More about this is on the 
    <a href="https://github.com/Roave/SecurityAdvisories" target="_blank">project page</a>
</p>

<hr/>

<h2>Fin</h2>
