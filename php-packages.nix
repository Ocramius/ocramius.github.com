{composerEnv, fetchurl, fetchgit ? null, fetchhg ? null, fetchsvn ? null, noDev ? false}:

let
  packages = {
    "components/bootstrap" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-bootstrap-fca56bda4c5c40cb2a163a143e8e4271a6721492";
        src = fetchurl {
          url = "https://api.github.com/repos/components/bootstrap/zipball/fca56bda4c5c40cb2a163a143e8e4271a6721492";
          sha256 = "138fz0xp2z9ysgxfsnl7qqgh8qfnhv2bhvacmngnjqpkssz7jagx";
        };
      };
    };
    "components/highlightjs" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-highlightjs-60f5b260c3ae12578f7241e15e8102e9b65c4d3b";
        src = fetchurl {
          url = "https://api.github.com/repos/components/highlightjs/zipball/60f5b260c3ae12578f7241e15e8102e9b65c4d3b";
          sha256 = "00bbmhkpk82axd0xdmc4ndphfpvh2zcb9ymmc7j6vzlwgvx13xx2";
        };
      };
    };
    "components/jquery" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "components-jquery-8edc7785239bb8c2ad2b83302b856a1d61de60e7";
        src = fetchurl {
          url = "https://api.github.com/repos/components/jquery/zipball/8edc7785239bb8c2ad2b83302b856a1d61de60e7";
          sha256 = "0q9vrhsb1zqy45xhsdngcc83gkyb2jvazz9fcgb4ygs1vpy69wpd";
        };
      };
    };
    "dflydev/ant-path-matcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-ant-path-matcher-c8406d2d85a844b0dbb4ee76d9db9def7ca67518";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-util-antPathMatcher/zipball/c8406d2d85a844b0dbb4ee76d9db9def7ca67518";
          sha256 = "01858fvizpx8jz0q8k4c2s2dgmvf7yc1vzdp4i8bp7jdgsm219ik";
        };
      };
    };
    "dflydev/apache-mime-types" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-apache-mime-types-f30a57e59b7476e4c5270b6a0727d79c9c0eb861";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-apache-mime-types/zipball/f30a57e59b7476e4c5270b6a0727d79c9c0eb861";
          sha256 = "1zskf42xcnz2gf5lwzc1x0gnrgcrviqijs73kwvl4fg0nbr3453l";
        };
      };
    };
    "dflydev/canal" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-canal-668af213d86f0f378f5dcce6799b974044fa6a51";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-canal/zipball/668af213d86f0f378f5dcce6799b974044fa6a51";
          sha256 = "11r3idyswyah1vx1k8i8w67avd9mpkm4d9w00x9hcgqjrkwlrfnm";
        };
      };
    };
    "dflydev/dot-access-configuration" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-dot-access-configuration-2e6eb0c8b8830b26bb23defcfc38d4276508fc49";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-dot-access-configuration/zipball/2e6eb0c8b8830b26bb23defcfc38d4276508fc49";
          sha256 = "0bmx3p45i7i4wadlj2dixb4x6p7xy41am43hshihlcnnsyv6d89r";
        };
      };
    };
    "dflydev/dot-access-data" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-dot-access-data-3fbd874921ab2c041e899d044585a2ab9795df8a";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-dot-access-data/zipball/3fbd874921ab2c041e899d044585a2ab9795df8a";
          sha256 = "0n9jb8chx4k0aigapi9rvxwfqrg18x5dqgwnrnigq8243bsjg6nc";
        };
      };
    };
    "dflydev/placeholder-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-placeholder-resolver-d0161b4be1e15838327b01b21d0149f382d69906";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-placeholder-resolver/zipball/d0161b4be1e15838327b01b21d0149f382d69906";
          sha256 = "0lrqddmvdhrq5amx7fs79yqb3bmklkj0wdvlhalgvnzdcgxdr11p";
        };
      };
    };
    "doctrine/inflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-inflector-4bd5c1cdfcd00e9e2d8c484f79150f67e5d355d9";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/inflector/zipball/4bd5c1cdfcd00e9e2d8c484f79150f67e5d355d9";
          sha256 = "0390gkbk3vdjd98h7wjpdv0579swbavrdb6yrlslfdr068g4bmbf";
        };
      };
    };
    "evenement/evenement" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "evenement-evenement-0a16b0d71ab13284339abb99d9d2bd813640efbc";
        src = fetchurl {
          url = "https://api.github.com/repos/igorw/evenement/zipball/0a16b0d71ab13284339abb99d9d2bd813640efbc";
          sha256 = "1gbm1nha3h8hhqlqxdrgmrwh35xld0by1si7qg2944g5wggfxpad";
        };
      };
    };
    "fig/http-message-util" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fig-http-message-util-9d94dc0154230ac39e5bf89398b324a86f63f765";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-message-util/zipball/9d94dc0154230ac39e5bf89398b324a86f63f765";
          sha256 = "1cbhchmvh8alqdaf31rmwldyrpi5cgmzgair1gnjv6nxn99m3pqf";
        };
      };
    };
    "guzzlehttp/guzzle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-guzzle-b87eda7a7162f95574032da17e9323c9899cb6b2";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/guzzle/zipball/b87eda7a7162f95574032da17e9323c9899cb6b2";
          sha256 = "1fxm3rhan2mbng6zvsqhkx2yg8kk306d3yrfgnqwldlxy1ksvclb";
        };
      };
    };
    "guzzlehttp/ringphp" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-ringphp-5e2a174052995663dd68e6b5ad838afd47dd615b";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/RingPHP/zipball/5e2a174052995663dd68e6b5ad838afd47dd615b";
          sha256 = "09n1znwxawmsidyq6zk94mg85hibsg8kxm1j0bi795pa55fiqzj9";
        };
      };
    };
    "guzzlehttp/streams" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-streams-47aaa48e27dae43d39fc1cea0ccf0d84ac1a2ba5";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/streams/zipball/47aaa48e27dae43d39fc1cea0ccf0d84ac1a2ba5";
          sha256 = "1ax2b61l31vsx5814iak7l35rmh9yk0rbps5gndrkwlf27ciq9jy";
        };
      };
    };
    "kriswallsmith/assetic" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "kriswallsmith-assetic-e911c437dbdf006a8f62c2f59b15b2d69a5e0aa1";
        src = fetchurl {
          url = "https://api.github.com/repos/kriswallsmith/assetic/zipball/e911c437dbdf006a8f62c2f59b15b2d69a5e0aa1";
          sha256 = "1dqk4zvx8fgqf8rb81sj9bipl5431jib2b9kcvxyig5fw99irpf8";
        };
      };
    };
    "michelf/php-markdown" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "michelf-php-markdown-5024d623c1a057dcd2d076d25b7d270a1d0d55f3";
        src = fetchurl {
          url = "https://api.github.com/repos/michelf/php-markdown/zipball/5024d623c1a057dcd2d076d25b7d270a1d0d55f3";
          sha256 = "1zhaiqfzvcf36vq2wvqx0gyyj4d1rs9i8vxn8191cyxhkxap3zfw";
        };
      };
    };
    "netcarver/textile" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "netcarver-textile-02ed0cbe6832c2100342dabb6d01d7ba558cb8e7";
        src = fetchurl {
          url = "https://api.github.com/repos/textile/php-textile/zipball/02ed0cbe6832c2100342dabb6d01d7ba558cb8e7";
          sha256 = "1qnfcxv7k2wc3ksirxj6x9n26nhxv1vkpfmw4bk80pv9znnm9vmf";
        };
      };
    };
    "psr/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-container-513e0666f7216c7459170d56df27dfcefe1689ea";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/container/zipball/513e0666f7216c7459170d56df27dfcefe1689ea";
          sha256 = "00yvj3b5ls2l1d0sk38g065raw837rw65dx1sicggjnkr85vmfzz";
        };
      };
    };
    "psr/http-message" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-message-cb6ce4845ce34a8ad9e68117c10ee90a29919eba";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-message/zipball/cb6ce4845ce34a8ad9e68117c10ee90a29919eba";
          sha256 = "1s87sajxsxl30ciqyhx0vir2pai63va4ssbnq7ki6s050i4vm80h";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-ef29f6d262798707a9edd554e2b82517ef3a9376";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/log/zipball/ef29f6d262798707a9edd554e2b82517ef3a9376";
          sha256 = "02z3lixbb248li6y060afd2mdz6w5chfwxgsnwkff89205xafzg1";
        };
      };
    };
    "react/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-cache-d47c472b64aa5608225f47965a484b75c7817d5b";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/cache/zipball/d47c472b64aa5608225f47965a484b75c7817d5b";
          sha256 = "0qz43ah5jrbixbzndzx70vyfg5mxg0qsha0bhc136jrrgp9sk4sp";
        };
      };
    };
    "react/dns" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-dns-eb8ae001b5a455665c89c1df97f6fb682f8fb0f5";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/dns/zipball/eb8ae001b5a455665c89c1df97f6fb682f8fb0f5";
          sha256 = "1l3w8wmdhwg08i6ps9wrwavs12f0gw3cap66n7h5qbr8cgz319lr";
        };
      };
    };
    "react/event-loop" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-event-loop-bbe0bd8c51ffc05ee43f1729087ed3bdf7d53354";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/event-loop/zipball/bbe0bd8c51ffc05ee43f1729087ed3bdf7d53354";
          sha256 = "0g2l68nsmf80wdam602xp1m8w2dvl9qm5rzdvssgn8hq9fil60iv";
        };
      };
    };
    "react/http" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-http-8db02de41dcca82037367f67a2d4be365b1c4db9";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/http/zipball/8db02de41dcca82037367f67a2d4be365b1c4db9";
          sha256 = "1glwyv9db5px7zwmrz2mlw5iairbw3phliackvmkxswybnf0k8sn";
        };
      };
    };
    "react/promise" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-promise-1a8460931ea36dc5c76838fec5734d55c88c6831";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/promise/zipball/1a8460931ea36dc5c76838fec5734d55c88c6831";
          sha256 = "0vv5xjadcz6pk7vynvsw8r6x7w7jk7n94mrncw4ilwllys6yiaw1";
        };
      };
    };
    "react/socket" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-socket-23e4ff33ea3e160d2d1f59a0e6050e4b0fb0eac1";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/socket/zipball/23e4ff33ea3e160d2d1f59a0e6050e4b0fb0eac1";
          sha256 = "0fm580hgr86mya8rnr8h24az08m6yrg7vw51rs84r09w2l6gdxdm";
        };
      };
    };
    "react/stream" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "react-stream-1e5b0acb8fe55143b5b426817155190eb6f5b18d";
        src = fetchurl {
          url = "https://api.github.com/repos/reactphp/stream/zipball/1e5b0acb8fe55143b5b426817155190eb6f5b18d";
          sha256 = "0gq8h3028hgvihnapchqskl8b9lhkag2mj7yxr7n7i3cwwl7la9l";
        };
      };
    };
    "robloach/component-installer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "robloach-component-installer-1864f25db21fc173e02a359f646acd596c1b0460";
        src = fetchurl {
          url = "https://api.github.com/repos/RobLoach/component-installer/zipball/1864f25db21fc173e02a359f646acd596c1b0460";
          sha256 = "02sn9k5qpzj303lg3szk3wyj5nfiqijimgm2k135vxgcs4bj8g7l";
        };
      };
    };
    "sculpin/sculpin" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sculpin-sculpin-5f705d845b2dc980ed91b79c49ccaa5f64cbdda0";
        src = fetchurl {
          url = "https://api.github.com/repos/sculpin/sculpin/zipball/5f705d845b2dc980ed91b79c49ccaa5f64cbdda0";
          sha256 = "0chpgrarsn6fxr12xvdrb07mv6s4660p61ip8ascynhyh4mmy91d";
        };
      };
    };
    "sculpin/sculpin-theme-composer-plugin" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sculpin-sculpin-theme-composer-plugin-e3f4e1d6a10368709d07933f8391ef7e534c5db4";
        src = fetchurl {
          url = "https://api.github.com/repos/sculpin/sculpin-theme-composer-plugin/zipball/e3f4e1d6a10368709d07933f8391ef7e534c5db4";
          sha256 = "06a9iyjbb27ymfqwm5k561r29y63qf12w3q53jq82dr8hqikqrph";
        };
      };
    };
    "symfony/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-config-ed42f8f9da528d2c6cae36fe1f380b0c1d8f0658";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/config/zipball/ed42f8f9da528d2c6cae36fe1f380b0c1d8f0658";
          sha256 = "1kda3hpwhiiwgj92s65z8i1kjiam1ldmqvpa6s690r79nycixq83";
        };
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-33fa45ffc81fdcc1ca368d4946da859c8cdb58d9";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/console/zipball/33fa45ffc81fdcc1ca368d4946da859c8cdb58d9";
          sha256 = "17mqfqw96xqa2fj5697jhnwbzybgxvh7inr4fpbphizhyk51jkxm";
        };
      };
    };
    "symfony/debug" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-debug-1a692492190773c5310bc7877cb590c04c2f05be";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/debug/zipball/1a692492190773c5310bc7877cb590c04c2f05be";
          sha256 = "04i9p1rr2d1pqp3174kknsiasm821b77zsdpwi9rz6c7fydhh5yr";
        };
      };
    };
    "symfony/dependency-injection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-dependency-injection-9065fe97dbd38a897e95ea254eb5ddfe1310f734";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/dependency-injection/zipball/9065fe97dbd38a897e95ea254eb5ddfe1310f734";
          sha256 = "0yxx943qqa0fhai31v8926kpf68pai4pc6wpn269m1b48vmr0lg1";
        };
      };
    };
    "symfony/deprecation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-deprecation-contracts-63afe740e99a13ba87ec199bb07bbdee937a5b62";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/deprecation-contracts/zipball/63afe740e99a13ba87ec199bb07bbdee937a5b62";
          sha256 = "1blzjsmk38b36l15khbx2qs3c6xqmfp32l9xxq3305ifshw7ldby";
        };
      };
    };
    "symfony/error-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-error-handler-be731658121ef2d8be88f3a1ec938148a9237291";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/error-handler/zipball/be731658121ef2d8be88f3a1ec938148a9237291";
          sha256 = "02r1nmvig9h093sdx7zjr3db8pz633v5dvfcdwz4ycq45yhac2gx";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-1e866e9e5c1b22168e0ce5f0b467f19bba61266a";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher/zipball/1e866e9e5c1b22168e0ce5f0b467f19bba61266a";
          sha256 = "089dk0cj9cxi9plqd2ad1qdz15zxflmf05pzdng6pz0avqhsc320";
        };
      };
    };
    "symfony/event-dispatcher-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-contracts-761c8b8387cfe5f8026594a75fdf0a4e83ba6974";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher-contracts/zipball/761c8b8387cfe5f8026594a75fdf0a4e83ba6974";
          sha256 = "1641zj1y8j0w60jwbz1ydgd85lg5c97ks5wny6nk55mag2dc72yz";
        };
      };
    };
    "symfony/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-filesystem-815412ee8971209bd4c1eecd5f4f481eacd44bf5";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/filesystem/zipball/815412ee8971209bd4c1eecd5f4f481eacd44bf5";
          sha256 = "1dha3s81c44xlfk9imgyi5mddx43fld1cdqamfsns0a2capkxjf9";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-66bd787edb5e42ff59d3523f623895af05043e4f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/finder/zipball/66bd787edb5e42ff59d3523f623895af05043e4f";
          sha256 = "0a6wjs89vckwfqnxacr126jlkwqpyf3fifr3m2vxz39hm548k2cg";
        };
      };
    };
    "symfony/http-client-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-client-contracts-48ef1d0a082885877b664332b9427662065a360c";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-client-contracts/zipball/48ef1d0a082885877b664332b9427662065a360c";
          sha256 = "11hqsqfcqa7y150bs8kljppsak0gmaqqyak7mdx2pk8aicrh2rj0";
        };
      };
    };
    "symfony/http-foundation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-foundation-3f38b8af283b830e1363acd79e5bc3412d055341";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-foundation/zipball/3f38b8af283b830e1363acd79e5bc3412d055341";
          sha256 = "0rkxgmfa50naqb1wgx957iy4ap193pgz3i9avjn1zf0scfrd07dp";
        };
      };
    };
    "symfony/http-kernel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-kernel-ad8ab192cb619ff7285c95d28c69b36d718416c7";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-kernel/zipball/ad8ab192cb619ff7285c95d28c69b36d718416c7";
          sha256 = "1mlrd1b475rd058nj82dcpibg3p1dv7jlldn7wa6xb4085p4xzrc";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-a3cc8b044a6ea513310cbd48ef7333b384945638";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-ctype/zipball/a3cc8b044a6ea513310cbd48ef7333b384945638";
          sha256 = "1gwalz2r31bfqldkqhw8cbxybmc1pkg74kvg07binkhk531gjqdn";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-6d857f4d76bd4b343eac26d6b539585d2bc56493";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/6d857f4d76bd4b343eac26d6b539585d2bc56493";
          sha256 = "0g9a4jdc0gf7vilvz1yfyzj83bisaqa6j4sz0j9arwjzlc1p2708";
        };
      };
    };
    "symfony/polyfill-php72" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php72-fa2ae56c44f03bed91a39bfc9822e31e7c5c38ce";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php72/zipball/fa2ae56c44f03bed91a39bfc9822e31e7c5c38ce";
          sha256 = "07f558n0jbw8076z0hdawp2k6zv12hqq9vbp23xi5b49sfh5jg5h";
        };
      };
    };
    "symfony/polyfill-php73" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php73-0f68c03565dcaaf25a890667542e8bd75fe7e5bb";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php73/zipball/0f68c03565dcaaf25a890667542e8bd75fe7e5bb";
          sha256 = "1dxg0xfikmfk0jzspd7h9ap0kzkgkbb0sv3q48mgdkqnc8gz58wy";
        };
      };
    };
    "symfony/polyfill-php80" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php80-0cc9dd0f17f61d8131e7df6b84bd344899fe2608";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php80/zipball/0cc9dd0f17f61d8131e7df6b84bd344899fe2608";
          sha256 = "0bliap0hqz9ca7795ah9dlmispl0r67lsbs3s33awf677ql6amwk";
        };
      };
    };
    "symfony/polyfill-php81" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php81-4a4cfc2d253c21a5ad0e53071df248ed48c6ce5c";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php81/zipball/4a4cfc2d253c21a5ad0e53071df248ed48c6ce5c";
          sha256 = "01s1x2ak9c3idpigbdx7y6a9h2mfplh53131z0mr48wh9azn2s5q";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-b8648cf1d5af12a44a51d07ef9bf980921f15fca";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/process/zipball/b8648cf1d5af12a44a51d07ef9bf980921f15fca";
          sha256 = "02hxmkjv3k4ims5hrjjyd6k9fxqjbcclljnxgriczd10l58cv4sv";
        };
      };
    };
    "symfony/service-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-service-contracts-f37b419f7aea2e9abf10abd261832cace12e3300";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/service-contracts/zipball/f37b419f7aea2e9abf10abd261832cace12e3300";
          sha256 = "068lfvlmxkddgaggw0h5iipbbp99kwqvnvpdc2f9lijgzpivsv12";
        };
      };
    };
    "symfony/var-dumper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-var-dumper-42f18f170aa86d612c3559cfb3bd11a375df32c8";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/var-dumper/zipball/42f18f170aa86d612c3559cfb3bd11a375df32c8";
          sha256 = "03nxn3j8v540bd95syl28y2hvllikf2r5z3ryhb49z3xbhxc1bw1";
        };
      };
    };
    "symfony/yaml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-yaml-aeccc4dc52a9e634f1d1eebeb21eacfdcff1053d";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/yaml/zipball/aeccc4dc52a9e634f1d1eebeb21eacfdcff1053d";
          sha256 = "1k9n8i3yl0p07s4naa5f84lnf0q4gnk2266ppyi8mksgr27qiwxz";
        };
      };
    };
    "twig/twig" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "twig-twig-19185947ec75d433a3ac650af32fc05649b95ee1";
        src = fetchurl {
          url = "https://api.github.com/repos/twigphp/Twig/zipball/19185947ec75d433a3ac650af32fc05649b95ee1";
          sha256 = "17yrdvw591dkw3y51b3h916mblmzrwiplnqs6fspqb8ycvidw9ih";
        };
      };
    };
    "webignition/disallowed-character-terminated-string" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webignition-disallowed-character-terminated-string-1c35b8bacbb2e76837c0aa8538dc2468a1f10e6e";
        src = fetchurl {
          url = "https://api.github.com/repos/webignition/disallowed-character-terminated-string/zipball/1c35b8bacbb2e76837c0aa8538dc2468a1f10e6e";
          sha256 = "03zpqhm9qkyy09ls85y3kksn0hj66pj16w5fqq3hawfgny9b6j2c";
        };
      };
    };
    "webignition/internet-media-type" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webignition-internet-media-type-1a5bbe38033b00b23acd5e1dd10489bb07eed77c";
        src = fetchurl {
          url = "https://api.github.com/repos/webignition/internet-media-type/zipball/1a5bbe38033b00b23acd5e1dd10489bb07eed77c";
          sha256 = "1hrqpz9f3dlp9wlg07w993cpk5bhsxi6lcwgwds0w0wv2qzdpb08";
        };
      };
    };
    "webignition/quoted-string" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webignition-quoted-string-88b36b7be067796683ab3668e175322842dd5313";
        src = fetchurl {
          url = "https://api.github.com/repos/webignition/quoted-string/zipball/88b36b7be067796683ab3668e175322842dd5313";
          sha256 = "1h8d3rpqqnxmvmp9js13ild23rp4kpma9hvql5kjzqrz5f368iyc";
        };
      };
    };
    "webignition/string-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webignition-string-parser-8591e28c05bd250bcc67b8001f3588995b9ef74b";
        src = fetchurl {
          url = "https://api.github.com/repos/webignition/string-parser/zipball/8591e28c05bd250bcc67b8001f3588995b9ef74b";
          sha256 = "1nrgclyvxh10hlf331x71l975bbbxjxwmcgkl1qivpnww5b59h1m";
        };
      };
    };
    "zendframework/zend-escaper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "zendframework-zend-escaper-2dcd14b61a72d8b8e27d579c6344e12c26141d4e";
        src = fetchurl {
          url = "https://api.github.com/repos/zendframework/zend-escaper/zipball/2dcd14b61a72d8b8e27d579c6344e12c26141d4e";
          sha256 = "0izsdkcra281a962c8j2v289aqc9v5hk4683vhbphyjqaw7k1s2m";
        };
      };
    };
  };
  devPackages = {
    "myclabs/deep-copy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "myclabs-deep-copy-faed855a7b5f4d4637717c2b3863e277116beb36";
        src = fetchurl {
          url = "https://api.github.com/repos/myclabs/DeepCopy/zipball/faed855a7b5f4d4637717c2b3863e277116beb36";
          sha256 = "0m94698a1xff11p5r4gakk3qlb11rpi9zg9i2qdpwgyks7h6c0n8";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-ae59794362fe85e051a58ad36b289443f57be7a9";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/PHP-Parser/zipball/ae59794362fe85e051a58ad36b289443f57be7a9";
          sha256 = "1jaz3zp2g5fgyma1dfdw52hkv1dcqm3bv6k8fil1m4bimjf7l522";
        };
      };
    };
    "phar-io/manifest" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-manifest-54750ef60c58e43759730615a392c31c80e23176";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/manifest/zipball/54750ef60c58e43759730615a392c31c80e23176";
          sha256 = "0xas0i7jd6w4hknfmbwdswpzngblm3d884hy3rba0q2cs928ndml";
        };
      };
    };
    "phar-io/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-version-4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/version/zipball/4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
          sha256 = "0mdbzh1y0m2vvpf54vw7ckcbcf1yfhivwxgc9j9rbb7yifmlyvsg";
        };
      };
    };
    "phpunit/php-code-coverage" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-code-coverage-ddec29dfc128eba9c204389960f2063f3b7fa170";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-code-coverage/zipball/ddec29dfc128eba9c204389960f2063f3b7fa170";
          sha256 = "18355gvqpq4x1jd6a6ya40p4hlwlxizpac8vzs3jkq4mpiy628k6";
        };
      };
    };
    "phpunit/php-file-iterator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-file-iterator-961bc913d42fe24a257bfff826a5068079ac7782";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-file-iterator/zipball/961bc913d42fe24a257bfff826a5068079ac7782";
          sha256 = "10z6gxgj4xs2vhz4ssa9ln5bxs7nbmws1iznxl10ffrbq5fazqcw";
        };
      };
    };
    "phpunit/php-invoker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-invoker-12b54e689b07a25a9b41e57736dfab6ec9ae5406";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-invoker/zipball/12b54e689b07a25a9b41e57736dfab6ec9ae5406";
          sha256 = "047b3bz9cwqbl70d82rvhwvqw2jjhakjycgzzh7jgrpd1s9pjyxf";
        };
      };
    };
    "phpunit/php-text-template" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-text-template-e1367a453f0eda562eedb4f659e13aa900d66c53";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-text-template/zipball/e1367a453f0eda562eedb4f659e13aa900d66c53";
          sha256 = "1mplrxmc6v9wkcnraysbbpgdrmsc5zgwq4ihj1glv77xrv1x0g36";
        };
      };
    };
    "phpunit/php-timer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-timer-f258ce36aa457f3aa3339f9ed4c81fc66dc8c2cc";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-timer/zipball/f258ce36aa457f3aa3339f9ed4c81fc66dc8c2cc";
          sha256 = "1xifx37m6i4cv2vxx4ss2i8v1vwh64jldb3r6wggza59ggg7aknp";
        };
      };
    };
    "phpunit/phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-phpunit-8b1348b254e5959acaf1539c6bd790515fb49414";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/phpunit/zipball/8b1348b254e5959acaf1539c6bd790515fb49414";
          sha256 = "0z26bhgcd9k1vp5w8lqc42y84wwc71v7ycqvc0758hmlywf4dvf4";
        };
      };
    };
    "sebastian/cli-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-cli-parser-6d584c727d9114bcdc14c86711cd1cad51778e7c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/cli-parser/zipball/6d584c727d9114bcdc14c86711cd1cad51778e7c";
          sha256 = "1anv1ry2z1ms08qdmzw3kqmk1mry4mvska7bqw03wp1qc7cgwwh2";
        };
      };
    };
    "sebastian/comparator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-comparator-03d905327dccc0851c9a08d6a979dfc683826b6f";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/comparator/zipball/03d905327dccc0851c9a08d6a979dfc683826b6f";
          sha256 = "14l82qhhv2zc1frmij2nl239mwan6jynlsahv0m199wjsb6873m8";
        };
      };
    };
    "sebastian/complexity" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-complexity-bad4316aba5303d0221f43f8cee37eb58d384bbb";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/complexity/zipball/bad4316aba5303d0221f43f8cee37eb58d384bbb";
          sha256 = "197w85zmdq2nakyp4ra03vck5d8d5dz43armdaswldvix83bppqn";
        };
      };
    };
    "sebastian/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-diff-7ab1ea946c012266ca32390913653d844ecd085f";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/diff/zipball/7ab1ea946c012266ca32390913653d844ecd085f";
          sha256 = "0gzmfh4f7nkpzvg62pa1pi1cdyjl4v2yz197bdmdvxnhkjcw7q5a";
        };
      };
    };
    "sebastian/environment" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-environment-d364b9e5d0d3b18a2573351a1786fbf96b7e0792";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/environment/zipball/d364b9e5d0d3b18a2573351a1786fbf96b7e0792";
          sha256 = "1s8h47wlwipas6jqs4pkq4xjrc3rj885f88xq9h98j6yhr4j4wcx";
        };
      };
    };
    "sebastian/exporter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-exporter-76432aafc58d50691a00d86d0632f1217a47b688";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/exporter/zipball/76432aafc58d50691a00d86d0632f1217a47b688";
          sha256 = "164klsgd55bcdg3jjwdsph0rqxa0hv3rhi7r6gd8khqwc2liamz2";
        };
      };
    };
    "sebastian/global-state" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-global-state-570a2aeb26d40f057af686d63c4e99b075fb6cbc";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/global-state/zipball/570a2aeb26d40f057af686d63c4e99b075fb6cbc";
          sha256 = "09xwy0q4l6qb4yhl34bf7f31klpyrl9r9sva94z0a06v3ligx48a";
        };
      };
    };
    "sebastian/lines-of-code" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-lines-of-code-97ffee3bcfb5805568d6af7f0f893678fc076d2f";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/lines-of-code/zipball/97ffee3bcfb5805568d6af7f0f893678fc076d2f";
          sha256 = "169ys3yxizdflrmp2nx1kdkly6zwkb8vrijdbf58rrpd44gy74kj";
        };
      };
    };
    "sebastian/object-enumerator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-enumerator-1effe8e9b8e068e9ae228e542d5d11b5d16db894";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-enumerator/zipball/1effe8e9b8e068e9ae228e542d5d11b5d16db894";
          sha256 = "0nsafpxab9lnviqll9wxsbkfnhzl5bpclddc8jkmprh7fbc02d1k";
        };
      };
    };
    "sebastian/object-reflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-reflector-4bfa827c969c98be1e527abd576533293c634f6a";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-reflector/zipball/4bfa827c969c98be1e527abd576533293c634f6a";
          sha256 = "14miw9cn75vhx93p75v889fd2zgr5ijfvq5v42mka25x1f5f4mhp";
        };
      };
    };
    "sebastian/recursion-context" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-recursion-context-c405ae3a63e01b32eb71577f8ec1604e39858a7c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/recursion-context/zipball/c405ae3a63e01b32eb71577f8ec1604e39858a7c";
          sha256 = "1v7h4jmwa9zs8sl5jp7lz53n7mxf6gja4sl55z8h0hqh8phhj5y5";
        };
      };
    };
    "sebastian/type" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-type-1d7cd6e514384c36d7a390347f57c385d4be6069";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/type/zipball/1d7cd6e514384c36d7a390347f57c385d4be6069";
          sha256 = "1szsnbyllhxc02li9wvkfw58a025bjlhsprpvsa09m42iwh1i1hz";
        };
      };
    };
    "sebastian/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-version-3e6ccf7657d4f0a59200564b08cead899313b53c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/version/zipball/3e6ccf7657d4f0a59200564b08cead899313b53c";
          sha256 = "073p96rnz2y8k2irm6fzjjzzp95mkvwpamikyd0kgj7m41pv2prc";
        };
      };
    };
    "staabm/side-effects-detector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "staabm-side-effects-detector-d8334211a140ce329c13726d4a715adbddd0a163";
        src = fetchurl {
          url = "https://api.github.com/repos/staabm/side-effects-detector/zipball/d8334211a140ce329c13726d4a715adbddd0a163";
          sha256 = "04kvzfgwpgncn3wm316l24a02lzds05z3nf83wrm9kk2vg52rn4h";
        };
      };
    };
    "theseer/tokenizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "theseer-tokenizer-737eda637ed5e28c3413cb1ebe8bb52cbf1ca7a2";
        src = fetchurl {
          url = "https://api.github.com/repos/theseer/tokenizer/zipball/737eda637ed5e28c3413cb1ebe8bb52cbf1ca7a2";
          sha256 = "1pi1wlzmyzla2wli0h3kqf8vhddhqra2bkp9rg81b38pbh791w34";
        };
      };
    };
  };
in
composerEnv.buildPackage {
  inherit packages devPackages noDev;
  name = "ocramius.github.com";
  src = composerEnv.filterSrc ./.;
  executable = false;
  symlinkDependencies = false;
  meta = {};
}
