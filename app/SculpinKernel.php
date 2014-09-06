<?php

use GithubBundle\GithubBundle;

class SculpinKernel extends \Sculpin\Bundle\SculpinBundle\HttpKernel\AbstractKernel
{
    protected function getAdditionalSculpinBundles()
    {
        return [
            GithubBundle::class,
        ];
    }
}