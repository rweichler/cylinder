include theos/makefiles/common.mk

TWEAK_NAME = Cylinder
Cylinder_FILES = Tweak.m
Cylinder_FRAMEWORKS = QuartzCore UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

scp:
	scp Cylinder.plist iphone:ms
	scp obj/Cylinder.dylib iphone:ms
