<?php

namespace GithubBundle;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Definition;
use Symfony\Component\HttpKernel\Bundle\Bundle;
use Github\HttpClient\HttpClient;
use Github\Client as GithubClient;

class GithubBundle extends Bundle
{
    public function build(ContainerBuilder $containerBuilder)
    {
        $githubRepositoriesDefinition = new Definition(
            GithubRepositoriesGenerator::class,
            []
        );

        $config = require dirname(dirname(__DIR__)) . '/config.php';

        $client = new GithubClient(new HttpClient(array(
            'token' => $config['github']['token'],
            'timeout' => 60,
            'auth_method' => GithubClient::AUTH_URL_TOKEN
        )));

        $client->setHeaders(array(
            'User-Agent: ' . $config['github']['user_agent']
        ));

        $githubRepositoriesDefinition->addTag('kernel.event_subscriber');
        $githubRepositoriesDefinition->addArgument($config);
        $githubRepositoriesDefinition->addArgument($client);

        $containerBuilder->addDefinitions([$githubRepositoriesDefinition]);
    }
}
