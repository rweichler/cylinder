#import <Defines.h>
#import "CLDonateController.h"

// #import "UDTableView.h"
#include <objc/runtime.h>

#define TEXT_SECTION 0
#define PAYPAL_SECTION 1
#define BITCOIN_SECTION 2
#define BITCOIN_ADDRESS @"177JwbKv8msAQPVk8azEKMCuNBWHJbs1XT"
#define PAYPAL_URL @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=rweichler%40gmail%2ecom&lc=US&item_name=Reed%20Weichler&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"

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


@implementation CLDonateController

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]))
    {
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

        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:true error:&sessionError];

        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:BUNDLE_PATH "iloveyou.mp3"] error:&error];
        if(!error)
        {
            [_player prepareToPlay];
        }
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [_player stop];
    [_player release];
    [super dealloc];
}

- (NSString*)navigationTitle
{
    return @"Donate";
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

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case BITCOIN_SECTION:
            return @"Bitcoin (tap to copy address)";
        case PAYPAL_SECTION:
            return @"Paypal";
    }
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yeah"];
    if(!cell)
    {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EffectCell"].autorelease;
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    switch(indexPath.section)
    {
        case TEXT_SECTION:
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", @"\u2764\u2764\u2764\u2764 ", LOCALIZE(@"THANK_YOU", @"Thank you"), @" \u2764\u2764\u2764\u2764"];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        break;
        case BITCOIN_SECTION:
            cell.textLabel.text = BITCOIN_ADDRESS;
        break;
        case PAYPAL_SECTION:
            cell.textLabel.text = LOCALIZE(@"PAYPAL", @"Tap here to go to Safari and donate via Paypal");
        break;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if(indexPath.section == BITCOIN_SECTION)
    {
        UIPasteboard.generalPasteboard.string = BITCOIN_ADDRESS;
        [[UIAlertView.alloc initWithTitle:@"Address copied!" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil].autorelease show];
    }
    else if(indexPath.section == PAYPAL_SECTION)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PAYPAL_URL]];
    }
    else
    {
        _player.currentTime = 0;
        [_player prepareToPlay];
        [_player play];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return (UITableViewCellEditingStyle)3;
}

@end
