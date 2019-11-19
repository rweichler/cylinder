#import <Preferences/PSViewController.h>
#import <Preferences/PSRootController.h>
#import "CLEffect.h"

@interface CLEffectsController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_effects;
    NSMutableArray *_selectedEffects;
    BOOL _initialized;
}
@property (nonatomic, retain) NSMutableArray *effects;
@property (nonatomic, retain) NSMutableArray *selectedEffects;
@property (nonatomic, strong) UIBarButtonItem *clearButton;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
@end 
