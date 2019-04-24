# written by Benjamin Benno Falkner
#

SRCS:=$(shell ls -d */)
DEBS= $(SRCS:%/=%.deb)

all: .build $(DEBS)


install: all


clean:
	rm -rf .build
	rm -rf *.deb


%.deb: %
	dpkg-deb -b $< 

.build: 
	mkdir -p .build