<?php
namespace GithubBundleTest;

use Github\Client;
use GithubBundle\GithubRepositoriesGenerator;

class GitHubRepositoriesGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testIfClassCanBeInstantiated()
    {
        $github = new GithubRepositoriesGenerator([], new Client);
        $this->assertInstanceOf(
            GitHubRepositoriesGenerator::class,
            $github
        );
    }
}
