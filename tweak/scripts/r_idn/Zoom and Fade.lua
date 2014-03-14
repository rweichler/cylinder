--ridn
return function(page, offset, width, height)
    local percent = offset/width
    page:translate(offset)
    page.alpha = 1-math.abs(percent)
    if (percent > 0) then percent = percent*5 end
    page:scale(1+percent)

end
