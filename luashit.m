#include "luashit.h"
#include "lua/lauxlib.h"
#import "macros.h"

static lua_State *L = NULL;
static CATransform3D _transform = {1,0,0,0,0,1,0,0,0,0,1,-0.002,0,0,0,1};
static int func;
static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_transform_scale(lua_State *L);
static int l_uiview_index(lua_State *L);
static int l_uiview_setindex(lua_State *L);

NSString *THE_ERROR_LOL = nil;

void init_lua()
{
    if(L == NULL)
    {
        //create state
        L = luaL_newstate();

        //set globals
        /*lua_pushcfunction(L, l_transform_rotate);
        lua_setglobal(L, "ROTATE");
        lua_pushcfunction(L, l_transform_translate);
        lua_setglobal(L, "TRANSLATE");
        lua_pushcfunction(L, l_transform_scale);
        lua_setglobal(L, "SCALE");*/
        lua_pushlightuserdata(L, &_transform);
        lua_setglobal(L, "BASE");

        //set UIView metatable
        luaL_newmetatable(L, "UIView");
        lua_pushcfunction(L, l_uiview_index);
        lua_setfield(L, -2, "__index");

        lua_pushcfunction(L, l_uiview_setindex);
        lua_setfield(L, -2, "__newindex");
        

    }

    luaL_loadfile(L, "/Library/Cylinder/lol.lua");
    lua_pcall(L, 0, 1, 0);
    func = luaL_ref(L, LUA_REGISTRYINDEX);
    lua_pop(L, 1);


}
CATransform3D *default_transform()
{
    return &_transform;
}

void push_view(UIView *view)
{
    lua_pushlightuserdata(L, view);
    luaL_getmetatable(L, "UIView");
    lua_setmetatable(L, -2);
}

void manipulate(UIView *view, float width, float offset)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, func);

    push_view(view);
    lua_pushnumber(L, width);
    lua_pushnumber(L, offset);

    lua_pcall(L, 3, 1, 0);

    if(lua_isstring(L, -1))
    {
        [THE_ERROR_LOL release];
        THE_ERROR_LOL = [[NSString stringWithUTF8String:lua_tostring(L, -1)] retain];
    }
    lua_pop(L, 1);


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

int get_transform(UIView *self, lua_State *L, CATransform3D *transform)
{
    if(lua_isuserdata(L, 2))
    {
        *transform = *(CATransform3D *)lua_touserdata(L, 2);
        return 1;
    }
    else
    {
        *transform = self.layer.transform;
        return 0;
    }
}
static int l_uiview_setindex(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isstring(L, 2))
    {
        const char *key = lua_tostring(L, 2);
        if(!strcmp(key, "alpha"))
        {
            if(lua_isnumber(L, 3))
            {
                self.alpha = lua_tonumber(L, 3);
            }
        }
    }
    return 0;
}

static int l_uiview_index(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isnumber(L, 2)) //if it's a number, return the subview
    {
        int index = lua_tonumber(L, 2) - 1;
        if(index <= self.subviews.count)
        {
            push_view(self.subviews[index]);
            return 1;
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
                push_view(self.subviews[i]);
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
    }

    return 0;
}

static int l_transform_rotate(lua_State *L)
{
    if(!lua_isuserdata(L, 1)) return 0;

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);
    transform = CATransform3DRotate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2), lua_tonumber(L, first+3));
    self.layer.transform = transform;

    return 0;
}
static int l_transform_translate(lua_State *L)
{
    if(!lua_isuserdata(L, 1)) return 0;

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);
    transform = CATransform3DTranslate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));

    return 0;
}
static int l_transform_scale(lua_State *L)
{
    if(!lua_isuserdata(L, 1)) return 0;

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);

    transform = CATransform3DScale(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));
    self.layer.transform = transform;

    return 0;
}
