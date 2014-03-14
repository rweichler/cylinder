IPHONE_IP=iphone
#IPHONE_IP=root@192.168.1.7
#SSH_FLAGS=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
PACKAGE=UNSTABLE.deb
BUNDLE_IDENTIFIER=com.r333d.cylinder

MOBSUB=.tmp/Library/MobileSubstrate/DynamicLibraries


all:
	cd tweak && $(MAKE)
	cd settings && $(MAKE)

clean:
	rm -f $(PACKAGE)
	cd tweak && $(MAKE) clean
	cd settings && $(MAKE) clean

package-dirs:
	mkdir -p .tmp
	mkdir -p .tmp/Library
	mkdir -p .tmp/Library/Cylinder
	mkdir -p .tmp/Library/MobileSubstrate
	mkdir -p $(MOBSUB)
	mkdir -p .tmp/Library/PreferenceBundles
	mkdir -p .tmp/Library/PreferenceLoader/Preferences

tweak:
	cd tweak && $(MAKE)

settings:
	cd settings && $(MAKE)

$(PACKAGE): all
	$(MAKE) package-dirs
	cp tweak/Cylinder.dylib $(MOBSUB)
	cp tweak/Cylinder.plist $(MOBSUB)
	cp -r tweak/scripts/* .tmp/Library/Cylinder/
	cp -r settings/CylinderSettings.bundle .tmp/Library/PreferenceBundles
	cp settings/CylinderSettingsLoader.plist .tmp/Library/PreferenceLoader/Preferences/
	cp -r DEBIAN .tmp/
	dpkg-deb -b .tmp
	mv .tmp.deb $(PACKAGE)
	rm -rf .tmp

package: $(PACKAGE)

install: $(PACKAGE)
	scp $(SSH_FLAGS) $(PACKAGE) $(IPHONE_IP):.
	ssh $(SSH_FLAGS) $(IPHONE_IP) "dpkg -i $(PACKAGE)"

uninstall:
	ssh $(SSH_FLAGS) $(IPHONE_IP) "apt-get remove $(BUNDLE_IDENTIFIER)"

respring:
	ssh $(SSH_FLAGS) $(IPHONE_IP) "killall SpringBoard"

babies: $(PACKAGE)
	scp $(SSH_FLAGS) $(PACKAGE) $(IPHONE_IP):.
	ssh $(SSH_FLAGS) $(IPHONE_IP) "dpkg -i $(PACKAGE) && killall SpringBoard"
