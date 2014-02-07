#This was completely ripped off of Alex Zielenski's Zeppelin settings.

#Thanks.

include theos/makefiles/common.mk

BUNDLE_NAME = CylinderSettings
CylinderSettings_FILES = CylinderSettings.m CLAlignedTableViewCell.m CLEffectsController.m CLEffect.m
CylinderSettings_INSTALL_PATH = /Library/PreferenceBundles
CylinderSettings_FRAMEWORKS = UIKit
CylinderSettings_PRIVATE_FRAMEWORKS = Preferences
CylinderSettings_CFLAGS = -I../include

include $(THEOS_MAKE_PATH)/bundle.mk


internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CylinderSettings.plist$(ECHO_END)

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.plist' -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -iname '*.png' -exec pincrush -i {} \;$(ECHO_END)
