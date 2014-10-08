<?php

namespace GithubBundle;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Definition;
use Symfony\Component\DependencyInjection\Reference;
use Symfony\Component\HttpKernel\Bundle\Bundle;
use Github\HttpClient\HttpClient;
use Github\Client as GithubClient;

class GithubBundle extends Bundle
{
    public function build(ContainerBuilder $containerBuilder)
    {
        $config = require __DIR__ . '/../../config.php';

        $httpClientDefinition = new Definition(
            HttpClient::class,
            [
                [
                    'token'       => $config['github']['token'],
                    'timeout'     => 60,
                    'auth_method' => GithubClient::AUTH_URL_TOKEN
                ],
            ]
        );
        $githubClientDefinition       = new Definition(GithubClient::class, [new Reference(HttpClient::class)]);
        $githubRepositoriesDefinition = new Definition(
            GithubRepositoriesGenerator::class,
            [
                $config['github'],
                new Reference(GithubClient::class),
            ]
        );

        $githubClientDefinition->addMethodCall('setHeaders', [['User-Agent: ' . $config['github']['user_agent']]]);
        $githubRepositoriesDefinition->addTag('kernel.event_subscriber');

        $containerBuilder->setDefinition(HttpClient::class, $httpClientDefinition);
        $containerBuilder->setDefinition(GithubClient::class, $githubClientDefinition);
        $containerBuilder->setDefinition(GithubRepositoriesGenerator::class, $githubRepositoriesDefinition);
    }
}
