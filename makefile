PKG_NAME=urepo
PKG_VERSION=2.2
PKG_DESCRIPTION="Universal repository for linux binary packages"

.PHONY: all
SHELL=/bin/bash

all: pkg
bin:
	gcc -Wall -O2 -o extract-post-file extract-post-file.c
clean:
	rm -rf extract-post-file build
pkg: bin
	mkdir build
	cp -r {var,etc} build/
	cp extract-post-file build/var/urepo/cgi
	cd build && \
		fpm --deb-user root --deb-group root \
	    -d nginx -d fcgiwrap -d createrepo \
		--deb-no-default-config-files \
		--deb-config ../DEBIAN/config \
        --deb-templates ../DEBIAN/templates \
	    --description $(PKG_DESCRIPTION) \
	    --after-install ../DEBIAN/postinst \
	    --before-remove ../DEBIAN/prerm \
	    -s dir -t deb -v $(PKG_VERSION) -n $(PKG_NAME) `find . -type f` && \
	rm -rf `ls|grep -v deb$$`
purge: clean
	apt-get purge -y urepo || true
	rm -f /var/lib/dpkg/info/urepo.*
	echo PURGE | debconf-communicate urepo

