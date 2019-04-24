#!/bin/sh
set -ex

WWWGROUP=www-data

echo "Moodle install and config helper"

echo "install -- install packages" 
install () {
	sudo apt install software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php -y
	sudo apt-get update
	sudo apt-get install nginx
	sudo apt install php7.2-fpm php7.2-curl php7.2-cli \
		php7.2-gmp php7.2-gd php7.2-xmlrpc php7.2-json php7.2-intl \
	       	php-imagick php7.2-common php7.2-mbstring php7.2-zip\
	       	php7.2-soap php7.2-xml -y
	sudo apt-get install postgresql postgresql-contrib php7.2-pgsql
	sudo apt-get install git
	# install lastes version of moodle using git
	sudo mkdir -p /var/www/moodle
        sudo chown -R $USER:$WWWGROUP /var/www/moodle
	cd /var/www/moodle
	git clone https://github.com/moodle/moodle.git .

}

echo "config -- write config files"
config () {}

$@
