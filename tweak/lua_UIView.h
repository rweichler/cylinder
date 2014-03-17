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
#import "CALayer+Cylinder.h"

#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX) || ![(NSObject *)lua_touserdata(STATE, INDEX) isKindOfClass:UIView.class]) \
        return luaL_error(STATE, "first argument must be a view")

//this allows a 3D perspective, sometimes this value is needed
//for transformations that translate, THEN rotate. (like cube,
//page flip, etc)
#define PERSPECTIVE_DISTANCE 500.0

int l_create_uiview_metatable(lua_State *L);
int l_push_base_transform(lua_State *L);
int l_push_view(lua_State *L, id view);
