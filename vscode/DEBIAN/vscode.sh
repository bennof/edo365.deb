#!/bin/sh
set -e #x

echo "Visual Studio Code install and config helper"

echo "install -- install packages" 
install () {
	if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then 
		sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
		wget  https://packages.microsoft.com/keys/microsoft.asc 
		gpg --dearmor microsoft.asc
		sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		rm microsoft.asc microsoft.asc.gpg
		sudo apt-get update
	fi
	sudo apt-get install code
}

$@
