--[[ ******************************************************************
Burst by KOP
******************************************************************* ]]

return function(pg, of, sw, sh)
    local pc, cx, cy = math.abs(of/pg.width), pg.width/2, pg.height/2
    -- target distance
    local tg = pg.width
    local fnum=1;
    local fx=5*pc
    local de = 3*pc
    if de>1 then de=1 end
    if fx>1 then fx=1 end
    for i, ic in subviews(pg) do
        -- get icon center
        local icx, icy = (ic.x+ic.width/2), (ic.y+ic.height/2)
        -- get icon offset from page center
        local ox, oy = cx-icx, cy-icy
        local ax, ay = math.abs(ox), math.abs(oy)
        -- get angle of icon position
        local ang = math.atan2(oy,ox)
        local ang2 = math.atan(ay/ax)
        -- get hypotenuse
        local h = math.sqrt( ox^2+oy^2)
        -- get hypotenuse extension
        local oh = pc*tg+fx*(1.5^(3*pc+1)-3.4*de^0.33)*h
        -- directions
        local dx, dy = 1,1
        if icx<cx then dx=-dx end
        if icy<cy then dy=-dy end
        if icy==cy then dy=0 end
        if ang>=math.pi then fnum=-1 end
        if ang<math.pi then fnum=1 end
        -- calc new x & y
        local nx = oh * math.cos(ang2) * dx
        local ny = oh * math.sin(ang2) * dy

        -- move!
        ic:translate(nx, ny)
        if oy >= 0 then
            ic:rotate(fx*(ang-.5*math.pi), 0, 0, 1)
        else
            ic:rotate(fx*(ang+.5*math.pi), 0, 0, 1)
        end
        ic:rotate(pc*(380/(h+20)^0.8), oy, 0, 0)
        if oy==0 then
            ic:rotate(pc*(380/(h+20)^0.8), ox, 0, 0)
        end
        --ic:rotate(, 0, 0-oy, 0)
        -- if pc>0.6 then
            ic.alpha = 1-pc
        -- end
    end
end

