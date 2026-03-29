# Makefile para wifidump BOF — Adaptix
CC     := x86_64-w64-mingw32-gcc
STRIP  := x86_64-w64-mingw32-strip
# -fno-stack-check -fno-stack-protector -mno-stack-arg-probe
# eliminan la dependencia de __chkstk_ms en BOFs
CFLAGS := -Wall -masm=intel -fno-stack-check -fno-stack-protector -mno-stack-arg-probe
BINDIR := _bin

all: dirs \
	$(BINDIR)/wifidump_enum.x64.o \
	$(BINDIR)/wifidump_dump.x64.o \
	$(BINDIR)/wifidump_auth.x64.o

dirs:
	mkdir -p $(BINDIR)

$(BINDIR)/wifidump_enum.x64.o: wifidump.c beacon.h
	$(CC) $(CFLAGS) -DBOF_ENTRY_ENUM -o $@ -c wifidump.c
	$(STRIP) --strip-unneeded $@

$(BINDIR)/wifidump_dump.x64.o: wifidump.c beacon.h
	$(CC) $(CFLAGS) -DBOF_ENTRY_DUMP -o $@ -c wifidump.c
	$(STRIP) --strip-unneeded $@

$(BINDIR)/wifidump_auth.x64.o: wifidump.c beacon.h
	$(CC) $(CFLAGS) -DBOF_ENTRY_AUTH -o $@ -c wifidump.c
	$(STRIP) --strip-unneeded $@

clean:
	rm -f $(BINDIR)/wifidump_enum.x64.o \
	      $(BINDIR)/wifidump_dump.x64.o \
	      $(BINDIR)/wifidump_auth.x64.o
