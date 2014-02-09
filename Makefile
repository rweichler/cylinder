
MOBSUB=.tmp/Library/MobileSubstrate/DynamicLibraries


all:
	cd tweak && $(MAKE)
	cd settings && $(MAKE)

package-dirs:
	mkdir -p .tmp
	mkdir -p .tmp/DEBIAN
	mkdir -p .tmp/Library
	mkdir -p .tmp/Library/Cylinder
	mkdir -p .tmp/Library/MobileSubstrate
	mkdir -p $(MOBSUB)
	mkdir -p .tmp/Library/PreferenceBundles
	mkdir -p .tmp/Library/PreferenceLoader/Preferences

package:
	$(MAKE) all
	$(MAKE) package-dirs
	cp tweak/Cylinder.dylib $(MOBSUB)
	cp tweak/Cylinder.plist $(MOBSUB)
	cp -r settings/.theos/obj/CylinderSettings.bundle .tmp/Library/PreferenceBundles
	cp settings/entry.plist .tmp/Library/PreferenceLoader/Preferences
	cp control .tmp/DEBIAN/
	dpkg-deb -b .tmp
	mv .tmp.deb cylinder.deb
	rm -rf .tmp
