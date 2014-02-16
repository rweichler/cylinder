--this code could use some improving...
return function (page, percent, is_inside)
    local angle = percent*math.pi
    local m = is_inside and 1/3 or -2/3

    local x = page.width/2
    if percent < 0 then x = -x end

    page:translate(x, 0, 0)
    page:rotate(m*angle, 0, 1, 0)
    page:translate(-x, 0, 0)
end
