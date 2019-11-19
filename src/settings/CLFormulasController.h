#import <Preferences/PSViewController.h>
#import "CLEffect.h"

@interface CLFormulasController : PSViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	UITableView *_tableView;
	NSMutableDictionary *_formulass;
    NSString *_selectedFormula;
    BOOL _initialized;
}
@property (nonatomic, retain) NSMutableDictionary *formulas;
@property (nonatomic, retain) NSString *selectedFormula;
@property (nonatomic, strong) UIBarButtonItem *editButton;
// + (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (NSString*)navigationTitle;
- (void)refreshList;
@end 
