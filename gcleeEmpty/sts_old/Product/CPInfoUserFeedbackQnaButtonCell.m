#import "CPInfoUserFeedbackQnaButtonCell.h"

@interface CPInfoUserFeedbackQnaButtonCell ()
{
	UIButton *_button;
	UIImageView *_iconView;
	UIImageView *_arrowView;
	UIView *_bottomLineView;
}

@end

@implementation CPInfoUserFeedbackQnaButtonCell

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
	self.backgroundColor = UIColorFromRGB(0xfafafa);
	
	_button = [UIButton buttonWithType:UIButtonTypeCustom];
	_button.frame = CGRectZero;
	[_button setTitle:@"Q&A쓰기" forState:UIControlStateNormal];
	[_button setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
	[_button.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
	[_button addTarget:self action:@selector(pressedQnaWriteButton:) forControlEvents:UIControlEventTouchUpInside];
	
	_iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_button addSubview:_iconView];
	
	_arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_button addSubview:_arrowView];
	
	[self addSubview:_button];
	
	_bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
	_bottomLineView.backgroundColor = UIColorFromRGB(0xe5e5e5);
	[self addSubview:_bottomLineView];
}

- (void)layoutSubviews
{
	UIImage *imgBtnBgNor = [UIImage imageNamed:@"btn_large_white_nor.png"];
	UIImage *imgBtnBgHil = [UIImage imageNamed:@"btn_large_white_press.png"];
	
	imgBtnBgNor = [imgBtnBgNor resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	imgBtnBgHil = [imgBtnBgHil resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	
	_button.frame = CGRectMake(10.f, 7.f, self.frame.size.width-20.f, imgBtnBgNor.size.height);
	[_button setBackgroundImage:imgBtnBgNor forState:UIControlStateNormal];
	[_button setBackgroundImage:imgBtnBgHil forState:UIControlStateHighlighted];
	
	UIImage *imgIcon = [UIImage imageNamed:@"detail_review_list_icon_qa.png"];
	_iconView.image = imgIcon;
	_iconView.frame = CGRectMake(_button.titleLabel.frame.origin.x-imgIcon.size.width,
								 _button.titleLabel.center.y-(imgIcon.size.height/2),
								 imgIcon.size.width,
								 imgIcon.size.height);
	
	UIImage *imgArrow = [UIImage imageNamed:@"detail_review_list_icon_qa_arrow.png"];
	_arrowView.image = imgArrow;
	_arrowView.frame = CGRectMake(CGRectGetMaxX(_button.titleLabel.frame)+7.f,
								  _button.titleLabel.center.y-(imgArrow.size.height/2),
								  imgArrow.size.width,
								  imgArrow.size.height);
	
	_bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)pressedQnaWriteButton:(id)sender
{
	DELEGATE_CALL2(self.delegate,
				   CPInfoUserFeedbackQnaButtonCell:onClickQnaWriteButton:,
				   self,
				   sender);
}

@end
