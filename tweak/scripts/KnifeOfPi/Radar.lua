--[[ ******************************************************************
Radar by KnifeOfPi
                
******************************************************************* ]]

return function(pg, of, sw, sh)

        pg:translate(of,0,0)

    local pc, cx, cy, ops = math.abs(of/pg.width), pg.width/2, pg.height/2, of/pg.width
        -- target distance
local midx =pg.width/2

        local midy =pg.height/2+7
        local tg = pg.width
        local fx = pc*5
        if fx>1 then fx=1 end
local side = -1

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
                local fall = (1-pc^2)*h
          local iconY = ic.y+ic.height/2
                -- get hypotenuse extension
                local nh = math.sqrt((iconX-midx)^2+(iconY-midy)^2)
                local oh = fx*h+fx*tg
                -- directions
                local dx, dy, dxz, dyz = 1,1,1,1
                if icx<cx then dx=0 dxz=1 end
                if icx>cx then dx=-1 dxz=-1 end
                if icy<cy then dy=0 dyz=1 end
                if icy>cy then dy=-1 dyz=-1 end
                if icy==cy then dy=1 end
                local nx = 0
local ny = 0
local r=0
if ops<0 then r=-1 else r=1 end
local an = ang - .5*math.pi
if an>0 and r==1 then an=an-2*math.pi end
if an<0 and r==-1 then an=an+2*math.pi end

                -- calc new x & y
                -- local nx = math.sqrt(h^2-oy^2)
                -- local ny = math.sqrt(h^2-ox^2)
local go = -2*pc*an+ang
                nx =0-h*math.cos(-go)
                ny =0-h*math.sin(go)
                local size=(3-fx)*(fall/h)
                if size>1 then size=1 end
                -- move!
                -- print(ox)
                ic:translate(fx*(nx-iconX+midx),fx*(ny-iconY+midy),0)
-- ic:scale(size*size)
-- ic:translate(-0.5*nx,-0.5*ny,0)
                
                -- if pc>0.6 then
                        ic.alpha = 1-2*pc
                -- end

    end
end
