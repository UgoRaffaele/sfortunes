
# Where do the data files (fortunes, or cookies) go?
COOKIEDIR=$(prefix)/usr/share/games/fortunes
# Where do local data files go?
LOCALDIR=$(prefix)/usr/local/share/games/fortunes

COOKIES=salug

STRFILE=strfile

DIST-DIR=salug-fortunes

# To get a list of the possible targets, try 'make help'

.PHONY: all cookies install clean

all: cookies

check:
	for i in $(COOKIES) ; \
		do \
			echo -n "Testing $$i..."; \
			if ! tail -n 1 $$i | grep -q ^%$  ; then \
			        echo " failed % check" ; \
				echo "Fortune cookie file does not end in a single %" ; \
				exit 1; \
			fi;\
			if egrep -q ".{72}." $$i ; then \
				echo " failed length check"; \
				echo "Fortune cookie file contains a line longer than 72 characters"; \
				exit 1; \
			fi; \
			echo " passed " ;\
		done;

cookies: cookies-stamp

cookies-stamp:
	rm -f *.dat
	for i in $(COOKIES) ; \
	    do \
		$(STRFILE) $$i ; \
	    done
	touch cookies-stamp

install:
	install -m 0755 -d $(COOKIEDIR)
	for i in $(COOKIES) ; do \
		install -m 0644 $$i $$i.dat $(COOKIEDIR) || exit $? ; \
		cp -d $$i.u8 $(COOKIEDIR) || echo no $$i.u8 ; \
		done

uninstall:
	for i in $(COOKIES) ; do \
		rm -f $(COOKIEDIR)/$$i $(COOKIEDIR)/$$i.* ; \
	done

clean:
	rm -f cookies-stamp *.dat
	rm -rf $(DIST-DIR)*

release:
	rm -rf $(DIST-DIR)
	tla export $(DIST-DIR)
	tar -czf $(DIST-DIR).tar.gz $(DIST-DIR)

publish: release
	scp $(DIST-DIR).tar.gz rastandy@salug.it:/home/rastandy/public_html/$(DIST-DIR).tar.gz

announce: publish
	cat announce.mail | mail -s 'Nuova versione dei Fortunes del SaLUG!' \
			--append="From: rastandy@inventati.org" "salug@salug.it"
