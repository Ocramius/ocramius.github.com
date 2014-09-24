<?php

namespace GithubBundle;

use Github\Client;
use Sculpin\Core\Sculpin;
use Sculpin\Core\Event\SourceSetEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class GithubRepositoriesGenerator implements EventSubscriberInterface
{
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
        $repositories = $this->client
                             ->api('user')
                            ->repositories($this->config['github']['user']);

        $sourceSet = $sourceSetEvent->sourceSet();

        foreach ($sourceSet->updatedSources() as $source) {
            if ($source->data()->get('github')
                && 'repositories' == $source->data()->get('github')
            ) {

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
}
