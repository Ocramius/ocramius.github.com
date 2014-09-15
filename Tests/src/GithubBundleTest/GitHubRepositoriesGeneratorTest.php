<?php
namespace GithubBundleTest;

use GithubBundle\GithubRepositoriesGenerator;

class GitHubRepositoriesGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testIfClassCanBeInstantiated()
    {
        $github = new GithubRepositoriesGenerator([]);
        $this->assertInstanceOf(
            GitHubRepositoriesGenerator::class,
            $github
        );
    }

    public function testCanCreateAInstanceOfGithubClient()
    {
        $github = new GithubRepositoriesGenerator([]);
        $class = new \ReflectionClass(GitHubRepositoriesGenerator::class);
        $method = $class->getMethod('createClientObject');
        $method->setAccessible(true);
        $output = $method->invoke($github, array());

        $this->assertInstanceOf(\Github\Client::class, $output);
    }
}
