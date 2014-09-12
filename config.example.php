<?php
return [
  'github' => [
      'user' => 'User Name',
      'token' => 'Token Key',
      'user_agent' => 'Custom User Agent',
      'replace_on_content' => '{GITHUB_REPOSITORIES}',
      'render' => function($repositories) {
              $content = [];
              foreach ($repositories as $repository) {

                  $date = new DateTime($repository['updated_at']);
                  $content[] = <<<EOF
<div class="span11 github-repository">
    <h3>{$repository['name']}</h3>
    <p><small><a href="{$repository['html_url']}" target="_blank">
        {$repository['full_name']}</a> - last update: {$date->format('Y-m-d')}</small></p>
    <p class="description">{$repository['description']}</p>
</div>
EOF;
              }
              return implode(' ', $content);
      }
  ]
];
