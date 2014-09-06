sculpin: sculpin.json sculpin.lock
	curl -O https://download.sculpin.io/sculpin.phar
	chmod +x sculpin.phar

install: source/
	php sculpin.phar install

setup: .sculpin
	php sculpin.phar generate --watch --server
