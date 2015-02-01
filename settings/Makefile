include ../base.mk

DYLIB=$(NAME)Settings

PREFERENCES=$(SDK)/System/Library/PrivateFrameworks/Preferences.framework/Preferences
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics -framework AVFoundation $(PREFERENCES)
OUTPUT=CLAlignedTableViewCell.o CLDonateController.o CLEffect.o CLEffectsController.o CLFormulasController.o CylinderSettings.o

all: $(DYLIB).bundle/$(DYLIB)

clean:
	rm -rf $(DYLIB).bundle
	rm -f $(OUTPUT)

.PHONY: all clean

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
