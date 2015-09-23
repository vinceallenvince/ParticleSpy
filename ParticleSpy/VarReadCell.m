#import "VarReadCell.h"

@implementation VarReadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    // TODO: is this necessary since we set allowSelection = NO in table view?
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        
        // TODO: add horizontal padding
        self.val = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        self.val.textAlignment = NSTextAlignmentCenter;
        UILabel *val = self.val;
        val.adjustsFontSizeToFitWidth = YES;
        [val setFont:[UIFont fontWithName:@"HelveticaNeue" size:72.0f]];
        [val setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:val];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(val);
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[val]-|"
                                                                       options: 0
                                                                       metrics:nil
                                                                         views:views];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[val]-|"
                                                              options: 0
                                                              metrics:nil
                                                                views:views];
        [self.contentView addConstraints:constraints];
    }
    return self;
}

/*- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}*/

@end
