NAME=Cylinder

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 -mios-version-min=3.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk
ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore
FLAGS= -dynamiclib #-undefined suppress -flat_namespace
DYLIB=$(NAME).dylib
LIBLUA=lua/liblua.a

all: $(DYLIB)

copy: $(DYLIB)
	scp $(DYLIB) iphone:ms
	scp $(NAME).plist iphone:ms

clean:
	rm $(DYLIB)
	cd lua && $(MAKE) clean

$(DYLIB): substrate/libsubstrate.dylib Tweak.m $(LIBLUA)
	$(CC) $^ $(ARCH) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $@

$(LIBLUA): lua/Makefile
	cd lua && $(MAKE)
