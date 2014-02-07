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


--this is the function that gets called when the screen moves
--remember to "return" it at the end
return function(page, width, offset)

    local percent = offset/width
    if percent < 0 then percent = -percent end

    view:rotate(BASE, percent*3.14159265/4, 1, 0, 0) --this will tilt all icons slightly backward
end
