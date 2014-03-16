--[[
Backwards effect v1.0
by gertab
Beware! This effect makes you go crazy!! It makes your icons go the other side you scroll.
]]
return function(page, offset, screen_width, screen_height)
    page:translate(2*offset, 0, 0)
end
