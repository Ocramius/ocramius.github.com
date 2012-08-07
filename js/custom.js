jQuery(document).ready(function () {

    $('#gf').text('GitHub Followers');
    $('#gfr').text('GitHub Repos');

    JSONP('https://api.github.com/users/ocramius?callback=?', function (response) {
        var data = response.data;
        $('#gf').text(data.followers + ' GitHub Followers');
        $('#gfr').text(data.public_repos + ' GitHub Repos');
    });

    function JSONP(url, callback) {
        var id = ( 'jsonp' + Math.random() * new Date() ).replace('.', '');
        var script = document.createElement('script');
        script.src = url.replace('callback=?', 'callback=' + id);
        document.body.appendChild(script);
        window[ id ] = function (data) {
            if (callback) {
                callback(data);
            }
        };
    }

    $('#ghw').githubWidget({
        'username':                   'Ocramius',
        'displayActions':             false,
        'firstCount':                 10,
        'displayHeader':              false,
        'displayLastCommit':          false,
        'displayAccountInformations': false,
        'displayLanguage':            false
    });
});