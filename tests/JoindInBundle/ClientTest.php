<?php

namespace JoindInBundle;

use PHPUnit_Framework_TestCase;
use GuzzleHttp\Client as HttpClient;

class ClientTest extends PHPUnit_Framework_TestCase
{
    public function testThrowsAnExceptionIfGivenAInvalidConfigData()
    {
        $this->setExpectedException('InvalidArgumentException');
        new Client([]);
    }

    /**
     * @covers JoindInBundle\Client::getUserInfo
     */
    public function testCanGetDataOfAUser()
    {
        $httpClient = new HttpClient();
        $client = new Client(['user' => 'ocramius'], $httpClient);

        $userInfo = $client->getUserInfo();

        $this->assertTrue(isset($userInfo['users'][0]));
        $this->assertEquals('ocramius', $userInfo['users'][0]['username']);
    }

    /**
     * @covers JoindInBundle\Client::getTalks
     */
    public function testCanGetTalksFromUser()
    {
        $httpClient = new HttpClient();
        $client = new Client(['user' => 'ocramius'], $httpClient);

        $userInfo = $client->getTalks();

        $this->assertTrue(isset($userInfo['talks']));
    }
}
