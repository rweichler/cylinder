--[[
there is only one custom type, a view (UIView)
view.subviews returns a table containing view's subviews (which conveniently are the individual icons)
you can also do view[i] to get the subview at an index
keep in mind, with lua, arrays start with index 1, not 0
width is the width of the screen
offset is the offset of the page from the screen's center.

available functions:

include("file.lua") --> runs the lua file like a function and returns whatever it returns

view:rotate(angle, pitch, yaw, roll) --> rotate the view by angle (in radians).
                                     --  typically pitch, yaw, roll are 1, -1 or 0.
                                     --  pitch is tilt forward or back (3D)
                                     --  yaw is tilt left or right (3D)
                                     --  roll is the flat one.
view:rotate(angle) --> equivalent of view:rotate(angle, 0, 0, 1)

  *****WARNING*******
  DO NOT rotate the pitch or yaw of the page AND its icons. this
  will make them blur and cause  performance loss. roll only is fine.

view:translate(x, y, z) --> this one should be obvious.

there is no scale function. the same effect can be achieved
using view:translate on the Z axis.

view.alpha = 0 --> completely transparent
view.alpha = 0.5 --> semitransparent
view.alpha = 1 --> completely opaque

view.transform --> advanced users only. this is if you want to
               --  manipulate the transformation matrix directly.
               --  it will return an array like this:
               --  [1, 0, 0, 0,
               --   0, 1, 0, 0,
               --   0, 0, 1, 0,
               --   0, 0, 0, 1]
               --   and you can edit it however you like.
               --   the BASE_TRANSFORM global variable is the
               --   equivalent of CATransform3DIdentity in Cocoa.

more will be added later
]]

--this is the function that gets called when the screen moves
--remember to "return" it at the end
--"view" is the icon page you will be manipulating (aka a view)
--"offset" is the x-offset of the current page to the center of the screen
--"width" and "height" are the width and height of the screen
return function(view, offset, width, height)

    local percent = offset/width
    if percent < 0 then percent = -percent end

    view:rotate(percent*3.14159265/4, 1, 0, 0) --this will tilt all icons slightly backward
end

--errors are stored in /var/mobile/Library/Logs/Cylinder/errors.log
