#define IOS_VERSION UIDevice.currentDevice.systemVersion.intValue
#define SCREEN_SIZE UIScreen.mainScreen.bounds.size
static const CATransform3D DEFAULT_TRANSFORM = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};
#define CYLINDER_DIR "/Library/Cylinder/"

#define PREFS_PATH           [NSString stringWithFormat:@"%@/Library/Preferences/com.r333d.cylinder.plist", NSHomeDirectory()]
#define PrefsEffectKey        @"effect"
#define kCylinderSettingsChanged         @"com.r333d.cylinder/settingsChanged"
