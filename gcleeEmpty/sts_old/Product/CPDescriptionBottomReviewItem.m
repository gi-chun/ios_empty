#import "CPDescriptionBottomReviewItem.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPDescriptionBottomReviewItem ()
{
	NSString *_url;
	NSString *_prdNo;
	NSDictionary *_item;
	UIImageView *_iconBGView;
    UIImageView *_iconView;
    UIImageView *_moveIconView;
	UILabel *_iconLabel;
	UILabel *_titleLabel;
	UILabel *_descLabel;
	UILabel *_optionLabel;
	UILabel *_etcLabel;
	UIImageView *_imageView;
	
	UIView *_imgLineL;
	UIView *_imgLineR;
	UIView *_imgLineT;
	UIView *_imgLineB;
	
	UIView *_lineView;
    
    UIButton *_blankButton;
	
	BOOL _lastItem;
    BOOL _isInTab;
}

@end

@implementation CPDescriptionBottomReviewItem

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item url:(NSString *)url prdNo:(NSString *)prdNo lastItem:(BOOL)lastItem isInTab:(BOOL)isInTab
{
	if (self = [super initWithFrame:frame])
	{
		if (url) {
			_url = url;
		}
		
		if (prdNo) {
			_prdNo = prdNo;
		}
		
		if (item) {
			_item = item;
		}
        
        if (isInTab) {
            _isInTab = isInTab;
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
    
    _moveIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_iconView addSubview:_moveIconView];
    
	_iconBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_iconBGView];
    
	_iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_iconLabel.backgroundColor = [UIColor clearColor];
	_iconLabel.font = [UIFont systemFontOfSize:12];
	_iconLabel.textAlignment = NSTextAlignmentLeft;
	[self addSubview:_iconLabel];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont systemFontOfSize:15];
	_titleLabel.textColor = UIColorFromRGB(0x333333);
	_titleLabel.textAlignment = NSTextAlignmentLeft;
	_titleLabel.numberOfLines = 1;
	[self addSubview:_titleLabel];
	
	_descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_descLabel.backgroundColor = [UIColor clearColor];
	_descLabel.font = [UIFont systemFontOfSize:13];
	_descLabel.textColor = UIColorFromRGB(0x666666);
	_descLabel.textAlignment = NSTextAlignmentLeft;
	_descLabel.numberOfLines = 1;
	[self addSubview:_descLabel];
	
	_optionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_optionLabel.backgroundColor = [UIColor clearColor];
	_optionLabel.font = [UIFont systemFontOfSize:13];
	_optionLabel.textColor = UIColorFromRGB(0x7883a2);
	_optionLabel.textAlignment = NSTextAlignmentLeft;
	_optionLabel.numberOfLines = 1;
	[self addSubview:_optionLabel];
	
	_etcLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_etcLabel.backgroundColor = [UIColor clearColor];
	_etcLabel.font = [UIFont systemFontOfSize:13];
	_etcLabel.textColor = UIColorFromRGB(0x999999);
	_etcLabel.textAlignment = NSTextAlignmentLeft;
	_etcLabel.numberOfLines = 1;
	[self addSubview:_etcLabel];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self addSubview:_imageView];
	
	_imgLineL = [[UIView alloc] initWithFrame:CGRectZero];
	_imgLineR = [[UIView alloc] initWithFrame:CGRectZero];
	_imgLineT = [[UIView alloc] initWithFrame:CGRectZero];
	_imgLineB = [[UIView alloc] initWithFrame:CGRectZero];
	
	_imgLineL.backgroundColor = UIColorFromRGBA(0x000000, 0.08f);
	_imgLineR.backgroundColor = UIColorFromRGBA(0x000000, 0.08f);
	_imgLineT.backgroundColor = UIColorFromRGBA(0x000000, 0.08f);
	_imgLineB.backgroundColor = UIColorFromRGBA(0x000000, 0.08f);
	
	[_imageView addSubview:_imgLineL];
	[_imageView addSubview:_imgLineR];
	[_imageView addSubview:_imgLineT];
	[_imageView addSubview:_imgLineB];
	
	_lineView = [[UIView alloc] initWithFrame:CGRectZero];
	_lineView.backgroundColor = UIColorFromRGB(0xededed);
	[self addSubview:_lineView];
    
    _blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_blankButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [_blankButton setAlpha:0.15];
    [_blankButton addTarget:self action:@selector(touchReviewCell:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_blankButton];
}

- (void)layoutSubviews
{
	/* review
	 01 : 추천안함
	 02 : 보통
	 03 : 추천
	 04 : 적극추천
	 */
	
	if (!_item) return;
	
	NSInteger iconType = [_item[@"reviewIcon"] integerValue];
	NSString *imageUrl = _item[@"imgUrl"];
	
	UIImage *imgIconBg = nil;
	UIColor *textColor = nil;
	NSString *iconText = nil;
	
	if (iconType == 0)
	{
		imgIconBg = [UIImage imageNamed:@"postscript_pd_recommend_no.png"];
		textColor = UIColorFromRGB(0x666666);
		iconText = @"추천안함";
	}
	else if (iconType == 1)
	{
		imgIconBg = [UIImage imageNamed:@"postscript_pd_normal.png"];
		textColor = UIColorFromRGB(0x4c6ce2);
		iconText = @"보통";
	}
	else if (iconType == 2)
	{
		imgIconBg = [UIImage imageNamed:@"postscript_pd_recommend.png"];
		textColor = UIColorFromRGB(0xff5a00);
		iconText = @"추천";
	}
	else
	{
		imgIconBg = [UIImage imageNamed:@"postscript_pd_recommend_high.png"];
		textColor = UIColorFromRGB(0xff2128);
		iconText = @"적극추천";
	}
    
    BOOL hasImgUrl = [imageUrl length] > 0;
    
    if (hasImgUrl) {
        NSRange strRange = [imageUrl rangeOfString:@"http"];
        if (strRange.location == NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imageUrl];
        }
        strRange = [imageUrl rangeOfString:@"{{img_width}}"];
        if (strRange.location != NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 160]];
        }
        strRange = [imageUrl rangeOfString:@"{{img_height}}"];
        if (strRange.location != NSNotFound) {
            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 160]];
        }
        
        [_iconView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        _iconView.frame = CGRectMake(self.frame.size.width-10-80, self.frame.size.height/2-40, 80, 80);
    }
    else {
        _iconView.frame = CGRectZero;
    }
    
    if (hasImgUrl && [_item[@"viewType"] integerValue] == 3) {
        UIImage *moveImage = [UIImage imageNamed:@"bt_pd_play.png"];
        [_moveIconView setImage:moveImage];
        [_moveIconView setFrame:CGRectMake((_iconView.frame.size.width-moveImage.size.width)/2, (_iconView.frame.size.height-moveImage.size.height)/2, moveImage.size.width, moveImage.size.height)];
    }
	
	_iconLabel.text = iconText;
	_iconLabel.textColor = textColor;
	[_iconLabel sizeToFitWithFloor];
	
	imgIconBg = [imgIconBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	_iconBGView.image = imgIconBg;
    _iconBGView.frame = CGRectMake(10, 16, _iconLabel.frame.size.width+6.f, imgIconBg.size.height);
	
	_iconLabel.center = _iconBGView.center;
	
	NSString *titleText = _item[@"title"];
	
    CGFloat titleLabelWidth = self.frame.size.width-CGRectGetMaxX(_iconBGView.frame)-10-(hasImgUrl?90:0);
//	if (![SHCommonLibrary isNullString:imageUrl]) {
//		titleLabelWidth = self.frame.size.width-(CGRectGetMaxX(_iconBGView.frame)+6.f+30.f+68);
//	}
	
	_titleLabel.text = titleText;
	_titleLabel.frame = CGRectMake(CGRectGetMaxX(_iconBGView.frame)+6.f, 0,
								   titleLabelWidth,
								   0.f);
	[_titleLabel sizeToFitWithVersionHoldWidth];
	[_titleLabel setCenter:CGPointMake(_titleLabel.center.x, _iconBGView.center.y)];
	
	NSString *descText = _item[@"subject"];
	
	CGFloat otherLabelWidth = self.frame.size.width-(hasImgUrl?110:20);
//	if (![SHCommonLibrary isNullString:imageUrl]) {
//		otherLabelWidth = self.frame.size.width-45.f-68.f;
//	}
	
	_descLabel.text = descText;
	_descLabel.frame = CGRectMake(_iconBGView.frame.origin.x, CGRectGetMaxY(_titleLabel.frame)+6.f, otherLabelWidth, 0.f);
	[_descLabel sizeToFitWithVersionHoldWidth];
	
	NSString *optionText = _item[@"option"];
	
//	BOOL emptyOption = [SHCommonLibrary isNullString:optionText];
//	if (emptyOption) optionText = @"가";
	
	_optionLabel.text = optionText;
	_optionLabel.frame = CGRectMake(_iconBGView.frame.origin.x, CGRectGetMaxY(_descLabel.frame)+3.f, otherLabelWidth, 0.f);
	[_optionLabel sizeToFitWithVersionHoldWidth];
	
//	if (emptyOption) _optionLabel.text = @"";
	
//	NSString *etcText = [NSString stringWithFormat:@"%@ / %@ / 조회 %@ / %@",
//						 _item[@"createDate"], _item[@"buyYN"], _item[@"readCnt"], _item[@"memId"]];
    NSString *etcText = _item[@"createDate"];
	_etcLabel.text = etcText;
	_etcLabel.frame = CGRectMake(_iconBGView.frame.origin.x, CGRectGetMaxY(_optionLabel.frame)+2.f, otherLabelWidth, 0.f);
	[_etcLabel sizeToFitWithVersionHoldWidth];
	
//	if ([SHCommonLibrary isNullString:imageUrl])
//    if (!imageUrl)
//	{
//		_imageView.frame = CGRectZero;
//		_imageView.hidden = YES;
//		
//		_imgLineL.hidden = YES;
//		_imgLineR.hidden = YES;
//		_imgLineT.hidden = YES;
//		_imgLineB.hidden = YES;
//	}
//	else
//	{
//		_imageView.hidden = NO;
//		_imageView.frame = CGRectMake(self.frame.size.width-15.f-68.f, (self.frame.size.height/2)-34.f, 68.f, 68.f);
//		[_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_loading_4.png"]];
//		
//		_imgLineL.hidden = NO;
//		_imgLineR.hidden = NO;
//		_imgLineT.hidden = NO;
//		_imgLineB.hidden = NO;
//		
//		_imgLineL.frame = CGRectMake(0, 0, 1, _imageView.frame.size.height);
//		_imgLineR.frame = CGRectMake(_imageView.frame.size.width-1, 0, 1, _imageView.frame.size.height);
//		_imgLineT.frame = CGRectMake(0, 0, _imageView.frame.size.width, 1);
//		_imgLineB.frame = CGRectMake(0, _imageView.frame.size.height-1, _imageView.frame.size.width, 1);
//	}
	
	_lineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);

	if (_lastItem)	_lineView.hidden = YES;
	else			_lineView.hidden = NO;
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
//	[self setTouchView:YES];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
//	[self setTouchView:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
//	[self setTouchView:NO];
//	
//	if (_url)
//	{
//		NSString *tmepUrl = [_url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:_prdNo];
//		tmepUrl = [tmepUrl stringByReplacingOccurrencesOfString:@"{{contNo}}" withString:_item[@"contNo"]];
//		tmepUrl = [tmepUrl stringByReplacingOccurrencesOfString:@"{{reviewIcon}}" withString:_item[@"reviewIcon"]];
//		
//		DELEGATE_CALL2(self.delegate,
//					   CPDescriptionBottomReviewItem:moveUrl:,
//					   self,
//					   tmepUrl);
//	}
}

- (void)setTouchView:(BOOL)isTouch
{

	NSInteger iconType = [_item[@"reviewIcon"] integerValue];
	UIImage *imgIconBg = nil;
	
	if (iconType == 0)
	{
		if (isTouch)	imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend_no_press.png"];
		else			imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend_no.png"];
	}
	else if (iconType == 1)
	{
		if (isTouch)	imgIconBg = [UIImage imageNamed:@"detail_postscript_normal_press.png"];
		else			imgIconBg = [UIImage imageNamed:@"detail_postscript_normal.png"];
	}
	else if (iconType == 2)
	{
		if (isTouch)	imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend_press.png"];
		else			imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend.png"];
	}
	else
	{
		if (isTouch)	imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend_high_press.png"];
		else			imgIconBg = [UIImage imageNamed:@"detail_postscript_recommend_high.png"];
	}
	
	imgIconBg = [imgIconBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	_iconBGView.image = imgIconBg;
}

#pragma mark - Selectors

- (void)touchReviewCell:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchReviewCell:)]) {
        [self.delegate didTouchReviewCell:_item[@"detailLinkUrl"]];
    }
    
    if (_isInTab) {
        //AccessLog - 상품리뷰 클릭 - 두번째 탭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL05"];
    }
    else {
        //AccessLog - 리뷰 상세 클릭 - 상품정보 하단
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ11"];
    }
}

@end
