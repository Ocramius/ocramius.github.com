---
layout: post
title: On Aggregates and their interaction with the external world
category: PHP
tags: ["php", "ddd", "cqrs", "event sourcing", "aggregate", "aggregate root", "patterns", "clean code"]
year: 2017
month: 1
day: 25
published: true
summary: IDDD/DDD Aggregates often have to talk to the external world somehow: a practical approachs
description: A practical example of how DDD Aggregates can talk to the external world without the need to "know" about its 
tweet: s
---

<p>
    Some time ago, I was asked where I put I/O operations when dealing with
    aggregates.
</p>

<div data-tweet-id="808545609468801024" class="twitter-tweet"></div>

<p>
    The context was a <abbr title="command query responsibility segregation">CQRS</abbr>
    and Event Sourced architecture, but in general, the approach that I prefer also applies to most
    imperative ORM entity code (assuming a proper data-mapper is involved).
</p>

<h3>Scenario</h3>

<p>
    Let's take a practical scenario as a reference:
</p>

~~~gherkin
Feature: credit card payment for a shopping cart checkout

  Scenario: a user must be able to check out a shopping cart
    Given the user has added some products to their shopping cart
    When the user checks out the shopping cart with their credit card
    Then the user was charged for the shopping cart total price
  
  Scenario: a user must not be able to check out an empty shopping cart
    When the user checks out the shopping cart with their credit card
    Then the user was not charged
  
  Scenario: a user cannot check out an already purchased shopping cart
    Given the user has added some products to their shopping cart
    And the user has checked out the shopping cart with their credit card
    When the user checks out the shopping cart with their credit card
    Then the user was not charged
~~~

<p>
    The scenario is quite generic, but we can all understand what the application is
    supposed to do.
</p>

<p>
    I will take an imperative command + event approach, but will not dig into the patterns
    behind it. Hopefully, the pseudo-code will be sufficient for you to understand all
    of the examples.
</p>

<h3>An initial implementation</h3>

<p>
    At first glance, we are looking at a command like following:
</p>

~~~php
final class CheckOutShoppingCart
{
    public static function from(
        CreditCardCharge $charge,
        ShoppingCartId $shoppingCart
    ) : self {
        // ...
    }
    
    public function charge() : CreditCardCharge { /* ... */ }
    public function shoppingCart() : ShoppingCartId { /* ... */ }
}
~~~

<p>
    And here's a naive aggregate performing the actual domain logic work
</p>

~~~php
final class ShoppingCart
{
    // ... 
    
    public function checkOut(CapturedCreditCardCharge $payment) : void
    {
        $this->charge = $charge;
        
        $this->raisedEvents[] = ShoppingCartCheckedOut::from(
            $this->id,
            $this->charge
        );
    }
    
    // ... 
}
~~~

<p>
    We need to glue this all together with a command handler:
</p>

~~~php
final class HandleCheckOutShoppingCart
{
    // ... 
    
    public function __invoke(CheckOutShoppingCart $command) : void
    {
        // assignment is redundant for clarity to the reader
        $shoppingCart = $this->carts->get($command->shoppingCart());
        
        $payment = $this->paymentGateway->captureCharge($command->charge());
        
        $shoppingCart->checkOut($capturedCharge);
    }
}
~~~

<p>
    This covers the "happy path" of our workflow, but we still lack:
</p>

<ul>
    <li>The ability to check whether the payment has already occurred</li>
    <li>Preventing payment for empty shopping carts</li>
    <li>Preventing payment of an incorrect amount</li>
    <li>Handling of critical failures on the payment gateway</li>
</ul>

<p>
    In order to do that, we have to add some "guards" that prevent the interaction.
    This is the approach that I've seen being used in the wild:
</p>


~~~php
final class HandleCheckOutShoppingCart
{
    // ... 
    
    public function __invoke(CheckOutShoppingCart $command) : void
    {
        $cartId = $command->shoppingCart();
        $charge = $command->charge();

        // assignment is redundant for clarity to the reader
        $shoppingCart = $this->carts->get($cartId);
        
        ($this->nonEmptyShoppingCart)($cartId);
        ($this->nonPurchasedShoppingCart)($cartId);
        ($this->paymentAmountMatches)($cartId, $charge->amount());
        
        $payment = $this->paymentGateway->captureCharge($charge);
        
        $shoppingCart->checkOut($capturedCharge);
    }
}
~~~

<p>
    As you can see, we are adding some logic to our command handler here.
    This is usually done because dependency injection on the command handler
    is easy, whereas doing it on the aggregate root is generally <a
    href="http://misko.hevery.com/2008/09/30/to-new-or-not-to-new/" target="_blank">problematic</a>
</p>

<p>
    With this code, we are able to handle most unhappy paths, and eventually
    also failures of the payment gateway.
</p>

<h3>The problem</h3>

<p>
    While the code above works, what we did is adding some domain-specific logic
    to the command handler. Since the command handler is part of our application
    layer, we are effectively diluting these checks into "less important layers". 
</p>

<p>
    In addition to that, we now require the command handler when writing tests
    that consume the above specification: without the command handler, our logic
    will fail to handle the unhappy paths correctly.
</p>

<p>
    For those that are reading and apply CQRS+<abbr title="Event Sourcing>ES</abbr>:
    you also know that those guard aren't that simple to implement!
    Read models, projections... Oh my!
</p>

<p>
    Also: what if we wanted to react to those failures, rather than just stop
    execution? Who is responsible or that?
</p>

<p>
    If you went the <abbr title="test driven development">TDD</abbr> way, then
    you already saw all of this coming. Let's fix it!
</p>

<h3>A possible solution</h3>

<p>
    What we did is putting logic from the domain layer (which should be in the aggregate)
    into the application layer: let's turn around and put domain logic in the domain (reads:
    in the aggregate logic).
</p>

<p>
    Since we don't really want to inject a payment gateway as a constituent part
    of our aggregate root (it shouldn't be a dependency, after all!), we just borrow
    a brutally simple concept from functional programming: we pass the interactor
    as a parameter.
</p>

~~~php
final class ShoppingCart
{
    // ... 
    
    public function checkOut(
        CheckOutShoppingCart $checkOut,
        PaymentGateway $paymentGateway
    ) : void {
        $charge = $checkOut->charge();

        Assert::null($this->payment, 'Already purchased');
        Assert::greaterThan(0, $this->totalAmount, 'Price invalid');
        Assert::same($this->totalAmount, $charge->amount());

        $this->charge = $paymentGateway->captureCharge($charge);

        $this->raisedEvents[] = ShoppingCartCheckedOut::from(
            $this->id,
            $this->charge
        );
    }
    
    // ... 
}
~~~

<p>
    The command handler will also be massively simplified, since all what it
    does is forward all the required information to the aggregate:
</p>

~~~php
final class HandleCheckOutShoppingCart
{
    // ... 
    
    public function __invoke(CheckOutShoppingCart $command) : void
    {
        $this
            ->shoppingCarts
            ->get($command->shoppingCart())
            ->checkOut($command, $this->paymentGateway);
    }
}
~~~

<h3>Conclusions</h3>

<p>
    We can obviously continue with what this enables, but I think that it is all very clear,
    so I will just list it here to keep things short and nice:
</p>

<ol>
    <li>
        We can run the domain without infrastructure code (note: the payment gateway is a
        domain service)
    </li>
    <li>
        We can prevent invalid interactions to happen without having to push verification
        data across layers
    </li>
    <li>
        Our aggregate is now able to fullfill its role: being a domain-specific state machine.
        If something goes wrong, then the aggregate is able to revert state mutations.
    </li>
    <li>
        We can raise more domain events on failures.
    </li>
    <li>
        The domain logic is in one place, easy to read and easy to change.
    </li>
</ol>

<p>
    This does not just apply to CQRS users: anyone having domain logic that
    is mixed up between services and entities can benefit from it. Feel free
    to stuff business logic into your entity API.
</p>

<p>
    Just remember that entities should only be self-aware, and only context-aware
    in the context of certain business interactions: don't inject services as
    constructor dependencies.
</p>
