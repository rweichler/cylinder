include ../base.mk

NAME:=$(NAME)Settings
BUNDLE=$(NAME).bundle
DYLIB=$(BUNDLE)/$(NAME)

PREFERENCES=$(SDK)/System/Library/PrivateFrameworks/Preferences.framework/Preferences
FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics -framework AVFoundation $(PREFERENCES)
OUTPUT=CLAlignedTableViewCell.o CLDonateController.o CLEffect.o CLEffectsController.o CLFormulasController.o CylinderSettings.o

all: $(DYLIB)

clean:
	@echo cleaning settings...
	@rm -rf $(BUNDLE)
	@rm -f $(OUTPUT)
	@echo clean!

.PHONY: all clean

$(BUNDLE): Resources/* $(REQ)
	@echo copying resources to preference bundle...
	@mkdir -p $@
	@cp -r Resources/* $@/

$(DYLIB): $(OUTPUT) $(BUNDLE)
	@echo linking $@
	@$(CC) -dynamiclib -o $@ $(OUTPUT) $(FRAMEWORKS)

CLAlignedTableViewCell.o: CLAlignedTableViewCell.h CLAlignedTableViewCell.m
CLDonateController.o: CLDonateController.h CLDonateController.m
CLEffect.o: CLEffect.h CLEffect.m
CLEffectsController.o: CLEffectsController.h CLEffectsController.m
CLFormulasControler.o: CLFormulasController.h CLFormulasController.m
CylinderSettings.o: CylinderSettings.h CylinderSettings.m
