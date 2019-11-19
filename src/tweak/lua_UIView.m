#import <lua/lua.h>
#import <lua/lauxlib.h>
#import "lua_UIView.h"
#import "UIView+Cylinder.h"
#import "tweak.h"
#import "lua_UIView_index.h"

static int l_set_transform(lua_State *L, CALayer *self); //-1 = transform
static int l_get_transform(lua_State *L, CALayer *self); //pushes transform to top of stack

static int l_nsobject_index(lua_State *L);
static int l_nsobject_setindex(lua_State *L);
static int l_nsobject_len(lua_State *L);

static int  _layerIndexTable;

int l_push_view(lua_State *L, id view)
{
    lua_pushlightuserdata(L, view);
    luaL_getmetatable(L, "nsobject");
    lua_setmetatable(L, -2);
    return 1;
}

int l_create_uiview_metatable(lua_State *L)
{
    luaL_newmetatable(L, "nsobject");

    lua_pushcfunction(L, l_nsobject_index);
    lua_setfield(L, -2, "__index");

    lua_pushcfunction(L, l_nsobject_setindex);
    lua_setfield(L, -2, "__newindex");

    lua_pushcfunction(L, l_nsobject_len);
    lua_setfield(L, -2, "__len");

    lua_pop(L, 1);

    l_create_viewindextable(L);
    return 0;
}

static int l_calayer_index(lua_State *L)
{
    CALayer *self = (CALayer *)lua_touserdata(L, 1);
    if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);

        if(!strcmp(key, "x"))
        {
            lua_pushnumber(L, self.position.x);
            return 1;
        }
        else if(!strcmp(key, "y"))
        {
            lua_pushnumber(L, self.position.y);
            return 1;
        }
        else if(!strcmp(key, "width"))
        {
            lua_pushnumber(L, self.bounds.size.width);
            return 1;
        }
        else if(!strcmp(key, "height"))
        {
            lua_pushnumber(L, self.bounds.size.height);
            return 1;
        }
        else if(!strcmp(key, "transform"))
        {
            return l_get_transform(L, self);
        }
    }

    return 0;
}

static int l_nsobject_index(lua_State *L)
{
    id self = (id)lua_touserdata(L, 1);
    if([self isKindOfClass:UIView.class])
        return l_uiview_index(L);
    else if([self isKindOfClass:CALayer.class])
        return l_calayer_index(L);

    return 0;
}

static int l_uiview_setindex(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);
        if(!strcmp(key, "alpha"))
        {
            if(!lua_isnumber(L, 3))
                return luaL_error(L, LUA_QL("alpha")" must be a number");

            float alpha = lua_tonumber(L, 3);

            CHECK_NAN(alpha, LUA_QL("alpha"));

            self.alpha = lua_tonumber(L, 3);
            self.wasModifiedByCylinder = true;
        }
    }
    return 0;
}

static int l_calayer_setindex(lua_State *L)
{
    CALayer *self = (CALayer *)lua_touserdata(L, 1);
    UIView *view = (UIView *)self.delegate;
    if(![view isKindOfClass:UIView.class])
    {
        view = nil;
    }

    if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);

        if(!strcmp(key, "x"))
        {
            if(!lua_isnumber(L, 3)) return luaL_error(L, LUA_QL("x") " must be a number");

            float x = lua_tonumber(L, 3);
            CHECK_NAN(x, LUA_QL("x"));

            [self savePosition];
            CGPoint pos = self.position;
            pos.x = x;
            self.position = pos;
            view.wasModifiedByCylinder = true;
        }
        else if(!strcmp(key, "y"))
        {
            if(!lua_isnumber(L, 3)) return luaL_error(L, LUA_QL("y") " must be a number");

            float y = lua_tonumber(L, 3);
            CHECK_NAN(y, LUA_QL("y"));

            [self savePosition]; //TODO implement this and resetPosition.... prolly needa refactor some shit
            CGPoint pos = self.position;
            pos.y = y;
            self.position = pos;
            view.wasModifiedByCylinder = true;
        }
        else if(!strcmp(key, "transform"))
        {
            lua_pushvalue(L, 3);
            int result = l_set_transform(L, self);
            lua_pop(L, 1);
            return result;
            view.wasModifiedByCylinder = true;
        }
    }
    return 0;
}

static int l_nsobject_setindex(lua_State *L)
{
    id self = (id)lua_touserdata(L, 1);
    if([self isKindOfClass:UIView.class])
        return l_uiview_setindex(L);
    else if([self isKindOfClass:CALayer.class])
        return l_calayer_setindex(L);

    return 0;
}

static int l_uiview_len(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    lua_pushnumber(L, self.subviews.count);
    return 1;
}

static int l_nsobject_len(lua_State *L)
{
    id self = (id)lua_touserdata(L, 1);
    if([self isKindOfClass:UIView.class])
        return l_uiview_len(L);

    return 0;
}

const static char *ERR_MALFORMED = "malformed transformation matrix";

#define CALL_TRANSFORM_MACRO(F, ...) do {\
    F(m11, ## __VA_ARGS__);\
    F(m12, ## __VA_ARGS__);\
    F(m13, ## __VA_ARGS__);\
    F(m14, ## __VA_ARGS__);\
    F(m21, ## __VA_ARGS__);\
    F(m22, ## __VA_ARGS__);\
    F(m23, ## __VA_ARGS__);\
    F(m24, ## __VA_ARGS__);\
    F(m31, ## __VA_ARGS__);\
    F(m32, ## __VA_ARGS__);\
    F(m33, ## __VA_ARGS__);\
    F(m34, ## __VA_ARGS__);\
    F(m41, ## __VA_ARGS__);\
    F(m42, ## __VA_ARGS__);\
    F(m43, ## __VA_ARGS__);\
    F(m44, ## __VA_ARGS__);\
} while(0)

#define BASE_TRANSFORM_STEP(M, LUASTATE, I, TRANSFORM) do{\
    lua_pushnumber(LUASTATE, ++I);\
    lua_pushnumber(LUASTATE, TRANSFORM.M);\
    lua_settable(LUASTATE, -3);\
} while(0)

int l_push_base_transform(lua_State *L)
{
    int i = 0;
    CALL_TRANSFORM_MACRO(BASE_TRANSFORM_STEP, L, i, CATransform3DIdentity);
    return 1;
}

#define FILL_TRANSFORM(M, LUASTATE, I, TRANSFORM) do{\
    lua_pushnumber(LUASTATE, ++I);\
    lua_gettable(LUASTATE, -3);\
    if(!lua_isnumber(LUASTATE, -1))\
        return luaL_error(LUASTATE, ERR_MALFORMED);\
    TRANSFORM.M = lua_tonumber(LUASTATE, -1);\
    CHECK_NAN(TRANSFORM.M, "the "#M" of the transform");\
    lua_pop(LUASTATE, 1);\
} while(0)

static int l_set_transform(lua_State *L, CALayer *self) //-1 = transform
{
    if(!lua_istable(L, -1))
        return luaL_error(L, "transform must be a table");
#ifdef LUA_OK
    lua_len(L, -1);
#else
    lua_objlen(L, -1);
#endif
    if(lua_tonumber(L, -1) != 16)
        return luaL_error(L, ERR_MALFORMED);
    lua_pop(L, 1);

    CATransform3D transform;
    int i = 0;
    CALL_TRANSFORM_MACRO(FILL_TRANSFORM, L, i, transform);
    self.transform = transform;

    return 0;
}

#define PUSH_TRANSFORM(M, LUASTATE, I, TRANSFORM)\
    lua_pushnumber(LUASTATE, ++I);\
    lua_pushnumber(LUASTATE, TRANSFORM.M);\
    lua_settable(LUASTATE, -3)

static int l_get_transform(lua_State *L, CALayer *self) //pushes transform to top of stack
{
    lua_newtable(L);
    int i = 0;
    CALL_TRANSFORM_MACRO(PUSH_TRANSFORM, L, i, self.transform);
    return 1;
}

