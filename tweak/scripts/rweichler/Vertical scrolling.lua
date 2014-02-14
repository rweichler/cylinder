return function(page, offset, width, height)
    local view = page
    local percent = offset/width
    local x = percent * width
    local y = percent * width * 1.5
    view:translate(x, y, 0)
end
