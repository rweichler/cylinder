NAME=Cylinder
IPHONE_IP=iphone #root@192.168.1.7
SCP=scp #-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 -arch arm64
SDKS=-mios-version-min=3.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk
#ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore
FLAGS= -dynamiclib -undefined suppress -flat_namespace -I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback
DYLIB=CylinderSettings

COMP= CLAlignedTableViewCell.m CLEffect.m CLEffectsController.m CylinderSettings.m
REQ=$(COMP) CLAlignedTableViewCell.h CLEffect.h CLEffectsController.h CylinderSettings.h Defines.h

all: $(DYLIB).bundle

clean:
	rm -rf $(DYLIB).bundle

$(DYLIB).bundle: $(REQ)
	$(CC) $(COMP) $(ARCH) $(SDKS) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $(DYLIB)
	mkdir -p $(DYLIB).bundle
	cp Resources/* $(DYLIB).bundle/
	mv $(DYLIB) $(DYLIB).bundle
