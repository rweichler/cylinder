return function(page, offset, width, height)
    local x = offset
    local y = offset * 1.5
    page:translate(x, y, 0)
end
