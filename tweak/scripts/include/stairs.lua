return function(view, percent, left)
    local x = -percent*20
    local z = percent*100
    if left then z = -z end
    view:translate(x, 0, z)
end
