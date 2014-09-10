<?php

namespace GithubBundle;

use Sculpin\Core\Event\SourceSetEvent;
use Sculpin\Core\Sculpin;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class GithubRepositoriesGenerator implements EventSubscriberInterface
{
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
     * on header and '{github}' on content.
     *
     * @param SourceSetEvent $sourceSetEvent
     */
    public function beforeRun(SourceSetEvent $sourceSetEvent)
    {
        $repositories = new GithubRepositoriesList('ocramius', '...');
        $sourceSet = $sourceSetEvent->sourceSet();

        foreach ($sourceSet->updatedSources() as $source) {
            if ($source->data()->get('github')
                && 'repositories' == $source->data()->get('github')) {

                $content = preg_replace('/{github}/i', $repositories->asHTML(), $source->content());
                $source->setContent($content);
                $source->setIsGenerated();
            }
        }
    }
}