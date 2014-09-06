<?php
namespace Github\File;

use Symfony\Component\Filesystem;

class Content
{
    private $content;

    public function __construct($file)
    {
        $fs = new Filesystem\Filesystem();
        if ($fs->exists($file)) {
            $this->content = file_get_contents($file);
        }
    }

    public function getContent()
    {
        return $this->content;
    }
} 