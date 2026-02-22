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
        in {
          packages = {
            update-php-packages = pkgs.writeShellScriptBin "generate-composer-to-nix.sh" ''
              set -euxo pipefail
              TMPDIR="$(${pkgs.coreutils}/bin/mktemp -d)"
              echo $TMPDIR
              #trap 'rm -rf -- "$TMPDIR"' EXIT
              mkdir "$TMPDIR/src"
              mkdir "$TMPDIR/composer2nix"
              ${pkgs.coreutils}/bin/cp "${./.}/composer.json" "$TMPDIR/src/"
              ${pkgs.coreutils}/bin/cp "${./.}/composer.lock" "$TMPDIR/src/"
              ${pkgs.coreutils}/bin/cp -r "${./.}/app" "$TMPDIR/src/app"
              ${pkgs.coreutils}/bin/cp -r "${composer2nix}/." "$TMPDIR/composer2nix"
              ${pkgs.coreutils}/bin/chmod -R +w "$TMPDIR/composer2nix"
              ${pkgs.php84Packages.composer}/bin/composer install --working-dir="$TMPDIR/composer2nix" --no-scripts --no-plugins
              ${pkgs.php}/bin/php $TMPDIR/composer2nix/bin/composer2nix --name=ocramius.github.com
              ${pkgs.coreutils}/bin/rm -f default.nix
            '';
            
            built-blog-assets = derivation {
              name    = "built-blog-assets";
              src     = with-autoloader;
              builder = pkgs.writeShellScript "generate-blog-assets.sh" ''
                set -euxo pipefail
                ${pkgs.coreutils}/bin/cp -r $src/. $TMPDIR
                cd $TMPDIR
                ${pkgs.php}/bin/php vendor/bin/sculpin generate --env=prod
                ${pkgs.coreutils}/bin/cp -r $TMPDIR/output_prod $out
              '';
              inherit system;
            };
          };
        }
    );
}
