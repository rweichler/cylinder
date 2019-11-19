#import <Preferences/PSListController.h>
#import "CLEffect.h"

@interface CylinderSettingsListController: PSListController
@property (nonatomic, retain, readonly) NSDictionary *settings;
- (void)setSelectedEffects:(NSArray *)effects;
-(void)setSelectedFormula:(NSString *)formula;
-(void)setFormulas:(NSDictionary *)formulas;
- (void)writeSettings;
- (void)sendSettings;
@end
