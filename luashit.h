#include "lua/lua.h"
#import <QuartzCore/QuartzCore.h>

void init_lua();
CATransform3D *default_transform();
CATransform3D *transform_me(float width, float offset);
