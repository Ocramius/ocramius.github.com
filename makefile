sculpin: composer.json sculpin.lock
	curl -sS https://getcomposer.org/installer | php --

install: source/
	php composer.phar install

setup: .sculpin
	php vendor/bin/sculpin generate --watch --server
