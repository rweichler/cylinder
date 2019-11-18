#import "lua_UIView.h"
#import "lua_UIView_index.h"
#import "UIView+Cylinder.h"
#import "tweak.h"
#import "icon_sort.h"
#import "luashit.h"

static int _viewIndexTable;

static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_transform_scale(lua_State *L);

int l_uiview_index(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isnumber(L, 2)) //if it's a number, return the subview
    {
        if(![self isKindOfClass:_listClass]) {
            return luaL_error(L, "trying to get icon from object that is not a list");
        }
        int index = lua_tonumber(L, 2) - 1;
        if(index >= 0 && index < get_max_icons_for_list(self))
        {
            UIView *view = get_sorted_icons_from_list(self)[index];
            if(view != NULL) {
                return l_push_view(L, view);
            }
        }
    }
    else if(lua_isstring(L, 2))
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, _viewIndexTable);
        int lastStackTop = lua_gettop(L);
        lua_pushvalue(L, 2);
        lua_gettable(L, -2);
        lua_pushvalue(L, 1);
        lua_call(L, 1, LUA_MULTRET);
        int diff = lua_gettop(L) - lastStackTop;
        return diff;
    }

    return 0;
}


//screw good practice, i dont have time for casting and
//private header files
static int invoke_int(id self, SEL selector, BOOL use_orientation)
{
    IMP imp = [self methodForSelector:selector];
    if(use_orientation)
    {
        typedef int (*functype)(id, SEL, UIDeviceOrientation);
        return ((functype)imp)(self, selector, UIDevice.currentDevice.orientation);
    }
    else
    {
        typedef int (*functype)(id, SEL);
        return ((functype)imp)(self, selector);
    }
}

static int l_uiview_index_subviews(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(![self isKindOfClass:_listClass]) {
        return luaL_error(L, "trying to get icon from object that is not a list");
    }
    UIView **views = get_sorted_icons_from_list(self);
    lua_newtable(L);
    for(int i = 0; views[i] != NULL; i++)
    {
        lua_pushnumber(L, i+1);
        l_push_view(L, views[i]);
        lua_settable(L, -3);
    }
    return 1;
}

static int l_uiview_index_alpha(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    lua_pushnumber(L, self.alpha);
    return 1;
}

static int l_uiview_index_rotate(lua_State *L)
{
    lua_pushcfunction(L, l_transform_rotate);
    return 1;
}

static int l_uiview_index_translate(lua_State *L)
{
    lua_pushcfunction(L, l_transform_translate);
    return 1;
}

static int l_uiview_index_scale(lua_State *L)
{
    lua_pushcfunction(L, l_transform_scale);
    return 1;
}

static int l_uiview_index_x(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    BOOL old = self.wasModifiedByCylinder;
    self.wasModifiedByCylinder = false;
    lua_pushnumber(L, self.frame.origin.x);
    self.wasModifiedByCylinder = old;
    return 1;
}

static int l_uiview_index_y(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    BOOL old = self.wasModifiedByCylinder;
    self.wasModifiedByCylinder = false;
    lua_pushnumber(L, self.frame.origin.y);
    self.wasModifiedByCylinder = old;
    return 1;
}

static int l_uiview_index_width(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    BOOL old = self.wasModifiedByCylinder;
    self.wasModifiedByCylinder = false;
    lua_pushnumber(L, self.frame.size.width/self.layer.transform.m11);
    self.wasModifiedByCylinder = old;
    return 1;
}

static int l_uiview_index_height(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    BOOL old = self.wasModifiedByCylinder;
    self.wasModifiedByCylinder = false;
    lua_pushnumber(L, self.frame.size.height/self.layer.transform.m22);
    self.wasModifiedByCylinder = old;
    return 1;
}

static int l_uiview_index_max_icons(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    id obj;
    SEL selector;
    if(IOS_VERSION >= 13) {
        obj = self;
        selector = @selector(maximumIconCount);
    } else {
        obj = self.class;
        selector = @selector(maxIcons);
    }
    if([obj respondsToSelector:selector])
    {
        lua_pushnumber(L, invoke_int(obj, selector, false));
        return 1;
    }

    return 0;
}

static int l_uiview_index_max_columns(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    SEL selector = @selector(iconColumnsForCurrentOrientation);
    if([self respondsToSelector:selector])
    {
        lua_pushnumber(L, invoke_int(self, selector, false));
        return 1;
    }

    return 0;
}

static int l_uiview_index_max_rows(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    SEL selector = @selector(iconRowsForCurrentOrientation);
    if([self respondsToSelector:selector])
    {
        lua_pushnumber(L, invoke_int(self, selector, false));
        return 1;
    }

    return 0;
}

static int l_uiview_index_layer(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    self.wasModifiedByCylinder = true;
    return l_push_view(L, self.layer);
}

#define PUSH_FUNC(X) do {                       \
    lua_pushstring(L, #X);                      \
    lua_pushcfunction(L, l_uiview_index_##X);   \
    lua_settable(L, -3);                        \
} while(0)

void l_create_viewindextable(lua_State *L)
{
    lua_newtable(L);
    PUSH_FUNC(subviews);
    PUSH_FUNC(alpha);
    PUSH_FUNC(rotate);
    PUSH_FUNC(translate);
    PUSH_FUNC(scale);
    PUSH_FUNC(x);
    PUSH_FUNC(y);
    PUSH_FUNC(width);
    PUSH_FUNC(height);
    PUSH_FUNC(max_icons);
    PUSH_FUNC(max_columns);
    PUSH_FUNC(max_rows);
    PUSH_FUNC(layer);
    _viewIndexTable = luaL_ref(L, LUA_REGISTRYINDEX);
}

static int l_transform_rotate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);
    self.wasModifiedByCylinder = true;

    CATransform3D transform = self.layer.transform;
    float pitch = 0, yaw = 0, roll = 0;
    if(!lua_isnumber(L, 3))
        roll = 1;
    else
    {
        pitch = lua_tonumber(L, 3);
        yaw = lua_tonumber(L, 4);
        roll = lua_tonumber(L, 5);
    }

    CHECK_NAN(pitch, "the pitch of the rotation");
    CHECK_NAN(yaw, "the yaw of the rotation");
    CHECK_NAN(roll, "the roll of the rotation");

    if(fabs(pitch) > 0.01 || fabs(yaw) > 0.01)
        transform.m34 = -1/PERSPECTIVE_DISTANCE;

    transform = CATransform3DRotate(transform, lua_tonumber(L, 2), pitch, yaw, roll);

    self.layer.transform = transform;

    return 0;
}

static int l_transform_translate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);
    self.wasModifiedByCylinder = true;

    CATransform3D transform = self.layer.transform;
    float x = lua_tonumber(L, 2), y = lua_tonumber(L, 3), z = lua_tonumber(L, 4);

    CHECK_NAN(x, "the x value for the translation");
    CHECK_NAN(y, "the y value for the translation");
    CHECK_NAN(z, "the z value for the translation");

    float oldm34 = transform.m34;
    if(fabs(z) > 0.01)
        transform.m34 = -1/PERSPECTIVE_DISTANCE;
    transform = CATransform3DTranslate(transform, x, y, z);
    transform.m34 = oldm34;

    self.layer.transform = transform;

    return 0;
}

static int l_transform_scale(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);
    self.wasModifiedByCylinder = true;

    CATransform3D transform = self.layer.transform;
    float x = lua_tonumber(L, 2);
    float y = lua_isnumber(L, 3) ? lua_tonumber(L, 3) : x;
    float z = lua_isnumber(L, 4) ? lua_tonumber(L, 4) : 1;

    CHECK_NAN(x, "the x value for the scale");
    CHECK_NAN(y, "the y value for the scale");
    CHECK_NAN(z, "the z value for the scale");

    float oldm34 = transform.m34;
    transform.m34 = -1/PERSPECTIVE_DISTANCE;
    transform = CATransform3DScale(transform, x, y, z);
    transform.m34 = oldm34;

    self.layer.transform = transform;

    return 0;
}
