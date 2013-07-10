<?php
require_once __DIR__ . '/bootstrap.php';

$sweetsThief = Closure::bind(function (Kitchen $kitchen, $value) {
    return $kitchen->yummy = $value;
}, null, 'Kitchen');

for ($i = 0; $i < $iterations; $i += 1) {
    $sweetsThief($kitchen, 'the cake is a lie');
}