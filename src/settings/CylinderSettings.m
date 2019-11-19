#import "CylinderSettings.h"
#import <Defines.h>
#import "twitter.h"
#import "CLEffect.h"

@interface PSListController()
-(id)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end

@interface CylinderSettingsListController()
{
    NSMutableDictionary *_settings;
    NSString *_defaultFooterText;
}
@property (nonatomic, retain, readwrite) NSMutableDictionary *settings;
@end

@implementation CylinderSettingsListController
@synthesize settings = _settings;

- (id)initForContentSize:(CGSize)size
{
    if ((self = [super initForContentSize:size])) {
        self.settings = [([NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PATH] ?: DefaultPrefs) retain];
        if(![[_settings valueForKey:PrefsEffectKey] isKindOfClass:NSArray.class]) [_settings setValue:nil forKey:PrefsEffectKey];
        _defaultFooterText = [[[NSDictionary dictionaryWithContentsOfFile:@"/Library/PreferenceBundles/CylinderSettings.bundle/en.lproj/CylinderSettings.strings"] objectForKey:@"FOOTER_TEXT"] retain];
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

-(void)visitBarrel:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.aaronash.barrel"]];
}

- (void)visitTwitter:(id)sender {
    open_twitter();
}

- (void)visitWeibo:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://weibo.cn/r333d"]];
}

- (void)visitGithub:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/rweichler/cylinder"]];
}

- (void)visitReddit:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://reddit.com/r/cylinder"]];
}

- (void)respring:(id)sender {
	// set the enabled value
	UITableViewCell *cell = [(UITableView*)self.table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	UISwitch *swit = (UISwitch *)cell.accessoryView;
	[_settings setObject: [NSNumber numberWithBool:swit.on] forKey:PrefsEnabledKey];

	[self writeSettings];
	[self sendSettings];
}

-(void)setSelectedEffects:(NSArray *)effects
{
    NSMutableString *text = [NSMutableString string];
    NSMutableArray *toWrite = [NSMutableArray arrayWithCapacity:effects.count];
    for(CLEffect *effect in effects)
    {
        if(!effect.name || !effect.directory) continue;

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:effect.name, PrefsEffectKey, effect.directory, PrefsEffectDirKey, nil];
        [toWrite addObject:dict];

        [text appendString:effect.name];
        if(effect != effects.lastObject)
        {
            [text appendString:@", "];
        }
    }

    UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailTextLabel.text = text;

    [_settings setObject:toWrite forKey:PrefsEffectKey];
    self.selectedFormula = nil;
    [self sendSettings];
}

-(void)setFormulas:(NSDictionary *)formulas
{
    [_settings setObject:formulas forKey:PrefsFormulaKey];
}

-(void)setSelectedFormula:(NSString *)formula
{
    if(!formula)
    {
        [_settings removeObjectForKey:PrefsSelectedFormulaKey];
        return;
    }

    [_settings setObject:formula forKey:PrefsSelectedFormulaKey];

    NSDictionary *formulas = [_settings objectForKey:PrefsFormulaKey];
    NSArray *effects = [formulas objectForKey:formula];

    if(effects)
        [_settings setObject:effects forKey:PrefsEffectKey];

}

- (NSNumber *)enabled {
	return [self.settings objectForKey:PrefsEnabledKey];
}

- (void)setEnabled:(NSNumber *)enabled {
	[_settings setObject:enabled forKey:PrefsEnabledKey];
	[self sendSettings];
}

-(NSNumber *)randomized
{
    return [self.settings objectForKey:PrefsRandomizedKey];
}

-(void)setRandomized:(NSNumber *)randomized
{
    [_settings setObject:randomized forKey:PrefsRandomizedKey];
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

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 1)
        return LOCALIZE(@"FOOTER_TEXT", _defaultFooterText);
    else
        return [super tableView:tableView titleForFooterInSection:section];
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
    [_defaultFooterText release];

	[super dealloc];
}

@end
