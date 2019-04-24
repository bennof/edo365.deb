# written by Benjamin Benno Falkner
#

SRCS:=$(shell ls -d */)
DEBS= $(SRCS:%/=%.deb)

all: .build $(DEBS)
	wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb


install: all
	test -d "/usr/local/edo365deb/ubuntu" || mkdir -p /usr/local/edo365deb/ubuntu
	#test -d "/usr/local/edo365deb/debian" || mkdir -p /usr/local/edo365deb/debian
	#test -d "/usr/local/edo365deb/raspbian" || mkdir -p /usr/local/edo365deb/raspbian
	chmod -R 0755 /usr/local/edo365deb/
	cp $(DEBS) /usr/local/edo365deb/ubuntu
	cd /usr/local/edo365deb/ubuntu; dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
	chmod -R 0644 /usr/local/edo365deb/ubuntu/*
	add-apt-repository 'deb [trusted=yes] file:/usr/local/edo365deb/ubuntu ./'

clean:
	rm -rf .build
	rm -rf *.deb


%.deb: %
	dpkg-deb -b $< 

.build: 
	mkdir -p .build