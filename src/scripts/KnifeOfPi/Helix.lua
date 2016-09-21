--[[ ******************************************************************
Double Helix by KOP
        
******************************************************************* ]]

return function(pg, of, sw, sh)
    local pc, cx, cy, ops = math.abs(of/pg.width), pg.width/2, pg.height/2, of/pg.width
    -- target distance
    local midx =pg.width/2

    local midy =pg.height/2+7
    local tg = pg.width
    local fx = pc*5
    if fx>1 then fx=1 end
    if fx<-1 then fx=-1 end
    local side = -1
    local to=pc

    -- if(of>0) then side=1 end
    for i, ic in subviews(pg) do
        -- get icon center
        local icx, icy = (ic.x+ic.width/2), (ic.y+ic.height/2)
        -- get icon offset from page center
        local ox, oy = cx-icx, cy-icy
        -- get angle of icon position
        local ang = math.atan2(oy,ox)
        -- get hypotenuse
        local h = math.sqrt( ox^2+oy^2)
        local iconX = ic.x+ic.width/2
        local fall = (1-pc)*h
        local iconY = ic.y+ic.height/2
        -- get hypotenuse extension
        local oh = fx*h+fx*tg
        -- directions
        local dx, dy = 1,1
        if icx<cx then dx=-dx end
        if icy<cy then dy=-dy end
        if icy==cy then dy=0 end
        local nx = 0
        local ny = 0
        local cy = 3-3*pc
        if cy>1 then cy=1 end
        if pc==0 then pc=0.0001 end

        -- calc new x & y
        -- local nx = math.sqrt(h^2-oy^2)
        -- local ny = math.sqrt(h^2-ox^2)
        nx =midx-ops/pc*(pg.width/(7.5-pg.max_columns))*math.sin(ops*4*math.pi+8*(oy-(1/pg.max_columns*ox))/1.33/pg.height)
        ny =midy-oy+(1/pg.max_columns)*ox
        -- midy-(ops*pg.height)-oy
        local size=0

        -- move!!
        ic:translate(fx*(nx-iconX),fx*(ny-iconY),0)
        -- print(nx)
        ic:rotate(fx*(ops*4*math.pi+0.5*ops/pc*math.pi+8*(oy-(1/pg.max_columns*ox))/1.33/pg.height), 0, 1, 0)
        -- ic:scale(size*size)
        -- ic:translate(-0.5*nx,-0.5*ny,0)
    end
end

