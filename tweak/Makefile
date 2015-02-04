include ../base.mk

DYLIB = $(NAME).dylib

FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics
LIBLUA=../include/lua/liblua.a
OUTPUT=tweak.o luashit.o lua_UIView.o UIView+Cylinder.o CALayer+Cylinder.o
SUBSTRATE=../include/libsubstrate.dylib

all: $(DYLIB)

clean:
	@echo cleaning tweak...
	@rm -f $(DYLIB) $(OUTPUT) tweak.x.o.m
	@echo done!

.PHONY: all clean

$(DYLIB): $(OUTPUT) $(LIBLUA) $(SUBSTRATE)
	@echo linking $@...
	@$(CC) -dynamiclib -o $@ $^ $(FRAMEWORKS)

$(LIBLUA):
	cd ../include/lua && $(MAKE)

tweak.o: tweak.x tweak.h
luashit.o: luashit.h luashit.m
lua_UIView.o: lua_UIView.h lua_UIView.m
UIView+Cylinder.o: UIView+Cylinder.h UIView+Cylinder.m
CALayer+Cylinder.o: CALayer+Cylinder.h CALayer+Cylinder.m
