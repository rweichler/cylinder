return function(page, offset, is_inside)

    local percent = offset/page.width
    page.layer.x = page.layer.x + offset

    local angle = -percent*math.pi/2

    local h = page.width/2
    local x = h*math.cos(math.abs(angle)) - page.width/2
    local z = -h*math.sin(math.abs(angle))

    if percent > 0 then
        x = -x
    end

    x = x - offset

    if is_inside then
        z = -z
        angle = -angle
    end

    page:translate(x, 0, z)
    page:rotate(angle, 0, 1, 0)

    return x, z, angle
end
