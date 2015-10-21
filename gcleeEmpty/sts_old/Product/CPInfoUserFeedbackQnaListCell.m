#import "CPInfoUserFeedbackQnaListCell.h"

@interface CPInfoUserFeedbackQnaListCell ()
{
    UIImageView *_iconBgView;
	UILabel *_iconLabel;
	UILabel *_typeLabel;
	UIImageView *_arrowView;
	UILabel *_textLabel;
	UIImageView *_secretView;
	UILabel *_optionLabel;
	UIView *_bottomLineView;
}

@end

@implementation CPInfoUserFeedbackQnaListCell

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
	self.backgroundColor = UIColorFromRGB(0xffffff);
    
    _iconBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_iconBgView];
	
	_iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_iconLabel.font = [UIFont systemFontOfSize:12.f];
	_iconLabel.textAlignment = NSTextAlignmentCenter;
	_iconLabel.backgroundColor = [UIColor clearColor];
	[_iconBgView addSubview:_iconLabel];
	
	_typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_typeLabel.font = [UIFont systemFontOfSize:15.f];
	_typeLabel.backgroundColor = [UIColor clearColor];
	_typeLabel.textColor = UIColorFromRGB(0x333333);
	_typeLabel.textAlignment = NSTextAlignmentLeft;
	[self addSubview:_typeLabel];
	
	_arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_arrowView];
	
	_textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_textLabel.font = [UIFont systemFontOfSize:15.f];
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.textColor = UIColorFromRGB(0x333333);
	_textLabel.textAlignment = NSTextAlignmentLeft;
	_textLabel.backgroundColor = [UIColor clearColor];
	_textLabel.numberOfLines = 1;
	[self addSubview:_textLabel];
	
	_secretView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_secretView];
	
	
	_optionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_optionLabel.font = [UIFont systemFontOfSize:13.f];
	_optionLabel.backgroundColor = [UIColor clearColor];
	_optionLabel.textColor = UIColorFromRGB(0x7883a2);
	_optionLabel.textAlignment = NSTextAlignmentLeft;
	_optionLabel.numberOfLines = 1;
	[self addSubview:_optionLabel];

	
	_bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
	_bottomLineView.backgroundColor = UIColorFromRGB(0xededed);
	[self addSubview:_bottomLineView];
}

- (void)layoutSubviews
{
	NSString *iconStyle = self.dict[@"answerIcon"];
	
	UIColor *iconTextColor = nil;
	NSString *iconText = @"";
	
	if ([iconStyle isEqualToString:@"01"])
	{
		iconTextColor = UIColorFromRGB(0x666666);
		iconText = @"미답변";
        [_iconBgView setFrame:CGRectMake(10, 14, 38, 18)];
        [_iconBgView setImage:[UIImage imageNamed:@"answer_pd_no.png"]];
	}
	else
	{
		iconTextColor = UIColorFromRGB(0x4c6ce2);
		iconText = @"답변완료";
        [_iconBgView setFrame:CGRectMake(10, 14, 47, 18)];
        [_iconBgView setImage:[UIImage imageNamed:@"answer_pd_ok.png"]];
	}
	
	_iconLabel.text = iconText;
	_iconLabel.textColor = iconTextColor;
	_iconLabel.frame = CGRectMake(0, 0, CGRectGetWidth(_iconBgView.frame), CGRectGetHeight(_iconBgView.frame));
	
    
	NSString *typeStr = [NSString stringWithFormat:@"[%@]", self.dict[@"qnaDtlsCdNm"]];
	_typeLabel.text = typeStr;
	[_typeLabel sizeToFitWithFloor];
	_typeLabel.frame = CGRectMake(CGRectGetMaxX(_iconBgView.frame)+6.f,
								  _iconBgView.center.y-(_typeLabel.frame.size.height/2),
								  _typeLabel.frame.size.width,
								  _typeLabel.frame.size.height);
	
    
	UIImage *imgArrow = nil;
	NSString *openYn = self.dict[@"openYn"];
	if ([openYn isEqualToString:@"N"])	imgArrow = [UIImage imageNamed:@"bt_s_arrow_down_02"];
	else								imgArrow = [UIImage imageNamed:@"bt_s_arrow_up_02"];
	
	_arrowView.image = imgArrow;
	_arrowView.frame = CGRectMake(self.frame.size.width-imgArrow.size.width-10.f,
								  (self.frame.size.height/2)-(imgArrow.size.height/2),
								  imgArrow.size.width, imgArrow.size.height);
	
	CGFloat maxWidth = 0.f;
	UIImage *imgSecret = [UIImage imageNamed:@"ic_pd_lock.png"];
	NSString *secretYn = self.dict[@"secretYn"];
	
	if ([secretYn isEqualToString:@"Y"])
	{
		maxWidth = self.frame.size.width - (CGRectGetMaxX(_typeLabel.frame)+3.f+_arrowView.frame.size.width+10.f+5.f+7.f+imgSecret.size.width);
		_secretView.hidden = NO;
	}
	else
	{
		maxWidth = self.frame.size.width - (CGRectGetMaxX(_typeLabel.frame)+3.f+_arrowView.frame.size.width+10.f+7.f);
		_secretView.hidden = YES;
	}
	
	NSString *subjectStr = self.dict[@"brdInfoSbjct"];
	_textLabel.text = subjectStr;
	_textLabel.frame = CGRectMake(CGRectGetMaxX(_typeLabel.frame)+3.f,
								  _typeLabel.frame.origin.y,
								  0.f,
								  _typeLabel.frame.size.height);
	[_textLabel sizeToFitWithVersionHoldHeight];
	
	if (_textLabel.frame.size.width > maxWidth)
	{
		_textLabel.frame = CGRectMake(_textLabel.frame.origin.x,
									  _textLabel.frame.origin.y,
									  maxWidth,
									  _textLabel.frame.size.height);
	}
	
	if (_secretView.hidden == NO)
	{
		_secretView.image = imgSecret;
		_secretView.frame = CGRectMake(CGRectGetMaxX(_textLabel.frame)+4,
									   _textLabel.center.y-(imgSecret.size.height/2),
									   imgSecret.size.width,
									   imgSecret.size.height);
	}
	
    //구매/비구매
    NSString *buyYN = [self.dict[@"buyYN"] isEqualToString:@"Y"]?@"구매":@"비구매";
    
	NSString *optionStr = [NSString stringWithFormat:@"%@ / %@ / %@", self.dict[@"memId"], self.dict[@"createDt"], buyYN];
	_optionLabel.text = optionStr;
	_optionLabel.frame = CGRectMake(10.f,
									CGRectGetMaxY(_iconBgView.frame)+6.f,
									self.frame.size.width-20.f-imgArrow.size.width,
									0.f);
	[_optionLabel sizeToFitWithVersionHoldWidth];
	
	_bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
