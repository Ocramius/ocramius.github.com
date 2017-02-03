<?php
require_once __DIR__ . '/bootstrap.php';

$sweetsThief = Closure::bind(function (Kitchen $kitchen) {
    return $kitchen->yummy;
}, null, 'Kitchen');

for ($i = 0; $i < $iterations; $i += 1) {
    $sweets = $sweetsThief($kitchen);
}
