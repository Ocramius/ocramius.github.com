<?php

use Zend\Escaper\Escaper;

/**
 * Bundles configuration
 */
return [
    'joindin' => [
        'user' => 'ocramius',
        'template' => function($talks) {

            $templatePattern = <<<'HTML'
<div class="item" itemscope itemtype="https://schema.org/Event">
    <meta itemprop="duration" content="%s"/>
    <meta itemprop="startDate" content="%s"/>
    <h3 itemprop="name">%s</h3><p><small itemprop="description">%s</small></p>
    <div class="links">
        <div><i class="icon-calendar"> </i> %s</div>
        <div><i class="icon-star"> </i> %s</div>
        <div><a itemprop="url" href="%s" target="_blank"><i class="icon-eye-open"> </i> See on joind.in</a></div>
        %s
    </div>
</div>
%s
HTML;

            $slidesLinkPattern = <<<'HTML'
        <div itemprop="recordedIn" itemscope itemtype="http://schema.org/CreativeWork">
            <a itemprop="url" href="%s" target="_blank"><i class="icon-film"> </i> Slides</a>
        </div>
HTML;


            $escaper   = new Escaper();
            $template  = '<h1>My talks <small><i>(via joind.in)</i></small></h1><hr />';
            $increment = 0;

            foreach ($talks['talks'] as $talk) {
                $increment++;

                $start = DateTime::createFromFormat(DateTime::ISO8601, $talk['start_date'], new DateTimeZone('UTC'));

                $slides =  (isset($talk['slides_link']) && $talk['slides_link'])
                    ? sprintf(
                        $slidesLinkPattern,
                        $talk['slides_link']
                    )
                    : '';

                $template .= sprintf(
                    $templatePattern,
                    'T' . ((int) $talk['duration']) . 'M',
                    $start->format(DateTime::ISO8601),
                    $escaper->escapeHtml($talk['talk_title']),
                    $escaper->escapeHtml($talk['talk_description']),
                    $start->format('Y-m-d'),
                    (int) $talk['average_rating'],
                    $escaper->escapeHtmlAttr($talk['website_uri']),
                    $slides,
                    (0 == $increment % 2) ? '<div class="clear"></div>' : ' '
                );
            }

            return $template;
        },
    ]
];
