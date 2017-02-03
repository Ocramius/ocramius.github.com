<?php

require_once __DIR__.'/bootstrap.php';

$sweetsThief = function ($value) {
    $this->yummy = $value;
};

for ($i = 0; $i < $iterations; $i += 1) {
    $sweetsThief->call($kitchen, 'the cake is a lie');
}
