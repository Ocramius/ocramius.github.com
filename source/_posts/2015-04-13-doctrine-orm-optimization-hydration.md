---
layout: post
title: Doctrine ORM Hydration Performance Optimization
category: PHP
tags: ["php", "doctrine", "orm", "hydration", "performance", "speed"]
year: 2015
month: 4
day: 13
published: true
summary: Squeezing performance out of the most expensive operation that Doctrine ORM is doing for you 
description: "Hydration is the most expensive operation performed by Doctrine ORM: how do we prevent it from killing our applications?"
tweet: 587605445000441856
---

<p class="alert alert-warning">
    <span class="label label-warning">PRE-REQUISITE:</span>
    Please note that this article explains complexity in internal ORM operations with the <strong>Big-O</strong>
    notation. Consider reading
    <a href="http://stackoverflow.com/questions/487258/plain-english-explanation-of-big-o" target="_blank">this article</a>, 
    if you are not familiar with the <strong>Big-O</strong> syntax.
</p>

<h2>What is hydration?</h2>

<p>
    Doctrine ORM, like most ORMs, is performing a process called <strong>Hydration</strong> when converting database
    results into objects.
</p>

<p>
    This process usually involves reading a record from a database result and then converting the column values
    into an object's properties.
</p>

<p>
    Here is a little pseudo-code snippet that shows what a mapper is actually doing under the hood:
</p>

~~~php
<?php

$results          = [];
$reflectionFields = $mappingInformation->reflectionFields();

foreach ($resultSet->fetchRow() as $row) {
    $object = new $mappedClassName;

    foreach ($reflectionFields as $column => $reflectionField) {
        $reflectionField->setValue($object, $row[$column]);
    }

    $results[] = $object;
}

return $results;
~~~

<p>
    That's a very basic example, but this gives you an idea of what an ORM is doing for you.
</p>

<p class="alert alert-success">
    As you can see, this is an <code>O(N)</code> operation (assuming a constant number of reflection fields).
</p>

<p>
    There are multiple ways to speed up this particular process, but we can only remove constant overhead from
    it, and not actually reduce it to something more efficient.
</p>

<h2>When is hydration expensive?</h2>

<p>
    Hydration starts to become expensive with complex resultsets.
</p>

<p>
    Consider the following SQL query:
</p>

~~~sql
SELECT
    u.id       AS userId,
    u.username AS userUsername,
    s.id       AS socialAccountId,
    s.username AS socialAccountUsername,
    s.type     AS socialAccountType
FROM
    user u
LEFT JOIN
    socialAccount s
        ON s.userId = u.id
~~~

<p>
    Assuming that the relation from <code>user</code> to <code>socialAccount</code> is a <code>one-to-many</code>,
    this query retrieves all the social accounts for all the users in our application
</p>

<p>
    A resultset may be as follows:
</p>

<table class="table table-bordered table-striped">
    <thead>
        <tr>
            <th>userId</th>
            <th>userUsername</th>
            <th>socialAccountId</th>
            <th>socialAccountUsername</th>
            <th>socialAccountType</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>20</td>
            <td>ocramius</td>
            <td>Facebook</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>21</td>
            <td>@ocramius</td>
            <td>Twitter</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>22</td>
            <td>ocramiusaethril</td>
            <td>Last.fm</td>
        </tr>
        <tr>
            <td>2</td>
            <td>grandpa@example.com</td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
        </tr>
        <tr>
            <td>3</td>
            <td>grandma@example.com</td>
            <td>85</td>
            <td>awesomegrandma9917</td>
            <td>Facebook</td>
        </tr>
    </tbody>
</table>

<p>
    As you can see, we are now joining 2 tables in the results, and the ORM has to perform more complicated operations:
</p>

<dl class="dl-horizontal">
    <dt>
        Hydrate <strong>1</strong>
    </dt>
    <dd>
        <code>User</code> object for
        <i>ocramius@gmail.com</i>
    </dd>
    <dt>
        Hydrate <strong>3</strong>
    </dt>
    <dd>
        <code>SocialAccount</code> 
        instances into 
        <code>User#$socialAccounts</code> 
        for 
        <i>ocramius@gmail.com</i>,
        while skipping re-hydrating
        <code>User</code>
        <i>ocramius@gmail.com</i>
    </dd>
    <dt>
        Hydrate <strong>1</strong>
    </dt>
    <dd>
        <code>User</code>
        object for
        <i>grandpa@example.com</i>
    </dd>
    <dt>
        Skip hydrating
    </dt>
    <dd>
        <code>User#$socialAccounts</code>
        for
        <i>grandpa@example.com</i>,
        as no social accounts are associated
    </dd>
    <dt>
        Hydrate <strong>1</strong>
    </dt>
    <dd>
        <code>User</code>
        object for
        <i>grandma@example.com</i>
    </dd>
    <dt>
        Hydrate <strong>1</strong>
    </dt>
    <dd>
        <code>SocialAccount</code>
        instance into
        <code>User#$socialAccounts</code>
        for
        <i>grandma@example.com</i>
    </dd>
</dl>

<p class="alert alert-info">
    <span class="label label-info">DOCS</span>
    This operation is what is done by Doctrine ORM when you use the
    <abbr title="Doctrine Query Language">DQL</abbr>
    <a href="http://docs.doctrine-project.org/en/latest/reference/dql-doctrine-query-language.html#joins" target="_blank">
        Fetch Joins
    </a>
    feature.
</p>

<p>
    Fetch joins are a very efficient way to hydrate multiple records without resorting to multiple queries, but there
    are two performance issues with this approach (both not being covered by this article):
</p>

<ul>
    <li>
        Empty records require some useless looping inside the ORM internals (see <i>grandpa@example.com</i>'s
        social account). This is a quick operation, but we can't simply ignore those records upfront.
    </li>
    <li>
        If multiple duplicated records are being joined (happens a lot in <code>many-to-many</code> associations),
        then we want to de-duplicate records by keeping a temporary in-memory identifier map.
    </li>
</ul>

<p class="alert alert-danger">
    Additionally, our operation starts to become more complicated, as it is now <code>O(n * m)</code>, with
    <code>n</code> and <code>m</code> being the records in the <code>user</code> and the <code>socialAccount</code>
    tables.
</p>

<p>
    What the ORM is actually doing here is <strong>normalizing</strong> data that was fetched in a de-normalized
    resultset, and that is going through your CPU and your memory.
</p>

<h2>Bringing hydration cost to an extreme</h2>

<p>
    The process of hydration becomes extremely expensive when more than <strong>2</strong> <code>LEFT JOIN</code>
    operations clauses are part of our queries:
</p>

~~~sql
SELECT
    u.id         AS userId,
    u.username   AS userUsername,
    sa.id        AS socialAccountId,
    sa.username  AS socialAccountUsername,
    sa.type      AS socialAccountType,
    s.id         AS sessionId,
    s.expiresOn  AS sessionExpiresOn,
FROM
    user u
LEFT JOIN
    socialAccount sa
        ON sa.userId = u.id
LEFT JOIN
    session s
        ON s.userId = u.id
~~~

<p>
    This kind of query produces a much larger resultset, and the results are duplicated by a lot:
</p>

<table class="table table-bordered table-striped" style="max-width: 500px">
    <thead>
        <tr>
            <th>userId</th>
            <th>user Username</th>
            <th>social Account Id</th>
            <th>social Account Username</th>
            <th>social Account Type</th>
            <th>session Id</th>
            <th>session Expires On</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>20</td>
            <td>ocramius</td>
            <td>Facebook</td>
            <td>ocramius-macbook</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>21</td>
            <td>@ocramius</td>
            <td>Twitter</td>
            <td>ocramius-macbook</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>22</td>
            <td>ocramiusaethril</td>
            <td>Last.fm</td>
            <td>ocramius-macbook</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>20</td>
            <td>ocramius</td>
            <td>Facebook</td>
            <td>ocramius-android</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>21</td>
            <td>@ocramius</td>
            <td>Twitter</td>
            <td>ocramius-android</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>1</td>
            <td>ocramius@gmail.com</td>
            <td>22</td>
            <td>ocramiusaethril</td>
            <td>Last.fm</td>
            <td>ocramius-android</td>
            <td>2015-04-20 22:08:56</td>
        </tr>
        <tr>
            <td>2</td>
            <td>grandpa@example.com</td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
            <td><code>NULL</code></td>
        </tr>
        <tr>
            <td>3</td>
            <td>grandma@example.com</td>
            <td>85</td>
            <td>awesomegrandma</td>
            <td>Facebook</td>
            <td>home-pc</td>
            <td>2015-04-15 10:05:31</td>
        </tr>
    </tbody>
</table>

<p>
    If you try to re-normalize this resultset, you can actually see how many useless de-duplication operation
    have to happen.
</p>

<p>
    That is because the <code>User</code> <i>ocramius@gmail.com</i> has multiple active sessions on
    multiple devices, as well as multiple social accounts.
</p>

<p class="alert alert-danger">
    <span class="label label-warning">SLOW!</span>
    The hydration operations on this resultset are <code>O(n * m * q)</code>, which I'm going to simply
    generalize as <code>O(n ^ m)</code>, with <code>n</code> being the amount of results, and <code>m</code>
    being the amount of joined tables.
</p>

<p>
    Here is a graphical representation of <code>O(n ^ m)</code>:
</p>

<p>
    <img
        src="/img/posts/2015-04-13-doctrine-orm-optimization-hydration/boy-that-escalated-quickly.jpg"
        alt="Boy, that escalated quickly"
    />
</p>

<p>
    Yes, it is bad.
</p>

<h2>How to avoid <code>O(n ^ m)</code> hydration?</h2>

<p>
    <code>O(n ^ m)</code> can be avoided with some very simple, yet effective approaches.
</p>

<blockquote cite="me">
    No, it's not <em>"don't use an ORM"</em>, you muppet.
</blockquote>

<h3>Avoiding <code>one-to-many</code> and <code>many-to-many</code> associations</h3>

<p>
    Collection valued associations are as useful as problematic, as you never know how much data you are
    going to load.
</p>

<p>
    Unless you use <code>fetch="EXTRA_LAZY"</code> and <code>Doctrine\Common\Collections\Collection#slice()</code>
    wisely, you will probably make your app crash if you initialize a very large collection of associated objects.
</p>

<p>
    Therefore, the simplest yet most limiting advice is to avoid collection-valued associations whenever
    they are not strictly necessary.
</p>

<p>
    Additionally, reduce the amount of bi-directional associations to the strict necessary.
</p>

<p>
    After all, code that is not required should not be written in first place.
</p>

<h3>Multi-step hydration</h3>

<p>
    The second approach is simpler, and allows us to exploit how the ORM's <code>UnitOfWork</code> is working
    internally.
</p>

<p>
    In fact, we can simply split hydration for different associations into different queries, or multiple steps:
</p>

~~~sql
SELECT
    u.id         AS userId,
    u.username   AS userUsername,
    s.id         AS socialAccountId,
    s.username   AS socialAccountUsername,
    s.type       AS socialAccountType
FROM
    user u
LEFT JOIN
    socialAccount s
        ON s.userId = u.id
~~~

<p>
    We already know this query: hydration for it is <code>O(n * m)</code>, but that's the best we can do,
    regardless of how we code it.
</p>


~~~sql
SELECT
    u.id        AS userId,
    u.username  AS userUsername,
    s.id        AS sessionId,
    s.expiresOn AS sessionExpiresOn,
FROM
    user u
LEFT JOIN
    session s
        ON s.userId = u.id
~~~

<p>
    This query is another <code>O(n * m)</code> hydration one, but we are now only loading the user sessions
    in the resultsets, avoiding duplicate results overall.
</p>

<p>
    By re-fetching the same users, we are telling the ORM to re-hydrate those objects (which are now in memory,
    stored in the <code>UnitOfWork</code>): that fills the <code>User#$sessions</code> collections.
</p>

<p>
    Also, please note that we could have used a <code>JOIN</code> instead of a <code>LEFT JOIN</code>, but that
    would have triggered lazy-loading on the sessions for the <i>grandpa@example.com</i> <code>User</code>
</p>

<p>
    Additionally, we could also skip the <i>userUsername</i> field from the results, as it already is in memory
    and well known.
</p>

<p class="alert alert-success">
    <span class="label label-success">SOLUTION:</span>
    We now reduced the hydration complexity from <code>O(n ^ m)</code> to <code>O(n * m * k)</code>, with
    <code>n</code> being the amount of <code>User</code> instances, <code>m</code> being the amount of associated
    <code>to-many</code> results, and <code>k</code> being the amount of associations that we want to hydrate.
</p>

<h3>Coding multi-step hydration in Doctrine ORM</h3>

<p>
    Let's get more specific and code the various queries represented above in
    <abbr title="Doctrine Query Language">DQL</abbr>.
</p>

<p>
    Here is the <code>O(n ^ m)</code> query (in this case, <code>O(n ^ 3)</code>):
</p>

~~~php
return $entityManager
    ->createQuery('
        SELECT
            user, socialAccounts, sessions 
        FROM
            User user
        LEFT JOIN
            user.socialAccounts socialAccounts
        LEFT JOIN
            user.sessions sessions
    ')
    ->getResult();
~~~

<p>
    This is how you'd code the multi-step hydration approach:
</p>


~~~php
$users = $entityManager
    ->createQuery('
        SELECT
            user, socialAccounts
        FROM
            User user
        LEFT JOIN
            user.socialAccounts socialAccounts
    ')
    ->getResult();

$entityManager
    ->createQuery('
        SELECT PARTIAL
            user.{id}, sessions
        FROM
            User user
        LEFT JOIN
            user.sessions sessions
    ')
    ->getResult(); // result is discarded (this is just re-hydrating the collections)

return $users;
~~~

<p>
    I'd also add that this is the only legitimate use-case for partial hydration that I ever
    had, but it's a personal opinion/feeling.
</p>

<h2>Other alternatives (science fiction)</h2>

<p>
    As you may have noticed, all this overhead is caused by normalizing de-normalized data coming
    from the DB.
</p>

<p>
    Other solutions that we may work on in the future include:
</p>

<ul>
    <li>
        Generating hydrator code - solves constant overhead issues, performs better with
        <abbr title="Just In Time">JIT</abbr> engines such as <abbr title="HipHop VM">HHVM</abbr>
    </li>
    <li>
        Leveraging the capabilities of powerful engines such as PostgreSQL, which comes with JSON
        support (since version 9.4), and would allow us to normalize the fetched data to some extent
    </li>
    <li>
        Generate more complex SQL, creating an own output format that is "hydrator-friendly" (re-inventing
        the wheel here seems like a bad idea)
    </li>
</ul>

<h2>Research material</h2>

<p>
    Just so you stop thinking that I pulled out all these thought out of thin air, here is a repository
    with actual code examples that you can run, measure, compare and patch yourself:
</p>

<h4>
    <a href="https://github.com/Ocramius/Doctrine2StepHydration" target="_blank">
        https://github.com/Ocramius/Doctrine2StepHydration
    </a>
</h4>

<p>
    Give it a spin and see the results for yourself!
</p>
