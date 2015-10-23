NAME=Cylinder

#SDK stuff

ifeq ("", "$(wildcard config.mk)")
include ../config.mk
else
include config.mk
endif
XCODE=`xcrun --sdk iphoneos --show-sdk-path`

ifdef SDK
SDK_ERROR:=SDK '$(SDK)' not found in filesystem
ifeq ("", "$(wildcard $(SDK))")
ifeq (1, $(USE_XCODE_IF_AVAILABLE))
SDK=
else
$(error $(SDK_ERROR))
endif
endif
else
SDK_ERROR=SDK not defined
endif

ifndef SDK
ifneq ("", "$(wildcard /usr/bin/xcrun)")
SDK=$(XCODE)
else
$(error $(SDK_ERROR). Set the SDK (in config.mk) or install Xcode)
endif
endif

#flags and shit

SDKFLAGS=-mios-version-min=3.0 -isysroot $(SDK)
CFLAGS=-Wall -Wno-unused-function -Wno-unused-variable
ARMV7=-arch armv7
ARM64=-arch arm64
ARCH=$(ARMV7) $(ARM64)
INCLUDE=-I../include -I../include/iphoneheaders -I../include/iphoneheaders/_fallback
IOS9_SHIT=-Wl,-segalign,4000
LDFLAGS=$(IOS9_SHIT)

CC=clang -g -O2 $(ARCH) $(SDKFLAGS) $(INCLUDE)

%.o: %.x
	@echo compiling $<...
	@../bin/logos.pl $< > $(@:.o=.x.o.m)
	@$(CC) $(CFLAGS) -c -o $@ $(@:.o=.x.o.m)

%.o: %.m
	@echo compiling $<...
	@$(CC) $(CFLAGS) -c -o $@ $<

%.dylib:
	@echo linking $@...
	@$(CC) -dynamiclib -o $@ $(LINK_US) $(FRAMEWORKS) $(LDFLAGS)
	@echo signing $@...
	@ldid -S $@
