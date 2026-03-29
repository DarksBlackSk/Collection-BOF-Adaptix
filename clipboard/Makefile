# Makefile para clipboard BOF — Adaptix
CC_x64  := x86_64-w64-mingw32-gcc
CC_x86  := i686-w64-mingw32-gcc
STRIP   := x86_64-w64-mingw32-strip
STRIP86 := i686-w64-mingw32-strip
CFLAGS  := -Wall -masm=intel
BINDIR  := _bin

all: dirs $(BINDIR)/clipboard.x64.o $(BINDIR)/clipboard.x86.o

dirs:
	mkdir -p $(BINDIR)

$(BINDIR)/clipboard.x64.o: clipboard.c beacon.h
	$(CC_x64) $(CFLAGS) -o $@ -c clipboard.c
	$(STRIP) --strip-unneeded $@

$(BINDIR)/clipboard.x86.o: clipboard.c beacon.h
	$(CC_x86) $(CFLAGS) -o $@ -c clipboard.c
	$(STRIP86) --strip-unneeded $@

clean:
	rm -f $(BINDIR)/clipboard.x64.o $(BINDIR)/clipboard.x86.o
