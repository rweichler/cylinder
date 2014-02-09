#import "luashit.h"
#import "lua/lauxlib.h"
#import "macros.h"
#import "UIView+Cylinder.h"

#define LOG_DIR @"/var/mobile/Library/Logs/Cylinder/"
#define LOG_PATH LOG_DIR"errors.log"

static lua_State *L = NULL;
const char *_script;
static int func;
static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_uiview_index(lua_State *L);
static int l_uiview_setindex(lua_State *L);
static int l_include(lua_State *L);

void write_error(const char *error);

void post_notification(const char *script, BOOL broken)
{
    if(script != NULL)
    {
        [[[NSString stringWithFormat:@"%s\n%d", script, broken] dataUsingEncoding:NSUTF8StringEncoding] writeToFile:LOG_DIR".errornotify" atomically:true];
        CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification(r, CFSTR("luaERROR"), NULL, NULL, true);
    }
}

void close_lua()
{
    if(L != NULL) lua_close(L);
    L = NULL;

    post_notification(_script, true);
    
}
BOOL init_lua(const char *script)
{
    BOOL success = true;
    _script = script;

    //if we are reloading, close the state
    if(L != NULL) lua_close(L);

    //create state
    L = luaL_newstate();

    //set globals
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
        post_notification(script, true);
    }
    else
    {
        func = luaL_ref(L, LUA_REGISTRYINDEX);
        lua_pop(L, 1);
        post_notification(script, false);
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

void push_view(UIView *view)
{
    lua_pushlightuserdata(L, view);
    luaL_getmetatable(L, "UIView");
    lua_setmetatable(L, -2);
}

BOOL manipulate(UIView *view, float offset, float width, float height)
{
    if(L == NULL) return false;

    lua_rawgeti(L, LUA_REGISTRYINDEX, func);

    push_view(view);
    lua_pushnumber(L, offset);
    lua_pushnumber(L, width);
    lua_pushnumber(L, height);

    view.transformed = false;
    for(UIView *v in view.subviews)
        v.transformed = false;

    if(lua_pcall(L, 4, 1, 0) != 0)
    {
        write_error(lua_tostring(L, -1));
        close_lua();
        return false;
    }
    lua_pop(L, 1);
    return true;
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
    }

    return 0;
}

#define GET_TRANSFORM(self) (self.transformed ? self.layer.transform : CATransform3DIdentity)
#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX) || ![(NSObject *)lua_touserdata(STATE, INDEX) isKindOfClass:UIView.class]) \
        return luaL_error(STATE, "first argument must be a view")


static int l_transform_rotate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform = GET_TRANSFORM(self);
    self.transformed = true;
    int first = 2;

    float pitch = 0, yaw = 0, roll = 0;
    if(!lua_isnumber(L, first+1))
        roll = 1;
    else
    {
        pitch = lua_tonumber(L, first+1);
        yaw = lua_tonumber(L, first+2);
        roll = lua_tonumber(L, first+3);
    }

    if(fabs(pitch) > 0.01 || fabs(yaw) > 0.01)
        transform.m34 = -0.002;
    transform = CATransform3DRotate(transform, lua_tonumber(L, first), pitch, yaw, roll);
    self.layer.transform = transform;

    return 0;
}
static int l_transform_translate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform = GET_TRANSFORM(self);
    self.transformed = true;
    int first = 2;
    float x = lua_tonumber(L, first), y = lua_tonumber(L, first+1), z = lua_tonumber(L, first+2);
    if(fabs(z) > 0.01)
        transform.m34 = -0.002;
    transform = CATransform3DTranslate(transform, x, y, z);

    self.layer.transform = transform;

    return 0;
}
