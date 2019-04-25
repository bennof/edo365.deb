# written by Benjamin Benno Falkner
#

SRCS:=$(shell ls -d */)
DEBS= $(SRCS:%/=%.deb)

all: .build $(DEBS)
	wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb


install: all
	test -d "/usr/local/edo365deb/" || mkdir -p /usr/local/edo365deb
	chmod -R 0755 /usr/local/edo365deb/
	cp $(DEBS) /usr/local/edo365deb
	cd /usr/local/edo365deb/; dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
	chmod -R 0644 /usr/local/edo365deb/*
	echo '### THIS FILE IS AUTOMATICALLY CONFIGURED ###' > /etc/apt/sources.list.d/edo365.list
	echo 'deb [trusted=yes] file:/usr/local/edo365deb ./' >> /etc/apt/sources.list.d/edo365.list

clean:
	rm -rf .build
	rm -rf *.deb*


%.deb: %
	dpkg-deb -b $< 

.build: 
	mkdir -p .build