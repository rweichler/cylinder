#import "Defines.h"
#import "CLEffectsController.h"
#import "CylinderSettings.h"

// #import "UDTableView.h"
#import "CLAlignedTableViewCell.h"
#include <objc/runtime.h>

static CLEffectsController *sharedController = nil;

@implementation UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString*)version {
    NSComparisonResult result = [[self systemVersion] compare:version options:NSNumericSearch];
    return (result == NSOrderedDescending || result == NSOrderedSame);
}
@end

@interface UITableView (Private)
- (NSArray *) indexPathsForSelectedRows;
@property(nonatomic) BOOL allowsMultipleSelectionDuringEditing;
@end

@interface PSViewController(Private)
-(void)viewWillAppear:(BOOL)animated;
@end


@implementation CLEffectsController
@synthesize effects = _effects;
@synthesize packs  = _packs;

- (id)initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size])) {		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:NO];
		[_tableView setAllowsSelection:YES];

		if ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"]) {
			[_tableView setAllowsMultipleSelection:NO];
			[_tableView setAllowsSelectionDuringEditing:YES];
			[_tableView setAllowsMultipleSelectionDuringEditing:YES];
		}
		
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];			
	}
    sharedController = self;
	return self;
}

- (void)addEffectsFromDirectory:(NSString *)directory pack: (NSString *)pack {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *diskEffects = [manager contentsOfDirectoryAtPath:directory error:nil];
	
	for (NSString *scriptName in diskEffects) {
		NSString *path = [directory stringByAppendingPathComponent:scriptName];

		CLEffect *effect = [CLEffect effectWithPath:path];
		effect.pack = pack ? pack : @"";
		
		
		if (effect) {
			NSString *effectIdentifier = [effect.pack stringByAppendingFormat: @".%@", effect.name];
			CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;

			if ([[ctrl.settings objectForKey: PrefsBrokenKey] containsObject: effectIdentifier])
				effect.broken = true;
			
			[self.effects addObject:effect];
		}
	}
}

- (void)refreshList {
	self.effects = [NSMutableArray array];
	self.packs  = [NSMutableArray array];
	CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;
	[self addEffectsFromDirectory: kEffectsDirectory pack: nil];
			
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	[self.effects sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release]; // sort
	
	selectedEffect = [ctrl.settings objectForKey:PrefsEffectKey];
	if (!selectedEffect)
		selectedEffect = @"Cube (inside)";
}

- (void)viewWillAppear:(BOOL)animated {
	[self refreshList];
    [super viewWillAppear:animated];
}

- (NSArray *)currentEffects {
	return self.effects;
}

- (void)dealloc { 
    sharedController = nil;
	self.effects = nil;
	[super dealloc];
}

- (NSString*)navigationTitle {
	return @"Effects";
}

- (id)view {
	return _tableView;
}

/* UITableViewDelegate / UITableViewDataSource Methods {{{ */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentEffects.count;
}

-(void)setCellIcon:(UITableViewCell *)cell effect:(CLEffect *)effect
{
    if(effect.broken)
        cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CylinderSettings.bundle/error.png"];
    else
        cell.imageView.image = nil;
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CLAlignedTableViewCell *cell = (CLAlignedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EffectCell"];
    if (!cell) {
        cell = [[[CLAlignedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EffectCell"] autorelease];
    }
    
	CLEffect *effect = [self.currentEffects objectAtIndex:indexPath.row];
	cell.textLabel.text = effect.name;	
	cell.selected = false;
    [self setCellIcon:cell effect:effect];

	if ([effect.name isEqualToString: selectedEffect] && !tableView.isEditing) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else if (!tableView.isEditing) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!tableView.isEditing) {
		// deselect old one
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
		UITableViewCell *old = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: [[self.currentEffects valueForKey:@"name"] indexOfObject: selectedEffect] inSection: 0]];
		if (old)
			old.accessoryType = UITableViewCellAccessoryNone;


		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		// check it off
		cell.accessoryType = UITableViewCellAccessoryCheckmark;

		CLEffect *effect = (CLEffect*)[self.currentEffects objectAtIndex:indexPath.row];
	
		// make the title changes
		CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;

        ctrl.currentEffect = effect;
	
		selectedEffect = effect.name;

	} else {
		// future pack functionality
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
	return (UITableViewCellEditingStyle)3;
}

@end


// borrowed from winterboard
#define WBSAddMethod(_class, _sel, _imp, _type) \
    if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
        class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)

void $PSViewController$hideNavigationBarButtons(PSRootController *self, SEL _cmd) {
}

id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize) {
    return [self init];
}

#define ERROR_DIR @"/var/mobile/Library/Logs/Cylinder/.errornotify"

static inline void luaErrorNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    CLEffectsController *self = sharedController;
    if(!self) return;
    BOOL isDir;
    if(![NSFileManager.defaultManager fileExistsAtPath:ERROR_DIR isDirectory:&isDir] || isDir) return;
    NSData *data = [NSData dataWithContentsOfFile:ERROR_DIR];
    NSArray *info = [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] componentsSeparatedByString:@"\n"];
    if(info.count != 2) return;



    UITableView *tableView = self.view;
    NSString *key = info[0];
    BOOL broken = [info[1] boolValue];

    for(int i = 0; i < self.currentEffects.count; i++)
    {
        CLEffect *effect = self.currentEffects[i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if([effect.name isEqualToString:key])
        {
            effect.broken = broken;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self setCellIcon:cell effect:effect];
        }
    }
}

static __attribute__((constructor)) void __wbsInit() {
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &luaErrorNotification, (CFStringRef)@"luaERROR", NULL, 0);
}
