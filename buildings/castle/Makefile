
PROJECT ?= castle_modpack
VERSION ?= $(shell git describe --tags --always)

all:
	@echo "Nothing to do. Maybe you want `make dist` instead?"

dist:
	@echo Running git archive...
	git archive --prefix=$(PROJECT)-$(VERSION)/ -o $(PROJECT)-$(VERSION).tar $(VERSION)
	@echo Running git archive submodules...
	p=`pwd` && (echo .; git submodule foreach) | while read entering path; do \
		temp="$${path%\'}"; \
		temp="$${temp#\'}"; \
		path=$$temp; \
		[ "$$path" = "" ] && continue; \
		(cd $$path && git archive --prefix=$(PROJECT)-$(VERSION)/$$path/ HEAD > $$p/tmp.tar && tar --concatenate --file=$$p/$(PROJECT)-$(VERSION).tar $$p/tmp.tar && rm $$p/tmp.tar); \
	done
