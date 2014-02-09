#import <UIKit/UIKit.h>
#import <substrate.h>

#define CLLog(format, ...) NSLog(@"Cylinder: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])

#define PrefsEffectKey        @"effect"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsOldMethodKey    @"useOldMethod"

#define PrefsPackKey         @"pack"
#define PrefsBrokenKey       @"brokenEffects"

#define IN_SPRINGBOARD()     ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
#define IS_RETINA()          ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define PREFS_PATH           [NSString stringWithFormat:@"%@/Library/Preferences/com.r333d.cylinder.plist", NSHomeDirectory()]
#define RETINIZE(r)          [(IS_RETINA()) ? [r stringByAppendingString:@"@2x"] : r stringByAppendingPathExtension: @"png"]

#define kCylinderSettingsChanged         @"com.r333d.cylinder/settingsChanged"
#define kCylinderSettingsRefreshSettings @"com.r333d.cylinder/refreshSettings"

#define kEffectsDirectory     @"/Library/Cylinder"
#define kPacksDirectory      @"/Library/Cylinder/Packs"
#define DefaultPrefs         [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cylinder", PrefsPackKey, @"Cube (inside)", PrefsEffectKey, [NSNumber numberWithBool:YES], PrefsEnabledKey, nil]

@interface UIDevice (de)
- (BOOL)iOSVersionIsAtLeast:(NSString *)vers;
@end

#define IS_IOS_70_OR_LATER() [[UIDevice currentDevice] iOSVersionIsAtLeast: @"7.0"]
#define IS_IOS_60()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"6.0"] && !IS_IOS_70_OR_LATER())
#define IS_IOS_50()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"] && !IS_IOS_60() && !IS_IOS_70_OR_LATER())
#define IS_IOS_40()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"4.2"] && !IS_IOS_50() && !IS_IOS_60() && !IS_IOS_70_OR_LATER())

