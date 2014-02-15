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

#import "CLAlignedTableViewCell.h"

#define MARGIN 0
#define IMAGE_PADDING 10
@implementation CLAlignedTableViewCell
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect cvf = self.contentView.frame;
    CGFloat width = 44; //60;
    self.imageView.frame = CGRectMake(IMAGE_PADDING, IMAGE_PADDING, width - IMAGE_PADDING*2, cvf.size.height-1 - IMAGE_PADDING*2);
    //self.imageView.contentMode = UIViewContentModeCenter;//|UIViewContentModeScaleAspectFit;

    self.textLabel.frame = CGRectMake(width + MARGIN,
                              self.textLabel.frame.origin.y,
                              cvf.size.width - width - 2*MARGIN,
                              self.textLabel.frame.size.height);

    self.detailTextLabel.frame = CGRectMake(width + MARGIN,
                       self.detailTextLabel.frame.origin.y,
                       cvf.size.width - width - 2*MARGIN,
                       self.detailTextLabel.frame.size.height);
}
@end
