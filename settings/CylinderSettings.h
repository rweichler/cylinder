#import <Preferences/PSListController.h>
#import "CLEffect.h"

@interface CylinderSettingsListController: PSListController
@property (nonatomic, retain, readonly) NSDictionary *settings;
- (void)setSelectedEffects:(NSArray *)effects;
- (void)writeSettings;
- (void)sendSettings;
@end
