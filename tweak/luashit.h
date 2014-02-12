#import "lua/lua.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

void close_lua();
BOOL init_lua_random();
BOOL init_lua(const char *script);
CATransform3D *default_transform();
BOOL manipulate(UIView *view, float offset, float width, float height, u_int32_t rand);
