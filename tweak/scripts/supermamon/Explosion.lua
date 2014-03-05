--[[ ******************************************************************
Explosion v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)
request by: /u/gertab

v1.1 2014-03-04: Icons father from the center move away faster.
v1.0 2014-03-04: First release.
		
******************************************************************* ]]

return function(pg, of, sw, sh)

	pg:translate(of,0,0)

    local pc, cx, cy = math.abs(of/pg.width), pg.width/2, pg.height/2
	-- target distance
	local tg = pg.width
	
    for i, ic in subviews(pg) do
		-- get icon center
		local icx, icy = (ic.x+ic.width/2), (ic.y+ic.height/2)
		-- get icon offset from page center
		local ox, oy = math.abs(cx-icx), math.abs(cy-icy)
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
		
		-- calc new x & y
		local nx = oh * math.cos(ang) * dx
		local ny = oh * math.sin(ang) * dy
		
		-- move!!
		ic:translate(nx,ny,0)
		
		if pc>0.6 then
			ic.alpha = (pc-0.6)/0.4
		end

    end
end

