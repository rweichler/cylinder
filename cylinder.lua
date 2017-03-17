local LEGACY = require '/var/root/tmp/legacy'

identity = ffi.new('struct CATransform3D',
                    {   1, 0, 0, 0,
                        0, 1, 0, 0,
                        0, 0, 1, 0,
                        0, 0, 0, 1,
                    })

local effect = dofile '/var/lua/cylinder/rweichler/Spin.lua'

local function reset(view)
    view.layer.m:setTransform(identity)
    if view.layer.old_pos then
        view.layer.m:setPosition(view.layer.old_pos)
        view.layer.old_pos = nil
    end
end

function scrol(self)
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
