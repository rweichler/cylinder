#import "luashit.h"
#import <lua/lauxlib.h>
#import <lua/lualib.h>
#import "macros.h"
#import "lua_UIView.h"


#define LOG_DIR @"/var/mobile/Library/Logs/Cylinder/"
#define LOG_PATH "errors.log"
#define PRINT_PATH "print.log"

static lua_State *L = NULL;
static BOOL set_perspective_distance = false;

static NSMutableArray *_scripts = nil;
static NSMutableArray *_scriptNames = nil;
BOOL _randomize;

static int l_loadfile_override(lua_State *L);
static int l_print(lua_State *L);
static int l_subviews(lua_State *L);
static int l_popup(lua_State *L);

static void write_error(const char *error);
static void write_file(const char *msg, const char *filename);

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
    int func = [[_scripts objectAtIndex:index] intValue];
    luaL_unref(L, LUA_REGISTRYINDEX, func);
    [_scripts removeObjectAtIndex:index];
    [_scriptNames removeObjectAtIndex:index];
}

static NSDictionary *gen_error_dict(NSString *script, BOOL broken)
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

static void error_notification(NSArray *errors)
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

    // LuaJIT and 64-bit OS X don't play well together http://luajit.org/install.html#embed
    // since we're embedding in SpringBoard we don't have the luxury of using linker flags
    // turning off the JIT fixes all the issues, unfortunately this mean C callbacks cannot be used
    //luaL_dostring(L, "if jit and jit.arch == 'arm64' then jit.off() end");

    //override certain functions
    lua_pushcfunction(L, l_print);
    lua_setglobal(L, "print");

    //set globals
    lua_newtable(L);
    l_push_base_transform(L);
    lua_setglobal(L, "BASE_TRANSFORM");

    lua_pushcfunction(L, l_subviews);
    lua_setglobal(L, "subviews");

    lua_pushcfunction(L, l_popup);
    lua_setglobal(L, "popup");

    //set UIView metatable
    l_create_uiview_metatable(L);
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


static int open_script(const char *script)
{
    int func = -1;

    const char *path = [NSString stringWithFormat:@CYLINDER_DIR"%s.lua", script].UTF8String;

    //load our file and save the function we want to call
    BOOL loaded = luaL_loadfile(L, path) == 0;
    if(loaded)
    {
        set_environment(script);
        loaded = lua_pcall(L, 0, 1, 0) == 0;
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
    set_perspective_distance = false;
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
    BOOL success = lua_pcall(L, top, 1, 0) == 0;
    if(!success)
    {
        return luaL_error(L, lua_tostring(L, -1));
    }
    return 1;
}

//stolen from lua's print function
static int l_concat_args(lua_State *L, const char *func_name, const char *separator)
{
    int n = lua_gettop(L);  /* number of arguments */
    int i;
    NSMutableString *result = [NSMutableString string];
    lua_getglobal(L, "tostring");
    for (i=1; i<=n; i++) {
        const char *s;
        lua_pushvalue(L, -1);  /* function to be called */
        lua_pushvalue(L, i);   /* value to print */
        lua_call(L, 1, 1);
        s = lua_tolstring(L, -1, NULL);  /* get result */
        if (s == NULL)
            return luaL_error(L,
                    [NSString stringWithFormat:@LUA_QL("tostring") " must return a string to " LUA_QL("%s"), func_name].UTF8String);
        if (i>1) [result appendFormat:@"%s", separator];//luai_writestring("\t", 1);
        [result appendFormat:@"%s", s];//luai_writestring(s, l);
        lua_pop(L, 1);  /* pop result */
    }
    lua_pop(L, 1); //pop tostring()
    lua_pushstring(L, result.UTF8String);
    return 1;
}

static int l_print(lua_State *L)
{
    l_concat_args(L, "print", "\t");

    write_file(lua_tostring(L, -1), "print.log");
    return 0;
}

static int l_popup(lua_State *L)
{
    l_concat_args(L, "popup", "\n");

    [[[UIAlertView.alloc initWithTitle:@"Cylinder" message:[NSString stringWithUTF8String:lua_tostring(L, -1)] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease] show];

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


static void write_error(const char *error)
{
    write_file(error, LOG_PATH);
}

static void write_file(const char *msg, const char *filename)
{
    Log(@"wrote to file %s: %s", filename, msg);

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
    [fileHandle writeData:[NSData dataWithBytes:msg length:strlen(msg)]];
    [fileHandle writeData:[NSData dataWithBytes:"\n" length:1]];
    [fileHandle closeFile];
}

static BOOL manipulate_step(UIView *view, float offset, int funcIndex)
{
    int func = [[_scripts objectAtIndex:funcIndex] intValue];
    lua_rawgeti(L, LUA_REGISTRYINDEX, func);

    l_push_view(L, view);
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
    if(!set_perspective_distance)
    {
        //the reason why this is not initialized in create_state()
        //is because create_state() is called when SpringBoard loads.
        //unfortunately in lower versions of iOS,  calling
        //UIScreen.mainScreen.bounds.size causes a bootloop.
        //so instead of setting that global variable there, we set it when
        //we know that everything in SpringBoard has already loaded
        lua_pushnumber(L, PERSPECTIVE_DISTANCE);
        lua_setglobal(L, "PERSPECTIVE_DISTANCE");
        set_perspective_distance = true;
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

/*
static const char * get_stack(lua_State *L, const char *strr)
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"%s{", strr];
    int i;
    int top = lua_gettop(L);
    for (i = 1; i <= top; i++) {  //repeat for each level
        int t = lua_type(L, i);
        switch (t) {
                
            case LUA_TSTRING:  //strings
                [str appendFormat:@"\"%s\"", lua_tostring(L, i)];
                break;
                
            case LUA_TBOOLEAN:  //booleans
                [str appendString:lua_toboolean(L, i) ? @"true" : @"false"];
                break;
                
            case LUA_TNUMBER:  //numbers
                [str appendFormat:@"%g", lua_tonumber(L, i)];
                break;
                
            default:  //other values
                [str appendFormat:@"<%s>", lua_typename(L, t)];
                break;
                
        }
        if(i < top)
            [str appendString:@",  "];  //put a separator
    }
    return [NSString stringWithFormat:@"%@} %d", str, top].UTF8String;
}
*/
