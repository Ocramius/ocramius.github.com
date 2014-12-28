<?php

namespace JoindInBundle;

use GuzzleHttp;
use InvalidArgumentException;

/**
 * Client to get informations about a user
 * previously configurated
 *
 * @author Jefersson Nathan <malukenho@phpse.net>
 */
class Client
{
    /**
     * Url to get informations about a user
     */
    const API_USER_URL = 'http://api.joind.in/v2.1/users?username=%s';

    /**
     * Configuration for the bundle works.
     *
     * @var string[]
     */
    private $config;

    /**
     * @var GuzzleHttp\Client
     */
    private $client;

    /**
     * Construct.
     *
     * @throws InvalidArgumentException
     */
    public function __construct(array $config)
    {
        if (! $this->validateConfig($config)) {
            throw new InvalidArgumentException('The config bundle has not all mandatory config keys.');
        }

        $this->config = $config;
        $this->client = new GuzzleHttp\Client();
    }

    /**
     * @return string[][]
     */
    public function getUserInfo()
    {
        $response = $this->client->get(sprintf(self::API_USER_URL, $this->config['user']));

        return $response->json();
    }

    /**
     * @return string[][]
     */
    public function getTalks()
    {
        $userInfo = $this->getUserInfo();
        $talkUri  = $userInfo['users'][0]['talks_uri'];

        $reponse  = $this->client->get(sprintf($talkUri, $this->config['user']));

        return $reponse->json();
    }

    /**
     * @return boolean
     */
    private function validateConfig(array $config)
    {
        $mandatoryConfig = ['user'];
        return !array_diff($mandatoryConfig, array_keys($config));
    }
}
