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

#get the SDK

ifeq ("", "$(wildcard config.mk)")
include ../config.mk
else
include config.mk
endif
XCODE=`xcrun --sdk iphoneos --show-sdk-path`

SDK_ERROR="SDK not defined"

ifdef SDK
ifeq (1, $(USE_XCODE_IF_AVAILABLE))
SDK_ERROR= "SDK '$(SDK)' not found in filesystem"
SDK=
else
ifeq ("", "$(wildcard $(SDK))")
$(error SDK '$(SDK)' not found in filesystem)
endif
endif
endif

ifndef SDK
ifneq ("", "$(wildcard /usr/bin/xcrun)")
SDK=$(XCODE)
else
$(error $(SDK_ERROR) and Xcode is not installed. Please set the SDK environment variable (in config.mk) or install Xcode)
endif
endif

SDKFLAGS=-mios-version-min=3.0 -isysroot $(SDK)
CFLAGS=-Wall
ARCH=-arch armv7 -arch arm64
INCLUDE=-I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback

CC=clang -g -O2 $(ARCH) $(SDKFLAGS) $(INCLUDE)

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<
