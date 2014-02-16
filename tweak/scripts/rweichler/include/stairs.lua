return function(view, percent, is_going_left)
    local x = -percent*20
    local z = percent*100
    if is_going_left then z = -z end
    view:translate(x, 0, z)
end
