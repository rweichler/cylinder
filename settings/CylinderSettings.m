#import "CylinderSettings.h"

#import "Defines.h"
#import "CLEffect.h"


@interface CylinderSettingsListController () {
	NSMutableDictionary *_settings;
}
@property (nonatomic, retain, readwrite) NSMutableDictionary *settings;
@end

@implementation CylinderSettingsListController
@synthesize settings = _settings;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {
		self.settings = [([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs) retain];
	}
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"CylinderSettings" target:self] retain];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:key];
}

- (id)readPreferenceValue:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    id plistValue = [self.settings objectForKey:key];

    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool: (![plistValue boolValue])];
    return plistValue;
}

- (void)visitWebsite:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://r333d.com"]];
}

- (void)visitTwitter:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/rweichler"]];
}

- (void)viewSource:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/rweichler/cylinder"]];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch *)cell.accessoryView;
	[_settings setObject: [NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];

	[self writeSettings];
	[self sendSettings];
}

- (void)setCurrentEffect:(CLEffect *)effect {
	if ([effect.name isEqualToString: [_settings objectForKey: PrefsEffectKey]])
		return;
	
	[_settings setObject:effect.name forKey:PrefsEffectKey];
	[_settings setObject:effect.pack forKey:PrefsPackKey];

	UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	cell.detailTextLabel.text = effect.name;
	
	[self sendSettings];
}

- (NSNumber *)enabled {
	return [self.settings objectForKey:PrefsEnabledKey];
}

- (void)setEnabled:(NSNumber *)enabled {
	[_settings setObject:enabled forKey:PrefsEnabledKey];
	[self sendSettings];
}

- (void)writeSettings {
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:self.settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

	if (!data)
		return;
	if (![data writeToFile:PREFS_PATH atomically:NO]) {
		NSLog(@"Cylinder: failed to write preferences. Permissions issue?");
		return;
	}
}

- (void)sendSettings {
	[self writeSettings];

	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification(r, (CFStringRef)kCylinderSettingsChanged, NULL, (CFDictionaryRef)self.settings, true);
}

- (void)suspend {
	[self writeSettings];
}

- (void)dealloc {
	// set the enabled value
	[self writeSettings];

	self.settings = nil;

	[super dealloc];
}

@end
