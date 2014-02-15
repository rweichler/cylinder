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
