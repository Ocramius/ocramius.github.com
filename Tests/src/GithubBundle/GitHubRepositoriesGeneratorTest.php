<?php
namespace GithubBundle;

class GitHubRepositoriesGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function testIfClassCanBeInstantiated()
    {
        $github = new GithubRepositoriesGenerator([]);
        $this->assertInstanceOf(
            __NAMESPACE__ . '\\GitHubRepositoriesGenerator',
            $github
        );
    }

    public function testCanCreateAInstanceOfGithubClient()
    {
        $github = new GithubRepositoriesGenerator([]);
        $class = new \ReflectionClass(__NAMESPACE__ . '\\GitHubRepositoriesGenerator');
        $method = $class->getMethod('createClientObject');
        $method->setAccessible(true);
        $output = $method->invoke($github, array());

        $this->assertInstanceOf('Github\Client', $output);
    }
}
