#import <UIKit/UIKit.h>

@interface CLEffect : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *pack;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

+ (CLEffect *)effectWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end
