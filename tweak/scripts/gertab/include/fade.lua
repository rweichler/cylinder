--[[
    Fade
    by gertab
]]
return function (icon, percent, mult)
    if mult == nil then mult = 1 end
    icon.alpha = 1 - math.abs(percent*mult)
end