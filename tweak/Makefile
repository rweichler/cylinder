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
IPHONE_IP=iphone
SCP=scp

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
COMPILEO=$(CC) $(ARCH) $(SDKS) $(INCLUDES) $(ARC)
COMPILE=$(COMPILEO) $(FRAMEWORKS) $(FLAGS)

MS_DIR=/Library/MobileSubstrate/DynamicLibraries/
CYLINDER_DIR=/Library/Cylinder/

all: $(DYLIB)

tweak.o: Tweak.m
	$(COMPILEO) -c -o tweak.o Tweak.m
luashit.o: luashit.h luashit.m
	$(COMPILEO) -c -o luashit.o luashit.m
lua_UIView.o: lua_UIView.h lua_UIView.m
	$(COMPILEO) -c -o lua_UIView.o lua_UIView.m
UIView_Cylinder.o: UIView+Cylinder.h UIView+Cylinder.m
	$(COMPILEO) -c -o UIView_Cylinder.o UIView+Cylinder.m
CALayer_Cylinder.o: CALayer+Cylinder.h CALayer+Cylinder.m
	$(COMPILEO) -c -o CALayer_Cylinder.o CALayer+Cylinder.m

clean:
	rm -f $(DYLIB)
	cd ../include/lua && $(MAKE) clean

$(DYLIB): tweak.o luashit.o lua_UIView.o UIView_Cylinder.o CALayer_Cylinder.o $(LIBLUA) ../include/libsubstrate.dylib
	$(COMPILE) $^ -o $@

$(LIBLUA):
	cd ../include/lua && $(MAKE)
