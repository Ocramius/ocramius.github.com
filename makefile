sculpin: sculpin.json sculpin.lock
	curl -sS https://getcomposer.org/installer | php

install: source/
	php vendor/bin/sculpin install

setup: .sculpin
	php vendor/bin/sculpin generate --watch --server
