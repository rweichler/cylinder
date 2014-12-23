-- Psychospiral animation by Cylgom
return function(page, offset, screen_width, screen_height)
	local percent = math.abs(offset/page.width)
	side = -1
	if(offset>0) then side=1 end

	local rollup = percent*5
	if(rollup>1) then rollup=1 end
	local runaway = (percent-0.20)/0.6
	if(runaway<0) then runaway=0 end
	if(runaway>1) then runaway=1 end

	local middleX =page.width/2
	local middleY =page.height/2+7
	local radiusparts = (middleY)/#page.subviews
	local theta = (3.5*math.pi)/#page.subviews

	for i, icon in subviews(page) do
	  local initangle =(i-1)*theta
	  local initradius =(i-1)*radiusparts
	  local angle = initangle+runaway*(3.5*math.pi-initangle)
	  local radius = initradius+runaway*(middleY-initradius)+45
	  local iconX = icon.x+icon.width/2
	  local iconY = icon.y+icon.height/2
	  local pathX = (middleX+(radius*math.cos(angle))*side)
	  local pathY = (middleY+(radius*math.sin(angle))*side)
	  local iconAngle = angle
	  icon:translate(rollup*(pathX-iconX), rollup*(pathY-iconY), 0)
	  icon:rotate(rollup*iconAngle)
	  local size = 1-(1-(radius/(middleY+50)))*rollup
	  icon:scale(size*size)
	end
	page:translate(offset,0,0)
end