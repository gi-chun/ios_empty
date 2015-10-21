#import "CPDescriptionBottomPostItem.h"

@interface CPDescriptionBottomPostItem ()
{
	NSDictionary *_item;
	
	UIImageView *_iconView;
//	UILabel *_iconLabel;
//	UIView *_iconBarView;
	UILabel *_descLabel;
	UILabel *_optionLabel;
	UILabel *_etcLabel;
	
	UIView *_bottomLineView;
	BOOL _lastItem;
}

@end

@implementation CPDescriptionBottomPostItem

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item lastItem:(BOOL)lastItem
{
	if (self = [super initWithFrame:frame])
	{
		if (item) {
			_item = item;
		}
		
		_lastItem = lastItem;
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
	
	_iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_iconView];
	
//	_iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	_iconLabel.backgroundColor = [UIColor clearColor];
//	_iconLabel.font = [UIFont boldSystemFontOfSize:12];
//	_iconLabel.textAlignment = NSTextAlignmentLeft;
//	_iconLabel.numberOfLines = 1;
//	[self addSubview:_iconLabel];
	
//	_iconBarView = [[UIView alloc] initWithFrame:CGRectZero];
//	_iconBarView.backgroundColor = UIColorFromRGB(0xeeeeee);
//	[self addSubview:_iconBarView];
	
	_descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_descLabel.backgroundColor = [UIColor clearColor];
	_descLabel.font = [UIFont systemFontOfSize:14.f];
	_descLabel.textAlignment = NSTextAlignmentLeft;
	_descLabel.textColor = UIColorFromRGB(0x333333);
	_descLabel.numberOfLines = 100;
	[self addSubview:_descLabel];
	
	_optionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_optionLabel.backgroundColor = [UIColor clearColor];
	_optionLabel.font = [UIFont systemFontOfSize:13.f];
	_optionLabel.textAlignment = NSTextAlignmentLeft;
	_optionLabel.textColor = UIColorFromRGB(0x7883a2);
	_optionLabel.numberOfLines = 1;
	[self addSubview:_optionLabel];
	
	_etcLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_etcLabel.backgroundColor = [UIColor clearColor];
	_etcLabel.font = [UIFont systemFontOfSize:13.f];
	_etcLabel.textAlignment = NSTextAlignmentLeft;
	_etcLabel.textColor = UIColorFromRGB(0x999999);
	_etcLabel.numberOfLines = 1;
	[self addSubview:_etcLabel];
	
	_bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
	_bottomLineView.backgroundColor = UIColorFromRGB(0xededed);
	[self addSubview:_bottomLineView];

	self.frame = CGRectMake(self.frame.origin.x,
							self.frame.origin.y,
							self.frame.size.width,
							[self getPostItemHeight]);
}

- (void)layoutSubviews
{
	/* evlPnt
	 1 : 불만족
	 2 : 보통
	 3 : 만족
	 */
	
	if (!_item) return;
	
	NSInteger evlPnt = [_item[@"evlPnt"] integerValue];
	
	UIImage *imgIcon = nil;
//	NSString *iconText = @"";
//	UIColor *iconColor = nil;
	
	if (evlPnt == 1)
	{
		imgIcon = [UIImage imageNamed:@"postscript_pd_unhappy.png"];
//		iconText = @"불만족";
//		iconColor = UIColorFromRGB(0x9c9c9c);
	}
	else if (evlPnt == 2)
	{
		imgIcon = [UIImage imageNamed:@"postscript_pd_soso.png"];
//		iconText = @"보통";
//		iconColor = UIColorFromRGB(0x7993f0);
	}
	else
	{
		imgIcon = [UIImage imageNamed:@"postscript_pd_happy.png"];
//		iconText = @"만족";
//		iconColor = UIColorFromRGB(0xfe6e6e);
	}
	
	_iconView.image = imgIcon;
	_iconView.frame = CGRectMake(10, self.frame.size.height/2-imgIcon.size.height/2, imgIcon.size.width, imgIcon.size.height);
	
//	_iconLabel.text = iconText;
//	_iconLabel.textColor = iconColor;
//	[_iconLabel sizeToFitWithFloor];
//	_iconLabel.frame = CGRectMake(_iconView.center.x-(_iconLabel.frame.size.width/2)-1.f,
//								  CGRectGetMaxY(_iconView.frame)+6.f,
//								  _iconLabel.frame.size.width, _iconLabel.frame.size.height);
	
//	_iconBarView.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+10.f, 16.f, 1, self.frame.size.height-32.f);
	
	
	CGFloat textWidth = self.frame.size.width - (CGRectGetMaxX(_iconView.frame)+10.f+10.f);
	
	NSString *descStr = _item[@"subject"];
	_descLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame)+10.f, 13.f, textWidth, 0);
	_descLabel.text = descStr;
	[_descLabel sizeToFitWithVersionHoldWidth];
	
	NSString *optionStr = _item[@"option"];
	
	//옵션이 없는 경우가 있어서 공간을 만들어주기 위해 의미없는 문자열을 넣고 삭제한다.
//	BOOL emptyOption = [SHCommonLibrary isNullString:optionStr];
//	if (emptyOption) optionStr = @"가";
	
	_optionLabel.frame = CGRectMake(_descLabel.frame.origin.x, CGRectGetMaxY(_descLabel.frame)+4.f, textWidth, 0);
	_optionLabel.text = optionStr;
	[_optionLabel sizeToFitWithVersionHoldWidth];
	
//	if (emptyOption) _optionLabel.text = @"";
	
//	NSString *etcStr = [NSString stringWithFormat:@"%@ / %@ / %@", _item[@"createDate"], _item[@"buyYN"], _item[@"memId"]];
    NSString *etcStr = _item[@"createDate"];
	_etcLabel.frame = CGRectMake(_optionLabel.frame.origin.x, CGRectGetMaxY(_optionLabel.frame)+2.f, textWidth, 0);
	_etcLabel.text = etcStr;
	[_etcLabel sizeToFitWithVersionHoldWidth];
	
	_bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
	
	if (_lastItem)	_bottomLineView.hidden = YES;
	else			_bottomLineView.hidden = NO;
}

- (CGFloat)getPostItemHeight
{
//	//상단마진
//	CGFloat height = 16.f;
//	
//	//후기 제목
//	NSString *subject = _item[@"subject"];
//	height += [SHCommonLibrary getLabelHeightWithText:subject
//												frame:CGRectMake(0, 0, self.frame.size.width-84.f, 0)
//												 font:[UIFont systemFontOfSize:14.f]
//												lines:100
//										textAlignment:NSTextAlignmentLeft];
//	
//	//마진
//	height += 6.f;
//	
//	//옵션
//	NSString *option = @"가"; //옵션은 무조건 공간이 존재해야해서 강제로 텍스트를 박아놓는다.
//	CGFloat optionHeight = [SHCommonLibrary getLabelHeightWithText:option
//															 frame:CGRectMake(0, 0, self.frame.size.width-84.f, 0)
//															  font:[UIFont systemFontOfSize:12.f]
//															 lines:1
//													 textAlignment:NSTextAlignmentLeft];
//	height += optionHeight;
//	
//	//마진
//	height += 3.f;
//	
//	//기타 텍스트 (옵션과 높이가 같기때문에 따로 계산하지 않는다.
//	height += optionHeight;
//	
//	//하단 마진
//	height += 15.f;
	
//    return 80;//height;
    
    //후기
    //상단마진
    CGFloat height = 15.f;
    
    //후기 제목
    NSString *subject = _item[@"subject"];
    height += GET_STRING_SIZE(subject, [UIFont systemFontOfSize:14], kScreenBoundsWidth-85).height;
    
    //마진
    height += 6.f;
    
    //옵션
    NSString *option = @"가"; //옵션은 무조건 공간이 존재해야해서 강제로 텍스트를 박아놓는다.
    CGFloat optionHeight = GET_STRING_SIZE(option, [UIFont systemFontOfSize:13], kScreenBoundsWidth-85).height;
    height += optionHeight;
    
    //마진
    height += 4.f;
    
    //기타 텍스트 (옵션과 높이가 같기때문에 따로 계산하지 않는다.
    height += optionHeight;
    
    //하단 마진
    height += 15.f;
    
    return height;
}

@end
