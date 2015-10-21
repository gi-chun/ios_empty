#import "CPErrorContentsView.h"

@interface CPErrorContentsView ()
{
	UIImageView *errorIconView;
	UILabel *_messageLabel;
	UIButton *_refreshButton;
}

@end

@implementation CPErrorContentsView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
	
	errorIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:errorIconView];
	
	_messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_messageLabel.text = @"";
	_messageLabel.textColor = UIColorFromRGB(0xb8b8b8);
    _messageLabel.font = [UIFont systemFontOfSize:14];
	_messageLabel.textAlignment = NSTextAlignmentCenter;
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.numberOfLines = 5;
	[self addSubview:_messageLabel];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_refreshButton setTitle:@"새로고침" forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"btn_medium_orange_nor.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"btn_medium_orange_press.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(onClickedRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_refreshButton];
}

- (void)layoutSubviews
{
	UIImage *imgIcon = nil;
	
	if ([self.errorIcon isEqual:[NSNull null]] || [self.errorIcon length] == 0) {
		imgIcon = [UIImage imageNamed:@"nodata_icon_error.png"];
	}
	else {
		imgIcon = [UIImage imageNamed:self.errorIcon];
	}

	CGFloat iconWidth = imgIcon.size.width;
	CGFloat iconHeight = imgIcon.size.height;
	CGFloat startY = ((self.frame.size.height/10)*4) - (iconHeight/2);

	errorIconView.image = imgIcon;
	errorIconView.frame = CGRectMake((self.frame.size.width/2)-(iconWidth/2), startY, iconWidth, iconHeight);
	
	_messageLabel.text = self.errorText;
	_messageLabel.frame = CGRectMake(10, CGRectGetMaxY(errorIconView.frame)+12.f, self.frame.size.width-20.f, 0.f);
	[_messageLabel sizeToFitWithVersionHoldWidth];
	
	_messageLabel.frame = CGRectMake((self.frame.size.width/2)-(_messageLabel.frame.size.width)/2,
									 _messageLabel.frame.origin.y,
									 _messageLabel.frame.size.width,
									 _messageLabel.frame.size.height);

	if (self.isRetryButton) {
		CGFloat buttonWidth = 200.0f;
		CGFloat buttonHeight = 45.0f;
		_refreshButton.frame = CGRectMake((self.frame.size.width/2)-(buttonWidth/2),
										  CGRectGetMaxY(_messageLabel.frame)+20.f, buttonWidth, buttonHeight);
		
		_refreshButton.hidden = NO;
	}
	else {
		_refreshButton.hidden = YES;
		_refreshButton.frame = CGRectZero;
	}
}

- (void)onClickedRefreshButton:(id)sender
{
	DELEGATE_CALL2(_delegate,
				   CPErrorContentsView:didClickedRefreshButton:,
				   self,
				   sender);
}

@end
