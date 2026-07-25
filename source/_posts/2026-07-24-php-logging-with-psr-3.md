---
layout: post
title: Proper logging in PHP with PSR-3
category: Blog
tags: [ "logging", "php", "software design", "psr-3" ]
year: 2026
month: 07
day: 24
published: true
summary: "Logging with PSR-3 in PHP - the proper way"
description: Common logging usage in PHP, how to do it well, and what to avoid
---

<h3>Who is this article for?</h3>

<p>
    This post is for people that do day-by-day busywork coding, and for team leads that want to direct their
    peers towards better logging practices.
</p>

<p>
    Note that this article comes from my regular need to present these exact points to different people, multiple
    times a year, in multiple teams, in multiple companies.
</p>

<p>
    Also, we will not talk about how to <b>configure</b> a <a href="www.php-fig.org/psr/psr-3/">PSR-3</a> logger,
    but rather how to <b>use</b> one.
</p>

<h3>Handling errors properly</h3>

<p>
    Error/exception handling is the main use-case for logging.
</p>

<p>
    When logging exceptions, please pass the <code>Throwable</code> instance to the <code>'exception'</code> context key.
</p>

~~~php
try {
    // logic here
} catch (SomeException $failed) {
    $this->logger->error('Something went wrong', [
        'exception' => $failed,
    ]);
}
~~~

<p>
    Avoid cluttering the logger call with data deriving from the exception: it's not the logger call-site's job,
    and you are just repeating work.
</p>

<p>
    I often see <b>unnecessary code like</b>:
</p>

~~~php
try {
    // logic here
} catch (SomeException $failed) {
    $this->logger->error('Something went wrong', [
        // first mistake: we forgot 'exception'
        'previous' => $failed->getPrevious(), // let the logger do this!
        'line' => $failed->getLine(), // already part of the stack trace
        'error' => $failed->getMessage(), // also always rendered
        'error_type' => $failed::class, // done by the logger, usually
    ]);
}
~~~

<p>
    The logger itself must instead be configured (and usually already <b>is</b> configured) to render:
</p>

<ul>
    <li>
        the exception <code>::class</code>
    </li>
    <li>
        the exception message and code (codes are not really relevant any more, in this century)
    </li>
    <li>
        the stack trace
    </li>
    <li>
        previous exceptions
    </li>
    <li>
        additional exception fields
    </li>
</ul>

<p>
    Your responsibility is to instead <b>pass context</b> information <b>that the logger can't infer on its own</b>.
</p>

<h4>
    What if my code fails gracefully, and <b>does not raise an exception</b>?
</h4>

~~~php
if (is_wrong($something)) {
    $this->logger->warn('Something went wrong', ['something' => $something]);
}
~~~

<p>
    For business-specific failures that deserve a type, we can upcast them to a <code>Throwable</code> anyway:
</p>

~~~php
if (is_wrong($something)) {
    $this->logger->warn('Something went wrong', [
        'something' => $something,
        'exception' => new SomethingWentWrong($something), // Throwable
    ]);
}
~~~

<p>
    Having clear exception types, even if used just with the logger, will allow you to easily
    detect multiple code locations affected by the same kind of failure later on.
</p>

<p>
    Beware: raising exceptions and logging both come with substantial CPU, memory and IO overhead,
    so you should always decide carefully when logging and exceptions can be raised in a tight loop.
</p>

<p>
    Remember also that a <code>Throwable</code> always collects the entire stack trace it was raised from,
    which may affect garbage collection, if the logger keeps messages in memory.
</p>

<p>
    Loggers are perfectly capable of determining the stack trace of a raised log message: the <code>'exception'</code>
    key is not necessary for that feature to work, so creating a new <code>Throwable</code> is your decision.
</p>

<h3>
    "Some logs" are better than "no logs"
</h3>

<p>
    I'm personally not a fan of cluttering code with log and debug statements, but it is undeniable that logging will
    help you keep a general understanding of how your software is behaving in production, both when healthy or unhealthy. 
</p>

<p>
    A system that produces <b>no output</b> may be functioning perfectly, or be completely broken: having some insight
    into whether it is "still ticking" is a good idea.
</p>

<blockquote cite="me">
    Not sure if everything OK, or monitoring is broken.
</blockquote>

<p>
    I recommend having <code>$logger->info('Heartbeat');</code> or similar calls in code that runs in long-running
    operations, polling loops, or that are sitting idly, waiting for input:
</p>

~~~php
$eventLoop->whenever(function ($someEvent) {
    // main application logic
});

$eventLoop->periodically(function () {
    $this->logger->info('still here, waiting for you');
}, Time::seconds()->multiply(120));

$eventLoop->run();
~~~

<p>
    You can either configure the logger or the call-site to only log a percentage of the calls,
    where the system would otherwise become too chatty.
</p>

<p>
    Periodically logging is not a replacement for
    <a href="https://github.com/inadarei/rfc-healthcheck/blob/5dc80646edea9415ecaece9d51de79bc8ef0f744/draft-inadarei-api-health-check-06.txt">
        a health-check probe
    </a>.
</p>

<h3>Injecting loggers</h3>

<p>
    Please <b>use dependency injection</b> when requesting a logger:
</p>

~~~php
final readonly class MyService implements SomeService
{
    public function __construct(private LoggerInterface $logger) {}
    
    function someLogic() {
        $this->logger->debug('Look ma, I got the logger via DI!');
    }
}
~~~

<p>
    Besides avoiding the pitfalls of service location and global state, you get:
</p>

<ul>
    <li>
        a clear declaration that your code unit will emit log messages
    </li>
    <li>
        the possibility of picking a specific logger for each service
    </li>
    <li>
        the ability to use non-magic test spies/mocks to verify logging behaviors
    </li>
</ul>

<p>
    Here's how one could customize the logger in a service definition:
</p>

~~~php
$serviceDefinitions->add(
    SomeService::class,
    function (MainLogger $rootLogger) { 
        return new MyService(
            $rootLogger
                ->forWiredService(SomeService::class)
                ->withEnvironment($someEnvironment)
        );
    }
);
~~~

<p>
    Here's how one could work with log messages in a test:
</p>

~~~php
#[Test]
function my_service_does_a_bunch_of_things_in_a_very_specific_order(): void
{
    $testSpyLogger = new RecordingLogger();

    $systemUnderTest = new MyService($testSpyLogger);

    $systemUnderTest->doSomeWork();

    Assert::equals(
        [
            'Extracted data',
            'processed row A',
            'processed row B',
            'failed to process row C',
            'finished',
        ],
        $testSpyLogger->messages
    );
}
~~~

<h3>Using the logger for measurements?</h3>

<p>
    I often see teams using loggers to record metric information, then <code>grep</code>ping through the result,
    to produce graphs or further analytics data:
</p>

~~~php
final readonly class LoggedCart implements CartService {
    public function __construct(
        // ...
        private LoggerInterface $logger,
    ) {}

    public function cartCheckout(
        // ...
    ): void {
        // ...
        
        $this->logger->info(
            'cart.checkout',
            ['total_amount' => $cart->totalAmount()]
        );
    }
}
~~~

<p>
    While you can most certainly do that, <b>the logger is the wrong abstraction for metrics</b>. 
</p>

<p>
    The correct tool for metrics is
    <a href="https://github.com/open-telemetry/opentelemetry.io/blob/0916db501b8b2562b21e2fb56dea97aab38d3266/content/en/docs/concepts/signals/metrics.md">OTEL metrics</a>,
    (although any "metrics-alike" tooling works too):
</p>

~~~php
final readonly class LoggedCart implements CartService {
    public function __construct(
        // ...
        MeterProvider $metrics,
    ) {
        $this->checkoutAmounts = $metrics->createHistogram('cart.checkout.total_amount');
    }

    public function cartCheckout(
        // ...
    ): void {
        // ...
        
        $this->checkoutAmounts->record($cart->totalAmount());
    }
}
~~~

<p>
    See also <a href="https://github.com/open-telemetry/opentelemetry-php/blob/c948c8fe4eff3c6264f02b6a92e8b44f577ef2d5/src/API/Metrics/MeterProviderInterface.php">the <code>MeterProviderInterface</code></a>.
</p>

<p>
    With this setup, your metrics can be collected more efficiently (in batches), and can be sent to dedicated
    backends, such as time series databases, ready to be viewed.
</p>

<p>
    Note that you are still free to wire the metrics reader so that it forwards recorded metrics to your logger!
</p>

<h3>Logging durations</h3>

<p>
    You will often see developers logging the elapsed time for an operation:
</p>

~~~php
final readonly class CreditCardCheckout implements Checkout {
    public function __construct(
        // ...
        private LoggerInterface $logger,
    ) {}

    public function cartCheckout(
        // ...
    ): void {
        $start = $this->clock->now();
        $this->logger->debug('checkout.start', ['time' => $start])
        // ...
        
        $end = $this->clock->now();
        $this->logger->log(
            'checkout.end',
            [
                'time'     => $end,
                'duration' => $end->diff($start)
            ]
        );
    }
}
~~~

<p>
    Similarly to metrics, a logger is not the correct abstraction: instead, look at
    <a href="https://github.com/open-telemetry/opentelemetry.io/blob/0916db501b8b2562b21e2fb56dea97aab38d3266/content/en/docs/concepts/signals/traces.md">OTEL Tracing</a>
</p>

<p>
    Traces allows for a cleaner implementation:
</p>

~~~php
final readonly class CreditCardCheckout implements Checkout {
    public function __construct(
        // ...
        private Tracer $tracer,
    ) {}

    public function cartCheckout(
        // ...
    ): void {
        $span = $this->tracer->spanBuilder('checkout')
            ->startSpan();

        // ... 

        $span->end();
    }
}
~~~

<p>
    The API can be further improved with your own <code>Tracer</code> additions, and you can still
    send span start/end to your logger.
</p>

<p>
    By using the correct abstraction, dedicated trace collector software (such as
    <a href="https://www.jaegertracing.io/">Jaeger</a>, <a href="https://zipkin.io/">Zipkin</a>, AWS X-Ray, etc.)
    can give you full insight into how operations are nested, run concurrently, etc:
</p>

<p>
    <img
        src="../../img/posts/2026-07-24-php-logging-with-psr-3/distributed-trace-jaeger.png"
        alt="An example trace containing multiple parallel spans in different services. Image taken from https://github.com/open-telemetry/opentelemetry-php/tree/c948c8fe4eff3c6264f02b6a92e8b44f577ef2d5/examples/traces/demo"
    >
</p>

<h3>Message interpolation</h3>

<p>
    Please don't do this:
</p>

~~~php
$this->logger->info('user ' . $user->username() . ' logged in');
~~~

<p>
    PSR-3 specifies a <code>{bracket_based}</code> message interpolation convention, which you can rely upon:
</p>

~~~php
$this->logger->info(
    'user {username} logged in',
    ['username' => $user->username()]
);
~~~

<p>
    With the above, you gain:
</p>

<ul>
    <li>
        a structured, searchable "username" field in your logs 
    </li>
    <li>
        clarity on which bits of the message are dynamic, especially when interpolated values contain spaces
    </li>
</ul>

<h3>Log levels</h3>

<p>
    The log level mostly has an effect on:
</p>

<ul>
    <li>
        whether the log message will be emitted
    </li>
    <li>
        who will be notified
    </li>
</ul>

<p>
    It is important to not raise the log level unnecessarily,
    or you may run into a full disk, capped out monitoring system, full email inbox, or annoyed
    on-call coworker.
</p>

<blockquote cite="me">
    Logs should capture our attention only when relevant: attention is a valuable currency
</blockquote>

<p>
    When reviewing new code, always ask yourself whether you can "push the log level down".
</p>

<p>
    For tight loops, <code>debug</code> could suffice. You also don't want to see these messages in production: they
    should be turned off by default.
</p>

<p>
    Successful operations should probably receive an <code>info</code> level: you also want to know if a system
    is working correctly.
</p>

<p>
    For acceptable blips in your data, a <code>notice</code> could work.
</p>

<p>
    Data processing that failed, but recovered, should probably receive a <code>warning</code>.
</p>

<p>
    Anything from <code>exception</code> up should be discussed within your team and business domain, when introduced.
</p>

<h3>Avoid performing I/O during logging</h3>

<p>
    Logging is a delicate matter: avoid making it more delicate, as it is your last resort in trying to
    understand a failing system.
</p>

<p>
    Following code is problematic:
</p>

~~~php
$this->logger->error(
    'user {username} failed to log in',
    [
        'exception' => $exception,
        'username'  => $this->users->get($userId)->username()
    ]
);
~~~

<p>
    At this stage, you do not know if the system is in an irrecoverable state, and this entire expression may fail.
</p>

<p>
    Additionally, your logging operation is potentially slowing down the system: perhaps logging <code>$userId</code>
    sufficed?
</p>

<p>
    As a good rule of thumb, the logger call-site should not perform expressions that can <code>@throw</code>,
    or which interact with global state (a <code>@phpstan-pure</code> or <code>@psalm-pure</code> declaration can help).
</p>

<h3>Conclusion</h3>

<p>
    This article hopefully contains things that you can point at when discussing logger usages with your colleagues:
    I sure needed this compendium of patterns for my future self ☺️
</p>