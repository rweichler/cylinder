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

#import "luashit.h"
#import <lua/lauxlib.h>
#import <lua/lualib.h>
#import "macros.h"

#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX) || ![(NSObject *)lua_touserdata(STATE, INDEX) isKindOfClass:UIView.class]) \
        return luaL_error(STATE, "first argument must be a view")

#define LOG_DIR @"/var/mobile/Library/Logs/Cylinder/"
#define LOG_PATH "errors.log"
#define PRINT_PATH "print.log"

//this allows a 3D perspective, sometimes this value is needed
//for transformations that translate, THEN rotate. (like cube,
//page flip, etc)
#define PERSPECTIVE_DISTANCE 500.0

static lua_State *L = NULL;

static NSMutableArray *_scripts = nil;
static NSMutableArray *_scriptNames = nil;
BOOL _randomize;

static int l_transform_rotate(lua_State *L);
static int l_transform_translate(lua_State *L);
static int l_transform_scale(lua_State *L);
static int l_push_base_transform(lua_State *L);
static int l_set_transform(lua_State *L, UIView *self); //-1 = transform
static int l_get_transform(lua_State *L, UIView *self); //pushes transform to top of stack
static int l_uiview_index(lua_State *L);
static int l_uiview_setindex(lua_State *L);
static int l_uiview_len(lua_State *L);
static int l_loadfile_override(lua_State *L);
static int l_print(lua_State *L);
static int l_subviews(lua_State *L);

static const char * get_stack(lua_State *L, const char *strr);

void write_error(const char *error);
void write_file(const char *msg, const char *filename);

static const char *OS_DANGER[] = {
    "exit",
    "setlocale",
    //"date",
    //"getenv",
    //"difftime",
    "remove",
    //"time",
    //"clock",
    "tmpname",
    "rename",
    "execute",
    NULL
};

static void remove_script(int index)
{
    [_scripts removeObjectAtIndex:index];
    [_scriptNames removeObjectAtIndex:index];
}

NSDictionary *gen_error_dict(NSString *script, BOOL broken)
{
    NSArray *components = script.pathComponents;
    NSString *folder = [components objectAtIndex:0];
    NSString *name = [components objectAtIndex:1];
    NSNumber *nsbroken = [NSNumber numberWithBool:broken];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        folder, PrefsEffectDirKey,
        name, PrefsEffectKey,
        nsbroken, @"broken",
        nil];
}

void error_notification(NSArray *errors)
{
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:errors format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    if(data)
    {
        [data writeToFile:LOG_DIR".errornotify" atomically:true];
        CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification(r, CFSTR("luaERROR"), NULL, NULL, true);
    }
}

void close_lua()
{
    if(L != NULL) lua_close(L);
    L = NULL;
    [_scripts release];
    [_scriptNames release];
    _scripts = nil;
    _scriptNames = nil;
}

static void create_state()
{
    //create state
    L = luaL_newstate();

    //load libraries
    luaL_openlibs(L);

    //disable dangerous libraries
    lua_pushnil(L);
    lua_setglobal(L, LUA_LOADLIBNAME);
    lua_pushnil(L);
    lua_setglobal(L, LUA_IOLIBNAME);
    lua_pushnil(L);
    lua_setglobal(L, "require");

    //disable dangerous functions

    lua_getglobal(L, LUA_OSLIBNAME);
    for(int i = 0; OS_DANGER[i] != NULL; i++)
    {
        lua_pushstring(L, OS_DANGER[i]);
        lua_pushnil(L);
        lua_settable(L, -3);
    }
    lua_pop(L, 1);

    //override certain functions
    lua_pushcfunction(L, l_print);
    lua_setglobal(L, "print");

    //set globals
    lua_newtable(L);
    l_push_base_transform(L);
    lua_setglobal(L, "BASE_TRANSFORM");

    lua_pushnumber(L, PERSPECTIVE_DISTANCE);
    lua_setglobal(L, "PERSPECTIVE_DISTANCE");

    lua_pushcfunction(L, l_subviews);
    lua_setglobal(L, "subviews");

    //set UIView metatable
    luaL_newmetatable(L, "UIView");

    lua_pushcfunction(L, l_uiview_index);
    lua_setfield(L, -2, "__index");

    lua_pushcfunction(L, l_uiview_setindex);
    lua_setfield(L, -2, "__newindex");

    lua_pushcfunction(L, l_uiview_len);
    lua_setfield(L, -2, "__len");

    lua_pop(L, 1);
}

static void changedofile(const char *folder, const char *func)
{
    //(), {}
    lua_getupvalue(L, -2, 1);
    lua_pushstring(L, func);
    //(), {}, _ENV, func""
    lua_gettable(L, -2);
    lua_pushstring(L, folder);
    //(), {}, _ENV{}, func(), folder""
    lua_pushcclosure(L, l_loadfile_override, 2);
    //(), {}, _ENV{}, newfunc()
    lua_pushstring(L, func);
    lua_pushvalue(L, -2);
    //(), {}, _ENV{}, newfunc(), func"", newfunc()
    lua_settable(L, -5);
    //(), {}, _ENV{}, newfunc()
    lua_pop(L, 2);
    //(), {}
}

static void set_environment(const char *script)
{
    const char *folder = [[[NSString stringWithUTF8String:script].pathComponents objectAtIndex:0] UTF8String];
    //()
    lua_newtable(L);
    lua_newtable(L);
    lua_pushstring(L, "__index");
    lua_getupvalue(L, -4, 1);
    //(), {}, {}, "__index", _ENV{}
    lua_settable(L, -3);
    //(), {}, {"__index":_ENV{}}
    lua_setmetatable(L, -2);
    //(), {}
    changedofile(folder, "dofile");
    changedofile(folder, "loadfile");
    lua_setupvalue(L, -2, 1);
}


int open_script(const char *script)
{
    int func = -1;

    const char *path = [NSString stringWithFormat:@CYLINDER_DIR"%s.lua", script].UTF8String;

    //load our file and save the function we want to call
    BOOL loaded = luaL_loadfile(L, path) == LUA_OK;
    if(loaded)
    {
        set_environment(script);
        loaded = lua_pcall(L, 0, 1, 0) == LUA_OK;
    }

    if(!loaded)
    {
        write_error(lua_tostring(L, -1));
    }
    else if(!lua_isfunction(L, -1))
    {
        write_error([NSString stringWithFormat:@"error opening %s: result must be a function", script].UTF8String);
    }
    else
    {
        lua_pushvalue(L, -1);
        func = luaL_ref(L, LUA_REGISTRYINDEX);
    }

    lua_pop(L, 1);

    return func;
}

BOOL init_lua(NSArray *scripts, BOOL random)
{
    if(scripts == nil) scripts = DEFAULT_EFFECTS;
    if(scripts.count == 0) return false;

    _randomize = random;
    close_lua();
    create_state();

    _scripts = [NSMutableArray arrayWithCapacity:scripts.count].retain;
    _scriptNames = [NSMutableArray arrayWithCapacity:scripts.count].retain;

    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:scripts.count];
    for(NSDictionary *scriptDict in scripts)
    {
        NSString *script = [NSString stringWithFormat:@"%@/%@", [scriptDict valueForKey:PrefsEffectDirKey], [scriptDict valueForKey:PrefsEffectKey]];

        int func = open_script(script.UTF8String);

        NSMutableDictionary *errorDict = scriptDict.mutableCopy;
        [errorDict setValue:[NSNumber numberWithBool:(func == -1)] forKey:@"broken"];
        [errors addObject:errorDict];

        if(func != -1)
        {
            [_scripts addObject:[NSNumber numberWithInt:func]];
            [_scriptNames addObject:script];
        }
    }

    error_notification(errors);

    if(_scripts.count == 0)
    {
        close_lua();
        return false;
    }
    return true;
}

static int l_loadfile_override(lua_State *L)
{
    const char *file = lua_tostring(L, 1);
    const char *subfolder = lua_tostring(L, lua_upvalueindex(2));

    if(file != NULL)
        file = [NSString stringWithFormat:@"/Library/Cylinder/%s/%s", subfolder, file].UTF8String;

    int top = lua_gettop(L);
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);

    if(file != NULL)
    {
        lua_pushstring(L, file);
        lua_remove(L, 2);
        lua_insert(L, 2);
    }
    BOOL success = lua_pcall(L, top, 1, 0) == LUA_OK;
    if(!success)
    {
        return luaL_error(L, lua_tostring(L, -1));
    }
    return 1;
}

static int l_print(lua_State *L)
{
    const char *str = lua_tostring(L, 1);
    if(str == NULL) return luaL_error(L, "could not argument for printing");

    write_file(str, "print.log");
    return 0;
}

//this is literally the same code as ipairs
static int l_subviewsaux(lua_State *L)
{
    CHECK_UIVIEW(L, 1);
    int i = luaL_checkint(L, 2);
    i++;
    lua_pushinteger(L, i);
    lua_pushvalue(L, -1);
    lua_gettable(L, 1);
    return (lua_isnil(L, -1)) ? 1 : 2;
}


static int l_subviews(lua_State *L)
{
    CHECK_UIVIEW(L, 1);
    lua_pushcfunction(L, l_subviewsaux);
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 0);
    return 3;
}


void write_error(const char *error)
{
    write_file(error, LOG_PATH);
}

void write_file(const char *msg, const char *filename)
{
    NSString *path = [LOG_DIR stringByAppendingPathComponent:[NSString stringWithUTF8String:filename]];

    if(![NSFileManager.defaultManager fileExistsAtPath:path isDirectory:nil])
    {
        if(![NSFileManager.defaultManager fileExistsAtPath:LOG_DIR isDirectory:nil])
            [NSFileManager.defaultManager createDirectoryAtPath:LOG_DIR withIntermediateDirectories:false attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [fileHandle seekToEndOfFile];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"[yyyy-MM-dd HH:mm:ss] "];
    NSString *dateStr = [dateFormatter stringFromDate:NSDate.date];

    [fileHandle writeData:[dateStr dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle writeData:[NSData dataWithBytes:msg length:(strlen(msg) + 1)]];
    [fileHandle writeData:[NSData dataWithBytes:"\n" length:2]];
    [fileHandle closeFile];
}

static void push_view(UIView *view)
{
    lua_pushlightuserdata(L, view);
    luaL_getmetatable(L, "UIView");
    lua_setmetatable(L, -2);
}


static BOOL manipulate_step(UIView *view, float offset, int funcIndex)
{
    int func = [[_scripts objectAtIndex:funcIndex] intValue];
    lua_rawgeti(L, LUA_REGISTRYINDEX, func);

    push_view(view);
    lua_pushnumber(L, offset);
    lua_pushnumber(L, SCREEN_SIZE.width);
    lua_pushnumber(L, SCREEN_SIZE.height);

    BOOL success = lua_pcall(L, 4, 1, 0) == 0;

    if(!success)
    {
        write_error(lua_tostring(L, -1));
        NSDictionary *error = gen_error_dict([_scriptNames objectAtIndex:funcIndex], true);
        NSArray *errors = [NSArray arrayWithObject:error];
        error_notification(errors);
        remove_script(funcIndex);
    }
    lua_pop(L, 1);
    return success;
}

BOOL manipulate(UIView *view, float offset, u_int32_t rand)
{
    if(L == NULL) return false;
    else if(_scripts.count == 0)
    {
        close_lua();
        return false;
    }

    view.layer.transform = CATransform3DIdentity;
    view.alpha = 1;
    for(UIView *v in view.subviews)
    {
        v.layer.transform = CATransform3DIdentity;
        view.alpha = 1;
    }
    if(_randomize)
    {
        if(manipulate_step(view, offset, rand % _scripts.count))
            return true;
        else
            return manipulate(view, offset, rand); //next script will be different since
                                                                  //_scripts.count has decremented by 1
    }
    else
    {
        for(int i = 0; i < _scripts.count; i++)
        {
            if(!manipulate_step(view, offset, i))
                i--;
        }
        if(_scripts.count == 0)
        {
            close_lua();
            return false;
        }
        else
        {
            return true;
        }
    }
}

typedef unsigned int (*maxicons_func)(id, SEL);
typedef unsigned int (*maxrowcols_func)(id, SEL, UIDeviceOrientation);
int invoke_int(id self, SEL selector, BOOL use_orientation)
{
    IMP imp = [self methodForSelector:selector];
    if(use_orientation)
    {
        maxrowcols_func f = (maxrowcols_func)imp;
        return (int)f(self, selector, UIDevice.currentDevice.orientation);
    }
    else
    {
        maxicons_func f = (maxicons_func)imp;
        return (int)f(self, selector);
    }
}

static int l_uiview_index(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    if(lua_isnumber(L, 2)) //if it's a number, return the subview
    {
        int index = lua_tonumber(L, 2) - 1;
        if(index < self.subviews.count)
        {
            push_view([self.subviews objectAtIndex:index]);
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
                push_view([self.subviews objectAtIndex:i]);
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
        else if(!strcmp(key, "scale"))
        {
            lua_pushcfunction(L, l_transform_scale);
            return 1;
        }
        else if(!strcmp(key, "x"))
        {
            lua_pushnumber(L, self.frame.origin.x);
            return 1;
        }
        else if(!strcmp(key, "y"))
        {
            lua_pushnumber(L, self.frame.origin.y);
            return 1;
        }
        else if(!strcmp(key, "width"))
        {
            lua_pushnumber(L, self.frame.size.width/self.layer.transform.m11);
            return 1;
        }
        else if(!strcmp(key, "height"))
        {
            lua_pushnumber(L, self.frame.size.height/self.layer.transform.m22);
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
            else
                return 0;
        }
        else if(!strcmp(key, "max_columns"))
        {
            SEL selector = @selector(iconColumnsForInterfaceOrientation:);
            if([self.class respondsToSelector:selector])
            {
                lua_pushnumber(L, invoke_int(self.class, selector, true));
                return 1;
            }
            else
                return 0;
        }
        else if(!strcmp(key, "max_rows"))
        {
            SEL selector = @selector(iconRowsForInterfaceOrientation:);
            if([self.class respondsToSelector:selector])
            {
                lua_pushnumber(L, invoke_int(self.class, selector, true));
                return 1;
            }
            else
                return 0;
        }
    }

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

static int l_uiview_len(lua_State *L)
{
    UIView *self = (UIView *)lua_touserdata(L, 1);
    lua_pushnumber(L, self.subviews.count);
    return 1;
}


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
        transform.m34 = -1/PERSPECTIVE_DISTANCE;

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
        return luaL_error(LUASTATE, ERR_MALFORMED);\
    TRANSFORM.M = lua_tonumber(LUASTATE, -1);\
    lua_pop(LUASTATE, 1)

static int l_set_transform(lua_State *L, UIView *self) //-1 = transform
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

static const char * get_stack(lua_State *L, const char *strr)
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"%s{", strr];
    int i;
    int top = lua_gettop(L);
    for (i = 1; i <= top; i++) {  /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
                
            case LUA_TSTRING:  /* strings */
                [str appendFormat:@"\"%s\"", lua_tostring(L, i)];
                break;
                
            case LUA_TBOOLEAN:  /* booleans */
                [str appendString:lua_toboolean(L, i) ? @"true" : @"false"];
                break;
                
            case LUA_TNUMBER:  /* numbers */
                [str appendFormat:@"%g", lua_tonumber(L, i)];
                break;
                
            default:  /* other values */
                [str appendFormat:@"<%s>", lua_typename(L, t)];
                break;
                
        }
        if(i < top)
            [str appendString:@",  "];  /* put a separator */
    }
    return [NSString stringWithFormat:@"%@} %d", str, top].UTF8String;
}
