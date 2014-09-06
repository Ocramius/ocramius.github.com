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

        $githubRepositoriesDefinition->addTag('kernel.event_subscriber');

        $containerBuilder->addDefinitions([$githubRepositoriesDefinition]);
    }
}
