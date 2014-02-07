#import <Preferences/PSViewController.h>

@interface CLEffectsController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_effects;
	NSMutableArray *_packs;
	NSString *selectedEffect;
}
@property (nonatomic, retain) NSMutableArray *effects;
@property (nonatomic, retain) NSMutableArray *packs;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
- (NSArray *)currentEffects;
@end 
