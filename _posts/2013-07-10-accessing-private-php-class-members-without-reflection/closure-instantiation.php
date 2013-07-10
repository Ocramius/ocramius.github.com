<?php
require_once __DIR__ . '/bootstrap.php';

for ($i = 0; $i < $iterations; $i += 1) {
    $sweetsThief = Closure::bind(function (Kitchen $kitchen) {
        return $kitchen->yummy;
    }, null, 'Kitchen');
}