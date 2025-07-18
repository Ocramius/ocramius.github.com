<?php

use JoindInBundle\JoindInBundle;
use Sculpin\Bundle\SculpinBundle\HttpKernel\AbstractKernel;

final class SculpinKernel extends AbstractKernel
{
    public function getAdditionalSculpinBundles(): array
    {
        return [
            JoindInBundle::class,
        ];
    }
}
