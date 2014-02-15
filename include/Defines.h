/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <UIKit/UIKit.h>
#import <substrate.h>

#define CLLog(format, ...) NSLog(@"Cylinder: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])

#define PrefsEffectKey        @"effect"
#define PrefsEffectDirKey  @"effectFolder"
#define PrefsCarrierTextKey  @"carrierText"
#define PrefsUseTextKey      @"useText"
#define PrefsEnabledKey      @"enabled"
#define PrefsRandomizedKey      @"randomized"
#define PrefsOldMethodKey    @"useOldMethod"

#define PrefsPackKey         @"pack"
#define PrefsBrokenKey       @"brokenEffects"

#define DEFAULT_EFFECT @"Cube (inside)"
#define DEFAULT_DIRECTORY @"rweichler"

#define IN_SPRINGBOARD()     ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
#define IS_RETINA()          ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define PREFS_PATH           [NSString stringWithFormat:@"%@/Library/Preferences/com.r333d.cylinder.plist", NSHomeDirectory()]
#define RETINIZE(r)          [(IS_RETINA()) ? [r stringByAppendingString:@"@2x"] : r stringByAppendingPathExtension: @"png"]

#define kCylinderSettingsChanged         @"com.r333d.cylinder/settingsChanged"
#define kCylinderSettingsRefreshSettings @"com.r333d.cylinder/refreshSettings"

#define kEffectsDirectory     @"/Library/Cylinder"
#define kPacksDirectory      @"/Library/Cylinder/Packs"
#define DEFAULT_EFFECTS      [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:DEFAULT_EFFECT, PrefsEffectKey, DEFAULT_DIRECTORY, PrefsEffectDirKey, nil], nil]
#define DefaultPrefs         [NSMutableDictionary dictionaryWithObjectsAndKeys: DEFAULT_EFFECTS, PrefsEffectKey, [NSNumber numberWithBool:YES], PrefsEnabledKey, [NSNumber numberWithBool:false], PrefsRandomizedKey, nil]

@interface UIDevice (de)
- (BOOL)iOSVersionIsAtLeast:(NSString *)vers;
@end

#define IS_IOS_70_OR_LATER() [[UIDevice currentDevice] iOSVersionIsAtLeast: @"7.0"]
#define IS_IOS_60()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"6.0"] && !IS_IOS_70_OR_LATER())
#define IS_IOS_50()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"] && !IS_IOS_60() && !IS_IOS_70_OR_LATER())
#define IS_IOS_40()          ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"4.2"] && !IS_IOS_50() && !IS_IOS_60() && !IS_IOS_70_OR_LATER())

