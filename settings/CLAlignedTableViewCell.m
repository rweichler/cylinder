#import "CLAlignedTableViewCell.h"

#define MARGIN 44
@implementation CLAlignedTableViewCell
- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect cvf = self.contentView.frame;
    CGFloat width = 0; //60;
    //self.imageView.frame = CGRectMake(0.0, 0.0, width, cvf.size.height-1);
    //self.imageView.contentMode = UIViewContentModeCenter;//|UIViewContentModeScaleAspectFit;

    CGRect frame = CGRectMake(width + MARGIN,
                              self.textLabel.frame.origin.y,
                              cvf.size.width - width - 2*MARGIN,
                              self.textLabel.frame.size.height);
    self.textLabel.frame = frame;

    frame = CGRectMake(width + MARGIN,
                       self.detailTextLabel.frame.origin.y,
                       cvf.size.width - width - 2*MARGIN,
                       self.detailTextLabel.frame.size.height);   
    self.detailTextLabel.frame = frame;
}
@end
