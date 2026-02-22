{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    composer2nix = {
      url = "github:svanderburg/composer2nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, composer2nix, ... }@inputs: 
    flake-utils.lib.eachDefaultSystem (
      system: 
        let
          website-name = "ocramius.github.io";
          pkgs = (import nixpkgs) {
            inherit system;
          };
          composerEnv = import ./composer-env.nix {
            stdenv        = pkgs.stdenv;
            lib           = pkgs.lib;
            writeTextFile = pkgs.writeTextFile;
            fetchurl      = pkgs.fetchurl;
            unzip         = pkgs.unzip;
            php           = pkgs.php;
            phpPackages   = pkgs.phpPackages; 
          };
          with-vendor = import ./php-packages.nix {
            inherit composerEnv;
            
            noDev    = true;
            fetchurl = pkgs.fetchurl;
            fetchgit = pkgs.fetchgit;
            fetchhg  = pkgs.fetchhg;
            fetchsvn = pkgs.fetchsvn;
          };
          with-autoloader = derivation {
            name    = "with-autoloader";
            src     = with-vendor;
            builder = pkgs.writeShellScript "install-via-composer.sh" ''
              set -euxo pipefail
              ${pkgs.coreutils}/bin/cp -r $src/. $TMPDIR
              cd $TMPDIR
              ${pkgs.coreutils}/bin/chmod -R +w $TMPDIR/vendor/composer
              ${pkgs.php84Packages.composer}/bin/composer install --no-dev --no-scripts --no-plugins
              ${pkgs.coreutils}/bin/cp -r $TMPDIR/. $out
            '';
            inherit system;
          };
          built-blog-assets = derivation {
            name    = "built-blog-assets";
            src     = with-autoloader;
            builder = pkgs.writeShellScript "generate-blog-assets.sh" ''
              set -euxo pipefail
              ${pkgs.coreutils}/bin/cp -r $src/. $TMPDIR
              cd $TMPDIR
              ${pkgs.php}/bin/php vendor/bin/sculpin generate --env=prod
              ${pkgs.coreutils}/bin/cp -r $TMPDIR/output_prod $out
              #${pkgs.coreutils}/bin/cp -r ${./presentations/.} $out/presentations
              #${pkgs.findutils}/bin/find $out -name ".git" -exec ${pkgs.coreutils}/bin/rm -rf {} \;
            '';
            inherit system;
          };
          caddy-module-with-assets = derivation {
            name    = "caddy-module-with-assets";
            builder = pkgs.writeShellScript "generate-blog-assets.sh" ''
              set -euxo pipefail
              ${pkgs.coreutils}/bin/cp -r ${./caddy-embed/.} $out
              ${pkgs.coreutils}/bin/chmod +w $out/files/
              ${pkgs.coreutils}/bin/cp -rf ${built-blog-assets}/. $out/files/
            '';
            inherit system;
          };
          embedded-server = pkgs.buildGo126Module {
            name       = "embedded-server";
            src        = caddy-module-with-assets;
            vendorHash = "sha256-v0YXbAaftLLc+e8/w1xghW5OHRjT7Xi87KyLv1siGSc=";
          };
        in {
          packages = {
            update-php-packages = pkgs.writeShellScriptBin "generate-composer-to-nix.sh" ''
              set -euxo pipefail
              TMPDIR="$(${pkgs.coreutils}/bin/mktemp -d)"
              trap 'rm -rf -- "$TMPDIR"' EXIT
              mkdir "$TMPDIR/src"
              mkdir "$TMPDIR/composer2nix"
              ${pkgs.coreutils}/bin/cp "${./composer.json}" "$TMPDIR/src/"
              ${pkgs.coreutils}/bin/cp "${./composer.lock}" "$TMPDIR/src/"
              ${pkgs.coreutils}/bin/cp -r "${./app}" "$TMPDIR/src/app"
              ${pkgs.coreutils}/bin/cp -r "${composer2nix}/." "$TMPDIR/composer2nix"
              ${pkgs.coreutils}/bin/chmod -R +w "$TMPDIR/composer2nix"
              ${pkgs.php84Packages.composer}/bin/composer install --working-dir="$TMPDIR/composer2nix" --no-scripts --no-plugins
              ${pkgs.php}/bin/php $TMPDIR/composer2nix/bin/composer2nix --name=${website-name}
              ${pkgs.coreutils}/bin/rm -f default.nix
            '';
            
            built-blog-assets = built-blog-assets;

            embedded-server = embedded-server;
            
            runnable-container = pkgs.dockerTools.buildLayeredImage {
              name = website-name;
              tag  = "latest";
              
              contents = [
                (pkgs.writeTextDir "Caddyfile" (builtins.readFile ./caddy-embed/Caddyfile))
              ];

              config = {
                Cmd = [
                  "${embedded-server}/bin/caddy-embed"
                  "run"
                ];
              };
            };

            publish-to-github-pages = pkgs.writeShellScriptBin "publish-blog.sh" ''
              set -euxo pipefail
              TMPDIR="$(${pkgs.coreutils}/bin/mktemp -d)"
              trap 'rm -rf -- "$TMPDIR"' EXIT
              cd "$TMPDIR"
              ${pkgs.git}/bin/git clone git@github.com:Ocramius/ocramius.github.com.git .
              git checkout master
              ${pkgs.rsync}/bin/rsync --quiet --archive --filter="P .git*" --exclude=".*.sw*" --exclude=".*.un~" --delete "${built-blog-assets}/" ./
              git add -A :/
              git commit -a -m "Deploying sculpin-generated pages to \`master\` branch"
              git push origin HEAD
            '';
          };

          checks = {
            blog-assets-can-be-built = pkgs.stdenv.mkDerivation {
              name       = "Website blogpost pages are being built";
              src        = ./.;
              doCheck    = true;
              checkPhase = ''
                if [[ -f "${built-blog-assets}/blog/proxy-manager-1-0-0-release/index.html" && -r "${built-blog-assets}/blog/proxy-manager-1-0-0-release/index.html" ]]; then
                  echo "OK" >> $out;
                else
                  echo "KO" >> $out;
                  exit 1;
               fi
              '';
            };
          };
        }
    );
}
