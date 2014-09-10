<?php

namespace GithubBundle;


class GithubRepositoriesList
{
    const API_URL = 'https://api.github.com/users/%s/repos?access_token=%s&sort=updated';

    /**
     * @var string
     */
    private $user;

    /**
     * @var string
     */
    private $token;

    /**
     * @var string|null
     */
    private $result = null;

    /**
     * Constructor
     *
     * @param $user
     * @param $token
     */
    public function __construct($user, $token)
    {
        $this->user = $user;
        $this->token = $token;
    }

    /**
     * Get result lazy initialization
     *
     * @return string
     */
    private function getResult()
    {
        if (! $this->result) {
            $githubApi = sprintf(self::API_URL, $this->user, $this->token);
            $this->result = `curl -sS $githubApi`;
        }
        return $this->result;
    }

    /**
     * @return array
     */
    public function asArray()
    {
        return json_decode($this->getResult());
    }

    /**
     * Create a list of repositories tag formatted as html
     *
     * @return string
     */
    public function asHTML()
    {
        $html = '';
        $repositories = $this->asArray();

        foreach ($repositories as $repository) {
            $html .= require __DIR__ . "/Template/Repositories.php";
        }

        return $html;
    }
}
