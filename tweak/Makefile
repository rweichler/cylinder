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
DEVELOPER_DIR=`xcode-select --print-path`
SDKS=-mios-version-min=3.0 -isysroot $(DEVELOPER_DIR)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7*.sdk
#ARC=-fobjc-arc
INCLUDES= -I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics
FLAGS= -dynamiclib #-undefined suppress -flat_namespace
DYLIB=$(NAME).dylib
LIBLUA=../include/lua/liblua.a

MS_DIR=/Library/MobileSubstrate/DynamicLibraries/
CYLINDER_DIR=/Library/Cylinder/

COMP=../include/libsubstrate.dylib CompileMe.m $(LIBLUA)
REQ=$(COMP) Tweak.m luashit.h luashit.m lua_UIView.h lua_UIView.m macros.h Makefile UIView+Cylinder.m UIView+Cylinder.h CALayer+Cylinder.h CALayer+Cylinder.m

all: $(DYLIB)

copy: $(DYLIB)
	$(SCP) $(DYLIB) $(IPHONE_IP):$(MS_DIR)
	$(SCP) $(NAME).plist $(IPHONE_IP):$(MS_DIR)
	$(SCP) -r scripts/* $(IPHONE_IP):$(CYLINDER_DIR)

clean:
	rm -f $(DYLIB)
	cd ../include/lua && $(MAKE) clean

$(DYLIB): $(REQ)
	$(CC) $(COMP) $(ARCH) $(SDKS) $(FRAMEWORKS) $(INCLUDES) $(ARC) $(FLAGS) -o $@

$(LIBLUA):
	cd ../include/lua && $(MAKE)
