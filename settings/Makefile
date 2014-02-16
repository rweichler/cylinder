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
LIBLUA=../include/lua/liblua.a

COMP= CLAlignedTableViewCell.m CLEffect.m CLEffectsController.m CylinderSettings.m writeit.m $(LIBLUA)
REQ=$(COMP) CLAlignedTableViewCell.h CLEffect.h CLEffectsController.h CylinderSettings.h writeit.h

all: $(DYLIB).bundle

clean:
	rm -rf $(DYLIB).bundle

$(DYLIB).bundle: Resources/* $(REQ)
	mkdir -p $(DYLIB).bundle
	cp -r Resources/* $(DYLIB).bundle/
	$(MAKE) $(DYLIB).bundle/$(DYLIB)

$(DYLIB).bundle/$(DYLIB): $(REQ)
	$(MAKE) $(LIBLUA)
	$(CC) $(COMP) $(ARCH) $(SDKS) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $(DYLIB)
	mv $(DYLIB) $(DYLIB).bundle/$(DYLIB)

$(LIBLUA):
	cd ../include/lua && $(MAKE)
