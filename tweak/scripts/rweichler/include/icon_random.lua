
local rand = nil
local view_order = nil

local function randomize(tbl)

    --use the same random seed every time
    if not rand then
        rand = math.random(1, 8297094)
    end

    for i=1,#tbl-1 do
        local rand_index = i + rand % (#tbl - i + 1)

        local tmp = tbl[i]
        tbl[i] = tbl[rand_index]
        tbl[rand_index] = tmp
    end

end

local function init(len)

    if not view_order or len > #view_order then
        view_order = {}
        for i=1,len do
            table.insert(view_order, i)
        end
        randomize(view_order)
    end
end

local function make_progress_table(mag, max)
    local inc = (1 - mag)/(max - 1)
    local first = mag/2
    local tbl = {}
    for i=0,max-1 do
        table.insert(tbl, first + inc*i)
    end
    return tbl
end

return function(page, percent, mag, callback)
    init(#page)
    local max = #view_order

    if mag < 1/max then mag = 1/max end
    if mag > 1 then mag = 1 end

    local negative = percent < 0

    if negative then
        percent = -percent
    end

    local progress_table = make_progress_table(mag, max)
    for i, prog in ipairs(progress_table) do
        if negative then
            i = #progress_table - i + 1
        end
        local icon = page[view_order[i]]
        if not icon then
        elseif percent < prog - mag/2 then
            callback(icon, 0)
        elseif percent > prog + mag/2 then
            callback(icon, negative and -1 or 1)
        else
            local p = (percent - prog + mag/2)/mag
            if negative then
                p = -p
            end
            callback(icon, p)
        end
    end

end
