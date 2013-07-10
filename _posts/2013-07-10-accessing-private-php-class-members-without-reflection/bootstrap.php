<?php

$iterations = isset($argv[1]) ? (int) $argv[1] : 100000;
$start      = 0;

// this is just to avoid including something like a "footer" in all these simple scripts
register_shutdown_function(function () use (& $start, $iterations) {
    echo $_SERVER['SCRIPT_NAME'] . ' - ' . $iterations . ' iterations - '
        . number_format(microtime(true) - $start, 5) . ' sec' . PHP_EOL;
});

// dummy class used for tests
class Kitchen
{
    private $yummy = 'cake';
}

$start = microtime(true);