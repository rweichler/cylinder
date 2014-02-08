local M_PI = 3.14159265

return function (view, percent, is_inside)
    local angle = percent*M_PI/2
    if not is_inside then angle = -angle end
    view:rotate(BASE3D, angle, 0, 1, 0)

    if percent < 0 then percent = -percent end
    view.alpha = 1 - percent
end
