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

local id = ffi.typeof('id')
function scrol(self)
    self = id(self)
    for _,page in ipairs(objc.tolua(self:subviews())) do
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
