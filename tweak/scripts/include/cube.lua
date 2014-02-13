local M_PI = 3.14159265
--this code could use some improving...
return function (view, width, percent, is_inside)
    local angle = percent*M_PI
    local m = is_inside and 1/3 or -2/3

    local x = width/2
    if percent < 0 then x = -x end

    view:translate(x, 0, 0)
    view:rotate(m*angle, 0, 1, 0)
    view:translate(-x, 0, 0)
end
