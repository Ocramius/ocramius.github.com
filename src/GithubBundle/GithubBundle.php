<?php

namespace GithubBundle;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Definition;
use Symfony\Component\HttpKernel\Bundle\Bundle;

class GithubBundle extends Bundle
{
    public function build(ContainerBuilder $containerBuilder)
    {
        $githubRepositoriesDefinition = new Definition(
            GithubRepositoriesGenerator::class,
            []
        );

        $config = require dirname(dirname(__DIR__)) . '/config.php';

        $githubRepositoriesDefinition->addTag('kernel.event_subscriber');
        $githubRepositoriesDefinition->addArgument($config);

        $containerBuilder->addDefinitions([$githubRepositoriesDefinition]);
    }
}
