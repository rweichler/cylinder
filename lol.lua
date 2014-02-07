--page is the icon page you will be manipulating (aka a view)
--view.subviews returns a table containing view's subviews (which conveniently are the individual icons)
--you can also do view[i] to get the subview at an index
--keep in mind, with lua, arrays start with index 1, not 0
--width is the width of the screen
--offset is the offset of the page from the screen's center.

--when manipulating the view's transform, call rotate/translate/scale with BASE as the first argument
--BASE is the original transform for that object
--with each subsequent manipulation to the view, omit BASE from the first argument

--view:rotate([transform], angle, pitch, yaw, roll)
--view:translate([transform], x, y, z)
--view:scale([transform], x, y, z)

--view.alpha = 0 --completely transparent
--view.alpha = 0.5 --set alpha to half
--view.alpha = 1 --completely opaque

--more will be added later

local M_PI = 3.14159265

local function spin(view, percent)
    local angle = percent*M_PI*2

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(BASE, angle, 0, 0, 1)
    end
end

local function cube(view, percent, is_inside)
    local angle = percent*M_PI/2
    if not is_inside then angle = -angle end
    view:rotate(BASE, angle, 0, 1, 0)

    if percent < 0 then percent = -percent end
    view.alpha = 1 - percent
end


--this is the function that gets called when the screen moves
--remember to "return" it at the end
return function(page, width, offset)

    local percent = offset/width
    spin(page, percent)
    --cube(page, percent, true)
end
