#import <Preferences/PSViewController.h>
#import "CLEffect.h"

@interface CLEffectsController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableDictionary *_effects;
    NSMutableArray *_selectedEffects;
}
@property (nonatomic, retain) NSMutableDictionary *effects;
@property (nonatomic, retain) NSMutableArray *selectedEffects;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
@end 
