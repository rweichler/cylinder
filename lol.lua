--width is the width of the screen
--offset is the offset of the page from the screen's center.

--you have three functions at disposal, which all return a CATransform3D pointer.
--you may pass this pointer as the first argument to each of these functions for
--more complex transforms. if you dont pass one, it will be created.
--ROTATE([transform], angle, pitch, yaw, roll)
--TRANSLATE([transform], x, y, z)
--SCALE([transform], x, y, z)

--more will be added later

local M_PI = 3.14159265
return function(width, offset)

    local percent = -offset/width
    local angle = percent*M_PI/2

    return ROTATE(-angle, 0, 1, 0)

end
