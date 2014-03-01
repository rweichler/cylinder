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

-(BOOL)hasDifferentSubviews
{
    NSNumber *count = objc_getAssociatedObject(self, @selector(hasDifferentSubviews));

    BOOL different = self.subviews.count != count.intValue;

    if(different)
    {
        count = [NSNumber numberWithInt:self.subviews.count];
        objc_setAssociatedObject(self, @selector(hasDifferentSubviews), count, OBJC_ASSOCIATION_RETAIN);
    }

    return different;
}

-(void)setHasDifferentSubviews:(BOOL)different
{
    NSNumber *count = different ? nil : [NSNumber numberWithInt:self.subviews.count];
    objc_setAssociatedObject(self, @selector(hasDifferentSubviews), count, OBJC_ASSOCIATION_RETAIN);
}

@end
