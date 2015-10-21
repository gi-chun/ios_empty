#import "CPInfoUserFeedbackQnaAnswerCell.h"

@interface CPInfoUserFeedbackQnaAnswerCell ()
{
	UIImageView *_iconView;
	UILabel *_textLabel;
    UIView *_bottomLineView;
}

@end

@implementation CPInfoUserFeedbackQnaAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = UIColorFromRGB(0xf2f2f2);
	
	_iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_iconView];
	
	_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.textColor = UIColorFromRGB(0x525252);
	_textLabel.font = [UIFont systemFontOfSize:13.f];
	_textLabel.numberOfLines = 100;
	_textLabel.textAlignment = NSTextAlignmentLeft;
	[self addSubview:_textLabel];
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomLineView.backgroundColor = UIColorFromRGB(0xededed);
    [self addSubview:_bottomLineView];
}

- (void)layoutSubviews
{
	UIImage *imgIcon = [UIImage imageNamed:@"ic_pd_answer.png"];
	_iconView.image = imgIcon;
	_iconView.frame = CGRectMake(10.f, 14.f, imgIcon.size.width, imgIcon.size.height);

	NSString *text = self.dict[@"text"];
	
	CGFloat textWidth = self.frame.size.width-(CGRectGetMaxX(_iconView.frame)+11.f+10.f);
	_textLabel.text = text;
	_textLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+11.f, 16.f, textWidth, 0);
	[_textLabel sizeToFitWithVersionHoldWidth];
    
    _bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
