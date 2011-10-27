PACKAGE = scribed_launcher
PACKAGE_DIR = scribed_launcher

PREFIX = /usr/local
ETCDIR = /etc
INITDIR = /etc/init.d

INSTALLDIR = $(PREFIX)/$(PACKAGE_DIR)
SCRIBED_PATH ?= $(shell which scribed)

all: build

build:
	echo "nothing to build."

install:
	test -d $(INSTALLDIR) || mkdir $(INSTALLDIR)
	cp -r bin $(INSTALLDIR)
	chmod +x $(INSTALLDIR)/bin/scribe_cat $(INSTALLDIR)/bin/scribe_ctrl
	@if [ ! -f $(ETCDIR)/scribed_launcher.conf ] ; then \
		cp misc/scribed_launcher.conf $(ETCDIR) ; \
		if [ "x"$(SCRIBED_PATH) != "x" ] ; then \
			echo "SCRIBED_PATH="$(SCRIBED_PATH) >> $(ETCDIR)/scribed_launcher.conf; \
		fi; \
	fi
	cp misc/scribed_init.bash $(INITDIR)/scribed
	chmod +x $(INITDIR)/scribed
