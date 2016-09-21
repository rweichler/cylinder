return function(page, offset, is_inside)

    local percent = offset/page.width

    local angle = -percent * (math.pi/2)

    local Rx = page.width/2

    page.layer.x = page.layer.x + offset

    local dx = math.sin(angle)*Rx
    local dz = (math.cos(angle) - 1)*Rx

    if (is_inside) then
        dz = -dz
        angle = -angle
    end

    page:translate(dx, 0, dz)
    page:rotate(angle, 0, 1, 0)

    return dx, dz, angle
end