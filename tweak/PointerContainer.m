#import "PointerContainer.h"

@implementation PointerContainer
@synthesize description=_description;
-(void *)pointer
{
    return _pointer;
}
-(void)setPointer:(void *)pointer
{
    _pointer = pointer;
}
@end
