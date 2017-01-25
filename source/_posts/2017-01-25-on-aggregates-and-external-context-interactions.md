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
    A bit of time ago, I was asked where I put I/O operations when dealing with
    aggregates.
</p>

<!-- link to verraes' tweet here -->

<p>
    The context was a <abbr title="command query responsibility segregation">CQRS</abbr>
    and Event Sourced architecture, but in general, the approach that I prefer also applies to most
    imperative ORM entity code (assuming proper data-mapper).
</p>

<h3>Scenario</h3>

<p>
    In order to make the scenario clear, let's take a practical example:
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
    I will take an imperative command + event approach, but I will not dig into the patterns
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
    public static function from(CreditCardCharge $charge, ShoppingCartId $shoppingCart) : self {
        // ... not relevant ...
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
        Assert::null($this->payment);
        Assert::greaterThan(0, $this->totalAmount);
        Assert::same($this->totalAmount, $payment->amount);
        
        $this->charge = $charge;
        
        $this->raisedEvents[] = ShoppingCartCheckedOut::from($this->id);
    }
    
    // ... 
}
~~~

<p>
    And then we need to glue this all together with a command handler:
</p>

~~~php
final class HandleCheckOutShoppingCart
{
    // ... 
    
    public function __invoke(CheckOutShoppingCart $command) : void
    {
        // assignment is redundant for clarity to the reader
        $shoppingCart = $this->shoppingCarts->get($command->shoppingCart);
        
        $payment = $this->paymentGateway->captureCharge($command->charge());
        
        $shoppingCart->checkOut($capturedCharge);
    }
}
~~~
