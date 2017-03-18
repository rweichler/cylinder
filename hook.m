/*
// How to compile (macOS):

clang -arch arm64 -arch armv7 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) hook.m -dynamiclib -o hook.so -Ldeps/lib -lsubstrate -Ideps/include -framework Foundation -lluajit-5.1.2
ldid -S hook.so
*/

#include <substrate.h>
#include <objc/runtime.h>
#include <objc/objc.h>
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>

static lua_State *state = NULL;
static int func;

void (*orig)(id, SEL, id);
void hook(id self, SEL _cmd, id scrollView)
{
    orig(self, _cmd, scrollView);
    lua_rawgeti(state, LUA_REGISTRYINDEX, func);
    lua_pushlightuserdata(state, scrollView);
    lua_call(state, 1, 0);
}

int luaopen_hook(lua_State *L)
{
    state = L;
    lua_getglobal(L, "LMFAO");
    func = luaL_ref(L, LUA_REGISTRYINDEX);
    MSHookMessageEx(objc_getClass("SBRootFolderView") ?: objc_getClass("SBIconController"), sel_registerName("scrollViewDidScroll:"), (IMP)hook, (IMP *)&orig);
    return 0;
}

