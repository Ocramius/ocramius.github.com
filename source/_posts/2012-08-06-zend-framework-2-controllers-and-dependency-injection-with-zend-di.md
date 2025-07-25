---
layout: post
title: ZF2, Zend Di and Controllers for fast SOA development
category: PHP
tags: ["zend", "zendframework", "dependency", "injection", "di", "dic", "soa", "mvc"]
year: 2012
month: 08
day: 06
published: true
summary: A quick overview of how to use Zend\Di from Zend Framework 2 to retrieve controllers in a SOA architecture using ZF2's Zend\Mvc
---

<h2>What is Zend\Di</h2>
<p>
    <code>Zend\Di</code> is a component introduced in early Beta versions of ZendFramework 2. Its job is to
    provide you with instances of a requested object populated with all the dependencies required for it to work
    correctly. If you're not familiar with it, you can read more about <code>Zend\Di</code> on the
    <a href="http://zf2.readthedocs.org/en/latest/modules/zend.di.introduction.html"
    title="Zend Framework 2 Zend\Di manual" target="_blank">ZF2 Zend\Di manual pages</a> and eventually try
    out <a href="https://github.com/ralphschindler/Zend_DI-Examples" title="examples about Zend\Di usage"
    target="_blank">Ralphschindler's examples</a>.
</p>

<hr/>

<h2>Why Zend\Di?</h2>
<p>
    <code>Zend\Di</code> has often been accused of being slow and complex to follow. It is if you don't have any
    experience with it. I will try to make a simple example of correct usage of it, directly taking my examples
    from how I develop with ZF2 daily. We will also cover the performance problem later in this blogpost.
</p>
<p>
    The reason why I use Zend\Di despite of its slowness is development time and clean
    <abbr title="Inversion of Control">IOC</abbr>. I am also quite experienced with it, so I learned to tame it
    and to take advantage of it over time, now it almost works as a linting tool for my code.
</p>
<p>
    When working with complex application structures with dozens of different services, repositories,
    controllers, caches and more you tend to do some mistakes (caused by lazyness) that will penalize you on the
    long run. Such mistakes are things like avoiding IOC to speed up development, or using setters for your hard
    dependencies because you don't know how to retrieve all dependencies at instantiation time. Even by
    following best practices, you will often be slowed down by having to maintain all the factories that are
    responsible for generating your controllers! Here's how I do it.
</p>

<hr/>

<h2>Let's get started!</h2>
<p>
    We will be developing a simple "greeting" action controller with a <code>helloAction</code>. It will consume
    a GreetingService, which produces greeting messages by fetching them from a given message container.
</p>

<p>
    First, let's get a skeleton application to work. Please mind that we're going to work within the Application
    module provided by ZendSkeletonApplication, but you should apply these concepts only for your own modules!
</p>

~~~sh
~$ git clone git://github.com/zendframework/ZendSkeletonApplication.git
~$ cd ZendSkeletonApplication
~$ ./composer.phar install
~~~

<p>
    <span class="label label-info">For the lazy:</span> If you just prefer to look at the code and run it
    without having to reproduce my example, you can just look at the already modified skeleton at
    <a href="https://github.com/Ocramius/ZendSkeletonApplication/tree/demo/zf2-controllers-from-zend-di/module">
        Ocramius/ZendSkeletonApplication - branch demo/zf2-controllers-from-zend-di
    </a> and see what I did in the
    <a href="https://github.com/Ocramius/ZendSkeletonApplication/compare/master...demo;zf2-controllers-from-zend-di" target="_blank">diff</a>.
</p>

<p>
    You should now be able to browse to <code>http://localhost/path-to-skeleton-application/</code> and see the
    ZendSkeletonApplication default intro page.
</p>

<hr/>

<h2>The code</h2>
<p>
    Here are our service, greeting container and controller: that's the core of our application. I will already
    start with IOC, since I don't think I need to explain why I like it (nor am I qualified to do so!), and you
    already have read this far.
</p>

<h4>Greetings repository:</h4>
<p>
    A simple repository that fetches a random greeting message from an array.
</p>

~~~php
<?php
// module/Application/src/Application/Repository/StaticGreetingRepository.php

namespace Application\Repository;

class StaticGreetingRepository
{
    protected $availableGreetings = array('Hi', 'Hello', 'Hey', 'What\'s up');

    /** @return string */
    public function getRandomGreeting()
    {
        return $this->availableGreetings[array_rand($this->availableGreetings)];
    }
}
~~~

<h4>Greetings service (consumes repository):</h4>
<p>
    A service that assembles the entire message by picking a random greeting from a given repository and a
    provided name.
</p>
~~~php
<?php
// module/Application/src/Application/Service/GreetingService.php

namespace Application\Service;

use Application\Repository\StaticGreetingRepository;

class GreetingService
{
    protected $repository;

    /** @var StaticGreetingRepository $repository */
    public function __construct(StaticGreetingRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * this is an example method. It could perform operations such as discovering
     * the gender of the given name to customize the reply
     *
     * @var    string $name
     * @return string
     */
    public function greet($name)
    {
        return $this->repository->getRandomGreeting() . ' ' . $name . '!';
    }
}
~~~

<h4>Greetings controller (consumes service):</h4>
<p>
    A controller we use to collect a <code>GET</code> request and return the message to the end user.
</p>

~~~php
<?php
// module/Application/src/Application/Controller/GreetingController.php

namespace Application\Controller;

use Application\Service\GreetingService;
use Zend\Mvc\Controller\AbstractActionController;
use Zend\View\Model\ViewModel;

class GreetingController extends AbstractActionController
{
    /**
     * @var GreetingService
     */
    protected $greetingService;

    /**
     * @var GreetingService $greetingService
     */
    public function __construct(GreetingService $greetingService)
    {
        $this->greetingService = $greetingService;
    }

    public function helloAction()
    {
        $name = $this->getRequest()->getQuery('name', 'anonymous');

        return new ViewModel(array('greeting' => $this->greetingService->greet($name)));
    }
}
~~~

<h4>And then a view to see some output:</h4>
~~~php 
<?php
// module/Application/view/application/greeting/hello.phtml
echo '<h1>' . $this->escapeHtml($this->greeting) . '</h1>';
~~~

<hr/>

<h2>Wiring it together</h2>
<p>
    To allow <code>Zend\Di</code> to work correctly with our application, we now need to allow our application
    to access the controller somehow. To do so, we have to define <code>config.di.allowed_controllers</code> and
    a route to allow access to our controller (and a couple of fixes required to inject inherited dependencies).
</p>

~~~php 
<?php

return array(
    'di' => array(
        'allowed_controllers' => array(
            // this config is required, otherwise the MVC won't even attempt to ask Di for the controller!
            'Application\Controller\GreetingController',
        ),

        'instance' => array(
            'preference' => array(
                // these allow injecting correct EventManager and ServiceManager
                // (taken from the main ServiceManager) into the controller,
                // because Di doesn't know how to retrieve abstract types. These
                // dependencies are inherited from Zend\Mvc\Controller\AbstractController
                'Zend\EventManager\EventManagerInterface' => 'EventManager',
                'Zend\ServiceManager\ServiceLocatorInterface' => 'ServiceManager',
            ),
        ),
    ),

    'router' => array(
        'routes' => array(
            'hello' => array(
                'type' => 'Zend\Mvc\Router\Http\Literal',
                'options' => array(
                    'route'    => '/hello',
                    'defaults' => array(
                        'controller' => 'Application\Controller\GreetingController',
                        'action'     => 'hello',
                    ),
                ),
            ),
        ),
    ),

    // remaining config
);
~~~

<hr/>

<h2>Running it!</h2>
<p><strong>Seriously?</strong> Was that all? The answer is yes!</p>
<p>This will give you a basic example that renders a web page like the following:</p>

<p>
    <img
        style="box-shadow: 0 0 3px 5px #000"
        src="/img/posts/2012-08-6-zend-framework-2-controllers-and-dependency-injection-with-zend-di/zend-di-controller-sample-preview.png"
        alt="Preview of the output of the Zend\Di based Mvc SOA example"
    />
</p>

<hr/>

<h2>Considerations</h2>
<p>
    Ok, what did just happen? <code>Zend\Di</code> recursively discovered all hard dependencies and built a
    fully operational controller for us! And that with very clean and simple code.
</p>
<p>
    Some may argue that this is "dark magic". It is not, it is just another way of wiring things together,
    and I am not suggesting it for your production environment nor as a definitive solution to solve all your
    dependency injection problems: just for development.
</p>

<hr/>

<h2>Performance issues</h2>
<p><span class="label label-important">Careful!</span> Performance impact of using <code>Zend\Di</code> over a
    ServiceManager factory is around 15%, and that overhead increases with the number and recursion of the
    dependencies.
    Enabling complex Di based modules such as <a href="https://github.com/Ocramius/ZfPhpcrOdm" target="_blank">
    ocramius/zf-phpcr-odm</a> may affect performance by an order of 200% or more!
</p>
<p>
    But that is perfectly fine in a development environment, since we want to get working as fast as possible
    and keeping our code clean and simple. This is simply not possible in a context where dependencies continue
    to change because of architectural changes in your application. You must be free to do your decisions before
    freezing everything into a Service Factory!
</p>
<p>
    If you want to remove the performance overhead and still keep the benefits of using Zend\Di, you can try my
    <a href="https://github.com/Ocramius/OcraDiCompiler" target="_blank">ocramius/ocra-di-compiler</a>, which
    simply does the work you should do when you want to compile your Di container into a series of service
    factories/PHP closures.
</p>
<p>
    Otherwise, simply do following in your configuration once you are sure your dependencies won't change much:
</p>

~~~php 
<?php

return array(
    'controllers' => array(
        'factories' => array(
            'Application\Controller\GreetingController' => function($sm) {
                return new \Application\Controller\GreetingController(
                    new \Application\Service\GreetingService(
                       new \Application\Repository\StaticGreetingRepository()
                    ),
                );
            },
        ),
    ),

    // remaining config
);
~~~

<p>
    This basically removes all the overhead, but also removes the flexibility of <code>Zend\Di</code>, since
    you won't be able to swap the implementation of either the <code>GreetingService</code> or the
    <code>StaticGreetingRepository</code> used to dispatch your request. I personally see this as one of the
    last steps before shipping your code for production, since OcraDiCompiler can handle these operations for
    you.
</p>

<p>
   <span class="label label-info">Note:</span>  Please also note that in this example, all dependency injection
     are based on type hints of concret  implementations. I cleaned up my code and invite you to check
    <a href="https://github.com/Ocramius/ZendSkeletonApplication/tree/demo/zf2-controllers-from-zend-di-cleanup/module" target="_blank">
        Ocramius/ZendSkeletonApplication - demo/zf2-controllers-from-zend-di-cleanup
    </a> and see what I did in the
    <a href="https://github.com/Ocramius/ZendSkeletonApplication/compare/demo;zf2-controllers-from-zend-di...demo;zf2-controllers-from-zend-di-cleanup" target="_blank">diff</a>.
    In this case I simply exchanged the type hints with abstract types (which allow more flexibility) and taught
    <code>Zend\Di</code> how to handle injections for them.
</p>

<p>
    To check how I improved performance using <code>ocramius/ocra-di-compiler</code>, please refer to branch
    <a href="https://github.com/Ocramius/ZendSkeletonApplication/tree/demo/zf2-controllers-from-zend-di-with-compiled-di/module" target="_blank">
        Ocramius/ZendSkeletonApplication - demo/zf2-controllers-from-zend-di-with-compiled-di
    </a> and to the related <a href="https://github.com/Ocramius/ZendSkeletonApplication/compare/demo;zf2-controllers-from-zend-di-cleanup...demo;zf2-controllers-from-zend-di-with-compiled-di" target="_blank">diff</a>.
</p>

<hr/>

<h2>Conclusions</h2>
<p>
    As I've stated from the beginning, this is a development process, not something you want to have happening
    at runtime at every request. <code>Zend\Di</code> is a very powerful tool, especially when it comes to
    testing, exchenging deeply nested dependencies and keeping IOC as clean as possible. Use it wisely and it
    may become your best ally while handling your usual impossible customer, but maybe this time without
    screwing up as much code as usual ;-)
</p>