--[[ ******************************************************************
Focus - modified Explosion by KnifeOfPi
******************************************************************* ]]

return function(pg, of, sw, sh)

    local pc, cx, cy = math.abs(of/pg.width), pg.width/2, pg.height/2
    -- target distance
    local tg = pg.width
    local fnum=1;
    for i, ic in subviews(pg) do
        -- get icon center
        local icx, icy = (ic.x+ic.width/2), (ic.y+ic.height/2)
        -- get icon offset from page center
        local ox, oy = cx-icx, cy-icy
        -- get angle of icon position
        local ang = math.atan(oy/ox)
        -- get hypotenuse
        local h = math.sqrt( ox^2+oy^2)
        -- get hypotenuse extension
        local oh = pc*tg+pc*h
        -- directions
        local dx, dy = 1,1
        if icx<cx then dx=-dx end
        if icy<cy then dy=-dy end
        if icy==cy then dy=0 end
        if ang>=math.pi then fnum=-1 end
        if ang<math.pi then fnum=1 end
        -- calc new x & y
        local nx = oh * math.cos(ang) * dx
        local ny = oh * math.sin(ang) * dy
        -- move!
        ic:rotate(pc*math.pi/(0.0008*(h+200)), 0-ox, 0-oy, 0)
        -- if pc>0.6 then
            ic.alpha = 1-pc
        -- end
    end
end

