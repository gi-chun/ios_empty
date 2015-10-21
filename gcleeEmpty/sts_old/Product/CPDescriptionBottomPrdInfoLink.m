#import "CPDescriptionBottomPrdInfoLink.h"
#import "AccessLog.h"

#define VIEW_HEIGHT 44

@interface CPDescriptionBottomPrdInfoLink ()
{
	NSString *_prdSelInfoUrl;
    NSString *_prdInfoNoticeUrl;
	
    UIButton *_prdSelInfoButton;
    UIButton *_prdInfoNoticeButton;
    
    UIView *_topLineView;
    UIView *_bottomLineView;
    UIView *_midLineView;
}

@end

@implementation CPDescriptionBottomPrdInfoLink

- (id)initWithFrame:(CGRect)frame prdSelInfoUrl:(NSString *)aPrdSelInfoUrl prdInfoNoticeUrl:(NSString *)aPrdInfoNoticeUrl
{
	if (self = [super initWithFrame:frame])
	{
        if (aPrdSelInfoUrl) {
            _prdSelInfoUrl = aPrdSelInfoUrl;
        }
        
        if (aPrdInfoNoticeUrl) {
            _prdInfoNoticeUrl = aPrdInfoNoticeUrl;
        }
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
	
    _prdSelInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_prdSelInfoButton setFrame:CGRectZero];
    [_prdSelInfoButton setTitle:@"상품판매 일반정보" forState:UIControlStateNormal];
    [_prdSelInfoButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_prdSelInfoButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [_prdSelInfoButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [_prdSelInfoButton addTarget:self action:@selector(touchPrdSelInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_prdSelInfoButton];
    
    _prdInfoNoticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_prdInfoNoticeButton setFrame:CGRectZero];
    [_prdInfoNoticeButton setTitle:@"상품정보 제공고시" forState:UIControlStateNormal];
    [_prdInfoNoticeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_prdInfoNoticeButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [_prdInfoNoticeButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [_prdInfoNoticeButton addTarget:self action:@selector(touchProInfoNotice:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_prdInfoNoticeButton];
    
    _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_topLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:_topLineView];
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_bottomLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:_bottomLineView];
	
	_midLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [_midLineView setBackgroundColor:UIColorFromRGB(0xededed)];
	[self addSubview:_midLineView];
}

- (void)layoutSubviews
{
    [_prdSelInfoButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth/2, VIEW_HEIGHT)];
    
    [_prdInfoNoticeButton setFrame:CGRectMake(CGRectGetMaxX(_prdSelInfoButton.frame), 0, kScreenBoundsWidth/2, VIEW_HEIGHT)];
    
    [_topLineView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [_bottomLineView setFrame:CGRectMake(0, VIEW_HEIGHT-1, kScreenBoundsWidth, 1)];
    [_midLineView setFrame:CGRectMake(CGRectGetMaxX(_prdSelInfoButton.frame), 0, 1, VIEW_HEIGHT)];
}

#pragma mark - Selectors

- (void)touchPrdSelInfo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchPrdSelInfo:)]) {
        [self.delegate didTouchPrdSelInfo:_prdSelInfoUrl];
    }
    
    //AccessLog - 상품판매 일번정보 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ13"];
}

- (void)touchProInfoNotice:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchProInfoNotice:)]) {
        [self.delegate didTouchProInfoNotice:_prdInfoNoticeUrl];
    }
    
    //AccessLog - 상품정보 제공고시 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ14"];
}

@end
