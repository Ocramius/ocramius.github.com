<?php

namespace GithubBundle;

use Github\Client;
use Sculpin\Core\Sculpin;
use Sculpin\Core\Event\SourceSetEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class GithubRepositoriesGenerator implements EventSubscriberInterface
{
    const SOURCE_GITHUB_KEY          = 'github';
    const SOURCE_GITHUB_REPOSITORIES = 'repositories';

    /**
     * @var array[]
     */
    private $config = [];

    /**
     * @var Client
     */
    private $client;

    /**
     * Constructor.
     *
     * @param array[]  $config
     * @param Client   $client
     */
    public function __construct(array $config, Client $client)
    {
        $this->config = $config;
        $this->client = $client;
    }

    /**
     * {@inheritDoc}
     */
    public static function getSubscribedEvents()
    {
        return [Sculpin::EVENT_BEFORE_RUN => 'beforeRun'];
    }

    /**
     * Generate and replace content of pages with (github: repositories)
     * on header and '{replace_on_content}' on content.
     *
     * @param SourceSetEvent $sourceSetEvent
     */
    public function beforeRun(SourceSetEvent $sourceSetEvent)
    {
        $repositories = $this
            ->client
            ->api('user')
            ->repositories($this->config['user']);

        /* @var $source \Sculpin\Core\Source\SourceInterface */
        foreach ($sourceSetEvent->sourceSet()->updatedSources() as $source) {
            if (static::SOURCE_GITHUB_REPOSITORIES === $source->data()->get(static::SOURCE_GITHUB_KEY)) {
                $source->setContent(str_ireplace(
                    $this->config['replace_on_content'],
                    $this->config['render']($repositories),
                    $source->content()
                ));

                $source->setIsGenerated();
            }
        }
    }
}
