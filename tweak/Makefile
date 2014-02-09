NAME=Cylinder
IPHONE_IP=iphone #root@192.168.1.7
SCP=scp #-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 -arch arm64
SDKS=-mios-version-min=3.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk
#ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore
FLAGS= -dynamiclib #-undefined suppress -flat_namespace
DYLIB=$(NAME).dylib
LIBLUA=lua/liblua.a

MS_DIR=/Library/MobileSubstrate/DynamicLibraries/
CYLINDER_DIR=/Library/Cylinder/

COMP=substrate/libsubstrate.dylib CompileMe.m $(LIBLUA)
REQ=$(COMP) Tweak.m PointerContainer.h PointerContainer.m luashit.h luashit.m macros.h Makefile

all: $(DYLIB)

copy: $(DYLIB)
	$(SCP) $(DYLIB) $(IPHONE_IP):$(MS_DIR)
	$(SCP) $(NAME).plist $(IPHONE_IP):$(MS_DIR)
	$(SCP) -r scripts/* $(IPHONE_IP):$(CYLINDER_DIR)

clean:
	rm -f $(DYLIB)
	cd lua && $(MAKE) clean

$(DYLIB): $(REQ)
	$(CC) $(COMP) $(ARCH) $(SDKS) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $@

$(LIBLUA): lua/Makefile
	cd lua && $(MAKE)
