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
#import "tweak.h"
#import "lua_UIView_index.h"

static int l_set_transform(lua_State *L, CALayer *self); //-1 = transform

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
            return l_push_transform(L, self.transform);
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
const static unsigned int MATRIX_SIZE = 16;
inline CGFloat * get_matrix(CATransform3D *transform, unsigned int i)
{
    switch(i) {
    case 0:  return &transform->m11;
    case 1:  return &transform->m12;
    case 2:  return &transform->m13;
    case 3:  return &transform->m21;

    case 4:  return &transform->m21;
    case 5:  return &transform->m22;
    case 6:  return &transform->m23;
    case 7:  return &transform->m34;

    case 8:  return &transform->m31;
    case 9:  return &transform->m32;
    case 10: return &transform->m33;
    case 11: return &transform->m34;

    case 12: return &transform->m41;
    case 13: return &transform->m42;
    case 14: return &transform->m43;
    case 15: return &transform->m44;
    }
    return NULL;
}

static int l_set_transform(lua_State *L, CALayer *self) //-1 = transform
{
    if(!lua_istable(L, -1))
        return luaL_error(L, "transform must be a table");
    lua_len(L, -1);
    if(lua_tonumber(L, -1) != 16)
        return luaL_error(L, ERR_MALFORMED);
    lua_pop(L, 1);

    CATransform3D transform;
    for(unsigned int i = 0; i < MATRIX_SIZE; i++) {
        CGFloat *val = get_matrix(&transform, i);

        lua_pushnumber(L, i + 1);
        lua_gettable(L, -3);
        if(!lua_isnumber(L, -1)) {
            return luaL_error(L, ERR_MALFORMED);
        }
        *val = lua_tonumber(L, -1);
        CHECK_NAN(*val, "transform[%d]", i);
        lua_pop(L, 1);
    }
    self.transform = transform;

    return 0;
}

int l_push_transform(lua_State *L, CATransform3D transform) //pushes transform to top of stack
{
    lua_newtable(L);
    for(unsigned int i = 0; i < MATRIX_SIZE; i++) {
        CGFloat *val = get_matrix(&transform, i);

        lua_pushnumber(L, i + 1);
        lua_pushnumber(L, *val);
        lua_settable(L, -3);
    }
    return 1;
}

