#include "luashit.h"
#include "lua/lauxlib.h"
#import "macros.h"

static lua_State *L;
static CATransform3D _transform = {1,0,0,0,0,1,0,0,0,0,1,-0.002,0,0,0,1};
static int func;
static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_transform_scale(lua_State *L);

void init_lua()
{
    L = luaL_newstate();
    lua_pushcfunction(L, l_transform_rotate);
    lua_setglobal(L, "ROTATE");
    lua_pushcfunction(L, l_transform_translate);
    lua_setglobal(L, "TRANSLATE");
    lua_pushcfunction(L, l_transform_scale);
    lua_setglobal(L, "SCALE");
    lua_pushlightuserdata(L, (void *)(&_transform));
    lua_setglobal(L, "BASE");

    luaL_loadfile(L, "/Library/Cylinder/lol.lua");
    lua_pcall(L, 0, 1, 0);
    func = luaL_ref(L, LUA_REGISTRYINDEX);
    //float percent = -offset/SCREEN_SIZE.width;
    //float angle = percent*M_PI/2;

    //view.layer.transform = CATransform3DRotate(_transform, angle, 0, 1, 0);
}

CATransform3D *transform_me(float width, float offset)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, func);
    lua_pushnumber(L, width);
    lua_pushnumber(L, offset);
    lua_pcall(L, 2, 1, 0);
    if(!lua_isuserdata(L, -1))
    {
        lua_pop(L, 1);
        return NULL;
    }
    CATransform3D *transform = (CATransform3D *)lua_touserdata(L, -1);
    lua_pop(L, 1);
    return transform;
}

int get_transform(lua_State *L, CATransform3D *transform)
{
    if(lua_isuserdata(L, 1))
    {
        transform = (CATransform3D *)lua_touserdata(L,1);
        return 1;
    }
    else
    {
        *transform = _transform;
        return 0;
    }
}

static int l_transform_rotate(lua_State *L)
{
    CATransform3D transform;
    int first = 1 + get_transform(L, &transform);
    transform = CATransform3DRotate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2), lua_tonumber(L, first+3));

    lua_pushlightuserdata(L, &transform);
    return 1;
}
static int l_transform_translate(lua_State *L)
{
    CATransform3D transform;
    int first = 1 + get_transform(L, &transform);
    transform = CATransform3DTranslate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));

    lua_pushlightuserdata(L, &transform);
    return 1;
}
static int l_transform_scale(lua_State *L)
{
    CATransform3D transform;
    int first = 1 + get_transform(L, &transform);
    transform = CATransform3DScale(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));

    lua_pushlightuserdata(L, &transform);
    return 1;
}
