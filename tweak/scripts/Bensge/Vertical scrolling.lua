return function(page, offset, width, height)
    local percent = offset/width
    local x = offset
    local y = percent * height
    page:translate(x, y, 0)
end
