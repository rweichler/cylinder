--ridn
return function(page, offset, width, height)
    local percent = offset/width
    page:translate(offset)
    page.alpha = 1-math.abs(percent)
    page:scale(1-math.abs(percent))

end
