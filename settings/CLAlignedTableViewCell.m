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
