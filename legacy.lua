ffi.cdef[[
typedef double CGFloat;
struct CGPoint {
    CGFloat x, y;
};
struct CGSize {
    CGFloat width, height;
};
struct CGRect {
    struct CGPoint origin;
    struct CGSize size;
};
struct CATransform3D
{
  CGFloat m11, m12, m13, m14,
          m21, m22, m23, m24,
          m31, m32, m33, m34,
          m41, m42, m43, m44;
};

struct CATransform3D CATransform3DRotate(struct CATransform3D t, CGFloat angle, CGFloat pitch, CGFloat yaw, CGFloat roll);
struct CATransform3D CATransform3DTranslate(struct CATransform3D t, CGFloat x, CGFloat y, CGFloat z);
struct CATransform3D CATransform3DScale(struct CATransform3D t, CGFloat x, CGFloat y, CGFloat z);
]]

local LEGACY

function subviews(t)
    local i = 0
    local n = #t
    return function()
        i = i + 1
        if i <= n then return i, t[i] end
    end
end

SCREEN = objc.UIScreen:mainScreen():bounds().size
PERSPECTIVE_DISTANCE = (SCREEN.width + SCREEN.height)/2

-- transform functions

local f = {}
function f.translate(self, x, y, z)
    local t = self.layer.m:transform()

    if not(z == 0) then
        t.m34 = -1/PERSPECTIVE_DISTANCE
    end

    t = C.CATransform3DTranslate(t, x, y, z)

    self.layer.m:setTransform(t)
end
function f.rotate(self, angle, pitch, yaw, roll)
    local t = self.layer.m:transform()

    if not(pitch == 0 and yaw == 0) then
        t.m34 = -1/PERSPECTIVE_DISTANCE
    end

    if not pitch then
        t = C.CATransform3DRotate(t, angle, 0, 0, 1)
    else
        t = C.CATransform3DRotate(t, angle, pitch, yaw, roll)
    end

    self.layer.m:setTransform(t)
end
function f.scale(self, x, y, z)
    local t = self.layer.m:transform()
    local m34 = transform.m34
    t.m34 = -1/PERSPECTIVE_DISTANCE
    t = C.CATransform3DScale(t, x, y, z)
    t.m34 = m34

    self.layer.m:setTransform(t)
end

-- UIView

local pagemt = {}
pagemt.__index = function(self, k)
    if type(k) == 'number' then
        local m = self.m:subviews():objectAtIndex(k - 1)
        return m and LEGACY(m)
    elseif k == 'width' then
        return self.m:frame().size.width
    elseif k == 'height' then
        return self.m:frame().size.height
    elseif k == 'x' then
        return self.m:frame().origin.x
    elseif k == 'y' then
        return self.m:frame().origin.y
    elseif k == 'alpha' then
        return self.m:alpha()
    elseif f[k] then
        return f[k]
    end
end
pagemt.__newindex = function(self, k, v)
    if k == 'alpha' then
        self.m:setAlpha(v)
    else
        rawset(self, k, v)
    end
end
pagemt.__len = function(self)
    return tonumber(self.m:subviews():count())
end

-- CALayer

local layermt = {}
layermt.__index = function(self, k)
    if k == 'x' then
        return self.m:position().x
    end
end
layermt.__newindex = function(self, k, v)
    if k == 'x' then
        if not self.old_pos then
            self.old_pos = self.m:position()
        end
        local pos = self.m:position()
        pos.x = v
        self.m:setPosition(pos)
    else
        rawset(self, k, v)
    end
end

-- Lua

local uintptr_t = ffi.typeof('uintptr_t')
local hash = {}
LEGACY = function(m) -- m is the objective-c object
    local key = tonumber(ffi.cast(uintptr_t, m) % 2^32)
    if hash[key] then
        return hash[key]
    end

    local self = {}
    self.m = m

    self.layer = {}
    self.layer.m = m:layer()

    setmetatable(self.layer, layermt)
    setmetatable(self, pagemt)

    hash[key] = self
    return self
end

return LEGACY
