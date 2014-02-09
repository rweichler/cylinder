return function(view, percent, left)
    if left then percent = -percent end
    view:translate(percent*20, 0, percent*100)
end
