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

CC=xcrun -sdk iphoneos clang
ARCH=-arch armv7 -arch arm64
DEVELOPER_DIR=`xcode-select --print-path`
SDKS=-mios-version-min=3.0 -isysroot $(DEVELOPER_DIR)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7*.sdk
#ARC=-fobjc-arc
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework AVFoundation
FLAGS= -dynamiclib -undefined suppress -flat_namespace -I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback
DYLIB=CylinderSettings

#lol fuck it
COMP= *.m
REQ=$(COMP) *.h

all: $(DYLIB).bundle

clean:
	rm -rf $(DYLIB).bundle

$(DYLIB).bundle: Resources/* $(REQ)
	mkdir -p $(DYLIB).bundle
	cp -r Resources/* $(DYLIB).bundle/
	$(MAKE) $(DYLIB).bundle/$(DYLIB)

$(DYLIB).bundle/$(DYLIB): $(REQ)
	$(CC) $(COMP) $(ARCH) $(SDKS) $(FRAMEWORKS) $(ARC) $(FLAGS) -o $(DYLIB)
	mv $(DYLIB) $(DYLIB).bundle/$(DYLIB)
