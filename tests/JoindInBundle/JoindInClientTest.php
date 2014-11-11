<?php

namespace JoindInBundle;

use PHPUnit_Framework_TestCase;

class JoindInClientTest extends PHPUnit_Framework_TestCase
{
    /**
     * @expectedException InvalidArgumentException
     */
    public function testThrowsAnExceptionIfGivenAInvalidConfigData()
    {
        new Client([]);
    }

    public function testCanGetDataOfAUser()
    {
        $client = new Client(['user' => 'ocramius']);
        $userInfo = $client->getUserInfo();

        $this->assertTrue(isset($userInfo['users'][0]));
        $this->assertEquals('ocramius', $userInfo['users'][0]['username']);
    }
}
