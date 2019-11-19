#import <QuartzCore/QuartzCore.h>
#import <lua/lua.h>
#import <UIKit/UIKit.h>
#import "CALayer+Cylinder.h"

void close_lua();
BOOL init_lua(NSArray *scripts, BOOL random);
BOOL manipulate(UIView *view, float offset, u_int32_t rand);
//const char * get_stack(lua_State *L, const char *strr);
