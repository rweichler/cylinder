#import "UIView+Cylinder.h"
#import <objc/objc.h>

@implementation UIView(Cylinder)
-(BOOL)isOnScreen
{
    NSNumber *num = objc_getAssociatedObject(self, @selector(isOnScreen));
    return num && num.boolValue;
}

-(void)setIsOnScreen:(BOOL)isOnScreen
{
    NSNumber *num = (isOnScreen ? [NSNumber numberWithBool:true] : nil);
    objc_setAssociatedObject(self, @selector(isOnScreen), num, OBJC_ASSOCIATION_RETAIN);
}

@end
