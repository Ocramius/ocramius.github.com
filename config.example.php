<?php

/**
 * Bundles configuration
 */
return [
    'joindin' => [
        'user' => 'ocramius',
        'template' => function($talks) {

            $templatePattern = '<div itemscope itemtype="http://schema.org/Event">'
                             . '<h3 itemprop="name">%s</h3><p><small>%s</small></p>'
                             . '<a itemprop="url" href="%s" target="_blank">See on joind.in</a>'
                             . '</div>';

            $template = '<h1>My talks <small><i>(joind.in)</i></small></h1><hr />';

            foreach ($talks['talks'] as $talk) {
                $template .= sprintf(
                    $templatePattern,
                    $talk['talk_title'],
                    $talk['talk_description'],
                    $talk['website_uri']
                );
            }

            return $template;
        },
    ]
];
