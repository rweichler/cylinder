include theos/makefiles/common.mk

TWEAK_NAME = Cylinder
Cylinder_FILES = Tweak.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
