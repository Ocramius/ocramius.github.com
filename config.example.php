<?php

/**
 * Bundles configuration
 */
return [
    'joindin' => [
        'user' => 'ocramius',
        'template' => function($talks) {

            $templatePattern = <<<'HTML'
<div class="item" itemscope itemtype="http://schema.org/Event">
    <meta itemprop="duration" content="%s"/>
    <meta itemprop="startDate" content="%s"/>
    <h3 itemprop="name">%s</h3><p><small>%s</small></p>
    <div class="links">
        <div><i class="icon-calendar"> </i> %s</div>
        <div><i class="icon-star"> </i> %s</div>
        <div><a itemprop="url" href="%s" target="_blank"><i class="icon-eye-open"> </i> See on joind.in</a></div>
    </div>
</div>
%s
HTML;

            $template  = '<h1>My talks <small><i>(via joind.in)</i></small></h1><hr />';
            $increment = 0;

            foreach ($talks['talks'] as $talk) {
                $increment++;

                $start = DateTime::createFromFormat(DateTime::ISO8601, $talk['start_date'], new DateTimeZone('UTC'));

                $template .= sprintf(
                    $templatePattern,
                    'PT' . ((int) $talk['duration']) . 'M',
                    $start->format(DateTime::ISO8601),
                    $talk['talk_title'],
                    $talk['talk_description'],
                    date('Y-m-d', strtotime($talk['start_date'])),
                    $talk['average_rating'],
                    $talk['website_uri'],
                    (0 == $increment % 2) ? '<div class="clear"></div>' : ' '
                );
            }

            return $template;
        },
    ]
];
