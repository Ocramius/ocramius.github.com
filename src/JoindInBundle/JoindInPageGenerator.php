<?php

namespace JoindInBundle;

use Closure;
use Sculpin\Core\Sculpin;
use Sculpin\Core\Event\SourceSetEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class JoindInPageGenerator implements EventSubscriberInterface
{

    const JOINDIN_TALKS = 'talks';
    const JOINDIN_KEY   = 'joindin';

    /**
     * @var Client
     */
    private $client;

    /**
     * Function to render informations from talks
     *
     * @var Closure
     */
    private $template;

    /**
     * Constructor.
     */
    public function __construct(Client $client, Closure $template)
    {
        $this->client   = $client;
        $this->template = $template;
    }

    /**
     * {@inheritDoc}
     */
    public static function getSubscribedEvents()
    {
        return [Sculpin::EVENT_BEFORE_RUN => 'beforeRun'];
    }

    /**
     * Generate the page.
     *
     * @param SourceSetEvent $sourceSetEvent
     */
    public function beforeRun(SourceSetEvent $sourceSetEvent)
    {
        /* @var $source \Sculpin\Core\Source\SourceInterface */
        foreach ($sourceSetEvent->sourceSet()->updatedSources() as $source) {
            if (static::JOINDIN_TALKS === $source->data()->get(static::JOINDIN_KEY)) {
                $talks = $this->client->getTalks();
                $template = $this->template;

                $source->setContent($template($talks));
                $source->setIsGenerated();
            }
        }
    }
}
