<?php

namespace JoindInBundle;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Definition;
use Symfony\Component\DependencyInjection\Reference;
use Symfony\Component\HttpKernel\Bundle\Bundle;
use GuzzleHttp\Client as HttpClient;

class JoindInBundle extends Bundle
{
    public function build(ContainerBuilder $containerBuilder)
    {
        $config = require __DIR__ . '/../../config.php';

        $joindInClientDefinition = new Definition(
            Client::class,
            [
                $config['joindin'],
                new  HttpClient()
            ]
        );

        $joindInPageGeneratorDefinition = new Definition(
            JoindInPageGenerator::class,
            [
                new Reference(Client::class),
                $config['joindin']['template']
            ]
        );

        $joindInPageGeneratorDefinition->addTag('kernel.event_subscriber');

        $containerBuilder->setDefinition(Client::class, $joindInClientDefinition);
        $containerBuilder->setDefinition(JoindInPageGenerator::class, $joindInPageGeneratorDefinition);
    }
}
