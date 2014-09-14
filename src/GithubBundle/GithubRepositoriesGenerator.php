<?php

namespace GithubBundle;

use Sculpin\Core\Sculpin;
use Github\HttpClient\HttpClient;
use Github\Client as GithubClient;
use Sculpin\Core\Event\SourceSetEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class GithubRepositoriesGenerator implements EventSubscriberInterface
{
    /**
     * @var array
     */
    private $config = [];

    /**
     * Constructor.
     *
     * @param array $config
     */
    public function __construct(array $config)
    {
        $this->config = $config;
    }

    /**
     * {@inheritDoc}
     */
    public static function getSubscribedEvents()
    {
        return [
            Sculpin::EVENT_BEFORE_RUN => 'beforeRun',
        ];
    }

    /**
     * Generate and replace content of pages with (github: repositories)
     * on header and '{replace_on_content}' on content.
     *
     * @param SourceSetEvent $sourceSetEvent
     */
    public function beforeRun(SourceSetEvent $sourceSetEvent)
    {
        $client = $this->createClientObject($this->config);

        $repositories = $client->api('user')->repositories($this->config['github']['user']);
        $sourceSet = $sourceSetEvent->sourceSet();

        foreach ($sourceSet->updatedSources() as $source) {
            if ($source->data()->get('github')
                && 'repositories' == $source->data()->get('github')) {

                $content = str_ireplace(
                    $this->config['github']['replace_on_content'],
                    $this->config['github']['render']($repositories),
                    $source->content()
                );

                $source->setContent($content);
                $source->setIsGenerated();
            }
        }
    }

    /**
     * Create a github object configures with information
     * stored on config.php
     *
     * @param $config
     *
     * @return GithubClient
     */
    private function createClientObject(array $config)
    {

        $client = new GithubClient(new HttpClient(array(
            'token' => $config['github']['token'],
            'timeout' => 60,
            'auth_method' => GithubClient::AUTH_URL_TOKEN
        )));

        $client->setHeaders(array(
            'User-Agent: ' . $config['github']['user_agent']
        ));

        return $client;
    }
}
