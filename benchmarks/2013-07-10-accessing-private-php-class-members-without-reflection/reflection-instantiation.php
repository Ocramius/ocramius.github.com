<?php
require_once __DIR__ . '/bootstrap.php';

for ($i = 0; $i < $iterations; $i += 1) {
    $sweetsThief = new ReflectionProperty('Kitchen', 'yummy');

    $sweetsThief->setAccessible(true);
}
