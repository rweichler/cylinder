NAME=Cylinder
IPHONE_IP=iphone #root@192.168.1.7
SCP=scp #-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 #-arch arm64
SDKS=-mios-version-min=3.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk
#ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback
UNDEFINED=-undefined suppress -flat_namespace
FLAGS= -dynamiclib $(UNDEFINED)
DYLIB=$(NAME).dylib

MS_DIR=/Library/MobileSubstrate/DynamicLibraries/
CYLINDER_DIR=/Library/Cylinder/

COMP=CompileMe.m
REQ=$(COMP) Tweak.m luashit.h luashit.m macros.h Makefile PointerContainer.h UIView+Cylinder.h PointerContainer.m UIView+Cylinder.m lua_loader.c lua_loader.h

all: $(DYLIB)

copy: $(DYLIB)
	$(SCP) $(DYLIB) $(IPHONE_IP):$(MS_DIR)
	$(SCP) $(NAME).plist $(IPHONE_IP):$(MS_DIR)
	$(SCP) -r scripts/* $(IPHONE_IP):$(CYLINDER_DIR)

clean:
	rm -f $(DYLIB)
	cd lua && $(MAKE) clean
	cd luajit && $(MAKE) clean

$(DYLIB): $(REQ)
	$(MAKE) luadylib
	$(MAKE) luajitdylib
	$(CC) $(COMP) luajit/libluajit.so $(ARCH) $(SDKS) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $@

luadylib:
	cd lua && make

IXCODE=$(shell xcode-select -print-path)
ISDK=$(IXCODE)/Platforms/iPhoneOS.platform/Developer
#ISDKP=$(ISDK)/usr/bin/
ISDKP=/usr/bin/
ISDKVER=iPhoneOS7.0.sdk
ISDKF=-arch armv7 -isysroot $(ISDK)/SDKs/$(ISDKVER)

luajitdylib:
	cd luajit && $(MAKE) HOST_CC="gcc -m32 -arch i386" CROSS=$(ISDKP) TARGET_FLAGS="$(ISDKF)" TARGET_SYS=iOS

