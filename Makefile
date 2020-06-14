ARCH=x86_64-unknown-linux-gnu
XSB_HOME=~/opt/xsb-3.8.0
LUA_HOME=~/opt/luajit

CC=gcc
CFLAGS= -O4 -Wall
LDFLAGS=  -lm -ldl -Wl,-export-dynamic -lpthread
XSB_PREFIX = $(shell realpath $(XSB_HOME))
LUA_PREFIX = $(shell realpath $(LUA_HOME))
INC= -I$(XSB_PREFIX)/emu -I$(XSB_PREFIX)/config/$(ARCH)
INC+= -I$(LUA_PREFIX)/include

XSB_OBJ=$(XSB_PREFIX)/config/$(ARCH)/saved.o/xsb.o

all:
	$(CC) -o xsblua.so $(CFLAGS) -shared -fpic $(INC) $(LDFLAGS) $(XSB_OBJ) xsblua.c

clean:
	@rm -f xsblua.so

.PHONY: clean
