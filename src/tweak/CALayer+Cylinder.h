#import <UIKit/UIKit.h>

@interface CALayer(Cylinder)
-(void)savePosition;
-(void)restorePosition;
@property (nonatomic, readonly) CGPoint savedPosition;
@property (nonatomic, readonly) BOOL hasSavedPosition;
@end
