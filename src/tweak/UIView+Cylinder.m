/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

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
