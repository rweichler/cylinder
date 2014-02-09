--[[
there is only one custom type, a view (UIView)
view.subviews returns a table containing view's subviews (which conveniently are the individual icons)
you can also do view[i] to get the subview at an index
keep in mind, with lua, arrays start with index 1, not 0
width is the width of the screen
offset is the offset of the page from the screen's center.

view:rotate(angle, pitch, yaw, roll)
view:rotate(angle) --> equivalent of view:rotate(angle, 0, 0, 1)
  angle is in radians, and typically pitch/yaw/roll are 1 or 0

  *****WARNING*******
  DO NOT rotate the pitch or yaw of the page AND its icons. (roll only is fine)
  this will make them blur and will cause drastic performance
  loss. this is not a bug. it is just how Apple designed
  Quartz. you shouldn't even have to rotate the pitch
  and yaw of the page and its icons under any circumstances
  anyway, but i thought i should mention it.

view:translate(x, y, z) --> same warning applies here, do not translate
                            across the Z axis for the page and its
                            icons simultaneously, the same blurring
                            effect will occur if you do.

there is no scale function. the same effect can be achieved
using view:translate on the Z axis.

view.alpha = 0 --> completely transparent
view.alpha = 0.5 --> semitransparent
view.alpha = 1 --> completely opaque

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
