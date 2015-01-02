<?php

namespace JoindInBundle;

use InvalidArgumentException;
use GuzzleHttp\ClientInterface;

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
    public function __construct(array $config, ClientInterface $httpClient)
    {
        if (! $this->validateConfig($config)) {
            throw new InvalidArgumentException('The config bundle has not all mandatory config keys.');
        }

        $this->config = $config;
        $this->client = $httpClient;
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
        $userInfo   = $this->getUserInfo();
        $talks      = $userInfo['users'][0]['talks_uri'];
        $parsedUri  = parse_url($talks);

        parse_str(isset($parsedUri['query']) ? $parsedUri['query'] : '', $queryParams);

        $queryParams['verbose'] = 'yes';

        $talksUri = $parsedUri['scheme']
            . '://'
            . $parsedUri['host']
            . $parsedUri['path']
            . '?'
            . http_build_query($queryParams);

        return $this->client->get($talksUri)->json();
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
