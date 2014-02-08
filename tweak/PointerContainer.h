#import <Foundation/Foundation.h>

@interface PointerContainer : NSObject
{
    void *_pointer;
}
@property (nonatomic, retain) NSString *description;
-(void *)pointer;
-(void)setPointer:(void *)pointer;
@end
