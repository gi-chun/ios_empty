#import "CPDescriptionBottomMiniMall.h"
#import "CPDescriptionBottomSellerPrdList.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

#define BUTTON_HEIGHT   44

@interface CPDescriptionBottomMiniMall () <CPDescriptionBottomSellerPrdListDelegate>
{
	NSDictionary *_item;
    NSString *_title;
    NSString *_linkUrl;
    NSString *_resistLinkUrl;
    NSString *_helpLinkUrl;
    NSString *_indiSellerYn;
    
    UIView *headerView;
    UIImageView *iconView;
    UILabel *titleLabel;
    UILabel *sellerInfoLabel;
    UIButton *sellerInfoButton;
    
    UIView *satisfyView;
    
    CPDescriptionBottomSellerPrdList *sellerPrdListView;
    
    UIButton *showPrdAllButton;
    UIButton *regularRegButton;

    UIView *topLineView;
    UIView *midLineView;
    UIView *centerLineView;
    UIView *bottomLineView;
    
    CGFloat viewHeight;
}

@end

@implementation CPDescriptionBottomMiniMall

- (id)initWithFrame:(CGRect)frame title:(NSString *)title item:(NSDictionary *)item linkUrl:(NSString *)aLinkUrl resistLinkUrl:(NSString *)aResistLinkUrl helpLinkUrl:(NSString *)aHelpLinkUrl indiSellerYn:(NSString *)aIndiSellerYn
{
	if (self = [super initWithFrame:frame])
	{
        if (title) {
            _title = title;
        }
        
        if (item) {
            _item = item;
        }
        
        if (aLinkUrl) {
            _linkUrl = aLinkUrl;
        }
        
        if (aResistLinkUrl) {
            _resistLinkUrl = aResistLinkUrl;
        }
        
        if (aHelpLinkUrl) {
            _helpLinkUrl = aHelpLinkUrl;
        }
        
        if (aIndiSellerYn) {
            _indiSellerYn = aIndiSellerYn;
        }
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	self.backgroundColor = [UIColor whiteColor];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 70)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:headerView];
    
    iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [headerView addSubview:iconView];
    
    titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:titleLabel];
    
    sellerInfoLabel = [[UILabel alloc] init];
    [sellerInfoLabel setBackgroundColor:[UIColor clearColor]];
    [sellerInfoLabel setTextColor:UIColorFromRGB(0x666666)];
    [sellerInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [sellerInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [headerView addSubview:sellerInfoLabel];
    
    sellerInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sellerInfoButton setFrame:CGRectZero];
    [sellerInfoButton setImage:[UIImage imageNamed:@"ic_pd_information.png"] forState:UIControlStateNormal];
    [sellerInfoButton addTarget:self action:@selector(touchInfoButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:sellerInfoButton];
    
    
    satisfyView = [[UIView alloc] initWithFrame:CGRectZero];
    [satisfyView setBackgroundColor:[UIColor whiteColor]];
    [headerView addSubview:satisfyView];
    
    
    sellerPrdListView = [[CPDescriptionBottomSellerPrdList alloc] initWithFrame:CGRectZero item:_item[@"sellerInfo"][@"list"] moreUrl:_linkUrl type:CPSellerPrdListTypeMiniMall];
    [sellerPrdListView setDelegate:self];
    [self addSubview:sellerPrdListView];
    
    
    showPrdAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showPrdAllButton setFrame:CGRectZero];
    [showPrdAllButton setTitle:@"판매상품 전체보기" forState:UIControlStateNormal];
    [showPrdAllButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [showPrdAllButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [showPrdAllButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [showPrdAllButton addTarget:self action:@selector(touchSellerInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:showPrdAllButton];
    
    regularRegButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [regularRegButton setFrame:CGRectZero];
    [regularRegButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [regularRegButton addTarget:self action:@selector(touchShowPrdAll:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:regularRegButton];
    
    
    topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [topLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:topLineView];
    
    midLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [midLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:midLineView];
    
    centerLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [centerLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:centerLineView];
    
    bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [bottomLineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    viewHeight = 280;
    
    //로그인 상태 and 단골등록 상태일 경우 아래 버튼 히든
    BOOL isDangol = [Modules checkLoginFromCookie] && [_item[@"sellerInfo"][@"favoriteYn"] isEqualToString:@"Y"];
    if (isDangol) {
        [regularRegButton setHidden:YES];
        [centerLineView setHidden:YES];
    }
    else {
        [regularRegButton setHidden:NO];
        [centerLineView setHidden:NO];
    }
    
    [iconView setImage:[UIImage imageNamed:@"ic_pd_minimall.png"]];
    [iconView setFrame:CGRectMake(10, 15, 15, 14)];
    
    //개인셀러
    BOOL indiSellerYn = [_indiSellerYn isEqualToString:@"Y"];
    if (indiSellerYn) {
        [sellerInfoButton setHidden:YES];
        [sellerInfoLabel setHidden:YES];
    }
    else {
        [sellerInfoButton setHidden:NO];
        [sellerInfoLabel setHidden:NO];
        
        [sellerInfoButton setFrame:CGRectMake(kScreenBoundsWidth-26, 15, 18, 18)];
        
        NSString *sellerInfoStr = @"판매자정보";
        CGSize sellerInfoStrSize = [sellerInfoStr sizeWithFont:[UIFont systemFontOfSize:14]];
        
        [sellerInfoLabel setFrame:CGRectMake(sellerInfoButton.frame.origin.x-5-sellerInfoStrSize.width, 17, sellerInfoStrSize.width, 15)];
        [sellerInfoLabel setText:sellerInfoStr];
    }
    
    [titleLabel setText:_item[@"sellerInfo"][@"selMnbNckNmText"]];
    [titleLabel setFrame:CGRectMake(CGRectGetMaxX(iconView.frame)+7, iconView.frame.origin.y, indiSellerYn?CGRectGetWidth(headerView.frame)-(CGRectGetMaxX(iconView.frame)+7):sellerInfoLabel.frame.origin.x-(CGRectGetMaxX(iconView.frame)+7), 17)];
    
    [satisfyView setFrame:CGRectMake(0, 39, kScreenBoundsWidth, 14)];
    
    //star
    UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
    CGFloat buySatisfyGrd = [_item[@"sellerInfo"][@"psmScorStr"] floatValue];
    CGFloat viewWidth = 10;
    
    for (int i = 0; i < 5; i++) {
        
        if (i >= buySatisfyGrd) {
            image = [UIImage imageNamed:@"ic_pd_star_off.png"];
        }
        if (i+0.5f == buySatisfyGrd) {
            image = [UIImage imageNamed:@"ic_pd_star_half.png"];
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 2, 10, 9)];
        [imgView setImage:image];
        [satisfyView addSubview:imgView];
        
        viewWidth += 11;
    }
    
    //판매우수
    BOOL bestSellerYN = [_item[@"sellerInfo"][@"bestSellerYN"] isEqualToString:@"Y"];
    
    if (bestSellerYN) {
        
        UIImageView *bestIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [bestIconView setFrame:CGRectMake(viewWidth+11, 0, 18, 14)];
        [bestIconView setImage:[UIImage imageNamed:@"ic_li_crown.png"]];
        [satisfyView addSubview:bestIconView];
        
        NSString *bestStr = @"판매우수";
        CGSize bestStrSize = [bestStr sizeWithFont:[UIFont systemFontOfSize:12]];
        
        UILabel *bestLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bestIconView.frame)+3, 2, bestStrSize.width, 12)];
        [bestLabel setBackgroundColor:[UIColor clearColor]];
        [bestLabel setText:bestStr];
        [bestLabel setTextColor:UIColorFromRGB(0x666666)];
        [bestLabel setFont:[UIFont systemFontOfSize:12]];
        [bestLabel setTextAlignment:NSTextAlignmentLeft];
        [satisfyView addSubview:bestLabel];
        
        viewWidth = CGRectGetMaxX(bestLabel.frame);
    }
    
    //고객만족
    BOOL satisfiedIconYN = [_item[@"sellerInfo"][@"satisfiedIconYN"] isEqualToString:@"Y"];
    
    if (satisfiedIconYN) {
        
        UIImageView *satisfiedIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [satisfiedIconView setFrame:CGRectMake(viewWidth+11, 0, 18, 14)];
        [satisfiedIconView setImage:[UIImage imageNamed:@"ic_li_diamond.png"]];
        [satisfyView addSubview:satisfiedIconView];
        
        NSString *satisfiedStr = @"고객만족";
        CGSize satisfiedStrSize = [satisfiedStr sizeWithFont:[UIFont systemFontOfSize:12]];
        
        UILabel *satisfiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(satisfiedIconView.frame)+3, 2, satisfiedStrSize.width, 12)];
        [satisfiedLabel setBackgroundColor:[UIColor clearColor]];
        [satisfiedLabel setText:satisfiedStr];
        [satisfiedLabel setTextColor:UIColorFromRGB(0x666666)];
        [satisfiedLabel setFont:[UIFont systemFontOfSize:12]];
        [satisfiedLabel setTextAlignment:NSTextAlignmentLeft];
        [satisfyView addSubview:satisfiedLabel];
    }
    
    [sellerPrdListView setFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), kScreenBoundsWidth, 155)];
    
    [showPrdAllButton setFrame:CGRectMake(0, CGRectGetMaxY(sellerPrdListView.frame)+10, isDangol?kScreenBoundsWidth:kScreenBoundsWidth/2, BUTTON_HEIGHT)];
    [regularRegButton setFrame:CGRectMake(kScreenBoundsWidth/2, CGRectGetMaxY(sellerPrdListView.frame)+10, kScreenBoundsWidth/2, BUTTON_HEIGHT)];
    
    UIView *regularRegView = [[UIView alloc] initWithFrame:CGRectZero];
    [regularRegView setBackgroundColor:[UIColor clearColor]];
    [regularRegView setUserInteractionEnabled:NO];
    [regularRegButton addSubview:regularRegView];
    
    UIImageView *haertIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (BUTTON_HEIGHT-15)/2, 15, 15)];
    [haertIconView setImage:[UIImage imageNamed:@"ic_pd_like.png"]];
    [regularRegView addSubview:haertIconView];
    
    NSString *regularRegStr = @"단골등록";
    CGSize sregularRegStrSize = [regularRegStr sizeWithFont:[UIFont systemFontOfSize:15]];
    
    UILabel *regularRegLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(haertIconView.frame)+5, 0, sregularRegStrSize.width, BUTTON_HEIGHT)];
    [regularRegLabel setBackgroundColor:[UIColor clearColor]];
    [regularRegLabel setText:regularRegStr];
    [regularRegLabel setTextColor:UIColorFromRGB(0x333333)];
    [regularRegLabel setFont:[UIFont systemFontOfSize:15]];
    [regularRegLabel setTextAlignment:NSTextAlignmentLeft];
    [regularRegView addSubview:regularRegLabel];
    
    [regularRegView setFrame:CGRectMake(kScreenBoundsWidth/4-CGRectGetMaxX(regularRegLabel.frame)/2, 0, CGRectGetWidth(regularRegLabel.frame), BUTTON_HEIGHT)];
    
    
    [topLineView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [midLineView setFrame:CGRectMake(0, CGRectGetMaxY(sellerPrdListView.frame)+10, kScreenBoundsWidth, 1)];
    [centerLineView setFrame:CGRectMake(kScreenBoundsWidth/2, CGRectGetMaxY(sellerPrdListView.frame)+10, 1, BUTTON_HEIGHT)];
    [bottomLineView setFrame:CGRectMake(0, viewHeight-1, kScreenBoundsWidth, 1)];
}

#pragma mark - Selectors

//판매자정보
- (void)touchInfoButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchInfoButton:)]) {
        if (_helpLinkUrl && [[_helpLinkUrl trim] length] > 0) {
            [self.delegate didTouchInfoButton:_helpLinkUrl];
        }
    }
}

//판매상품 전체보기
- (void)touchSellerInfo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerInfo:)]) {
        [self.delegate didTouchSellerInfo:_linkUrl];
    }
    
    //AccessLog - 판매자상품 전체보기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK03"];
}

//단골등록
- (void)touchShowPrdAll:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchShowPrdAll:)]) {
        [self.delegate didTouchShowPrdAll:_resistLinkUrl];
    }
    
    //AccessLog - 단골등록
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK04"];
}

- (void)didTouchSellerPrd:(NSString *)prdNo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:prdNo];
    }
}

- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type
{
    if ([self.delegate respondsToSelector:@selector(didTouchMoreButton:type:)]) {
        [self.delegate didTouchMoreButton:moreUrl type:type];
    }
}

@end
