/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <lua/lua.h>
#import <lua/lauxlib.h>
#import "lua_UIView.h"
#import "UIView+Cylinder.h"

static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_transform_scale(lua_State *L);
static int l_set_transform(lua_State *L, CALayer *self); //-1 = transform
static int l_get_transform(lua_State *L, CALayer *self); //pushes transform to top of stack

static int l_nsobject_index(lua_State *L);
static int l_nsobject_setindex(lua_State *L);
static int l_nsobject_len(lua_State *L);

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

static int l_uiview_index(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isnumber(L, 2)) //if it's a number, return the subview
    {
        int index = lua_tonumber(L, 2) - 1;
        if(index >= 0 && index < self.subviews.count)
        {
            return l_push_view(L, [self.subviews objectAtIndex:index]);
        }
    }
    else if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);

        if(!strcmp(key, "subviews"))
        {
            lua_newtable(L);
            for(int i = 0; i < self.subviews.count; i++)
            {
                lua_pushnumber(L, i+1);
                l_push_view(L, [self.subviews objectAtIndex:i]);
                lua_settable(L, -3);
            }
            return 1;
        }
        else if(!strcmp(key, "alpha"))
        {
            lua_pushnumber(L, self.alpha);
            return 1;
        }
        else if(!strcmp(key, "rotate"))
        {
            lua_pushcfunction(L, l_transform_rotate);
            return 1;
        }
        else if(!strcmp(key, "translate"))
        {
            lua_pushcfunction(L, l_transform_translate);
            return 1;
        }
        else if(!strcmp(key, "scale"))
        {
            lua_pushcfunction(L, l_transform_scale);
            return 1;
        }
        else if(!strcmp(key, "x"))
        {
            self.isOnScreen = false;
            lua_pushnumber(L, self.frame.origin.x);
            self.isOnScreen = true;
            return 1;
        }
        else if(!strcmp(key, "y"))
        {
            self.isOnScreen = false;
            lua_pushnumber(L, self.frame.origin.y);
            self.isOnScreen = true;
            return 1;
        }
        else if(!strcmp(key, "width"))
        {
            self.isOnScreen = false;
            lua_pushnumber(L, self.frame.size.width);
            self.isOnScreen = true;
            return 1;
        }
        else if(!strcmp(key, "height"))
        {
            self.isOnScreen = false;
            lua_pushnumber(L, self.frame.size.height);
            self.isOnScreen = true;
            return 1;
        }
        else if(!strcmp(key, "max_icons"))
        {
            SEL selector = @selector(maxIcons);
            if([self.class respondsToSelector:selector])
            {
                lua_pushnumber(L, invoke_int(self.class, selector, false));
                return 1;
            }
        }
        else if(!strcmp(key, "max_columns"))
        {
            SEL selector = @selector(iconColumnsForInterfaceOrientation:);
            if([self.class respondsToSelector:selector])
            {
                lua_pushnumber(L, invoke_int(self.class, selector, true));
                return 1;
            }
        }
        else if(!strcmp(key, "max_rows"))
        {
            SEL selector = @selector(iconRowsForInterfaceOrientation:);
            if([self.class respondsToSelector:selector])
            {
                lua_pushnumber(L, invoke_int(self.class, selector, true));
                return 1;
            }
        }
        else if(!strcmp(key, "layer"))
        {
            self.isOnScreen = true;
            return l_push_view(L, self.layer);
        }
    }

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
                return luaL_error(L, "alpha must be a number");

            self.alpha = lua_tonumber(L, 3);
            self.isOnScreen = true;
        }
    }
    return 0;
}

static int l_calayer_setindex(lua_State *L)
{
    CALayer *self = (CALayer *)lua_touserdata(L, 1);
    if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);

        if(!strcmp(key, "x"))
        {
            if(!lua_isnumber(L, 3)) return luaL_error(L, LUA_QL("x") " must be a number");
            [self savePosition];
            CGPoint pos = self.position;
            pos.x = lua_tonumber(L, 3);
            self.position = pos;
        }
        else if(!strcmp(key, "y"))
        {
            if(!lua_isnumber(L, 3)) return luaL_error(L, LUA_QL("y") " must be a number");
            [self savePosition]; //TODO implement this and resetPosition.... prolly needa refactor some shit
            CGPoint pos = self.position;
            pos.y = lua_tonumber(L, 3);
            self.position = pos;
        }
        else if(!strcmp(key, "transform"))
        {
            lua_pushvalue(L, 3);
            int result = l_set_transform(L, self);
            lua_pop(L, 1);
            return result;
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


static int l_transform_rotate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);
    self.isOnScreen = true;

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
    self.isOnScreen = true;

    CATransform3D transform = self.layer.transform;
    float x = lua_tonumber(L, 2), y = lua_tonumber(L, 3), z = lua_tonumber(L, 4);
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
    self.isOnScreen = true;

    CATransform3D transform = self.layer.transform;
    float x = lua_tonumber(L, 2);
    float y = x;
    float z = 1;
    if(lua_isnumber(L, 3))
        y = lua_tonumber(L, 3);
    if(lua_isnumber(L, 4))
        z = lua_tonumber(L, 4);
    float oldm34 = transform.m34;
    transform.m34 = -1/PERSPECTIVE_DISTANCE;
    transform = CATransform3DScale(transform, x, y, z);
    transform.m34 = oldm34;

    self.layer.transform = transform;

    return 0;
}

const static char *ERR_MALFORMED = "malformed transformation matrix";

static float POPA_T(lua_State *L, int index)
{
    lua_pushnumber(L, index);
    lua_gettable(L, -2);
    if(!lua_isnumber(L, -1))
        return luaL_error(L, ERR_MALFORMED);

    float result = lua_tonumber(L, -1);
    lua_pop(L, 1);
    return result;
}

#define CALL_TRANSFORM_MACRO(F, ...)\
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
    F(m44, ## __VA_ARGS__)

#define BASE_TRANSFORM_STEP(M, LUASTATE, I, TRANSFORM)\
    lua_pushnumber(LUASTATE, ++I);\
    lua_pushnumber(LUASTATE, TRANSFORM.M);\
    lua_settable(LUASTATE, -3)

int l_push_base_transform(lua_State *L)
{
    int i = 0;
    CALL_TRANSFORM_MACRO(BASE_TRANSFORM_STEP, L, i, CATransform3DIdentity);
    return 1;
}

#define FILL_TRANSFORM(M, LUASTATE, I, TRANSFORM)\
    lua_pushnumber(LUASTATE, ++I);\
    lua_gettable(LUASTATE, -3);\
    if(!lua_isnumber(LUASTATE, -1))\
        return luaL_error(LUASTATE, ERR_MALFORMED);\
    TRANSFORM.M = lua_tonumber(LUASTATE, -1);\
    lua_pop(LUASTATE, 1)

static int l_set_transform(lua_State *L, CALayer *self) //-1 = transform
{
    if(!lua_istable(L, -1))
        return luaL_error(L, "transform must be a table");
    lua_len(L, -1);
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

