#!/bin/sh
set -e#x

WWWGROUP=www-data

echo "Postfix install and config helper"

echo "install -- install packages" 
install () {
	sudo apt-get update
	sudo DEBIAN_PRIORITY=low apt-get install postfix
}


echo "config -- write config files"
config () {
	sudo postconf -e 'home_mailbox= Maildir/'
	sudo postconf -e 'virtual_alias_maps= hash:/etc/postfix/virtual'
	sudo vi /etc/postfix/virtual
	sudo postmap /etc/postfix/virtual
	sudo systemctl restart postfix
	sudo ufw allow Postfix
	echo 'export MAIL=~/Maildir' | sudo tee -a /etc/bash.bashrc | sudo tee -a /etc/profile.d/mail.sh
	echo "use <source /etc/profile.d/mail.sh> to enable postfix "
}

echo "client -- install and setup a client"
client (){
	sudo apt-get install s-nail
	echo -e "set emptystart\nset folder=Maildir\nset record=+sent\n" | sudo tee -a /etc/s-nail.rc
	echo "alias mail='s-nail'" | sudo tee -a /etc/bash.bashrc | sudo tee -a /etc/profile.d/mail.sh
	echo 'init' | s-nail -s 'init' -Snorecord $USER
}


$@
