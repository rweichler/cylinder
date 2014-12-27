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
DYLIB = $(NAME).dylib

DEVELOPER_DIR=`xcode-select --print-path`
#SDK_PATH=$(DEVELOPER_DIR)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7*.sdk
SDK_PATH=~/code/iPhoneOS7.1.sdk
SDKS=-mios-version-min=3.0 -isysroot $(SDK_PATH)
CFLAGS=-Wall
ARCH=-arch armv7 -arch arm64
INCLUDE=-I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback

CC=clang -g -O2 $(ARCH) $(SDKS) $(INCLUDE)

FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics
LIBLUA=../include/lua/liblua.a
OUTPUT=tweak.o luashit.o lua_UIView.o UIView+Cylinder.o CALayer+Cylinder.o

all: $(DYLIB)

clean:
	rm -f $(DYLIB) $(OUTPUT)

.PHONY: all clean

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<

$(DYLIB): $(OUTPUT) $(LIBLUA) ../include/libsubstrate.dylib
	$(CC) -dynamiclib -o $@ $^ $(FRAMEWORKS)

$(LIBLUA):
	cd ../include/lua && $(MAKE)

tweak.o: tweak.m
luashit.o: luashit.h luashit.m
lua_UIView.o: lua_UIView.h lua_UIView.m
UIView+Cylinder.o: UIView+Cylinder.h UIView+Cylinder.m
CALayer+Cylinder.o: CALayer+Cylinder.h CALayer+Cylinder.m
