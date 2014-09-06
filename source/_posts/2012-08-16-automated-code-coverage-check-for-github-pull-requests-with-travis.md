---
layout: post
title: Automated Test Coverage Checks with Travis, PHPUnit for Github Pull Requests
category: PHP
tags: phpunit code coverage travis travis continuos integration testing
year: 2012
month: 8
day: 16
published: true
summary: Developers are lazy, and their Pull Requests in Github often do not respect our code quality standards. Automate testing so that you can enforce a minimum PHPUnit Code Coverage in Travis!
tweet: 236012181685170177
---

<h2>Code quality</h2>
<p>
    Github is fun, and it is a great place for showing off our coding skills and building great tools for our next
    great project!
    <br/>
    But what if we want to also ensure that our tool works perfectly?
    <br/>
    Obviously, <q>perfection</q> is not a term of the developer world. There is always a flaw waiting for us behind
    the corner, but we can do our best to try to avoid it by testing our code, and testing it well.
</p>

<hr/>

<h2>Code coverage</h2>
<p>
    <strong>Code coverage</strong> is one of the metrics we can get from
    <a href="https://github.com/sebastianbergmann/phpunit/" target="_blank">PHPUnit</a> tests, and it is a strong
    indicator of how hard we worked on testing our application. It is not an universal metric to define if our code
    works, and there is tons of examples of how your code can still be buggy even if every line of code was executed
    at least once. It should anyway not be ignored, and it is up to us to decide how hard we want to test each part
    of our application.
</p>
<p>
    That's why I came up with the idea of automating a simple coverage check on a
    <a href="https://github.com/RWOverdijk/AssetManager" target="_blank">library I was working on</a>.
</p>

<hr/>
<h2>The script</h2>
<p>
    What we basically want to do is to automate a very simple check that verifies that our test suite covered at
    least a given percentage of the
    <a href="http://pdepend.org/documentation/software-metrics/index.html" target="_blank">]
        <abbr title="Executable Lines Of Code">ELOC</abbr></a>.
    The script should exit with an <a href="http://en.wikipedia.org/wiki/Exit_status" target="_blank">exit code</a>
    different from <strong>1</strong> if the check wasn't successful, thus being recognized by our test runner as a
    failure.
</p>
<p>
    I will use <a href="http://travis-ci.org/" target="_blank">Travis-CI</a> for my examples, but what I am going to
    show can be easily integrated also in other
    <a href="http://en.wikipedia.org/wiki/Continuous_integration" target="_blank">Continuous Integration</a>
    environments.
</p>

<hr/>

<h2>PHPUnit setup and clover.xml</h2>
<p>
    PHPUnit is able to generate log files in an XML format called <strong>clover</strong>. You will need to setup
    PHPUnit as following to generate a correct clover report:
</p>
~~~xml
<?xml version="1.0"?>
<!-- works fine with PHPUnit-3.6.10 -->
<phpunit>
    <!-- you can keep your own options in these elements -->
    <filter>
        <whitelist addUncoveredFilesFromWhitelist="true">
            <!-- this is the path of the files included in your clover report -->
            <directory suffix=".php">./src</directory>
        </whitelist>
    </filter>
    <logging>
        <!-- and this is where your report will be written -->
        <log type="coverage-clover" target="./clover.xml"/>
    </logging>
</phpunit>
~~~

<p>
    Now let's try to run our test suite... you will get a <code>clover.xml</code> file like following:
</p>

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
    <coverage generated="1345080270">
        <project timestamp="1345080270"></project>
            <file name="/home/ocramius/Desktop/ZendSkeletonApplication/vendor/rwoverdijk/assetmanager/src/ClassName.php">
                <class name="ClassName" namespace="global">
                    <metrics methods="1" coveredmethods="0" conditionals="0" coveredconditionals="0" statements="114" coveredstatements="0" elements="115" coveredelements="0"/>
                </class>
                <line num="12" type="method" name="testMethod" crap="2" count="0"/>
                <line num="15" type="stmt" count="0"/>
                <line num="16" type="stmt" count="0"/>
                <line num="17" type="stmt" count="0"/>
                <line num="18" type="stmt" count="0"/>
                <line num="19" type="stmt" count="0"/>
                <line num="20" type="stmt" count="0"/>
                <-- ... [continues] ... -->
~~~

<p>
    You can read more about this on the
    <a href="http://www.phpunit.de/manual/3.7/en/code-coverage-analysis.html" target="_blank">PHPUnit docs</a>.
</p>

<p>
    We now want to check this log in our script. What seems interesting for us is
    <code>coverage -&gt; project -&gt; file -&gt; class -&gt; metrics -&gt; elements|coveredelements</code>, which
    gives us the number of elements that can could be executed and the number of elements that have been executed.
</p>

<h2>The PHP script</h2>
<p>
    And here's the PHP script that will handle all this. It is just using
    <a href="http://www.php.net/manual/en/simplexml.examples-basic.php" target="_blank">SimpleXMLElement</a> and
    an <a href="http://en.wikipedia.org/wiki/XPath" target="_blank">XPath</a> expression to find elements relevant
    to us and extract them from the XML.
</p>

~~~php
<?php
// coverage-checker.php
$inputFile  = $argv[1];
$percentage = min(100, max(0, (int) $argv[2]));

if (!file_exists($inputFile)) {
    throw new InvalidArgumentException('Invalid input file provided');
}

if (!$percentage) {
    throw new InvalidArgumentException('An integer checked percentage must be given as second parameter');
}

$xml             = new SimpleXMLElement(file_get_contents($inputFile));
$metrics         = $xml->xpath('//metrics');
$totalElements   = 0;
$checkedElements = 0;

foreach ($metrics as $metric) {
    $totalElements   += (int) $metric['elements'];
    $checkedElements += (int) $metric['coveredelements'];
}

$coverage = ($checkedElements / $totalElements) * 100;

if ($coverage < $percentage) {
    echo 'Code coverage is ' . $coverage . '%, which is below the accepted ' . $percentage . '%' . PHP_EOL;
    exit(1);
}

echo 'Code coverage is ' . $coverage . '% - OK!' . PHP_EOL;
~~~

<p>
    The script basically asks for two  input arguments. One is the clover file path and one is the minimum
    percentage of code coverage we want. Usage is like following:
</p>

~~~sh
~$ php coverage-checker.php clover.xml 80
Code coverage is 74.32%, which is below the accepted 80%

~$ php coverage-checker.php clover.xml 70
Code coverage is 74.32% - OK!
~~~

<h2>Putting it in our CI environment</h2>
<p>
    And here's the simple <code>.travis.yml</code> configuration to make everything work!
</p>

~~~yaml
language: php

php:
  - 5.3
  - 5.4

script:
  - phpunit
  - php coverage-checker.php clover.xml 75
~~~

<p>
    Was it hard? Quite impressive for such a simple script combined with what PHPUnit can do! If you don't want to
    try it out yourself, here's a link to a recent build with 100% code coverage:
    <a href="http://travis-ci.org/#!/Ocramius/AssetManager/jobs/2137625/L83" target="_blank">
        http://travis-ci.org/#!/Ocramius/AssetManager/jobs/2137625/L83
    </a>. Now you don't need to ask anyone to write tests for the features they just wrote. Just let the tests fail
    and they'll see it directly! :-)
</p>

<p>
    Enjoy!
</p>