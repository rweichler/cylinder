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
DYLIB=$(NAME)Settings

DEVELOPER_DIR=`xcode-select --print-path`
#SDK_PATH=$(DEVELOPER_DIR)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7*.sdk
SDK_PATH=~/code/iPhoneOS7.1.sdk
SDKS=-mios-version-min=3.0 -isysroot $(SDK_PATH)
CFLAGS=-Wall
ARCH=-arch armv7 -arch arm64
INCLUDE=-I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback

CC=clang -g -O2 $(ARCH) $(SDKS) $(INCLUDE)

PREFERENCES=$(SDK_PATH)/System/Library/PrivateFrameworks/Preferences.framework/Preferences
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics -framework AVFoundation $(PREFERENCES)
OUTPUT=CLAlignedTableViewCell.o CLDonateController.o CLEffect.o CLEffectsController.o CLFormulasController.o CylinderSettings.o

all: $(DYLIB).bundle/$(DYLIB)

clean:
	rm -rf $(DYLIB).bundle
	rm -f $(OUTPUT)

.PHONY: all clean

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<

$(DYLIB).bundle: Resources/* $(REQ)
	mkdir -p $(DYLIB).bundle
	cp -r Resources/* $(DYLIB).bundle/

$(DYLIB).bundle/$(DYLIB): $(OUTPUT) $(DYLIB).bundle
	$(CC) -dynamiclib -o $@ $(OUTPUT) $(FRAMEWORKS)

CLAlignedTableViewCell.o: CLAlignedTableViewCell.h CLAlignedTableViewCell.m
CLDonateController.o: CLDonateController.h CLDonateController.m
CLEffect.o: CLEffect.h CLEffect.m
CLEffectsController.o: CLEffectsController.h CLEffectsController.m
CLFormulasControler.o: CLFormulasController.h CLFormulasController.m
CylinderSettings.o: CylinderSettings.h CylinderSettings.m
