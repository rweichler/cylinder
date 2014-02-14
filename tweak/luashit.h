#import <QuartzCore/QuartzCore.h>
#import <lua/lua.h>
#import <UIKit/UIKit.h>

void close_lua();
BOOL init_lua(NSArray *scripts, BOOL random);
CATransform3D *default_transform();
BOOL manipulate(UIView *view, float offset, float width, float height, u_int32_t rand);
