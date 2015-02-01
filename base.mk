NAME=Cylinder

#SDK stuff

ifeq ("", "$(wildcard config.mk)")
include ../config.mk
else
include config.mk
endif
XCODE=`xcrun --sdk iphoneos --show-sdk-path`

SDK_ERROR="SDK not defined"

ifdef SDK
ifeq ("", "$(wildcard $(SDK))")
ifeq (1, $(USE_XCODE_IF_AVAILABLE))
SDK_ERROR:=SDK '$(SDK)' not found in filesystem
SDK=
else
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

#flags and shit

SDKFLAGS=-mios-version-min=3.0 -isysroot $(SDK)
CFLAGS=-Wall
ARCH=-arch armv7 -arch arm64
INCLUDE=-I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback

CC=clang -g -O2 $(ARCH) $(SDKFLAGS) $(INCLUDE)

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<
