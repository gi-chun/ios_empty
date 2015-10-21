//
//  OptionDrawer.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "OptionDrawer.h"
#import "OptionItemView.h"
#import "CPProductOptionLoadingView.h"
#import "CPRESTClient.h"
#import "CMDQueryStringSerialization.h"
#import "NSString+URLEncodedString.h"
#import "UIAlertView+Blocks.h"
#import "RegexKitLite.h"
#import "AccessLog.h"

#define tagItemViewVal              10
#define tagNoticeBtnVal             20
#define CELL_TEXTFIELD_TAG			100

@interface OptionDrawer()
{
    BOOL isInitialize, isShowingOptionItem, isKeyboardShowing, isOnlyInputOption;
    NSInteger openDrawerType;
    
    CGPoint originalBottomViewPos;
    CGRect prevBottomViewFrame;
    
    NSInteger currentOptionSection, currentOptionRow;
    
    CGRect beforeRectKeyboardShowSelfView;
    CGRect beforeRectKeyboardShowOptionTableView;
    CGRect beforeRectKeyboardShowOptionBottomView;
    
    NSString *downloadProductItemUrl;
    
    //독립형 옵션일 경우 컨트롤한다.
    BOOL _isGetIndipendentOptionName;
    BOOL _isloopingIndipendentOption;
    
    OptionItemView *itemView;
    
    CPProductOptionLoadingView *loadingView;
    
    CGFloat totalPriceViewHeight;
    CGFloat optionBottomViewHeight;
    CGFloat optionTableViewHeight;
}

@property (nonatomic, strong) UIView *optionBottomView, *keyboardToolView;
@property (nonatomic, strong) UITableView *optionTableView;
@property (nonatomic, strong) UILabel *priceCountLabel;
@property (nonatomic, strong) UILabel *priceLabel, *priceWonLabel, *priceTagLabel;
@property (nonatomic, strong) UILabel *myCouponLabel;
@property (nonatomic, strong) UIButton *myCouponButton;
@property (nonatomic, strong) UIButton *cartButton, *purchaseButton, *giftButton, *syrupButton, *shockingdealButton, *downloadButton;
@property (nonatomic, strong) UIView *totalPriceView;
@property (nonatomic, strong) UIButton *optionArrowButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray *optionArray, *additionalOptionArray, *selectedOptionArray, *inputOptionArray;
@property (nonatomic, strong) NSMutableDictionary *multiOptionInfoDictionary;
@property (nonatomic, strong) NSMutableArray *saveSelectItemArray; //독립형 상품일 경우 임시저장을 위한 어레이
@property (nonatomic, strong) NSMutableArray *saveLoopItemArray; //독립형 상품 최종 구매시 필요한 어레이
@property (nonatomic, strong) MyPriceModel *myPriceModel;

// coupon
@property (nonatomic, assign) BOOL myCouponSectionVisible;
//@property (nonatomic, strong) NSString *localizedCouponDiscountPrice;

@end

@implementation OptionDrawer

+ (CGFloat)ArrowButtonHeight
{
    return 20;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        originalBottomViewPos = CGPointZero;
        beforeRectKeyboardShowSelfView = CGRectZero;
        beforeRectKeyboardShowOptionTableView = CGRectZero;
        beforeRectKeyboardShowOptionBottomView = CGRectZero;
        
        _optionArray = [[NSMutableArray alloc] init];
        _inputOptionArray = [[NSMutableArray alloc] init];
        _selectedOptionArray = [[NSMutableArray alloc] init];
        _additionalOptionArray = [[NSMutableArray alloc] init];
        _multiOptionInfoDictionary = [[NSMutableDictionary alloc] init];
        _saveSelectItemArray = [[NSMutableArray alloc] init];
        _saveLoopItemArray = [[NSMutableArray alloc] init];
        _myCoupons = [NSMutableArray array];
        
        [self setOpenOffset:0];
        [self setOpenMinimumHeight:150.f];
        [self setupGesture];
        [self initLayout];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    if (_optionTableView) {
        _optionTableView.delegate = nil;
    }
    
    NSLog(@"dealloc optionDrawer");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initLayout
{
    UIImage *upNorImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    UIImage *upHilImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    
    _optionArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.drawerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 24.f)];
    _keyboardToolView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 43.f)];
    
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 1)];
    [barView setBackgroundColor:UIColorFromRGBA(0x000000, 0.05f)];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              barView.frame.origin.y,
                                                              self.frame.size.width,
                                                              self.frame.size.height-barView.frame.origin.y+barView.frame.size.height)];
    
    [bgView setBackgroundColor:UIColorFromRGB(0xeaeaea)];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UIView *keyboardToolLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _keyboardToolView.frame.size.width, 1.f)];
    
    UIButton *btnKeyboardDown = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self.optionArrowButton setAdjustsImageWhenHighlighted:NO];
    [self.optionArrowButton setImage:upNorImage forState:UIControlStateNormal];
    [self.optionArrowButton setImage:upHilImage forState:UIControlStateHighlighted];
    [self.optionArrowButton setFrame:CGRectMake((_drawerBar.frame.size.width-upNorImage.size.width)/2,
                                                0,
                                                upNorImage.size.width,
                                                upNorImage.size.height)];
    
    if ([self respondsToSelector:@selector(onClickToggleDrawer:)]) {
        [self.optionArrowButton addTarget:self action:@selector(onClickToggleDrawer:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.drawerBar setBackgroundColor:[UIColor clearColor]];
    
//    [bgView setBackgroundColor:UIColorFromRGB(0x42454e)];

    [keyboardToolLine setBackgroundColor:UIColorFromRGBA(0x000000, 0.33f)];
    
    [btnKeyboardDown setBackgroundColor:[UIColor clearColor]];
    [btnKeyboardDown.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [btnKeyboardDown setTitle:@"닫기" forState:UIControlStateNormal];
    [btnKeyboardDown setTitleColor:UIColorFromRGB(0x636566) forState:UIControlStateNormal];
    [btnKeyboardDown addTarget:self action:@selector(onClickKeyboardDown:) forControlEvents:UIControlEventTouchUpInside];
    [btnKeyboardDown setBackgroundImage:[UIImage imageNamed:@"search_keypad_btn_nor.png"] forState:UIControlStateNormal];
    [btnKeyboardDown setBackgroundImage:[UIImage imageNamed:@"search_keypad_btn_select.png"] forState:UIControlStateHighlighted];
    [btnKeyboardDown setFrame:CGRectMake(_keyboardToolView.frame.size.width - 70.f, (_keyboardToolView.frame.size.height - 36.f) / 2, 60.f, 36.f)];
    
    [self.keyboardToolView setBackgroundColor:UIColorFromRGBA(0xb7b7b7, 0.9f)];
    [self.keyboardToolView addSubview:keyboardToolLine];
    [self.keyboardToolView addSubview:btnKeyboardDown];
    
    [self.drawerBar addSubview:barView];
    [self.drawerBar addSubview:self.optionArrowButton];
    
    [self addSubview:bgView];
    [self addSubview:self.drawerBar];
    [self addSubview:self.keyboardToolView];
    
    //로딩뷰
    loadingView = [[CPProductOptionLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-20,
                                                                               CGRectGetHeight(self.frame)/2-20,
                                                                               40,
                                                                               40)];
}

#pragma mark - Property

- (void)setIsDlvCstPayChecked:(BOOL)isDlvCstPayChecked
{
    _isDlvCstPayChecked = isDlvCstPayChecked;
    
    if (isDlvCstPayChecked) {
        for (int i = 0; i < self.myCoupons.count; i++) {
//        for (NSMutableDictionary *coupon in self.myCoupons) {
        
            NSMutableDictionary *coupon = [NSMutableDictionary dictionaryWithDictionary:self.myCoupons[i]];
            /*
             STOCK_NO          옵션번호
             ADD_ISS_CUPN_NO   선택할인,즉실할인쿠폰
             ADD_DSC_AMT       선택할인 금액
             BONUS_ISS_CUPN_NO 보너스쿠폰번호
             BONUS_DSC_AMT     보너스쿠폰금액
             SO_DSC_AMT        SO즉시할인가
             DLV_ISS_CUPN_NO   배송비쿠폰
             */
            NSString *DLV_ISS_CUPN_NO = [coupon[@"DLV_ISS_CUPN_NO"] stringValue];
            if (!nilCheck(DLV_ISS_CUPN_NO) && ![DLV_ISS_CUPN_NO isEqualToString:@"0"]) {
                [coupon setObject:@"" forKey:@"DLV_ISS_CUPN_NO"];
                [self.myCoupons replaceObjectAtIndex:i withObject:coupon];
                DEFAULT_ALERT(@"알림", @"배송지 착불시, 배송비쿠폰은 사용 불가하므로 자동 해제됩니다.");
                [self requestMyCouponInfoIfNeeded];
            }
        }
    }
}

- (void)setIsVisitDlvChecked:(BOOL)isVisitDlvChecked
{
    _isVisitDlvChecked = isVisitDlvChecked;
    
    if (isVisitDlvChecked) {
        for (int i = 0; i < self.myCoupons.count; i++) {
            NSMutableDictionary *coupon = [NSMutableDictionary dictionaryWithDictionary:self.myCoupons[i]];
            /*
             STOCK_NO          옵션번호
             ADD_ISS_CUPN_NO   선택할인,즉실할인쿠폰
             ADD_DSC_AMT       선택할인 금액
             BONUS_ISS_CUPN_NO 보너스쿠폰번호
             BONUS_DSC_AMT     보너스쿠폰금액
             SO_DSC_AMT        SO즉시할인가
             DLV_ISS_CUPN_NO   배송비쿠폰
             */
            
            NSString *DLV_ISS_CUPN_NO = [coupon[@"DLV_ISS_CUPN_NO"] stringValue];
            if (!nilCheck(DLV_ISS_CUPN_NO) && ![DLV_ISS_CUPN_NO isEqualToString:@"0"]) {
                [coupon setObject:@"" forKey:@"DLV_ISS_CUPN_NO"];
                [self.myCoupons replaceObjectAtIndex:i withObject:coupon];
                DEFAULT_ALERT(@"알림", @"방문수령 선택시, 배송비쿠폰은 사용 불가하므로 자동 해제됩니다.");
                [self requestMyCouponInfoIfNeeded];
            }
        }
    }
}

#pragma mark - Layout - 테이블뷰, 가격, 버튼

- (void)makeOptionLayout
{
    UITableViewStyle tableStyle = UITableViewStyleGrouped;
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6")) {
        tableStyle = UITableViewStylePlain;
    }
    
    //쿠폰변경 버튼 기본노출로 변경
    totalPriceViewHeight = 85;
    optionBottomViewHeight = 130;
    optionTableViewHeight = 160;
    
//    totalPriceViewHeight = 45;
//    optionBottomViewHeight = 90;
//    optionTableViewHeight = 126;
    
    _totalPriceView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), totalPriceViewHeight)];
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _priceTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _priceWonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _priceCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0.f)];
    
    _optionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)style:tableStyle];
    _optionBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-optionBottomViewHeight, CGRectGetWidth(self.frame), optionBottomViewHeight)];
    
    [self.optionTableView setDelegate:self];
    [self.optionTableView setDataSource:self];
    [self.optionTableView setBackgroundColor:[UIColor clearColor]];
    [self.optionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.priceCountLabel setText:@"(0개)"];
    [self.priceCountLabel setAdjustsFontSizeToFitWidth:YES];
    [self.priceCountLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceCountLabel setTextColor:UIColorFromRGB(0x5d5e5f)];
    [self.priceCountLabel setFont:[UIFont systemFontOfSize:13]];
    
    [self.priceWonLabel setText:@"원"];
    [self.priceWonLabel setAdjustsFontSizeToFitWidth:YES];
    [self.priceWonLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceWonLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceWonLabel setTextColor:UIColorFromRGB(0xff0c0c)];
    [self.priceWonLabel setFont:[UIFont systemFontOfSize:13.f]];
    [self.priceWonLabel sizeToFitWithFloor];
    
    [self.priceLabel setText:@"0"];
    [self.priceLabel setAdjustsFontSizeToFitWidth:YES];
    [self.priceLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceLabel setTextColor:UIColorFromRGB(0xff0c0c)];
    [self.priceLabel setFont:[UIFont boldSystemFontOfSize:23.f]];
    
    [self.priceTagLabel setText:@"총 금액"];
    [self.priceTagLabel setAdjustsFontSizeToFitWidth:YES];
    [self.priceTagLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceTagLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceTagLabel setTextColor:UIColorFromRGB(0x5d5e5f)];
    [self.priceTagLabel setFont:[UIFont systemFontOfSize:13]];
    
    //쿠폰변경
    _myCouponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myCouponButton setFrame:CGRectMake(CGRectGetWidth(self.totalPriceView.frame)-63, 13, 53, 24)];
    [self.myCouponButton setImage:[UIImage imageNamed:@"bt_coupon.png"] forState:UIControlStateNormal];
    [self.myCouponButton addTarget:self action:@selector(onClickMyCouponPopup:) forControlEvents:UIControlEventTouchUpInside];
    [self.myCouponButton setHidden:NO];
    [self.totalPriceView addSubview:self.myCouponButton];
    
    NSString *myCouponString = @"";
    CGSize myCouponStringSize = GET_STRING_SIZE(myCouponString, [UIFont systemFontOfSize:13], CGRectGetWidth(self.totalPriceView.frame));
    
    _myCouponLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.myCouponButton.frame)-(myCouponStringSize.width+7), 13, myCouponStringSize.width, 24)];
    [self.myCouponLabel setTextAlignment:NSTextAlignmentLeft];
    [self.myCouponLabel setBackgroundColor:[UIColor clearColor]];
    [self.myCouponLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.myCouponLabel setFont:[UIFont systemFontOfSize:13]];
    [self.myCouponLabel setText:myCouponString];
    [self.myCouponLabel setHidden:YES];
    [self.totalPriceView addSubview:self.myCouponLabel];

    //사이즈 계산
    [self resizePriceLabel];
    
    [self.totalPriceView addSubview:self.priceLabel];
    [self.totalPriceView addSubview:self.priceWonLabel];
    [self.totalPriceView addSubview:self.priceTagLabel];
    [self.totalPriceView addSubview:self.priceCountLabel];
    
    _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _syrupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shockingdealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.cartButton.frame = CGRectZero;
    self.giftButton.frame = CGRectZero;
    self.purchaseButton.frame = CGRectZero;
    self.syrupButton.frame = CGRectZero;
    self.shockingdealButton.frame = CGRectZero;
    self.downloadButton.frame = CGRectZero;
    
    [self.cartButton addTarget:self action:@selector(onClickCartList:) forControlEvents:UIControlEventTouchUpInside];
    [self.giftButton addTarget:self action:@selector(onClickSendGift:) forControlEvents:UIControlEventTouchUpInside];
    [self.purchaseButton addTarget:self action:@selector(onClickPurchase:) forControlEvents:UIControlEventTouchUpInside];
    [self.syrupButton addTarget:self action:@selector(onClickSyrup:) forControlEvents:UIControlEventTouchUpInside];
    [self.shockingdealButton addTarget:self action:@selector(onClickShockingdealButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadButton addTarget:self action:@selector(onClickPurchase:) forControlEvents:UIControlEventTouchUpInside];
    
//    //시럽페이 버튼 노출일 경우
//    if ([self.itemDetailInfo[@"syrupPayYn"] isEqualToString:@"Y"]) {
//    }
    
    [self setButtonLayoutWithType];
    
    //상단라인
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.optionBottomView.frame.size.width, 1.f)];
    [lineView setBackgroundColor:UIColorFromRGB(0xcfcfcf)];
    
    [self.optionBottomView setClipsToBounds:YES];
    [self.optionBottomView setBackgroundColor:UIColorFromRGB(0xeaeaea)];
    [self.optionBottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self.optionBottomView addSubview:self.totalPriceView];
    
    [self.optionBottomView addSubview:self.giftButton];
    [self.optionBottomView addSubview:self.purchaseButton];
    [self.optionBottomView addSubview:self.cartButton];
    [self.optionBottomView addSubview:self.syrupButton];
    [self.optionBottomView addSubview:self.shockingdealButton];
    [self.optionBottomView addSubview:self.downloadButton];
    [self.optionBottomView addSubview:lineView];
    
    [self addSubview:self.optionTableView];
    [self addSubview:self.optionBottomView];
    
    [self bringSubviewToFront:self.drawerBar];
    
    
    [self setOptionTableViewFooterView];
}

- (void)resizePriceLabel
{
    //상품 가격
    [self.priceWonLabel sizeToFitWithFloor];
    [self.priceWonLabel setFrame:CGRectMake(self.totalPriceView.frame.size.width-10-self.priceWonLabel.frame.size.width,
                                            self.totalPriceView.frame.size.height-self.priceWonLabel.frame.size.height-11,
                                            self.priceWonLabel.frame.size.width,
                                            self.priceWonLabel.frame.size.height)];
    
    [self.priceLabel sizeToFitWithFloor];
    [self.priceLabel setFrame:CGRectMake(self.priceWonLabel.frame.origin.x-1-self.priceLabel.frame.size.width,
                                         self.totalPriceView.frame.size.height-self.priceLabel.frame.size.height-8,
                                         self.priceLabel.frame.size.width,
                                         self.priceLabel.frame.size.height)];
    
    [self.priceTagLabel sizeToFitWithFloor];
    [self.priceTagLabel setFrame:CGRectMake(10,
                                            self.totalPriceView.frame.size.height-self.priceTagLabel.frame.size.height-11,
                                            self.priceTagLabel.frame.size.width,
                                            self.priceTagLabel.frame.size.height)];
    
    [self.priceCountLabel sizeToFitWithFloor];
    [self.priceCountLabel setFrame:CGRectMake(CGRectGetMaxX(self.priceTagLabel.frame)+5,
                                              self.totalPriceView.frame.size.height-self.priceCountLabel.frame.size.height-12,
                                              self.priceCountLabel.frame.size.width,
                                              self.priceCountLabel.frame.size.height)];
}

- (void)setButtonLayoutWithType
{
    //카트버튼
    UIImage *imgCartBgNor = [UIImage imageNamed:@"bt_optionbar_cart_nor.png"];
    UIImage *imgCartBgHil = [UIImage imageNamed:@"bt_optionbar_cart_press.png"];
    
    imgCartBgNor = [imgCartBgNor resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    imgCartBgHil = [imgCartBgHil resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    [self.cartButton setBackgroundImage:imgCartBgNor forState:UIControlStateNormal];
    [self.cartButton setBackgroundImage:imgCartBgHil forState:UIControlStateHighlighted];
    [self.cartButton setTitle:@"장바구니" forState:UIControlStateNormal];
    [self.cartButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.cartButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    //구매하기 버튼
    UIImage *imgPurchaseBgNor = [UIImage imageNamed:@"bt_optionbar_buy_nor.png"];
    UIImage *imgPurchaseBgHil = [UIImage imageNamed:@"bt_optionbar_buy_press.png"];
    
    imgPurchaseBgNor = [imgPurchaseBgNor resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    imgPurchaseBgHil = [imgPurchaseBgHil resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    [self.purchaseButton setBackgroundImage:imgPurchaseBgNor forState:UIControlStateNormal];
    [self.purchaseButton setBackgroundImage:imgPurchaseBgHil forState:UIControlStateHighlighted];
    [self.purchaseButton setTitle:@"구매하기" forState:UIControlStateNormal];
    [self.purchaseButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.purchaseButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    //시럽페이 버튼
    UIImage *imgSyrupBgNor = [UIImage imageNamed:@"bt_syrup_pay.png"];
    UIImage *imgSyrupBgHil = [UIImage imageNamed:@"bt_syrup_pay_press.png"];
    
    imgSyrupBgNor = [imgSyrupBgNor resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    imgSyrupBgHil = [imgSyrupBgHil resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [self.syrupButton setBackgroundImage:imgSyrupBgNor forState:UIControlStateNormal];
    [self.syrupButton setBackgroundImage:imgSyrupBgHil forState:UIControlStateHighlighted];
    [self.syrupButton setImage:[UIImage imageNamed:@"ic_syrup_pay.png"] forState:UIControlStateNormal];
    
    //선물하기 버튼
    [self.giftButton setBackgroundImage:imgPurchaseBgNor forState:UIControlStateNormal];
    [self.giftButton setBackgroundImage:imgPurchaseBgHil forState:UIControlStateHighlighted];
    [self.giftButton setTitle:@"선물 구매하기" forState:UIControlStateNormal];
    [self.giftButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.giftButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    //쇼킹딜전용상품 버튼
    [self.shockingdealButton setBackgroundImage:imgPurchaseBgNor forState:UIControlStateNormal];
    [self.shockingdealButton setBackgroundImage:imgPurchaseBgHil forState:UIControlStateHighlighted];
    [self.shockingdealButton setTitle:@"쇼킹딜앱 전용상품(쇼킹딜앱 실행)" forState:UIControlStateNormal];
    [self.shockingdealButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.shockingdealButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    //다운로드 버튼
    [self.downloadButton setBackgroundImage:imgPurchaseBgNor forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:imgPurchaseBgHil forState:UIControlStateHighlighted];
    [self.downloadButton setTitle:@"다운로드" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.downloadButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    NSString *syrupPayYn = self.itemDetailInfo[@"syrupPayYn"]; //시럽페이 여부
    
    if (openDrawerType == openOptionTypeShockingdeal) { //쇼킹딜전용
        [self.shockingdealButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     CGRectGetWidth(self.optionBottomView.frame)-10,
                                                     imgPurchaseBgNor.size.height)];
        [self.shockingdealButton setHidden:NO];
        
        [self.purchaseButton setHidden:YES];
        [self.cartButton setHidden:YES];
        [self.giftButton setHidden:YES];
        [self.syrupButton setHidden:YES];
        [self.downloadButton setHidden:YES];
    }
    else if (openDrawerType == openOptionTypeGift) { //선물하기
        [self.giftButton setFrame:CGRectMake(5,
                                             CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                             CGRectGetWidth(self.optionBottomView.frame)-10,
                                             imgPurchaseBgNor.size.height)];
        
        [self.giftButton setHidden:NO];
        
        [self.purchaseButton setHidden:YES];
        [self.cartButton setHidden:YES];
        [self.shockingdealButton setHidden:YES];
        [self.syrupButton setHidden:YES];
        [self.downloadButton setHidden:YES];
    }
    else if (openDrawerType == openOptionTypeDownload) { //다운로드
        
        if ([@"Y" isEqualToString:syrupPayYn]) {
            CGFloat buttonWidth = (CGRectGetWidth(self.optionBottomView.frame)-15) / 3;
            
            [self.downloadButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     buttonWidth*2,
                                                     imgPurchaseBgNor.size.height)];
            [self.syrupButton setFrame:CGRectMake(CGRectGetMaxX(self.downloadButton.frame)+5,
                                                  CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                  buttonWidth,
                                                  imgPurchaseBgNor.size.height)];
            
            [self.downloadButton setHidden:NO];
            [self.syrupButton setHidden:NO];
        }
        else {
            [self.downloadButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     CGRectGetWidth(self.bottomView.frame)-10,
                                                     imgPurchaseBgNor.size.height)];
            
            [self.downloadButton setHidden:NO];
            [self.syrupButton setHidden:YES];
        }
        
        [self.cartButton setHidden:YES];
        [self.purchaseButton setHidden:YES];
        [self.shockingdealButton setHidden:YES];
        [self.giftButton setHidden:YES];
    }
    else if (openDrawerType == openOptionTypeBasket) { //장바구니 비노출
        
        if ([@"Y" isEqualToString:syrupPayYn]) {
            CGFloat buttonWidth = (CGRectGetWidth(self.optionBottomView.frame)-15) / 3;
            
            [self.purchaseButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     buttonWidth*2,
                                                     imgPurchaseBgNor.size.height)];
            [self.syrupButton setFrame:CGRectMake(CGRectGetMaxX(self.purchaseButton.frame)+5,
                                                  CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                  buttonWidth,
                                                  imgPurchaseBgNor.size.height)];
            [self.purchaseButton setHidden:NO];
            [self.syrupButton setHidden:NO];
        }
        else {
            [self.purchaseButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     CGRectGetWidth(self.bottomView.frame)-10,
                                                     imgPurchaseBgNor.size.height)];
            [self.purchaseButton setHidden:NO];
            [self.syrupButton setHidden:YES];
        }
        
        [self.cartButton setHidden:YES];
        [self.downloadButton setHidden:YES];
        [self.shockingdealButton setHidden:YES];
        [self.giftButton setHidden:YES];
    }
    else { //기본
        if ([@"Y" isEqualToString:syrupPayYn]) {
            CGFloat buttonWidth = (CGRectGetWidth(self.optionBottomView.frame)-20) / 3;

            [self.cartButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     buttonWidth,
                                                     imgPurchaseBgNor.size.height)];
            [self.purchaseButton setFrame:CGRectMake(CGRectGetMaxX(self.cartButton.frame)+5,
                                                 CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                 buttonWidth,
                                                 imgPurchaseBgNor.size.height)];
            [self.syrupButton setFrame:CGRectMake(CGRectGetMaxX(self.purchaseButton.frame)+5,
                                                  CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                  buttonWidth,
                                                  imgPurchaseBgNor.size.height)];
            [self.purchaseButton setHidden:NO];
            [self.cartButton setHidden:NO];
            [self.syrupButton setHidden:NO];
        }
        else {
            CGFloat buttonWidth = (CGRectGetWidth(self.optionBottomView.frame)-15) / 2;
            [self.cartButton setFrame:CGRectMake(5,
                                                     CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                     buttonWidth,
                                                     imgPurchaseBgNor.size.height)];
            [self.purchaseButton setFrame:CGRectMake(CGRectGetMaxX(self.cartButton.frame)+5,
                                                 CGRectGetHeight(self.optionBottomView.frame)-imgPurchaseBgNor.size.height-5,
                                                 buttonWidth,
                                                 imgPurchaseBgNor.size.height)];
            [self.purchaseButton setHidden:NO];
            [self.cartButton setHidden:NO];
            [self.syrupButton setHidden:YES];
        }
        
        [self.downloadButton setHidden:YES];
        [self.shockingdealButton setHidden:YES];
        [self.giftButton setHidden:YES];
    }
}

#pragma mark - API

- (void)syncLoadOption:(NSString *)url completion:(void (^)(NSDictionary *json))completion
{
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             if (result) completion(result);
                                                             else		completion(nil);
                                                         }
                                                         failure:^(NSError *error) {
                                                             completion(nil);
                                                         }];
    }
}

- (void)parsingOptionData
{
    isOnlyInputOption = YES;
    
    //code 785 : 옵션이 없는 상품
    if ([self.optionDictionary[@"status"][@"code"] intValue] == 200 || [self.optionDictionary[@"status"][@"code"] intValue] == 785) {
//        NSLog(@"optionList : %@", self.optionDictionary[@"optList"]);
        
        for (NSMutableArray *array in self.optionDictionary[@"optList"]) {
            [self.optionArray addObject:[array mutableCopy]];
        }
        
        for (NSMutableArray *array in self.optionDictionary[@"addPrdList"]) {
            [self.additionalOptionArray addObject:[array mutableCopy]];
        }
        
        for (NSDictionary *dic in self.optionArray) {
            if (![@"03" isEqualToString:dic[@"optClfCd"]])
            {
                isOnlyInputOption = NO;
                break;
            }
        }
        
        if (self.optionArray.count == 0) {
            isOnlyInputOption = NO;
        }
        
        for (NSInteger i = 0; i < [self.itemDetailInfo[@"insOptCnt"] intValue]; i++) {
            [self.inputOptionArray addObject:@""];
        }
    }
    
    //옵션이 없는 상품이거나 입력형만 있을 경우 선택된 기본값이 필요함
    if ([self.optionDictionary[@"status"][@"code"] intValue] == 785 || isOnlyInputOption) {
        [self.selectedOptionArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             self.itemDetailInfo[@"prdNm"], @"prdNm",
//                                             @"", @"prdNm",
                                             self.itemDetailInfo[@"prdNo"], @"prdNo",
                                             self.priceInfoDictionary[@"finalDscPrc"], @"price",
                                             self.itemDetailInfo[@"totPrdPrc"], @"addPrc",
                                             [NSNumber numberWithBool:NO], @"optionType",
                                             @"1", @"selectedCount",
                                             @"0", @"selOptCnt",
                                             @"02", @"optClfCd",
                                             self.itemDetailInfo[@"totPrdStckNo"], @"stckNo",
                                             self.itemDetailInfo[@"totStock"], @"stckQty", nil]];
        
//        [self requestMyCouponInfo];
    }
    
    //마트일 경우 ctlgStockNo 로 넘어오는 옵션을 디폴트로 옵션선택되어 있도록 한다
    if (self.itemDetailInfo[@"ctlgStockNo"]) {
        [self addOptionByStockNo:self.itemDetailInfo[@"ctlgStockNo"]];
    }
}

- (void)visibleOptionTableView:(BOOL)isShow
{
    if (isShow)	self.optionTableView.alpha = 1.f;
    else		self.optionTableView.alpha = 0.f;
}

- (void)setupGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [pan setDelegate:self];
    [self addGestureRecognizer:pan];
}

- (void)setOptionType:(openOptionType)openType
{
    openDrawerType = openType;
}

#pragma mark - 서랍 액션

//서랍을 열기전에 타입이 선물하기인지 확인한다.
- (void)validateOpenDrawer:(BOOL)animated
{
    if (openDrawerType == openOptionTypeGift) {
        if ([self validateSelectedOptionGiftType]) {
            [self openDrawer:animated];
        }
        else {
            [UIAlertView showWithTitle:STR_APP_TITLE
                               message:@"추가구성상품은 선물할 수 없습니다. 선택된 추가구성상품을 제외 하시겠습니까?"
                     cancelButtonTitle:@"취소"
                     otherButtonTitles:@[ @"확인" ]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (alertView.cancelButtonIndex != buttonIndex) {
                                      for (NSInteger i=self.selectedOptionArray.count-1; i>=0; i--) {
                                          NSDictionary *dict = self.selectedOptionArray[i];
                                          if ([dict[@"optionType"] boolValue]) {
                                              [self.selectedOptionArray removeObjectAtIndex:i];
                                          }
                                      }
                                      
                                      [self openDrawer:animated];
                                  }
                              }];
        }
    }
    else {
        [self openDrawer:animated];
    }
}

- (void)openDrawer:(BOOL)animated
{
    //AccessLog - 옵션창 오픈
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPG00"];
    
    CGRect bottomViewFrame = CGRectZero, viewFrame = CGRectZero;
    
    UIImage *downNorImage = [UIImage imageNamed:@"bt_optionbar_down.png"];
    UIImage *downHilImage = [UIImage imageNamed:@"bt_optionbar_down.png"];
    
    self.startViewFrame = self.frame;
    self.startBottomViewFrame = self.bottomView.frame;
    
    [self.optionArrowButton setImage:downNorImage forState:UIControlStateNormal];
    [self.optionArrowButton setImage:downHilImage forState:UIControlStateHighlighted];
    
    originalBottomViewPos = CGPointMake(self.bottomView.frame.origin.x, self.superviewFrame.size.height-self.bottomView.frame.size.height);
    
    bottomViewFrame = CGRectMake(self.startBottomViewFrame.origin.x, self.superviewFrame.size.height, self.startBottomViewFrame.size.width, self.startBottomViewFrame.size.height);
    viewFrame = CGRectMake(0, self.superviewFrame.size.height - self.openMinimumHeight, self.frame.size.width, self.openMinimumHeight);
    
    if (!CGRectEqualToRect(bottomViewFrame, CGRectZero) && !CGRectEqualToRect(viewFrame, CGRectZero))
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self.bottomView setFrame:bottomViewFrame];
                [self setFrame:viewFrame];
            } completion:^(BOOL finished) {
                _isDrawerOpen = YES;
                
                if (!isInitialize)
                {
                    [self parsingOptionData];
                    [self makeOptionLayout];
                    [self setButtonLayoutWithType];
                    [self visibleOptionTableView:YES];
                    [self reloadDataInTableView];
                }
                else
                {
                    [self setButtonLayoutWithType];
                    [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
                    [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
                    
                    [self.optionBottomView setHidden:NO];
                    [self.optionTableView setHidden:NO];
                    [self visibleOptionTableView:YES];
                    [self reloadDataInTableView];
                }
                
                isInitialize = YES;
            }];
        }
        else
        {
            [self.bottomView setFrame:bottomViewFrame];
            [self setFrame:viewFrame];
            
            _isDrawerOpen = YES;
            
            if (!isInitialize)
            {
                [self parsingOptionData];
                [self makeOptionLayout];
                [self setButtonLayoutWithType];
                [self visibleOptionTableView:YES];
                [self reloadDataInTableView];
            }
            else
            {
                [self setButtonLayoutWithType];
                [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
                [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
                
                [self.optionBottomView setHidden:NO];
                [self.optionTableView setHidden:NO];
                [self visibleOptionTableView:YES];
                [self reloadDataInTableView];
            }
            
            isInitialize = YES;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)closeDrawer
{
    if (isShowingOptionItem)
    {
        [self removeOptionItemView];
        
        isShowingOptionItem = NO;
    }
    
    [self keyboardHide];
    
    CGRect bottomViewFrame = CGRectZero, viewFrame = CGRectZero, optionBottomViewFrame;
    
    UIImage *upNorImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    UIImage *upHilImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    
    [self.optionArrowButton setImage:upNorImage forState:UIControlStateNormal];
    [self.optionArrowButton setImage:upHilImage forState:UIControlStateHighlighted];
    
    CGFloat bottomOriginY = self.superviewFrame.size.height-self.bottomView.frame.size.height;
    
    bottomViewFrame = CGRectMake(self.bottomView.frame.origin.x, bottomOriginY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    optionBottomViewFrame = CGRectMake(self.optionBottomView.frame.origin.x,
                                       bottomOriginY,
                                       self.optionBottomView.frame.size.width,
                                       self.optionBottomView.frame.size.height);
    viewFrame = CGRectMake(self.frame.origin.x,
                           bottomViewFrame.origin.y - _drawerBar.frame.size.height,
                           self.frame.size.width,
                           bottomViewFrame.size.height + _drawerBar.frame.size.height);
    
    if (!CGRectEqualToRect(bottomViewFrame, CGRectZero) && !CGRectEqualToRect(viewFrame, CGRectZero))
    {
        [UIView animateWithDuration:0.3f animations:^{
            [self.bottomView setFrame:bottomViewFrame];
            [self.optionBottomView setFrame:optionBottomViewFrame];
            [self setFrame:viewFrame];
        } completion:^(BOOL finished) {
            _isDrawerOpen = NO;
            
            [UIView animateWithDuration:0.3f animations:^{
                [self setFrame:CGRectMake(self.frame.origin.x, bottomViewFrame.origin.y-([OptionDrawer ArrowButtonHeight]+1), self.frame.size.width, bottomViewFrame.size.height+[OptionDrawer ArrowButtonHeight])];
                [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
                [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
                
                originalBottomViewPos = bottomViewFrame.origin;
            }];
            
            [self.optionBottomView setHidden:YES];
            [self.optionTableView setHidden:YES];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)closeDrawerNoAnimation
{
    if (isShowingOptionItem) {
        [self removeOptionItemView];
        
        isShowingOptionItem = NO;
    }
    
    [self keyboardHide];
    
    CGRect bottomViewFrame = CGRectZero, viewFrame = CGRectZero;
    
    UIImage *upNorImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    UIImage *upHilImage = [UIImage imageNamed:@"bt_optionbar_up.png"];
    
    [self.optionArrowButton setImage:upNorImage forState:UIControlStateNormal];
    [self.optionArrowButton setImage:upHilImage forState:UIControlStateHighlighted];
    
    CGFloat bottomOriginY = self.superviewFrame.size.height-self.bottomView.frame.size.height;
    
    bottomViewFrame = CGRectMake(self.bottomView.frame.origin.x,
                                 bottomOriginY,
                                 self.bottomView.frame.size.width,
                                 self.bottomView.frame.size.height);
    
    viewFrame = CGRectMake(self.frame.origin.x,
                           bottomViewFrame.origin.y - _drawerBar.frame.size.height,
                           self.frame.size.width,
                           bottomViewFrame.size.height + _drawerBar.frame.size.height);
    
    if (!CGRectEqualToRect(bottomViewFrame, CGRectZero) && !CGRectEqualToRect(viewFrame, CGRectZero))
    {
        [UIView animateWithDuration:0.3f animations:^{
            [self.bottomView setFrame:bottomViewFrame];
            [self setFrame:viewFrame];
        } completion:^(BOOL finished) {
            _isDrawerOpen = NO;
            
            [UIView animateWithDuration:0.3f animations:^{
                [self setFrame:CGRectMake(self.frame.origin.x, bottomViewFrame.origin.y-([OptionDrawer ArrowButtonHeight]+1), self.frame.size.width, bottomViewFrame.size.height+[OptionDrawer ArrowButtonHeight])];
                [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
                [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
                
                originalBottomViewPos = bottomViewFrame.origin;
            }];
            
            [self.optionBottomView setHidden:YES];
            [self.optionTableView setHidden:YES];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 스마트옵션 선택

- (void)addOptionByName:(NSString *)optionName
{
    if (optionName == nil || optionName.length <= 0) {
        return;
    }
    
    if (!_isDrawerOpen) {
        [self validateOpenDrawer:NO];
    }
    
    if ([self.itemDetailInfo[@"insOptCnt"] intValue] > 0) {
        BOOL notCompleteInput = NO;
        
        for (NSDictionary *input in self.inputOptionArray) {
            if (![input isKindOfClass:[NSDictionary class]] || ([input isKindOfClass:[NSDictionary class]] && [@"" isEqualToString:[input[@"text"] trim]])) {
                notCompleteInput = YES;
                
                break;
            }
        }
        
        if (notCompleteInput) {
            DEFAULT_ALERT(STR_APP_TITLE, @"입력형 옵션이 입력되지 않았습니다.\n입력형 옵션을 입력 후 선택하세요.");
            
            return;
        }
    }
    
    NSArray *optionItems = _optionArray[0][@"optItemList"];
    NSDictionary *foundOption = nil;
    NSUInteger optionIndex = 0;
    for (NSDictionary *optionInfo in optionItems) {
        if ([optionInfo[@"dtlOptNm"] isEqualToString:optionName]) {
            foundOption = optionInfo;
            break;
        }
        
        optionIndex++;
    }
    
    if (foundOption) {
        NSLog(@"foundOption:%@", foundOption);
        
//        NSInteger addPrice = [foundOption[@"addPrc"] intValue];
//        NSInteger price = [self.priceInfoDictionary[@"finalDscPrc"] intValue] + addPrice;
//        NSDictionary *option = self.optionArray[0];
//        
//        [self confirmSelectItemParserWithItemName:foundOption[@"dtlOptNm"]
//                                           itemNo:foundOption[@"optNo"]
//                                          stockNo:foundOption[@"stckNo"]
//                                          stckQty:foundOption[@"stckQty"]
//                                            price:price
//                                         addPrice:addPrice
//                                        prdCompNo:@""
//                                    selectedCount:@"1"
//                            isOptionTypeAddOption:NO
//                                           option:option
//                                     compareOptNo:foundOption[@"optNo"]
//                                  inputOptionText:@""
//                                    inputOptionNo:@""
//                                    inputOptionNm:@""];
//        
//        [self confirmSelectOptionArray];
//        
//        if (_isloopingIndipendentOption) {
//            [self checkLoopSelectedIndipendentOption];
//        }
//        else {
//            [self endSelectItemParser];
//        }
        
        [self.optionTableView.delegate tableView:self.optionTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        
        [self performSelector:@selector(touchOptionWithIndex:) withObject:[NSString stringWithFormat:@"%lu", (unsigned long)optionIndex] afterDelay:0.5f];
        
//        [itemView.optionTableView.delegate tableView:itemView.optionTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:optionIndex inSection:0]];
    }
}

- (void)touchOptionWithIndex:(NSString *)index
{
    [itemView touchOptionWithIndex:[index integerValue]];
}

#pragma mark - 마트상품 옵션 선택

- (void)addOptionByStockNo:(NSString *)stockNo
{
    if (stockNo == nil || stockNo.length <= 0) {
        return;
    }
    
    if (!_isDrawerOpen) {
        [self validateOpenDrawer:NO];
    }
    
    NSArray *optionItems = _optionArray[0][@"optItemList"];
    NSDictionary *foundOption = nil;
    NSUInteger optionIndex = 0;
    for (NSDictionary *optionInfo in optionItems) {
        if ([optionInfo[@"stckNo"] isEqualToString:stockNo]) {
            foundOption = optionInfo;
            break;
        }
        
        optionIndex++;
    }
    
    if (foundOption) {
        NSLog(@"foundOption:%@", foundOption);
        
        NSInteger addPrice = [foundOption[@"addPrc"] intValue];
        NSInteger price = [self.priceInfoDictionary[@"finalDscPrc"] intValue] + addPrice;
        NSDictionary *option = self.optionArray[0];
        
        [self confirmSelectItemParserWithItemName:foundOption[@"dtlOptNm"]
                                           itemNo:foundOption[@"optNo"]
                                          stockNo:foundOption[@"stckNo"]
                                          stckQty:foundOption[@"stckQty"]
                                            price:price
                                         addPrice:addPrice
                                        prdCompNo:@""
                                    selectedCount:@"1"
                            isOptionTypeAddOption:NO
                                           option:option
                                     compareOptNo:foundOption[@"optNo"]
                                  inputOptionText:@""
                                    inputOptionNo:@""
                                    inputOptionNm:@""];
        
        [self confirmSelectOptionArray];
        
        if (_isloopingIndipendentOption) {
            [self checkLoopSelectedIndipendentOption];
        }
        else {
            [self endSelectItemParser];
        }
    }
}

#pragma mark - Selectors

- (void)onClickKeyboardDown:(id)sender
{
    [self keyboardHide];
}

- (void)onClickToggleDrawer:(id)sender
{
    if (isKeyboardShowing) {
        [self keyboardHide];
    }
    else {
        if (!_isDrawerOpen) {
            NSString *prdTypCd = [self.itemDetailInfo objectForKey:@"prdTypCd"];
            if ([@"20" isEqualToString:[prdTypCd trim]]) {
                [self setOptionType:openOptionTypeDownload];
            }
            else if ([@"Y" isEqualToString:self.itemDetailInfo[@"dealPrivatePrdYn"]]) {
                [self setOptionType:openOptionTypeShockingdeal];
            }
            else if ([@"Y" isEqualToString:self.itemDetailInfo[@"bcktExYn"]]) {
                [self setOptionType:openOptionTypeBasket];
            }
            else {
                [self setOptionType:openOptionTypePurchase];
            }

            [self validateOpenDrawer:YES];
        }
        else {
            [self closeDrawer];
            
            [self setOptionType:openOptionTypePurchase];
        }
    }
}

- (void)onClickDeleteOption:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    [self.selectedOptionArray removeObjectAtIndex:tag];
    [self reloadDataInTableView];
}

//- (void)startLodingView
//{
//    //보이는 시간이 짧고, 위치가 애매하여 구현하지 않음.
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.optionTableView animated:YES];
//    hud.mode = MBProgressHUDModeCustomView;
//    hud.opacity = 0.5f;
//    
//    if (hud.customView == nil)
//    {
//        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        indicator.hidesWhenStopped = YES;
//        hud.customView = indicator;
//        [indicator startAnimating];
//    }
//}

//- (void)stopLoadingView
//{
//    //보이는 시간이 짧고, 위치가 애매하여 구현하지 않음.
//    [MBProgressHUD hideHUDForView:self.optionTableView animated:YES];
//}

- (void)onClickSyrup:(id)sender
{
    //AccessLog - 시럽페이
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPG03"];
    
    //주문제작 상품 구매 동의
    if ([@"Y" isEqualToString:self.itemDetailInfo[@"oemPrdYn"]]) {
        [UIAlertView showWithTitle:@"주문제작 상품 구매안내"
                           message:@"해당상품은 고객님의 주문사항에 맞춰 제작되는 상품이므로 판매자의 의사에 반하여 취소 및 교환, 반품이 불가능 합니다.(상품하자시 제외)\n이에 동의하시는 경우 동의버튼을 선택해주세요."
                 cancelButtonTitle:@"동의"
                 otherButtonTitles:@[ @"취소" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (alertView.cancelButtonIndex == buttonIndex) {
                                  [self actionPurchaseOrSendGift:NO isSyrup:YES];
                              }
                              else {
                                  return;
                              }
                          }];
    }
    else {
        [self actionPurchaseOrSendGift:NO isSyrup:YES];
    }
}

- (void)onClickPurchase:(id)sender
{
//    [TRACKING_MANAGER sendEventWithCategory:@"상품상세" action:@"구매타입" label:@"구매하기" value:nil];
    
    //AccessLog - 구매하기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPG01"];
    
    // 3. Hot Click 전환수 측정 로그 호출
    NSString *ad11stPrdLogUrl = self.productInfo[@"ad11stPrdLogUrl"];
    
    if (ad11stPrdLogUrl && [[ad11stPrdLogUrl trim] length] > 0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"order"];
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{logTime}}" withString:strDate];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:ad11stPrdLogUrl];
    }
    
    //주문제작 상품 구매 동의
    if ([@"Y" isEqualToString:self.itemDetailInfo[@"oemPrdYn"]]) {
        [UIAlertView showWithTitle:@"주문제작 상품 구매안내"
                           message:@"해당상품은 고객님의 주문사항에 맞춰 제작되는 상품이므로 판매자의 의사에 반하여 취소 및 교환, 반품이 불가능 합니다.(상품하자시 제외)\n이에 동의하시는 경우 동의버튼을 선택해주세요."
                 cancelButtonTitle:@"동의"
                 otherButtonTitles:@[ @"취소" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (alertView.cancelButtonIndex == buttonIndex) {
                                  [self actionPurchaseOrSendGift:NO isSyrup:NO];
                              }
                              else {
                                  return;
                              }
                          }];
    }
    else {
        [self actionPurchaseOrSendGift:NO isSyrup:NO];
    }
}

- (void)onClickSendGift:(id)sender
{
//    [TRACKING_MANAGER sendEventWithCategory:@"상품상세" action:@"구매타입" label:@"선물하기" value:nil];
    
    //방문수령을 선택한 경우
    if ([self.delegate isVisitDlvChecked]) {
        DEFAULT_ALERT(STR_APP_TITLE, @"방문수령을 선택한 상품은 선물하기를 할 수 없습니다.");
        return;
    }
    
    //주문제작 상품 구매 동의
    if ([@"Y" isEqualToString:self.itemDetailInfo[@"oemPrdYn"]]) {
        [UIAlertView showWithTitle:@"주문제작 상품 구매안내"
                           message:@"해당상품은 고객님의 주문사항에 맞춰 제작되는 상품이므로 판매자의 의사에 반하여 취소 및 교환, 반품이 불가능 합니다.(상품하자시 제외)\n이에 동의하시는 경우 동의버튼을 선택해주세요."
                 cancelButtonTitle:@"동의"
                 otherButtonTitles:@[ @"취소" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (alertView.cancelButtonIndex == buttonIndex) {
                                  [self actionPurchaseOrSendGift:YES isSyrup:NO];
                              }
                              else {
                                  return;
                              }
                          }];
    }
    else {
        [self actionPurchaseOrSendGift:YES isSyrup:NO];
    }
}

- (void)actionPurchaseOrSendGift:(BOOL)isGift isSyrup:(BOOL)isSyrup
{
    BOOL isSelectedOptionItem = NO;
    BOOL notCompleteInput = NO;
    
    if (!self.urlDictionary || self.urlDictionary[@"checkBuyPrefix"] == nil) {
        
        DEFAULT_ALERT(STR_APP_TITLE, @"죄송합니다. 일시적인 오류가 발생하였습니다. 잠시 후 다시 이용해주세요.");
        return;
    }
    
    NSMutableArray *addItemArray = [[NSMutableArray alloc] init];
    NSMutableString *makeUrl = [[NSMutableString alloc] initWithString:self.urlDictionary[@"checkBuyPrefix"]];
    
    NSString *requestUrl = nil;
    
    NSInteger selOptCnt = [self.itemDetailInfo[@"selOptCnt"] intValue];
    NSInteger insOptCnt = [self.itemDetailInfo[@"insOptCnt"] intValue];
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (!item[@"optClfCd"] || [@"" isEqualToString:[item[@"optClfCd"] trim]]) {
            [addItemArray addObject:item];
        }
        else {
            isSelectedOptionItem = YES;
        }
    }
    
    if (!isSelectedOptionItem && [self.itemDetailInfo[@"selOptCnt"] intValue] > 0) {
        DEFAULT_ALERT(STR_APP_TITLE, @"옵션이나 수량을 선택후 구매하기를 선택해주세요.");
        return;
    }
    
    //덤상품 알럿
    if (self.isPrdPromotionAlert) {
        NSString *msg = [NSString stringWithFormat:@"%@을 선택해주세요.", self.productInfo[@"prdPromotion"][@"label"]];
        DEFAULT_ALERT(STR_APP_TITLE, msg);
        return;
    }
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (![item[@"optionType"] boolValue]) {
            NSInteger maxQty = ([@"" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]]) ? 0 : [self.itemDetailInfo[@"maxQty"] integerValue];
            
            if ([item[@"selectedCount"] intValue] > maxQty && maxQty > 0) {
                NSString *alertString = [NSString stringWithFormat:@"해당 상품의 최대구매 가능 수량(%li개)을 초과하셨습니다.", (long)maxQty];
                DEFAULT_ALERT(STR_APP_TITLE, alertString);
                return;
            }
            
            NSInteger minQty = ([@"" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]]) ? 0 : [self.itemDetailInfo[@"minQty"] integerValue];
            
            if ([item[@"selectedCount"] intValue] < minQty && minQty > 0) {
                NSString *alertString = [NSString stringWithFormat:@"해당 상품의 최소구매 가능 수량(%li개)만큼 선택해주세요.", (long)minQty];
                DEFAULT_ALERT(STR_APP_TITLE, alertString);
                return;
            }
        }
    }
    
    [self startLoadingAnimation];
    
    [makeUrl appendFormat:@"incommingCode=%@", self.itemDetailInfo[@"incommingCode"]];
    [makeUrl appendFormat:@"&prdNo=%@", self.itemDetailInfo[@"prdNo"]];
    [makeUrl appendFormat:@"&iscpn=%@", self.itemDetailInfo[@"iscpn"]];
    [makeUrl appendFormat:@"&insOptCnt=%@", self.itemDetailInfo[@"insOptCnt"]];
    [makeUrl appendFormat:@"&selOptCnt=%@", self.itemDetailInfo[@"selOptCnt"]];
    [makeUrl appendFormat:@"&dispCtgrNo=%@", self.itemDetailInfo[@"dispCtgrNo"]];
    [makeUrl appendFormat:@"&ldispCtgrNo=%@", self.itemDetailInfo[@"lDispCtgrNo"]];
    [makeUrl appendFormat:@"&selPrc=%@", self.priceInfoDictionary[@"selPrc"]];
    [makeUrl appendFormat:@"&optCnt=%d", [self.itemDetailInfo[@"selOptCnt"] intValue] + [self.itemDetailInfo[@"insOptCnt"] intValue]];
    
    //시럽결제
    [makeUrl appendFormat:@"&syrupPayYn=%@", isSyrup ? @"Y" : @"N"];
    
    //상품수령시 결제(착불) 체크여부
    if (self.isDlvCstPayChecked) { //착불 : 02
        [makeUrl appendString:@"&prdDlvCstStlTyp=02"];
    }
    else { //선결제 : 01
        [makeUrl appendString:@"&prdDlvCstStlTyp=01"];
    }
    
    //방문수령
    if (self.isVisitDlvChecked) { //Y: 방문수령
        [makeUrl appendString:@"&prdVisitDlvYn=Y"];
    }
    else { //N: 택배
        [makeUrl appendString:@"&prdVisitDlvYn=N"];
    }
    
    //마트 상품
    if (self.martDictionary && [self.martDictionary[@"isMart"] isEqualToString:@"Y"] && [Modules checkLoginFromCookie]) {
        /*
         isMart     마트 상품 여부
         strNo      선택된 마트 지점 번호
         mailNo     마트 우편번호
         mailNoSeq  마트 우편번호 시퀀스
         
         prdPromotion.promotionLayer
         martPrmtSeq    선택된 마트 프로모션  상품 시퀀스
         martPrmtNm     선택된 마트 프로모션 상품 이름
         martPrmtCd     마트 프로모션 상품 코드
         */
        
        if (nilCheck(self.martDictionary[@"strNo"]) || nilCheck(self.martDictionary[@"mailNoSeq"])) {
            DEFAULT_ALERT(STR_APP_TITLE, @"배송지 설정 후 주문이 가능합니다.");
            [self stopLoadingAnimation];
            return;
        }
        
        [makeUrl appendFormat:@"&isMart=%@", self.martDictionary[@"isMart"]];
        [makeUrl appendFormat:@"&strNo=%@", self.martDictionary[@"strNo"]];
        [makeUrl appendFormat:@"&mailNo=%@", self.martDictionary[@"mailNo"]];
        [makeUrl appendFormat:@"&mailNoSeq=%@", self.martDictionary[@"mailNoSeq"]];
        
        if (self.martPromotionDictionary) {
            [makeUrl appendFormat:@"&martPrmtSeq=%@", self.martPromotionDictionary[@"martPrmtSeq"]];
            [makeUrl appendFormat:@"&martPrmtNm=%@", self.martPromotionDictionary[@"martPrmtNm"]];
            [makeUrl appendFormat:@"&martPrmtCd=%@", self.martPromotionDictionary[@"martPrmtCd"]];
        }
    }
    
    //옵션스트링은 여기부터 조합. 다른 파라미터는 여기 위나 조합이 끝나고 넣으세요.
    [makeUrl appendString:@"&optString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            if (selOptCnt > 0)
            {
                if (item[@"compareOptNo"])
                {
                    NSString *optNo = @"0_";
                    
                    optNo = [optNo stringByAppendingString:[item[@"compareOptNo"] stringByReplacingOccurrencesOfString:@":" withString:@"!=!"]];
                    optNo = [optNo stringByReplacingOccurrencesOfString:@"," withString:@"_ @=@0_"];
                    
                    [makeUrl appendString:optNo];
                }
                else
                {
                    [makeUrl appendFormat:@"0_%@_ @=@", [item[@"prdNo"] stringByReplacingOccurrencesOfString:@":" withString:@"!=!"]];
                }
            }
            
            if (selOptCnt > 0 && insOptCnt > 0)
            {
                NSArray *inputTextArray = item[@"inputText"] ? [item[@"inputText"] componentsSeparatedByString:@"/"] : nil;
                NSArray *inputNoArray = item[@"inputNo"] ? [item[@"inputNo"] componentsSeparatedByString:@"/"] : nil;
                
                if (inputTextArray && [inputTextArray count] > 0)
                {
                    for (NSInteger i = 0; i < [inputTextArray count] - 1; i++)
                    {
                        NSString *text = inputTextArray[i];
                        NSString *optNo = inputNoArray[i];
                        
                        if ([@"" isEqualToString:[text trim]])
                        {
                            notCompleteInput = YES;
                            
                            break;
                        }
                        
                        if (i == 0) [makeUrl appendString:@"_ @=@"];
                        
                        [makeUrl appendFormat:@"1_%@_%@", optNo, text];
                        
                        if (i != [inputTextArray count] - 2) [makeUrl appendString:@"@=@"];
                    }
                }
            }
            else if (selOptCnt == 0 && insOptCnt > 0)
            {
                for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
                {
                    NSDictionary *item = self.inputOptionArray[i];
                    
                    if (![item isKindOfClass:[NSDictionary class]] || ([item isKindOfClass:[NSDictionary class]] && [@"" isEqualToString:[item[@"text"] trim]]))
                    {
                        notCompleteInput = YES;
                        
                        break;
                    }
                    
                    [makeUrl appendFormat:@"1_%@_%@", item[@"optItemNo"], item[@"text"]];
                    
                    if (i != [self.inputOptionArray count] - 1) [makeUrl appendString:@"@=@"];
                }
            }
            
            [makeUrl appendString:@"_ @=@:=:"];
        }
    }
    
    if (notCompleteInput)
    {
        [self stopLoadingAnimation];
        
        DEFAULT_ALERT(STR_APP_TITLE, @"옵션을 입력후 구매하기를 선택해주세요.");
        return;
    }
    
    if (selOptCnt > 0 && insOptCnt > 0)
    {
        for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
        {
            NSDictionary *selectedItem = self.selectedOptionArray[i];
            
            NSArray *inputNoArray = selectedItem[@"inputNo"] ? [selectedItem[@"inputNo"] componentsSeparatedByString:@"/"] : nil;
            
            if (inputNoArray && [inputNoArray count] > 0)
            {
                for (NSInteger i = 0; i < [inputNoArray count] - 1; i++)
                {
                    NSString *optNo = inputNoArray[i];
                    
                    [makeUrl appendString:@"&optionNo="];
                    [makeUrl appendFormat:@"%@", optNo];
                }
            }
        }
        
        for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
        {
            NSDictionary *selectedItem = self.selectedOptionArray[i];
            NSArray *inputTextArray = selectedItem[@"inputText"] ? [selectedItem[@"inputText"] componentsSeparatedByString:@"/"] : nil;
            
            if (inputTextArray && [inputTextArray count] > 0)
            {
                for (NSInteger i = 0; i < [inputTextArray count] - 1; i++)
                {
                    NSString *text = inputTextArray[i];
                    
                    [makeUrl appendString:@"&optionText="];
                    [makeUrl appendFormat:@"%@", text];
                }
            }
        }
        
        for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
        {
            NSDictionary *selectedItem = self.selectedOptionArray[i];
            
            NSArray *inputNameArray = selectedItem[@"inputName"] ? [selectedItem[@"inputName"] componentsSeparatedByString:@"/"] : nil;
            
            if (inputNameArray && [inputNameArray count] > 0)
            {
                for (NSInteger i = 0; i < [inputNameArray count] - 1; i++)
                {
                    NSString *name = inputNameArray[i];
                    
                    //MD가 입력했던 /를 다시 원상복구한다. (/를 |||로 치환했었음.)
                    name = [name stringByReplacingOccurrencesOfString:@"|||" withString:@"/"];
                    [makeUrl appendString:@"&optionName="];
                    [makeUrl appendFormat:@"%@", name];
                }
            }
        }
    }
    else if (selOptCnt == 0 && insOptCnt > 0)
    {
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
        {
            NSDictionary *item = self.inputOptionArray[i];
            
            [makeUrl appendString:@"&optionName="];
            [makeUrl appendFormat:@"%@", item[@"optItemNm"]];
        }
        
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
        {
            NSDictionary *item = self.inputOptionArray[i];
            
            [makeUrl appendString:@"&optionNo="];
            [makeUrl appendFormat:@"%@", item[@"optItemNo"]];
        }
        
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
        {
            NSDictionary *item = self.inputOptionArray[i];
            
            [makeUrl appendString:@"&optionText="];
            [makeUrl appendFormat:@"%@", item[@"text"]];
        }
    }
    
    [makeUrl appendString:@"&addArrPrdNoString="];
    
    for (NSInteger i = 0; i < [addItemArray count]; i++)
    {
        NSDictionary *item = addItemArray[i];
        
        [makeUrl appendFormat:@"%@:%@:%@:%@", item[@"prdNo"], item[@"prdCompNo"], item[@"selectedCount"], item[@"stckNo"]];
        
        if (i != [addItemArray count] - 1) [makeUrl appendString:@"_"];
    }
    
    for (NSInteger i = 0; i < [addItemArray count]; i++)
    {
        NSDictionary *item = addItemArray[i];
        
        [makeUrl appendFormat:@"&addPrdQty=%@", item[@"selectedCount"]];
        [makeUrl appendFormat:@"&addPrdStckNo=%@", item[@"stckNo"]];
        [makeUrl appendFormat:@"&addCurrStokQty=%@", item[@"stckQty"]];
    }
    
    [makeUrl appendString:@"&optQtyString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendFormat:@"%d:=:", [item[@"selectedCount"] intValue]];
        }
    }
    
    [makeUrl appendString:@"&optPrcString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendFormat:@"%@:=:", item[@"addPrc"] ? item[@"addPrc"] : @"0"];
        }
    }
    
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendString:@"&optionPrc="];
            [makeUrl appendFormat:@"%@", item[@"addPrc"] ? item[@"addPrc"] : @"0"];
        }
    }
    
    [makeUrl appendString:@"&optArr="];
    
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendFormat:@"%@", item[@"prdNo"]];
            
            if (i != [self.selectedOptionArray count] - 1) [makeUrl appendString:@","];
        }
    }
    
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendString:@"&optionStock="];
            [makeUrl appendFormat:@"%@", item[@"selectedCount"]];
        }
    }
    
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendString:@"&optionStckNo="];
            [makeUrl appendFormat:@"%@", item[@"stckNo"]];
        }
    }
    
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendString:@"&optionStockHid="];
            [makeUrl appendFormat:@"%@", item[@"stckQty"]];
        }
    }
    
    /*
     기존 파라미터에 &cupnIssNo1=선택할인쿠폰번호&cupnIssNo2=보너스쿠폰번호 를 옵션 갯수만큼 추가 and 배송비쿠폰은 제일 뒤에 한번 전송
     
     쿠폰 정보 : cupnIssNo1[] :- 선택할인 쿠폰 발급번호 (N개)
     */
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            NSMutableArray *couponNumbers = [NSMutableArray new];
            for (NSDictionary *coupon in _myCoupons)
            {
                NSString *optionNumber = [coupon[@"STOCK_NO"] stringValue];
                if ([optionNumber isEqualToString:item[@"stckNo"]])
                {
                    [couponNumbers addObject:coupon[@"ADD_ISS_CUPN_NO"]];
                }
            }
            
            if (couponNumbers.count > 0)
            {
                [makeUrl appendFormat:@"&cupnIssNo1=%@", [couponNumbers componentsJoinedByString:@","]];
            }
        }
    }
    
    /*
     쿠폰 정보 : cupnIssNo2[] :- 보너스할인 쿠폰 발급번호 (N개)
     */
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            NSMutableArray *couponNumbers = [NSMutableArray new];
            for (NSDictionary *coupon in _myCoupons)
            {
                NSString *optionNumber = [coupon[@"STOCK_NO"] stringValue];
                if ([optionNumber isEqualToString:item[@"stckNo"]])
                {
                    [couponNumbers addObject:coupon[@"BONUS_ISS_CUPN_NO"]];
                }
            }
            
            if (couponNumbers.count > 0)
            {
                [makeUrl appendFormat:@"&cupnIssNo2=%@", [couponNumbers componentsJoinedByString:@","]];
            }
        }
    }
    
    /*
     쿠폰 정보 : dlvCupnIssNo :- 배송비쿠폰 발급번호 (1개)
     */
    for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
    {
        NSDictionary *item = self.selectedOptionArray[i];
        
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            for (NSDictionary *coupon in _myCoupons)
            {
                NSString *optionNumber = [coupon[@"STOCK_NO"] stringValue];
                if ([optionNumber isEqualToString:item[@"stckNo"]])
                {
                    [makeUrl appendFormat:@"&dlvCupnIssNo=%@", coupon[@"DLV_ISS_CUPN_NO"]];
                    break;
                }
            }
        }
    }
    
    //gift여부
    [makeUrl appendString:[NSString stringWithFormat:@"&SendGiftYn=%@", (isGift ? @"Y" : @"N")]];
    
    //recoPick - 레코픽 집계용 URL
    if (self.trTypeCd && [self.trTypeCd length] > 0) {
        [makeUrl appendString:[NSString stringWithFormat:@"&trTypeCd=%@", self.trTypeCd]];
    }
    
    //웹에서 보내고 있는 주문 파라미터
    if (!nilCheck(self.itemDetailInfo[@"buyParameter"])) {
        [makeUrl appendString:self.itemDetailInfo[@"buyParameter"]];
    }
    
    //파라미터 조합 완료지점--------------------------------------------------------------
    
    requestUrl = [makeUrl stringByAddingPercentEscapesUsingEncoding:DEFAULT_ENCODING];
    
    [self syncLoadOption:requestUrl completion:^(NSDictionary *json) {
        if ([self.delegate respondsToSelector:@selector(requestItemPurchase:requestUrl:)])
        {
            NSString *alertMessage = nil;
            
            if (json)
            {
                NSString *prdTypCd = [self.itemDetailInfo objectForKey:@"prdTypCd"];
                if ([@"20" isEqualToString:[prdTypCd trim]])
                {
                    if ([json[@"status"][@"code"] intValue] == 401)
                    {
                        alertMessage = json[@"status"][@"d_message"];
                        
                        if (alertMessage)
                        {
                            [UIAlertView showWithTitle:STR_APP_TITLE
                                               message:alertMessage
                                     cancelButtonTitle:@"확인"
                                     otherButtonTitles:@[ @"취소" ]
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  if (alertView.cancelButtonIndex == buttonIndex) {
                                                      [self closeDrawer];
                                                      
                                                      DELEGATE_CALL(self.delegate,
                                                                    requestLogin:,
                                                                    self);
                                                  }
                                              }];
                        }
                    }
                    else if ([json[@"status"][@"code"] intValue] == 200)
                    {
                        NSString *url = [requestUrl stringByReplacingOccurrencesOfString:self.urlDictionary[@"checkBuyPrefix"]
                                                                              withString:self.urlDictionary[@"orderUrl"]];
                        
                        [self closeDrawer];
                        [self.delegate requestItemPurchase:self requestUrl:url];
                    }
                    else if ([json[@"status"][@"code"] intValue] == 780)
                    {
                        //무형상품 컨핌
                        alertMessage = json[@"status"][@"d_message"];
                        
                        if (json[@"status"][@"downloadFreePrdApiUrl"])
                        {
                            NSString *downloadFreePrdApiUrl = json[@"status"][@"downloadFreePrdApiUrl"];
                            if ([downloadFreePrdApiUrl isHttpProtocol])
                            {
                                NSString *itemQtyCount = @"";
                                for (NSDictionary *item in self.selectedOptionArray)
                                {
                                    if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
                                    {
                                        itemQtyCount = item[@"selectedCount"];
                                        break;
                                    }
                                }
                                
                                NSString *prdNo;
                                
                                if ([self.itemDetailInfo[@"prdNo"] isKindOfClass:[NSNumber class]]) {
                                    prdNo = [self.itemDetailInfo[@"prdNo"] stringValue];
                                }
                                else {
                                    prdNo = self.itemDetailInfo[@"prdNo"];
                                }
                                
                                downloadFreePrdApiUrl = [downloadFreePrdApiUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:prdNo];
                                downloadFreePrdApiUrl = [downloadFreePrdApiUrl stringByReplacingOccurrencesOfString:@"{{optQtyString}}" withString:itemQtyCount];
                                
                                downloadProductItemUrl = [[NSString alloc] initWithString:downloadFreePrdApiUrl];
                            }
                        }
                        
                        if (alertMessage)
                        {
                            [UIAlertView showWithTitle:STR_APP_TITLE
                                               message:alertMessage
                                     cancelButtonTitle:@"확인"
                                     otherButtonTitles:@[ @"취소" ]
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  if (alertView.cancelButtonIndex == buttonIndex) {
                                                      if (downloadProductItemUrl)
                                                      {
                                                          if ([downloadProductItemUrl isHttpProtocol])
                                                          {
                                                              [self startLoadingAnimation];
                                                              [self performSelector:@selector(sendFreeProductForSMS:) withObject:downloadProductItemUrl afterDelay:0.3f];
                                                          }
                                                      }
                                                  }
                                                  
                                                  if (downloadProductItemUrl) downloadProductItemUrl = nil;
                                              }];
                        }
                    }
                    else if (json[@"status"][@"d_message"])
                    {
                        alertMessage = json[@"status"][@"d_message"];
                        if (alertMessage)	DEFAULT_ALERT(STR_APP_TITLE, alertMessage);
                    }
                }
                else {
                    if ([json[@"status"][@"code"] intValue] == 200 || [json[@"status"][@"code"] intValue] == 401) {
                        NSString *url = [requestUrl stringByReplacingOccurrencesOfString:self.urlDictionary[@"checkBuyPrefix"]
                                                                              withString:self.urlDictionary[@"orderUrl"]];
                        
                        [self closeDrawer];
                        [self.delegate requestItemPurchase:self requestUrl:url];
                    }
                    else if ([json[@"status"][@"code"] intValue] == 702) {
                        //마트상품 로그인
                        [self closeDrawer];
                        
                        DELEGATE_CALL(self.delegate,
                                      requestLogin:,
                                      self);
                    }
                    else if (json[@"status"][@"d_message"]) {
                        alertMessage = json[@"status"][@"d_message"];
                    }
                    
                    if (alertMessage) {
                        DEFAULT_ALERT(STR_APP_TITLE, alertMessage);
                    }
                }
            }
        }
    }];
    
    [self stopLoadingAnimation];
}

- (void)onClickCartList:(id)sender
{
//    [TRACKING_MANAGER sendEventWithCategory:@"상품상세" action:@"구매타입" label:@"장바구니" value:nil];
    
    //AccessLog - 장바구니
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPG02"];
    
    //선택 개수
    NSInteger selectedCount = 0;
    NSInteger price = 0;
    for (NSDictionary *item in self.selectedOptionArray) {
        if ([item objectForKey:@"selectedCount"]) {
            selectedCount = [item[@"selectedCount"] integerValue];
        }
        
        if ([item objectForKey:@"price"]) {
            price = [item[@"price"] integerValue];
        }
    }
    
    // 1. 레코픽 로그 호출
    NSString *recopickLogUrl = self.productInfo[@"recopickLogUrl"];
    
    if (recopickLogUrl && [[recopickLogUrl trim] length] > 0) {
        
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"basket"];
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:[NSString stringWithFormat:@"%ld", (long)selectedCount]];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:recopickLogUrl];
    }
    
    // 2. 시럽AD로그 호출
    NSString *syrupAdLogUrl = self.productInfo[@"syrupAdLogUrl"];
    
    if (syrupAdLogUrl && [[syrupAdLogUrl trim] length] > 0) {
        
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{action}}" withString:@"basket"];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:[NSString stringWithFormat:@"%ld", (long)selectedCount]];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{total_sales}}" withString:[NSString stringWithFormat:@"%ld", (long)(price*selectedCount)]];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:syrupAdLogUrl];
    }
    
    // 3. Hot Click 전환수 측정 로그 호출
    NSString *ad11stPrdLogUrl = self.productInfo[@"ad11stPrdLogUrl"];
    
    if (ad11stPrdLogUrl && [[ad11stPrdLogUrl trim] length] > 0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"basket"];
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{logTime}}" withString:strDate];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:ad11stPrdLogUrl];
    }
    
    // 4. Hot Click Pairing 로그 호출
    NSString *hotClickPairingLogUrl = self.productInfo[@"hotClickPairingLogUrl"];
    
    if (hotClickPairingLogUrl && [[hotClickPairingLogUrl trim] length] > 0) {
        hotClickPairingLogUrl = [hotClickPairingLogUrl stringByReplacingOccurrencesOfString:@"{{method}}" withString:@"cart"];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:hotClickPairingLogUrl];
    }
    
    if ([@"y" isEqualToString:[self.itemDetailInfo[@"bcktExYn"] lowercaseString]])
    {
        [UIAlertView showWithTitle:STR_APP_TITLE
                           message:@"즉시구매만 가능합니다."
                 cancelButtonTitle:@"확인"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              
                          }];
        return;
    }
    
    BOOL isSelectedOptionItem = NO;
    BOOL notCompleteInput = NO;
    
    NSMutableArray *addItemArray = [[NSMutableArray alloc] init];
    NSMutableString *makeUrl = [[NSMutableString alloc] initWithString:self.urlDictionary[@"insBskPrefix"]];
    NSString *requestUrl = nil;
    
    NSInteger selOptCnt = [self.itemDetailInfo[@"selOptCnt"] intValue];
    NSInteger insOptCnt = [self.itemDetailInfo[@"insOptCnt"] intValue];
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (!item[@"optClfCd"] || [@"" isEqualToString:[item[@"optClfCd"] trim]])	[addItemArray addObject:item];
        else																		isSelectedOptionItem = YES;
    }
    
    if (!isSelectedOptionItem && [self.itemDetailInfo[@"selOptCnt"] intValue] > 0) {
        DEFAULT_ALERT(STR_APP_TITLE, @"옵션이나 수량을 선택후 장바구니를 선택해주세요.");
        return;
    }
    
    //덤상품 알럿
    if (self.isPrdPromotionAlert) {
        NSString *msg = [NSString stringWithFormat:@"%@을 선택해주세요.", self.productInfo[@"prdPromotion"][@"label"]];
        DEFAULT_ALERT(STR_APP_TITLE, msg);
        return;
    }
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (![item[@"optionType"] boolValue]) {
            NSInteger maxQty = ([@"" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]]) ? 0 : [self.itemDetailInfo[@"maxQty"] integerValue];
            
            if ([item[@"selectedCount"] intValue] > maxQty && maxQty > 0) {
                NSString *alertString = [NSString stringWithFormat:@"해당 상품의 최대구매 가능 수량(%li개)을 초과하셨습니다.", (long)maxQty];
                DEFAULT_ALERT(STR_APP_TITLE, alertString);
                return;
            }
            
            NSInteger minQty = ([@"" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]]) ? 0 : [self.itemDetailInfo[@"minQty"] integerValue];
            
            if ([item[@"selectedCount"] intValue] < minQty && minQty > 0) {
                NSString *alertString = [NSString stringWithFormat:@"해당 상품의 최소구매 가능 수량(%li개)만큼 선택해주세요.", (long)minQty];
                DEFAULT_ALERT(STR_APP_TITLE, alertString);
                return;
            }
        }
    }
    
    [makeUrl appendFormat:@"prdNo=%@", self.itemDetailInfo[@"prdNo"]];
    [makeUrl appendFormat:@"&iscpn=%@", self.itemDetailInfo[@"iscpn"]];
    [makeUrl appendFormat:@"&selOptCnt=%@", self.itemDetailInfo[@"selOptCnt"]];
    [makeUrl appendFormat:@"&insOptCnt=%@", self.itemDetailInfo[@"insOptCnt"]];
    [makeUrl appendFormat:@"&dispCtgrNo=%@", self.itemDetailInfo[@"dispCtgrNo"]];
    [makeUrl appendFormat:@"&ldispCtgrNo=%@", self.itemDetailInfo[@"lDispCtgrNo"]];
    
    //상품수령시 결제(착불) 체크여부
    if (self.isDlvCstPayChecked) { //착불 : 02
        [makeUrl appendString:@"&prdDlvCstStlTyp=02"];
    }
    else { //선결제 : 01
        [makeUrl appendString:@"&prdDlvCstStlTyp=01"];
    }
    
    //방문수령
    if (self.isVisitDlvChecked) { //Y: 방문수령
        [makeUrl appendString:@"&prdVisitDlvYn=Y"];
    }
    else { //N: 택배
        [makeUrl appendString:@"&prdVisitDlvYn=N"];
    }
    
    //마트 상품
    if (self.martDictionary && [self.martDictionary[@"isMart"] isEqualToString:@"Y"] && [Modules checkLoginFromCookie]) {
        /*
         isMart     마트 상품 여부
         strNo      선택된 마트 지점 번호
         mailNo     마트 우편번호
         mailNoSeq  마트 우편번호 시퀀스
         
         prdPromotion.promotionLayer
         martPrmtSeq    선택된 마트 프로모션  상품 시퀀스
         martPrmtNm     선택된 마트 프로모션 상품 이름
         martPrmtCd     마트 프로모션 상품 코드
         */
        
        if (nilCheck(self.martDictionary[@"strNo"]) || nilCheck(self.martDictionary[@"mailNoSeq"])) {
            DEFAULT_ALERT(STR_APP_TITLE, @"배송지 설정 후 주문이 가능합니다.");
            [self stopLoadingAnimation];
            return;
        }
        
        [makeUrl appendFormat:@"&isMart=%@", self.martDictionary[@"isMart"]];
        [makeUrl appendFormat:@"&strNo=%@", self.martDictionary[@"strNo"]];
        [makeUrl appendFormat:@"&mailNo=%@", self.martDictionary[@"mailNo"]];
        [makeUrl appendFormat:@"&mailNoSeq=%@", self.martDictionary[@"mailNoSeq"]];
        
        if (self.martPromotionDictionary) {
            [makeUrl appendFormat:@"&martPrmtSeq=%@", self.martPromotionDictionary[@"martPrmtSeq"]];
            [makeUrl appendFormat:@"&martPrmtNm=%@", self.martPromotionDictionary[@"martPrmtNm"]];
            [makeUrl appendFormat:@"&martPrmtCd=%@", self.martPromotionDictionary[@"martPrmtCd"]];
        }
    }
    
    [makeUrl appendString:@"&optString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            if (selOptCnt > 0)
            {
                if (item[@"compareOptNo"])
                {
                    NSString *optNo = @"0_";
                    
                    optNo = [optNo stringByAppendingString:[item[@"compareOptNo"] stringByReplacingOccurrencesOfString:@":" withString:@"!=!"]];
                    optNo = [optNo stringByReplacingOccurrencesOfString:@"," withString:@"_ @=@0_"];
                    
                    [makeUrl appendString:optNo];
                }
                else
                {
                    [makeUrl appendFormat:@"0_%@_ @=@", [item[@"prdNo"] stringByReplacingOccurrencesOfString:@":" withString:@"!=!"]];
                }
            }
            
            if (selOptCnt > 0 && insOptCnt > 0)
            {
                NSArray *inputTextArray = item[@"inputText"] ? [item[@"inputText"] componentsSeparatedByString:@"/"] : nil;
                NSArray *inputNoArray = item[@"inputNo"] ? [item[@"inputNo"] componentsSeparatedByString:@"/"] : nil;
                
                if (inputTextArray && [inputTextArray count] > 0)
                {
                    for (NSInteger i = 0; i < [inputTextArray count] - 1; i++)
                    {
                        NSString *text = inputTextArray[i];
                        NSString *optNo = inputNoArray[i];
                        
                        if ([@"" isEqualToString:[text trim]])
                        {
                            notCompleteInput = YES;
                            
                            break;
                        }
                        
                        if (i == 0) [makeUrl appendString:@"_ @=@"];
                        
                        [makeUrl appendFormat:@"1_%@_%@", optNo, text];
                        
                        if (i != [inputTextArray count] - 2) [makeUrl appendString:@"@=@"];
                    }
                }
            }
            else if (selOptCnt == 0 && insOptCnt > 0)
            {
                for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
                {
                    NSDictionary *item = self.inputOptionArray[i];
                    
                    if (![item isKindOfClass:[NSDictionary class]] || ([item isKindOfClass:[NSDictionary class]] && [@"" isEqualToString:[item[@"text"] trim]]))
                    {
                        notCompleteInput = YES;
                        
                        break;
                    }
                    
                    [makeUrl appendFormat:@"1_%@_%@", item[@"optItemNo"], item[@"text"]];
                    
                    if (i != [self.inputOptionArray count] - 1) [makeUrl appendString:@"@=@"];
                }
            }
            
            [makeUrl appendString:@"_ @=@:=:"];
        }
    }
    
    if (notCompleteInput)
    {
        DEFAULT_ALERT(STR_APP_TITLE, @"옵션을 입력후 장바구니를 선택해주세요.");
        return;
    }
    
    if (selOptCnt > 0 && insOptCnt > 0)
    {
        for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
        {
            NSDictionary *selectedItem = self.selectedOptionArray[i];
            
            NSArray *inputNoArray = selectedItem[@"inputNo"] ? [selectedItem[@"inputNo"] componentsSeparatedByString:@"/"] : nil;
            
            if (inputNoArray && [inputNoArray count] > 0)
            {
                for (NSInteger i = 0; i < [inputNoArray count] - 1; i++)
                {
                    NSString *optNo = inputNoArray[i];
                    
                    [makeUrl appendString:@"&optionNo="];
                    [makeUrl appendFormat:@"%@", optNo];
                }
            }
        }
        
        for (NSInteger i = 0; i < [self.selectedOptionArray count]; i++)
        {
            NSDictionary *selectedItem = self.selectedOptionArray[i];
            NSArray *inputTextArray = selectedItem[@"inputText"] ? [selectedItem[@"inputText"] componentsSeparatedByString:@"/"] : nil;
            
            if (inputTextArray && [inputTextArray count] > 0)
            {
                for (NSInteger i = 0; i < [inputTextArray count] - 1; i++)
                {
                    NSString *text = inputTextArray[i];
                    
                    [makeUrl appendString:@"&optionText="];
                    [makeUrl appendFormat:@"%@", text];
                }
            }
        }
    }
    else if (selOptCnt == 0 && insOptCnt > 0)
    {
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
        {
            NSDictionary *item = self.inputOptionArray[i];
            
            [makeUrl appendString:@"&optionNo="];
            [makeUrl appendFormat:@"%@", item[@"optItemNo"]];
        }
        
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++)
        {
            NSDictionary *item = self.inputOptionArray[i];
            
            [makeUrl appendString:@"&optionText="];
            [makeUrl appendFormat:@"%@", item[@"text"]];
        }
    }
    
    [makeUrl appendString:@"&addArrPrdNoString="];
    
    for (NSInteger i = 0; i < [addItemArray count]; i++)
    {
        NSDictionary *item = addItemArray[i];
        
        [makeUrl appendFormat:@"%@:%@:%@:%@", item[@"prdNo"], item[@"prdCompNo"], item[@"selectedCount"], item[@"stckNo"]];
        
        if (i != [addItemArray count] - 1) [makeUrl appendString:@"_"];
    }
    
    [makeUrl appendString:@"&optQtyString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendFormat:@"%d:=:", [item[@"selectedCount"] intValue]];
        }
    }
    
    [makeUrl appendString:@"&optPrcString="];
    
    for (NSDictionary *item in self.selectedOptionArray)
    {
        if (item[@"optClfCd"] && ![@"" isEqualToString:[item[@"optClfCd"] trim]])
        {
            [makeUrl appendFormat:@"%@:=:", item[@"addPrc"] ? item[@"addPrc"] : @"0"];
        }
    }
    
    [makeUrl appendString:@"&addArrPrdNoString="];
    
    for (NSInteger i = 0; i < [addItemArray count]; i++)
    {
        NSDictionary *item = addItemArray[i];
        
        [makeUrl appendFormat:@"%@:%@:%@:%@", item[@"prdNo"], item[@"prdCompNo"], item[@"selectedCount"], item[@"stckNo"]];
        
        if (i != [addItemArray count] - 1) [makeUrl appendString:@"_"];
    }
    
    //recoPick - 레코픽 집계용 URL
    if (self.trTypeCd && [self.trTypeCd length] > 0) {
        [makeUrl appendString:[NSString stringWithFormat:@"&trTypeCd=%@", self.trTypeCd]];
    }
    
    requestUrl = [makeUrl stringByAddingPercentEscapesUsingEncoding:DEFAULT_ENCODING];
    
    DELEGATE_CALL2(self.delegate,
                   requestItemWishList:requestUrl:,
                   self,
                   requestUrl);
}

- (void)onClickMinusOptionCount:(id)sender
{
    for (UITableViewCell *visibleCell in self.optionTableView.visibleCells)
    {
        if ([visibleCell isKindOfClass:[OptionItemCell class]])
        {
            OptionItemCell *cell = (OptionItemCell *)visibleCell;
            
            if (cell.tag == [sender tag])
            {
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:self.selectedOptionArray[cell.tag]];
                
                NSInteger selectedCount = [cell.countTextField.text intValue]-1;
                if (selectedCount == 0) selectedCount = 1;
                
                [item setObject:[NSString stringWithFormat:@"%ld", (long)selectedCount] forKey:@"selectedCount"];
                
                [self.selectedOptionArray replaceObjectAtIndex:cell.tag withObject:item];
                [self reloadDataInTableView];
                break;
            }
        }
    }
}

- (void)onClickPlusOptionCount:(id)sender
{
    for (UITableViewCell *visibleCell in self.optionTableView.visibleCells)
    {
        if ([visibleCell isKindOfClass:[OptionItemCell class]])
        {
            OptionItemCell *cell = (OptionItemCell *)visibleCell;
            
            if (cell.tag == [sender tag])
            {
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:self.selectedOptionArray[cell.tag]];
                
                NSInteger selectedCount = [cell.countTextField.text intValue] + 1;
                if (selectedCount > 999) selectedCount = 999;
                
                [item setObject:[NSString stringWithFormat:@"%ld", (long)selectedCount] forKey:@"selectedCount"];
                
                [self.selectedOptionArray replaceObjectAtIndex:cell.tag withObject:item];
                [self reloadDataInTableView];
                break;
            }
        }
    }
}

- (BOOL)hasOnlyAdditionalOption
{
    BOOL isAdditional = YES;
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (![item[@"optionType"] boolValue]) {
            isAdditional = NO;
            break;
        }
    }
    
    return isAdditional;
}

- (void)onClickShockingdealButton:(id)sender
{
    NSString *shockingDealAppURL = @"elevenstdeal://maintab/home";
    NSString *shockingDealAppstoreURL = @"itms-apps://itunes.apple.com/app/id804663259?mt=8";
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:shockingDealAppURL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppURL]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppstoreURL]];
    }
}

#pragma mark - 쿠폰

- (void)requestMyCouponInfoIfNeeded
{
    if (self.selectedOptionArray.count == 0) {
        [self hideMyCouponSection];
        return;
    }
    
    if (![Modules checkLoginFromCookie]) {
        return;
    }
    
    [self requestMyCouponInfo];
}

- (void)requestMyCouponInfo
{
    // http://wiki.11st.co.kr/pages/viewpage.action?pageId=18966018
    /*
     prdNo          상품번호
     selMnbdNo      셀러번호
     selMthdCd      판매방식
     lDispCtgrNo	대카번호
     mDispCtgrNo	중카번호
     sDispctgrNo	소카번호
     dispCtgrNo     전시번호
     brd_cd         브랜드코드
     selPrc         판매가
     soCupnAmt      SO 즉시할인금액
     moCupnAmt      MO 즉시할인금액
     
     optionStock	옵션수량(배열)
     optionPrc      옵션가격(배열)
     optionStckNo	옵션번호 (배열)
     */
    
    NSMutableString *queryString = [NSMutableString new];
    [queryString appendFormat:@"prdNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"prdNo"])];
    [queryString appendFormat:@"&selMnbdNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"selMemNo"])];
    [queryString appendFormat:@"&selMthdCd=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"selMthdCd"])];
    [queryString appendFormat:@"&lDispCtgrNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"lDispCtgrNo"])];
    [queryString appendFormat:@"&mDispCtgrNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"mDispCtgrNo"])];
    [queryString appendFormat:@"&sDispctgrNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"sDispCtgrNo"])];
    [queryString appendFormat:@"&dispCtgrNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"dispCtgrNo"])];
    [queryString appendFormat:@"&brd_cd=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"brd_cd"])];
//    [queryString appendFormat:@"&selPrc=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"selPrc"])];
    [queryString appendFormat:@"&selPrc=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"cpnParamSelPrc"])];
    [queryString appendFormat:@"&soCupnAmt=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"soDscAmt"])];
    [queryString appendFormat:@"&moCupnAmt=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"moDscAmt"])];
    
    for (NSDictionary *optionInfo in _selectedOptionArray) {
        //추가구성상품은 제외
        if (![optionInfo[@"optionType"] boolValue]) {
            [queryString appendFormat:@"&optionStock=%@", STRING_OR_EMPTYSTRING(optionInfo[@"selectedCount"])];
            [queryString appendFormat:@"&optionPrc=%@", STRING_OR_EMPTYSTRING(optionInfo[@"addPrc"])];
            [queryString appendFormat:@"&optionStckNo=%@", STRING_OR_EMPTYSTRING(optionInfo[@"stckNo"])];
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", PRODUCT_COUPON_DETAIL_URL, queryString];
    
    [[CPRESTClient sharedClient] requestProductDetailWithUrl:urlString
                                                     success:^(NSDictionary *dict) {
                                                         //
                                                         NSInteger statusCode = [dict[@"resultCode"] integerValue];
                                                         if (statusCode == 200) {
                                                             self.myCoupons = [NSMutableArray arrayWithArray:dict[@"result"]];//[dict[@"result"] copy];
                                                             [self showMyCouponSection];
                                                             
                                                             /*
                                                              STOCK_NO          옵션번호
                                                              ADD_ISS_CUPN_NO   선택할인,즉실할인쿠폰
                                                              ADD_DSC_AMT       선택할인 금액
                                                              BONUS_ISS_CUPN_NO 보너스쿠폰번호
                                                              BONUS_DSC_AMT     보너스쿠폰금액
                                                              SO_DSC_AMT        SO즉시할인가
                                                              DLV_ISS_CUPN_NO   배송비쿠폰
                                                              */
                                                         }
                                                     }
                                                     failure:^(NSError *error) {
                                                         //
                                                     }];
}

- (void)onClickMyCouponPopup:(id)sender
{
    if (![Modules checkLoginFromCookie]) {
        [self closeDrawer];
        
        DELEGATE_CALL(self.delegate,
                      requestLogin:,
                      self);
        return;
    }
    
    BOOL isSelectedOptionItem = NO;
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (!item[@"optClfCd"] || [@"" isEqualToString:[item[@"optClfCd"] trim]]) {
        }
        else {
            isSelectedOptionItem = YES;
        }
    }
    
    if (!isSelectedOptionItem && [self.itemDetailInfo[@"selOptCnt"] intValue] > 0) {
        DEFAULT_ALERT(STR_APP_TITLE, @"옵션이나 수량을 선택후 쿠폰변경을 선택해주세요.");
        return;
    }
    
    if ([self hasOnlyAdditionalOption]) {
        DEFAULT_ALERT(@"알림", @"추가 구성상품은 쿠폰변경을 할 수 없습니다.");
        return;
    }
    
    // http://wiki.11st.co.kr/pages/viewpage.action?pageId=18966018
    /*
     prdNo              상품번호
     prdDlvCstStlTyp	배송비 결제 방식
     visitDlvYn         방문수령 여부
     
     optionStckNo       옵션 재고번호(배열)
     optionStock        주문 수량(배열)
     optionNm           옵션명(배열, 레이어 팝업에 노출되는 용도)
     cupnIssNo1         쿠폰번호(배열, 선택할인쿠폰)
     cupnIssNo2         쿠폰번호(배열, 보너스쿠폰)
     dlvCupnIssNo       배송비 쿠폰
     addPrdAmtSum       추가구성상품 총합
     */
    
    NSMutableString *url = [NSMutableString new];
    [url appendFormat:@"prdNo=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"prdNo"])];
    //    [url appendFormat:@"&prdDlvCstStlTyp=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"dlvCstPayTypCd"])];
    //    [url appendFormat:@"&visitDlvYn=%@", STRING_OR_EMPTYSTRING(self.itemDetailInfo[@"dispVisitDlvYn"])];
    
    //상품수령시 결제(착불) 체크여부
    if (self.isDlvCstPayChecked) { //착불 : 02
        [url appendString:@"&prdDlvCstStlTyp=02"];
    }
    else { //선결제 : 01
        [url appendString:@"&prdDlvCstStlTyp=01"];
    }
    
    //방문수령
    if (self.isVisitDlvChecked) { //Y: 방문수령
        [url appendString:@"&visitDlvYn=Y"];
    }
    else { //N: 택배
        [url appendString:@"&visitDlvYn=N"];
    }
    
    if (self.martDictionary && [self.martDictionary[@"isMart"] isEqualToString:@"Y"]) {
        /*
         isMart     마트 상품 여부
         strNo      선택된 마트 지점 번호
         mailNo     마트 우편번호
         mailNoSeq  마트 우편번호 시퀀스
         
         prdPromotion.promotionLayer
         martPrmtSeq    선택된 마트 프로모션  상품 시퀀스
         martPrmtNm     선택된 마트 프로모션 상품 이름
         martPrmtCd     마트 프로모션 상품 코드
         */
        [url appendFormat:@"&strNo=%@", self.martDictionary[@"strNo"]];
    }
    
    NSInteger addPrdAmtSum = 0;
    
    for (NSDictionary *optionInfo in _selectedOptionArray) {
        //추가구성상품은 제외
        if (![optionInfo[@"optionType"] boolValue]) {
            [url appendFormat:@"&optionStckNo=%@", STRING_OR_EMPTYSTRING(optionInfo[@"stckNo"])];
            [url appendFormat:@"&optionStock=%@", STRING_OR_EMPTYSTRING(optionInfo[@"selectedCount"])];
            [url appendFormat:@"&optionNm=%@", STRING_OR_EMPTYSTRING([optionInfo[@"prdNm"] URLEncodedStringWithEncoder:DEFAULT_ENCODING])];
            
            for (NSDictionary *coupon in _myCoupons) {
                /*
                 STOCK_NO          옵션번호
                 ADD_ISS_CUPN_NO   선택할인,즉실할인쿠폰
                 ADD_DSC_AMT       선택할인 금액
                 BONUS_ISS_CUPN_NO 보너스쿠폰번호
                 BONUS_DSC_AMT     보너스쿠폰금액
                 SO_DSC_AMT        SO즉시할인가
                 DLV_ISS_CUPN_NO   배송비쿠폰
                 */
                
                NSString *optionNumber = [coupon[@"STOCK_NO"] stringValue];
                if ([optionNumber isEqualToString:optionInfo[@"stckNo"]]) {
                    [url appendFormat:@"&cupnIssNo1=%@", STRING_OR_EMPTYSTRING(coupon[@"ADD_ISS_CUPN_NO"])];
                    [url appendFormat:@"&cupnIssNo2=%@", STRING_OR_EMPTYSTRING(coupon[@"BONUS_ISS_CUPN_NO"])];
                    [url appendFormat:@"&dlvCupnIssNo=%@", STRING_OR_EMPTYSTRING(coupon[@"DLV_ISS_CUPN_NO"])];
                }
            }
        }
        else {
            addPrdAmtSum += [optionInfo[@"price"] integerValue];
        }
    }
    
    //추가구성상품 총합
    [url appendFormat:@"&addPrdAmtSum=%li", (long)addPrdAmtSum];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", PRODUCT_COUPON_POP_URL, url];
    
    if ([self.delegate respondsToSelector:@selector(didTouchMyCoupon:)]) {
        [self.delegate didTouchMyCoupon:urlString];
    }
    
    //AccessLog - 쿠폰변경 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPG04"];
}

- (void)hideMyCouponSection
{
    [self.myCouponLabel setHidden:YES];
    self.myCoupons = nil;
}

- (void)showMyCouponSection
{
    if (_myCouponSectionVisible == NO)
    {
        _myCouponSectionVisible = YES;
        
        _myCouponButton.hidden = NO;
        _myCouponLabel.hidden = NO;
        
        totalPriceViewHeight = 85;
        optionBottomViewHeight = 130;
        optionTableViewHeight = 160;

        [_totalPriceView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), totalPriceViewHeight)];
        [_optionBottomView setFrame:CGRectMake(0, CGRectGetHeight(self.frame)-optionBottomViewHeight, CGRectGetWidth(self.frame), optionBottomViewHeight)];
        [_optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
        
        [self resizePriceLabel];
        [self setButtonLayoutWithType];
    }
    
    [self localizedCouponDiscountPrice];
}

- (void)localizedCouponDiscountPrice
{
    if (_myCoupons.count > 0) {
        long long totalPrice = 0;
        for (NSDictionary *coupon in _myCoupons) {
            totalPrice += [coupon[@"ADD_DSC_AMT"] integerValue] + [coupon[@"BONUS_DSC_AMT"] integerValue] + [coupon[@"SO_DSC_AMT"] integerValue];
        }
        
        if (totalPrice > 0) {
            NSString *myCouponString = [NSString localizedStringWithFormat:@"%@원 쿠폰자동적용", @(totalPrice)];
            CGSize myCouponStringSize = GET_STRING_SIZE(myCouponString, [UIFont systemFontOfSize:13], CGRectGetWidth(self.totalPriceView.frame));
            
            [_myCouponLabel setFrame:CGRectMake(CGRectGetMinX(self.myCouponButton.frame)-(myCouponStringSize.width+7), 13, myCouponStringSize.width, 24)];
            [self.myCouponLabel setHidden:NO];
            [self.myCouponLabel setText:myCouponString];
        }
        
        [self.optionTableView reloadData];
        [self calculationTotalCouponPrice];
    }
    
    /*
     @"couponDiscountPrice" : @"ADD_DSC_AMT",
     @"bonusCouponNumber" : @"BONUS_ISS_CUPN_NO",
     @"bonusCouponDiscountPrice" : @"BONUS_DSC_AMT",
     @"soDiscountPrice" : @"SO_DSC_AMT",
     @"deliveryCouponNumber" : @"DLV_ISS_CUPN_NO" };
     */
}

- (void)calculationTotalCouponPrice
{
    NSInteger totalPrice = 0;
    
    for (NSDictionary *dic in self.myCoupons) {
        totalPrice += [dic[@"TOTAL_AMT"] intValue];
    }
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if ([item[@"optionType"] boolValue]) {
            totalPrice += [item[@"price"] intValue];
        }
    }
    
    [self.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:totalPrice]]];
    [self resizePriceLabel];
}

// 선택된 옵션 아이템의 총 금액 (쿠폰 적용 금액 빠진 금액, 갯수 반영)
- (NSUInteger)getSelectedOptionPrice:(NSDictionary *)selectedOption
{
    NSUInteger totalPrice = 0;
    
    NSUInteger itemPrice = [selectedOption[@"price"] integerValue];
    NSUInteger itemCount = [selectedOption[@"selectedCount"] integerValue];
    totalPrice = itemPrice * itemCount;
    
    NSUInteger selectedOptionNumber = [selectedOption[@"stckNo"] integerValue];
    
    for (NSDictionary *coupon in self.myCoupons) {
        
        NSUInteger STOCK_NO = [coupon[@"STOCK_NO"] integerValue];
        
        if (selectedOptionNumber == STOCK_NO) {
            totalPrice = [coupon[@"TOTAL_AMT"] integerValue];
        }
    }
    
    return totalPrice;
}

#pragma mark - deliveryNotice

- (void)onClickDeliveryNotice:(id)sender
{
    NSArray *noticeArr = self.deliveryInfoDictionary[@"layer"];
    
    if (!noticeArr || [noticeArr count] == 0) return;
    
    NSInteger layerNo = [sender tag] - tagNoticeBtnVal;
    
    NSDictionary *layerDic = nil;
    
    for (NSInteger nIndex = 0; nIndex < [noticeArr count]; nIndex++)
    {
        NSInteger tempNo = [noticeArr[nIndex][@"no"] intValue];
        
        if (layerNo == tempNo)
        {
            layerDic = noticeArr[nIndex];
            break;
        }
    }
    
    NSMutableArray *item = layerDic[@"content"];
    NSString *title = [layerDic[@"title"] trim];
    
    if (!item || [item count] == 0) return;
    
    CGFloat noticeViewHeight = self.superviewFrame.size.height - (self.superviewFrame.size.height/3) - 35.f;
    UIView *noticeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.superviewFrame.size.width, noticeViewHeight)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, noticeView.frame.size.width, noticeView.frame.size.height)];
    
    CGFloat originY = 18.f;
    CGFloat marginY = 4.f;
    for (NSInteger nIndex = 0; nIndex < [item count]; nIndex++)
    {
        if (nIndex != 0)
        {
            //라인을 그려준다.
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
            [lineView setBackgroundColor:UIColorFromRGB(0xe3e3e4)];
            [lineView setFrame:CGRectMake(0, originY + 5, noticeView.frame.size.width, 1.f)];
            [scrollView addSubview:lineView];
            
            originY = lineView.frame.origin.y + lineView.frame.size.height + marginY + 5;
        }
        
        NSString *itemTitle = [[[item objectAtIndex:nIndex] objectForKey:@"title"] trim];
        
        if (itemTitle && [[itemTitle trim] length] > 0)
        {
            UILabel *itemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, originY, noticeView.frame.size.width - 30.f, 0)];
            [itemTitleLabel setNumberOfLines:5];
            [itemTitleLabel setText:itemTitle];
            [itemTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [itemTitleLabel sizeToFitWithFloor];
            
            [scrollView addSubview:itemTitleLabel];
            
            originY = itemTitleLabel.frame.origin.y + itemTitleLabel.frame.size.height + marginY;
        }
        
        NSArray *contentArr = [[item objectAtIndex:nIndex] objectForKey:@"content"];
        
        if (contentArr && [contentArr count] > 0)
        {
            for (NSInteger mIndex = 0; mIndex < [contentArr count]; mIndex++)
            {
                NSString *leftTitle = [[[contentArr objectAtIndex:mIndex] objectForKey:@"label"] trim];
                NSString *rightTitle = [[[contentArr objectAtIndex:mIndex] objectForKey:@"text"] trim];
                
                //double space 제거..
                leftTitle = [leftTitle stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                rightTitle = [rightTitle stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                
                UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, originY, 90.f, 0)];
                UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftLabel.frame.origin.x+leftLabel.frame.size.width+20.f, originY, scrollView.frame.size.width - (leftLabel.frame.origin.x + leftLabel.frame.size.width + 35.f), 0)];
                
                [leftLabel setNumberOfLines:5];
                [leftLabel setText:leftTitle];
                [leftLabel setFont:[UIFont systemFontOfSize:13.f]];
                [leftLabel setTextColor:UIColorFromRGB(0x1a1a1a)];
                [leftLabel sizeToFitWithFloor];
                
                [rightLabel setNumberOfLines:5];
                [rightLabel setText:rightTitle];
                [rightLabel setFont:[UIFont systemFontOfSize:13.f]];
                [rightLabel setBackgroundColor:[UIColor clearColor]];
                [rightLabel setTextColor:UIColorFromRGB(0x666666)];
                [rightLabel sizeToFitWithFloor];
                
                if (!leftTitle || [[leftTitle trim] length] == 0)
                {
                    [leftLabel setFrame:CGRectZero];
                    [leftLabel setHidden:YES];
                    
                    [rightLabel setFrame:CGRectMake(15.f, originY, scrollView.frame.size.width - 30.f, 0)];
                    [rightLabel sizeToFitWithFloor];
                }
                
                [scrollView addSubview:leftLabel];
                [scrollView addSubview:rightLabel];
                
                if (leftLabel.frame.size.height > rightLabel.frame.size.height)
                {
                    originY = leftLabel.frame.origin.y + leftLabel.frame.size.height + marginY;
                }
                else
                {
                    originY = rightLabel.frame.origin.y + rightLabel.frame.size.height + marginY;
                }
            }
        }
        else
        {
            //해외배송
            if ([[item objectAtIndex:nIndex] objectForKey:@"text"])
            {
                NSString *rightTitle = [[item objectAtIndex:nIndex] objectForKey:@"text"];
                
                //double space 제거..
                rightTitle = [rightTitle stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                
                UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, originY, 90.f, 0)];
                [rightLabel setNumberOfLines:5];
                [rightLabel setText:rightTitle];
                [rightLabel setFont:[UIFont systemFontOfSize:13.f]];
                [rightLabel setBackgroundColor:[UIColor clearColor]];
                [rightLabel setTextColor:UIColorFromRGB(0x666666)];
                [rightLabel sizeToFitWithFloor];
                
                [rightLabel setFrame:CGRectMake(15.f, originY, scrollView.frame.size.width - 30.f, 0)];
                [rightLabel sizeToFitWithFloor];
                [scrollView addSubview:rightLabel];
                
                originY = rightLabel.frame.origin.y + rightLabel.frame.size.height + marginY;
            }
        }
    }
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, originY + 10.f)];
    
    [noticeView setBackgroundColor:[UIColor whiteColor]];
    [noticeView addSubview:scrollView];
    
    if ([self.delegate respondsToSelector:@selector(showModalView:title:)])
    {
        [self.delegate performSelector:@selector(showModalView:title:) withObject:noticeView withObject:title];
    }
}

#pragma mark - OptionItemViewDelegate

- (void)didTouchCloseDrawerButton
{   
    [self closeDrawer];
}

- (void)didSelectedOptionItem:(OptionItemView *)optionItemView item:(NSDictionary *)item selectedRow:(NSInteger)selectedRow isConfirm:(BOOL)isConfirm
{
    //현재선택된 옵션 재설정
    currentOptionRow = selectedRow;
    
    if (isConfirm) {
        [UIView animateWithDuration:0.3f animations:^{
            [optionItemView setAlpha:0];
        } completion:^(BOOL finished) {
//            [optionItemView removeFromSuperview];
            [self removeOptionItemView];
            
            if (item) {
                [self startSelectItemParser:item];
            }
        }];
    }
    else {
        if (item) {
            [self startSelectItemParser:item];
        }
    }
}

- (void)removeOptionItemView
{
    if (itemView) {
        [itemView removeFromSuperview];
        itemView = nil;
    }
}

#pragma mark - 옵션 선택 시작

- (void)startSelectItemParser:(NSDictionary *)item
{
    if (currentOptionSection == 0)
    {
        //독립형 옵션 확인
        if (NO == [self isIndipendentOption:self.optionArray])
        {
            //일반 옵션 : 상위 옵션이 선택되면 하위옵션을 초기화한다.
            for (int i=0; i<[self.optionArray count]; i++) {
                if (i > currentOptionRow) {
                    
                    if ([[self.optionArray objectAtIndex:i] objectForKey:@"selectedItemNm"]) {
                        [[self.optionArray objectAtIndex:i] removeObjectForKey:@"selectedItemNm"];
                    }
                    
                    if ([[self.optionArray objectAtIndex:i] objectForKey:@"compareOptNo"]) {
                        [[self.optionArray objectAtIndex:i] removeObjectForKey:@"compareOptNo"];
                    }
                    
                    if ([[self.optionArray objectAtIndex:i] objectForKey:@"optItemList"]) {
                        [[self.optionArray objectAtIndex:i] removeObjectForKey:@"optItemList"];
                    }
                }
            }
            
            [self optionTypeDefaultOptionParser:item currentOptionSection:currentOptionSection currentOptionRow:currentOptionRow];
        }
        else
        {
            //독립형 옵션
            _isGetIndipendentOptionName = YES;
            [self addIndipendentOptionArray:item optionRow:currentOptionRow];
            [self optionTypeDefaultOptionParser:item currentOptionSection:currentOptionSection currentOptionRow:currentOptionRow];
        }
    }
    else if (currentOptionSection == 1)
    {
        [self optionTypeAddOptionParser:item currentOptionSection:currentOptionSection currentOptionRow:currentOptionRow];
    }
}

#pragma mark - 옵션 선택 종료

- (void)endSelectItemParser
{
    [self reloadDataInTableView];
    isShowingOptionItem = NO;
    [self stopLoadingAnimation];
}

- (void)reloadDataInTableView
{
    if (itemView) {
        [itemView setOptions:self.optionArray];
//        [itemView.optionTableView reloadData];
        [itemView reloadOptionItemView];
    }
    
    [self.optionTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self calculationTotalPrice];
    [self requestMyCouponInfoIfNeeded];
}

- (void)calculationTotalPrice
{
    NSInteger totalPrice = 0;
    NSInteger totalPriceCount = 0;
    
    for (NSDictionary *dic in self.selectedOptionArray)
    {
        totalPrice += [dic[@"price"] intValue] * [dic[@"selectedCount"] intValue];
        totalPriceCount += [dic[@"selectedCount"] intValue];
    }
    
    [self.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:totalPrice]]];
    [self.priceCountLabel setText:[NSString stringWithFormat:@"(%ld개)", (long)totalPriceCount]];
    [self resizePriceLabel];
}

#pragma mark - 독립형 옵션 상품 저장

- (BOOL)isIndipendentOption:(NSArray *)array
{
    if (!array) return NO;
    
    NSInteger indipendentOptionCount = 0;
    for (int i=0; i<array.count; i++) {
        NSString *tOptClfCd = [[array objectAtIndex:i] objectForKey:@"optClfCd"];
        
        if ([@"02" isEqualToString:tOptClfCd]) {
            indipendentOptionCount++;
        }
    }
    
    return indipendentOptionCount > 0 ? YES : NO;
}

- (BOOL)isAllSelectedIndipendentOption:(NSArray *)array
{
    if (!array) return NO;
    
    //독립형 옵션 확인
    NSInteger tIndipendentOptionCount = 0;
    NSInteger tIdipendentSelectCount = 0;
    for (int i=0; i<array.count; i++) {
        NSString *tOptClfCd = [[array objectAtIndex:i] objectForKey:@"optClfCd"];
        NSString *tSelectItemNm = [[array objectAtIndex:i] objectForKey:@"selectedItemNm"];
        
        if ([@"02" isEqualToString:tOptClfCd]) {
            tIndipendentOptionCount++;
            
            if (tSelectItemNm && [[tSelectItemNm trim] length] > 0) {
                tIdipendentSelectCount++;
            }
        }
    }
    
    return tIndipendentOptionCount == tIdipendentSelectCount ? YES : NO;
}

//option row 순서에 따라 저장한다. //같은 Row가 있으면 덮어쓴다.
- (void)addIndipendentOptionArray:(NSDictionary *)item optionRow:(NSInteger)optionRow
{
    //같은 Row가 있는지 확인한다.
    NSInteger	selectIdx = -1;
    for (int i=0; i<[self.saveSelectItemArray count]; i++) {
        
        NSInteger tRow = [[[self.saveSelectItemArray objectAtIndex:i] objectForKey:@"optionRow"] intValue];
        
        if (tRow == optionRow) {
            selectIdx = i;
            break;
        }
    }
    
    //중복이면 덮어쓴다.
    if (selectIdx != -1) {
        [self.saveSelectItemArray removeObjectAtIndex:selectIdx];
        
        [self.saveSelectItemArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSString stringWithFormat:@"%ld", (long)optionRow], @"optionRow",
                                                item, @"item", nil]
                                       atIndex:selectIdx];
        
        return;
    }
    
    //optionRow를 기준으로 정렬하여 저장한다.
    selectIdx = -1;
    for (int i=0; i<[self.saveSelectItemArray count]; i++) {
        
        NSInteger tRow = [[[self.saveSelectItemArray objectAtIndex:i] objectForKey:@"optionRow"] intValue];
        
        if (tRow > optionRow) {
            selectIdx = i;
            break;
        }
    }
    
    if (selectIdx != -1) {
        [self.saveSelectItemArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSString stringWithFormat:@"%ld", (long)optionRow], @"optionRow",
                                                item, @"item", nil]
                                       atIndex:selectIdx];
    }
    else {
        [self.saveSelectItemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%ld", (long)optionRow], @"optionRow",
                                             item, @"item", nil]];
    }
}

- (void)checkFinishedSelectIndipendentOption
{
    if ([self isAllSelectedIndipendentOption:self.optionArray])
    {
        _isGetIndipendentOptionName = NO;
        
        //임시변수에 저장해놓는다.
        if ([_saveLoopItemArray count] == 0) _saveLoopItemArray = [NSMutableArray arrayWithArray:_saveSelectItemArray];
        _isloopingIndipendentOption = YES;
        [self checkLoopSelectedIndipendentOption];
    }
    else
    {
        _isGetIndipendentOptionName = NO;
        [self endSelectItemParser];
    }
}

- (void)checkLoopSelectedIndipendentOption
{
    if ([_saveLoopItemArray count] == 0) {
        _isloopingIndipendentOption = NO;
        [self endSelectItemParser];
        return;
    }
    
    NSDictionary *item = [NSDictionary dictionaryWithDictionary:[[_saveLoopItemArray objectAtIndex:0] objectForKey:@"item"]];
    NSInteger optionRow = [[[_saveLoopItemArray objectAtIndex:0] objectForKey:@"optionRow"] intValue];
    
    [_saveLoopItemArray removeObjectAtIndex:0];
    
    //currentOptionSection은 무조건 0이다. 1은 추가구성 상품임. (추가구성 상품은 독립형이 없다.)
    [self optionTypeDefaultOptionParser:item currentOptionSection:0 currentOptionRow:optionRow];
}

#pragma mark - 상품선택 (Default 상품)
//선택형 / 입력형 일반 상품
- (void)optionTypeDefaultOptionParser:(NSDictionary *)item currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow
{
    NSDictionary *option = self.optionArray[optionRow];
    NSArray *optNoSeparator = [item[@"optNo"] componentsSeparatedByString:@":"];
    
    //셀렉트 박스
    if (![@"03" isEqualToString:option[@"optClfCd"]]) {
        if ((optNoSeparator && [optNoSeparator count] > 1 && [optNoSeparator[0] intValue] < [self.itemDetailInfo[@"selOptCnt"] intValue])) {
            [self getOptionTypeDefaultOptionItemList:item
                                      optNoSeparator:optNoSeparator
                                              option:option
                                currentOptionSection:optionSection
                                    currentOptionRow:optionRow];
        }
        else {
            [self checkOptionTypeDefaultOptionMultiOptionInfo:item
                                               optNoSeparator:optNoSeparator
                                                       option:option
                                         currentOptionSection:optionSection
                                             currentOptionRow:optionRow];
        }
    }
    else {
        //따로 분기처리가 되어있으나, 해당 함수는 didSelectedOptionItem에서 호출되기 때문에 셀렉트박스이외에
        //입력형 처리시에는 호출될리 없다. (즉, 해당 else는 history를 위해 남겨둠.)
    }
}

- (void)getOptionTypeDefaultOptionItemList:(NSDictionary *)item  optNoSeparator:(NSArray *)optNoSeparator option:(NSDictionary *)option currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow
{
//    NSString *containOptNo = [self.multiOptionInfoDictionary objectForKey:optNoSeparator[0]] ? [self.multiOptionInfoDictionary objectForKey:optNoSeparator[0]][@"optNo"] : @"";
    NSString *optNo = @"";
    NSString *compareOptNo = @"";
    NSString *url = nil;
    
    for (NSInteger index = 1; index < [optNoSeparator[0] intValue]; index++)
    {
        NSString *multiOptNo = [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"optNo"];
        
        if (!multiOptNo) continue;
        
        optNo = [optNo stringByAppendingString:multiOptNo];
        optNo = [optNo stringByAppendingString:@","];
        
        compareOptNo = [compareOptNo stringByAppendingString:multiOptNo];
        compareOptNo = [compareOptNo stringByAppendingString:@","];
    }
    
    optNo = [optNo stringByAppendingString:item[@"optNo"]];
    compareOptNo = [compareOptNo stringByAppendingString:item[@"optNo"]];
    
    if ([self.itemDetailInfo[@"selOptCnt"] intValue] != [optNoSeparator[0] intValue] + 1)
    {
        url = [NSString stringWithFormat:@"%@prdNo=%@", self.urlDictionary[@"subOptPrefix"], self.itemDetailInfo[@"prdNo"]];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@prdNo=%@", self.urlDictionary[@"lastOptPrefix"], self.itemDetailInfo[@"prdNo"]];
    }
    
    url = [url stringByAppendingFormat:@"&optNo=%@", optNo];
    url = [url stringByAppendingFormat:@"&selOptCnt=%d", [optNoSeparator[0] intValue] + 1];
    
    if (url) // && ![containOptNo isEqualToString:item[@"optNo"]])
    {
        [self syncLoadOption:url completion:^(NSDictionary *json) {
            if (json)
            {
                if ([json[@"status"][@"code"] intValue] == 200)
                {
                    //기존의 옵션에 새로 조회해온 하위 옵션을 추가
                    if (json[@"optList"] && [json[@"optList"] count] > 0 && (NO == _isGetIndipendentOptionName && NO == _isloopingIndipendentOption))
                    {
                        [self.optionArray[optionRow + 1] setObject:compareOptNo forKey:@"compareOptNo"];
                        [self.optionArray[optionRow + 1] setObject:json[@"optList"] forKey:@"optItemList"];
                    }
                    
                    [self.optionArray[optionRow] removeObjectForKey:@"selectedItemNm"];
                    [self.optionArray[optionRow] setObject:item[@"dtlOptNm"] forKey:@"selectedItemNm"];
                    
                    [self.multiOptionInfoDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:item[@"optNo"], @"optNo", item[@"dtlOptNm"], @"dtlOptNm", self.optionArray[optionRow][@"optItemNm"], @"optItemNm", nil] forKey:optNoSeparator[0]];
                    
                    BOOL isReturn = [self setSelectedOptionItemName:item option:option currentOptionSection:optionSection currentOptionRow:optionRow];
                    if (isReturn) {
                        [self checkFinishedSelectIndipendentOption];
                        return;
                    }
                    
                    //next Step
                    [self checkLastSelectedItem:item
                                 optNoSeparator:optNoSeparator
                                         option:option
                           currentOptionSection:optionSection
                               currentOptionRow:optionRow
                                       itemName:@""
                                         itemNo:@""
                                   compareOptNo:compareOptNo
                                       addPrice:0
                                          price:0
                                     isLastItem:NO];
                }
                else
                {
                    [UIAlertView showWithTitle:STR_APP_TITLE
                                       message:json[@"status"][@"d_message"]
                             cancelButtonTitle:@"확인"
                             otherButtonTitles:nil
                                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          BOOL isReturn = [self setSelectedOptionItemName:item option:option currentOptionSection:optionSection currentOptionRow:optionRow];
                                          if (isReturn) {
                                              [self checkFinishedSelectIndipendentOption];
                                              return;
                                          }
                                          
                                          //next Step
                                          [self checkLastSelectedItem:item
                                                       optNoSeparator:optNoSeparator
                                                               option:option
                                                 currentOptionSection:optionSection
                                                     currentOptionRow:optionRow
                                                             itemName:@""
                                                               itemNo:@""
                                                         compareOptNo:compareOptNo
                                                             addPrice:0
                                                                price:0
                                                           isLastItem:NO];
                                      }];
                }
            }
        }];
    }
    else
    {
        BOOL isReturn = [self setSelectedOptionItemName:item option:option currentOptionSection:optionSection currentOptionRow:optionRow];
        if (isReturn) {
            [self checkFinishedSelectIndipendentOption];
            return;
        }
        
        //next Step
        [self checkLastSelectedItem:item
                     optNoSeparator:optNoSeparator
                             option:option
               currentOptionSection:optionSection
                   currentOptionRow:optionRow
                           itemName:@""
                             itemNo:@""
                       compareOptNo:compareOptNo
                           addPrice:0
                              price:0
                         isLastItem:NO];
    }
}

- (void)checkOptionTypeDefaultOptionMultiOptionInfo:(NSDictionary *)item  optNoSeparator:(NSArray *)optNoSeparator option:(NSDictionary *)option currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow
{
    NSString *compareOptNo = @"";
    NSString *itemName = @"";
    NSString *itemNo = @"";
    NSInteger addPrice = 0, price = 0;
    
    for (NSInteger index = 1; index < [self.multiOptionInfoDictionary count] + 1; index++)
    {
        NSString *multiOptNo = [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"optNo"];
        NSString *multiOptNm = [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"dtlOptNm"];
        
        if (multiOptNm) {
            itemName = [itemName stringByAppendingString:multiOptNm];
            itemName = [itemName stringByAppendingString:@"/"];
            
            compareOptNo = [compareOptNo stringByAppendingString:multiOptNo];
        }
        
        if ([self.multiOptionInfoDictionary count] != index) compareOptNo = [compareOptNo stringByAppendingString:@","];
    }
    
    itemName = [itemName stringByAppendingString:STRING_OR_EMPTYSTRING(item[@"dtlOptNm"])];
    itemNo = item[@"optNo"];
    addPrice = [item[@"addPrc"] intValue];
    price = [self.priceInfoDictionary[@"finalDscPrc"] intValue] + addPrice;
    
    [self.optionArray[optionRow] setObject:compareOptNo forKey:@"compareOptNo"];
    BOOL isReturn = [self setSelectedOptionItemName:item option:option currentOptionSection:optionSection currentOptionRow:optionRow];
    if (isReturn) {
        [self checkFinishedSelectIndipendentOption];
        return;
    }
    
    //next step
    [self checkLastSelectedItem:item
                 optNoSeparator:optNoSeparator
                         option:option
           currentOptionSection:optionSection
               currentOptionRow:optionRow
                       itemName:itemName
                         itemNo:itemNo
                   compareOptNo:compareOptNo
                       addPrice:addPrice
                          price:price
                     isLastItem:YES];
}

- (BOOL)setSelectedOptionItemName:(NSDictionary *)item option:(NSDictionary *)option currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow
{
    if ([option[@"selOptCnt"] intValue] >= 1)
    {
        [self.optionArray[optionRow] setObject:item[@"dtlOptNm"] forKey:@"selectedItemNm"];
    }
    
    return _isGetIndipendentOptionName;
}

- (void)checkLastSelectedItem:(NSDictionary *)item optNoSeparator:(NSArray *)optNoSeparator option:(NSDictionary *)option currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow itemName:(NSString *)itemName itemNo:(NSString *)itemNo compareOptNo:(NSString *)compareOptNo addPrice:(NSInteger)addPrice price:(NSInteger)price isLastItem:(BOOL)isLastItem
{
    if (isLastItem)
    {
        //input box 이름 먼저 확인한다.
        NSMutableString *inputOptionText = [[NSMutableString alloc] init];
        NSMutableString *inputOptionNo = [[NSMutableString alloc] init];
        NSMutableString *inputOptionNm = [[NSMutableString alloc] init];
        
        for (NSDictionary *inputDic in self.inputOptionArray)
        {
            [inputOptionText appendString:inputDic[@"text"]];
            [inputOptionText appendString:@"/"];
            
            [inputOptionNo appendFormat:@"%@", inputDic[@"optItemNo"]];
            [inputOptionNo appendString:@"/"];
            
            //문구에 /가 들어가면 안되는데, MD입력시 /를 넣어주는 경우가 있어서 강제로 변경해준다.
            //이후 하단에 파싱하는 부분에서 다시 |||를 /로 변경하는 작업을 해야한다.
            NSString *replaceOptionName = inputDic[@"optItemNm"];
            replaceOptionName = [replaceOptionName stringByReplacingOccurrencesOfString:@"/" withString:@"|||"];
            
            [inputOptionNm appendFormat:@"%@", replaceOptionName];
            [inputOptionNm appendString:@"/"];
        }
        
        if (itemName) {
            itemName = [inputOptionText stringByAppendingString:itemName];
        }
        
        NSMutableString *_compareOptNo = [[NSMutableString alloc] init];
        
        if (optNoSeparator && [optNoSeparator count] > 0 && [optNoSeparator[0] intValue] >= [self.itemDetailInfo[@"selOptCnt"] intValue])
        {
            NSMutableString *requestUrl = [[NSMutableString alloc] initWithString:self.urlDictionary[@"stockInfoPrefix"]];
            
            [requestUrl appendFormat:@"prdNo=%@", self.itemDetailInfo[@"prdNo"]];
            [requestUrl appendString:@"&mixOptNo="];
            
            for (NSInteger index = 1; index < [self.itemDetailInfo[@"selOptCnt"] intValue]; index++)
            {
                [requestUrl appendFormat:@"%@,", [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"optNo"]];
                [_compareOptNo appendFormat:@"%@,", [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"optNo"]];
            }
            
            [_compareOptNo appendString:itemNo];
            
            [requestUrl appendString:itemNo];
            [requestUrl appendFormat:@"&selOptCnt=%@", option[@"selOptCnt"]];
            [requestUrl appendFormat:@"&selOptTyp=%@", option[@"optClfCd"]];
            [requestUrl appendFormat:@"&optNmList="];
            
            for (NSInteger index = 1; index < [self.itemDetailInfo[@"selOptCnt"] intValue]; index++)
            {
                [requestUrl appendFormat:@"%@,", [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"optItemNm"]];
            }
            
            [requestUrl appendString:self.optionArray[optionRow][@"optItemNm"]];
            [requestUrl appendFormat:@"&mixOptNm="];
            
            for (NSInteger index = 1; index < [self.itemDetailInfo[@"selOptCnt"] intValue]; index++)
            {
                [requestUrl appendFormat:@"%@,", [self.multiOptionInfoDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)index]][@"dtlOptNm"]];
            }
            
            [requestUrl appendString:item[@"dtlOptNm"]];
            
            if (requestUrl)
            {
                [self syncLoadOption:[requestUrl stringByAddingPercentEscapesUsingEncoding:DEFAULT_ENCODING] completion:^(NSDictionary *json) {
                    if (json) {
                        if ([json[@"status"][@"code"] intValue] == 200) {
                            NSLog(@"stock : %@", json[@"optInfo"]);
                            
                            NSString *stockNo = json[@"optInfo"][@"prdStckNo"];
                            NSString *stckQty = json[@"optInfo"][@"stckQty"];
                            
                            if (!stckQty || [@"" isEqualToString:stckQty]) {
                                stckQty = item[@"stckQty"] ? item[@"stckQty"] : @"";
                            }
                            
                            //next step
                            [self confirmSelectItemParserWithItemName:itemName
                                                               itemNo:itemNo
                                                              stockNo:stockNo
                                                              stckQty:stckQty
                                                                price:price
                                                             addPrice:addPrice
                                                            prdCompNo:@""
                                                        selectedCount:@"1"
                                                isOptionTypeAddOption:NO
                                                               option:option
                                                         compareOptNo:_compareOptNo
                                                      inputOptionText:inputOptionText
                                                        inputOptionNo:inputOptionNo
                                                        inputOptionNm:inputOptionNm];
                            
                            [self confirmSelectOptionArray];
                            
                            if (_isloopingIndipendentOption) {
                                [self checkLoopSelectedIndipendentOption];
                            }
                            else {
                                [self endSelectItemParser];
                            }
                        }
                        else
                        {
                            [UIAlertView showWithTitle:STR_APP_TITLE
                                               message:json[@"status"][@"d_message"]
                                     cancelButtonTitle:@"확인"
                                     otherButtonTitles:nil
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  //next step
                                                  [self confirmSelectItemParserWithItemName:itemName
                                                                                     itemNo:itemNo
                                                                                    stockNo:@""
                                                                                    stckQty:(item[@"stckQty"] ? item[@"stckQty"] : @"")
                                                                                      price:price
                                                                                   addPrice:addPrice
                                                                                  prdCompNo:@""
                                                                              selectedCount:@"1"
                                                                      isOptionTypeAddOption:NO
                                                                                     option:option
                                                                               compareOptNo:_compareOptNo
                                                                            inputOptionText:inputOptionText
                                                                              inputOptionNo:inputOptionNo
                                                                              inputOptionNm:inputOptionNm];
                                                  
                                                  [self confirmSelectOptionArray];
                                                  
                                                  if (_isloopingIndipendentOption)	[self checkLoopSelectedIndipendentOption];
                                                  else								[self endSelectItemParser];
                                              }];
                        }
                    }
                }];
            }
        }
        else
        {
            //next step
            [self confirmSelectItemParserWithItemName:itemName
                                               itemNo:itemNo
                                              stockNo:@""
                                              stckQty:(item[@"stckQty"] ? item[@"stckQty"] : @"")
                                                price:price
                                             addPrice:addPrice
                                            prdCompNo:@""
                                        selectedCount:@"1"
                                isOptionTypeAddOption:NO
                                               option:option
                                         compareOptNo:_compareOptNo
                                      inputOptionText:inputOptionText
                                        inputOptionNo:inputOptionNo
                                        inputOptionNm:inputOptionNm];
            
            [self confirmSelectOptionArray];
            
            if (_isloopingIndipendentOption)	[self checkLoopSelectedIndipendentOption];
            else								[self endSelectItemParser];
        }
    }
    else
    {
        [self confirmSelectOptionArray];
        
        if (_isloopingIndipendentOption)	[self checkLoopSelectedIndipendentOption];
        else								[self endSelectItemParser];
    }
}

#pragma mark - 상품선택 (추가구성상품)
//추가구성상품
- (void)optionTypeAddOptionParser:(NSDictionary *)item currentOptionSection:(NSInteger)optionSection currentOptionRow:(NSInteger)optionRow
{
    NSDictionary *option = self.additionalOptionArray[optionRow];
    
    NSString *itemName = nil, *itemNo = nil, *stockNo = nil, *prdCompNo = nil, *stckQty = nil;
    NSString *selectedCount = @"1";
    
    NSInteger price = 0;
    
    itemName = item[@"prdNm"];
    itemNo = item[@"prdNo"];
    stockNo = item[@"prdStckNo"];
    prdCompNo = item[@"prdCompNo"];
    price = [item[@"addCompPrc"] intValue];
    stckQty = item[@"stckQty"] ? item[@"stckQty"] : @"";
    
    [self.additionalOptionArray[optionRow] setObject:itemNo forKey:@"compareOptNo"];
    
    //추가구성상품 등록
    [self confirmSelectItemParserWithItemName:itemName
                                       itemNo:itemNo
                                      stockNo:stockNo
                                      stckQty:stckQty
                                        price:price
                                     addPrice:0
                                    prdCompNo:prdCompNo
                                selectedCount:selectedCount
                        isOptionTypeAddOption:YES
                                       option:option
                                 compareOptNo:itemNo
                              inputOptionText:@""
                                inputOptionNo:@""
                                inputOptionNm:@""];
    
    [self confirmSelectOptionArray];
    [self endSelectItemParser];
}


- (void)confirmSelectItemParserWithItemName:(NSString *)itemName
                                     itemNo:(NSString *)itemNo
                                    stockNo:(NSString *)stockNo
                                    stckQty:(NSString *)stckQty
                                      price:(NSInteger)price
                                   addPrice:(NSInteger)addPrice
                                  prdCompNo:(NSString *)prdCompNo
                              selectedCount:(NSString *)selectedCount
                      isOptionTypeAddOption:(BOOL)isOptionTypeAddOption
                                     option:(NSDictionary *)option
                               compareOptNo:(NSString *)compareOptNo
                            inputOptionText:(NSString *)inputOptionText
                              inputOptionNo:(NSString *)inputOptionNo
                              inputOptionNm:(NSString *)inputOptionNm
{
    
    for (NSDictionary *dic in self.selectedOptionArray) {
        if ([dic[@"compareOptNo"] isEqualToString:compareOptNo]) {
            DEFAULT_ALERT(STR_APP_TITLE, @"이미 선택된 옵션입니다.");
            return;
        }
    }
    
    [self.selectedOptionArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         itemName, @"prdNm",
                                         itemNo, @"prdNo",
                                         stockNo, @"stckNo",
                                         stckQty, @"stckQty",
                                         [NSString stringWithFormat:@"%ld", (long)price], @"price",
                                         [NSString stringWithFormat:@"%ld", (long)addPrice], @"addPrc",
                                         prdCompNo, @"prdCompNo", /*item[@"stckQty"], @"stckQty",*/
                                         selectedCount, @"selectedCount",
                                         [NSNumber numberWithBool:isOptionTypeAddOption], @"optionType",
                                         option[@"selOptCnt"] ? option[@"selOptCnt"] : @"", @"selOptCnt",
                                         option[@"optClfCd"] ? option[@"optClfCd"] : @"",
                                         @"optClfCd", compareOptNo,
                                         @"compareOptNo", inputOptionText,
                                         @"inputText", inputOptionNo, @"inputNo",
                                         inputOptionNm, @"inputName", nil]];
    
    NSInteger totalPrice = 0;
    NSInteger totalPriceCount = 0;
    
    for (NSDictionary *dic in self.selectedOptionArray)
    {
        totalPrice += [dic[@"price"] intValue] * [dic[@"selectedCount"] intValue];
        totalPriceCount += [dic[@"selectedCount"] intValue];
    }
    
    [self.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:totalPrice]]];
    [self.priceCountLabel setText:[NSString stringWithFormat:@"(%ld개)", (long)totalPriceCount]];
    [self resizePriceLabel];
    
//    if (!isOptionTypeAddOption) {
//        [self requestMyCouponInfo];
//    }
}

- (void)confirmSelectOptionArray
{
    NSMutableArray *tempOption = [[NSMutableArray alloc] init];
    NSMutableArray *tempAddOption = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in self.selectedOptionArray) {
        if (![item[@"optionType"] boolValue]) {
            [tempOption addObject:item];
        }
        else {
            [tempAddOption addObject:item];
        }
    }
    
    [self.selectedOptionArray removeAllObjects];
    [self.selectedOptionArray addObjectsFromArray:tempOption];
    [self.selectedOptionArray addObjectsFromArray:tempAddOption];
}

- (void)didCloseOptionItem:(OptionItemView *)tableView
{
    isShowingOptionItem = NO;
}

- (BOOL)validateAdditionalOptionArray
{
    if ((openDrawerType != openOptionTypeGift) && ([self.additionalOptionArray count] > 0)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)validateSelectedOptionGiftType
{
    if ([self.selectedOptionArray count] == 0) {
        return YES;
    }
    
    BOOL hasAdditionalOption = NO;
    for (NSDictionary *dic in self.selectedOptionArray) {
        if ([dic[@"optionType"] boolValue]) //추가구성 상품
        {
            hasAdditionalOption = YES;
            break;
        }
    }
    
    if (!hasAdditionalOption) {
        return YES;
    }
    
    return NO;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (section == 0) {
        count = [self.optionArray count];
    }
    
    if (section == 1)	{
        count = ([self validateAdditionalOptionArray] ? [self.additionalOptionArray count] : 0);
    }
    
    if (section == 2) {
        count = [self.selectedOptionArray count];
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = 0.1f;
    
    if (section == 0) {
        if ([self.optionArray count] > 0) {
            headerHeight = 30;
        }
        else if ([self.optionDictionary[@"status"][@"code"] intValue] == 785) {
            headerHeight = 0.1f;
        }
        else if (isOnlyInputOption) {
            headerHeight = 30;
        }
    }
    
    if (section == 1 && [self validateAdditionalOptionArray]) {
        headerHeight = 30;
    }
    
    if (section == 2 && [self.selectedOptionArray count] > 0) {
        headerHeight = 10;
    }
    
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSString *maxQty = ([@"" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]]) ? nil : self.itemDetailInfo[@"maxQty"];
    NSString *minQty = ([@"" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]]) ? nil : self.itemDetailInfo[@"minQty"];
    
    //최대/최소 구매수량 있을 경우에만 노출
//    if (section == 0 && [self.optionArray count] > 0 && (maxQty || minQty)) {
//    CGFloat dateViewHeight = 0;
    CGFloat qtyViewHeight = 0.01f;
    
    if (section == 0) {
        
        if (maxQty || minQty) {
            qtyViewHeight = 28;
        }
        
//        NSString *dateOptYn = self.itemDetailInfo[@"dateOptYn"];
//        if ([@"Y" isEqualToString:dateOptYn]) {
//            NSString *dateString = @"선택한 날짜가 지나면 자동으로 구매확정되며, 환불이 불가하므로 구매시 유의하시기 바랍니다.";
//            CGSize dateStringSize = GET_STRING_SIZE(dateString, [UIFont systemFontOfSize:12], CGRectGetWidth(tableView.frame)-20);
//            dateViewHeight = dateStringSize.height+12;
//        }
        return qtyViewHeight;
    }
    
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    
    if (indexPath.section == 0 && [self.optionArray count] > 0){
        
        NSDictionary *option = self.optionArray[indexPath.row];
        if ([@"01" isEqualToString:option[@"optClfCd"]] || [@"02" isEqualToString:option[@"optClfCd"]]) {
            NSInteger optItemNo = [self.optionArray[indexPath.row][@"optItemNo"] integerValue];
            //선택형 옵션중 첫번째만 노출 idx 1부터 시작
            if (optItemNo > 1) {
                rowHeight = 0;
            }
            else {
                rowHeight = 40;
            }
        }
        else if ([@"03" isEqualToString:option[@"optClfCd"]]) {
            rowHeight = 57;
        }
    }
    
    if (indexPath.section == 1 && [self validateAdditionalOptionArray]) {
        rowHeight = 40;
    }
    
    if (indexPath.section == 2 && [self.selectedOptionArray count] > 0) {
        //상단 마진
        rowHeight += 15.f;
        
        //텍스트 라벨 높이
        NSString *addPrc = self.selectedOptionArray[indexPath.row][@"addPrc"];
        NSString *text = self.selectedOptionArray[indexPath.row][@"prdNm"];
        if (![@"0" isEqualToString:addPrc]) {
            text = [text stringByAppendingFormat:@"(%@%@)", [addPrc intValue] > 0 ? @"+" : @"", self.selectedOptionArray[indexPath.row][@"addPrc"]];
        }
        
        rowHeight += [Modules getLabelHeightWithText:text
                                               frame:CGRectMake(0, 0, tableView.frame.size.width-53.f, 0)
                                                font:[UIFont systemFontOfSize:14.f]
                                               lines:3
                                       textAlignment:NSTextAlignmentLeft];
        
        
        //텍스트 라벨 마진
        rowHeight += 10.f;
        
        //카운터 뷰 높이
        rowHeight += 24.f;
        
        //하단 마진
        rowHeight += 15.f;
    }
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    
    [view setBackgroundColor:[UIColor clearColor]];
    [label setBackgroundColor:[UIColor clearColor]];
//    NSLog(@"header:%ld, %f", (long)section, [self tableView:tableView heightForHeaderInSection:section]);;
    if (section == 0) {
        if ([self.optionArray count] > 0 || isOnlyInputOption) {
            [label setText:@"옵션"];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:UIColorFromRGB(0x5d5d5d)];
            [label setFont:[UIFont boldSystemFontOfSize:14]];
            [label setFrame:CGRectMake(10, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
        }
    }
    
    if (section == 1 && [self validateAdditionalOptionArray]) {
        [label setText:@"추가구성상품"];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:UIColorFromRGB(0x5d5d5d)];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
//        [label sizeToFitWithFloor];
        [label setFrame:CGRectMake(10, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
        
        //옵션이 있을 경우에만 라인 노출
        if ([self.optionArray count] > 0) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
            [view setClipsToBounds:NO];
            [view addSubview:lineView];
        }
    }
    
    if (section == 2 && [self.selectedOptionArray count] > 0) {
        //선택한 상품이 있을 경우
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        [view addSubview:lineView];
    }
    
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];

    [view setBackgroundColor:[UIColor clearColor]];
    
//    if (section == 0 && [self.optionArray count] > 0) {
    if (section == 0) {
        NSString *text = @"";
        NSString *maxQty = ([@"" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"maxQty"] trim]]) ? nil : self.itemDetailInfo[@"maxQty"];
        NSString *minQty = ([@"" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]] || [@"-1" isEqualToString:[self.itemDetailInfo[@"minQty"] trim]]) ? nil : self.itemDetailInfo[@"minQty"];
        NSString *selLimitStr = [@"" isEqualToString:[self.itemDetailInfo[@"selLimitStr"] trim]] ? @"" : self.itemDetailInfo[@"selLimitStr"];
        
//        CGFloat originY = 2;
        if (maxQty || minQty) {
            UILabel *qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, tableView.frame.size.width, 0)];
            
            if (!nilCheck(selLimitStr)) {
                selLimitStr = [NSString stringWithFormat:@"%@ ", selLimitStr];
            }
            
            if (maxQty && minQty) {
                text = [text stringByAppendingFormat:@"(%@최대구매수량 : %@개/최소구매수량 : %@개)", selLimitStr, maxQty, minQty];
            }
            else if (maxQty && !minQty) {
                text = [text stringByAppendingFormat:@"(%@최대구매수량 : %@개)", selLimitStr, maxQty];
            }
            else if (!maxQty && minQty) {
                text = [text stringByAppendingFormat:@"(최소구매수량 : %@개)", minQty];
            }
            
            [qtyLabel setText:text];
            [qtyLabel setFont:[UIFont systemFontOfSize:12]];
            [qtyLabel setBackgroundColor:[UIColor clearColor]];
            [qtyLabel setTextColor:UIColorFromRGB(0x8e8d8d)];
            [qtyLabel sizeToFitWithFloor];
            [qtyLabel setFrame:CGRectMake(10, 0, qtyLabel.frame.size.width, qtyLabel.frame.size.height)];
            
            [view addSubview:qtyLabel];
        }
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellIdentifier = @"OptionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryView:nil];
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        NSDictionary *option = self.optionArray[indexPath.row];
        
        // 옵셩항목구분 (01:조합형 ,02:독립형, 03:입력형)
        if ([@"01" isEqualToString:option[@"optClfCd"]] || [@"02" isEqualToString:option[@"optClfCd"]]) {
            
            //선택형 옵션중 첫번째만 노출
            NSInteger optItemNo = [self.optionArray[indexPath.row][@"optItemNo"] integerValue];
            
            if (optItemNo == 1) {
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                
                NSMutableArray *selectedTextArray = [NSMutableArray array];
                for (NSDictionary *option in self.selectedOptionArray) {
                    //추가구성상품이 아닌것만
                    if (!nilCheck(option[@"prdNm"]) && ![option[@"optionType"] boolValue]) {
                        [selectedTextArray addObject:option[@"prdNm"]];
                    }
                }

                NSString *selectedText = nil;
                if (selectedTextArray.count > 0) {
                    //마지막 선택 옵션만 하이라이트
                    selectedText = selectedTextArray.lastObject; //[selectedTextArray componentsJoinedByString:@" / "];
                }
                
                UIImage *bgImage = [UIImage imageNamed:@"layer_pd_inputbox.png"];
                bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
                
                UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_optionTableView.frame)-20, 32)];
                [selectImageView setImage:bgImage];
                [selectImageView setUserInteractionEnabled:YES];
                [cell.contentView addSubview:selectImageView];
                
                UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(selectImageView.frame)-52, 32)];
                [selectLabel setText:(nilCheck(selectedText) ? @"옵션을 선택해 주세요" : selectedText)];
                [selectLabel setTextColor:UIColorFromRGB(0xb6b6b6)];
                [selectLabel setFont:[UIFont systemFontOfSize:14]];
                [selectLabel setBackgroundColor:[UIColor clearColor]];
                [selectImageView addSubview:selectLabel];
                
                UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(selectImageView.frame)-32, 0, 32, 32)];
                [arrowImageView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
                [selectImageView addSubview:arrowImageView];
            }
        }
        else if ([@"03" isEqualToString:option[@"optClfCd"]]) //입력형
        {
            NSDictionary *inputDictionary = self.inputOptionArray[indexPath.row];
            
            //입력형 옵션 타이틀
            NSString *name = option[@"optItemNm"];
            
            CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:14]];
        
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, nameSize.width, 20)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setFont:[UIFont systemFontOfSize:14]];
            [nameLabel setText:name];
            [nameLabel setTextColor:UIColorFromRGB(0x666666)];
            [cell.contentView addSubview:nameLabel];
            
            //입력 TextField
            UIImage *bgImage = [UIImage imageNamed:@"layer_pd_inputbox.png"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            
            UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLabel.frame), CGRectGetWidth(_optionTableView.frame)-20, 32)];
            [selectImageView setImage:bgImage];
            [selectImageView setUserInteractionEnabled:YES];
            [cell.contentView addSubview:selectImageView];
            
            UIView *leftInsetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
            [leftInsetView setBackgroundColor:[UIColor clearColor]];
            
            NSAttributedString *placeholderAttribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProductOptionInputHint", nil)
                                                                                       attributes:@{
                                                                                                    NSForegroundColorAttributeName: UIColorFromRGB(0xb6b6b6), NSFontAttributeName: [UIFont systemFontOfSize:14] }];
            
            UITextField *inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_optionTableView.frame)-20, 32)];
            [inputTextField setDelegate:self];
            [inputTextField setLeftView:leftInsetView];
            [inputTextField setReturnKeyType:UIReturnKeyDone];
            [inputTextField setBorderStyle:UITextBorderStyleNone];
            [inputTextField setTextColor:UIColorFromRGB(0xb6b6b6)];
            [inputTextField setFont:[UIFont systemFontOfSize:14]];
            [inputTextField setBackgroundColor:[UIColor clearColor]];
            [inputTextField setLeftViewMode:UITextFieldViewModeAlways];
            [inputTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [inputTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [inputTextField setAttributedPlaceholder:placeholderAttribute];
            [inputTextField setTag:CELL_TEXTFIELD_TAG+indexPath.row];
            [inputTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [selectImageView addSubview:inputTextField];

            if (inputDictionary && [inputDictionary isKindOfClass:[NSDictionary class]] && ![@"" isEqualToString:[inputDictionary[@"text"] trim]]) {
                [inputTextField setText:inputDictionary[@"text"]];
            }
        }
        
        return cell;
    }
    else if (indexPath.section == 1) //추가구성상품
    {
        
        NSString *cellIdentifier = @"AdditionalOptionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryView:nil];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        NSDictionary *option = self.additionalOptionArray[indexPath.row];
        
        NSString *addPrdNm = option[@"addPrdGrpNm"];
        
        //선택된 옵션명으로 노출
        if (option[@"prdList"] && [option[@"prdList"] count] > 0) {
            
            for (NSDictionary *selectedOption in self.selectedOptionArray) {
                
                if ([selectedOption[@"optionType"] boolValue]) {
                    
                    NSArray *prdList = option[@"prdList"];
                    
                    for (NSDictionary *prdOption in prdList) {
                        if ([prdOption[@"prdNo"] isEqualToString:selectedOption[@"prdNo"]]) {
                            addPrdNm = selectedOption[@"prdNm"];
                            break;
                        }
                    }
                }
            }
        }
        
        UIImage *bgImage = [UIImage imageNamed:@"layer_pd_inputbox.png"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_optionTableView.frame)-20, 32)];
        [selectImageView setImage:bgImage];
        [selectImageView setUserInteractionEnabled:YES];
        [cell.contentView addSubview:selectImageView];
        
        UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(_optionTableView.frame)-52, 32)];
        [selectLabel setText:addPrdNm];
        [selectLabel setTextColor:UIColorFromRGB(0xb6b6b6)];
        [selectLabel setFont:[UIFont systemFontOfSize:14]];
        [selectImageView addSubview:selectLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(selectImageView.frame)-32, 0, 32, 32)];
        [arrowImageView setImage:[UIImage imageNamed:@"layer_pd_input_down.png"]];
        [selectImageView addSubview:arrowImageView];
        
        return cell;
    }
    else if (indexPath.section == 2) //선택된 옵션
    {
        NSString *cellIdentifier = @"OptionItemCell";
        
        OptionItemCell *cell = (OptionItemCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSString *title = @"";
//        NSString *addPrc = self.selectedOptionArray[indexPath.row][@"addPrc"];
        
        if (!cell) {
            cell = [[OptionItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        
        cell.tag = indexPath.row;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, cellHeight);
        
        cell.deleteButton.frame = CGRectMake(CGRectGetWidth(cell.frame)-(CGRectGetWidth(cell.deleteButton.frame)+20),
                                             cellHeight-(CGRectGetHeight(cell.deleteButton.frame)+10),
                                             CGRectGetWidth(cell.deleteButton.frame),
                                             CGRectGetHeight(cell.deleteButton.frame));
        
        
        if ([self.selectedOptionArray[indexPath.row][@"optionType"] boolValue]) {
            title = [NSString stringWithFormat:@"(추가)%@", self.selectedOptionArray[indexPath.row][@"prdNm"]];
            [cell.titleLabel setTextColor:UIColorFromRGB(0x5460d2)];
        }
        else {
            title = self.selectedOptionArray[indexPath.row][@"prdNm"];
            [cell.titleLabel setTextColor:UIColorFromRGB(0x333333)];
        }
    
        //선택된 옵션에서 추가 옵션가는 제외
//        if (![@"0" isEqualToString:addPrc]) {
//            title = [title stringByAppendingFormat:@"(%@%@)", [addPrc intValue] > 0 ? @"+" : @"", self.selectedOptionArray[indexPath.row][@"addPrc"]];
//        }
        
        cell.titleLabel.text = title;
        cell.titleLabel.frame = CGRectMake(20, 12, tableView.frame.size.width-53.f, 0.f);
        [cell.titleLabel sizeToFitWithVersionHoldWidth];
        
        [cell.countTextField setDelegate:self];
        [cell.countTextField setTag:indexPath.row];
        [cell.countTextField setText:self.selectedOptionArray[indexPath.row][@"selectedCount"]];
        
        cell.countView.frame = CGRectMake(20, cellHeight-(CGRectGetHeight(cell.deleteButton.frame)+10),
                                          cell.countView.frame.size.width, cell.countView.frame.size.height);
        
        
        cell.priceWonLabel.frame = CGRectMake(CGRectGetMinX(cell.deleteButton.frame)-(CGRectGetWidth(cell.priceWonLabel.frame) + 10),
                                              CGRectGetMinY(cell.countView.frame)+9,
                                              cell.priceWonLabel.frame.size.width,
                                              cell.priceWonLabel.frame.size.height);
        
        NSUInteger itemTotalPrice = [self getSelectedOptionPrice:self.selectedOptionArray[indexPath.row]];
        [cell.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:itemTotalPrice]]];
        
        [cell.priceLabel sizeToFitWithFloor];
        cell.priceLabel.frame = CGRectMake(CGRectGetMinX(cell.priceWonLabel.frame)-(CGRectGetWidth(cell.priceLabel.frame) + 1),
                                           (CGRectGetMaxY(cell.priceWonLabel.frame)-cell.priceLabel.frame.size.height)+2.f,
                                           cell.priceLabel.frame.size.width,
                                           cell.priceLabel.frame.size.height);
        
        
        if ((([self.optionDictionary[@"status"][@"code"] integerValue] == 785 && indexPath.row == 0)
             || ([self.optionDictionary[@"status"][@"code"] integerValue] == 200 && isOnlyInputOption))
            && ![self.selectedOptionArray[indexPath.row][@"optionType"] boolValue]) {
            [cell.priceWonLabel setHidden:YES];
            [cell.priceLabel setHidden:YES];
            [cell.deleteButton setHidden:YES];
            [cell.deleteButton removeTarget:self action:@selector(onClickDeleteOption:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cell.priceLabel setHidden:NO];
            [cell.priceWonLabel setHidden:NO];
            [cell.deleteButton setHidden:NO];
            [cell.deleteButton setTag:indexPath.row];
            [cell.deleteButton addTarget:self action:@selector(onClickDeleteOption:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell.minusButton setTag:indexPath.row];
        [cell.minusButton addTarget:self action:@selector(onClickMinusOptionCount:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.plusButton setTag:indexPath.row];
        [cell.plusButton addTarget:self action:@selector(onClickPlusOptionCount:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)heightOptionTableViewFooterView
{
    CGFloat footerHeight = 5.f;
    
    if (self.deliveryInfoDictionary)
    {
        NSArray *displayArr = (self.deliveryInfoDictionary[@"display"] ? self.deliveryInfoDictionary[@"display"] : nil);
        if (displayArr && [displayArr count] > 0) footerHeight = (23.f * [displayArr count]) + 10.f;
    }
    
    if (self.periodInfo)
    {
        //높이를 지정하기 전에 배송정보가 없으면 0부터 셋팅한다.
        if (footerHeight == 5.0) footerHeight = 0.0f;
        if (self.periodInfo && [self.periodInfo count] > 0) footerHeight += (23.f * [self.periodInfo count]) + 10.f;
    }
    
    return footerHeight;
}

- (void)setOptionTableViewFooterView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                            self.optionTableView.frame.size.width,
                                                            [self heightOptionTableViewFooterView])];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    CGFloat periodOriginY = 5.f, sizeHeight = 20.f;
    
    if (self.deliveryInfoDictionary)
    {
        NSString *deliveryTitle = [self.deliveryInfoDictionary[@"label"] trim];
        
        UIImage *iconDelibery = [UIImage imageNamed:@"optionbar_icon_truck.png"];
        UIImage *iconNotice = [UIImage imageNamed:@"optionbar_btn_tooltip.png"];
        
        NSArray *displayArr = self.deliveryInfoDictionary[@"display"];
        NSArray *layerArr = self.deliveryInfoDictionary[@"layer"];
        BOOL isItalic = NO;
        
        CGFloat originY = 5.f;
        
        for (NSInteger nIndex = 0; nIndex < [displayArr count]; nIndex++)
        {
            NSString *deliveryText = @"";
            UIImageView *imageView = [[UIImageView alloc] initWithImage:iconDelibery];
            UIButton *noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            
            BOOL isNotice = NO;
            NSInteger deliveryNo = [displayArr[nIndex][@"layer"] intValue];
            
            for (NSInteger mIndex = 0; mIndex < [layerArr count]; mIndex++)
            {
                NSInteger layerNo = [layerArr[mIndex][@"no"] intValue];
                
                if (layerNo == deliveryNo)
                {
                    isNotice = YES;
                    break;
                }
            }
            
            [imageView setBackgroundColor:[UIColor clearColor]];
            [imageView setFrame:CGRectMake(0, originY+2.f, iconDelibery.size.width, iconDelibery.size.height)];
            
            deliveryText = [displayArr[nIndex][@"text"] trim];
            
            if ([deliveryText indexOf:@"꼭 확인하세요"] != -1)	isItalic = YES;
            else											isItalic = NO;
            
            if ([deliveryTitle length] > 0)
            {
                CGFloat sizeWidth = [deliveryTitle sizeWithFont:FONTSIZE(12)].width;
                
                [leftLabel setText:deliveryTitle];
                [leftLabel setFont:FONTSIZE(12)];
                [leftLabel setBackgroundColor:[UIColor clearColor]];
                [leftLabel setTextColor:UIColorFromRGB(0xffffff)];
                [leftLabel setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 4.f, originY+1.f, sizeWidth, sizeHeight)];
            }
            else
            {
                [leftLabel setFrame:CGRectZero];
            }
            
            if ([deliveryText length] > 0)
            {
                CGFloat posX = 0.f;
                UIFont *font = (isItalic ? BOLDFONTSIZE(13) : FONTSIZE(12));
                CGFloat sizeWidth = [deliveryText sizeWithFont:font].width;
                
                if (leftLabel.frame.size.width > 0.f)
                {
                    posX = leftLabel.frame.origin.x + leftLabel.frame.size.width + 5.f;
                }
                else
                {
                    posX = imageView.frame.origin.x + imageView.frame.size.width + 5.f;
                }
                
                [rightLabel setText:deliveryText];
                [rightLabel setFont:font];
                [rightLabel setBackgroundColor:[UIColor clearColor]];
                [rightLabel setTextColor:(isItalic ? UIColorFromRGB(0xe1291e) : UIColorFromRGB(0xffffff))];
                [rightLabel setFrame:CGRectMake(posX, originY+1.f, sizeWidth, sizeHeight)];
                [view addSubview:rightLabel];
                
                if (rightLabel.frame.origin.x + rightLabel.frame.size.width > view.frame.size.width - (isNotice ? iconNotice.size.width + 5.f : 0.f))
                {
                    CGRect frame = rightLabel.frame;
                    if (isNotice)	frame.size.width = view.frame.size.width - rightLabel.frame.origin.x - iconNotice.size.width - 5.f;
                    else			frame.size.width = view.frame.size.width - rightLabel.frame.origin.x - 5.f;
                    
                    [rightLabel setFrame:frame];
                }
            }
            else
            {
                [rightLabel setFrame:CGRectZero];
            }
            
            if (isNotice)
            {
                CGFloat posX = 0.f;
                
                if (rightLabel.frame.size.width > 0.f)
                {
                    posX = rightLabel.frame.origin.x + rightLabel.frame.size.width + 4.f;
                }
                else
                {
                    if (leftLabel.frame.size.width > 0.f)
                    {
                        posX = leftLabel.frame.origin.x + leftLabel.frame.size.width + 4.f;
                    }
                    else
                    {
                        posX = imageView.frame.origin.x + imageView.frame.size.width + 4.f;
                    }
                }
                
                [noticeBtn setTag:tagNoticeBtnVal + deliveryNo];
                [noticeBtn setImage:iconNotice forState:UIControlStateNormal];
                [noticeBtn setFrame:CGRectMake(posX, originY+3.f, iconNotice.size.width, iconNotice.size.height)];
                [noticeBtn setAccessibilityLabel:@"툴팁" Hint:nil];
                
                if ([self respondsToSelector:@selector(onClickDeliveryNotice:)])
                {
                    [noticeBtn addTarget:self action:@selector(onClickDeliveryNotice:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else
            {
                [noticeBtn setHidden:YES];
            }
            
            if (leftLabel.frame.size.height > rightLabel.frame.size.height)
            {
                originY = leftLabel.frame.origin.y + leftLabel.frame.size.height + 3.f;
            }
            else
            {
                originY = rightLabel.frame.origin.y + rightLabel.frame.size.height + 3.f;
            }
            
            [view addSubview:imageView];
            [view addSubview:leftLabel];
            [view addSubview:rightLabel];
            [view addSubview:noticeBtn];
            
            periodOriginY = originY;
        }
    }
    
    if (self.periodInfo)
    {
        for (NSInteger i=0; i<[self.periodInfo count]; i++)
        {
            NSString *leftText	= [[self.periodInfo objectAtIndex:i] objectForKey:@"label"];
            NSString *rightText = [[self.periodInfo objectAtIndex:i] objectForKey:@"text"];
            NSString *iconType	= [[self.periodInfo objectAtIndex:i] objectForKey:@"iconType"];
            
            UIImage *iconImage = nil;
            if ([[iconType trim] isEqualToString:@"01"])	iconImage = [UIImage imageNamed:@"optionbar_icon_calendar.png"];
            else											iconImage = [UIImage imageNamed:@"optionbar_icon_clock.png"];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:iconImage];
            UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            
            [imageView setBackgroundColor:[UIColor clearColor]];
            [imageView setFrame:CGRectMake(0, periodOriginY+2.f, iconImage.size.width, iconImage.size.height)];
            
            if ([leftText length] > 0)
            {
                CGFloat sizeWidth = [leftText sizeWithFont:[UIFont systemFontOfSize:12.f]].width;
                
                [leftLabel setText:leftText];
                [leftLabel setFont:[UIFont systemFontOfSize:12]];
                [leftLabel setBackgroundColor:[UIColor clearColor]];
                [leftLabel setTextColor:UIColorFromRGB(0xffffff)];
                [leftLabel setFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 4.f, periodOriginY + 1.f, sizeWidth, sizeHeight)];
            }
            else
            {
                [leftLabel setFrame:CGRectZero];
            }
            
            if ([rightText length] > 0)
            {
                CGFloat posX = 0.f;
                UIFont *font = [UIFont systemFontOfSize:12];
                CGFloat sizeWidth = [rightText sizeWithFont:font].width;
                
                if (leftLabel.frame.size.width > 0.f)
                {
                    posX = leftLabel.frame.origin.x + leftLabel.frame.size.width + 5.f;
                }
                else
                {
                    posX = imageView.frame.origin.x + imageView.frame.size.width + 5.f;
                }
                
                [rightLabel setText:rightText];
                [rightLabel setFont:font];
                [rightLabel setBackgroundColor:[UIColor clearColor]];
                [rightLabel setTextColor:UIColorFromRGB(0xffffff)];
                [rightLabel setFrame:CGRectMake(posX, periodOriginY + 1.f, sizeWidth, sizeHeight)];
                [view addSubview:rightLabel];
                
                if (rightLabel.frame.origin.x + rightLabel.frame.size.width > view.frame.size.width)
                {
                    CGRect frame = rightLabel.frame;
                    frame.size.width = view.frame.size.width - rightLabel.frame.origin.x - 5.f;
                    [rightLabel setFrame:frame];
                }
            }
            else
            {
                [rightLabel setFrame:CGRectZero];
            }
            
            if (leftLabel.frame.size.height > rightLabel.frame.size.height)
            {
                periodOriginY = leftLabel.frame.origin.y + leftLabel.frame.size.height + 3.f;
            }
            else
            {
                periodOriginY = rightLabel.frame.origin.y + rightLabel.frame.size.height + 3.f;
            }
            
            [view addSubview:imageView];
            [view addSubview:leftLabel];
            [view addSubview:rightLabel];
        }
    }
    
    [self.optionTableView setTableFooterView:view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *optionArray = nil;
    NSString *optionType = nil;
    NSString *compareOptNo = nil;
    NSString *title = nil;
    BOOL isAdditional = NO;
    
    [self keyboardHide];
    
    if (indexPath.section == 0) {
        //입력형 상품일 경우 셀렉트가 안되도록 변경
        if ([@"03" isEqualToString:self.optionArray[indexPath.row][@"optClfCd"]]) {
            return;
        }
        
        if ([self.itemDetailInfo[@"insOptCnt"] intValue] > 0) {
            BOOL notCompleteInput = NO;
            
            for (NSDictionary *input in self.inputOptionArray) {
                if (![input isKindOfClass:[NSDictionary class]] || ([input isKindOfClass:[NSDictionary class]] && [@"" isEqualToString:[input[@"text"] trim]])) {
                    notCompleteInput = YES;
                    
                    break;
                }
            }
            
            if (notCompleteInput) {
                DEFAULT_ALERT(STR_APP_TITLE, @"입력형 옵션이 입력되지 않았습니다.\n입력형 옵션을 입력 후 선택하세요.");
                
                for (UITableViewCell *cell in self.optionTableView.visibleCells) {
                    NSIndexPath *indexPath = [self.optionTableView indexPathForCell:cell];
                    
                    UITextField *inputTextField = (UITextField *)[cell viewWithTag:CELL_TEXTFIELD_TAG+indexPath.row];
                    
                    if (nilCheck(inputTextField.text)) {
                        [inputTextField becomeFirstResponder];
                        break;
                    }
                }
                
                return;
            }
        }
        
        compareOptNo = self.optionArray[indexPath.row][@"compareOptNo"];
//        optionArray = self.optionArray[indexPath.row][@"optItemList"];
        optionArray = self.optionArray;
        optionType = self.optionArray[indexPath.row][@"optClfCd"];
        title = self.optionArray[indexPath.row][@"optItemNm"];
    }
    else if (indexPath.section == 1) {
        isAdditional = YES;
        optionArray = self.additionalOptionArray[indexPath.row][@"prdList"];
        title = self.additionalOptionArray[indexPath.row][@"addPrdGrpNm"];
        compareOptNo = self.additionalOptionArray[indexPath.row][@"compareOptNo"];
    }
    
    if (!optionArray || [optionArray count] == 0) {
        return;
    }
    
    NSString *selectName = @"";
    if (indexPath.section == 0) {
        selectName = @"옵션";
    }
    else if (indexPath.section == 1) {
        selectName = @"추가구성상품";
    }

    itemView = [[OptionItemView alloc] initWithProductOption:optionArray
                                              selectedOption:self.selectedOptionArray
                                              itemDetailInfo:self.itemDetailInfo
                                                       title:title
                                                  selectName:selectName
                                                isAdditional:isAdditional
                                                       frame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))]; //
//    OptionItemView *itemView = [[OptionItemView alloc] initWithProductOption:optionArray
//                                                              selectedOption:self.selectedOptionArray
//                                                                       title:title
//                                                                  selectName:selectName
//                                                                       frame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))]; //self.optionTableView.frame];
    
    [itemView setAlpha:0];
    [itemView setTag:tagItemViewVal];
    [itemView setOptionDelegate:self];
    [itemView setOptionType:optionType];
    [itemView setCompareOptNo:compareOptNo];
    [itemView setSelOptCnt:self.itemDetailInfo[@"selOptCnt"]];
    [itemView setMultiOptionDictionary:self.multiOptionInfoDictionary];
    [itemView setSuperviewFrame:self.superviewFrame];
    [self addSubview:itemView];
    
    currentOptionSection = indexPath.section;
    currentOptionRow = indexPath.row;
    
    [UIView animateWithDuration:0.3f animations:^{
        [itemView setAlpha:1.f];
    } completion:^(BOOL finished) {
    }];
    
    isShowingOptionItem = YES;
}

#pragma mark - UIPanGestureRecognizer

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    //아이템 옵션창이 열려있으면 리턴.
    if (isShowingOptionItem) {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateBegan)
    {
        if ([recognizer state] == UIGestureRecognizerStateBegan)
        {
            if (CGPointEqualToPoint(CGPointZero, originalBottomViewPos))
            {
                originalBottomViewPos = self.bottomView.frame.origin;
            }
            
            self.startViewFrame = self.frame;
            self.startBottomViewFrame = self.bottomView.frame;
        }
        
        
        CGPoint currentPoint = [recognizer translationInView:self];
        CGFloat y = currentPoint.y;
        
        CGFloat scrollingKoef = (self.openMinimumHeight <= 0) ? 1.f : self.bottomView.frame.size.height / (self.openMinimumHeight - self.bottomView.frame.size.height - _drawerBar.frame.size.height);
        
        CGFloat selfFrameY = self.startViewFrame.origin.y+y;
        CGFloat selfFrameH = self.superviewFrame.size.height-selfFrameY;
        
        //네비게이션 영역위로 넘어가지 않음
        if (selfFrameY < 64) {
            return;
        }
//        NSLog(@"y:%f, %f",y, selfFrameY);
        
        [self.bottomView setFrame:CGRectMake(self.startBottomViewFrame.origin.x,
                                             self.startBottomViewFrame.origin.y - (y * scrollingKoef),
                                             self.startBottomViewFrame.size.width,
                                             self.startBottomViewFrame.size.height)];
        [self setFrame:CGRectMake(self.frame.origin.x, selfFrameY, self.frame.size.width, selfFrameH)];
        [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
        [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
        
        if (CGRectGetHeight(self.frame) - (self.drawerBar.frame.size.height - 3.f) <= self.optionBottomView.frame.size.height)
        {
            CGRect optionBottomViewFrame = self.optionBottomView.frame;
            optionBottomViewFrame.origin.y = self.drawerBar.frame.size.height - 3.f;
            self.optionBottomView.frame = optionBottomViewFrame;
            
            [self visibleOptionTableView:NO];
        }
        else
        {
            [self visibleOptionTableView:YES];
        }
        
        if (self.frame.origin.y <= self.openOffset)
        {
            if (CGRectEqualToRect(prevBottomViewFrame, CGRectZero)) prevBottomViewFrame = self.bottomView.frame;
            
            [self.bottomView setFrame:CGRectMake(self.startBottomViewFrame.origin.x, prevBottomViewFrame.origin.y, self.startBottomViewFrame.size.width, self.startBottomViewFrame.size.height)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.openOffset, self.frame.size.width, self.superviewFrame.size.height - self.openOffset)];
            [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
            [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
            
//            //아이템 선택 창 프레임 조절
//            if (isShowingOptionItem)
//            {
//                OptionItemView *optionItemView = (OptionItemView *)[self viewWithTag:tagItemViewVal];
//                if (optionItemView)
//                {
//                    optionItemView.frame = self.optionTableView.frame;
//                    [optionItemView resizeFrame];
//                }
//            }
            return;
        }
        
        prevBottomViewFrame = CGRectZero;
        
        if (self.bottomView.frame.origin.y < originalBottomViewPos.y)
        {
            [self.bottomView setFrame:CGRectMake(self.startBottomViewFrame.origin.x, originalBottomViewPos.y, self.startBottomViewFrame.size.width, self.startBottomViewFrame.size.height)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.bottomView.frame.origin.y - self.drawerBar.frame.size.height, self.frame.size.width, self.bottomView.frame.size.height + self.drawerBar.frame.size.height)];
            
            CGFloat minusOptionBottomViewPos = self.optionBottomView.frame.size.height - self.bottomView.frame.size.height;
            [self.optionBottomView setFrame:CGRectMake(0,
                                                       self.frame.size.height-(_optionBottomView.frame.size.height - minusOptionBottomViewPos),
                                                       self.frame.size.width,
                                                       _optionBottomView.frame.size.height)];
            
            [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
        }
        
//        //아이템 선택 창 프레임 조절
//        if (isShowingOptionItem)
//        {
//            OptionItemView *optionItemView = (OptionItemView *)[self viewWithTag:tagItemViewVal];
//            if (optionItemView)
//            {
//                optionItemView.frame = self.optionTableView.frame;
//                [optionItemView resizeFrame];
//            }
//        }
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled)
    {
        self.startViewFrame = self.frame;
        self.startBottomViewFrame = self.bottomView.frame;
        
        if (self.startViewFrame.size.height > (self.openMinimumHeight / 2) && !_isDrawerOpen)
        {
            //0원 상품일 경우 다운로드로 바꿔준다.
            NSString *prdTypCd = [self.itemDetailInfo objectForKey:@"prdTypCd"];
            if ([@"20" isEqualToString:[prdTypCd trim]]) {
                [self setOptionType:openOptionTypeDownload];
            }
            else if ([@"Y" isEqualToString:self.itemDetailInfo[@"dealPrivatePrdYn"]]) {
                [self setOptionType:openOptionTypeShockingdeal];
            }
            else if ([@"Y" isEqualToString:self.itemDetailInfo[@"bcktExYn"]]) {
                [self setOptionType:openOptionTypeBasket];
            }
            else {
                [self setOptionType:openOptionTypePurchase];
            }
            
            [self validateOpenDrawer:YES];
            return;
        }
        
        if (self.startViewFrame.size.height < self.openMinimumHeight-(self.openMinimumHeight/3.f))
        {
            [self closeDrawer];
            return;
        }
    }
}

#pragma mark-  UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *view = [touch view];
    
    if (view)
    {
        if (view.tag == 99999) return NO;
        if ([view isKindOfClass:[OptionItemView class]]) return NO;
        if (isKeyboardShowing) return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)onTextDidChanged:(NSNotification *)notification
{
    BOOL isContainObject = NO;
    
    UITextField *textField = (UITextField *)[notification object];
    
    if ([@"0" isEqualToString:textField.text] && [textField keyboardType] == UIKeyboardTypeNumberPad) {
        textField.text = @"1";
        DEFAULT_ALERT(STR_APP_TITLE, @"수량은 1이상의 숫자만 입력이 가능합니다.");
    }
    
    if (!([textField keyboardType] == UIKeyboardTypeNumberPad)) { //입력형
        
        NSInteger textFieldTag = textField.tag - CELL_TEXTFIELD_TAG; //입력형 텍스트필드 태그
        
        for (NSInteger i = 0; i < [self.inputOptionArray count]; i++) {
            NSMutableDictionary *input = self.inputOptionArray[i];
            
            if (input && [input isKindOfClass:[NSDictionary class]] && i == textFieldTag) {
                [input setObject:textField.text forKey:@"text"];
                
                [self.inputOptionArray replaceObjectAtIndex:i withObject:input];
                
                isContainObject = YES;
                
                break;
            }
        }
        
        if (!isContainObject) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:textField.text, @"text", self.optionArray[textFieldTag][@"optItemNo"], @"optItemNo", textField.placeholder, @"optItemNm", nil];
            
            [self.inputOptionArray replaceObjectAtIndex:textFieldTag withObject:dic];
        }
    }
    else if ([textField keyboardType] == UIKeyboardTypeNumberPad) {
        NSInteger totalPrice = 0;
        NSInteger totalPriceCount = 0;
        NSMutableDictionary *selectedItem = self.selectedOptionArray[textField.tag];
        
//        OptionItemCell *cell = (OptionItemCell *)[Modules findSuperviewByClass:[OptionItemCell class] view:textField];
        
        [selectedItem setObject:textField.text forKey:@"selectedCount"];
//        NSUInteger itemTotalPrice = [self getSelectedOptionPrice:selectedItem];
        
//        [cell.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:(itemTotalPrice)]]];
//        [cell.priceLabel sizeToFitWithFloor];
//        cell.priceLabel.frame = CGRectMake(cell.priceWonLabel.frame.origin.x-2.f-cell.priceLabel.frame.size.width,
//                                           (CGRectGetMaxY(cell.priceWonLabel.frame)-cell.priceLabel.frame.size.height)+2.f,
//                                           cell.priceLabel.frame.size.width,
//                                           cell.priceLabel.frame.size.height);
        
        
        [self.selectedOptionArray replaceObjectAtIndex:textField.tag withObject:selectedItem];
        [self reloadDataInTableView];
        
        for (NSDictionary *dic in self.selectedOptionArray)
        {
            totalPrice += [dic[@"price"] intValue] * [dic[@"selectedCount"] intValue];
            totalPriceCount += [dic[@"selectedCount"] intValue];
        }
        
        [self.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:totalPrice]]];
        [self.priceCountLabel setText:[NSString stringWithFormat:@"(%ld개)", (long)totalPriceCount]];
        [self resizePriceLabel];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textFieldString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textFieldString isMatchedByRegex:@"[<>///!@=_:]"]) return NO;
    if ([string isEqualToString:@"£"] || [string isEqualToString:@"¥"] || [string isEqualToString:@"•"] || [string isEqualToString:@"₩"]  ||[string isEqualToString:@"€"]) return NO;
    if (([textFieldString intValue] > 999) && [textField keyboardType] == UIKeyboardTypeNumberPad) return NO;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    isKeyboardShowing = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    if ([textField keyboardType] == UIKeyboardTypeNumberPad && ([@"0" isEqualToString:textField.text] || [@"" isEqualToString:[textField.text trim]]))
    {
        NSInteger totalPrice = 0;
        NSInteger totalPriceCount = 0;
        NSMutableDictionary *selectedItem = self.selectedOptionArray[textField.tag];
        
        OptionItemCell *cell = (OptionItemCell *)[Modules findSuperviewByClass:[OptionItemCell class] view:textField];
        
        [textField setText:@"1"];
        
        [selectedItem setObject:textField.text forKey:@"selectedCount"];
        
        NSUInteger itemTotalPrice = [self getSelectedOptionPrice:selectedItem];
        [cell.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:(itemTotalPrice)]]];
        [cell.priceLabel sizeToFitWithFloor];
        cell.priceLabel.frame = CGRectMake(cell.priceWonLabel.frame.origin.x-2.f-cell.priceLabel.frame.size.width,
                                           (CGRectGetMaxY(cell.priceWonLabel.frame)-cell.priceLabel.frame.size.height)+2.f,
                                           cell.priceLabel.frame.size.width,
                                           cell.priceLabel.frame.size.height);
        
        
        [self.selectedOptionArray replaceObjectAtIndex:textField.tag withObject:selectedItem];
        
        for (NSDictionary *dic in self.selectedOptionArray)
        {
            totalPrice += [dic[@"price"] integerValue] * [dic[@"selectedCount"] integerValue];
            totalPriceCount += [dic[@"selectedCount"] integerValue];
        }
        
        [self.priceLabel setText:[NSString stringWithFormat:@"%@", [Modules numberFormatter:totalPrice]]];
        [self.priceCountLabel setText:[NSString stringWithFormat:@"(%ld개)", (long)totalPriceCount]];
        [self resizePriceLabel];
    }
    
    isKeyboardShowing = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    isKeyboardShowing = NO;
    
    return YES;
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSNumber *durationValue = [noti userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = [noti userInfo][UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    beforeRectKeyboardShowSelfView = self.frame;
    beforeRectKeyboardShowOptionTableView = self.optionTableView.frame;
    beforeRectKeyboardShowOptionBottomView = self.optionBottomView.frame;
    
    
    [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _keyboardToolView.frame.size.height, self.frame.size.width, 0)];
    [self.optionBottomView setAlpha:0.f];
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        [self setFrame:CGRectMake(0, self.openOffset, self.frame.size.width, self.superviewFrame.size.height - self.openOffset - keyboardFrame.size.height)];
        [self.keyboardToolView setFrame:CGRectMake(0, self.frame.size.height - _keyboardToolView.frame.size.height, _keyboardToolView.frame.size.width, _keyboardToolView.frame.size.height)];
        [self.optionTableView setFrame:CGRectMake(self.optionTableView.frame.origin.x,
                                                  self.optionTableView.frame.origin.y,
                                                  self.optionTableView.frame.size.width,
                                                  self.frame.size.height-_keyboardToolView.frame.size.height-self.optionTableView.frame.origin.y)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSNumber *durationValue = [noti userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = [noti userInfo][UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    [UIView animateWithDuration:animationDuration delay:0 options:(animationCurve << 16) animations:^{
        if (CGRectEqualToRect(beforeRectKeyboardShowSelfView, CGRectZero))
        {
            [self setFrame:CGRectMake(0, self.superviewFrame.size.height - self.openMinimumHeight, self.frame.size.width, self.openMinimumHeight)];
        }
        else
        {
            [self setFrame:beforeRectKeyboardShowSelfView];
        }
        
        [self.keyboardToolView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, _keyboardToolView.frame.size.width, _keyboardToolView.frame.size.height)];

        [self.optionBottomView setFrame:CGRectMake(0, CGRectGetHeight(self.frame)-optionBottomViewHeight, CGRectGetWidth(self.frame), optionBottomViewHeight)];
//        if (CGRectEqualToRect(beforeRectKeyboardShowOptionBottomView, CGRectZero))
//        {
//            [self.optionBottomView setFrame:CGRectMake(0, self.frame.size.height - _optionBottomView.frame.size.height, self.frame.size.width, _optionBottomView.frame.size.height)];
//        }
//        else
//        {
//            [self.optionBottomView setFrame:beforeRectKeyboardShowOptionBottomView];
//        }
        [self.optionBottomView setAlpha:1.f];
        
        if (CGRectEqualToRect(beforeRectKeyboardShowSelfView, CGRectZero))
        {
            [self.optionTableView setFrame:CGRectMake(0, 29, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-optionTableViewHeight)];
        }
        else
        {
            [self.optionTableView setFrame:beforeRectKeyboardShowOptionTableView];
        }
    } completion:^(BOOL finished) {
        beforeRectKeyboardShowSelfView = CGRectZero;
        beforeRectKeyboardShowOptionTableView = CGRectZero;
        beforeRectKeyboardShowOptionBottomView = CGRectZero;
    }];
}

- (void)keyboardHide
{
    UIWindow *tempWindow;
    
    for (int j = 0; j < [[[UIApplication sharedApplication] windows] count]; j++)
    {
        tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:j];
        
        for (int i = 0; i < [tempWindow.subviews count]; i++)
        {
            [self keyboardHide:[tempWindow.subviews objectAtIndex:i]];
        }
    }
}

- (void)keyboardHide:(UIView *)view
{
    if ([view conformsToProtocol:@protocol(UITextInputTraits)]) [view resignFirstResponder];
    
    if ([view.subviews count] > 0) for (NSInteger i = 0 ; i < [view.subviews count]; i++) [self keyboardHide:[view.subviews objectAtIndex:i]];
}

- (void)sendFreeProductForSMS:(NSString *)url
{
    [self syncLoadOption:url completion:^(NSDictionary *json) {
        if (json)
        {
            if (json[@"status"][@"d_message"])
            {
                NSString *alertMessage = json[@"status"][@"d_message"];
                DEFAULT_ALERT(STR_APP_TITLE, alertMessage);
            }
        }
        
        [self closeDrawer];
        [self stopLoadingAnimation];
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"6")) {
        // 각 세션의 헤더가 스크롤시 고정되있는 현상을 수정하기 위해 위치를 재조정하는 코드 추가
        CGFloat sectionHeaderHeight = self.optionTableView.sectionHeaderHeight;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self insertSubview:loadingView aboveSubview:self];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end