---
layout: post
title: JS/CSS/Images with Zend Framework 2 and the Asset Manager Module
category: Coding
tags: zf2 module assets
year: 2012
month: 9
day: 12
published: true
summary: A tutorial to start using assets from your modules within your ZF2 applications
---

<h2>RWOverdijk's AssetManager</h2>
<p>
    This blog post is about a module that I and <a href="https://twitter.com/RWOverdijk"
    target="_blank">Roberto Wesley Overdijk</a> developed last month. It is called
    <a href="https://github.com/RWOverdijk/AssetManager" target="_blank">AssetManager</a>
    and its aim is to simplify how you currently store and serve assets
    (JS/CSS/images/etc.) in your <abbr title="Zend Framework 2">ZF2</abbr> applications.
</p>

<h2>ZF2 Module structure</h2>
<p>
    When <a href="https://twitter.com/weierophinney" target="_blank">Matthew Weier
    O'Phinney</a> blogged about <a href="http://mwop.net/blog/why-conventions-matter.html"
    target="_blank">Why Conventions Matter</a> in ZF2 Modules, we were still defining the
    basic concepts of modules, and didn't really have a decent solution about how to
    serve assets. The idea is to ship assets with modules themselves, thus avoiding to
    copy files to your <code>public/</code> directory each time you start with a new
    project (copying is almost never a good thing, you know that!).
</p>
<p>
    AssetManager solves this problem and is a
    <a href="http://ocramius.github.io/blog/automated-code-coverage-check-for-github-pull-requests-with-travis/"
    target="_blank">high quality and well tested module</a>.
</p>

<hr/>
<h2>Let's get started</h2>
<p>
    We will use a standard <a href="https://github.com/zendframework/ZendSkeletonApplication"
    target="_blank">ZF2 skeleton application</a> and
    <a href="http://getcomposer.org/" target="_blank">Composer</a>:
</p>

~~~sh
~$ git clone git://github.com/zendframework/ZendSkeletonApplication.git
Cloning into 'ZendSkeletonApplication'...

~$ cd ZendSkeletonApplication

~$ ./composer.phar install
Loading composer repositories with package information
Installing dependencies
  - Installing zendframework/zendframework (2.0.0)
    Downloading: 100%

~$ ./composer.phar require rwoverdijk/assetmanager
Please provide a version constraint for the rwoverdijk/assetmanager requirement: *
composer.json has been updated
Loading composer repositories with package information
Updating dependencies
  - Installing kriswallsmith/assetic (v1.0.4)
    Downloading: 100%

  - Installing rwoverdijk/assetmanager (1.0.0)
    Downloading: 100%

Writing lock file
Generating autoload files
~~~

<hr/>

<p>Don't forget to enable the module in your <code>config/application.config.php</code>!</p>

~~~php
<?php
return array(
    'modules' => array(
        'AssetManager',
        'Application',
    ),
    // ... other configs ...
~~~

<h2>Assets</h2>
<p>
    To verify that everything works, we will add a simple asset that will just paint
    everything in our page as green (just to make things really really obvious). It will
    be our <code>module/Application/public/test-asset.css</code> (The <code>public</code>
    dir does not yet exist in the skeleton application, you will need to create it):
</p>

~~~css
* {color: green;}
~~~

<p>
    We now need to teach the AssetManager where to look for our assets. To do so, we will
    edit our module's configuration.
    Now let's go to <code>module/Application/config/module.config.php</code>, we need to
    add following configuration:
</p>

~~~php
<?php
return array(
    'asset_manager' => array(
        'resolver_configs' => array(
            'paths' => array(
                'Application' => __DIR__ . '/../public',
            ),
        ),
    ),
);
~~~

<p>
    This basically means that any request that couldn't be routed to a controller will
    check also within our module's <code>public/</code> dir and eventually serve an asset
    from there.
</p>

<p class="warning">
    <span class="label label-info">Warning!</span> By configuring your application this
    way, you're basically telling PHP to serve any content from within your module's
    <code>public/</code> dir. This also means PHP sources (as text) if there are any in
    there. Keep it in mind!
</p>

<h2>Checking if it works</h2>

<p>
    Once you've done all this, open your browser and go to
    <code>http://localhost/path/to/ZendSkeletonApplication/public/test-asset.css</code>.
    You should see the contents we wrote in the CSS file before.
</p>

<p>
    That's it! You can now add your CSS file in your
    <code>module/Application/view/layout/layout.phtml</code> as following if you want:
</p>

~~~php
<?php
    echo $this->headLink()->prependStylesheet($this->basePath() . '/test-asset.css');
?>
~~~

<p>
    Enjoy! You can now build your modules to ship any images, js or generally assets!
</p>

<p>
    This Asset Manager supports more kinds of resolver strategies, such as maps,
    asset collections (to get compiled JS/CSS), filters, caching, asset priorities and
    more. Most of all this is already implemented, but check the
    <a href="https://github.com/RWOverdijk/AssetManager" target="_blank">project page
    on github</a> for more amazing features!
</p>