#import <UIKit/UIKit.h>

@interface UIView(Cylinder)
@property (nonatomic, assign) BOOL wasModifiedByCylinder;
@property (nonatomic, assign) BOOL hasDifferentSubviews;
@property (nonatomic, assign, readonly) int cylinderLastSubviewCount;
@end
