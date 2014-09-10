<?php
/**
 * Template for show repositories on github blog page
 */
$date = new DateTime($repository->updated_at);
return <<<EOF
<div class="span11 github-repository">
    <h3>{$repository->name}</h3>
    <p><small><a href="{$repository->html_url}" target="_blank">
        {$repository->full_name}</a> - last update: {$date->format('Y-m-d')}</small></p>
    <p class="description">{$repository->description}</p>
</div>
EOF;
