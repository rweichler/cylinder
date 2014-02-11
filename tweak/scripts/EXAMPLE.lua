--[[
available functions:

dofile("file.lua") --> runs the lua file like a function and returns whatever it returns

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

--declare your own constants and functions here

PI = 3.14159265

function abs(x) --> absolute value convenience function
    if x < 0 then
        return -x
    else
        return x
    end
end

--this is the function that gets called when the screen moves
--remember to "return" it at the end
--"view" is the icon page you will be manipulating (aka a view)
--"offset" is the x-offset of the current page to the center of the screen
--"width" and "height" are the width and height of the screen

return function(view, offset, width, height)
    local percent = offset/width

    view:rotate(percent*PI/3, 1, 0, 0) --> this will tilt the page slightly backward

    local first_icon = view[1]
    first_icon:rotate(percent*PI*2) --> this will spin the first icon in the page

    local i = 0
    while true do --> loop through all of the icons
        i = i + 1
        local icon = view[i]
        if icon == nil then --> if there is no view
            break --break out of the loop
        else
            icon.alpha = 1 - abs(percent) --> set the opacity with respect to how far away it is from the center of the screen
                                          --  this calls the absolute value function we declared earlier
        end
    end
end

--errors are stored in /var/mobile/Library/Logs/Cylinder/errors.log
