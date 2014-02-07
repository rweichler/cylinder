NAME=Cylinder

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 -mios-version-min=3.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk
#ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore
FLAGS= -dynamiclib #-undefined suppress -flat_namespace
DYLIB=$(NAME).dylib
LIBLUA=lua/liblua.a

COMP=substrate/libsubstrate.dylib Tweak.m $(LIBLUA)
REQ=$(COMP) luashit.h luashit.m macros.h

all: $(DYLIB)

copy: $(DYLIB)
	scp $(DYLIB) iphone:ms
	scp $(NAME).plist iphone:ms
	scp lol.lua iphone:/Library/Cylinder/

clean:
	rm $(DYLIB)
	cd lua && $(MAKE) clean

$(DYLIB): $(REQ)
	$(CC) $(COMP) $(ARCH) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $@

$(LIBLUA): lua/Makefile
	cd lua && $(MAKE)
