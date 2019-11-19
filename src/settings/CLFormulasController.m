#import <Defines.h>
#import "CLFormulasController.h"
#import "CylinderSettings.h"

// #import "UDTableView.h"
#import "CLAlignedTableViewCell.h"
#include <objc/runtime.h>

#define ADD_SECTION 0
#define FORMULA_SECTION 1

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


@implementation CLFormulasController
@synthesize formulas=_formulas,selectedFormula=_selectedFormula,editButton=_editButton;

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]))
    {
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        //_tableView.allowsSelection = true;
        //_tableView.allowsSelectionDuringEditing = true;

        /*
		if ([[UIDevice currentDevice] iOSVersionIsAtLeast: @"5.0"]) {
			[_tableView setAllowsMultipleSelection:NO];
			[_tableView setAllowsSelectionDuringEditing:YES];
			[_tableView setAllowsMultipleSelectionDuringEditing:YES];
		}
        */

		if ([self respondsToSelector:@selector(setView:)])
			[self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];	

        self.editButton = [[UIBarButtonItem.alloc initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed:)] autorelease];
	}
	return self;
}

- (void)refreshList
{
    CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;

    NSDictionary *formulas = [ctrl.settings objectForKey:PrefsFormulaKey];
    if(!formulas || ![formulas isKindOfClass:NSDictionary.class])
    {
        self.formulas = [NSMutableDictionary dictionary];
    }
    else
    {
        self.formulas = formulas.mutableCopy;
        /*
        self.formulas = [NSMutableDictionary dictionaryWithCapacity:formulas.count];
        for(NSString *key in formulas)
        {
            NSArray *effectDicts = [formulas objectForKey:key];
            NSMutableArray *effects = [NSMutableArray arrayWithCapacity:effectDicts.count];
            for(NSDictionary *effectDict in effectDicts)
            {
                NSString *dir = [effectDict objectForKey:PrefsEffectDirKey];
                NSString *name = [effectDict objectForKey:PrefsEffectKey];

                if(dir && name)
                {
                    NSString *path = [[kEffectsDirectory stringByAppendingPathComponent:dir] stringByAppendingPathComponent:name];
                    CLEffect *effect = [CLEffect effectWithPath:path];
                    if(effect)
                        [effects addObject:effectDict];
                }
            }
            [self.formulas setObject:effects forKey:key];
        }
        */
    }

    self.selectedFormula = [ctrl.settings objectForKey:PrefsSelectedFormulaKey];
}

-(void)showAlertWithText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:LOCALIZE(@"CANCEL", @"Cancel") otherButtonTitles:LOCALIZE(@"CREATE_FORMULA", @"Create Formula"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].placeholder = LOCALIZE(@"FORMULA_NAME", @"Formula name");
    [alert show];

}

-(void)createFormulaWithName:(NSString *)name
{
    CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;
    NSArray *effects = [ctrl.settings objectForKey:PrefsEffectKey];

    if(!effects)
    {
        [self showAlertWithText:@"IT FUCKED UP!"];
        return;
    }

    [self.formulas setObject:effects forKey:name];
    self.selectedFormula = name;
    [self updateSettings];
    [_tableView reloadData];
}

-(void)editButtonPressed:(UIBarButtonItem *)button
{
    if(button != self.editButton) return;

    if(_tableView.editing)
    {
        [_tableView setEditing:false animated:true];
        button.title = @"Edit";
    }
    else
    {
        [_tableView setEditing:true animated:true];
        button.title = @"Done";
    }

}

static NSString *_theFormulaName;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex)
    {
        //do nothing
    }
    else if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
    {
        NSString *name = [alertView textFieldAtIndex:0].text;
        
        if(name.length == 0)
        {
            [self showAlertWithText:@"You didn't type anything."];
        }
        else if([self.formulas objectForKey:name])
        {
            _theFormulaName = [name retain];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LOCALIZE(@"FORMULA_ALREADY_EXISTS", @"A formula with that name already exists.") delegate:self cancelButtonTitle:LOCALIZE(@"CANCEL", @"Cancel") otherButtonTitles:LOCALIZE(@"OVERWRITE_IT", @"Overwrite it"), nil];
            [alert show];
        }
        else
        {
            [self createFormulaWithName:name];
        }
    }
    else if(_theFormulaName)
    {
        [self createFormulaWithName:[_theFormulaName autorelease]];
        _theFormulaName = nil;
    }
    [alertView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(!_initialized)
    {
        [self refreshList];
        _initialized = true;
    }
    [super viewWillAppear:animated];
    //_tableView.editing = true;

    ((UINavigationItem *)self.navigationItem).rightBarButtonItem = self.editButton;
}

- (void)dealloc
{
    self.formulas = nil;
    self.selectedFormula = nil;
    self.editButton = nil;
    [super dealloc];
}

- (NSString*)navigationTitle
{
    return @"Formulas";
}

- (id)view
{
    return _tableView;
}

/* UITableViewDelegate / UITableViewDataSource Methods {{{ */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)keyForIndex:(int)index
{
    int i = 0;
    for(NSString *key in self.formulas)
    {
        if(i == index) return key;
        i++;
    }
    return nil;
}

-(NSUInteger)indexForKey:(NSString *)key
{
    NSUInteger i = 0;
    for(NSString *k in self.formulas)
    {
        if([k isEqualToString:key]) return i;
        i++;
    }
    return NSNotFound;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == ADD_SECTION)
        return 1;
    else if(section == FORMULA_SECTION)
        return self.formulas.count;

    return 0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == ADD_SECTION) return false;
    // Return NO if you do not want the specified item to be editable.
    return true;
}


-(id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EffectCell"];
    if (!cell)
    {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EffectCell"].autorelease;
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        //cell.editing = true;
        //cell.shouldIndentWhileEditing = false;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selected = false;

    if(indexPath.section == ADD_SECTION)
    {
        cell.textLabel.text = LOCALIZE(@"CREATE_NEW_FORMULA", @"Create new formula");
        cell.imageView.image = [UIImage imageWithContentsOfFile:BUNDLE_PATH "plus.png"];
    }
    else if(indexPath.section == FORMULA_SECTION)
    {
        NSString *name = [self keyForIndex:indexPath.row];
        BOOL selected = [name isEqualToString:self.selectedFormula];
        cell.textLabel.text = name;
        if(selected)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.imageView.image = nil;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *key = [self keyForIndex:indexPath.row];
        [self.formulas removeObjectForKey:key];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateSettings];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == ADD_SECTION)
    {
        CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;

        NSDictionary *effects = [ctrl.settings objectForKey:PrefsEffectKey];

        if(effects.count == 0)
        {
            [[UIAlertView.alloc initWithTitle:LOCALIZE(@"NO_EFFECTS_ENABLED_TITLE", @"You have no effects enabled!") message:LOCALIZE(@"NO_EFFECTS_ENABLED_DESC", @"Go back to the effects list, enable some effects, then come back here and create a new formula.") delegate:self cancelButtonTitle:LOCALIZE(@"NO_EFFECTS_ENABLED_OK", @"Aight cool") otherButtonTitles:nil] show];
        }
        else
        {
            [self showAlertWithText:LOCALIZE(@"CREATE_FORMULA_INFO", @"The new formula will have whatever effects you have enabled right now.")];
        }
    }
    else if(indexPath.section == FORMULA_SECTION)
    {
        if(self.selectedFormula)
        {
            int index = [self indexForKey:self.selectedFormula];
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:FORMULA_SECTION]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        self.selectedFormula = [self keyForIndex:indexPath.row];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

        [self updateSettings];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

-(void)updateSettings
{
    // make the title changes
    CylinderSettingsListController *ctrl = (CylinderSettingsListController*)self.parentController;
    ctrl.formulas = self.formulas;
    ctrl.selectedFormula = self.selectedFormula;
    [ctrl sendSettings];
}

@end
