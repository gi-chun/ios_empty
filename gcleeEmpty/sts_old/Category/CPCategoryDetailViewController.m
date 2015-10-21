//
//  CPCategoryDetailViewController.m
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCategoryDetailViewController.h"
#import "CPProductListViewController.h"
#import "CPSearchViewController.h"
#import "CPWebViewController.h"
#import "CPSnapshotListViewController.h"
#import "SetupController.h"
#import "CPProductViewController.h"

#import "CPToolBarView.h"
#import "CPNavigationBarView.h"
#import "CPLoadingView.h"
#import "CPFooterView.h"
#import "CPErrorView.h"
#import "CPBannerView.h"
#import "CPThumbnailView.h"
#import "CPCollectionData.h"
#import "CPCollectionViewFlowLayout.h"
#import "CPCollectionViewCommonCell.h"

#import "CPHomeViewController.h"
#import "CPBannerManager.h"
#import "CPRESTClient.h"
#import "CPCommonInfo.h"
#import "Modules.h"
#import "RegexKitLite.h"
#import "AccessLog.h"
#import "SBJSON.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+WebCache.h"

#define SEARCHVIEW_TAG          500
#define PRODUCT_ITEMS_TAG       1000
#define HEADER_CELL_TAG         800

#define HEADER_HEIGHT           36
#define FOOTER_HEIGHT           118
#define CATEGORY_CELL_HEIGHT    46

#define CATEGORY_VIEW_EXIST     55
#define CATEGORY_VIEW_NONE      56

typedef NS_ENUM(NSUInteger, CPButtonType){
    CPButtonTypeItem = 0,           //Item
    CPButtonTypeBrand               //Brand
};

@interface CPCategoryDetailViewController ()<CPToolBarViewDelegate,
                                            CPNavigationBarViewDelegate,
                                            CPErrorViewDelegate,
                                            CPFooterViewDelegate,
                                            CPSearchViewControllerDelegate,
                                            CPBannerManagerDelegate,
                                            CPBannerViewDelegate,
                                            SetupControllerDelegate,
                                            CPCollectionViewCommonCellDelegate,
                                            UITextFieldDelegate,
                                            UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UIScrollViewDelegate>
{
    NSString *categoryUrl;
    
    UICollectionView *categoryCollectionView;
    CPCollectionViewFlowLayout *categoryLayout;
    CPCollectionData *collectionData;
    
    CPLoadingView *loadingView;
    CPErrorView *errorView;
    
    //footerView
    CPFooterView *cpFooterView;
    CGFloat footerHeight;
    
    //categoryView
    UIView *categoryView;
    UIView *categoryHeaderView;
    UIView *categoryCellView;
    UIView *shadowView;
    UIView *itemBrandView;
    UIButton *iconButton;
    UITextField *searchTextField;
    UIButton *rightSearchButton;
    
    //category searchView
    UIView *searchView;
    BOOL isShowSearchView;
    BOOL isSearchViewClick;
    
    //JSON API 정보
    NSMutableDictionary *categoryTreeInfo;
    NSMutableDictionary *noData;
    NSMutableDictionary *lineBannerInfo;
    NSMutableArray *productDispTrcCdInfo;
    NSMutableArray *adDispTrcUrlInfo;
    
    //네크웤 다시시도 & 툴바 리프레쉬를 위한 url임시저장
    NSString *currentUrl;
    
    CPToolBarView *toolBarView;
    UIView *mdnBannerView;;
    CPBannerView *lineBannerView;
    
    //IOS6, IOS7 bug를 위해 임시 저장
    UICollectionReusableView *saveHeaderView;
    UICollectionReusableView *saveFooterView;
    
    CPNavigationBarView *navigationBarView;
    
    CGFloat ctgrHeight;
    CGFloat headerViewHeight;
    CGFloat cellViewHeight;
}

@end

@implementation CPCategoryDetailViewController

- (id)initWithUrl:(NSString *)aUrl
{
    if (self = [super init]) {
        categoryUrl = aUrl;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];
    
    // data init
    [self initData];
    
    // Layout
    [self initLayout];
    
    // API
    [self getCategoryDetailData:categoryUrl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];
    
    //네비게이션바가 없어진 상태라면 복구시킨다.
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [toolBarView setHiddenPopover:YES];
    
    [[CPBannerManager sharedManager] removeBannerView];
}

-  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewControllerNotification object:nil];
    
    categoryCollectionView.delegate = nil;
    categoryCollectionView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData
{
    categoryTreeInfo = [NSMutableDictionary dictionary];
    noData = [NSMutableDictionary dictionary];
    lineBannerInfo = [NSMutableDictionary dictionary];
    collectionData = [[CPCollectionData alloc] init];
    productDispTrcCdInfo = [NSMutableArray array];
    adDispTrcUrlInfo = [NSMutableArray array];
}

- (void)initLayout
{
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setParentViewController:self];
    
    searchView = [[UIView alloc] init];
    [searchView setTag:SEARCHVIEW_TAG];
    isShowSearchView = NO;
    isSearchViewClick = YES;
    
    categoryView = [[UIView alloc] init];
    categoryHeaderView = [[UIView alloc] init];
    categoryCellView = [[UIView alloc] init];
    itemBrandView = [[UIView alloc] init];
    searchTextField = [[UITextField alloc] init];
    rightSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //툴바
    toolBarView = [[CPToolBarView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight), CGRectGetWidth(self.view.frame), kToolBarHeight) toolbarType:CPToolbarTypeApp];
    [toolBarView setDelegate:self];
    [self.view addSubview:toolBarView];
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-40,
                                                                  (CGRectGetHeight(self.view.frame)-kToolBarHeight)/2-40,
                                                                  80,
                                                                  80)];
    [self.view addSubview:loadingView];
}

- (void)setCollectionView
{
    if (categoryCollectionView) {
        [categoryCollectionView removeFromSuperview];
        categoryCollectionView = nil;
    }
    
    //CollectionView
    categoryLayout = [[CPCollectionViewFlowLayout alloc] init];
    categoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight)) collectionViewLayout:categoryLayout];
    [categoryCollectionView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
    [categoryCollectionView setDelegate:self];
    [categoryCollectionView setDataSource:self];
    [categoryCollectionView setClipsToBounds:YES];
//    [categoryCollectionView registerClass:[CPCollectionViewCommonCell class] forCellWithReuseIdentifier:@"noData"];
    [categoryCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [categoryCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [categoryLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, 1000)];
    [categoryLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, FOOTER_HEIGHT)];
    [self.view insertSubview:categoryCollectionView belowSubview:toolBarView];
    
    
    NSArray *allGroupName = [NSArray arrayWithArray:[collectionData getAllGroupName]];
    
    for (NSString *str in allGroupName) {
        [categoryCollectionView registerClass:[CPCollectionViewCommonCell class] forCellWithReuseIdentifier:str];
    }
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

- (void)RequestDisplayCd
{
    //item/brand 노출
    if ([[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"hasBrandCategory"] intValue] == 1) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NSCTGB03"];
    }
    
    NSArray *allGroupName = [NSArray arrayWithArray:[collectionData getAllGroupName]];
    
    for (NSString *str in allGroupName) {
        
        if ([str isEqualToString:@"ctgrHotClick"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB08"];
        }
        else if ([str isEqualToString:@"ctgrBest"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB10"];
        }
        else if ([str isEqualToString:@"ctgrDealBest"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB13"];
        }
    }
    
    //상품노출코드
    for (NSString *str in productDispTrcCdInfo) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:str];
    }
    
    //광고노출집계URL
    for (NSString *str in adDispTrcUrlInfo) {
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:str];
    }
}

#pragma mark - API

- (void)getCategoryDetailData:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^categoryDetailSuccess)(NSDictionary *);
    categoryDetailSuccess = ^(NSDictionary *categoryDetailData) {
        
        if (categoryDetailData && [categoryDetailData count] > 0) {
            
            NSArray *dataArray = categoryDetailData[@"data"];
            
            [categoryTreeInfo removeAllObjects];
            [collectionData removeAllObjects];
            [lineBannerInfo removeAllObjects];
            [productDispTrcCdInfo removeAllObjects];
            [adDispTrcUrlInfo removeAllObjects];
            [self resetView];
            
            [collectionData setData:dataArray];
            
            NSPredicate *ctgrTreeInfoPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"categoryTree"];
            if ([dataArray filteredArrayUsingPredicate:ctgrTreeInfoPredicate].count > 0) {
                categoryTreeInfo = [[dataArray filteredArrayUsingPredicate:ctgrTreeInfoPredicate][0] mutableCopy];
            }
            
            //line banner
            NSArray *footerDataArray = categoryDetailData[@"footerData"];
            
            NSPredicate *bannerPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"adLineBanner"];
            if ([footerDataArray filteredArrayUsingPredicate:bannerPredicate].count > 0) {
                NSMutableDictionary *lineBannerUrlInfo = [[footerDataArray filteredArrayUsingPredicate:bannerPredicate][0] mutableCopy];
                
                if (lineBannerUrlInfo[@"url"]) {
                    [self getLineBannerWithUrl:lineBannerUrlInfo[@"url"]];
                }
            }
            
            //상품노출코드
            [productDispTrcCdInfo setArray:categoryDetailData[@"productDispTrcCd"]];
            //광고노출집계URL
            [adDispTrcUrlInfo setArray:categoryDetailData[@"adDispTrcUrl"]];
            //노출코드호출
            [self RequestDisplayCd];
        }
        
        //멀티쓰레드 문제로 collectionView init은 이곳에서 처리
        [self setCollectionView];
        [self stopLoadingAnimation];
        
        // Offer Banner
        mdnBannerView = [[CPBannerManager sharedManager] makeOfferBannerView];
        [[CPBannerManager sharedManager] setDelegate:self];
        [self.view insertSubview:mdnBannerView aboveSubview:categoryCollectionView];
    };
    
    void (^categoryDetailFailure)(NSError *);
    categoryDetailFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        
        errorView = [[CPErrorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)];
        [errorView setDelegate:self];
        [self.view addSubview:errorView];
    };
    
    currentUrl = url;
    
    if (url) {
        [[CPRESTClient sharedClient] requestCategoryDetailWithUrl:url
                                                          success:categoryDetailSuccess
                                                          failure:categoryDetailFailure];
    }
}

- (void)getLineBannerWithUrl:(NSString *)url
{
    void (^lineBannerSuccess)(NSDictionary *);
    lineBannerSuccess = ^(NSDictionary *bannerData) {
        
        if (bannerData && [bannerData count] > 0) {
            
            NSLog(@"bannerData : %@", bannerData);
            
            lineBannerInfo = [bannerData mutableCopy];
            
            //Line Banner
            if (lineBannerInfo) {
                lineBannerView = [[CPBannerView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight+kLineBannerHeight), kScreenBoundsWidth, kLineBannerHeight) bannerInfo:lineBannerInfo];
                [lineBannerView setDelegate:self];
                [self.view insertSubview:lineBannerView aboveSubview:categoryCollectionView];
                
                //NO animation
                [UIView setAnimationsEnabled:NO];
                
                //섹션헤더 리로드 - 아이패드 iOS7대에서 크래쉬 이슈로 예외처리
                if ((IS_IPAD || IS_IPHONE_6 || IS_IPHONE_6PLUS)) {// && SYSTEM_VERSION_LESS_THAN(@"8")) {
                    [categoryCollectionView reloadData];
                }
                else {
                    [categoryCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
                }
                
                [UIView setAnimationsEnabled:YES];
            }
        }
    };
    
    void (^lineBannerFailure)(NSError *);
    lineBannerFailure = ^(NSError *error) {
        
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestLineBannerWithUrl:url
                                                      success:lineBannerSuccess
                                                      failure:lineBannerFailure];
    }
}

#pragma mark - Private Methods

- (void)resetView
{
    for (UIView *subView in [categoryView subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [categoryHeaderView subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [categoryCellView subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [itemBrandView subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [searchTextField subviews]) {
        [subView removeFromSuperview];
    }
    for (UIView *subView in [searchView subviews]) {
        [subView removeFromSuperview];
    }
    
    [categoryView removeFromSuperview];
    [categoryHeaderView removeFromSuperview];
    [categoryCellView removeFromSuperview];
    [itemBrandView removeFromSuperview];
    [searchTextField removeFromSuperview];
    [searchView removeFromSuperview];
    
    isShowSearchView = NO;
    [categoryView setTag:CATEGORY_VIEW_NONE];
}

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    if ([url isMatchedByRegex:@"/MW/Product/productBasicInfo.tmall"]) {
        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
        
        CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo];
        [self.navigationController pushViewController:viewController animated:animated];
    }
    else {
        CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
        [self.navigationController pushViewController:viewControlelr animated:animated];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginStatusDidChange)
                                                     name:WebViewControllerNotification
                                                   object:nil];
    }
}

- (void)openSearchView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CGRect frame = searchView.frame;
    
    frame.size.height = isShowSearchView ? 0 : CATEGORY_CELL_HEIGHT;
    searchView.frame = frame;
    
    frame = categoryView.frame;
    frame.size.height += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
    categoryView.frame = frame;
    
    frame = categoryHeaderView.frame;
    frame.size.height += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
    categoryHeaderView.frame = frame;
    
    for (UIView *subView in [categoryHeaderView subviews]) {
        if (subView.tag == 1+HEADER_CELL_TAG) {
            frame = subView.frame;
            frame.size.height += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
            subView.frame = frame;
            break;
        }
    }
    
    frame = categoryCellView.frame;
    frame.origin.y += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
    categoryCellView.frame = frame;
    
    frame = shadowView.frame;
    frame.origin.y += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
    shadowView.frame = frame;
    
    if ([[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"hasBrandCategory"] intValue] == 1) {
    
        NSInteger levelCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
        if (levelCount == 1) {
            frame = itemBrandView.frame;
            frame.origin.y += isShowSearchView ? -CATEGORY_CELL_HEIGHT : CATEGORY_CELL_HEIGHT;
            itemBrandView.frame = frame;
        }
    }
    
    isShowSearchView = !isShowSearchView;
    [searchView setHidden:!isShowSearchView];
    [button setImage:isShowSearchView?[UIImage imageNamed:@"ic_c_search_close.png"]:[UIImage imageNamed:@"ic_c_search_01.png"] forState:UIControlStateNormal];
    [categoryLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT + CGRectGetHeight(categoryView.frame) + 20)];
    
    //클릭코드
    if (isSearchViewClick) {
        //AccessLog - 카테고리 내 검색 아이콘
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD04"];
    }
}

- (void)textFieldBecomeFirstResponder
{
    [searchTextField becomeFirstResponder];
}

- (void)textFieldResignFirstResponder
{
    [searchTextField resignFirstResponder];
}

- (void)startScrolling
{
    CGPoint offset = CGPointMake(CGRectGetMinX(searchView.frame), CGRectGetMinY(searchView.frame)-CATEGORY_CELL_HEIGHT);
    [categoryCollectionView setContentOffset:offset animated:YES];
}

- (NSString *)appLinkRemove:(NSString *)url
{
    if ([url hasPrefix:@"app://gocategory/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gocategory/" withString:@""];
        url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return url;
}

- (UIColor *)getSectionColor:(NSInteger)index
{
    UIColor *color = [UIColor whiteColor];
    NSInteger levelCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
    
    switch (levelCount-index) {
        case 0:
            color = UIColorFromRGB(0x6c81ea);
            break;
        case 1:
            color = UIColorFromRGB(0x8e97c2);
            break;
        case 2:
            color = UIColorFromRGB(0xb1b5cd);
            break;
    }
    
    return color;
}

- (UIColor *)getSectionLineColor:(NSInteger)index
{
    NSLog(@"---- index : %ld", (long)index);
    
    UIColor *color = [UIColor whiteColor];
    NSInteger levelCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
    
    switch (levelCount-(index-1)) {
        case 0:
            color = UIColorFromRGB(0x5462eb);
            break;
        case 1:
            color = UIColorFromRGB(0x6075df);
            break;
        case 2:
            color = UIColorFromRGB(0x8790ba);
            break;
        case 3:
            color = UIColorFromRGB(0x9fa3bc);
            break;
    }
    
    return color;
}

#pragma mark - AccessLog

- (void)hierarchyAccessLog:(NSInteger)index
{
    NSInteger dispCtgrLevel = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"][index][@"dispCtgrLevel"] integerValue];
    
    if (dispCtgrLevel == 1) {
        //AccessLog - 대카테고리
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD01"];
    }
    else if (dispCtgrLevel == 2) {
        //AccessLog - 중카테고리
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD02"];
    }
}

#pragma mark - Selectors

- (void)touchBanner
{
    NSString *linkUrl = lineBannerInfo[@"CONTENTS"][@"LURL1"];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        [self openWebViewControllerWithUrl:linkUrl animated:YES];
    }
}

- (void)touchHeaderView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *linkUrl = categoryTreeInfo[@"ctgrInfo"][@"hierarchy"][button.tag-1][@"url"];
    linkUrl = [self appLinkRemove:linkUrl];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        [self getCategoryDetailData:linkUrl];
    }
    
    //클릭코드
    [self hierarchyAccessLog:button.tag-1];
}

- (void)touchDeselectView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *linkUrl = @"";
    
    switch (button.tag) {
        case CPButtonTypeItem:
            linkUrl = [categoryTreeInfo[@"ctgrInfo"] objectForKey:@"itemUrl"];
            //AccessLog - ITEM 탭 터치 시
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB04"];
            break;
            
        case CPButtonTypeBrand:
            linkUrl = [categoryTreeInfo[@"ctgrInfo"] objectForKey:@"brandUrl"];
            //AccessLog - BRAND 탭 터치 시
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB05"];
            break;
            
        default:
            break;
    }
    
    linkUrl = [self appLinkRemove:linkUrl];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        [self getCategoryDetailData:linkUrl];
    }
}

- (void)touchShowProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger regionCount = button.tag / PRODUCT_ITEMS_TAG;
    NSInteger itemsCount = button.tag - regionCount*PRODUCT_ITEMS_TAG;
    
    NSString *searchUrl = categoryTreeInfo[@"items"][regionCount][@"items"][itemsCount][@"searchUrl"];
    if ([searchUrl hasPrefix:@"app://gosearch/"]) {
        searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        searchUrl = [searchUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:searchUrl keyword:nil referrer:categoryUrl];
    [self.navigationController pushViewController:viewConroller animated:YES];
    
    
    NSInteger hierarchyCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
    if (hierarchyCount == 2) {
        //AccessLog - 소카테고리 상품보기 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGC02"];
    }
    else if (hierarchyCount == 3) {
        //AccessLog - 세카테고리명 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD03"];
    }
}

- (void)touchGoLink:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger regionCount = button.tag / PRODUCT_ITEMS_TAG;
    NSInteger itemsCount = button.tag - regionCount*PRODUCT_ITEMS_TAG;
    
    NSString *itemLink = categoryTreeInfo[@"items"][regionCount][@"items"][itemsCount][@"url"];
    itemLink = [self appLinkRemove:itemLink];
    
    if (itemLink && [[itemLink trim] length] > 0) {
        [self getCategoryDetailData:itemLink];
    }
    
    NSInteger hierarchyCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
    if (hierarchyCount == 1) {
        //AccessLog - 중카테고리명 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB01"];
    }
    else if (hierarchyCount == 2) {
        //AccessLog - 소카테고리명 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGC02"];
    }
    else if (hierarchyCount == 3) {
        //AccessLog - 세카테고리명 클릭
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD03"];
    }
}

- (void)didTouchCtgrBest:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchCtgrHotClickProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchCtgrBestProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchCtgrDealBestProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)touchSearchButton
{
    //AccessLog - 카테고리내 검색 버튼 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGD05"];
    
    NSString *keyword = [searchTextField.text trim];
    
    if (!keyword || [[keyword trim] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];
        
        return;
    }
    
    NSString *inSearchUrl = categoryTreeInfo[@"ctgrInfo"][@"inSearchUrl"];
    
    if ([inSearchUrl hasPrefix:@"app://gosearch/"]) {
        inSearchUrl = [inSearchUrl stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        inSearchUrl = URLDecode(inSearchUrl);
    }
    
    if (keyword) {
        //        keyword = [Modules encodeAddingPercentEscapeString:keyword];
        NSString *encKeyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        inSearchUrl = [inSearchUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:encKeyword];
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:inSearchUrl keyword:keyword referrer:categoryUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)loginStatusDidChange
{
    [cpFooterView reloadLoginStatus];
}

- (void)reloadAfterLogin
{
    //로그인 후 API재호출
    [self getCategoryDetailData:currentUrl];
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchMenuButton
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
    if (searchTextField) {
        [searchTextField resignFirstResponder];
    }
}

- (void)didTouchBasketButton
{
    NSString *cartUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cart"];
    
    [self openWebViewControllerWithUrl:cartUrl animated:NO];
}

- (void)didTouchLogoButton
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeNotification object:self];
}

- (void)didTouchMyInfoButton
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)didTouchSearchButton:(NSString *)keywordUrl;
{
    if (keywordUrl) {
        [self openWebViewControllerWithUrl:keywordUrl animated:YES];
    }
}

- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword
{
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:categoryUrl];
    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [viewController setWantsFullScreenLayout:YES];
//    }
    
//    viewController.defaultUrl = keywordUrl;
//    viewController.isSearchText = YES;
//    viewController.defaultText = keyword;
    
//    [self.navigationController pushViewController:viewController animated:NO];
//    [self.navigationController setNavigationBarHidden:YES];
    [self presentViewController:viewController animated:NO completion:nil];
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:categoryUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)searchWithAdvertisement:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - CPToolBarViewDelegate

- (void)didTouchToolBarButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    switch (button.tag) {
        case CPToolBarButtonTypeBack:
            //            [[CPCommonInfo sharedInfo] setLastViewController:self];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case CPToolBarButtonTypeForward:
            if ([button isEnabled]) {
            }
            break;
        case CPToolBarButtonTypeReload:
            [self getCategoryDetailData:currentUrl];
            break;
        case CPToolBarButtonTypeTop:
            [categoryCollectionView setContentOffset:CGPointZero animated:YES];
            break;
        case CPToolBarButtonTypeHome:
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
        default:
            break;
    }
}

- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    switch (button.tag) {
        case CPSnapshotPopOverMenuTypeList:
        {
            CPSnapshotListViewController *viewController = [[CPSnapshotListViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    switch (button.tag) {
        case CPPopOverMenuTypeRecent:
        {
            NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"todayProduct"];
            [self openWebViewControllerWithUrl:url animated:YES];
            break;
        }
        case CPPopOverMenuTypeFavorite:
        {
            NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"interest"];
            [self openWebViewControllerWithUrl:url animated:NO];
            break;
        }
        case CPPopOverMenuTypeSetting:
        {
            SetupController *viewController = [[SetupController alloc] init];
            viewController.delegate = self;
            
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //검색결과가 없을 때 UI를 그리기 위한 코드
//    BOOL isNoData = collectionData.items.count == 0 || noData[@"noData"];
//    NSInteger bestItemCount = (isNoData ? 1 : collectionData.items.count);
//    
//    return bestItemCount;
    return collectionData.items.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionData getSizeForItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *headerView;
        
        @try {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            saveHeaderView = headerView;
            [categoryLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT)];
        }
        @catch (NSException *exception) {
            headerView = saveHeaderView;
        }
        @finally {}
        
        for (UIView *subView in [headerView subviews]) {
            [subView removeFromSuperview];
        }
        
        //Title
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, HEADER_HEIGHT)];
        [titleView setBackgroundColor:[UIColor whiteColor]];
        [headerView addSubview:titleView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleView.frame];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@"카테고리"];
        [titleLabel setFont:[UIFont systemFontOfSize:15]];
        [titleLabel setTextColor:UIColorFromRGB(0x575656)];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleView addSubview:titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, CGRectGetWidth(titleView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xb5b5bf)];
        [titleView addSubview:lineView];
        
        if (categoryView.tag != CATEGORY_VIEW_EXIST) {
            
            //카테고리
            [categoryView setBackgroundColor:[UIColor whiteColor]];
            [categoryView setTag:CATEGORY_VIEW_EXIST];
            
            [categoryHeaderView setBackgroundColor:[UIColor whiteColor]];
            [categoryView addSubview:categoryHeaderView];
            
            [categoryCellView setBackgroundColor:[UIColor whiteColor]];
            [categoryView addSubview:categoryCellView];
            
            
            NSInteger levelCount = [categoryTreeInfo[@"ctgrInfo"][@"hierarchy"] count];
            headerViewHeight = 0;
            
            for (int i = 1; i <= levelCount; i++) {
                
                //contentView
                UIView *headerCellView = [[UIView alloc] initWithFrame:CGRectMake(0, headerViewHeight, kScreenBoundsWidth-20, CATEGORY_CELL_HEIGHT)];
                [headerCellView setTag:i+HEADER_CELL_TAG];
                [headerCellView setBackgroundColor:[self getSectionColor:i]];
                [categoryHeaderView addSubview:headerCellView];
                
                //height++
                headerViewHeight += CATEGORY_CELL_HEIGHT;
                
                //Title
                NSString *title = categoryTreeInfo[@"ctgrInfo"][@"hierarchy"][i-1][@"dispCtgrNm"];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 250, CATEGORY_CELL_HEIGHT)];
                [titleLabel setBackgroundColor:[UIColor clearColor]];
                [titleLabel setText:title];
                [titleLabel setFont:[UIFont systemFontOfSize:16]];
                [titleLabel setTextColor:UIColorFromRGB(0xffffff)];
                [titleLabel setTextAlignment:NSTextAlignmentLeft];
                [headerCellView addSubview:titleLabel];
                
                
                //icon
                iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [iconButton setBackgroundColor:[UIColor clearColor]];
                [headerCellView addSubview:iconButton];
                
                
                if (i < levelCount) {
                    //downArrow icon
                    [iconButton setFrame:CGRectMake(CGRectGetWidth(headerCellView.frame)-12-16, 14, 16, 17)];
                    [iconButton setImage:[UIImage imageNamed:@"bt_c_arrow_down_02.png"] forState:UIControlStateNormal];
                }
                else {
                    BOOL isSearchButtonExist = [[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"searchButtonYN"] isEqualToString:@"Y"];
                    
                    if (isSearchButtonExist || levelCount == 1) {
                        //검색 icon
                        [iconButton setFrame:CGRectMake(CGRectGetWidth(headerCellView.frame)-44, 0, 44, CATEGORY_CELL_HEIGHT)];
                        [iconButton setImage:isShowSearchView?[UIImage imageNamed:@"ic_c_search_close.png"]:[UIImage imageNamed:@"ic_c_search_01.png"] forState:UIControlStateNormal];
                        [iconButton addTarget:self action:@selector(openSearchView:) forControlEvents:UIControlEventTouchUpInside];
                        [iconButton setAccessibilityLabel:@"검색"];
                        
                        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headerCellView.frame)-12-21-13, 10, 1, 26)];
                        [line setBackgroundColor:UIColorFromRGB(0x566cd9)];
                        [headerCellView addSubview:line];
                    }
                }
                
                //search
                if (i == levelCount) {
                    [searchView setFrame:CGRectMake(0, headerViewHeight, kScreenBoundsWidth-20, isShowSearchView ? CATEGORY_CELL_HEIGHT : 0)];
                    [searchView setBackgroundColor:[self getSectionColor:i]];
                    [categoryHeaderView addSubview:searchView];
                    
                    [searchView setHidden:!isShowSearchView];
                    
                    [searchTextField setFrame:CGRectMake(8, 8, kScreenBoundsWidth-36, CATEGORY_CELL_HEIGHT-16)];
                    [searchTextField setDelegate:self];
                    [searchTextField setPlaceholder:@"카테고리 내 검색"];
                    [searchTextField setTextColor:UIColorFromRGB(0x333333)];
                    [searchTextField setBackground:[UIImage imageNamed:@"bar_c_search_01.png"]];
                    [searchTextField setBackgroundColor:[UIColor whiteColor]];                                                                                    
                    [searchTextField setFont:[UIFont systemFontOfSize:14]];
                    [searchTextField setReturnKeyType:UIReturnKeySearch];
                    [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                    [searchTextField addTarget:self action:@selector(startScrolling) forControlEvents:UIControlEventEditingDidBegin];
                    [searchView addSubview:searchTextField];
                    
                    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, CATEGORY_CELL_HEIGHT)];
                    [searchTextField setLeftViewMode:UITextFieldViewModeAlways];
                    [searchTextField setLeftView:leftPaddingView];
                    
                    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchTextField.frame)-30, 8, 30, 30)];
                    [rightPaddingView setBackgroundColor:[UIColor whiteColor]];
                    [searchView addSubview:rightPaddingView];
                    
                    [rightSearchButton setFrame:CGRectMake(0, 0, 30, 30)];
                    [rightSearchButton setImage:[UIImage imageNamed:@"ic_c_search_02.png"] forState:UIControlStateNormal];
                    [rightSearchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
                    [rightSearchButton setAccessibilityLabel:@"검색"];
                    [rightPaddingView addSubview:rightSearchButton];
                    
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CATEGORY_CELL_HEIGHT-1, kScreenBoundsWidth-20, 1)];
                    [lineView setBackgroundColor:[self getSectionLineColor:i==1?i:i+1]];
                    [searchView addSubview:lineView];
                    
                    headerViewHeight += searchView.frame.size.height;
                }
                
                //Line
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CATEGORY_CELL_HEIGHT-1, CGRectGetWidth(headerCellView.frame), 1)];
                [lineView setBackgroundColor:[self getSectionLineColor:i+1]];
                [headerCellView addSubview:lineView];
                
                
                //item/brand
                if ([[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"hasBrandCategory"] intValue] == 1) {
                    if (i == 1) {
                        BOOL isBrand = [[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"tabId"] isEqualToString:@"BRAND"];
                        UIImage *image = [[UIImage imageNamed:[NSString stringWithFormat:@"bt_c_select_bg_0%d", (int)(levelCount)]] stretchableImageWithLeftCapWidth:122.0f topCapHeight:0.0f];
                        
                        [itemBrandView setFrame:CGRectMake(0, headerViewHeight, kScreenBoundsWidth-20, CATEGORY_CELL_HEIGHT)];
                        [itemBrandView setBackgroundColor:[self getSectionColor:i]];
                        [headerCellView addSubview:itemBrandView];
                        
                        //height++
                        headerViewHeight += CATEGORY_CELL_HEIGHT;
                        
                        CGRect frame = headerCellView.frame;
                        frame.size.height += CATEGORY_CELL_HEIGHT;
                        headerCellView.frame = frame;
                        
                        UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [selectedButton setTag:isBrand?CPButtonTypeItem:CPButtonTypeBrand];
                        [selectedButton setFrame:CGRectMake(21, 8, kScreenBoundsWidth-62, 28)];
                        [selectedButton setBackgroundImage:image forState:UIControlStateNormal];
                        [selectedButton addTarget:self action:@selector(touchDeselectView:) forControlEvents:UIControlEventTouchUpInside];
                        [itemBrandView addSubview:selectedButton];
                        
                        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(selectedButton.frame))];
                        [itemLabel setCenter:CGPointMake(CGRectGetWidth(selectedButton.frame)/4, CGRectGetHeight(selectedButton.frame)/2)];
                        [itemLabel setText:@"ITEM"];
                        [itemLabel setFont:[UIFont systemFontOfSize:12]];
                        [itemLabel setTextColor:UIColorFromRGB(0xffffff)];
                        [itemLabel setTextAlignment:NSTextAlignmentCenter];
                        [itemLabel setBackgroundColor:[UIColor clearColor]];
                        [selectedButton addSubview:itemLabel];
                        
                        UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(selectedButton.frame))];
                        [brandLabel setCenter:CGPointMake(CGRectGetWidth(selectedButton.frame)/4*3, CGRectGetHeight(selectedButton.frame)/2)];
                        [brandLabel setText:@"BRAND"];
                        [brandLabel setFont:[UIFont systemFontOfSize:12]];
                        [brandLabel setTextColor:UIColorFromRGB(0xffffff)];
                        [brandLabel setTextAlignment:NSTextAlignmentCenter];
                        [brandLabel setBackgroundColor:[UIColor clearColor]];
                        [selectedButton addSubview:brandLabel];
                        
                        image = [[UIImage imageNamed:@"bt_c_select_01"] stretchableImageWithLeftCapWidth:60.0f topCapHeight:0.0f];
                        
                        UIButton *deSelectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [deSelectedButton setTag:isBrand?CPButtonTypeBrand:CPButtonTypeItem];
                        [deSelectedButton setBackgroundImage:image forState:UIControlStateNormal];
                        [deSelectedButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
                        [deSelectedButton setTitleColor:UIColorFromRGB(0x3d3f43) forState:UIControlStateNormal];
                        [deSelectedButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
                        [deSelectedButton addTarget:self action:@selector(touchDeselectView:) forControlEvents:UIControlEventTouchUpInside];
                        [itemBrandView addSubview:deSelectedButton];
                        
                        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_c_cheak.png"]];
                        [deSelectedButton addSubview:iconView];
                        
                        if ([[categoryTreeInfo[@"ctgrInfo"] objectForKey:@"tabId"] isEqualToString:@"BRAND"]) {
                            [deSelectedButton setTitle:@"BRAND" forState:UIControlStateNormal];
                            [deSelectedButton setFrame:CGRectMake((CGRectGetWidth(selectedButton.frame)-CGRectGetWidth(selectedButton.frame)/2+10), 8, CGRectGetWidth(selectedButton.frame)/2+10, 28)];
                            [deSelectedButton setAccessibilityLabel:@"BRAND"];
                            [iconView setFrame:CGRectMake(CGRectGetWidth(deSelectedButton.frame)/2-30, (CGRectGetHeight(deSelectedButton.frame)-8)/2, 11, 8)];
                        }
                        else {
                            [deSelectedButton setTitle:@"ITEM" forState:UIControlStateNormal];
                            [deSelectedButton setFrame:CGRectMake(21, 8, CGRectGetWidth(selectedButton.frame)/2+10, 28)];
                            [deSelectedButton setAccessibilityLabel:@"ITEM"];
                            [iconView setFrame:CGRectMake(CGRectGetWidth(deSelectedButton.frame)/2-30, (CGRectGetHeight(deSelectedButton.frame)-8)/2, 11, 8)];
                        }
                        
                        //Line
                        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CATEGORY_CELL_HEIGHT-1, CGRectGetWidth(headerCellView.frame), 1)];
                        [lineView setBackgroundColor:[self getSectionLineColor:2]];
                        [itemBrandView addSubview:lineView];
                    }
                }
                
                if (i < levelCount) {
                    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [blankButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, CATEGORY_CELL_HEIGHT)];
                    [blankButton setTag:i];
                    [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
                    [blankButton setAlpha:0.3];
                    [blankButton addTarget:self action:@selector(touchHeaderView:) forControlEvents:UIControlEventTouchUpInside];
                    [blankButton setAccessibilityLabel:@"해당 카테고리로 이동합니다."];
                    [headerCellView addSubview:blankButton];
                }
            }
            
            
            //cell
            cellViewHeight = 0;
            NSArray *ctgrTree = categoryTreeInfo[@"items"];
            
            for (NSDictionary *regionDic in ctgrTree) {
                //title
                if ([[regionDic objectForKey:@"titleYN"] isEqualToString:@"Y"]) {
                    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, cellViewHeight, kScreenBoundsWidth-20, 28)];
                    [titleView setBackgroundColor:UIColorFromRGB(0xeaebee)];
                    [categoryCellView addSubview:titleView];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 28)];
                    [titleLabel setBackgroundColor:[UIColor clearColor]];
                    [titleLabel setText:[regionDic objectForKey:@"title"]];
                    [titleLabel setTextColor:UIColorFromRGB(0x1e1e1e)];
                    [titleLabel setFont:[UIFont systemFontOfSize:13]];
                    [titleLabel setTextAlignment:NSTextAlignmentLeft];
                    [titleView addSubview:titleLabel];
                    
                    cellViewHeight += 28;
                }
                
                for (NSDictionary *itemDic in regionDic[@"items"]) {
                    
                    BOOL isLeaf = [[itemDic objectForKey:@"leafCategoryYN"] isEqualToString:@"Y"];
                    
                    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, cellViewHeight, kScreenBoundsWidth-20, CATEGORY_CELL_HEIGHT)];
                    [cellView setBackgroundColor:[UIColor whiteColor]];
                    [categoryCellView addSubview:cellView];
                    
                    //title
                    NSString *text = [itemDic objectForKey:@"dispCtgrNm"];
                    CGSize labelSize = [text sizeWithFont:[UIFont systemFontOfSize:14]];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                    [titleLabel setFrame:CGRectMake(18, 0, labelSize.width, CGRectGetHeight(cellView.frame))];
                    [titleLabel setBackgroundColor:[UIColor clearColor]];
                    [titleLabel setText:text];
                    [titleLabel setFont:[UIFont systemFontOfSize:14]];
                    [titleLabel setTextColor:UIColorFromRGB(0x1e1e1e)];
                    [cellView addSubview:titleLabel];
                    
                    //상품보기
                    NSInteger buttonTag = [ctgrTree indexOfObject:regionDic]*PRODUCT_ITEMS_TAG + [regionDic[@"items"] indexOfObject:itemDic];
                    
                    UIButton *showProductButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [showProductButton setFrame:CGRectMake(CGRectGetWidth(cellView.frame)-68, 11, 59, 24)];
                    [showProductButton setTag:buttonTag];
                    [showProductButton setImage:[UIImage imageNamed:@"bt_c_arrow_view_01.png"] forState:UIControlStateNormal];
                    [showProductButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
                    [showProductButton setTitle:@"상품보기" forState:UIControlStateNormal];
                    [showProductButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
                    [showProductButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
                    [showProductButton setTitleEdgeInsets:UIEdgeInsetsMake(1, -10, 0, 0)];
                    [showProductButton setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
                    [showProductButton.layer setBorderColor:UIColorFromRGB(0xd2d3d9).CGColor];
                    [showProductButton.layer setBorderWidth:1];
                    [showProductButton addTarget:self action:@selector(touchShowProduct:) forControlEvents:UIControlEventTouchUpInside];
                    [showProductButton setAccessibilityLabel:@"상품보기"];
                    [cellView addSubview:showProductButton];
                    
                    
                    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [blankButton setFrame:CGRectMake(0, cellViewHeight, kScreenBoundsWidth-84, CATEGORY_CELL_HEIGHT)];
                    [blankButton setTag:buttonTag];
                    [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
                    [blankButton setAlpha:0.3];
                    [categoryCellView addSubview:blankButton];
                    
                    if (!isLeaf) {
                        [blankButton addTarget:self action:@selector(touchGoLink:) forControlEvents:UIControlEventTouchUpInside];
                        
                        //add icon
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 17, 12, 12)];
                        [imageView setImage:[UIImage imageNamed:@"ic_c_morelist.png"]];
                        [cellView addSubview:imageView];
                        
                        [titleLabel setFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+10, 0, CGRectGetWidth(titleLabel.frame), CGRectGetHeight(cellView.frame))];
                    }
                    else {
                        [blankButton addTarget:self action:@selector(touchShowProduct:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    // discount
                    NSInteger discount = [[itemDic objectForKey:@"tMemRate"] intValue];
                    NSString *discountText = [NSString stringWithFormat:@"~%d%%", [[itemDic objectForKey:@"tMemRate"] intValue]];
                    if (discountText && ![[discountText trim] isEqualToString:@""] && (discount != 0)) {
                        UIImage *tImage = [UIImage imageNamed:@"ic_c_t_sale.png"];
                        UIImageView *tImageView = [[UIImageView alloc] initWithImage:tImage];
                        [tImageView setFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 8, (CATEGORY_CELL_HEIGHT - tImage.size.height) / 2, tImage.size.width, tImage.size.height)];
                        [cellView addSubview:tImageView];
                        
                        UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        [discountLabel setTextColor:UIColorFromRGB(0xea0000)];
                        [discountLabel setFont:[UIFont systemFontOfSize:11]];
                        [discountLabel setBackgroundColor:[UIColor clearColor]];
                        [discountLabel setText:discountText];
                        [discountLabel sizeToFit];
                        [discountLabel setFrame:CGRectMake(CGRectGetMaxX(tImageView.frame) + 2, 0, discountLabel.frame.size.width, discountLabel.frame.size.height)];
                        [discountLabel setCenter:CGPointMake(discountLabel.center.x, tImageView.center.y)];
                        [cellView addSubview:discountLabel];
                    }
                    cellViewHeight += CATEGORY_CELL_HEIGHT;
                    
                    //Line
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CATEGORY_CELL_HEIGHT-1, CGRectGetWidth(cellView.frame), 1)];
                    [lineView setBackgroundColor:UIColorFromRGB(0xe6e7ec)];
                    [cellView addSubview:lineView];
                }
            }
        }
        else {
            //검색창이 열려있을 경우.
            if (isShowSearchView) {
                isSearchViewClick = NO;
                [self openSearchView:iconButton];
                isSearchViewClick = YES;
            }
        }
        
        ctgrHeight = headerViewHeight + cellViewHeight;
        
        //shadow
        if (!shadowView) {
            shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, ctgrHeight-1, kScreenBoundsWidth-20, 1)];
            [shadowView setBackgroundColor:UIColorFromRGB(0xc5c5ce)];
            [categoryView addSubview:shadowView];
        }
        
        [categoryHeaderView setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, headerViewHeight)];
        [categoryCellView setFrame:CGRectMake(0, headerViewHeight, kScreenBoundsWidth-20, cellViewHeight)];
        [categoryView setFrame:CGRectMake(10, CGRectGetMaxY(titleView.frame)+10, kScreenBoundsWidth-20, ctgrHeight)];
        [categoryLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT + CGRectGetHeight(categoryView.frame) + 15)];
        
        [headerView addSubview:categoryView];
        
        reusableview = headerView;
    }
    else if ([kind isEqual:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footerView;
        
        @try {
            footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
            saveFooterView = footerView;
        }
        @catch (NSException *exception) {
            footerView = saveFooterView;
        }
        @finally {}
        
        //Line Banner
        CPBannerView *footerLineBannerView = [[CPBannerView alloc] initWithFrame:CGRectMake(0, 10, kScreenBoundsWidth, kLineBannerHeight) bannerInfo:lineBannerInfo];
        [footerLineBannerView setFrame:CGRectMake(0, 10, footerLineBannerView.width, footerLineBannerView.height)];
        [footerLineBannerView setDelegate:self];
        [footerView addSubview:footerLineBannerView];
        
        //footerView
        [cpFooterView setFrame:CGRectMake(0, CGRectGetMaxY(footerLineBannerView.frame), cpFooterView.width, cpFooterView.height)];
        [cpFooterView setDelegate:self];
        [footerView addSubview:cpFooterView];
        
        [categoryLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, cpFooterView.height+footerLineBannerView.height+10)];
        reusableview = footerView;
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = @"noData";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (collectionData.items.count > 0) {
        dic = collectionData.items[indexPath.row];
        groupName = dic[@"groupName"];
    }
    
    [[CPCommonInfo sharedInfo] setGroupName:groupName];
    CPCollectionViewCommonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:groupName forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setData:collectionData indexPath:indexPath];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger contentOffset = scrollView.contentOffset.y;
    // 스크롤뷰가 바운스되는 경우는 상황에서 제외
    if (contentOffset < 0 || contentOffset > scrollView.contentSize.height - scrollView.frame.size.height) {
        return;
    }
    
    // 라인배너 처리
    static NSInteger lastContentOffset = 0;
    static BOOL isScrollingToUp = NO;
    if (lastContentOffset > contentOffset) {
        if (contentOffset < 50) {
            [UIView animateWithDuration:0.5f animations:^{
                //                [lineBannerView setHidden:YES];
            }];
        }
        isScrollingToUp = NO;
    }
    else if (lastContentOffset < contentOffset) {
        if (NO == isScrollingToUp) {
            [lineBannerView setHidden:YES];
        }
        isScrollingToUp = YES;
    }
    
    lastContentOffset = scrollView.contentOffset.y;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 키보드 액세사리뷰
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-36, kScreenBoundsWidth, 36)];
    [cancelView setBackgroundColor:[UIColor clearColor]];
    [textField setInputAccessoryView:cancelView];
    
    // 닫기 버튼
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(CGRectGetWidth(cancelView.frame)-59, 0, 51, 27)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close.png"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close_press.png"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(textFieldResignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
    [cancelView addSubview:cancelButton];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *keyword = [searchTextField.text trim];
    
    if (!keyword || [[keyword trim] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];
        
        return NO;
    }
    
    NSString *inSearchUrl = categoryTreeInfo[@"ctgrInfo"][@"inSearchUrl"];
    
    if ([inSearchUrl hasPrefix:@"app://gosearch/"]) {
        inSearchUrl = [inSearchUrl stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        inSearchUrl = URLDecode(inSearchUrl);
    }
    
    if (keyword) {
//        keyword = [Modules encodeAddingPercentEscapeString:keyword];
        NSString *encKeyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        inSearchUrl = [inSearchUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:encKeyword];
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:inSearchUrl keyword:keyword referrer:categoryUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == 0 && string.length == 0) {
        [rightSearchButton setImage:[UIImage imageNamed:@"ic_c_search_02.png"] forState:UIControlStateNormal];
    }
    else {
        [rightSearchButton setImage:[UIImage imageNamed:@"ic_c_search_03.png"] forState:UIControlStateNormal];;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [rightSearchButton setImage:[UIImage imageNamed:@"ic_c_search_02.png"] forState:UIControlStateNormal];
    return YES;
}

#pragma mark - SetupControllerDelegate

- (void)setupController:(SetupController *)controller gotoWebPageWithUrlString:(NSString *)urlString
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = app.homeViewController;
    
    if ([homeViewController respondsToSelector:@selector(handleOpenURL:)]) {
        [homeViewController handleOpenURL:urlString];
    }
}

#pragma mark - CPErrorViewDelegate

- (void)didTouchRetryButton
{
    [errorView removeFromSuperview];
    
    [self performSelectorInBackground:@selector(getCategoryDetailData:) withObject:currentUrl];
}

#pragma mark - CPBannerManagerDelegate

- (void)didTouchBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - CPBannerViewDelegate

- (void)didTouchLineBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:NO];
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
