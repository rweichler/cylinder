--[[

    Curl and Ascend v1.0
    by Samueljh1

    * http://github.com/samueljh1
    * http://youtube.com/samueljh1

--]]

local oneDegrees = math.pi/180
local threeSixtyDegrees = math.pi*2

return function(page, offset, screen_width, screen_height)

    local percent = offset/page.width
    local angle = threeSixtyDegrees * percent

    for i=1, #page do

        local icon = page[i]
        local deg = angle

        if offset >= 0 then

            deg = deg - oneDegrees*(i-1)*7

            if deg <= 0 then
                 deg = 0
            end

        elseif offset < 0 then

            deg = deg + oneDegrees*(i-1)*3

            if deg > 0 then
                deg = 0
            end

        end

        local trueX = icon.x/screen_width
        local trueY = icon.y/screen_height

        icon:translate(trueX, trueY + (deg * (math.sin(percent)*15)) * -2)
        icon:rotate(deg)

    end

end
