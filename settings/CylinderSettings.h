#import <Preferences/PSListController.h>
#import "CLEffect.h"

@interface CylinderSettingsListController: PSListController
@property (nonatomic, retain, readonly) NSDictionary *settings;
- (void)setCurrentEffect:(CLEffect *)effect;
- (void)writeSettings;
- (void)sendSettings;
@end
