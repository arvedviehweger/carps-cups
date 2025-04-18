CFLAGS=-Wall -Wextra --std=c99 -O2
CUPSDIR=$(shell cups-config --serverbin)

all:	carps-decode rastertocarps ppd/*.ppd

carps-decode:	carps-decode.c carps.h
	gcc $(CFLAGS) carps-decode.c -o carps-decode

rastertocarps:	rastertocarps.c carps.h
	gcc $(CFLAGS) rastertocarps.c -o rastertocarps -lcupsimage -lcups -ltiff

ppd/*.ppd: carps.drv
	ppdc carps.drv
	@echo "Cleaning *NickName entries..."
	sed -i '' 's/, "/"/g' ppd/*.ppd
	./insert_icons_mac.sh
	gzip -k ppd/*.ppd
	for file in ppd/*.ppd.gz; do mv $$file $$(echo $$file | sed 's/\.ppd\.gz$$/.gz/'); done
	rm -f ppd/*.ppd

clean:
	rm -rf carps-decode rastertocarps ppd/

install: rastertocarps
	# install rastertocarps filter
	install -s rastertocarps $(CUPSDIR)/filter/
	
	# install icons
	mkdir -p /Library/Printers/Canon/Icon/
	install -m 644 Icons/*.icns /Library/Printers/Canon/Icon/
	
	# install ppd files
	mkdir -p /Library/Printers/PPDs/Contents/Resources/
	install -m 644 ppd/*.gz /Library/Printers/PPDs/Contents/Resources/
