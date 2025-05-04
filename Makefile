UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

HOMEBREW := /usr/local

# check if we are on Apple Silicon
ifeq ($(UNAME_S),Darwin)
  ifeq ($(UNAME_M),arm64)
  HOMEBREW := /opt/homebrew
    ifeq ($(wildcard $(HOMEBREW)/include),$(HOMEBREW)/include)
      CFLAGS += -I$(HOMEBREW)/include
      LDFLAGS += -L$(HOMEBREW)/lib
    endif
  endif
endif

CFLAGS += -Wall -Wextra --std=c99 -O2
CUPSDIR := $(shell cups-config --serverbin)
LIBTIFF := $(HOMEBREW)/lib/libtiff.a $(HOMEBREW)/lib/libjpeg.a $(HOMEBREW)/lib/libzstd.a $(HOMEBREW)/lib/liblzma.a 

all:	carps-decode rastertocarps ppd/*.ppd

carps-decode:	carps-decode.c carps.h
	gcc $(CFLAGS) carps-decode.c -o carps-decode

rastertocarps:	rastertocarps.c carps.h
	gcc $(CFLAGS) rastertocarps.c $(LIBTIFF) -o rastertocarps $(LDFLAGS) -lcupsimage -lcups -lz

ppd/*.ppd: carps.drv
	ppdc carps.drv
	@echo "Cleaning *NickName entries..."
	@sed -i '' 's/, "/"/g' ppd/*.ppd
	@./patch_mac_ppd.sh
	@gzip -k ppd/*.ppd
	@for file in ppd/*.ppd.gz; do mv $$file $$(echo $$file | sed 's/\.ppd\.gz$$/.gz/'); done
	@rm -f ppd/*.ppd

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
