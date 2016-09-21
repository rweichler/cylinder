return function (page, offset)
    local percent = offset/page.width
    page.layer.x = page.layer.x + offset

    local angle = percent*math.pi
    local x = page.width/2
    if percent > 0 then x = -x end

    page:translate(x, 0, 0)
    page:rotate(angle, 0, 1, 0)
    page:translate(-x, 0, 0)
end
