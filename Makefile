CFLAGS=-Wall -Wextra --std=c99 -O2
CUPSDIR=$(shell cups-config --serverbin)

all:	carps-decode rastertocarps ppd/*.ppd

carps-decode:	carps-decode.c carps.h
	gcc $(CFLAGS) carps-decode.c -o carps-decode

rastertocarps:	rastertocarps.c carps.h
	gcc $(CFLAGS) rastertocarps.c -o rastertocarps -lcupsimage -lcups

ppd/*.ppd: carps.drv
	ppdc carps.drv
	@echo "Cleaning *NickName entries..."
	sed -i '' 's/, "/"/g' ppd/*.ppd
	./insert_icons_mac.sh

clean:
	rm -rf carps-decode rastertocarps ppd/

install: rastertocarps
	install -s rastertocarps $(CUPSDIR)/filter/
