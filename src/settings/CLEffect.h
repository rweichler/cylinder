#import <UIKit/UIKit.h>
#import "CLAlignedTableViewCell.h"

@interface CLEffect : NSObject

@property (nonatomic, assign) CLAlignedTableViewCell *cell;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, assign, getter=isBroken) BOOL broken;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

+ (CLEffect *)effectWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end
