#import <lua/lua.h>
#import <lua/lauxlib.h>
#import "CALayer+Cylinder.h"
#import <Defines.h>

#define CHECK_UIVIEW(STATE, INDEX) \
    if(!lua_isuserdata(STATE, INDEX) || ![(NSObject *)lua_touserdata(STATE, INDEX) isKindOfClass:UIView.class]) \
        return luaL_error(STATE, "first argument must be a view")

//this allows a 3D perspective, sometimes this value is needed
//for transformations that translate, THEN rotate. (like cube,
//page flip, etc)
#define SCREEN_SIZE UIScreen.mainScreen.bounds.size
#define PERSPECTIVE_DISTANCE ((SCREEN_SIZE.width +  SCREEN_SIZE.height)/2) 

int l_create_uiview_metatable(lua_State *L);
int l_push_base_transform(lua_State *L);
int l_push_view(lua_State *L, id view);
