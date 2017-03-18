local LEGACY = require 'legacy'

identity = ffi.new('struct CATransform3D',
                    {   1, 0, 0, 0,
                        0, 1, 0, 0,
                        0, 0, 1, 0,
                        0, 0, 0, 1,
                    })

local function effect(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    local angle = percent*math.pi*2

    for i, icon in subviews(page) do
        icon:rotate(angle)
    end
end

local function reset(view)
    view.layer.m:setTransform(identity)
    if view.layer.old_pos then
        view.layer.m:setPosition(view.layer.old_pos)
        view.layer.old_pos = nil
    end
end

function scrol(self)
    local views = self:subviews()
    local count = tonumber(views:count())
    for i=0,count-1 do
        local page = views:objectAtIndex(i)
        if page:isKindOfClass(objc.SBIconListView) then
            local page = LEGACY(page)

            reset(page)
            for i,icon in subviews(page) do
                reset(icon)
            end

            local x = self:contentOffset().x - page.x
            effect(page, x, SCREEN.width, SCREEN.height)
        end
    end
end
