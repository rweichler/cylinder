#import "UIView+Cylinder.h"
#import <objc/objc.h>

#define GET_TRANSFORMED objc_getAssociatedObject(self, @selector(transformed))

@implementation UIView(Cylinder)
-(BOOL)transformed
{
    NSNumber *num = GET_TRANSFORMED;
    if(num == nil)
    {
        self.transformed = false;
        return false;
    }
    return num.boolValue;
}

-(void)setTransformed:(BOOL)transformed
{
    NSNumber *num = GET_TRANSFORMED;
    if(num != nil)
        [num release];
    num = [[NSNumber numberWithBool:transformed] retain];
    objc_setAssociatedObject(self, @selector(transformed), num, OBJC_ASSOCIATION_ASSIGN);
}

@end
