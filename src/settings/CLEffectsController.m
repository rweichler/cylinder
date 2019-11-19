#import <Defines.h>
#import "CLEffectsController.h"
#import "CylinderSettings.h"

// #import "UDTableView.h"
#import "CLAlignedTableViewCell.h"
#include <objc/runtime.h>

static CLEffectsController *sharedController = nil;

@implementation UIDevice (OSVersion)
- (BOOL)iOSVersionIsAtLeast:(NSString*)version
{
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@implementation CLEffectsController
@synthesize effects = _effects, selectedEffects=_selectedEffects, clearButton=_clearButton;

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]))
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.editing = false;
        _tableView.allowsSelection = true;

        if(UIDevice.currentDevice.systemVersion.intValue >= 5)
        {
            _tableView.allowsMultipleSelection = false;
            _tableView.allowsSelectionDuringEditing = true;
            _tableView.allowsMultipleSelectionDuringEditing = true;
        }
		
		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];

        NSString *text = @"WARNING: combining certain 3D effects may cause lag";
        UIFont *font = [UIFont boldSystemFontOfSize:15];
        NSLineBreakMode mode = NSLineBreakByWordWrapping;

        CGSize size = {SCREEN_SIZE.width, 40};
        size =[text sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
        size.width = SCREEN_SIZE.width;

        UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        tableFooter.textColor = [UIColor blackColor];
        tableFooter.backgroundColor = [_tableView backgroundColor];
        tableFooter.opaque = YES;
        tableFooter.lineBreakMode = mode;
        tableFooter.numberOfLines = 0;
        tableFooter.font = font;
        tableFooter.textAlignment = NSTextAlignmentCenter;
        tableFooter.text = text;


        UIView *wrapperView = [[UIView alloc] initWithFrame:tableFooter.frame];
        [wrapperView addSubview:tableFooter];

        _tableView.tableFooterView = wrapperView;
        [wrapperView release];
        [tableFooter release];

        self.clearButton = [[UIBarButtonItem.alloc initWithTitle:LOCALIZE(@"RESET_EFFECTS", @"Clear") style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)] autorelease];
	}
    sharedController = self;
	return self;
}

- (void)addEffectsFromDirectory:(NSString *)directory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *directoryContents = [manager contentsOfDirectoryAtPath:directory error:nil];

    for (NSString *dirName in directoryContents)
    {
        NSString *path = [directory stringByAppendingPathComponent:dirName];

        BOOL isDir;
        if(![manager fileExistsAtPath:path isDirectory:&isDir] || !isDir) continue;

        NSArray *scripts = [manager contentsOfDirectoryAtPath:path error:nil];
        if(scripts.count == 0) continue;

        //NSMutableArray *effects = [NSMutableArray array];
        for(NSString *script in scripts)
        {
            CLEffect *effect = [CLEffect effectWithPath:[path stringByAppendingPathComponent:script]];
            if(effect)
                [self.effects addObject:effect];
        }
        //if(effects.count > 0)
        //    [self.effects setObject:effects forKey:dirName];
    }
    [self.effects sortUsingComparator:^NSComparisonResult(CLEffect *effect1, CLEffect *effect2)
    {
        return [effect1.name compare:effect2.name];
    }];
}

-(CLEffect *)effectWithName:(NSString *)name inDirectory:(NSString *)directory
{
    if(!name || !directory) return nil;

    //NSArray *effects = [self.effects valueForKey:directory];
    for(CLEffect *effect in self.effects)
    {
        if([effect.name isEqualToString:name] && [effect.directory isEqualToString:directory])
        {
            return effect;
        }
    }
    return nil;
}

- (void)refreshList
{
    //self.effects = [NSMutableDictionary dictionary];
    self.effects = [NSMutableArray array];
    CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;
    [self addEffectsFromDirectory:kEffectsDirectory];

    NSArray *effects = [ctrl.settings objectForKey:PrefsEffectKey];
    self.selectedEffects = [NSMutableArray array];

    if([effects isKindOfClass:NSArray.class])
    {
        for(NSDictionary *dict in effects)
        {
            NSString *name = [dict objectForKey:PrefsEffectKey];
            NSString *dir = [dict objectForKey:PrefsEffectDirKey];
            CLEffect *effect = [self effectWithName:name inDirectory:dir];
            effect.selected = true;
            if(effect)
                [self.selectedEffects addObject:effect];
        }
    }
    else
    {
        CLEffect *effect = [self effectWithName:DEFAULT_EFFECT inDirectory:DEFAULT_DIRECTORY];
        effect.selected = true;
        [self.selectedEffects addObject:effect];
    }
}

-(void)clear:(UIBarButtonItem *)clearButton
{
    if(clearButton != self.clearButton) return;

    for(CLEffect *effect in self.selectedEffects)
    {
        effect.selected = false;
        [self setCellIcon:effect.cell effect:effect];
    }

    self.selectedEffects = [NSMutableArray array];
    [_tableView reloadData];

    [self updateSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(!_initialized)
    {
        [self refreshList];
        _initialized = true;
    }
    [super viewWillAppear:animated];

    ((UINavigationItem *)self.navigationItem).rightBarButtonItem = self.clearButton;
}

- (void)dealloc
{
    sharedController = nil;
    self.selectedEffects = nil;
    self.effects = nil;
    self.clearButton = nil;
    [super dealloc];
}

- (NSString*)navigationTitle
{
    return @"Effects";
}

- (id)view
{
    return _tableView;
}

/* UITableViewDelegate / UITableViewDataSource Methods {{{ */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//self.effects.count;
}

-(NSString *)keyForIndex:(int)index
{
    int i = 0;
    for(NSString *key in self.effects)
    {
        if(i == index) return key;
        i++;
    }
    return nil;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;//[self keyForIndex:section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == self.effects.count) return 1;
    return self.effects.count;

    //return [[self.effects valueForKey:[self keyForIndex:section]] count];
}

-(void)setCellIcon:(UITableViewCell *)cell effect:(CLEffect *)effect
{
    if(effect.broken)
        cell.imageView.image = [UIImage imageWithContentsOfFile:BUNDLE_PATH "error.png"];
    else
        cell.imageView.image = nil;
}

-(CLEffect *)effectAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *key = [self keyForIndex:indexPath.section];
    //NSArray *effects = [self.effects valueForKey:key];
    CLEffect *effect = [self.effects objectAtIndex:indexPath.row];
    return effect;
}

-(id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLAlignedTableViewCell *cell = (CLAlignedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EffectCell"];
    if (!cell)
    {
        cell = [CLAlignedTableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EffectCell"].autorelease;
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    CLEffect *effect = [self effectAtIndexPath:indexPath];
    cell.effect.cell = nil;
    effect.cell.effect = nil;
    effect.cell = cell;
    cell.effect = effect;

    cell.textLabel.text = effect.name;
    cell.detailTextLabel.text = effect.directory;
    cell.selected = false;
    [self setCellIcon:cell effect:effect];

    cell.numberLabel.text = effect.selected ? [NSString stringWithFormat:@"%d", (int)([self.selectedEffects indexOfObject:effect] + 1)] : @"";

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing)
    {
        // deselect old one
        [tableView deselectRowAtIndexPath:indexPath animated:true];

        CLEffect *effect = [self effectAtIndexPath:indexPath];
        effect.selected = !effect.selected;

        if(effect.selected)
        {
            [self.selectedEffects addObject:effect];
        }
        else
        {
            effect.cell.numberLabel.text = @"";
            [self.selectedEffects removeObject:effect];
        }

        for(int i = 0; i < self.selectedEffects.count; i++)
        {
            CLEffect *e = [self.selectedEffects objectAtIndex:i];
            CLAlignedTableViewCell *cell = (CLAlignedTableViewCell *)e.cell;
            cell.numberLabel.text = [NSString stringWithFormat:@"%d", (i + 1)];
        }

        [self updateSettings];
    }
}

-(void)updateSettings
{
    // make the title changes
    CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;
    ctrl.selectedEffects = self.selectedEffects;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
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

    BOOL changed = false;
    NSArray *errors = [NSArray arrayWithContentsOfFile:ERROR_DIR];
    for(NSDictionary *effectDict in errors)
    {
        NSString *name = [effectDict valueForKey:PrefsEffectKey];
        NSString *folder = [effectDict valueForKey:PrefsEffectDirKey];
        CLEffect *effect = [self effectWithName:name inDirectory:folder];
        BOOL broken = [[effectDict valueForKey:@"broken"] boolValue];

        if(broken && !effect.broken) changed = true;

        effect.broken = broken;

        [self setCellIcon:effect.cell effect:effect];
    }
    if(changed) [(UITableView *)self.view reloadData];
}

static __attribute__((constructor)) void __wbsInit() {
    WBSAddMethod(PSViewController, hideNavigationBarButtons, $PSViewController$hideNavigationBarButtons, "v@:");
    WBSAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &luaErrorNotification, (CFStringRef)@"luaERROR", NULL, 0);
}
