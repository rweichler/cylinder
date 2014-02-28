--actual documentation is at the bottom of the file
--i thought i'd start with a heavily commented example first

--declare your own constants and functions here

local function fade(icon, percent) --fade convenience function
    --set the opacity with respect to how far away it is from the center of the screen
    if percent > 0.5 then
        icon.alpha = 0
    else
        icon.alpha = 1 - 2*math.abs(percent)
    end
end

--this is the function that gets called when the screen moves
--remember to "return" it at the end
--"page" is the icon page you will be manipulating (aka a view)
--"offset" is the x-offset of the current page to the center of the screen
--"screen_width" and "screen_height" are the width and height of the screen

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width

    for i, icon in subviews(page) do
        local distance_from_middle = math.abs(page.width/2 - (icon.x + icon.width/2))
        if distance_from_middle > page.width/4 then --> only do the icons on the sides
            fade(icon, percent) --> calls the convenience function we made earlier
        end
    end

    page:rotate(percent*math.pi/3, 1, 0, 0) --> this will tilt the page slightly backward

    local first_icon = page[1]
    first_icon:rotate(percent*math.pi*2) --> this will spin the first icon in the page

end

--errors are stored in /var/mobile/Library/Logs/Cylinder/errors.log

--[[

--available functions:


print("blah blah blah") --> writes blah blah blah to ~mobile/Library/Logs/Cylinder/print.log
popup("blah blah blah") --> makes a popup with the message: blah blah blah (for easy debugging)
                        -- WARNING: if you aren't careful there will be 1,000,000 popups appearing,
                        -- so make sure you only call this once

dofile("file.lua") --> runs the lua file like a function and returns whatever it returns

view:rotate(angle, pitch, yaw, roll) --> rotate the view by angle (in radians).
                                     --  typically pitch, yaw, roll are 1, -1 or 0.
                                     --  pitch is tilt forward or back (3D)
                                     --  yaw is tilt left or right (3D)
                                     --  roll is the flat one.
view:rotate(angle) --> equivalent of view:rotate(angle, 0, 0, 1)

view:translate(x, y, z) --> this one should be obvious.

view:scale(size) --> obvious
view:scale(x, y) --> obvious
view:scale(x,y,z) --> obvious, although you wont notice the z

view.alpha = 0 --> completely transparent
view.alpha = 0.5 --> semitransparent
view.alpha = 1 --> completely opaque

-- you can only get the x/y/width/height
-- you can't set them
-- these are useful for tweaks that allow
-- more than 4 icons per row and stuff
-- or tweaks that scale the icons down
-- or ipads

view.x
view.y
view.width
view.height

-- view layer properties
-- this is usually for when you want to do
-- a translation, then a rotation
-- but the perspective gets messed up.

--you can set these
view.layer.x
view.layer.y

--you can't set these
view.layer.width
view.layer.height

--more on this later
view.layer.transform

--a typical use case would be:

view.layer.x = view.layer.x + offset

-- stuff added in 0.14.2.26.1 (READONLY)

PERSPECTIVE_DISTANCE --distance from viewpoint to icons

--these should be self-explanitory
page.max_icons
page.max_columns
page.max_rows

--builtin lua functions

math.random(1, 100) --> random number between 1 and 100
math.pi --------------> 3.14159265......
math.sin(math.pi/6) --> 0.5
math.cos(math.pi/3) --> 0.5
math.tan(math.pi/4) --> 1
math.rad(180) --------> math.pi
math.deg(math.pi) ----> 180
math.abs(-32) --------> 32
math.floor(2.4328) ---> 2

os.time() ---> number of seconds since January 1st, 1970

-- ....yeah those are some basics,
-- there are a ton more. just google
-- "lua 5.2 standard library" or something
-- and you can see all the functions you can use.
-- i disabled a few dangerous ones like os.exit and
-- os.execute for obvious reasons but most of them are
-- there.

-- *************************
-- **** ADVANCED USERS *****
-- *************************

view.layer.transform
               --  this is if you want to manipulate
               --  the transformation matrix directly.
               --  it will return an array like this:
                   [m11, m12, m13, m14,
                    m21, m22, m23, m24,
                    m31, m32, m33, m34,
                    m41, m42, m43, m44]
               --   and you can edit it however you like.
               --   the BASE_TRANSFORM global variable is the
               --   equivalent of CATransform3DIdentity in Cocoa.
               --   NOTE: you have to set it back again, kinda like
               --   a view's frame. i.e.:
                    local transform = view.transform
                    transform[12] = -1/PERSPECTIVE_DISTANCE ---> allow perspective (don't worry i already do this automatically when you rotate)
                    view.transform = transform

-- more will be added later

]]
