#!/bin/bash
set -ex
CA="edo365.de"
HOSTNAME="vpn.edo365.de"

echo "install -- install packages" 
install () {
	sudo apt update
	sudo apt install strongswan strongswan-pki libcharon-extra-plugins libcharon-standard-plugins
}

echo "certs -- build and install certificates"
certs () {
	mkdir -p ~/pki/{cacerts,certs,private}
	chmod 700 ~/pki
	openssl genrsa -out ~/pki/private/ca-key.pem 4096
	#ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem
	ipsec pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
	    --type rsa --dn "CN=$CA CA" --outform pem > ~/pki/cacerts/ca-cert.pem
	openssl genrsa -out ~/pki/private/server-key.pem 4096
	#ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem
	ipsec pki --pub --in ~/pki/private/server-key.pem --type rsa \
	    | ipsec pki --issue --lifetime 1825 \
	        --cacert ~/pki/cacerts/ca-cert.pem \
	        --cakey ~/pki/private/ca-key.pem \
	        --dn "CN=$HOSTNAME" --san "$HOSTNAME" \
	        --flag serverAuth --flag ikeIntermediate --outform pem \
	        >  ~/pki/certs/server-cert.pem
	sudo cp -r ~/pki/* /etc/ipsec.d/
}

echo "config -- write config files"
config () {
	#sudo mv /etc/ipsec.conf{,.original}
	
	sudo bash -c "cat > /etc/ipsec.conf" <<"EOF"
	config setup
	    charondebug="ike 1, knl 1, cfg 0"
	    uniqueids=no
	
	conn ikev2-vpn
	    auto=add
	    compress=no
	    type=tunnel
	    keyexchange=ikev2
	    fragmentation=yes
	    forceencaps=yes
	    dpdaction=clear
	    dpddelay=300s
	    rekey=no
	    left=%any
	    leftid=@edo365.de
	    leftcert=server-cert.pem
	    leftsendcert=always
	    leftsubnet=0.0.0.0/0
	    right=%any
	    rightid=%any
	    rightauth=eap-mschapv2
	    rightsourceip=10.10.10.0/24
	    rightdns=8.8.8.8,8.8.4.4
	    rightsendcert=never
	    eap_identity=%identity
	
EOF
	
	sudo bash -c "cat > /etc/ipsec.secrets.add" <<"EOF"
	: RSA "server-key.pem"
	your_username : EAP "your_password"
EOF
	sudo vi -O /etc/ipsec.secrets /etc/ipsec.secrets.add
	
	sudo systemctl restart strongswan
}

echo "setup_ufw -- change firewall"
setup_ufw (){
	sudo ufw allow OpenSSH
	sudo ufw enable
	sudo ufw allow 500,4500/udp
	
	ip route | grep default
	sudo bash -c "cat > /etc/ufw/before.rules.add" <<"EOF"
	*nat
	-A POSTROUTING -s 10.10.10.0/24 -o ens3 -m policy --pol ipsec --dir out -j ACCEPT
	-A POSTROUTING -s 10.10.10.0/24 -o ens3 -j MASQUERADE
	COMMIT
	
	*mangle
	-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o ens3 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
	COMMIT
	
	... filter ...
	
	-A ufw-before-forward --match policy --pol ipsec --dir in --proto esp -s 10.10.10.0/24 -j ACCEPT
	-A ufw-before-forward --match policy --pol ipsec --dir out --proto esp -d 10.10.10.0/24 -j ACCEPT
EOF
	sudo vi -O /etc/ufw/before.rules /etc/ufw/before.rules.add
	
	sudo bash -c "cat > /etc/ufw/sysctl.conf.add" <<"EOF"
	net/ipv4/ip_forward=1
	net/ipv4/conf/all/accept_redirects=0
	net/ipv4/conf/all/send_redirects=0
	net/ipv4/ip_no_pmtu_disc=1
EOF
	sudo vi -O /etc/ufw/sysctl.conf /etc/ufw/sysctl.conf.add
	
	sudo ufw disable
	sudo ufw enable
}

all () {
	install
	certs
	config
	setup_ufw
}

$@
