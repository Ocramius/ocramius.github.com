<?php

namespace JoindInBundle;

use PHPUnit\Framework\TestCase;
use GuzzleHttp\Client as HttpClient;

/** @covers \JoindInBundle\Client */
class ClientTest extends TestCase
{
    public function testThrowsAnExceptionIfGivenAInvalidConfigData()
    {
        $this->setExpectedException('InvalidArgumentException');

        $httpClient = new HttpClient();
        new Client([], $httpClient);
    }

    public function testCanGetDataOfAUser()
    {
        $httpClient = new HttpClient();
        $client = new Client(['user' => 'ocramius'], $httpClient);

        $userInfo = $client->getUserInfo();

        $this->assertTrue(isset($userInfo['users'][0]));
        $this->assertEquals('ocramius', $userInfo['users'][0]['username']);
    }

    public function testCanGetTalksFromUser()
    {
        $httpClient = new HttpClient();
        $client = new Client(['user' => 'ocramius'], $httpClient);

        $userInfo = $client->getTalks();

        $this->assertTrue(isset($userInfo['talks']));
    }
}
