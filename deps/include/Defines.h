#import <UIKit/UIKit.h>
#import <substrate.h>

#define CLLog(format, ...) NSLog(@"Cylinder: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])
#define Log CLLog

#define IOS_VERSION ___iosversion_cylinder____yeah___ //UIDevice.currentDevice.systemVersion.intValue
extern int IOS_VERSION;
#define SCREEN_SIZE UIScreen.mainScreen.bounds.size

#define PrefsEffectKey        @"effect"
#define PrefsEffectDirKey  @"effectFolder"
#define PrefsFormulaKey @"formula"
#define PrefsSelectedFormulaKey @"selectedFormula"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsRandomizedKey      @"randomized"
#define PrefsOldMethodKey    @"useOldMethod"

#define PrefsPackKey         @"pack"
#define PrefsBrokenKey       @"brokenEffects"

#define DEFAULT_EFFECT @"Cube (inside)"
#define DEFAULT_DIRECTORY @"rweichler"

#ifndef MAIN_BUNDLE
#define MAIN_BUNDLE ([NSBundle bundleForClass:NSClassFromString(@"CylinderSettingsListController")])
#endif
#define LOCALIZE(KEY, DEFAULT) [MAIN_BUNDLE localizedStringForKey:KEY value:DEFAULT table:@"CylinderSettings"]
#define SYSTEM_LOCALIZE(KEY) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:KEY value:@"" table:nil]

#define IN_SPRINGBOARD()     ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
#define IS_RETINA()          ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define PREFS_PATH           @"/var/mobile/Library/Preferences/com.r333d.cylinder.plist"
#define RETINIZE(r)          [(IS_RETINA()) ? [r stringByAppendingString:@"@2x"] : r stringByAppendingPathExtension: @"png"]

#define kCylinderSettingsChanged         @"com.r333d.cylinder/settingsChanged"
#define kCylinderSettingsRefreshSettings @"com.r333d.cylinder/refreshSettings"

#define BUNDLE_PATH @"/Library/PreferenceBundles/CylinderSettings.bundle/"

#define kEffectsDirectory     @"/Library/Cylinder"
#define kPacksDirectory      @"/Library/Cylinder/Packs"
#define DEFAULT_EFFECTS      [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_EFFECT, PrefsEffectKey, DEFAULT_DIRECTORY, PrefsEffectDirKey, nil], nil]
#define DEFAULT_FORMULAS    [NSDictionary dictionary]
#define DefaultPrefs         [NSMutableDictionary dictionaryWithObjectsAndKeys: DEFAULT_EFFECTS, PrefsEffectKey, DEFAULT_FORMULAS, PrefsFormulaKey, [NSNumber numberWithBool:YES], PrefsEnabledKey, [NSNumber numberWithBool:false], PrefsRandomizedKey, nil]

@interface UIDevice (de)
- (BOOL)iOSVersionIsAtLeast:(NSString *)vers;
@end

#define IS_IOS_70_OR_LATER() [[UIDevice currentDevice] iOSVersionIsAtLeast: @"7.0"]
#define IS_IOS_60()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"6.0"] && !IS_IOS_70_OR_LATER())
#define IS_IOS_50()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"] && !IS_IOS_60() && !IS_IOS_70_OR_LATER())
#define IS_IOS_40()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"4.2"] && !IS_IOS_50() && !IS_IOS_60() && !IS_IOS_70_OR_LATER())

