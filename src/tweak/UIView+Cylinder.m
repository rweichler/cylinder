#import "UIView+Cylinder.h"
#import <objc/runtime.h>

@implementation UIView(Cylinder)
-(BOOL)wasModifiedByCylinder
{
    NSNumber *num = objc_getAssociatedObject(self, @selector(wasModifiedByCylinder));
    return num && num.boolValue;
}

-(void)setWasModifiedByCylinder:(BOOL)wasModifiedByCylinder
{
    NSNumber *num = (wasModifiedByCylinder ? [NSNumber numberWithBool:true] : nil);
    objc_setAssociatedObject(self, @selector(wasModifiedByCylinder), num, OBJC_ASSOCIATION_RETAIN);
}


static int lastSubPtr;
-(int)cylinderLastSubviewCount
{
    NSNumber *last = objc_getAssociatedObject(self, &lastSubPtr);
    NSNumber *current = [NSNumber numberWithInt:self.subviews.count];
    if(last == nil) {
        last = current;
    }
    objc_setAssociatedObject(self, &lastSubPtr, current, OBJC_ASSOCIATION_RETAIN);
    return last.intValue;
}

-(BOOL)hasDifferentSubviews
{
    NSNumber *num = objc_getAssociatedObject(self, @selector(hasDifferentSubviews));

    BOOL different = num.boolValue;

    if(different)
    {
        objc_setAssociatedObject(self, @selector(hasDifferentSubviews), nil, OBJC_ASSOCIATION_RETAIN);
    }

    return different;
}

-(void)setHasDifferentSubviews:(BOOL)different
{
    NSNumber *num = different ? nil : [NSNumber numberWithBool:true];
    objc_setAssociatedObject(self, @selector(hasDifferentSubviews), num, OBJC_ASSOCIATION_RETAIN);
}

@end
