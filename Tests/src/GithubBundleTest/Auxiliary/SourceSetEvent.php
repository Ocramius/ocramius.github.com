<?php

namespace GithubBundleTest\Auxiliary;

/**
 * Class SourceSetEvent
 *
 * Auxiliary class used for test
 *
 * @package GithubBundleTest
 */
class SourceSetEvent
{
    /**
     * @var string
     */
    private $content;

    public function data()
    {
        return $this;
    }

    public function api()
    {
        return $this;
    }

    public function repositories()
    {
        return 'Repository data';
    }

    public function get($page)
    {
        if ('github' == $page) {
            return 'repositories';
        }
        return false;
    }

    public function content()
    {
        return 'Heya! {GITHUB_TEST}';
    }

    public function updatedSources()
    {
        return [new self];
    }

    public function setContent($content)
    {
        $this->content = $content;
    }

    public function getContent()
    {
        return $this->content;
    }
}
