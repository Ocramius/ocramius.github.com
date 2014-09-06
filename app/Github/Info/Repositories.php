<?php
namespace Github\Info;

class Repositories
{
    const API_URL = 'https://api.github.com/users/[user_name]/repos';

    private $content;

    public function __construct($user)
    {
        $api = str_replace('[user_name]', $user, self::API_URL);
        $this->content = file_get_contents($api);
    }

    public function asArray()
    {
        return json_decode($this->content);
    }
} 