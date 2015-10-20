# Copyright (C) 2014 Reed Weichler

# This file is part of Cylinder.

# Cylinder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Cylinder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.


include base.mk

IPHONE_IP=5s
#IPHONE_IP=root@192.168.1.7
SSH_FLAGS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
PACKAGE=UNSTABLE.deb
BUNDLE_IDENTIFIER=com.r333d.cylinder

MOBSUB=.tmp/Library/MobileSubstrate/DynamicLibraries

all: tweakk settingss

clean:
	@rm -f $(PACKAGE)
	@cd tweak && $(MAKE) clean
	@cd settings && $(MAKE) clean

package-dirs:
	@echo making directory structure...
	@mkdir -p .tmp
	@mkdir -p .tmp/Library
	@mkdir -p .tmp/Library/Cylinder
	@mkdir -p .tmp/Library/MobileSubstrate
	@mkdir -p $(MOBSUB)
	@mkdir -p .tmp/Library/PreferenceBundles
	@mkdir -p .tmp/Library/PreferenceLoader/Preferences

tweakk:
	@echo === making tweak ===
	@cd tweak && $(MAKE)

settingss:
	@echo === making settings ===
	@cd settings && $(MAKE)

$(PACKAGE): all package-dirs
	@echo === making package ===
	@echo copying resources...
	@cp tweak/Cylinder.dylib $(MOBSUB)
	@cp tweak/Cylinder.plist $(MOBSUB)
	@cp -r tweak/scripts/* .tmp/Library/Cylinder/
	@cp -r settings/CylinderSettings.bundle .tmp/Library/PreferenceBundles
	@cp settings/CylinderSettingsLoader.plist .tmp/Library/PreferenceLoader/Preferences/
	@cp -r DEBIAN .tmp/
	@echo making .deb....
	@dpkg-deb -Zgzip -b .tmp
	@mv .tmp.deb $(PACKAGE)
	@rm -rf .tmp

package: $(PACKAGE)

install: $(PACKAGE)
	@echo copying to phone...
	@scp $(SSH_FLAGS) $(PACKAGE) $(IPHONE_IP):.
	@echo installing...
	@ssh $(SSH_FLAGS) $(IPHONE_IP) "dpkg -i $(PACKAGE)"

uninstall:
	@uninstalling...
	@ssh $(SSH_FLAGS) $(IPHONE_IP) "apt-get remove $(BUNDLE_IDENTIFIER)"

respring:
	@echo respringing...
	@ssh $(SSH_FLAGS) $(IPHONE_IP) "killall SpringBoard"

babies: $(PACKAGE)
	@echo copying to phone...
	@scp $(SSH_FLAGS) $(PACKAGE) $(IPHONE_IP):.
	@echo installing and respringing...
	@ssh $(SSH_FLAGS) $(IPHONE_IP) "dpkg -i $(PACKAGE) && killall SpringBoard"
