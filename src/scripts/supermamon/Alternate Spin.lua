--[[ *******************************************************
Alternate Spin v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

A modification of the built-in Spin effect.
This reverses the spin direction of every other icon

v1.1 2014-02-16: Code enhancements
v1.0 2014-02-13: First Release
******************************************************** ]]
local function spin(page, percent)
	local tumbles = 1 --how many time the icons will rotate 
    local angle = percent*math.pi*2*tumbles

    local i = 0
    while true do
        i = i + 1
        local icon = page[i]
        if icon == nil then break end
		-- reverse the direction on every other icon
		if (1 % 2 ~= 0) then angle = -angle end
		
        icon:rotate(angle)
    end
end
-- MAIN --
return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    spin(page, percent)
end
