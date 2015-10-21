//
//  CPProductViewController.m
//  11st
//
//  Created by spearhead on 2015. 6. 23..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductViewController.h"
#import "CPProductListViewController.h"
#import "CPWebViewController.h"
#import "CPHomeViewController.h"
#import "CPSearchViewController.h"
#import "CPMartSearchViewController.h"
#import "CPSnapshotListViewController.h"
#import "CPShareViewController.h"
#import "CPCommonLayerPopupView.h"
#import "SetupController.h"
#import "CPPopupViewController.h"
#import "CPDescriptionBottomTitleView.h"
#import "CPDescriptionBottomTownShopBranch.h"

#import "CPProductThumbnailView.h"
#import "CPProductBadgeView.h"
#import "CPProductPriceView.h"
#import "CPProductDiscountView.h"
#import "CPProductBenefitView.h"
#import "CPProductSellPeriodView.h"
#import "CPProductUsePeriodView.h"
#import "CPProductDeliveryView.h"
#import "CPProductPrdPromotionView.h"
#import "CPShockingDealBenefitView.h"
#import "CPProductLikeView.h"
#import "CPProductBannerView.h"
#import "CPProductTabMenuView.h"
#import "CPProductDescriptionView.h"
#import "CPProductInfoUserFeedbackView.h"
#import "CPProductInfoUserQnAView.h"
#import "CPProductExchangeView.h"
#import "OptionDrawer.h"
#import "CPLikePopupView.h"
#import "CPProductInfoSmartOptionView.h"
#import "CPSharePopupView.h"
#import "CPProductWebView.h"
#import "CPBookSeriesView.h"

#import "CPNavigationBarView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"
#import "CPThumbnailView.h"
#import "CPFooterView.h"

#import "ProductSmartOptionContainerModel.h"
#import "ProductSmartOptionModel.h"
#import "CPRESTClient.h"
#import "CPCommonInfo.h"
#import "CPSchemeManager.h"
#import "CPBannerManager.h"
#import "AccessLog.h"
#import "Modules.h"
#import "SBJSON.h"
#import "SBJsonWriter.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+Blocks.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <NetFunnel/NetFunnel.h>

typedef NS_ENUM(NSUInteger, LoadOptionStatus)
{
    LoadOptionStatusNone,
    LoadOptionStatusLoading,
    LoadOptionStatusFinished,
    LoadOptionStatusFailed,
    LoadOptionStatusRetryPurchase,
    LoadOptionStatusRetryGift
};

typedef NS_ENUM(NSUInteger, TabViewType)
{
    TabViewTypePrdInfo = 0,
    TabViewTypeReviewPost,
    TabViewTypeQA,
    TabViewTypeExchange
};

#define kBottomViewHeight   50

@interface CPProductViewController () <CPNavigationBarViewDelegate,
                                    CPErrorViewDelegate,
                                    CPFooterViewDelegate,
                                    CPSearchViewControllerDelegate,
                                    CPMartSearchViewControllerDelegate,
                                    CPBannerManagerDelegate,
                                    UIScrollViewDelegate,
                                    MFMessageComposeViewControllerDelegate,
                                    NetFunnelDelegate,
                                    OptionDrawerDelegate,
                                    CPSharePopupViewDelegate,
                                    CPCommonLayerPopupViewDelegate,
                                    CPLikePopupViewDelegate,
                                    CPBookSeriesViewDelegate,
                                    CPShockingDealBenefitViewDelegate,
                                    CPProductWebViewDelegate,
                                    CPProductThumbnailViewViewDelegate,
                                    CPProductBannerViewDelegate,
                                    CPProductPriceViewViewDelegate,
                                    CPProductInfoSmartOptionViewDelegate,
                                    CPProductLikeViewDelegate,
                                    CPProductBenefitViewDelegate,
                                    CPProductSellPeriodViewDelegate,
                                    CPProductUsePeriodViewDelegate,
                                    CPProductDeliveryViewDelegate,
                                    CPProductPrdPromotionViewDelegate,
                                    CPProductDescriptionViewDelegate,
                                    CPProductInfoUserFeedbackViewDelegate,
                                    CPProductInfoUserQnAViewDelegate,
                                    CPProductExchangeViewDelegate,
                                    CPProductTabMenuViewDelegate,
                                    CPProductDiscountViewDelegate,
                                    CPPopupViewControllerDelegate>
{
    NSString *productNumber;
    NSDictionary *productParameter;
    
    //스크롤뷰
    UIScrollView *mainScrollView;
    UIScrollView *tabScrollView;
    
    //서랍
    UIView *bottomView;
    OptionDrawer *drawerView;
    
    //상품기본이미지
    CPProductThumbnailView *productThumbnailView;
    
    //혜택 아이콘
    CPProductBadgeView *productBadgeView;
    
    //상품가격, 상품명, 쇼킹딜, 만족도
    CPProductPriceView *productPriceView;
    
    //내맘대로할인
    CPProductDiscountView *myDiscountView;
    
    //추가할인가
    CPProductDiscountView *productDiscountView;
    
    //혜택
    CPProductBenefitView *productBenefitView;
    
    //판매기간
    CPProductSellPeriodView *productSellPeriodView;
    
    //사용기간
    CPProductUsePeriodView *productUsePeriodView;
    
    //배송
    CPProductDeliveryView *productDeliveryView;
    //배송지 목록
    UIView *deliveryListView;
    //배송점 목록
    UIView *shopListView;
    
    //덤
    CPProductPrdPromotionView *productPrdPromotionView;
    //덤 목록
    UIView *promotionListView;
    
    //쇼킹딜앱혜택
    CPShockingDealBenefitView *shockingDealBenefitView;
    
    //좋아요/선물하기/공유하기
    CPProductLikeView *productLikeView;
    
    //도서-시리즈
    CPBookSeriesView *bookSeriesView;
    
    //공유하기 팝업
    CPSharePopupView *sharePopupView;
    
    //layer 팝업
    CPCommonLayerPopupView *commonLayerPopupView;
    
    //배너
    CPProductBannerView *productBannerView;
    
    //탭메뉴용 Height
    CGFloat defaultInfoHeight;
    
    //탭메뉴
    CPProductTabMenuView *tabMenuView;
    
    //상품정보
    CPProductDescriptionView *descriptionView;
    CPProductInfoSmartOptionView *productInfoSmartOptionView;
    
    //리뷰/후기
    CPProductInfoUserFeedbackView *productInfoFeedbackView;
    BOOL isMovePost;
    
    //Q&A
    CPProductInfoUserQnAView *productInfoQnAView;
    
    //반품/교환
    CPProductExchangeView *productExchangeView;
    
    //공통 웹뷰
    CPProductWebView *productWebView;
    NSDictionary *currentPopupInfo;
    
    //데이터
    NSDictionary *productInfo;
    NSDictionary *optionInfo;
    ProductSmartOptionContainerModel *smartOptionContainer;
    
    //버튼들
    UIButton *topButton;
    UIButton *originalButton;
    UIButton *reviewButton;
    
    //공통뷰
    CPLoadingView *loadingView;
    CPErrorView *errorView;
    CPNavigationBarView *navigationBarView;
    CPFooterView *footerView;
    UIView *mdnBannerView;
    
    //Qna 쓰기 상태값
    BOOL isQnaWrite;
    
    CGFloat footerHeight;
    
    NSInteger currentItemIndex;
    
    LoadOptionStatus loadOptionStatus;
    
    NSString *tempUrl;
    
    TabViewType currentType;
    
    BOOL isSkipParent;
    
    AfterLoginActionStatus afterLoginAction;
    NSString *afterLoginActionUrl;
    
    //서랍
    UIButton *cartButton;
    UIButton *purchaseButton;
    UIButton *syrupButton;
    UIButton *shockingdealButton;
    UIButton *downloadButton;
    
    NSString *netFunnelUrl;
    CPNetfunnelType netfunnelType;
    
    //Mall Type
    CPMallType mallType;
    
    //마트일 경우  ctlgStockNo 로 넘어오는 옵션을 디폴트로 옵션선택되어 있도록 한다
    NSString *ctlgStockNo;
    
    //서랍버튼 숨김여부
    BOOL isDrawerHidden;
    
    //배송 - 상품수령시 결제(착불) 노출여부
    BOOL isDlvCstPayCheck;
    
    //배송 - 방문수령체크여부
    BOOL isVisitDlvCheck;
    
    NSDictionary *myCouponInfo;
    
    BOOL isViewAlive;
    
    BOOL isApiRequesting;
    
    //코치마크
    UIView *tutorialView;
}

@end

@implementation CPProductViewController

- (id)initWithProductNumber:(NSString *)aProductNumber
{
    if (self = [super init]) {
        productNumber = aProductNumber;
    }
    return self;
}

- (id)initWithProductNumber:(NSString *)aProductNumber isPop:(BOOL)isPop
{
    if (self = [self initWithProductNumber:aProductNumber]) {
        isSkipParent = isPop;
    }
    return self;
}

- (id)initWithProductNumber:(NSString *)aProductNumber isPop:(BOOL)isPop parameters:(NSDictionary *)parameters
{
    if (self = [self initWithProductNumber:aProductNumber]) {
        isSkipParent = isPop;
        
        if (parameters) {
            productParameter = parameters;
            
            ctlgStockNo = parameters[@"ctlgStockNo"];
            
            if ([@"mart" isEqualToString:parameters[@"mallType"]]) {
                mallType = CPMallTypeMart;
            }
            else {
                mallType = CPMallTypeDefault;
            }
        }
    }
    return self;
}

- (id)initWithProductNumber:(NSString *)aProductNumber isPop:(BOOL)isPop mallType:(CPMallType)aMallType
{
    if (self = [self initWithProductNumber:aProductNumber]) {
        isSkipParent = isPop;
        mallType = aMallType;
    }
    return self;
}

- (NSString *)productNumber
{
    return productNumber;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //api에서 판단하지 않음(mallType=Mart로 들어오는 것만 마트GNB)
    if (mallType == CPMallTypeMart) {
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeMartBack]];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeBack]];
    }

    // Init Data
    [self initData];
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-40,
                                                                  (CGRectGetHeight(self.view.frame)-kToolBarHeight)/2-40,
                                                                  80,
                                                                  80)];
    
    // API
    [self getProductData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isQnaWrite)
    {
        isQnaWrite = NO;
    }
    
    if (descriptionView) {
        [descriptionView startAutoScroll];
    }
    
    [self didTouchTabMove:currentItemIndex];
    
    if (productDeliveryView && [Modules checkLoginFromCookie]) {
        //배송 리프래시
        [productDeliveryView reloadView:tempUrl];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //하단 서랍 (네비게이션뷰에 붙이는 것으로 변경. 원본보기등의 팝업뷰에서도 같은 서랍뷰를 사용한다)
    if ([bottomView isHidden]) {
        [self setHiddenBottomView:NO];
    }
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //api에서 판단하지 않음(mallType=Mart로 들어오는 것만 마트GNB)
    if (mallType == CPMallTypeMart) {
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeMartBack]];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
        [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeBack]];
    }

    //네비게이션바가 없어진 상태라면 복구시킨다.
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    if (isSkipParent) {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        
        if (viewControllers.count >= 2) {
            [viewControllers removeObjectAtIndex:viewControllers.count-2];
            self.navigationController.viewControllers = viewControllers;
        }
        
        isSkipParent = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isDrawerHidden = YES;
    [self setHiddenBottomView:YES];

    if (productWebView) {
        [productWebView removeFromSuperview];
        productWebView = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[CPBannerManager sharedManager] removeBannerView];
    [descriptionView stopAutoScroll];

    if (self.isMovingFromParentViewController) {
        
        isViewAlive = NO;
        
        if (productThumbnailView)           [productThumbnailView removeFromSuperview], [productThumbnailView releaseItem], productThumbnailView = nil;
        if (productBadgeView)               [productBadgeView removeFromSuperview], [productBadgeView releaseItem], productBadgeView = nil;
        if (productPriceView)               [productPriceView stopCountDown], [productPriceView removeFromSuperview], [productPriceView releaseItem], productPriceView = nil;
        if (myDiscountView)                 [myDiscountView removeFromSuperview], [myDiscountView releaseItem], myDiscountView = nil;
        if (productDiscountView)            [productDiscountView removeFromSuperview], [productDiscountView releaseItem], productDiscountView = nil;
        if (productBenefitView)             [productBenefitView removeFromSuperview], [productBenefitView releaseItem], productBenefitView = nil;
        if (productSellPeriodView)          [productSellPeriodView removeFromSuperview], [productSellPeriodView releaseItem], productSellPeriodView = nil;
        if (productUsePeriodView)           [productUsePeriodView removeFromSuperview], [productUsePeriodView releaseItem], productUsePeriodView = nil;
        if (productDeliveryView)            [productDeliveryView removeFromSuperview], [productDeliveryView releaseItem], productDeliveryView = nil;
        if (deliveryListView)               [deliveryListView removeFromSuperview], deliveryListView = nil;
        if (productPrdPromotionView)        [productPrdPromotionView removeFromSuperview], [productPrdPromotionView releaseItem], productPrdPromotionView = nil;
        if (promotionListView)              [promotionListView removeFromSuperview], promotionListView = nil;
        if (shockingDealBenefitView)        [shockingDealBenefitView removeFromSuperview], [shockingDealBenefitView releaseItem], shockingDealBenefitView = nil;
        if (productLikeView)                [productLikeView removeFromSuperview], [productLikeView releaseItem], productLikeView = nil;
        if (bookSeriesView)                 [bookSeriesView removeFromSuperview], [bookSeriesView releaseItem], bookSeriesView = nil;
        if (sharePopupView)                 [sharePopupView removeFromSuperview], [sharePopupView releaseItem], sharePopupView = nil;
        if (commonLayerPopupView)           [commonLayerPopupView removeFromSuperview], [commonLayerPopupView releaseItem], commonLayerPopupView = nil;
        if (productBannerView)              [productBannerView removeFromSuperview], [productBannerView releaseItem], productBannerView = nil;
        if (tabMenuView)                    [tabMenuView removeFromSuperview], [tabMenuView releaseItem], tabMenuView = nil;
        if (productInfoSmartOptionView)     [productInfoSmartOptionView removeFromSuperview], [productInfoSmartOptionView releaseItem], productInfoSmartOptionView = nil;
        if (productInfoFeedbackView)        [productInfoFeedbackView removeFromSuperview], [productInfoFeedbackView releaseItem], productInfoFeedbackView = nil;
        if (productInfoQnAView)             [productInfoQnAView removeFromSuperview], [productInfoQnAView releaseItem], productInfoQnAView = nil;
        if (productExchangeView)            [productExchangeView removeFromSuperview], [productExchangeView releaseItem], productExchangeView = nil;
        if (topButton)                      [topButton removeFromSuperview], topButton = nil;
        if (originalButton)                 [originalButton removeFromSuperview], originalButton = nil;
        if (reviewButton)                   [reviewButton removeFromSuperview], reviewButton = nil;
        if (loadingView)                    [loadingView stopAnimation], [loadingView removeFromSuperview], loadingView = nil;
        if (errorView)                      [errorView removeFromSuperview], errorView = nil;
        if (navigationBarView)              [navigationBarView removeFromSuperview], navigationBarView = nil;
        if (footerView)                     [footerView removeFromSuperview], footerView = nil;
        if (mdnBannerView)                  [mdnBannerView removeFromSuperview], mdnBannerView = nil;
        if (cartButton)                     [cartButton removeFromSuperview], cartButton = nil;
        if (purchaseButton)                 [purchaseButton removeFromSuperview], purchaseButton = nil;
        if (syrupButton)                    [syrupButton removeFromSuperview], syrupButton = nil;
        if (shockingdealButton)             [shockingdealButton removeFromSuperview], shockingdealButton = nil;
        if (downloadButton)                 [downloadButton removeFromSuperview], downloadButton = nil;
        
        if (descriptionView) {
            [descriptionView cancelImageDownloading];
            [descriptionView removeMemory];
            
            [descriptionView removeFromSuperview];
            descriptionView = nil;
        }
        
        if (drawerView)         [drawerView removeFromSuperview], drawerView = nil;
        if (bottomView)         [bottomView removeFromSuperview], bottomView = nil;
        if (tabScrollView)      [tabScrollView removeFromSuperview], tabScrollView = nil;
        if (mainScrollView)     [mainScrollView removeFromSuperview], mainScrollView = nil;
    }
}

-  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SettingControllerDidLoginNotification object:nil];
    
    [self removeBottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData
{    
    currentType = TabViewTypePrdInfo;
    currentItemIndex = 0;
    isMovePost= NO;
    isDlvCstPayCheck = NO;
    isVisitDlvCheck = NO;
    isViewAlive = YES;
}

- (void)initLayout
{
    [mainScrollView removeFromSuperview];
    
    //메인 스크롤뷰
    mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [mainScrollView setBackgroundColor:[UIColor clearColor]];
    [mainScrollView setBounces:NO];
    [mainScrollView setDelegate:self];
    [self.view addSubview:mainScrollView];
    
//    //하단 서랍
//    [self initBottomView];
    
    //상품 썸네일
    // http//i.011st.com/ex_t/R/300x300/1/80/0/0/src/ak/8/3/2/1/3/2/183832132_B_V18.gif
    productThumbnailView = [[CPProductThumbnailView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainScrollView.frame), 0) product:productInfo];
    [productThumbnailView setDelegate:self];
    [mainScrollView addSubview:productThumbnailView];
    
    //상품 혜택 아이콘 - prdBenfitIcon
    if ([productInfo[@"prdBenfitIcon"] isKindOfClass:[NSArray class]] && [productInfo[@"prdBenfitIcon"] count] > 0) {
        productBadgeView = [[CPProductBadgeView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(productThumbnailView.frame)+8, CGRectGetWidth(mainScrollView.frame)-20, 20)];
        productBadgeView.badgeType = ProductBadgeTypeRectangle;
        productBadgeView.isProductDetail = YES;
        productBadgeView.badges = productInfo[@"prdBenfitIcon"];
        [mainScrollView addSubview:productBadgeView];
    }
    else {
        productBadgeView = [[CPProductBadgeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productThumbnailView.frame)+8, 0, 0)];
    }
    
    //상품명 & 가격정보 & 만족도, 리뷰 영역 - prdNm & prdPrice
    productPriceView = [[CPProductPriceView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(productBadgeView.frame)+6, kScreenBoundsWidth-20, 0)
                                                         product:productInfo];
    [productPriceView setDelegate:self];
    [mainScrollView addSubview:productPriceView];

    //내맘대로할인 - bnfAddDiscount
    myDiscountView = [[CPProductDiscountView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productPriceView.frame), kScreenBoundsWidth, 0)
                                                          product:productInfo
                                                         viewType:CPProductViewTypeMyDiscount];
    [myDiscountView setDelegate:self];
    [mainScrollView addSubview:myDiscountView];
    
    //추가할인가 - bnfAddDiscount
    productDiscountView = [[CPProductDiscountView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myDiscountView.frame), kScreenBoundsWidth, 0)
                                                               product:productInfo
                                                              viewType:CPProductViewTypeAddDisount];
    [productDiscountView setDelegate:self];
    [mainScrollView addSubview:productDiscountView];
    
    //혜택 - bnfBenefit
    productBenefitView = [[CPProductBenefitView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, 0)
                                                             product:productInfo];
    [productBenefitView setDelegate:self];
    [mainScrollView addSubview:productBenefitView];
    
    //판매기간 - prdSalPeriod
    productSellPeriodView = [[CPProductSellPeriodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, 0)
                                                               product:productInfo];
    [productSellPeriodView setDelegate:self];
    [mainScrollView addSubview:productSellPeriodView];
    
    //사용기간 - prdUsePeriod
    productUsePeriodView = [[CPProductUsePeriodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, 0)
                                                                   product:productInfo];
    [productUsePeriodView setDelegate:self];
    [mainScrollView addSubview:productUsePeriodView];
    
    //배송 - prdDelivery
    productDeliveryView = [[CPProductDeliveryView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, 0)
                                                               product:productInfo productNumber:productNumber dlvCstPayChecked:isDlvCstPayCheck visitDlvChecked:isVisitDlvCheck];
    [productDeliveryView setDelegate:self];
    [mainScrollView addSubview:productDeliveryView];
    
    //덤 - prdPromotion
    productPrdPromotionView = [[CPProductPrdPromotionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, 0)
                                                                   product:productInfo];
    [productPrdPromotionView setDelegate:self];
    [mainScrollView addSubview:productPrdPromotionView];
    
    //쇼킹딜앱 혜택 - bnfDealApp
    shockingDealBenefitView = [[CPShockingDealBenefitView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productPrdPromotionView.frame), kScreenBoundsWidth, 0)
                                                                       product:productInfo];
    [shockingDealBenefitView setDelegate:self];
    [mainScrollView addSubview:shockingDealBenefitView];
    
    //좋아요/선물하기/공유 - prdLike
    productLikeView = [[CPProductLikeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shockingDealBenefitView.frame), kScreenBoundsWidth, 60)
                                                       product:productInfo];
    [productLikeView setDelegate:self];
    [mainScrollView addSubview:productLikeView];
    
    //도서-시리즈상품 상세보기
    bookSeriesView = [[CPBookSeriesView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productLikeView.frame), kScreenBoundsWidth, 0) product:productInfo];
    [bookSeriesView setDelegate:self];
    [mainScrollView addSubview:bookSeriesView];
    
    //라인배너 - lineBanner
    productBannerView = [[CPProductBannerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bookSeriesView.frame), kScreenBoundsWidth, 0)
                                                           product:productInfo];
    [productBannerView setDelegate:self];
    [mainScrollView addSubview:productBannerView];
    
    //탭 메뉴 Height
    defaultInfoHeight = CGRectGetMaxY(productBannerView.frame);
    
    //탭 메뉴
    tabMenuView = [[CPProductTabMenuView alloc] initWithFrame:CGRectMake(0, defaultInfoHeight, CGRectGetWidth(mainScrollView.frame), 49)
                                                      product:productInfo];
    [tabMenuView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
    [tabMenuView setDelegate:self];
    [mainScrollView addSubview:tabMenuView];
    
    BOOL optDrawerYn = [@"Y" isEqualToString:productInfo[@"optDrawerYn"]];
    
    //탭 메뉴 스크롤뷰
    tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame), CGRectGetWidth(mainScrollView.frame), CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(optDrawerYn?50:0))];
    [tabScrollView setBackgroundColor:[UIColor grayColor]];
    [tabScrollView setBounces:NO];
    [tabScrollView setDelegate:self];
    [mainScrollView addSubview:tabScrollView];
    
    
    [tabScrollView setContentSize:CGSizeMake(CGRectGetWidth(mainScrollView.frame), CGRectGetHeight(tabScrollView.frame))];

    //상품설명 탭 - prdDescImage
//    if ([productInfo[@"prdDescImage"][@"detailViewType"] isEqualToString:@"tagging"]) { //스마트옵션
//        //
//        smartOptionContainer = [[ProductSmartOptionContainerModel alloc] initWithOptionInfo:productInfo[@"prdDescImage"]];
//        if ([smartOptionContainer hasItem]) {
//            productInfoSmartOptionView = [[CPProductInfoSmartOptionView alloc] initWithFrame:tabScrollView.bounds
//                                                                      withProductDetailInfo:productInfo];
//            productInfoSmartOptionView.delegate = self;
//            [tabScrollView addSubview:productInfoSmartOptionView];
//            
//            productInfoSmartOptionView.optionItems = smartOptionContainer.allItems;
//        }
//        else {
//            descriptionView = [[CPProductDescriptionView alloc] initWithFrame:tabScrollView.bounds product:productInfo];
//            [descriptionView setDelegate:self];
//            [tabScrollView addSubview:descriptionView];
//        }
//    }
//    else {
        descriptionView = [[CPProductDescriptionView alloc] initWithFrame:tabScrollView.bounds product:productInfo];
        [descriptionView setDelegate:self];
        [tabScrollView addSubview:descriptionView];
//    }
    
//    //리뷰/후기 탭
//    productInfoFeedbackView = [[CPProductInfoUserFeedbackView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame),
//                                                                                              0,
//                                                                                              CGRectGetWidth(mainScrollView.frame),
//                                                                                              CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))
//                                                                             items:productInfo
//                                                                             prdNo:productNumber];
//    [productInfoFeedbackView setDelegate:self];
//    [tabScrollView addSubview:productInfoFeedbackView];
//    
//    //Q&A 탭
//    productInfoQnAView = [[CPProductInfoUserQnAView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame)*2,
//                                                                                              0,
//                                                                                              CGRectGetWidth(mainScrollView.frame),
//                                                                                              CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))
//                                                                             items:productInfo
//                                                                             prdNo:productNumber];
//    [productInfoQnAView setDelegate:self];
//    [tabScrollView addSubview:productInfoQnAView];
//    
//    
//    //반품/교환 탭
//    productExchangeView = [[CPProductExchangeView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame)*3, 0,
//                                                                               tabScrollView.frame.size.width,
//                                                                               tabScrollView.frame.size.height)];
//    productExchangeView.delegate = self;
//    [tabScrollView addSubview:productExchangeView];
    
    
    //버튼들
    UIImage *imgTopNor = [UIImage imageNamed:@"bt_pd_floating_top_nor.png"];
    UIImage *imgTopPress = [UIImage imageNamed:@"bt_pd_floating_top_press.png"];
    topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [topButton setImage:imgTopNor forState:UIControlStateNormal];
    [topButton setImage:imgTopPress forState:UIControlStateHighlighted];
    [topButton setFrame:CGRectMake(tabScrollView.frame.size.width-imgTopNor.size.width-5.f,
                                         CGRectGetHeight(tabScrollView.frame)-imgTopNor.size.height-5.f,
                                         imgTopNor.size.width, imgTopNor.size.height)];
    [topButton addTarget:self action:@selector(onClickedTopButton:) forControlEvents:UIControlEventTouchUpInside];
    [tabScrollView addSubview:topButton];
    
    UIImage *imgReviewNor = [UIImage imageNamed:@"bt_pd_floating_review_nor.png"];
    UIImage *imgReviewPress = [UIImage imageNamed:@"bt_pd_floating_review_press.png"];
    reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reviewButton setImage:imgReviewNor forState:UIControlStateNormal];
    [reviewButton setImage:imgReviewPress forState:UIControlStateHighlighted];
    [reviewButton setFrame:CGRectMake(tabScrollView.frame.size.width-imgReviewNor.size.width-5.f,
                                       topButton.frame.origin.y-imgReviewNor.size.height-5.f,
                                       imgReviewNor.size.width, imgReviewNor.size.height)];
    [reviewButton addTarget:self action:@selector(onClickedShowReviewButton:) forControlEvents:UIControlEventTouchUpInside];
    [tabScrollView addSubview:reviewButton];
    
    if (![productInfo[@"prdDescImage"][@"detailViewType"] isEqualToString:@"tagging"]) { //스마트옵션
        UIImage *imgOriginalNor = [UIImage imageNamed:@"bt_pd_floating_pc_nor.png"];
        UIImage *imgOriginalPress = [UIImage imageNamed:@"bt_pd_floating_pc_press.png"];
        originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [originalButton setImage:imgOriginalNor forState:UIControlStateNormal];
        [originalButton setImage:imgOriginalPress forState:UIControlStateHighlighted];
        [originalButton setFrame:CGRectMake(tabScrollView.frame.size.width-imgOriginalNor.size.width-5.f,
                                        reviewButton.frame.origin.y-imgOriginalNor.size.height-5.f,
                                        imgOriginalNor.size.width, imgOriginalNor.size.height)];
        [originalButton addTarget:self action:@selector(onClickedOriginalButton:) forControlEvents:UIControlEventTouchUpInside];
        [tabScrollView addSubview:originalButton];
    }
    
    
    //Footer
    footerView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [footerView setFrame:CGRectMake(0, 0, footerView.width, footerView.height)];
    [footerView setDelegate:self];
    [footerView setParentViewController:self];
    
    
    [mainScrollView setContentSize:CGSizeMake(kScreenBoundsWidth, 5000)];
    
    //상품 옵션 정보를 로드한다.
    loadOptionStatus = LoadOptionStatusLoading;
    [self getProductOption];
    
    //스크롤뷰 설정
    [self setMainScrollViewEnable:YES];
    
    //최근 본 상품 등록
    [self setTodayProduct];
}

- (void)initBottomView
{
    CGFloat statusBarHeight = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        statusBarHeight = 20;
    }
    
    //장바구니 / 구매하기 / 선물하기 버튼들
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-(kBottomViewHeight+statusBarHeight), kScreenBoundsWidth, kBottomViewHeight)];
    [bottomView setBackgroundColor:UIColorFromRGB(0xeaeaea)];
//    [self.view addSubview:bottomView];
    //네비게이션뷰에 붙이는 것으로 변경. 원본보기등의 팝업뷰에서도 같은 서랍뷰를 사용한다
    [self.navigationController.view addSubview:bottomView];
    
    //장바구니
    UIImage *basketImageNoraml = [UIImage imageNamed:@"bt_optionbar_cart_nor.png"];
    UIImage *basketImageHighlighted = [UIImage imageNamed:@"bt_optionbar_cart_press.png"];
    
    basketImageNoraml = [basketImageNoraml resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    basketImageHighlighted = [basketImageHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setBackgroundImage:basketImageNoraml forState:UIControlStateNormal];
    [cartButton setBackgroundImage:basketImageHighlighted forState:UIControlStateHighlighted];
    [cartButton setTitle:@"장바구니" forState:UIControlStateNormal];
    [cartButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [cartButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cartButton addTarget:self action:@selector(touchCartButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cartButton];
    
    //구매하기
    UIImage *purchaseImageNoraml = [UIImage imageNamed:@"bt_optionbar_buy_nor.png"];
    UIImage *purchaseImageHighlighted = [UIImage imageNamed:@"bt_optionbar_buy_press.png"];
    
    purchaseImageNoraml = [purchaseImageNoraml resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    purchaseImageHighlighted = [purchaseImageHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [purchaseButton setBackgroundImage:purchaseImageNoraml forState:UIControlStateNormal];
    [purchaseButton setBackgroundImage:purchaseImageHighlighted forState:UIControlStateHighlighted];
    [purchaseButton setTitle:@"구매하기" forState:UIControlStateNormal];
    [purchaseButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [purchaseButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [purchaseButton addTarget:self action:@selector(touchPurchaseButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:purchaseButton];
    
    //시럽
    UIImage *syrupImageNormal = [UIImage imageNamed:@"bt_syrup_pay.png"];
    UIImage *syrupImageHighlighted = [UIImage imageNamed:@"bt_syrup_pay_press.png"];
    
    syrupImageNormal = [syrupImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    syrupImageHighlighted = [syrupImageHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    syrupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [syrupButton setBackgroundImage:syrupImageNormal forState:UIControlStateNormal];
    [syrupButton setBackgroundImage:syrupImageHighlighted forState:UIControlStateHighlighted];
    [syrupButton setImage:[UIImage imageNamed:@"ic_syrup_pay.png"] forState:UIControlStateNormal];
    [syrupButton addTarget:self action:@selector(touchSyrupButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:syrupButton];
    
    //쇼킹딜앱 전용상품(쇼킹딜앱 실행)
    shockingdealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shockingdealButton setBackgroundImage:purchaseImageNoraml forState:UIControlStateNormal];
    [shockingdealButton setBackgroundImage:purchaseImageHighlighted forState:UIControlStateHighlighted];
    [shockingdealButton setTitle:@"쇼킹딜앱 전용상품(쇼킹딜앱 실행)" forState:UIControlStateNormal];
    [shockingdealButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [shockingdealButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [shockingdealButton addTarget:self action:@selector(touchShockingdealButton) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:shockingdealButton];
    
    //다운로드
    downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadButton setBackgroundImage:purchaseImageNoraml forState:UIControlStateNormal];
    [downloadButton setBackgroundImage:purchaseImageHighlighted forState:UIControlStateHighlighted];
    [downloadButton setTitle:@"다운로드" forState:UIControlStateNormal];
    [downloadButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [downloadButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [downloadButton addTarget:self action:@selector(touchPurchaseButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:downloadButton];
    
    //옵션창
    drawerView = [[OptionDrawer alloc] initWithFrame:CGRectMake(0,
                                                                bottomView.frame.origin.y-([OptionDrawer ArrowButtonHeight]+1),
                                                                self.view.frame.size.width,
                                                                bottomView.frame.size.height+[OptionDrawer ArrowButtonHeight])];
    [drawerView setBottomView:bottomView];
//    [drawerView setSuperviewFrame:self.view.frame];
    [drawerView setSuperviewFrame:self.navigationController.view.frame];
    [drawerView setOpenOffset:0.f];
    [drawerView setBackgroundColor:[UIColor clearColor]];
    [drawerView setOpenMinimumHeight:self.view.frame.size.height-(self.view.frame.size.height/3)];
//    [self.view addSubview:drawerView];
//    [self.view bringSubviewToFront:bottomView];
    
    [drawerView setTag:1999998];
    [bottomView setTag:1999997];
    
    [self.navigationController.view addSubview:drawerView];
    [self.navigationController.view bringSubviewToFront:bottomView];
    [drawerView setHidden:NO];
    
    [productDeliveryView checkDlvCstPayYn];
}

- (void)setDrawerOptionButtonLayout
{
    //타입에 따라 버튼 분기
    NSString *prdTypCd = productInfo[@"prdTypCd"]; //상품 타입 (20일경우 다운로드)
    NSString *bcktExYn = productInfo[@"bcktExYn"]; //장비구니 제한 여부
    NSString *dealPrivatePrdYn = productInfo[@"dealPrivatePrdYn"]; //쇼킹딜전용상품 여부
    NSString *syrupPayYn = productInfo[@"syrupPayYn"]; //시럽페이 여부
    
    //    dealPrivatePrdYn = @"Y";
    //    syrupPayYn = @"Y";
    
    if ([@"20" isEqualToString:prdTypCd]) { //다운로드 버튼
        if ([@"Y" isEqualToString:syrupPayYn]) {
            CGFloat buttonWidth = (CGRectGetWidth(bottomView.frame)-15) / 3;
            
            [downloadButton setFrame:CGRectMake(5, 5, buttonWidth*2, 40)];
            [syrupButton setFrame:CGRectMake(CGRectGetMaxX(downloadButton.frame)+5, 5, buttonWidth, 40)];
            [syrupButton setHidden:NO];
        }
        else {
            [downloadButton setFrame:CGRectMake(5, 5, CGRectGetWidth(bottomView.frame)-10, 40)];
            [syrupButton setHidden:YES];
        }
        
        [cartButton setHidden:YES];
        [purchaseButton setHidden:YES];
        [shockingdealButton setHidden:YES];
    }
    else if ([@"Y" isEqualToString:dealPrivatePrdYn]) { //쇼킹딜 전용상품
        [shockingdealButton setFrame:CGRectMake(5, 5, CGRectGetWidth(bottomView.frame)-10, 40)];
        
        [cartButton setHidden:YES];
        [purchaseButton setHidden:YES];
        [downloadButton setHidden:YES];
        [syrupButton setHidden:YES];
    }
    else if ([@"Y" isEqualToString:bcktExYn]) { //장비구니 제한
//        if ([@"Y" isEqualToString:syrupPayYn]) {
//            CGFloat buttonWidth = (CGRectGetWidth(bottomView.frame)-15) / 3;
//            
//            [purchaseButton setFrame:CGRectMake(5, 5, buttonWidth*2, 40)];
//            [syrupButton setFrame:CGRectMake(CGRectGetMaxX(purchaseButton.frame)+5, 5, buttonWidth, 40)];
//            [syrupButton setHidden:NO];
//        }
//        else {
            [purchaseButton setFrame:CGRectMake(5, 5, CGRectGetWidth(bottomView.frame)-10, 40)];
            [syrupButton setHidden:YES];
//        }
        
        [cartButton setHidden:YES];
        [downloadButton setHidden:YES];
        [shockingdealButton setHidden:YES];
    }
    else {
//        if ([@"Y" isEqualToString:syrupPayYn]) {
//            CGFloat buttonWidth = (CGRectGetWidth(bottomView.frame)-20) / 3;
//            
//            [cartButton setFrame:CGRectMake(5, 5, buttonWidth, 40)];
//            [purchaseButton setFrame:CGRectMake(CGRectGetMaxX(cartButton.frame)+5, 5, buttonWidth, 40)];
//            [syrupButton setFrame:CGRectMake(CGRectGetMaxX(purchaseButton.frame)+5, 5, buttonWidth, 40)];
//            [syrupButton setHidden:NO];
//        }
//        else {
            CGFloat buttonWidth = (CGRectGetWidth(bottomView.frame)-15) / 2;
            [cartButton setFrame:CGRectMake(5, 5, buttonWidth, 40)];
            [purchaseButton setFrame:CGRectMake(CGRectGetMaxX(cartButton.frame)+5, 5, buttonWidth, 40)];
            [syrupButton setHidden:YES];
//        }
        
        [downloadButton setHidden:YES];
        [shockingdealButton setHidden:YES];
    }
}

- (void)removeBottomView
{
    if (bottomView) [bottomView removeFromSuperview], bottomView = nil;
    if (drawerView) [drawerView removeFromSuperview], drawerView = nil;
}

- (void)setHiddenBottomView:(BOOL)isHidden
{
    [bottomView setHidden:isHidden];
    [drawerView setHidden:isHidden];
}

- (UIView *)navigationBarView:(CPNavigationType)navigationType
{
    if (navigationBarView) {
        [navigationBarView removeFromSuperview];
    }
    
    navigationBarView = [[CPNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44) type:navigationType];
    [navigationBarView setDelegate:self];
    
    //    // 개발자모드 진입점
    //    [self initDeveloperInfo:logoButton];
    //    //    }
    
    return navigationBarView;
}

- (void)removeDeliveryListView
{
    if (deliveryListView) {
        [deliveryListView removeFromSuperview];
        deliveryListView = nil;
    }
}

- (void)removeShopListView
{
    if (shopListView) {
        [shopListView removeFromSuperview];
        shopListView = nil;
    }
}

- (void)removePromotionListView
{
    if (promotionListView) {
        [promotionListView removeFromSuperview];
        promotionListView = nil;
    }
}

#pragma mark - API

- (void)getProductData
{
    [self startLoadingAnimation];
    
    isApiRequesting = YES;
    
    void (^productSuccess)(NSDictionary *);
    productSuccess = ^(NSDictionary *productData) {
        
        if (productData && [productData count] > 0) {
            
            if ([[productData[@"status"][@"code"] stringValue] isEqualToString:@"200"]) {
                productInfo = [productData[@"appDetail"] copy];
                
                //api에서 판단하지 않음(mallType=Mart로 들어오는 것만 마트GNB)
//                //마트 GNB
//                if ([@"Y" isEqualToString:productInfo[@"martPrdYn"]]) {
//                    [self.navigationItem setHidesBackButton:YES];
//                    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeMartBack]];
//                }
                
                [self initLayout];
                
                //외부 로그 호출
                [self externalCallUrl];
                
                //쿠폰적용가 조회
                if ([Modules checkLoginFromCookie]) {
                    [self getMyCouponInfo];
                }
                
                //Live data type - 상품상세 조회시 : htmlGenYn = Y 일 때 해당 URL 호출하여 정보를 변경시켜준다.
                if ([productInfo[@"htmlGenYn"] isEqualToString:@"Y"]) {
                    [self getLiveData];
                }
                
                //서랍옵션 노출
                NSLog(@"optDrawerYn:%@", productInfo[@"optDrawerYn"]);
                if ([@"Y" isEqualToString:productInfo[@"optDrawerYn"]]) {
                    if (!bottomView) {
                        [self initBottomView];
                        [self setDrawerOptionButtonLayout];
                    }
                }
                else {
                    [self removeBottomView];
                }
                
//                //옵션창에 상품수령시 결제(착불)에 대한 기본값을 전달
//                if (productInfo[@"prdDelivery"] && [productInfo[@"prdDelivery"][@"dlvCstPayYn"] isEqualToString:@"Y"]) {
//                    NSString *dlvCstPayTypCd = productInfo[@"prdDelivery"][@"dlvCstPayTypCd"];
//
//                    if (dlvCstPayTypCd && [dlvCstPayTypCd isEqualToString:@"01"]) {
//
//                        [self didTouchDlvCstPayCheckButton:YES];
//                    }
//                }
                
//                //성인상품 여부 - minorSelCnYn (N이 성인)
//                if ([@"N" isEqualToString:productInfo[@"minorSelCnYn"]]) {
//                    if (![Modules checkAdultFromCookie]) { //성인인증 안됐으면 인증페이지로
//                        //callback url은 상품상세weburl
//                        NSString *goPage = PRODUCT_DETAIL_WEB_URL;
//                        goPage = [goPage stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
//
//                        NSString *url = COMMON_AUTH_URL;
//                        url = [url stringByReplacingOccurrencesOfString:@"{{goPage}}" withString:goPage];
//
//                        [self openWebViewControllerWithUrl:url isPop:YES isIgnore:NO];
//                        return;
//                    }
//                }
            }
            else if ([[productData[@"status"][@"code"] stringValue] isEqualToString:@"201"]) { //웹으로 스위칭
                if ([[productData allKeys] containsObject:@"webLinkUrl"]) {
                    NSString *webLinkUrl = productData[@"webLinkUrl"];
                    if (productData[@"webLinkUrl"]) {
                        [self openWebViewControllerWithUrl:webLinkUrl isPop:YES isIgnore:YES];
                        return;
                    }
                }
            }
            else { //예외처리
                
                //"405" 존재하지 않는 상품
                if ([[productData[@"status"][@"code"] stringValue] isEqualToString:@"405"]) {
                    [UIAlertView showWithTitle:STR_APP_TITLE
                                       message:productData[@"status"][@"d_message"]
                             cancelButtonTitle:@"확인"
                             otherButtonTitles:nil
                                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          if (buttonIndex == alertView.cancelButtonIndex) {
                                              [self didTouchBackButton];
                                              return;
                                          }
                                      }];
                }
                //비로그인 상태 성인상품
                else if ([[productData[@"status"][@"code"] stringValue] isEqualToString:@"805"]) {
                    [self openLoginViewControllerWithAdult:YES];
                    return;
                }
                //로그인 상태 미성년 성인상품접근시
                else if ([[productData[@"status"][@"code"] stringValue] isEqualToString:@"804"]) {
                    
                    if (![Modules checkAdultFromCookie]) { //성인인증 안됐으면 인증페이지로
                        [self openLoginViewControllerWithAdult:YES];
                    }
                    else {
                        [UIAlertView showWithTitle:STR_APP_TITLE
                                           message:productData[@"status"][@"d_message"]
                                 cancelButtonTitle:@"확인"
                                 otherButtonTitles:nil
                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              if (buttonIndex == alertView.cancelButtonIndex) {
                                                  [self didTouchBackButton];
                                                  return;
                                              }
                                          }];
                    }
                }
            }
        }

        //튜토리얼
        if ([@"tagging" isEqualToString:productInfo[@"prdDescImage"][@"detailViewType"]]) { //스마트옵션
            if (NO == [[NSUserDefaults standardUserDefaults] boolForKey:@"product_smartoption_tutorial"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"product_smartoption_tutorial"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self makeSmartOptionTutorialView];
            }
        }
        else {
            if (NO == [[NSUserDefaults standardUserDefaults] boolForKey:@"product_coupon_tutorial"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"product_coupon_tutorial"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self makeCouponTutorialView];
            }
        }
    
        //Offer Banner
        mdnBannerView = [[CPBannerManager sharedManager] makeOfferBannerView];
        [[CPBannerManager sharedManager] setDelegate:self];
        [self.view insertSubview:mdnBannerView aboveSubview:mainScrollView];
        
        isApiRequesting = NO;
        
        if (afterLoginAction != AfterLoginActionStatusNone) {
            [self performSelector:@selector(delayPopupViewControllerAfterSuccessLogin) withObject:nil afterDelay:1.5f];
        }
        else {
            [self stopLoadingAnimation];
        }
    };
    
    void (^productFailure)(NSError *);
    productFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        
        errorView = [[CPErrorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)];
        [errorView setDelegate:self];
        [self.view addSubview:errorView];
        
        isApiRequesting = NO;
    };
    
    NSString *productUrl = PRODUCT_DETAIL_URL;
    productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    productUrl = [[Modules urlWithQueryString:productUrl] stringByAppendingFormat:@"&requestTime=%@",
           [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];

    tempUrl = productUrl;
    
    if (productUrl) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:productUrl
                                                         success:productSuccess
                                                         failure:productFailure];
    }
}

- (void)getProductOption
{
    NSString *url = PRODUCT_OPTION_URL;
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             if (result) {
                                                                 [self isSuccessLoadOptionWithStatusCode:result];
                                                             }
                                                             else {
                                                                 loadOptionStatus = LoadOptionStatusFailed;
                                                             }
        }
                                                         failure:^(NSError *error) {
                                                             loadOptionStatus = LoadOptionStatusFailed;
        }];
    }
}

- (void)setTodayProduct
{
    //최근 본 상품 등록
    NSString *url = PRODUCT_TODAY_URL;
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             //don't do anything.
                                                         }
                                                         failure:^(NSError *error) {
                                                             //
                                                         }];
    }
}

- (void)setProductLike
{
    [self startLoadingAnimation];
    
    //좋아요 등록
    NSString *url = PRODUCT_ADD_LIKE_URL;
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             if (result) {
                                                                 [self isSuccessAddLikeItemWithStatusCode:result];
                                                             }
                                                             else {
                                                                 [self stopLoadingAnimation];
                                                                 DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해 주십시오.");
                                                             }
                                                         }
                                                         failure:^(NSError *error) {
                                                             [self stopLoadingAnimation];
                                                             
                                                             DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해 주십시오.");
                                                         }];
    }
}

- (void)getProductLikeInfo
{
    [self startLoadingAnimation];
    
    //좋아요 조회
    NSString *url = PRODUCT_LIKE_INFO_URL;
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             [self stopLoadingAnimation];
                                                             
                                                             NSInteger statusCode = [result[@"status"][@"code"] intValue];
                                                             
                                                             if (statusCode == 200) {
                                                                 [productLikeView setLikeButtonStatus:result[@"response"][@"likeInfo"]];
                                                                 
                                                                 UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
                                                                 [likeImageView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
                                                                 [likeImageView setImage:[UIImage imageNamed:@"ic_like_animation.png"]];
                                                                 [self.view addSubview:likeImageView];
                                                                 [self.view bringSubviewToFront:likeImageView];
                                                                 
                                                                 if (SYSTEM_VERSION_GREATER_THAN(@"7")) {
                                                                     likeImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                                     [UIView animateWithDuration:2.0f
                                                                                           delay:0
                                                                          usingSpringWithDamping:0.2f
                                                                           initialSpringVelocity:6.0f
                                                                                         options:UIViewAnimationOptionAllowUserInteraction
                                                                                      animations:^{
                                                                                          likeImageView.transform = CGAffineTransformIdentity;
                                                                                      }
                                                                                      completion:^(BOOL finished) {
                                                                                          [likeImageView removeFromSuperview];
                                                                                      }];
                                                                 }
                                                                 else {
                                                                     [UIView animateWithDuration:1.0f animations:^{
                                                                         [likeImageView removeFromSuperview];
                                                                     }];
                                                                 }
                                                             }
                                                         }
                                                         failure:^(NSError *error) {
                                                             [self stopLoadingAnimation];
                                                             
                                                             DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해 주십시오.");
                                                         }];
    }
}

- (void)requestAddWishListWithUrl:(NSString *)url
{
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:^(NSDictionary *result) {
                                                             [self stopLoadingAnimation];
                                                             
                                                             if (result) {
                                                                 NSInteger statusCode = [result[@"status"][@"code"] integerValue];
                                                                 
                                                                 if (statusCode == 200) {
//                                                                     [self sendRecoPickWithAction:RecoPickActionTypeBasket];
                                                                     
                                                                     if (SYSTEM_VERSION_GREATER_THAN(@"7")) {
                                                                         UIImageView *cartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
                                                                         [cartImageView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
                                                                         [cartImageView setImage:[UIImage imageNamed:@"ic_cart_animation.png"]];
                                                                         [self.navigationController.view addSubview:cartImageView];
                                                                         [self.navigationController.view bringSubviewToFront:cartImageView];
                                                                         
                                                                         cartImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                                         [UIView animateWithDuration:2.0f
                                                                                               delay:0
                                                                              usingSpringWithDamping:0.2f
                                                                               initialSpringVelocity:6.0f
                                                                                             options:UIViewAnimationOptionAllowUserInteraction
                                                                                          animations:^{
                                                                                              cartImageView.transform = CGAffineTransformIdentity;
                                                                                          }
                                                                                          completion:^(BOOL finished) {
                                                                                              [cartImageView removeFromSuperview];
                                                                                          }];
                                                                     }
                                                                     else {
                                                                         [UIAlertView showWithTitle:STR_APP_TITLE
                                                                                            message:@"장바구니에 담겼습니다.\n지금 장바구니로 이동하시겠습니까?"
                                                                                  cancelButtonTitle:@"확인"
                                                                                  otherButtonTitles:@[ @"취소" ]
                                                                                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                               if (alertView.cancelButtonIndex == buttonIndex)
                                                                                               {
                                                                                                   [self onClickedCartButton:nil];
                                                                                               }
                                                                                           }];
                                                                     }
                                                                 }
                                                                 else {
                                                                     DEFAULT_ALERT(STR_APP_TITLE, result[@"status"][@"message"]);
                                                                 }
                                                             }
                                                             else {
                                                                 DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해 주십시오.");
                                                             }

                                                         }
                                                         failure:^(NSError *error) {
                                                             [self stopLoadingAnimation];
                                                             
                                                             DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해 주십시오.");
                                                         }];
    }
}

- (void)getMyCouponInfo
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
    [queryString appendFormat:@"prdNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"prdNo"])];
    [queryString appendFormat:@"&selMnbdNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"miniMall"][@"selMemNo"])];
    [queryString appendFormat:@"&selMthdCd=%@", STRING_OR_EMPTYSTRING(productInfo[@"selMthdCd"])];
    [queryString appendFormat:@"&lDispCtgrNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"lDispCtgrNo"])];
    [queryString appendFormat:@"&mDispCtgrNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"mDispCtgrNo"])];
    [queryString appendFormat:@"&sDispctgrNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"sDispCtgrNo"])];
    [queryString appendFormat:@"&dispCtgrNo=%@", STRING_OR_EMPTYSTRING(productInfo[@"dispCtgrNo"])];
    [queryString appendFormat:@"&brd_cd=%@", STRING_OR_EMPTYSTRING(productInfo[@"brd_cd"])];
    [queryString appendFormat:@"&selPrc=%@", STRING_OR_EMPTYSTRING(productInfo[@"cpnParamSelPrc"])];
    [queryString appendFormat:@"&soCupnAmt=%@", STRING_OR_EMPTYSTRING(productInfo[@"soDscAmt"])];
    [queryString appendFormat:@"&moCupnAmt=%@", STRING_OR_EMPTYSTRING(productInfo[@"moDscAmt"])];
    
    [queryString appendString:@"&optionStock=1"];
    [queryString appendString:@"&optionPrc=0"];
    [queryString appendString:@"&optionStckNo=0"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", PRODUCT_COUPON_DETAIL_URL, queryString];
    
    [[CPRESTClient sharedClient] requestProductDetailWithUrl:urlString
                                                     success:^(NSDictionary *dict) {
                                                         NSInteger statusCode = [dict[@"resultCode"] integerValue];
                                                         if (statusCode == 200) {
                                                             
                                                             if (dict[@"result"] && [dict[@"result"] count] > 0) {
                                                                 NSArray *coupons = [dict[@"result"] copy];
                                                                 
                                                                 NSDictionary *couponInfo = coupons.firstObject;
                                                                 NSInteger TOTAL_AMT = [couponInfo[@"TOTAL_AMT"] integerValue];
                                                                 NSInteger finalDscPrc = [productInfo[@"prdPrice"][@"finalDscPrc"] integerValue];
                                                                 
                                                                 if (TOTAL_AMT < finalDscPrc) {
                                                                     productPriceView.couponInfo = coupons.firstObject;
                                                                     
                                                                     if (!(productInfo[@"selStatStmt"] && [@"N" isEqualToString:productInfo[@"optDrawerYn"]])) {
                                                                         [productPriceView reloadLayout];
                                                                         
                                                                         //영역 넓혀줌
                                                                         [self didTouchExpandButton:CPProductViewTypePrice height:40];
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                     }
                                                     failure:^(NSError *error) {
                                                         //
                                                     }];
}

- (void)getLiveData
{   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"prdNo"] = productNumber;
    
    if (productInfo[@"prdLiveDataParam"]) {
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString *jsonString = [jsonWriter stringWithObject:productInfo[@"prdLiveDataParam"]];
        params[@"prdData"] = jsonString ? [Modules encodeAddingPercentEscapeString:jsonString] : @"";
    }
    
    NSString *url;
    if (productInfo[@"prdLiveDataUrl"]) {
        url = productInfo[@"prdLiveDataUrl"];
    }
    else {
        url = PRODUCT_LIVE_DATA_URL;
    }
    
    [[CPRESTClient sharedClient] requestProductLiveDataWithUrl:url
                                                         param:params
                                                       success:^(NSDictionary *dict) {
                                                        
                                                           NSInteger statusCode = [dict[@"status"][@"code"] integerValue];
                                                           if (statusCode == 200) {
                                                               
                                                               //test값
//                                                               NSString *jsonString = @"{\"status\": { \"code\" : 200 , \"d_message\" : \"\" , \"message\" : \"가가가가\"	 } , \"appDetail\" :{ \"prdLike\":{\"likeCnt\":\"3\",\"likeYn\":\"N\"} , \"bnfMyDiscount\" : {\"text\":\"최저 161,700원\",\"myDiscountLayer\":[{\"type\":\"TMember\",\"label\":\"테스트\",\"price\":\"161,700원\",\"dscText\":\"2% 5,000원\"},{\"helpTitle\":\"테테테스스스트트트\",\"type\":\"Card\",\"label\":\"라벨테스트\",\"price\":\"161,700원\",\"helpLinkUrl\":\"http://m.11st.co.kr/MW/api/app/elevenst/product/prdInfoLayer.tmall?type=cardDiscount&layerInfoStr=%7B%22cardDscNm%22%3A%22%BB%EF%BC%BA%2CNH%B3%F3%C7%F9%2C%BD%C5%C7%D1%2CKB%B1%B9%B9%CE%22%7D\",\"dscText\":\"2%\"},{\"type\":\"Mileage\",\"label\":\"라벨라벨\",\"price\":\"161,700원\",\"dscText\":\"2% 5,0000원\"},{\"helpTitle\":\"헬프타이틀\",\"type\":\"helpTxt\",\"label\":\"라벨벨벨\",\"helpLinkUrl\":\"http://m.11st.co.kr/MW/api/app/elevenst/product/prdInfoLayer.tmall?type=myDiscount\"}]} , \"bnfAddDiscount\" : {\"text\":\"25,370원 최저\",\"helpTitle\":\"테스트\",\"addDiscountLayer\":[{\"type\":\"Mileage\",\"label\":\"라벨라벨\",\"price\":\"25,370원\",\"dscText\":\"11% 할인 5,000원\"}],\"helpLinkUrl\":\"http://m.11st.co.kr/MW/api/app/elevenst/product/prdInfoLayer.tmall?type=priceInfo\"} , \"prdBenfitIcon\":[{\"borderColor\":\"0xB6C7FF\",\"textColor\":\"0x6989FF\",\"label\":\"아아아\",\"bgColor\":\"0xFFFFFF\"}] } }";
//
//                                                               NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//                                                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

//                                                               NSDictionary *appDetail = [dict[@"appDetail"] copy];

                                                               //뱃지 갱신
                                                               NSMutableArray *badgeArray = [dict[@"prdBenfitIcon"] mutableCopy];
                                                               if ([productInfo[@"prdBenfitIcon"] isKindOfClass:[NSArray class]] && [productInfo[@"prdBenfitIcon"] count] > 0) {
                                                                   productBadgeView.badges = badgeArray;
                                                               }
                                                               else {
                                                                   [productBadgeView setFrame:CGRectMake(10, CGRectGetMaxY(productThumbnailView.frame)+8, CGRectGetWidth(mainScrollView.frame)-20, 20)];
                                                                   productBadgeView.badgeType = ProductBadgeTypeRectangle;
                                                                   productBadgeView.isProductDetail = YES;
                                                                   productBadgeView.badges = badgeArray;
                                                                   [mainScrollView addSubview:productBadgeView];
                                                               }

                                                               //내맘대로할인 갱신
//                                                               NSDictionary *myDiscountDic = [appDetail mutableCopy];
                                                               NSDictionary *myDiscountDic = [dict[@"bnfMyDiscount"] mutableCopy];
                                                               if (myDiscountDic && [myDiscountDic count] > 0) {
                                                                   [myDiscountView reloadLayout:myDiscountDic viewType:CPProductViewTypeMyDiscount];
                                                               }
                                                               else {
                                                                   [myDiscountView reloadLayout:nil viewType:CPProductViewTypeMyDiscount];
                                                               }
                                                               
                                                               //추가할인가 갱신
//                                                               NSDictionary *addDiscountDic = [appDetail mutableCopy];
                                                               NSDictionary *addDiscountDic = [dict[@"bnfAddDiscount"] mutableCopy];
                                                               if (addDiscountDic && [addDiscountDic count] > 0) {
                                                                   [productDiscountView reloadLayout:addDiscountDic viewType:CPProductViewTypeAddDisount];
                                                               }
                                                               else {
                                                                   [productDiscountView reloadLayout:nil viewType:CPProductViewTypeAddDisount];
                                                               }
                                                               
                                                               [self viewReSetting];
                                                           }
                                                           
                                                    } failure:^(NSError *error) {
                                                        //
                                                    }];
}

#pragma mark - 좋아요

- (void)isSuccessAddLikeItemWithStatusCode:(NSDictionary *)dict
{
    //code
    //200 : 좋아요 성공
    //904 : 이미 좋아요 하셨습니다.
    //401 : 로그인이 필요합니다.
    NSInteger statusCode = [dict[@"status"][@"code"] integerValue];
    
    if (statusCode == 200) {
        [self getProductLikeInfo];
        
        //RecoPick - Like action
//        [self sendRecoPickWithAction:RecoPickActionTypeLike];
    }
    else if (statusCode == 904) {
        [self stopLoadingAnimation];
        
        DEFAULT_ALERT(@"알림", @"이미 좋아요 하셨습니다!");
        
//        [self showLikeStatusPopupSuccessOrFail:NO];
    }
    else if (statusCode == 401) {
        [self stopLoadingAnimation];
        [UIAlertView showWithTitle:STR_APP_TITLE
                           message:@"로그인이 필요합니다."
                 cancelButtonTitle:@"로그인"
                 otherButtonTitles:@[ @"취소" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == alertView.cancelButtonIndex) {
                                  afterLoginAction = AfterLoginActionStatusLike;
//                                  [self openLoginView:@"" isAdult:NO];
                                  [self openLoginViewControllerWithAdult:NO];
                              }
                          }];
    }
    else {
        [self stopLoadingAnimation];
        [UIAlertView showWithTitle:STR_APP_TITLE
                           message:dict[@"status"][@"d_message"]
                 cancelButtonTitle:@"취소"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          }];
    }
}

- (void)showLikeStatusPopupSuccessOrFail:(BOOL)successOrFail
{
    CGRect rectClient = self.view.bounds;
    CPLikePopupView *likeStatusPopupView = [[CPLikePopupView alloc] initWithFrame:rectClient popupType:LikePopupTypeProduct];
    [self.view addSubview:likeStatusPopupView];
    
    likeStatusPopupView.likeSuccess = successOrFail;
    likeStatusPopupView.hidden = NO;
    likeStatusPopupView.delegate = self;
    
    [likeStatusPopupView setAlpha:0.0f];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [likeStatusPopupView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:likeStatusPopupView];
                     }];
}


#pragma mark - 서랍옵션 설정

- (void)isSuccessLoadOptionWithStatusCode:(NSDictionary *)dict
{
    if (!isViewAlive) return;
    
    NSInteger statusCode = [dict[@"status"][@"code"] integerValue];
    
    if (statusCode == 200) {
        if (!dict[@"optList"] || [dict[@"optList"] count] == 0) {
            loadOptionStatus = LoadOptionStatusFailed;
            return;
        }
        
        optionInfo = [[NSDictionary alloc] initWithDictionary:dict];
        [self setOptionDrawerItem];
    }
    else if (statusCode == 785) {
        optionInfo = [[NSDictionary alloc] initWithDictionary:dict];
        [self setOptionDrawerItem];
    }
    else {
        loadOptionStatus = LoadOptionStatusFailed;
    }
}

- (void)setOptionDrawerItem
{
    if ([productInfo[@"status"][@"code"] integerValue] == 791) {
        return;
    }
    
    if (optionInfo) {
        if (!drawerView.optionDictionary) {
            [drawerView setOptionDictionary:optionInfo];
        }
        
        NSString *prdNo = productInfo[@"prdNo"] ? productInfo[@"prdNo"] : @""; // 상품번호
        NSString *prdNm = productInfo[@"prdNm"] ? productInfo[@"prdNm"] : @""; // 상품명
        
        NSString *price = productInfo[@"totPrdPrc"] ? productInfo[@"totPrdPrc"] : @""; // 옵션이 없는 상품일때 가격
        NSString *stckQty = productInfo[@"totStock"] ? productInfo[@"totStock"] : @""; // 옵션이 없을 때 재고수량
        NSString *prdTypCd = productInfo[@"prdTypCd"] ? productInfo[@"prdTypCd"] : @""; // 상품타입 "01~28" 일반
        NSString *selOptCnt = productInfo[@"selOptCnt"] ? productInfo[@"selOptCnt"] : @""; // 상품구매선택형 옵션 개수
        NSString *insOptCnt = productInfo[@"insOptCnt"] ? productInfo[@"insOptCnt"] : @""; // 입력형 옵션개수
        
        NSString *maxQty = productInfo[@"selLimitQty"] ? productInfo[@"selLimitQty"] :@""; // 최대구매수량 (최대구매수량이 있는 경우)
        NSString *minQty = productInfo[@"selMinLimitQty"] ? productInfo[@"selMinLimitQty"] : @""; // 최소구매수량 (최소구매수량이 있는 경우)
        NSString *selLimitStr = productInfo[@"selLimitStr"] ? productInfo[@"selLimitStr"] : @""; // 최대구매수량 문구
        
        NSString *categoryNo = productInfo[@"dispCtgrNo"] ? productInfo[@"dispCtgrNo"] : @""; // 카테고리번호
        NSString *idispCtgrNo = productInfo[@"lDispCtgrNo"] ? productInfo[@"lDispCtgrNo"] : @""; // 대카테고리 번호
        NSString *totPrdStckNo = productInfo[@"totPrdStckNo"] ? productInfo[@"totPrdStckNo"] : @""; // 옵션이 없을 때 재고번호
        
        NSString *bcktExYn = productInfo[@"bcktExYn"] ? productInfo[@"bcktExYn"] : @""; //장비구니 제한 여부
        NSString *iscpn = productInfo[@"iscpn"] ? productInfo[@"iscpn"] : @""; // 쿠폰유무
        NSString *giftYn = productInfo[@"giftYn"] ? productInfo[@"giftYn"] : @""; //선물여부
        NSString *syrupPayYn = productInfo[@"syrupPayYn"] ? productInfo[@"syrupPayYn"] : @""; //시럽페이 구매버튼 노출여부
        NSString *dateOptYn = productInfo[@"dateOptYn"] ? productInfo[@"dateOptYn"] : @""; //날짜형상품여부
        NSString *dealPrivatePrdYn = productInfo[@"dealPrivatePrdYn"] ? productInfo[@"dealPrivatePrdYn"] : @""; //쇼킹딜전용상품여부
        
        
        NSString *selPrc = productInfo[@"priceInfo"][@"selPrc"] ? productInfo[@"priceInfo"][@"selPrc"] : @""; // 판매가
        NSString *cupnPrc = productInfo[@"priceInfo"][@"finalDscPrc"] ? productInfo[@"priceInfo"][@"finalDscPrc"] : @""; // 할인모음가

        NSString *myPriceFlag = productInfo[@"mypriceFlag"] ? productInfo[@"mypriceFlag"] : @"Y"; //11번가에서 미사용?
        NSString *myPriceExtraParams = productInfo[@"mypriceExtraParams"] ? productInfo[@"mypriceExtraParams"] : @"";
        
        //쿠폰용
        NSString *selMemNo = productInfo[@"miniMall"][@"selMemNo"] ? productInfo[@"miniMall"][@"selMemNo"] : @"";
        NSString *selMthdCd = productInfo[@"selMthdCd"] ? productInfo[@"selMthdCd"] : @"";
        NSString *lDispCtgrNo = productInfo[@"lDispCtgrNo"] ? productInfo[@"lDispCtgrNo"] : @"";
        NSString *mDispCtgrNo = productInfo[@"mDispCtgrNo"] ? productInfo[@"mDispCtgrNo"] : @"";
        NSString *sDispCtgrNo = productInfo[@"sDispCtgrNo"] ? productInfo[@"sDispCtgrNo"] : @"";
        NSString *dispCtgrNo = productInfo[@"dispCtgrNo"] ? productInfo[@"dispCtgrNo"] : @"";
        NSString *brd_cd = productInfo[@"brd_cd"] ? productInfo[@"brd_cd"] : @"";
        NSString *soDscAmt = productInfo[@"soDscAmt"] ? productInfo[@"soDscAmt"] : @"";
        NSString *moDscAmt = productInfo[@"moDscAmt"] ? productInfo[@"moDscAmt"] : @"";
        NSString *cpnParamSelPrc = productInfo[@"cpnParamSelPrc"] ? productInfo[@"cpnParamSelPrc"] : @"";
        
        //01 구매하기(일반) 06 배송지지정하는마트상품
        NSString *incommingCode = productInfo[@"incommingCode"] ? productInfo[@"incommingCode"] : @"01";
        
        //주문제작 상품
        NSString *oemPrdYn = productInfo[@"oemPrdYn"] ? productInfo[@"oemPrdYn"] : @"";
        
        //웹에서 보내고 있는 주문 파라미터
        NSString *buyParameter = productInfo[@"buyParameter"] ? productInfo[@"buyParameter"] : @"";
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:prdNm forKey:@"prdNm"];
        [info setValue:prdNo forKey:@"prdNo"];
        [info setValue:selOptCnt forKey:@"selOptCnt"];
        [info setValue:categoryNo forKey:@"dispCtgrNo"];
        [info setValue:insOptCnt forKey:@"insOptCnt"];
        [info setValue:iscpn forKey:@"iscpn"];
        [info setValue:idispCtgrNo forKey:@"lDispCtgrNo"];
        [info setValue:prdTypCd forKey:@"prdTypCd"];
        [info setValue:totPrdStckNo forKey:@"totPrdStckNo"];
        [info setValue:price forKey:@"totPrdPrc"];
        [info setValue:stckQty forKey:@"totStock"];
        [info setValue:maxQty forKey:@"maxQty"];
        [info setValue:minQty forKey:@"minQty"];
        [info setValue:selLimitStr forKey:@"selLimitStr"];
        [info setValue:bcktExYn forKey:@"bcktExYn"];
        [info setValue:giftYn forKey:@"giftYn"];
        [info setValue:syrupPayYn forKey:@"syrupPayYn"];
        [info setValue:dateOptYn forKey:@"dateOptYn"];
        [info setValue:selPrc forKey:@"selPrc"];
        [info setValue:cupnPrc forKey:@"cupnPrc"];
        [info setValue:dealPrivatePrdYn forKey:@"dealPrivatePrdYn"];
        [info setValue:myPriceFlag forKey:@"myPriceFlag"];
        [info setValue:myPriceExtraParams forKey:@"myPriceExtraParams"];
//        [info setValue:pluYn forKey:@"pluYn"];
        [info setValue:selMemNo forKey:@"selMemNo"];
        [info setValue:selMthdCd forKey:@"selMthdCd"];
        [info setValue:lDispCtgrNo forKey:@"lDispCtgrNo"];
        [info setValue:mDispCtgrNo forKey:@"mDispCtgrNo"];
        [info setValue:sDispCtgrNo forKey:@"sDispCtgrNo"];
        [info setValue:dispCtgrNo forKey:@"dispCtgrNo"];
        [info setValue:brd_cd forKey:@"brd_cd"];
        [info setValue:soDscAmt forKey:@"soDscAmt"];
        [info setValue:moDscAmt forKey:@"moDscAmt"];
        [info setValue:cpnParamSelPrc forKey:@"cpnParamSelPrc"];
        [info setValue:ctlgStockNo forKey:@"ctlgStockNo"]; //마트일 경우  ctlgStockNo 로 넘어오는 옵션을 디폴트로 옵션선택되어 있도록
        [info setValue:incommingCode forKey:@"incommingCode"]; //01 구매하기(일반) 06 배송지지정하는마트상품
        [info setValue:oemPrdYn forKey:@"oemPrdYn"]; //주문제작 상품
        [info setValue:buyParameter forKey:@"buyParameter"];
        
        NSMutableDictionary *urlDict = [[NSMutableDictionary alloc] init];
        [urlDict setValue:PRODUCT_CHECK_BUY_URL forKey:@"checkBuyPrefix"];
        
        NSString *buyUrl;
        if (productInfo[@"netFunnelId"][@"buyUrl"]) {
            buyUrl = productInfo[@"netFunnelId"][@"buyUrl"];
            buyUrl = [buyUrl stringByAppendingString:@"?"];
        }
        else {
            buyUrl = PRODUCT_ORDER_URL;
        }
        [urlDict setValue:buyUrl forKey:@"orderUrl"];
        
        [urlDict setValue:PRODUCT_BASKET_URL forKey:@"insBskPrefix"];
        [urlDict setValue:PRODUCT_SUBOPT_URL forKey:@"subOptPrefix"];
        [urlDict setValue:PRODUCT_LASTOPT_URL forKey:@"lastOptPrefix"];
        [urlDict setValue:PRODUCT_STOCK_URL forKey:@"stockInfoPrefix"];
        
        [drawerView setDelegate:self];
        [drawerView setItemDetailInfo:info];
        [drawerView setUrlDictionary:urlDict];
        [drawerView setProductInfo:productInfo];
        [drawerView setPriceInfoDictionary:productInfo[@"prdPrice"]];
        [drawerView setMartDictionary:productInfo[@"martInfo"]];
        
        if (productInfo[@"response"][@"deliveryInfo"][0]) {
            NSArray *deliveryArr = [productInfo[@"response"][@"deliveryInfo"] mutableCopy];
            NSMutableDictionary *deliveryDict = [productInfo[@"response"][@"deliveryInfo"][0] mutableCopy];
            
            if (deliveryArr && [deliveryArr count] > 1) {
                NSDictionary *tempDict = [deliveryArr objectAtIndex:1];
                
                if (tempDict && [tempDict objectForKey:@"label"] == nil && [tempDict objectForKey:@"text"]) {
                    NSString *lastStr = [[[deliveryDict objectForKey:@"display"] lastObject] objectForKey:@"text"];
                    
                    if ([[lastStr trim] length] > 0 && [[[tempDict objectForKey:@"text"] trim] length] > 0) {
                        lastStr = [lastStr stringByAppendingString:[NSString stringWithFormat:@"(%@)", [tempDict objectForKey:@"text"]]];
                        
                        NSMutableArray *lastArray = [[deliveryDict objectForKey:@"display"] mutableCopy];
                        NSMutableDictionary *lastDict = [[lastArray lastObject] mutableCopy];
                        
                        [lastDict setObject:lastStr forKey:@"text"];
                        [lastArray replaceObjectAtIndex:lastArray.count-1 withObject:lastDict];
                        
                        [deliveryDict setValue:lastArray forKey:@"display"];
                    }
                }
            }
            
            [drawerView setDeliveryInfoDictionary:deliveryDict];
        }
        
        if (productInfo[@"response"][@"periodInfo"]) {
            [drawerView setPeriodInfo:productInfo[@"response"][@"periodInfo"]];
        }
        
        if (productInfo[@"response"][@"trTypeCd"]) {
            [drawerView setTrTypeCd:productInfo[@"response"][@"trTypeCd"]];
        }
        
        //다음과 같은 상황에 대한 오류 발생 해결
        //1. 상품상세 진입 후 바로 장바구니페이지로 이동할 경우
        //2. 상품구매 / 장바구니등록 시 로그인화면 진입 후 이동할 경우
        // -> 다음화면에 서랍이 남는 현상이 있다. (서랍을 navigation view에 붙이기 때문에..)
        UIViewController *lastViewController = (UIViewController *)[self.navigationController.viewControllers lastObject];
        if ([lastViewController isKindOfClass:[CPProductViewController class]]) {
            [drawerView setHidden:NO];
            [drawerView setAlpha:0.0f];
            [UIView animateWithDuration:0.15f animations:^{
                [drawerView setAlpha:1.0f];
            } completion:^(BOOL finished) {
                
                if (loadOptionStatus == LoadOptionStatusRetryPurchase) {
                    loadOptionStatus = LoadOptionStatusFinished;
                    return;
                }
                else if (loadOptionStatus == LoadOptionStatusRetryGift) {
                    loadOptionStatus = LoadOptionStatusFinished;
                    return;
                }
                
                loadOptionStatus = LoadOptionStatusFinished;
            }];
        }
        else {
            [drawerView setAlpha:1.0f];
            [self setHiddenBottomView:YES];
            
            if (loadOptionStatus == LoadOptionStatusRetryPurchase) {
                loadOptionStatus = LoadOptionStatusFinished;
                return;
            }
            else if (loadOptionStatus == LoadOptionStatusRetryGift) {
                loadOptionStatus = LoadOptionStatusFinished;
                return;
            }
            
            loadOptionStatus = LoadOptionStatusFinished;
        }
    }
    else {
        loadOptionStatus = LoadOptionStatusFailed;
    }
}

#pragma mark - Private Methods

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:viewControlelr animated:animated];
    
    if (![bottomView isHidden]) {
        [self setHiddenBottomView:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange)
                                                 name:WebViewControllerNotification
                                               object:nil];
}

- (void)openWebViewControllerWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)isIgnore
{
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url isPop:isPop isIgnore:isIgnore];
    [self.navigationController pushViewController:viewControlelr animated:NO];
    
    if (![bottomView isHidden]) {
        [self setHiddenBottomView:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange)
                                                 name:WebViewControllerNotification
                                               object:nil];
}

- (void)openWebViewControllerWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)isIgnore isProduct:(BOOL)isProduct
{
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url isPop:isPop isIgnore:isIgnore isProduct:isProduct];
    [self.navigationController pushViewController:viewControlelr animated:NO];
    
    if (![bottomView isHidden]) {
        [self setHiddenBottomView:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange)
                                                 name:WebViewControllerNotification
                                               object:nil];
}

- (void)openPopupBrowser:(NSDictionary *)popupInfo isOptionDrawer:(BOOL)isOptionDrawer
{
    if (productWebView && [popupInfo[@"key"] isEqualToString:currentPopupInfo[@"key"]]) {
        return;
    }
    
    currentPopupInfo = popupInfo;
    
    CGFloat statusBarY = [SYSTEM_VERSION intValue] >= 7 ? 20 : 0;
    CGFloat statusBarHeight = 20;
    
    //원본보기, 스마트옵션에만 서랍옵션을 노출
    CGFloat drawerHeight = 0;
    if (isOptionDrawer && bottomView) {
        drawerHeight = kBottomViewHeight;
    }
    
    productWebView = [[CPProductWebView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth,
                                                                        statusBarY,
                                                                        kScreenBoundsWidth,
                                                                        kScreenBoundsHeight-(statusBarHeight+drawerHeight))
                                                   popupInfo:popupInfo];
    [productWebView setDelegate:self];
    [self.navigationController.view addSubview:productWebView];
    
    if (isOptionDrawer && bottomView) {
        [self.navigationController.view bringSubviewToFront:drawerView];
        [self.navigationController.view bringSubviewToFront:bottomView];
    }
    
    CGRect frame = productWebView.frame;
    frame.origin.x = 0;
    
    [UIView animateWithDuration:0.3f animations:^{
        [productWebView setFrame:frame];
        
    }];
    
//    [UIView animateWithDuration:0.3f animations:^{
//        [productWebView setFrame:frame];
//    } completion:^(BOOL finished) {
//        if (isOptionDrawer) {
//            [self.navigationController.view bringSubviewToFront:drawerView];
//            [self.navigationController.view bringSubviewToFront:bottomView];
//        }
//    }];
}

- (void)openLayerPopup:(NSString *)title linkUrl:(NSString *)linkUrl
{
    commonLayerPopupView = [[CPCommonLayerPopupView alloc] initWithFrame:self.view.bounds
                                                                   title:title
                                                                 linkUrl:linkUrl];
    [commonLayerPopupView setDelegate:self];
    [self.view addSubview:commonLayerPopupView];
    [self.view bringSubviewToFront:commonLayerPopupView];
    
    [commonLayerPopupView openUrl:linkUrl];
}


- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index
{
    currentItemIndex = index;
    
//    for (UIView *subView in [tabMenuView subviews]) {
//        if ([subView isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)subView;
            
//            NSDictionary *title = tabMenuItems[button.tag];
//            NSDictionary *content = tabMenuItems[index];
            
//            if ([title[@"key"] isEqualToString:content[@"key"]]) {
////                [self setHighlightedButtonProperties:button];
//            }
//            else {
////                [self setButtonProperties:button];
//            }
//        }
//    }
}

- (NSInteger)findTabMenu:(NSInteger)index
{
    NSInteger tabIndex = 0;
//    NSString *menuTitleKey = tabMenuItems[index][@"key"];
//    
//    for (int i = 0; i < tabMenuItems.count; i++) {
//        NSDictionary *menuContentInfo = tabMenuItems[i];
//        if ([menuTitleKey isEqualToString:menuContentInfo[@"key"]]) {
//            
//            tabIndex =  i;
//            return tabIndex;
//        }
//    }
    
    return tabIndex;
}

- (void)moveSideButton:(NSInteger)index
{
    //top버튼 이동
    UIImage *imgOriginalNor = [UIImage imageNamed:@"bt_pd_floating_pc_nor.png"];
    CGFloat moveX = (tabScrollView.frame.size.width-imgOriginalNor.size.width-5.f)+kScreenBoundsWidth*index;
    
//    CGRect frame = originalButton.frame;
//    frame.origin.x = moveX;
//    originalButton.frame = frame;
//    
//    frame = reviewButton.frame;
//    frame.origin.x = moveX;
//    reviewButton.frame = frame;
    
    CGRect frame = topButton.frame;
    frame.origin.x = moveX;
    topButton.frame = frame;
}

- (void)productReload
{
    NSLog(@"productReload!!!");
    if (!loadingView.isAnimating && !isApiRequesting) {
        NSLog(@"productReload2!!!");
        [self getProductData];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SettingControllerDidLoginNotification object:nil];
    }
}

- (void)externalCallUrl
{
    // 1. 레코픽 로그 호출
    NSString *recopickLogUrl = productInfo[@"recopickLogUrl"];
    
    if (recopickLogUrl && [[recopickLogUrl trim] length] > 0) {
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"view"];
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:@""];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:recopickLogUrl];
    }
    
    // 2. 시럽AD로그 호출
    NSString *syrupAdLogUrl = productInfo[@"syrupAdLogUrl"];
    
    if (syrupAdLogUrl && [[syrupAdLogUrl trim] length] > 0) {
        
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{action}}" withString:@"view"];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:@"1"];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{total_sales}}" withString:[NSString stringWithFormat:@"%ld", (long)[productInfo[@"prdPrice"][@"finalDscPrc"] integerValue]]];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:syrupAdLogUrl];
    }
    
    // 3. Hot Click 전환수 측정 로그 호출
//    NSString *ad11stPrdLogUrl = productInfo[@"ad11stPrdLogUrl"];
    
    // 4. Hot Click Pairing 로그 호출
    NSString *hotClickPairingLogUrl = productInfo[@"hotClickPairingLogUrl"];
    
    if (hotClickPairingLogUrl && [[hotClickPairingLogUrl trim] length] > 0) {
        hotClickPairingLogUrl = [hotClickPairingLogUrl stringByReplacingOccurrencesOfString:@"{{method}}" withString:@"visit"];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:hotClickPairingLogUrl];
    }
    
    // 5. 구글 Ad 로그 호출
    NSString *googleAdLogUrl = productInfo[@"googleAdLogUrl"];
    
    if (googleAdLogUrl && [[googleAdLogUrl trim] length] > 0) {
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:googleAdLogUrl];
    }
    
    // 6.  페이스북 로그 호출
    NSString *facebookAdLogUrl = productInfo[@"facebookAdLogUrl"];
    
    if (facebookAdLogUrl && [[facebookAdLogUrl trim] length] > 0) {
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:facebookAdLogUrl];
    }
}

#pragma mark - Validate

- (BOOL)verifyPressedProductButtons:(BOOL)isGift
{
    if ([productInfo[@"status"][@"code"] intValue] == 791) {
        NSString *alertMessage = productInfo[@"status"][@"d_message"] ? productInfo[@"status"][@"d_message"] : nil;
        
        if (alertMessage)	DEFAULT_ALERT(STR_APP_TITLE, alertMessage);
        return NO;
    }
    
    if (loadOptionStatus == LoadOptionStatusFailed) {
        [UIAlertView showWithTitle:STR_APP_TITLE
                           message:@"상품 옵션을 불러오지 못하였습니다. 다시 시도하시겠습니까?"
                 cancelButtonTitle:@"재시도"
                 otherButtonTitles:@[ @"취소" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (alertView.cancelButtonIndex == buttonIndex) {
                                  
                                  if (isGift) {
                                      loadOptionStatus = LoadOptionStatusRetryGift;
                                  }
                                  else	{
                                      loadOptionStatus = LoadOptionStatusRetryPurchase;
                                  }
                                  
                                  [self startLoadingAnimation];
                                  [self getProductData];
                              }
                          }];
        
        return NO;
    }
    
    if (!optionInfo || [optionInfo count] == 0) {
        DEFAULT_ALERT(STR_APP_TITLE, @"상품 옵션을 불러올 수 없습니다. 잠시 후 다시 시도해주세요.");
        return NO;
    }
    
    return YES;
}


#pragma mark - Selectors

- (void)touchCartButton:(id)sender
{
    if (![self verifyPressedProductButtons:YES]) {
        return;
    }
    
    if (productPrdPromotionView && productPrdPromotionView.selectedIndex < 0) {
        [drawerView setIsPrdPromotionAlert:YES];
    }
    else {
        [drawerView setIsPrdPromotionAlert:NO];
    }
    
    //버튼 타입
    if ([@"20" isEqualToString:productInfo[@"prdTypCd"]]) {
        [drawerView setOptionType:openOptionTypeDownload];
    }
    else if ([@"Y" isEqualToString:productInfo[@"bcktExYn"]]) {
        [drawerView setOptionType:openOptionTypeBasket];
    }
    else {
        [drawerView setOptionType:openOptionTypePurchase];
    }
    
    [drawerView validateOpenDrawer:YES];
}

- (void)touchPurchaseButton:(id)sender
{
    if (![self verifyPressedProductButtons:YES]) {
        return;
    }
    
    if (productPrdPromotionView && productPrdPromotionView.selectedIndex < 0) {
        [drawerView setIsPrdPromotionAlert:YES];
    }
    else {
        [drawerView setIsPrdPromotionAlert:NO];
    }
    
    //버튼 타입
    if ([@"20" isEqualToString:productInfo[@"prdTypCd"]]) {
        [drawerView setOptionType:openOptionTypeDownload];
    }
    else if ([@"Y" isEqualToString:productInfo[@"bcktExYn"]]) {
        [drawerView setOptionType:openOptionTypeBasket];
    }
    else {
        [drawerView setOptionType:openOptionTypePurchase];
    }
    
    [drawerView validateOpenDrawer:YES];
}

- (void)touchSyrupButton:(id)sender
{
    //바닥에서는 구매하기와 기능 동일?
    
    if (![self verifyPressedProductButtons:YES]) {
        return;
    }
    
    if (productPrdPromotionView && productPrdPromotionView.selectedIndex < 0) {
        [drawerView setIsPrdPromotionAlert:YES];
    }
    else {
        [drawerView setIsPrdPromotionAlert:NO];
    }
    
    //버튼 타입
    if ([@"20" isEqualToString:productInfo[@"prdTypCd"]]) {
        [drawerView setOptionType:openOptionTypeDownload];
    }
    else {
        [drawerView setOptionType:openOptionTypePurchase];
    }
    
    [drawerView validateOpenDrawer:YES];
}

- (void)touchShockingdealButton
{
    [self touchShockingdealButton:productNumber];
}

- (void)touchShockingdealButton:(NSString *)prdNo
{
    NSString *shockingDealAppURL = @"";
    
    if (prdNo && prdNo.length > 0) {
        shockingDealAppURL = [NSString stringWithFormat:@"elevenstdeal://itemdetail/%@", prdNo];
    }
    else {
        shockingDealAppURL = @"elevenstdeal://maintab/home";
    }
    
    NSString *shockingDealAppstoreURL = @"itms-apps://itunes.apple.com/app/id804663259?mt=8";
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:shockingDealAppURL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppURL]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppstoreURL]];
    }
}

- (void)loginStatusDidChange
{
    [footerView reloadLoginStatus];
}

- (void)didTouchTabMove:(NSInteger)pageIndex
{
    [self didTouchTabMove:pageIndex moveTab:MoveTabTypeNone];
}

- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab
{
    currentItemIndex = pageIndex;
    
    //리뷰/후기 탭 이동 시 분기
    if (pageIndex == TabViewTypeReviewPost && moveTab != MoveTabTypeNone) {
        
        if (!productInfoFeedbackView) {
            //리뷰/후기 탭
            productInfoFeedbackView = [[CPProductInfoUserFeedbackView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame),
                                                                                                      0,
                                                                                                      CGRectGetWidth(mainScrollView.frame),
                                                                                                      CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))
                                                                                     items:productInfo
                                                                                     prdNo:productNumber
                                                                                   moveTab:moveTab
                                                                                   loading:NO];
            [productInfoFeedbackView setDelegate:self];
            [tabScrollView addSubview:productInfoFeedbackView];
            [tabScrollView bringSubviewToFront:topButton];
            [self setMainScrollViewEnable:YES];
        }
        
        isMovePost = YES;
        UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempButton setTag:moveTab-1];
        [productInfoFeedbackView touchTabView:tempButton];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:pageIndex+100];
    [tabMenuView touchTabMenuButton:button];
}

- (void)onClickedTopButton:(id)sender
{
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [tabScrollView setContentOffset:CGPointMake(tabScrollView.frame.origin.x+currentItemIndex*kScreenBoundsWidth, 0) animated:YES];
    [descriptionView setScrollTop];
    [productInfoFeedbackView setScrollTop];
    [productInfoQnAView setScrollTop];
    [productExchangeView setScrollTop];
    
    [self setMainScrollViewEnable:YES];
}

- (void)onClickedOriginalButton:(id)sender
{
    NSString *productUrl = productInfo[@"prdDescImage"][@"pcDetailImgLinkUrl"];
    [self openPopupBrowser:@{@"title": @"원본보기", @"url": productUrl, @"key": @"original"} isOptionDrawer:YES];
    
    //AccessLog - PC버전
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ05"];
}

- (void)onClickedShowReviewButton:(id)sender
{
    [productInfoFeedbackView setScrollTop];
    [productInfoFeedbackView reloadView];
    [self didTouchTabMove:TabViewTypeReviewPost];
    
    //AccessLog - 리뷰이동버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ06"];
}

- (void)onClickedCartButton:(id)sender
{
//    [TRACKING_MANAGER sendWiseLogEventWithDepth1:@"common" depth2:@"gnb" depth3:@"cart"];
    
    if ([Modules checkLoginFromCookie]) {
        NSString *cartUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cart"];
        [self openWebViewControllerWithUrl:cartUrl animated:YES];
    }
    else {
        afterLoginAction = AfterLoginActionStatusCart;
//        [self openLoginView:@"" isAdult:NO];
        [self openLoginViewControllerWithAdult:NO];
    }
}

#pragma mark - CPNavigationBarViewDelegate - 네비게이션바 액션

- (void)didTouchMenuButton
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didTouchBackButton
{
    //백버튼일 경우에는 서랍을 remove
    [self removeBottomView];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTouchBasketButton
{
    NSString *cartUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cart"];
    
    [self openWebViewControllerWithUrl:cartUrl animated:NO];
}

- (void)didTouchLogoButton
{
    [self removeBottomView];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeNotification object:self];
}

- (void)didTouchMartButton
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = app.homeViewController;
//    [homeViewController goToPageAction:@"MART"];
    [homeViewController didTouchMartButton];
}

- (void)didTouchMyInfoButton
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productReload)
                                                 name:SettingControllerDidLoginNotification
                                               object:nil];
}

- (void)didTouchSearchButton:(NSString *)keywordUrl;
{
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
    if ([SYSTEM_VERSION intValue] < 7) {
        [viewController setWantsFullScreenLayout:YES];
    }
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didTouchMartSearchButton
{
    CPMartSearchViewController *viewController = [[CPMartSearchViewController alloc] init];
    [viewController setDelegate:self];
    
    if ([SYSTEM_VERSION intValue] < 7) {
        [viewController setWantsFullScreenLayout:YES];
    }
    
    [self presentViewController:viewController animated:NO completion:nil];
}

#pragma mark - CPMartSearchViewControllerDelegate

- (void)martSearchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        NSString *searchUrl = [[CPCommonInfo sharedInfo] urlInfo][@"martSearch"];
        searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:keyword];
        
        [self openWebViewControllerWithUrl:searchUrl animated:YES];
    }
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:tempUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)searchWithAdvertisement:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - NetFunnelDelegate - 넷펀넬

-(void)setNetFunnelConfig:(NSString *)serviceId actionId:(NSString *)actionId actionUrl:(NSString *)actionUrl
{
    //http://220.103.231.203/ts.wseq?opcode=5101&sid=service_6&aid=test_01
    
    //    [NetFunnel setGlobalConfigObject:@"58.181.39.175" forKey:@"host" withId:nil];
    //    [NetFunnel setGlobalConfigObject:@"http://funnnel.11st.co.kr" forKey:@"host" withId:nil];
    [NetFunnel setGlobalConfigObject:@"220.103.231.203" forKey:@"host" withId:nil];
    [NetFunnel setGlobalConfigObject:@"80" forKey:@"port" withId:nil];
    
//#if DEBUG | ADHOC
//    [NetFunnel setGlobalConfigObject:@"service_6" forKey:@"service_id" withId:nil];
//    [NetFunnel setGlobalConfigObject:@"test_01" forKey:@"action_id" withId:nil];
//#else
    [NetFunnel setGlobalConfigObject:serviceId forKey:@"service_id" withId:nil];
    [NetFunnel setGlobalConfigObject:actionId forKey:@"action_id" withId:nil];
//#endif
    
    netFunnelUrl = actionUrl;
    [[[NetFunnel alloc] initWithDelegate:self pView:self.view] action];
}

-(void)NetFunnelActionSuccess:(NSString *)nid withResult:(NetFunnelResult *)result
{
    NSLog(@"NetFunnelActionSuccess [nid=%@,result=%@",nid,result);
    
    switch (netfunnelType) {
        case CPNetfunnelTypeBasket:
            if (netFunnelUrl) {
                [self requestAddWishListWithUrl:netFunnelUrl];
                [[[NetFunnel alloc] initWithDelegate:self pView:self.view] complete];
            }
            break;
        case CPNetfunnelTypePurchase:
        default:
            if (netFunnelUrl) {
                [self openWebViewControllerWithUrl:netFunnelUrl isPop:NO isIgnore:NO isProduct:YES];
                [[[NetFunnel alloc] initWithDelegate:self pView:self.view] complete];
            }
            break;
    }
}

-(void)NetFunnelCompleteSuccess:(NSString *)nid withResult:(NetFunnelResult *)result
{
    NSLog(@"NetFunnelCompleteSuccess [nid=%@,result=%@",nid,result);
}

-(BOOL)NetFunnelActionContinue:(NSString *)nid withResult:(NetFunnelResult *)result
{
    NSLog(@"NetFunnelActionContinue [nid=%@,result=%@",nid,result);
//    if(nid != nil && [nid isEqualToString:@"3"]){
//        return NO;
//    }
    return YES;
}

-(void)NetFunnelStop:(NSString *)nid
{
    NSLog(@"NetFunnelStop [nid=%@]",nid);
}

-(void)NetFunnelActionError:(NSString *)nid withResult:(NetFunnelResult *)result
{
    NSLog(@"NetFunnelActionError [nid=%@,result=%@",nid,result);
    
    switch (netfunnelType) {
        case CPNetfunnelTypeBasket:
            if (netFunnelUrl) {
                [self requestAddWishListWithUrl:netFunnelUrl];
            }
            break;
        case CPNetfunnelTypePurchase:
        default:
            if (netFunnelUrl) {
                [self openWebViewControllerWithUrl:netFunnelUrl isPop:NO isIgnore:NO isProduct:YES];
            }
            break;
    }
}

#pragma mark - OptionDrawerDelegate - 서랍 옵션

- (void)requestItemPurchase:(OptionDrawer *)optionDrawer requestUrl:(NSString *)url
{
    if ([Modules checkLoginFromCookie]) {
        
        //넷펀넬
        if (productInfo[@"netFunnelId"] && [@"Y" isEqualToString:productInfo[@"netfunnelYn"]]) {
            [self setNetFunnelConfig:productInfo[@"netFunnelId"][@"serviceId"]
                            actionId:productInfo[@"netFunnelId"][@"orderId"]
                           actionUrl:url];
            netfunnelType = CPNetfunnelTypePurchase;
            
        }
        else {
            [self openWebViewControllerWithUrl:url isPop:NO isIgnore:NO isProduct:YES];
        }
    }
    else {
        afterLoginAction = AfterLoginActionStatusPurchase;
        afterLoginActionUrl = url;
//
//        [self openLoginView:@"" isAdult:NO];
        [self openLoginViewControllerWithAdult:NO];
    }
   
    //웹뷰 닫기
    if (productWebView) {
        [productWebView removeFromSuperview];
    }
}

- (void)requestItemWishList:(OptionDrawer *)optionDrawer requestUrl:(NSString *)url
{
    if (!url) {
        return;
    }
    
    if ([Modules checkLoginFromCookie]) {
//        [self requestAddWishListWithUrl:url];
        //넷펀넬
        if (productInfo[@"netFunnelId"] && [@"Y" isEqualToString:productInfo[@"netfunnelYn"]]) {
            [self setNetFunnelConfig:productInfo[@"netFunnelId"][@"serviceId"]
                            actionId:productInfo[@"netFunnelId"][@"basketId"]
                           actionUrl:url];
            netfunnelType = CPNetfunnelTypeBasket;
        }
        else {
            [self requestAddWishListWithUrl:url];
        }
    }
    else {
        afterLoginAction = AfterLoginActionStatusAddWishList;
        afterLoginActionUrl = url;
//
//        [self openLoginView:@"" isAdult:NO];
        [self openLoginViewControllerWithAdult:NO];
    }
    
    if (drawerView) {
        [drawerView closeDrawerNoAnimation];
    }
    
    //웹뷰 닫기
    if (productWebView) {
        [productWebView removeFromSuperview];
    }
}

- (void)requestLogin:(OptionDrawer *)optionDrawer
{
    [self openLoginViewControllerWithAdult:NO];
}

- (void)didTouchMyCoupon:(NSString *)url
{
    if ([Modules checkLoginFromCookie]) {
        [self openPopupBrowser:@{@"title": @"쿠폰 변경", @"url": url, @"key": @"coupon"} isOptionDrawer:NO];
    }
    else {
        afterLoginAction = AfterLoginActionStatusMyCoupon;
        afterLoginActionUrl = url;
        
        [self openLoginViewControllerWithAdult:NO];
    }
}

#pragma mark - CPPopupViewControllerDelegate - 로그인

- (void)openLoginViewControllerWithAdult:(BOOL)isAdult
{
    NSString *loginUrl = [[CPCommonInfo sharedInfo] urlInfo][@"login"];
    NSString *loginUrlString = [Modules urlWithQueryString:loginUrl];
    
    if (isAdult) {
        //callback url은 상품상세weburl
        NSString *goPage = @"app://login/adultcertify/success";
//        NSString *goPage = PRODUCT_DETAIL_WEB_URL;
//        goPage = [goPage stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
        
        NSString *url = COMMON_AUTH_URL;
        loginUrlString = [url stringByReplacingOccurrencesOfString:@"{{goPage}}" withString:goPage];
    }
    
    CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
    
    [popViewController setTitle:@"로그인"];
    [popViewController setIsLoginType:YES];
    [popViewController setIsAdult:isAdult];
    [popViewController setRequestUrl:loginUrlString];
    [popViewController setDelegate:self];
    [popViewController initLayout];
    
    if (self.parentViewController) {
        [self.parentViewController presentViewController:popViewController animated:YES completion:nil];
    }
    else {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([homeViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [homeViewController presentViewController:popViewController animated:YES completion:nil];
        }
    }
}

- (void)popupViewControllerCloseButton
{
    [self didTouchTabMove:currentItemIndex];
}

- (void)popupViewControllerAfterSuccessLogin
{
    //로그인 후 갱신
    [self productReload];
}

- (void)delayPopupViewControllerAfterSuccessLogin
{
    [self stopLoadingAnimation];
    
    if (afterLoginAction == AfterLoginActionStatusLike) {
        //        [self onClickLikeButton:nil];
        [self setProductLike];
    }
    else if (afterLoginAction == AfterLoginActionStatusCart) {
        [self onClickedCartButton:nil];
    }
    else if (afterLoginAction == AfterLoginActionStatusPurchase) {
        [self requestItemPurchase:nil requestUrl:afterLoginActionUrl];
    }
    else if (afterLoginAction == AfterLoginActionStatusAddWishList) {
        [self requestItemWishList:nil requestUrl:afterLoginActionUrl];
    }
    else if (afterLoginAction == AfterLoginActionStatusQnaWrite) {
        [self CPProductInfoUserQnAView:nil openWriteQna:afterLoginActionUrl];
    }
    else if (afterLoginAction == AfterLoginActionStatusMyCoupon) {
        [self openPopupBrowser:@{@"title": @"쿠폰 변경", @"url": afterLoginActionUrl, @"key": @"coupon"} isOptionDrawer:NO];
    }

    afterLoginActionUrl = nil;
    afterLoginAction = AfterLoginActionStatusNone;
}

- (void)popupviewControllerDidAdultClosed
{
    [UIAlertView showWithTitle:STR_APP_TITLE
                       message:@"성인인증이 취소되었습니다."
             cancelButtonTitle:@"확인"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          [self didTouchBackButton];
                      }];
}

- (void)popupviewControllerDidAdultSuccessLogin:(BOOL)successYn
{
    if (successYn) {
        [self getProductData];
    }
    else {
        [UIAlertView showWithTitle:STR_APP_TITLE
                           message:@"성인인증이 취소되었습니다."
                 cancelButtonTitle:@"확인"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [self didTouchBackButton];
                          }];
    }
}

#pragma mark - CPProductWebViewDelegate - 웹뷰

- (void)didSelectedOptions:(NSArray *)selectedOptions
{
    drawerView.myCoupons = [NSMutableArray arrayWithArray:selectedOptions];
    [drawerView localizedCouponDiscountPrice];
}

- (void)productWebViewOpenUrlScheme:(NSString *)urlScheme
{
    if (urlScheme) {
        urlScheme = [urlScheme stringByReplacingOccurrencesOfString:@"app://popupBrowser/close/" withString:@""];
        
        SBJSON *json = [[SBJSON alloc] init];
        
        NSDictionary *props = [json objectWithString:URLDecode(urlScheme)];
        
        NSString *type = [props objectForKey:@"pType"];
        NSString *action = [props objectForKey:@"pAction"];
        
        if ([@"url" isEqualToString:type]) {
            if (action) {
                [self openWebViewControllerWithUrl:action animated:NO];
            }
        }
        
        if (currentItemIndex == TabViewTypeQA) {
            currentType = TabViewTypeQA;
            [productInfoQnAView reloadView];
        }
    }
}

- (void)didTouchWebViewClose
{
//    if (drawerView.isDrawerOpen) {
//        [drawerView closeDrawer];
//    }
    
    productWebView = nil;
}

#pragma mark - CPShockingDealBenefitViewDelegate

- (void)didTouchShockDealButton
{
    [self touchShockingdealButton:productNumber];
}

#pragma mark - CPProductBannerViewDelegate

- (void)didTouchLineBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - CPLikePopupViewDelegate

- (void)likeStatusPopupView:(CPLikePopupView *)view didClickedButton:(NSNumber *)buttonType
{
    
}

#pragma mark - CPProductLikeViewDelegate

- (void)didTouchLikeButton
{
    if ([Modules checkLoginFromCookie]) {
        [self setProductLike];
    }
    else {
        afterLoginAction = AfterLoginActionStatusLike;
//        [self openLoginView:@"" isAdult:NO];
        [self openLoginViewControllerWithAdult:NO];
    }
}

- (void)didTouchGiftButton
{
    if (![self verifyPressedProductButtons:NO]) {
        return;
    }
    
    if (productPrdPromotionView && productPrdPromotionView.selectedIndex < 0) {
        [drawerView setIsPrdPromotionAlert:YES];
    }
    else {
        [drawerView setIsPrdPromotionAlert:NO];
    }
    
    //방문수령을 선택한 경우
    if ([productDeliveryView isVisitDlvChecked]) {
        DEFAULT_ALERT(STR_APP_TITLE, @"방문수령을 선택한 상품은 선물하기를 할 수 없습니다.");
        return;
    }
    
    [drawerView setOptionType:openOptionTypeGift];
    [drawerView validateOpenDrawer:YES];
}

- (BOOL)isVisitDlvChecked
{
    return [productDeliveryView isVisitDlvChecked];
}

- (void)didTouchShareButton
{
    NSString *appScheme = [NSString stringWithFormat:@"elevenst://goproduct?prdNo=%@", productNumber];

    NSString *productUrl = PRODUCT_DETAIL_WEB_URL;
    productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
//    sharePopupView = [[CPSharePopupView alloc] initWithFrame:CGRectMake(13.5f, 0, kScreenBoundsWidth-27, 260) product:productInfo];
    sharePopupView = [[CPSharePopupView alloc] initWithFrame:self.view.bounds product:productInfo];
    [sharePopupView setDelegate:self];
    [sharePopupView setShareTitle:productInfo[@"prdNm"]];
    [sharePopupView setShareUrl:productUrl];
    [sharePopupView setShareAppScheme:appScheme];
    [self.view addSubview:sharePopupView];
//    [sharePopupView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [self.view bringSubviewToFront:sharePopupView];
}

#pragma mark - CPSharePopupViewDelegate

- (void)didTouchSMSButton
{
    NSString *productUrl = PRODUCT_DETAIL_WEB_URL;
    productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.body = [NSString stringWithFormat:@"%@\n%@", productInfo[@"prdNm"], productUrl];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didTouchFacebookButton
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *productUrl = PRODUCT_DETAIL_WEB_URL;
        productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
        
        [facebookSheet setInitialText:productInfo[@"prdNm"]];
        [facebookSheet addURL:[NSURL URLWithString:productUrl]];
        
        [self presentViewController:facebookSheet animated:YES completion:nil];
    }
    else {
        DEFAULT_ALERT(@"공유하기", @"설정에서 페이스북 로그인 후 이용해주세요.");
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate - SMS전송

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            DEFAULT_ALERT(@"공유하기", @"SMS 전송실패");
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPProductPriceViewViewDelegate

- (void)didTouchReviewButton
{
    [self didTouchTabMove:TabViewTypeReviewPost];
    
    [mainScrollView setContentOffset:CGPointMake(CGRectGetMinX(tabMenuView.frame), CGRectGetMinY(tabMenuView.frame))];
}

#pragma mark - CPProductDiscountViewDelegate - 펼치기

- (void)didTouchExpandButton:(CPProductViewType)viewType height:(CGFloat)height
{
    //더보기가 있는 뷰
    if (viewType == CPProductViewTypePrice) {
        [productPriceView setFrame:CGRectMake(10, CGRectGetMaxY(productBadgeView.frame)+8, kScreenBoundsWidth-20, CGRectGetHeight(productPriceView.frame)+height)];
        [myDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(productPriceView.frame), kScreenBoundsWidth, CGRectGetHeight(myDiscountView.frame))];
        [productDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(myDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productDiscountView.frame))];
        [productBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productBenefitView.frame))];
        [productSellPeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productSellPeriodView.frame))];
        [productUsePeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productUsePeriodView.frame))];
        [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
        [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    }
    else if (viewType == CPProductViewTypeMyDiscount) {
        [myDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(productPriceView.frame), kScreenBoundsWidth, height)];
        [productDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(myDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productDiscountView.frame))];
        [productBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productBenefitView.frame))];
        [productSellPeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productSellPeriodView.frame))];
        [productUsePeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productUsePeriodView.frame))];
        [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
        [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    }
    else if (viewType == CPProductViewTypeAddDisount) {
        [productDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(myDiscountView.frame), kScreenBoundsWidth, height)];
        [productBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productBenefitView.frame))];
        [productSellPeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productSellPeriodView.frame))];
        [productUsePeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productUsePeriodView.frame))];
        [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
        [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    }
    else if (viewType == CPProductViewTypeBenefit) {
        [productBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, height)];
        [productSellPeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productSellPeriodView.frame))];
        [productUsePeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productUsePeriodView.frame))];
        [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
        [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    }
    else if (viewType == CPProductViewTypeDelivery) {
        [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, height)];
        [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    }
    
    //더보기 없는 뷰
    [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
    [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    [shockingDealBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productPrdPromotionView.frame), kScreenBoundsWidth, CGRectGetHeight(shockingDealBenefitView.frame))];
    [productLikeView setFrame:CGRectMake(0, CGRectGetMaxY(shockingDealBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productLikeView.frame))];
    [bookSeriesView setFrame:CGRectMake(0, CGRectGetMaxY(productLikeView.frame), kScreenBoundsWidth, CGRectGetHeight(bookSeriesView.frame))];
    [productBannerView setFrame:CGRectMake(0, CGRectGetMaxY(bookSeriesView.frame), kScreenBoundsWidth, CGRectGetHeight(productBannerView.frame))];
    
    //탭메뉴
    defaultInfoHeight = CGRectGetMaxY(productBannerView.frame);
    
    [tabMenuView setFrame:CGRectMake(0, defaultInfoHeight, CGRectGetWidth(mainScrollView.frame), 49)];
    [tabScrollView setFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame), CGRectGetWidth(mainScrollView.frame), CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))];
    
    //뷰 위치 이동 후 탭정보 초기화 문제
    [self didTouchTabMenuButton:currentItemIndex];
}

- (void)viewReSetting
{
    [productBadgeView setFrame:CGRectMake(10, CGRectGetMaxY(productThumbnailView.frame)+8, CGRectGetWidth(mainScrollView.frame)-20, 20)];
    [productPriceView setFrame:CGRectMake(10, CGRectGetMaxY(productBadgeView.frame)+6, kScreenBoundsWidth-20, CGRectGetHeight(productPriceView.frame))];
    [myDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(productPriceView.frame), kScreenBoundsWidth, CGRectGetHeight(myDiscountView.frame))];
    [productDiscountView setFrame:CGRectMake(0, CGRectGetMaxY(myDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productDiscountView.frame))];
    [productBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productDiscountView.frame), kScreenBoundsWidth, CGRectGetHeight(productBenefitView.frame))];
    [productSellPeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productSellPeriodView.frame))];
    [productUsePeriodView setFrame:CGRectMake(0, CGRectGetMaxY(productSellPeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productUsePeriodView.frame))];
    [productDeliveryView setFrame:CGRectMake(0, CGRectGetMaxY(productUsePeriodView.frame), kScreenBoundsWidth, CGRectGetHeight(productDeliveryView.frame))];
    [productPrdPromotionView setFrame:CGRectMake(0, CGRectGetMaxY(productDeliveryView.frame), kScreenBoundsWidth, CGRectGetHeight(productPrdPromotionView.frame))];
    [shockingDealBenefitView setFrame:CGRectMake(0, CGRectGetMaxY(productPrdPromotionView.frame), kScreenBoundsWidth, CGRectGetHeight(shockingDealBenefitView.frame))];
    [productLikeView setFrame:CGRectMake(0, CGRectGetMaxY(shockingDealBenefitView.frame), kScreenBoundsWidth, CGRectGetHeight(productLikeView.frame))];
    [bookSeriesView setFrame:CGRectMake(0, CGRectGetMaxY(productLikeView.frame), kScreenBoundsWidth, CGRectGetHeight(bookSeriesView.frame))];
    [productBannerView setFrame:CGRectMake(0, CGRectGetMaxY(bookSeriesView.frame), kScreenBoundsWidth, CGRectGetHeight(productBannerView.frame))];
    
    //탭메뉴
    defaultInfoHeight = CGRectGetMaxY(productBannerView.frame);
    
    [tabMenuView setFrame:CGRectMake(0, defaultInfoHeight, CGRectGetWidth(mainScrollView.frame), 49)];
    [tabScrollView setFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame), CGRectGetWidth(mainScrollView.frame), CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))];
    
    //뷰 위치 이동 후 탭정보 초기화 문제
    [self didTouchTabMenuButton:currentItemIndex];
}

- (void)didTouchSaleInfoButton:(NSString *)linkUrl title:(NSString *)title
{
    [self openLayerPopup:title linkUrl:linkUrl];
}

- (void)didTouchHelpInfoButton:(NSString *)linkUrl title:(NSString *)title
{
    [self openLayerPopup:title linkUrl:linkUrl];
}

- (void)didTouchLinkButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:NO];
}

#pragma mark - CPProductBenefitViewDelegate

- (void)didTouchBenefitInfoButton:(NSString *)url
{
    [self didTouchBenefitInfoButton:url helpTitle:@""];
}

- (void)didTouchBenefitInfoButton:(NSString *)url helpTitle:(NSString *)helpTitle
{
    [self openLayerPopup:helpTitle?helpTitle:@"혜택" linkUrl:url];
}

- (void)didTouchBenefitLinkButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:NO];
}

- (void)didTouchEventLinkButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:NO];
}

#pragma mark - CPProductThumbnailViewViewDelegate

- (void)didTouchPreviewButton:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"미리보기", @"url": url, @"key": @"preview"} isOptionDrawer:NO];
}

#pragma mark - CPBookSeriesViewDelegate

- (void)didTouchSeriesDetailButton:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"시리즈 상품정보", @"url": url, @"key": @"series"} isOptionDrawer:NO];
}

#pragma mark - CPProductDeliveryViewDelegate - 배송

- (void)didTouchVisitDlvLink:(NSString *)linkUrl
{
    [self openPopupBrowser:@{@"title": @"위치보기", @"url": linkUrl, @"key": @"delivery"} isOptionDrawer:NO];
}

- (void)didTouchTextIconButton:(NSString *)linkUrl helpTitle:(NSString *)helpTitle
{
    [self openLayerPopup:helpTitle linkUrl:linkUrl];
}

- (void)didTouchDlvCstPayCheckButton:(BOOL)isCheck
{
    //상품수령시 결제(착불) 체크여부 - 구매하기할때 정보를 넘겨야한다
    drawerView.isDlvCstPayChecked = isCheck;
    isDlvCstPayCheck = isCheck;
}

- (void)didTouchVisitDlvCheckButton:(BOOL)isCheck
{
    //방문수령 체크여부 - 구매하기할때 정보를 넘겨야한다
    drawerView.isVisitDlvChecked = isCheck;
    isVisitDlvCheck = isCheck;
}

#pragma mark - CPProductTabMenuViewDelegate

- (void)didTouchTabMenuButton:(NSInteger)selectedIndex
{
    currentItemIndex = selectedIndex;
    
    switch (selectedIndex) {
        case TabViewTypePrdInfo:
            currentType = TabViewTypePrdInfo;
            break;
        case TabViewTypeReviewPost:
            if (!productInfoFeedbackView) {
                //리뷰/후기 탭
                productInfoFeedbackView = [[CPProductInfoUserFeedbackView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame),
                                                                                                          0,
                                                                                                          CGRectGetWidth(mainScrollView.frame),
                                                                                                          CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))
                                                                                         items:productInfo
                                                                                         prdNo:productNumber];
                [productInfoFeedbackView setDelegate:self];
                [tabScrollView addSubview:productInfoFeedbackView];
                [tabScrollView bringSubviewToFront:topButton];
                [self setMainScrollViewEnable:YES];
            }
            else {
                if (!isMovePost) {
                    [productInfoFeedbackView reloadView];
                }
            }
            
            currentType = TabViewTypeReviewPost;
            isMovePost = NO;
            break;
        case TabViewTypeQA:
            if (!productInfoQnAView) {
                //Q&A 탭
                productInfoQnAView = [[CPProductInfoUserQnAView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame)*2,
                                                                                                0,
                                                                                                CGRectGetWidth(mainScrollView.frame),
                                                                                                CGRectGetHeight(mainScrollView.frame)-CGRectGetHeight(tabMenuView.frame)-(bottomView?50:0))
                                                                               items:productInfo
                                                                               prdNo:productNumber];
                [productInfoQnAView setDelegate:self];
                [tabScrollView addSubview:productInfoQnAView];
                [tabScrollView bringSubviewToFront:topButton];
                [self setMainScrollViewEnable:YES];
            }
            else {
                [productInfoQnAView reloadView];
            }
            
            currentType = TabViewTypeQA;
            break;
        case TabViewTypeExchange:
        {
            if (!productExchangeView) {
                //반품/교환 탭
                productExchangeView = [[CPProductExchangeView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainScrollView.frame)*3, 0,
                                                                                              tabScrollView.frame.size.width,
                                                                                              tabScrollView.frame.size.height)];
                productExchangeView.delegate = self;
                [tabScrollView addSubview:productExchangeView];
                [self setMainScrollViewEnable:YES];
            }
            currentType = TabViewTypeExchange;
            
            NSString *url = productInfo[@"buyInfoLinkUrl"];
            url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
            [productExchangeView openUrl:url];
            [tabScrollView bringSubviewToFront:topButton];
        }
            break;
    }
    
    //하단 side버튼 이동
    [self moveSideButton:selectedIndex];
    
    [tabScrollView setContentOffset:CGPointMake(CGRectGetWidth(tabScrollView.frame)*selectedIndex, 0)];
}

#pragma mark - CPProductDescriptionViewDelegate

- (void)productDescriptionView:(CPProductDescriptionView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

- (void)didTouchSearchKeyword:(NSString *)linkUrl
{
    if (linkUrl) {
        if ([linkUrl hasPrefix:@"app://gosearch/"]) {
            linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
            linkUrl = [linkUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }

        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:linkUrl keyword:@"" referrer:tempUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)didTouchMapButton:(NSString *)linkUrl
{
    [self openPopupBrowser:@{@"title": @"지점정보", @"url": linkUrl, @"key": @"map"} isOptionDrawer:NO];
}

- (void)didTouchPrdSelInfo:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"상품판매 일반정보", @"url": url, @"key": @"selInfo"} isOptionDrawer:NO];
}

- (void)didTouchProInfoNotice:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"상품정보 제공고시", @"url": url, @"key": @"notice"} isOptionDrawer:NO];
}

- (void)didTouchInfoButton:(NSString *)url
{
    [self openLayerPopup:@"판매자정보" linkUrl:url];
}

- (void)didTouchSellerInfo:(NSString *)url
{
    [self openWebViewControllerWithUrl:[url trim] animated:NO];
}

- (void)didTouchShowPrdAll:(NSString *)url
{
    [self openWebViewControllerWithUrl:[url trim] animated:NO];
}

- (void)didTouchSellerPrd:(NSString *)prdNo
{
    CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type
{
    switch (type) {
        case CPSellerPrdListTypeMiniMall:
            [self openWebViewControllerWithUrl:[moreUrl trim] animated:YES];
            break;
        case CPSellerPrdListTypeCategoryPopular:
        {
            //리프 카테고리로 이동
            CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:moreUrl keyword:nil referrer:tempUrl];
            [self.navigationController pushViewController:viewConroller animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didTouchReviewCell:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"리뷰", @"url": url, @"key": @"review"} isOptionDrawer:NO];
}

- (void)didTouchCategoryArea:(NSString *)url
{
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:url keyword:nil referrer:tempUrl];
    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)didTouchAddDeliveryAddress:(NSString *)linkUrl
{
    NSString *productUrl = PRODUCT_DETAIL_WEB_URL;
    productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:productNumber];
    productUrl = [Modules encodeAddingPercentEscapeString:productUrl];
    
    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"&afterRedirectUrl=" withString:[NSString stringWithFormat:@"&afterRedirectUrl=%@", productUrl]];
    
    [self openWebViewControllerWithUrl:[linkUrl trim] isPop:NO isIgnore:NO isProduct:YES];
}

- (void)didTouchBrandShop:(NSString *)linkUrl;
{
    [self openWebViewControllerWithUrl:[linkUrl trim] animated:NO];
}

- (void)touchDeliveryListButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == productDeliveryView.selectedIndex) {
        [self removeDeliveryListView];
        return;
    }
    
    productDeliveryView.selectedIndex = button.tag;
    [productDeliveryView setDeliveryAddressView];
    
    [self removeDeliveryListView];
}

- (void)touchShopListButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == productDeliveryView.selectedShopIndex) {
        [self removeShopListView];
        return;
    }
    
    productDeliveryView.selectedShopIndex = button.tag;
    [productDeliveryView setShopAddressView];
    
    [self removeShopListView];
}

- (void)touchPromotionListButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    productPrdPromotionView.selectedIndex = button.tag;
    [productPrdPromotionView setPromotionView];
    
    //서랍옵션에 덤상품 넘겨줌
    [drawerView setMartPromotionDictionary:productInfo[@"prdPromotion"][@"promotionLayer"][button.tag]];
    
    [self removePromotionListView];
}

- (void)didTouchSellerNotice:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"판매자공지", @"url": url, @"key": @"sellerNotice"} isOptionDrawer:NO];
}

- (void)drawLayerDeliveryList:(id)sender listInfo:(NSDictionary *)listInfo
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat listViewY = productDeliveryView.frame.origin.y+[productDeliveryView getListButtonY];
    NSArray *deliveryList = listInfo[@"dlvAddrList"];
    
    if (deliveryListView) {
        [self removeDeliveryListView];
        return;
    }
    
    if (deliveryList && deliveryList.count > 0) {
    
        //배송지 목록
        deliveryListView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x, listViewY, button.frame.size.width, deliveryList.count*32+2)];
        [mainScrollView addSubview:deliveryListView];
        
        CGFloat cellHeight = 1;
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:backImage];
        [bgImageView setFrame:CGRectMake(0, 0, button.frame.size.width, deliveryList.count*32+2)];
        [deliveryListView addSubview:bgImageView];
        
        for (NSDictionary *dic in deliveryList) {
            
            UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [listButton setFrame:CGRectMake(1, cellHeight, button.frame.size.width-2, 32)];
            [listButton setTitle:dic[@"addrNm"] forState:UIControlStateNormal];
            [listButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [listButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [listButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [listButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [listButton addTarget:self action:@selector(touchDeliveryListButton:) forControlEvents:UIControlEventTouchUpInside];
            [listButton setTag:[deliveryList indexOfObject:dic]];
            [deliveryListView addSubview:listButton];
            
            //selected
            if (button.tag == [deliveryList indexOfObject:dic]) {
                [listButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [listButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
            }
            else {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(listButton.frame)-1, button.frame.size.width-2, 1)];
                [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
                [deliveryListView addSubview:lineView];
            }
            
            cellHeight += 32;
        }
    }
}

- (void)drawLayerShopList:(id)sender listInfo:(NSArray *)listInfo
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat listViewY = productDeliveryView.frame.origin.y+[productDeliveryView getShopListButtonY];
    NSArray *shopList = listInfo;
    
    if (shopListView) {
        [self removeShopListView];
        return;
    }
    
    if (shopList && shopList.count > 0) {
        
        //배송점 목록
        shopListView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x, listViewY, button.frame.size.width, shopList.count*32+2)];
        [mainScrollView addSubview:shopListView];
        
        CGFloat cellHeight = 1;
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:backImage];
        [bgImageView setFrame:CGRectMake(0, 0, button.frame.size.width, shopList.count*32+2)];
        [shopListView addSubview:bgImageView];
        
        for (NSDictionary *dic in shopList) {
            
            UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [listButton setFrame:CGRectMake(1, cellHeight, button.frame.size.width-2, 32)];
            [listButton setTitle:dic[@"strNm"] forState:UIControlStateNormal];
            [listButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [listButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [listButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [listButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [listButton addTarget:self action:@selector(touchShopListButton:) forControlEvents:UIControlEventTouchUpInside];
            [listButton setTag:[shopList indexOfObject:dic]];
            [shopListView addSubview:listButton];
            
            //selected
            if (productDeliveryView.selectedShopIndex == [shopList indexOfObject:dic]) {
                [listButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [listButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
            }
            else {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(listButton.frame)-1, button.frame.size.width-2, 1)];
                [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
                [shopListView addSubview:lineView];
            }
            
            cellHeight += 32;
        }
    }
}

#pragma mark - CPProductDescriptionViewDelegate - 스마트옵션

- (void)smartOptionDidClickedOptionDetailAtUrl:(NSString *)url
{
    [self openPopupBrowser:@{@"title": @"자세히보기", @"url": url, @"key": @"smartOption"} isOptionDrawer:YES];
}

- (void)smartOptionDidClickedOptionSelectButtonAtOptionName:(NSString *)optionName
{
    if (![@"Y" isEqualToString:productInfo[@"optDrawerYn"]]) {
        DEFAULT_ALERT(@"알림", @"해당 옵션은 품절등의 사유로 선택이 불가합니다");
        return;
    }
    
    [drawerView addOptionByName:optionName];
}

#pragma mark - CPProductPrdPromotionViewDelegate

- (void)drawLayerPrdPromotionList:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat listViewY = productPrdPromotionView.frame.origin.y+button.frame.origin.y+32;
    NSArray *promotionList = productInfo[@"prdPromotion"][@"promotionLayer"];
    
    if (promotionListView) {
        [self removePromotionListView];
        return;
    }
    
    if (promotionList && promotionList.count > 0) {
        
        //배송지 목록
        promotionListView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x, listViewY, button.frame.size.width, promotionList.count*32+2)];
        [mainScrollView addSubview:promotionListView];
        
        CGFloat cellHeight = 1;
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:backImage];
        [bgImageView setFrame:CGRectMake(0, 0, button.frame.size.width, promotionList.count*32+2)];
        [promotionListView addSubview:bgImageView];
        
        for (NSDictionary *dic in promotionList) {
            
            UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [listButton setFrame:CGRectMake(1, cellHeight, button.frame.size.width-2, 32)];
            [listButton setTitle:dic[@"martPrmtNm"] forState:UIControlStateNormal];
            [listButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [listButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [listButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [listButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [listButton addTarget:self action:@selector(touchPromotionListButton:) forControlEvents:UIControlEventTouchUpInside];
            [listButton setTag:[promotionList indexOfObject:dic]];
            [promotionListView addSubview:listButton];
            
            //selected
            if (productPrdPromotionView.selectedIndex == [promotionList indexOfObject:dic]) {
                [listButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [listButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
            }
            else {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(listButton.frame)-1, button.frame.size.width-2, 1)];
                [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
                [promotionListView addSubview:lineView];
            }
            
            cellHeight += 32;
        }
    }
}

#pragma mark - CPProductInfoUserFeedbackViewDelegate

- (void)productInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

- (void)productInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view openUrl:(NSString *)url
{
//    WebViewController *controller = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:[url trim]]];
//    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - CPProductInfoUserQnAViewDelegate

- (void)CPProductInfoUserQnAView:(CPProductInfoUserQnAView *)view openWriteQna:(NSString *)url
{
    if ([Modules checkLoginFromCookie]) {
        isQnaWrite = YES;

        [self openWebViewControllerWithUrl:[url trim] animated:YES];
//        WebViewController *controller = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:[url trim]]];
//        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        afterLoginAction = AfterLoginActionStatusQnaWrite;
        afterLoginActionUrl = url;
//        [self openLoginView:@"" isAdult:NO];
        [self openLoginViewControllerWithAdult:NO];
    }
}

- (void)productInfoUserQnAView:(CPProductInfoUserQnAView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

- (void)didTouchWriteButton:(NSString *)url
{
    if ([Modules checkLoginFromCookie]) {
        isQnaWrite = YES;
        [self openPopupBrowser:@{@"title": @"Q&A쓰기", @"url": url, @"key": @"qnaWrite"} isOptionDrawer:NO];
    }
    else {
        [self openLoginViewControllerWithAdult:NO];
    }
}

#pragma mark - CPProductInfoSmartOptionViewDelegate

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view didClickedOptionDetailButton:(ProductSmartOptionModel *)option
{
    if (option) {
//        [self popupSmartOptionDetail:option];
    }
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view didClickedOptionSelectButton:(ProductSmartOptionModel *)option
{
    if (option) {
//        [self addOptionToCart:option];
    }
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveMorePage:(NSString *)typeStr
{
    tabScrollView.delegate = nil;
    
    if ([typeStr isEqualToString:@"REVIEW"]) {
        [tabScrollView setContentOffset:CGPointMake(tabScrollView.frame.size.width * 1, 0) animated:NO];
//        [tabScrollView setSelectedIdx:1];
//        [self onClickProductInfoTab:1 pageNo:0];
    }
    else if ([typeStr isEqualToString:@"POST"]) {
//        [_productInfoScrollView setContentOffset:CGPointMake(_productInfoScrollView.frame.size.width * 1, 0) animated:NO];
//        [_productInfoTabView setSelectedIdx:1];
//        [self onClickProductInfoTab:1 pageNo:1];
    }
    else if ([typeStr isEqualToString:@"RECOMMEND"]) {
//        [_productInfoScrollView setContentOffset:CGPointMake(_productInfoScrollView.frame.size.width * 2, 0) animated:NO];
//        [_productInfoTabView setSelectedIdx:2];
//        [self onClickProductInfoTab:2 pageNo:0];
    }
    
    tabScrollView.delegate = self;
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveUrl:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
//    CPWebViewController *controller = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:[url trim]]];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveProductDetailController:(NSString *)prdNo
{
    CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveProductDetailControllerWithDict:(NSDictionary *)prdDict
{
//    CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdDict[@"prdNo"]
//                                                                                                trTypeCd:prdDict[@"trTypeCd"]];
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - ProductInfoWebview Delegate Method
- (void)productExchangeView:(CPProductExchangeView *)view isLoading:(NSNumber *)loading
{
    BOOL isLoading = [loading boolValue];
    
    if (isLoading)	[self startLoadingAnimation];
    else			[self stopLoadingAnimation];
}

- (void)productExchangeView:(CPProductExchangeView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

#pragma mark - CPDescriptionBottomTownShopBranch Delegate Method
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view isLoading:(NSNumber *)loading
{
    BOOL isLoading = [loading boolValue];
    
    if (isLoading)	[self startLoadingAnimation];
    else			[self stopLoadingAnimation];
}

- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self removeDeliveryListView];
    [self removePromotionListView];
    
    NSInteger contentOffset = scrollView.contentOffset.y;
//    // 스크롤뷰가 바운스되는 경우는 상황에서 제외
//    if (contentOffset < 0 || contentOffset > scrollView.contentSize.height - scrollView.frame.size.height) {
//        return;
//    }
//    
    static NSInteger lastContentOffset = 0;
    static BOOL isScrollingToUp = NO;
    if (lastContentOffset > contentOffset) {
        if (YES == isScrollingToUp) {
        }
        isScrollingToUp = NO;
    } else if (lastContentOffset < contentOffset) {
        if (NO == isScrollingToUp) {
        }
        isScrollingToUp = YES;
    }
    
    lastContentOffset = scrollView.contentOffset.y;
    
    if ([scrollView isEqual:mainScrollView]) {
//        NSLog(@"mainScrollView : %f", scrollView.contentOffset.y);
        
        CGFloat limitY = defaultInfoHeight;
        
        if (scrollView.contentOffset.y > limitY) {
            [scrollView setContentOffset:CGPointMake(0, limitY) animated:NO];
            [self setMainScrollViewEnable:NO];
        }
    }
    else if ([scrollView isEqual:tabScrollView]) {
//        NSLog(@"tabScrollView : %f, %@", scrollView.contentOffset.y, isScrollingToUp?@"y":@"n");
        
        
        
//        if (scrollView.contentOffset.y == 0 ) {//&& NO == isScrollingToUp) {
//            NSLog(@"NO == isScrollingToUp");
//            [self setMainScrollViewEnable:YES];
//        }
//        [self setMainScrollViewEnable:NO];
//        CGFloat pageWidth = scrollView.frame.size.width;
//        NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1;
        
//        if (page != [tabMenuView getSelectedIdx]) {
//            [_productInfoTabView setSelectedIdx:page];
//            [self onClickProductInfoTab:page pageNo:-1];
//        }
    }
    else {
//        NSLog(@"in tab ScrollView : %f", scrollView.contentOffset.y);
        if (scrollView.contentOffset.y < 0) {
            [self setMainScrollViewEnable:YES];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

- (void)setMainScrollViewEnable:(BOOL)isEnable
{
    [mainScrollView setScrollEnabled:isEnable];
    [mainScrollView setShowsHorizontalScrollIndicator:NO];
    [mainScrollView setShowsVerticalScrollIndicator:isEnable];
    
    [tabScrollView setScrollEnabled:!isEnable];
    [tabScrollView setShowsVerticalScrollIndicator:NO];
    [tabScrollView setShowsHorizontalScrollIndicator:!isEnable];
    
    if (descriptionView) {
        [descriptionView setScrollEnabled:!isEnable];
        [descriptionView setShowsHorizontalScrollIndicator:NO];
        [descriptionView setShowsVerticalScrollIndicator:!isEnable];
    }
    
    if (productInfoSmartOptionView)
    {
        [productInfoSmartOptionView setScrollEnabled:!isEnable];
        [productInfoSmartOptionView setShowsHorizontalScrollIndicator:NO];
        [productInfoSmartOptionView setShowsVerticalScrollIndicator:!isEnable];
    }
    
    [productInfoFeedbackView setScrollEnabled:!isEnable];
    [productInfoFeedbackView setShowsHorizontalScrollIndicator:NO];
    [productInfoFeedbackView setShowsVerticalScrollIndicator:!isEnable];

    [productInfoQnAView setScrollEnabled:!isEnable];
    [productInfoQnAView setShowsHorizontalScrollIndicator:NO];
    [productInfoQnAView setShowsVerticalScrollIndicator:!isEnable];
    
    [productExchangeView setScrollEnabled:!isEnable];
    [productExchangeView setShowsHorizontalScrollIndicator:NO];
    [productExchangeView setShowsVerticalScrollIndicator:!isEnable];
}

#pragma mark - CPErrorViewDelegate

- (void)didTouchRetryButton
{
    [errorView removeFromSuperview];
    
    [self performSelectorInBackground:@selector(getProductData) withObject:nil];
}

#pragma mark - CPBannerManagerDelegate

- (void)didTouchBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - Tutorials

- (void)makeSmartOptionTutorialView
{
    tutorialView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    tutorialView.backgroundColor = UIColorFromRGBA(0x000000, 0.8f);
    [self.navigationController.view addSubview:tutorialView];
    
    //워크스루에서 코치마크로 변경
    UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tutorialButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    [tutorialButton setBackgroundColor:[UIColor clearColor]];
    [tutorialButton setImage:[UIImage imageNamed:@"coachmark.png"] forState:UIControlStateNormal];
    [tutorialButton addTarget:self action:@selector(tutorialClose:) forControlEvents:UIControlEventTouchUpInside];
    [tutorialView addSubview:tutorialButton];
}

- (void)makeCouponTutorialView
{
    tutorialView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    tutorialView.backgroundColor = UIColorFromRGBA(0x000000, 0.8f);
    [self.navigationController.view addSubview:tutorialView];
    
    //워크스루에서 코치마크로 변경
    UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tutorialButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    [tutorialButton setBackgroundColor:[UIColor clearColor]];
    [tutorialButton setImage:[UIImage imageNamed:@"product_coupon_tutorial.png"] forState:UIControlStateNormal];
    [tutorialButton addTarget:self action:@selector(tutorialClose:) forControlEvents:UIControlEventTouchUpInside];
    [tutorialView addSubview:tutorialButton];
}

- (void)tutorialClose:(id)sender
{
    [tutorialView removeFromSuperview];
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self.view insertSubview:loadingView aboveSubview:self.view];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
