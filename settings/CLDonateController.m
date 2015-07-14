/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <Defines.h>
#import "CLDonateController.h"

// #import "UDTableView.h"
#include <objc/runtime.h>

#define BITCOIN_ADDRESS @"177JwbKv8msAQPVk8azEKMCuNBWHJbs1XT"
#define PAYPAL_URL @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=rweichler%40gmail%2ecom&lc=US&item_name=Reed%20Weichler&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"
#define VENMO_URL @"venmosdk://venmo.com?recipients=reedles&txn=pay&note=Cylinder%20Donation"

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
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    } else {//if section == 1
        if([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"venmo://"]]) {
            return 2;
        } else {
            return 1;
        }
    }
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
    if(indexPath.section == 0) {
        cell.imageView.image = nil;
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", @"\u2764\u2764\u2764\u2764 ", LOCALIZE(@"THANK_YOU", @"Thank you"), @" \u2764\u2764\u2764\u2764"];
    } else {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"PayPal";
            cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Applications/Preferences.app/Weibo.png"];
        } else {
            cell.textLabel.text = @"Venmo";
            cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Applications/Preferences.app/Twitter.png"];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if(indexPath.section == 0) {
        _player.currentTime = 0;
        [_player prepareToPlay];
        [_player play];
    } else {
        if(indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PAYPAL_URL]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:VENMO_URL]];
        } /* else if(BITCOIN) {
            UIPasteboard.generalPasteboard.string = BITCOIN_ADDRESS;
            [[UIAlertView.alloc initWithTitle:@"Address copied!"
                                message:nil
                                delegate:nil
                                cancelButtonTitle:@"Okay"
                                otherButtonTitles:nil].autorelease show];
        } */
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return (UITableViewCellEditingStyle)3;
}

@end
