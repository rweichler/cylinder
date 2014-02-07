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
static int l_include(lua_State *L);

void write_error(const char *error);

void close_lua()
{
    if(L != NULL) lua_close(L);
    L = NULL;
}
BOOL init_lua(const char *script)
{
    BOOL success = true;

    //if we are reloading, close the state
    if(L != NULL) lua_close(L);

    //create state
    L = luaL_newstate();

    //set globals
    lua_pushlightuserdata(L, &_transform);
    lua_setglobal(L, "BASE");

    lua_pushcfunction(L, l_include);
    lua_setglobal(L, "include");

    //set UIView metatable
    luaL_newmetatable(L, "UIView");

    lua_pushcfunction(L, l_uiview_index);
    lua_setfield(L, -2, "__index");

    lua_pushcfunction(L, l_uiview_setindex);
    lua_setfield(L, -2, "__newindex");

    if(script == NULL) script = "Cube (inside)";

    char *path = (char *)malloc(sizeof(char)*(strlen(script) + 1 + strlen(CYLINDER_DIR) + 1 + 5));
    path[0] = '\0';
    strcat(path, CYLINDER_DIR);
    strcat(path, script);
    strcat(path, ".lua");

    //load our file and save the function we want to call
    if(luaL_loadfile(L, path) != LUA_OK || lua_pcall(L, 0, 1, 0) != 0)
    {
        write_error(lua_tostring(L, -1));
        lua_close(L);
        L = NULL;
        success = false;
    }
    else
    {
        func = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1);
    }

    free(path);

    return success;
}

static int l_include(lua_State *L)
{
    if(!lua_isstring(L, 1))
    {
        lua_pushstring(L, "argument must be a string");
        return lua_error(L);
    }
    const char *filename = lua_tostring(L, 1);
    const char *path = [@CYLINDER_DIR stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]].UTF8String;

    if(luaL_loadfile(L, path) != LUA_OK || lua_pcall(L, 0, 1, 0) != 0)
    {
        return luaL_error(L, "%s", lua_tostring(L, -1));
    }

    return 1;
}

#define LOG_DIR @"/var/mobile/Library/Logs/Cylinder/"
#define LOG_PATH LOG_DIR"errors.log"

void write_error(const char *error)
{
    if(![NSFileManager.defaultManager fileExistsAtPath:LOG_PATH isDirectory:nil])
    {
        if(![NSFileManager.defaultManager fileExistsAtPath:LOG_DIR isDirectory:nil])
            [NSFileManager.defaultManager createDirectoryAtPath:LOG_DIR withIntermediateDirectories:false attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:LOG_PATH contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:LOG_PATH];
    [fileHandle seekToEndOfFile];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"[yyyy-MM-dd HH:mm:ss] "];
    NSString *dateStr = [dateFormatter stringFromDate:NSDate.date];

    [fileHandle writeData:[dateStr dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle writeData:[NSData dataWithBytes:error length:(strlen(error) + 1)]];
    [fileHandle writeData:[NSData dataWithBytes:"\n" length:2]];
    [fileHandle closeFile];
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
    if(L == NULL) return;

    lua_rawgeti(L, LUA_REGISTRYINDEX, func);

    push_view(view);
    lua_pushnumber(L, width);
    lua_pushnumber(L, offset);

    if(lua_pcall(L, 3, 1, 0) != 0)
    {
        write_error(lua_tostring(L, -1));
    }
    lua_pop(L, 1);

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
        if(index < self.subviews.count)
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

#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX)) \
    { \
        lua_pushstring(STATE, "first argument must be a view"); \
        return lua_error(STATE); \
    }


static int l_transform_rotate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);
    transform = CATransform3DRotate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2), lua_tonumber(L, first+3));
    self.layer.transform = transform;

    return 0;
}
static int l_transform_translate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);
    transform = CATransform3DTranslate(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));

    return 0;
}
static int l_transform_scale(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform;
    int first = 2 + get_transform(self, L, &transform);

    transform = CATransform3DScale(transform, lua_tonumber(L, first), lua_tonumber(L, first+1), lua_tonumber(L, first+2));
    self.layer.transform = transform;

    return 0;
}
