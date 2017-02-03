<?php

require_once __DIR__.'/bootstrap.php';

$sweetsThief = function () {
    return $this->yummy;
};
for ($i = 0; $i < $iterations; $i += 1) {
    $sweets = $sweetsThief->call($kitchen);
}
