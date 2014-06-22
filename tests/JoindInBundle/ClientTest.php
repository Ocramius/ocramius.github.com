<?php

namespace JoindInBundle;

use PHPUnit_Framework_TestCase;

class ClientTest extends PHPUnit_Framework_TestCase
{
    public function testThrowsAnExceptionIfGivenAInvalidConfigData()
    {
        $this->setExpectedException('InvalidArgumentException');
        new Client([]);
    }

    public function testCanGetDataOfAUser()
    {
        $client = new Client(['user' => 'ocramius']);
        $userInfo = $client->getUserInfo();

        $this->assertTrue(isset($userInfo['users'][0]));
        $this->assertEquals('ocramius', $userInfo['users'][0]['username']);
    }

    public function testCanGetTalksFromUser()
    {
        $client = new Client(['user' => 'ocramius']);
        $userInfo = $client->getTalks();

        $this->assertTrue(isset($userInfo['talks']));
    }
}
