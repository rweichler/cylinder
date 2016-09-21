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

#import "CALayer+Cylinder.h"
#import <objc/runtime.h>

@implementation CALayer(Cylinder)
-(void)setSavedValue:(NSValue *)value
{
    objc_setAssociatedObject(self, @selector(savedValue), value, OBJC_ASSOCIATION_RETAIN);
}
-(NSValue *)savedValue
{
    return objc_getAssociatedObject(self, @selector(savedValue));
}
-(void)savePosition
{
    if(!self.savedValue)
        self.savedValue = [NSValue valueWithCGPoint:self.position];

}
-(void)restorePosition
{
    NSValue *value = self.savedValue;
    if(!value) return;

    self.position = value.CGPointValue;
    self.savedValue = nil;
}
-(CGPoint) savedPosition
{
    NSValue *value = self.savedValue;
    if(value)
        return value.CGPointValue;
    else
        return self.position;
}

-(BOOL)hasSavedPosition
{
    return self.savedValue != nil;
}

@end
