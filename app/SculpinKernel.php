<?php

use JoindInBundle\JoindInBundle;
use Sculpin\Bundle\SculpinBundle\HttpKernel\AbstractKernel;

class SculpinKernel extends AbstractKernel
{
    public function getAdditionalSculpinBundles()
    {
        return [
            JoindInBundle::class,
        ];
    }
}
