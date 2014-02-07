#include "lua/lua.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

void init_lua();
CATransform3D *default_transform();
CATransform3D *transform_me(float width, float offset);
void manipulate(UIView *view, float width, float offset);
