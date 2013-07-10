<?php
require_once __DIR__ . '/bootstrap.php';

$sweetsThief = new ReflectionProperty('Kitchen', 'yummy');

$sweetsThief->setAccessible(true);

for ($i = 0; $i < $iterations; $i += 1) {
    $sweets = $sweetsThief->setValue($kitchen, 'the cake is a lie');
}