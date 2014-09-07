"use strict";

(function ($) {
    $(function () {
        var TWITTER_API_ENDPOINT = 'https://api.twitter.com/1/statuses/oembed.json';

        $("[data-tweet-id]").each(function () {
            var tweetContainer = $(this);

            $.ajax({
                url: TWITTER_API_ENDPOINT,
                dataType: "jsonp",
                data: {
                    id:     tweetContainer.attr("data-tweet-id"),
                    align: "center",
                    width: "100%",
                    hide_thread: 1,
                    hide_media: 1
                }
            })
                .success(function (data) {
                    var newNode = $(data.html);

                    newNode.attr("width", "100%");

                    tweetContainer.append(newNode);
                });
        });
    });
}(jQuery))
