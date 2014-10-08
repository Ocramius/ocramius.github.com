<?php
namespace GithubBundleTest;

use Github\Api\User;
use Github\Client;
use GithubBundle\GithubRepositoriesGenerator;
use Sculpin\Core\Configuration\Configuration;
use Sculpin\Core\Event\SourceSetEvent;
use Sculpin\Core\Source\SourceInterface;
use Sculpin\Core\Source\SourceSet;

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

    public function testCanGenerateContentCorrectlyOfGithubPage()
    {
        $client = $this->getMock(Client::class);
        $users  = $this->getMockBuilder(User::class)->disableOriginalConstructor()->getMock();

        $client
            ->expects($this->any())
            ->method('api')
            ->willReturn($users);

        $users->expects($this->any())->method('repositories')->will($this->returnValue('REPOSITORIES LIST'));

        $github = new GithubRepositoriesGenerator($this->getConfigForGithubBundle(), $client);

        $source1 = $this->getMock(SourceInterface::class);
        $source2 = $this->getMock(SourceInterface::class);

        $source1->expects($this->any())->method('hasChanged')->will($this->returnValue(true));
        $source2->expects($this->any())->method('hasChanged')->will($this->returnValue(true));

        $source1
            ->expects($this->any())
            ->method('data')
            ->will($this->returnValue(new Configuration(['foo' => 'bar'])));
        $source2
            ->expects($this->any())
            ->method('data')
            ->will($this->returnValue(new Configuration(['github' => 'repositories'])));

        $source1->expects($this->never())->method('setContent');
        $source2->expects($this->once())->method('content')->will($this->returnValue('CONTENTS {GITHUB_TEST}'));
        $source2->expects($this->once())->method('setContent')->with('CONTENTS REPOSITORIES LIST');

        $sourceSetEvent = new SourceSetEvent(new SourceSet([
            $source1,
            $source2,
        ]));

        $github->beforeRun($sourceSetEvent);
    }

    private function getConfigForGithubBundle()
    {
        return [
            'user' => 'foo',
            'replace_on_content' => '{GITHUB_TEST}',
            'render' => function ($data) {
                return $data;
            },
        ];
    }
}
