#!/bin/sh

set -x

git submodule update --init
curl -sS https://getcomposer.org/installer | php
./composer.phar install

rm -rf ./output_prod

./vendor/bin/sculpin generate --env=prod

cp -r ./presentations/ output_prod/presentations/
find ./output_prod/ -name ".git" -exec rm -rf {} \;

rm -rf ./gh-pages-deployment
git clone git@github.com:Ocramius/ocramius.github.com.git ./gh-pages-deployment
cd gh-pages-deployment
git checkout master
git checkout -b master

rsync --quiet --archive --filter="P .git*" --exclude=".*.sw*" --exclude=".*.un~" --delete ../output_prod/ ./
git add -A :/
git commit -a -m "Deploying sculpin-generated pages to \`master\` branch"

echo "Now please push \`master\` manually from dir \`gh-pages-deployment\`"
