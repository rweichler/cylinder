include ../base.mk

DYLIB = $(NAME).dylib

FRAMEWORKS=-framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics
LIBLUA=../include/lua/liblua.a
OUTPUT=tweak.o luashit.o lua_UIView.o UIView+Cylinder.o CALayer+Cylinder.o
SUBSTRATE=../include/libsubstrate.dylib

all: $(DYLIB)

clean:
	rm -f $(DYLIB) $(OUTPUT)

.PHONY: all clean

$(DYLIB): $(OUTPUT) $(LIBLUA) $(SUBSTRATE)
	$(CC) -dynamiclib -o $@ $^ $(FRAMEWORKS)

$(LIBLUA):
	cd ../include/lua && $(MAKE)

tweak.o: tweak.m
luashit.o: luashit.h luashit.m
lua_UIView.o: lua_UIView.h lua_UIView.m
UIView+Cylinder.o: UIView+Cylinder.h UIView+Cylinder.m
CALayer+Cylinder.o: CALayer+Cylinder.h CALayer+Cylinder.m
