#import "CPDescriptionBottomTownShopBranch.h"
#import "CPDescriptionBottomSellerPrdList.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPDescriptionBottomTownShopBranch () <CPDescriptionBottomSellerPrdListDelegate,
                                                UIWebViewDelegate,
                                                TTTAttributedLabelDelegate>
{
	NSDictionary *item;
    
    UIView *headerView;
    UIView *expandView;
    UIView *listView;
    UIWebView *aWebview;
    
    //지점목록 버튼
    UIButton *townShopListButton;
    
    CGFloat viewHeight;
    BOOL isExpand;
    
    NSInteger currentIndex;
}

@end

@implementation CPDescriptionBottomTownShopBranch

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)aItem
{
	if (self = [super initWithFrame:frame])
	{
        if (aItem) {
            item = aItem;
        }
		
        [self initData];
		[self initLayout];
	}
	return self;
}

- (void)initData
{
    isExpand = NO;
    currentIndex = 0;
    self.selectedIndex = 0;
}

- (void)initLayout
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews
{
    for (UIView *subView in [headerView subviews]) {
        [subView removeFromSuperview];
    }
    
    headerView = [[UIView alloc] init];
    [headerView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 165)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:headerView];
    
    if (listView) {
        [self bringSubviewToFront:listView];
    }
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"지점정보"];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [headerView addSubview:titleLabel];
    
    UIView *headerUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenBoundsWidth, 1)];
    [headerUnderLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [headerView addSubview:headerUnderLineView];
    
    
    //지점목록
    UIImage *townShopListImage = [[UIImage imageNamed:@"layer_pd_inputbox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    townShopListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [townShopListButton setFrame:CGRectMake(10, CGRectGetMaxY(headerUnderLineView.frame)+10, kScreenBoundsWidth-20, 32)];
    [townShopListButton setTitle:item[@"shopLayer"][self.selectedIndex][@"shopBranchNm"] forState:UIControlStateNormal];
    [townShopListButton setTitleColor:UIColorFromRGB(0xb6b6b6) forState:UIControlStateNormal];
    [townShopListButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [townShopListButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [townShopListButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
    [townShopListButton setBackgroundImage:townShopListImage forState:UIControlStateNormal];
    [townShopListButton setTag:currentIndex];
    [townShopListButton addTarget:self action:@selector(touchTownShopList:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:townShopListButton];
    
    UIImageView *inputDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(townShopListButton.frame)-32, 0, 32, 32)];
    [inputDownIconView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
    [townShopListButton addSubview:inputDownIconView];
    
    //전화
    NSString *callStr = @"전화";
    CGSize callStrSize = [callStr sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *callLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(townShopListButton.frame)+10, callStrSize.width, 15)];
    [callLabel setBackgroundColor:[UIColor clearColor]];
    [callLabel setText:callStr];
    [callLabel setTextColor:UIColorFromRGB(0x333333)];
    [callLabel setTextAlignment:NSTextAlignmentLeft];
    [callLabel setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:callLabel];
    
    NSString *callNumberStr = item[@"shopLayer"][self.selectedIndex][@"tel"];
    
    TTTAttributedLabel *callNumberLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(callLabel.frame)+9, CGRectGetMaxY(townShopListButton.frame)+10, kScreenBoundsWidth-20-callStrSize.width, 15)];
    [callNumberLabel setDelegate:self];
    [callNumberLabel setBackgroundColor:[UIColor clearColor]];
    [callNumberLabel setTextColor:UIColorFromRGB(0x52bbff)];
    [callNumberLabel setFont:[UIFont systemFontOfSize:14]];
    [callNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [callNumberLabel setText:callNumberStr];
    [callNumberLabel addLinkToPhoneNumber:callNumberStr withRange:[callNumberLabel.text rangeOfString:callNumberStr]];
    [headerView addSubview:callNumberLabel];
    
    
    UIImage *upImage = [UIImage imageNamed:@"ic_pd_arrow_up_02.png"];
    UIImage *downImage = [UIImage imageNamed:@"ic_pd_arrow_right_02.png"];
    NSString *mapStr = @"지도";
    CGSize mapStrSize = [mapStr sizeWithFont:[UIFont systemFontOfSize:13]];
    
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expandButton setFrame:CGRectMake(kScreenBoundsWidth-10-6-6-mapStrSize.width, 140, 12+mapStrSize.width, 14)];
    [expandButton addTarget:self action:@selector(touchMapButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:expandButton];
    
    UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mapStrSize.width, 14)];
    [mapLabel setBackgroundColor:[UIColor clearColor]];
    [mapLabel setText:mapStr];
    [mapLabel setTextColor:UIColorFromRGB(0x283593)];
    [mapLabel setTextAlignment:NSTextAlignmentLeft];
    [mapLabel setFont:[UIFont systemFontOfSize:13]];
    [expandButton addSubview:mapLabel];
    
    UIImageView *dropDownImageView = [[UIImageView alloc] init];
    [dropDownImageView setImage:isExpand?upImage:downImage];
    [dropDownImageView setFrame:CGRectMake(CGRectGetMaxX(mapLabel.frame)+6, 1.5f, 6, 11)];
    [expandButton addSubview:dropDownImageView];
    
    
    
    //주소
    NSString *addressStr = @"주소";
    CGSize addressStrSize = [addressStr sizeWithFont:[UIFont systemFontOfSize:14]];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(callLabel.frame)+9, addressStrSize.width, 15)];
    [addressLabel setBackgroundColor:[UIColor clearColor]];
    [addressLabel setText:addressStr];
    [addressLabel setTextColor:UIColorFromRGB(0x333333)];
    [addressLabel setTextAlignment:NSTextAlignmentLeft];
    [addressLabel setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:addressLabel];
    
    NSString *addressInfoStr = item[@"shopLayer"][self.selectedIndex][@"address"];
    CGSize addressInfoStrSize = [addressInfoStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(expandButton.frame.origin.x-CGRectGetMaxX(addressLabel.frame)-20, 1000) lineBreakMode:addressLabel.lineBreakMode];
//    BOOL isOneLine = kScreenBoundsWidth-10-(CGRectGetMaxX(addressLabel.frame)+9) >= addressInfoStrSize.width;
    
    UILabel *addressInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addressLabel.frame)+9, CGRectGetMaxY(callLabel.frame)+9, addressInfoStrSize.width, addressInfoStrSize.height)];//isOneLine?15:34)];
    [addressInfoLabel setBackgroundColor:[UIColor clearColor]];
    [addressInfoLabel setText:addressInfoStr];
    [addressInfoLabel setTextColor:UIColorFromRGB(0x999999)];
    [addressInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [addressInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [addressInfoLabel setNumberOfLines:2];
    [headerView addSubview:addressInfoLabel];

    viewHeight = 165;
}

- (void)initExpandView
{
    if (!expandView) {
        
        expandView = [[UIView alloc] init];
        [expandView setBackgroundColor:[UIColor whiteColor]];
        [expandView setFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), kScreenBoundsWidth, 277)];
        [self addSubview:expandView];
        
        aWebview = [[UIWebView alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 250)];
        aWebview.delegate = self;
        aWebview.clipsToBounds = NO;
        aWebview.scalesPageToFit = YES;
        aWebview.scrollView.scrollsToTop = NO;
        [expandView addSubview:aWebview];
        
        [self openUrl:item[@"shopLayer"][self.selectedIndex][@"mapLinkUrl"]];
    }
    
    if (currentIndex != self.selectedIndex) {
        [self openUrl:item[@"shopLayer"][self.selectedIndex][@"mapLinkUrl"]];
        currentIndex = self.selectedIndex;
    }
    
    viewHeight = 432;
}

//지점정보 세팅
- (void)setTownShopBranchView
{
    [self layoutSubviews];
}

#pragma mark - Private Methods

- (CGFloat)getListButtonY
{
    return 53+32;
}

#pragma mark - Selectors

- (void)touchMapButton:(id)sender
{
    NSString *linkUrl = item[@"shopLayer"][self.selectedIndex][@"mapLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchMapButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchMapButton:linkUrl];
        }
    }
    
    //AccessLog - 지도 보기 버튼 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ09"];
}

- (void)touchExpandMapButton:(id)sender
{
    isExpand = !isExpand;
    
    if (isExpand) {
        [self initExpandView];
    }
    else {
        viewHeight = 165;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton:height:)]) {
        [self.delegate didTouchExpandButton:CPDescriptionBottomViewTypeTownShop height:viewHeight];
    }
}

- (void)removeTouchTownShopListView
{
    if (listView) {
        [listView removeFromSuperview];
        listView = nil;
    }
}

- (void)touchTownShopList:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setTag:self.selectedIndex];
    
    if ([self.delegate respondsToSelector:@selector(didTouchTownShopList:)]) {
        [self.delegate didTouchTownShopList:sender];
    }
    
    //AccessLog - 지점정보 셀렉트 박스 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ07"];
}

- (void)touchTownShopListButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.selectedIndex = button.tag;
    
    [self removeTouchTownShopListView];
    [self layoutSubviews];
    if (isExpand) {
        [self initExpandView];
    }
}

#pragma mark - webview

- (void)openUrl:(NSString *)url
{
    [aWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)stopLoading
{
    [aWebview stopLoading];
}

- (void)setScrollTop
{
    [aWebview.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [aWebview.scrollView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [aWebview.scrollView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [aWebview.scrollView setShowsVerticalScrollIndicator:isShow];
}


#pragma mark - UIWebViewDelegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.delegate productTownShopBranchView:self isLoading:[NSNumber numberWithBool:YES]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate productTownShopBranchView:self isLoading:[NSNumber numberWithBool:NO]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate productTownShopBranchView:self isLoading:[NSNumber numberWithBool:NO]];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    // '080-850-2332~3' 같은 경우 ~뒤는 제거
    if ([phoneNumber rangeOfString:@"~"].location != NSNotFound) {
        NSArray *numberArray = [phoneNumber componentsSeparatedByString:@"~"];
        phoneNumber = numberArray[0];
    }
    
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *phoneNumUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]];
    
    if([[UIApplication sharedApplication] canOpenURL:phoneNumUrl])
    {
        [[UIApplication sharedApplication] openURL:phoneNumUrl];
    }
    
    //AccessLog - 지점 전화하기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ08"];
}

@end
