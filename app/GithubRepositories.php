<?php
// Setup Autoload
$loader = require '.sculpin/autoload.php';
$loader->add('Github\\', 'app/');

use Github\File\Content;
use Github\Info\Repositories;

class GithubRepositories
{
    private $filename;
    private $oldFileContent;

    public function __construct()
    {
        $this->filename = 'output_dev/github/index.html';
        $fileContent = new Content($this->filename);
        $gitHubContent = new Repositories('Ocramius');
    }
}