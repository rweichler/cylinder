--[[
    Spin function
    by gertab
]]
return function (icon, percent, rounds)
    local angle = percent*6.28318531*rounds
    icon:rotate(angle,0,0,1)
end