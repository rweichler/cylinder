#import "luashit.h"
#import "lua/lauxlib.h"
#import "macros.h"

#define LOG_DIR @"/var/mobile/Library/Logs/Cylinder/"
#define LOG_PATH LOG_DIR"errors.log"

static lua_State *L = NULL;
const char *_script;
static int func;
static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_push_base_transform(lua_State *L);
static int l_set_transform(lua_State *L, UIView *self); //-1 = transform
static int l_get_transform(lua_State *L, UIView *self); //pushes transform to top of stack
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

    lua_newtable(L);
    l_push_base_transform(L);
    lua_setglobal(L, "BASE_TRANSFORM");

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

    view.layer.transform = CATransform3DIdentity;
    for(UIView *v in view.subviews)
        v.layer.transform = CATransform3DIdentity;

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
            if(!lua_isnumber(L, 3))
                return luaL_error(L, "alpha must be a number");

            self.alpha = lua_tonumber(L, 3);
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
        else if(!strcmp(key, "transform"))
        {
            return l_get_transform(L, self);
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

#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX) || ![(NSObject *)lua_touserdata(STATE, INDEX) isKindOfClass:UIView.class]) \
        return luaL_error(STATE, "first argument must be a view")


static int l_transform_rotate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

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
        transform.m34 = -0.002;
    transform = CATransform3DRotate(transform, lua_tonumber(L, 2), pitch, yaw, roll);
    self.layer.transform = transform;

    return 0;
}
static int l_transform_translate(lua_State *L)
{
    CHECK_UIVIEW(L, 1);

    UIView *self = (UIView *)lua_touserdata(L, 1);

    CATransform3D transform = self.layer.transform;
    float x = lua_tonumber(L, 2), y = lua_tonumber(L, 3), z = lua_tonumber(L, 4);
    float oldm34 = transform.m34;
    if(fabs(z) > 0.01)
        transform.m34 = -0.002;
    transform = CATransform3DTranslate(transform, x, y, z);
    transform.m34 = oldm34;

    self.layer.transform = transform;

    return 0;
}

float POPA_T(lua_State *L, int index)
{
    lua_pushnumber(L, index);
    lua_gettable(L, -2);
    if(!lua_isnumber(L, -1))
        return luaL_error(L, "malformed transformation matrix");

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

static int l_push_base_transform(lua_State *L)
{
    int i = 0;
    CALL_TRANSFORM_MACRO(BASE_TRANSFORM_STEP, L, i, CATransform3DIdentity);
    return 1;
}

#define FILL_TRANSFORM(M, LUASTATE, I, TRANSFORM)\
    lua_pushnumber(LUASTATE, ++I);\
    lua_gettable(LUASTATE, -3);\
    if(!lua_isnumber(LUASTATE, -1))\
        return luaL_error(LUASTATE, "malformed transformation matrix");\
    TRANSFORM.M = lua_tonumber(LUASTATE, -1);\
    lua_pop(LUASTATE, 1)

static int l_set_transform(lua_State *L, UIView *self) //-1 = transform
{
    if(!lua_istable(L, -1))
        return luaL_error(L, "transform must be a table");
    lua_len(L, -1);
    if(lua_tonumber(L, -1) != 16)
        return luaL_error(L, "malformed transformation matrix");
    lua_pop(L, 1);

    CATransform3D transform;
    int i = 0;
    CALL_TRANSFORM_MACRO(FILL_TRANSFORM, L, i, transform);
    self.layer.transform = transform;

    return 0;
}

#define PUSH_TRANSFORM(M, LUASTATE, I, TRANSFORM)\
    lua_pushnumber(LUASTATE, ++I);\
    lua_pushnumber(LUASTATE, TRANSFORM.M);\
    lua_settable(LUASTATE, -3)

static int l_get_transform(lua_State *L, UIView *self) //pushes transform to top of stack
{
    lua_newtable(L);
    int i = 0;
    CALL_TRANSFORM_MACRO(PUSH_TRANSFORM, L, i, self.layer.transform);
    return 1;
}
