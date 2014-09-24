<?php
namespace GithubBundleTest;

use Github\Client;
use Sculpin\Core\Event\SourceSetEvent;
use GithubBundle\GithubRepositoriesGenerator;

class GitHubRepositoriesGeneratorTest extends \PHPUnit_Framework_TestCase
{
    public function getConfigForGithubBundle()
    {
        return [
            'github' => [
                'user' => 'foo',
                'replace_on_content' => '{GITHUB_TEST}',
                'render' => function ($data) {
                    return $data;
                }
            ]
        ];
    }

    public function testIfClassCanBeInstantiated()
    {
        $github = new GithubRepositoriesGenerator([], new Client);
        $this->assertInstanceOf(
            GitHubRepositoriesGenerator::class,
            $github
        );
    }

    public function testCanGenerateContentCorrectlyOfGithubPage()
    {
        $auxiliary = $this->getMock(Auxiliary\SourceSetEvent::class);
        $client = $this->getMock(Client::class)
            ->expects($this->any())
            ->method('api')
            ->willReturn($auxiliary);

        $sourceSetEvent = $this->getMockBuilder(SourceSetEvent::class)
            ->disableOriginalConstructor()
            ->getMock();

        $sourceSetEvent->method('sourceSet')
            ->willReturn($auxiliary);

        $github = new GithubRepositoriesGenerator($this->getConfigForGithubBunble(), $client);
        $github->beforeRun($sourceSetEvent);
        $this->assertEquals('Heya! Repository data', $auxiliary->getContent());
    }
}
