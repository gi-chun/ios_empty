//
//  CPProductListViewController.m
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductListViewController.h"
#import "CPCategoryDetailViewController.h"
#import "CPSnapshotListViewController.h"
#import "CPSearchViewController.h"
#import "CPWebViewController.h"
#import "SetupController.h"
#import "CPProductViewController.h"

#import "CPPowerLinkView.h"
#import "CPHotProductView.h"
#import "CPBannerView.h"
#import "CPToolBarView.h"
#import "CPFooterView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"
#import "CPNavigationBarView.h"
#import "CPProductFilterView.h"
#import "CPCollectionData.h"
#import "CPCollectionViewFlowLayout.h"
#import "CPCollectionViewCommonCell.h"
#import "iCarousel.h"

#import "CPHomeViewController.h"
#import "CPCommonInfo.h"
#import "CPBannerManager.h"
#import "CPRESTClient.h"
#import "SBJSON.h"
#import "RegexKitLite.h"
#import "Modules.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"
#import "AccessLog.h"

#define HEADER_HEIGHT           0
#define FOOTER_HEIGHT           118
#define CELL_GEP                10

#define SORTTYPE_INFOBUTTON_TAG 300
#define SEARCH_BUTTON_TAG       400
#define RELATED_SEARCH_BUTTON_TAG   700

typedef NS_ENUM(NSUInteger, CPPopularButtonType){
    CPPopularButtonTypeHot,
    CPPopularButtonTypeRising,
    CPPopularButtonTypePopular
};

@interface CPProductListViewController () <CPToolBarViewDelegate,
                                        CPNavigationBarViewDelegate,
                                        CPSearchViewControllerDelegate,
                                        CPBannerManagerDelegate,
                                        CPBannerViewDelegate,
                                        CPPowerLinkViewDelegate,
                                        CPHotProductViewDelegate,
                                        CPFooterViewDelegate,
                                        CPErrorViewDelegate,
                                        SetupControllerDelegate,
                                        CPCollectionViewCommonCellDelegate,
                                        CPProductFilterViewDelegate,
                                        iCarouselDelegate,
                                        iCarouselDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDataSource>
{
    NSString *categoryUrl;
    NSString *searchKeyword;
    NSString *currentUrl;
    NSString *parentUrl;
    NSString *referrerUrl;
    NSString *searchParameter;
    NSString *listingType;
    
    UICollectionView *listCollectionView;
    CPCollectionViewFlowLayout *listLayout;
    CPProductFilterView *filterView;
    CPCollectionData *collectionData;
    
    CPFooterView *cpFooterView;
    CPToolBarView *toolBarView;
    UIView *mdnBannerView;
    CPNavigationBarView *navigationBarView;
    CPBannerView *lineBannerView;
    CPPowerLinkView *powerLinkView;
    CPHotProductView *hotProductView;
    UIImageView *pagingView;
    
    CPLoadingView *loadingView;
    CPErrorView *errorView;
    
    //IOS6, IOS7 bug를 위해 임시 저장
    UICollectionReusableView *saveHeaderView;
    UICollectionReusableView *saveFooterView;
    
    //JSON API 정보
    NSMutableDictionary *listInfo;
    NSMutableDictionary *searchMetaInfo;
    NSMutableDictionary *footerData;
    NSMutableDictionary *noData;
    NSMutableDictionary *lineBannerInfo;
    NSMutableDictionary *powerLinkInfo;
    NSMutableDictionary *searchCaptionInfo;
    NSMutableDictionary *hotProductInfo;
    NSMutableDictionary *popularSearchTextInfo;
    NSMutableDictionary *relatedSearchTextInfo;
    NSMutableArray *productDispTrcCdInfo;
    NSMutableArray *adDispTrcUrlInfo;
    NSMutableArray *logUrl;
    
    NSArray *filterItems;
    NSArray *sortItems;
    
    CPCollectionViewCommonCell *srotingCell;
    UIView *viewTypeContainerView;
    UIView *sortTypeContainerView;
    UIView *filterTabView;
    
    NSIndexPath *filterCellIndexPath;
    
    NSString *moreUrl;
    NSInteger page;
    NSInteger pageTotal;
    BOOL isMore;
    BOOL needsRefresh;
    BOOL needCategoryRefresh;
    BOOL needFilterTabRefresh;
    
    UIButton *popularSearchTextHotButton;
    UIButton *popularSearchTextRisingButton;
    UIButton *popularSearchTextPopularButton;
    iCarousel *popularSearchTextiCarouselView;
    UIButton *topButton;
}

@end

@implementation CPProductListViewController

- (id)initWithKeyword:(NSString *)keyword referrer:(NSString *)referrer
{
    if (self = [super init]) {
        if (keyword) {
            searchKeyword = keyword;
            referrerUrl = referrer;
        }
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)aUrl keyword:(NSString *)keyword referrer:(NSString *)referrer
{
    if (self = [self initWithKeyword:keyword referrer:referrer]) {
        categoryUrl = aUrl;
        parentUrl = categoryUrl;
        referrerUrl = referrer;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xd6d6dd)];
    
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
    [self getProductList:categoryUrl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (searchKeyword) {
        [navigationBarView setSearchTextField:[searchKeyword stringByReplacingPercentEscapesUsingEncoding:DEFAULT_ENCODING]];
    }
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
    
    [self removeSortTypeContainerView];
    [self removeViewTypeContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData
{
    collectionData = [[CPCollectionData alloc] init];
    searchMetaInfo = [NSMutableDictionary dictionary];
    listInfo = [NSMutableDictionary dictionary];
    footerData = [NSMutableDictionary dictionary];
    noData = [NSMutableDictionary dictionary];
    lineBannerInfo = [NSMutableDictionary dictionary];
    powerLinkInfo = [NSMutableDictionary dictionary];
    searchCaptionInfo = [NSMutableDictionary dictionary];
    hotProductInfo = [NSMutableDictionary dictionary];
    popularSearchTextInfo = [NSMutableDictionary dictionary];
    relatedSearchTextInfo = [NSMutableDictionary dictionary];
    productDispTrcCdInfo = [NSMutableArray array];
    adDispTrcUrlInfo = [NSMutableArray array];
    logUrl = [NSMutableArray array];
    
    searchParameter = @"";
    needsRefresh = NO;
    needCategoryRefresh = NO;
    needFilterTabRefresh = NO;
}

- (void)initLayout
{
    //Footer
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setFrame:CGRectMake(0, 0, cpFooterView.width, cpFooterView.height)];
    [cpFooterView setDelegate:self];
    [cpFooterView setParentViewController:self];
    
    popularSearchTextHotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    popularSearchTextRisingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    popularSearchTextPopularButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [popularSearchTextHotButton setSelected:YES];
    popularSearchTextiCarouselView = [[iCarousel alloc] init];
    
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
    if (listCollectionView) {
        [listCollectionView removeFromSuperview];
        listCollectionView = nil;
    }
    
    //CollectionView
    listLayout = [[CPCollectionViewFlowLayout alloc] init];

    listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight)) collectionViewLayout:listLayout];
    [listCollectionView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
    [listCollectionView setDelegate:self];
    [listCollectionView setDataSource:self];
    [listCollectionView setClipsToBounds:YES];
    [listCollectionView registerClass:[CPCollectionViewCommonCell class] forCellWithReuseIdentifier:@"noData"];
    [listCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [listCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    [listLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT)];
    [listLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, FOOTER_HEIGHT)];
    [self.view insertSubview:listCollectionView belowSubview:toolBarView];
    
    NSArray *allGroupName = [NSArray arrayWithArray:[collectionData getAllGroupName]];
    
    for (NSString *str in allGroupName) {
        [listCollectionView registerClass:[CPCollectionViewCommonCell class] forCellWithReuseIdentifier:str];
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

- (void)initPowerLinkView
{
    [self sendPowerLinkWithUrl:powerLinkInfo currentUrl:currentUrl referrer:referrerUrl];
}

- (void)initHotProductView
{
    if (hotProductView) {
        [hotProductView removeFromSuperview];
    }
    
    
    
    //hotProduct
    hotProductView = [[CPHotProductView alloc] initWithFrame:CGRectMake(0, 0, hotProductView.width, hotProductView.height)
                                              hotProductInfo:hotProductInfo
                                                 listingType:listingType];
    [hotProductView setDelegate:self];
}

- (void)initFilterTabView
{
    if (filterTabView) {
        [filterTabView removeFromSuperview];
    }
    
    //floating filter menu
    filterTabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 39)];
    [filterTabView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
    [filterTabView setHidden:YES];
    [self.view addSubview:filterTabView];
    
    CGFloat filterButtonWidth = kScreenBoundsWidth/filterItems.count;
    
    for (int i = 0; i < filterItems.count; i++) {
        NSDictionary *menu = filterItems[i];
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton setFrame:CGRectMake(filterButtonWidth*i, 0, filterButtonWidth-1, CGRectGetHeight(filterTabView.frame))];
        [filterButton setBackgroundColor:[UIColor clearColor]];
        [filterButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [filterButton setTitleColor:UIColorFromRGB(0x5c5fd5) forState:UIControlStateHighlighted];
        [filterButton setTitleColor:UIColorFromRGB(0x5c5fd5) forState:UIControlStateSelected];
        [filterButton setTitle:menu[@"text"] forState:UIControlStateNormal];
        [filterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [filterButton setTag:i];
        [filterButton setSelected:([menu[@"selected"] isEqualToString:@"Y"] ? YES : NO)];
        [filterButton addTarget:self action:@selector(touchFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [filterTabView addSubview:filterButton];
        
        if (i < filterItems.count - 1) {
            UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(filterButton.frame), 12, 1, 15)];
            [verticalLineView setBackgroundColor:UIColorFromRGB(0xc4c4c5)];
            [filterTabView addSubview:verticalLineView];
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(filterTabView.frame)-1, CGRectGetWidth(filterTabView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0x9c9eab)];
    [filterTabView addSubview:lineView];
}

- (void)initPagingView
{
    [pagingView removeFromSuperview];
    
    UIImage *image = [[UIImage imageNamed:@"bt_s_paging.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    pagingView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-50)/2, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight)-36, 55, 21)];
    [pagingView setImage:image];
    [self.view addSubview:pagingView];
    
    NSString *pageText = [NSString stringWithFormat:@"%ld/%ld", (long)page, (long)pageTotal];
    
    TTTAttributedLabel *pagingLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 55, 21)];
    [pagingLabel setBackgroundColor:[UIColor clearColor]];
    [pagingLabel setTextColor:UIColorFromRGB(0x292929)];
    [pagingLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [pagingLabel setTextAlignment:NSTextAlignmentCenter];
    [pagingLabel setText:pageText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [pageText rangeOfString:[NSString stringWithFormat:@"/%ld", (long)pageTotal]];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
        }
        return mutableAttributedString;
    }];
    [pagingView addSubview:pagingLabel];
    pagingView.alpha = 0;
    
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        pagingView.alpha = 1;
    } completion:^(BOOL finished){
         //Appear
        [self performSelector:@selector(removePagingView) withObject:nil afterDelay:2.0f];
     }];
}

- (void)removePagingView
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        pagingView.alpha = 0;
    }];
}

- (void)RequestDisplayCd
{
    NSArray *allGroupName = [NSArray arrayWithArray:[collectionData getAllGroupName]];
    
    for (NSString *str in allGroupName) {
        
        if ([str isEqualToString:@"relatedSearchText"]) {
            //연관검색어 상단 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA01"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                
            }
            else if ([listingType isEqualToString:@"model"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA01"];
            }
        }
        else if ([str isEqualToString:@"recommendSearchText"]) {
            //추천 바로가기 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA06"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                
            }
            else if ([listingType isEqualToString:@"model"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA04"];
            }
        }
        else if ([str isEqualToString:@"searchTopTab"]) {
            //전체상품/가격비교 탭 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPC01"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                
            }
            else if ([listingType isEqualToString:@"model"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPC01"];
            }
        }
    }
    
    //footerData
    for (NSDictionary *dic in footerData) {
        if ([[dic objectForKey:@"groupName"] isEqualToString:@"powerLink"]) {
            //파워링크 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPG01"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPG01"];
            }
            else if ([listingType isEqualToString:@"model"]) {
                
            }
        }
        else if ([[dic objectForKey:@"groupName"] isEqualToString:@"searchHotProduct"]) {
            //하단 HOT클릭 단 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE18"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE18"];
            }
            else if ([listingType isEqualToString:@"model"]) {
                
            }
        }
        else if ([[dic objectForKey:@"groupName"] isEqualToString:@"relatedSearchText"]) {
            //연관검색어 하단 노출
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA01"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                
            }
            else if ([listingType isEqualToString:@"model"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA01"];
            }
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
    
    //로그용 URL
    for (NSDictionary *dic in logUrl) {
        NSString *url = @"";
        
        if ([[dic objectForKey:@"key"] isEqualToString:@"recopick"]) {
            url = [[dic objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"{{url}}" withString:currentUrl];
            url = [url stringByReplacingOccurrencesOfString:@"{{referer}}" withString:nilCheck(referrerUrl)?@"":referrerUrl];
            [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
        }
        else if ([[dic objectForKey:@"key"] isEqualToString:@"hotClick"]) {
            url = [[dic objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"{{url}}" withString:currentUrl];
            url = [url stringByReplacingOccurrencesOfString:@"{{deviceId}}" withString:@""];
            [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
        }
        else if ([[dic objectForKey:@"key"] isEqualToString:@"syrupAd"]) {
            url = [[dic objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"{{deviceUId}}" withString:@""];
            [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
        }
    }
}

#pragma mark - API

- (void)getProductList:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^productListSuccess)(NSDictionary *);
    productListSuccess = ^(NSDictionary *productListData) {
        
        if (productListData && [productListData count] > 0) {
            
            //redirectMeta 처리(ex.11번가쿠폰)
            if ([[productListData allKeys] containsObject:@"redirectMeta"]) {
                NSString *redirectUrl = productListData[@"redirectMeta"][@"redirectUrl"];
                if (productListData[@"redirectMeta"][@"redirectUrl"]) {
                    [self openWebViewControllerWithUrl:redirectUrl isPop:YES];
                    return;
                }
            }
            
            moreUrl = productListData[@"moreUrl"];
            isMore = [productListData[@"isMore"] isEqualToString:@"Y"];
            page = [productListData[@"page"] integerValue];
            listingType = productListData[@"searchMeta"][@"listingType"];
            if (productListData[@"pageTotal"]) {
                pageTotal = [productListData[@"pageTotal"] integerValue];
            }
            
            if ((isMore || (page != 1 && !isMore)) && listCollectionView) {
                needsRefresh = YES;
                NSMutableArray *addArray = productListData[@"data"];
                [collectionData setAddData:addArray];
                
                NSArray *allGroupName = [NSArray arrayWithArray:[collectionData getAllGroupName]];
                
                for (NSString *str in allGroupName) {
                    [listCollectionView registerClass:[CPCollectionViewCommonCell class] forCellWithReuseIdentifier:str];
                }
                
                [listCollectionView reloadData];
                [self initPagingView];
                [self stopLoadingAnimation];
                
                //노출코드호출
                [self RequestDisplayCd];
                return;
            }
            
            NSArray *dataArray = productListData[@"data"];
            
            [listInfo removeAllObjects];
            [searchMetaInfo removeAllObjects];
            [footerData removeAllObjects];
            [noData removeAllObjects];
            [popularSearchTextInfo removeAllObjects];
            [relatedSearchTextInfo removeAllObjects];
            [lineBannerInfo removeAllObjects];
            [powerLinkInfo removeAllObjects];
            [searchCaptionInfo removeAllObjects];
            [hotProductInfo removeAllObjects];
            [productDispTrcCdInfo removeAllObjects];
            [adDispTrcUrlInfo removeAllObjects];
            [logUrl removeAllObjects];
            [collectionData removeAllObjects];
            
            [collectionData setData:dataArray];
            searchMetaInfo = [productListData[@"searchMeta"] mutableCopy];
            footerData = [productListData[@"footerData"] mutableCopy];
            
            //searchParameter
            if (searchMetaInfo[@"searchParameter"]) {
                searchParameter = searchMetaInfo[@"searchParameter"];
            }
            
            //line banner
            NSArray *footerDataArray = productListData[@"footerData"];
            
            NSPredicate *bannerPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"adLineBanner"];
            if ([footerDataArray filteredArrayUsingPredicate:bannerPredicate].count > 0) {
                NSMutableDictionary *lineBannerUrlInfo = [[footerDataArray filteredArrayUsingPredicate:bannerPredicate][0] mutableCopy];
                
                if (lineBannerUrlInfo[@"url"]) {
                    [self getLineBannerWithUrl:lineBannerUrlInfo[@"url"]];
                }
            }
            
            NSPredicate *powerLinkPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"powerLink"];
            if ([footerDataArray filteredArrayUsingPredicate:powerLinkPredicate].count > 0) {
                powerLinkInfo = [[footerDataArray filteredArrayUsingPredicate:powerLinkPredicate][0] mutableCopy];
            }
            
            if (powerLinkInfo) {
                [self initPowerLinkView];
            }
            else {
                if (powerLinkView) {
                    [powerLinkView removeFromSuperview];
                }
            }
            
            NSPredicate *searchCaptionPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"searchCaption"];
            if ([footerDataArray filteredArrayUsingPredicate:searchCaptionPredicate].count > 0) {
                searchCaptionInfo = [[footerDataArray filteredArrayUsingPredicate:searchCaptionPredicate][0] mutableCopy];
            }
            
            NSPredicate *hotProductPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"searchHotProduct"];
            if ([footerDataArray filteredArrayUsingPredicate:hotProductPredicate].count > 0) {
                hotProductInfo = [[footerDataArray filteredArrayUsingPredicate:hotProductPredicate][0] mutableCopy];
                
                [self initHotProductView];
            }
            
            //popularSearchText
            NSPredicate *popularSearchTextPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"popularSearchText"];
            if ([footerDataArray filteredArrayUsingPredicate:popularSearchTextPredicate].count > 0) {
                popularSearchTextInfo = [[footerDataArray filteredArrayUsingPredicate:popularSearchTextPredicate][0] mutableCopy];
            }
            
            //relatedSearchText
            NSPredicate *relatedSearchTextPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"relatedSearchText"];
            if ([footerDataArray filteredArrayUsingPredicate:relatedSearchTextPredicate].count > 0) {
                relatedSearchTextInfo = [[footerDataArray filteredArrayUsingPredicate:relatedSearchTextPredicate][0] mutableCopy];
                [relatedSearchTextInfo setObject:@"N" forKey:@"isExpanded"];
            }
            
            //floating filter menu
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"searchFilter"];
            if ([dataArray filteredArrayUsingPredicate:filterPredicate].count > 0) {
                filterItems = [[dataArray filteredArrayUsingPredicate:filterPredicate][0][@"items"] mutableCopy];
                
                [self initFilterTabView];
            }
            
            if (filterItems) {
                [self initFilterTabView];
            }
            else {
                if (filterTabView) {
                    [filterTabView removeFromSuperview];
                }
            }
            
            //app://ads/searchText/
            if (nilCheck(searchKeyword)) {
                if (productListData[@"gnbText"][@"url"]) {
                    NSString *gnbText = productListData[@"gnbText"][@"url"];
                    
                    gnbText = [gnbText stringByReplacingOccurrencesOfString:@"app://ads/searchText/" withString:@""];
                    
                    SBJSON *json = [[SBJSON alloc] init];
                    NSDictionary *dict = [json objectWithString:URLDecode(gnbText)];
                    
                    if(dict && [[dict objectForKey:@"list"] count] > 0) {
                        NSString *searchText = dict [@"list"][0][@"name"];
//                        searchText = [Modules decodeFromPercentEscapeString:searchText];
                        searchText = [searchText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        [navigationBarView setSearchTextField:searchText];
                    }
                }
            }
            else {
                [navigationBarView setSearchTextField:[searchKeyword stringByReplacingPercentEscapesUsingEncoding:DEFAULT_ENCODING]];
            }
            
            //상품노출코드
            [productDispTrcCdInfo setArray:productListData[@"productDispTrcCd"]];
            //광고노출집계URL
            [adDispTrcUrlInfo setArray:productListData[@"adDispTrcUrl"]];
            //로그용 URL
            [logUrl setArray:productListData[@"logUrl"][@"items"]];
            //노출코드호출
            [self RequestDisplayCd];
        }
        
        //멀티쓰레드 문제로 collectionView init은 이곳에서 처리
        [self setCollectionView];
        [self stopLoadingAnimation];
        
        //searchMetaInfo
        if (needCategoryRefresh) {
            needCategoryRefresh = NO;
            if (filterView) {
                [filterView refreshData:searchMetaInfo];
            }
        }
        
        if (needFilterTabRefresh) {
            needFilterTabRefresh = NO;
            if (filterView) {
                [filterView refreshTabData:searchMetaInfo];
            }
        }
        
        // Offer Banner
        mdnBannerView = [[CPBannerManager sharedManager] makeOfferBannerView];
        [[CPBannerManager sharedManager] setDelegate:self];
        [self.view insertSubview:mdnBannerView aboveSubview:listCollectionView];
    };
    
    void (^productListFailure)(NSError *);
    productListFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        
        errorView = [[CPErrorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)];
        [errorView setDelegate:self];
        [self.view insertSubview:errorView belowSubview:toolBarView];
    };
    
    NSRange range = [url rangeOfString:@"http"];
    url = [url substringFromIndex:range.location];
    if (!(url && url.length > 0)) {
        if ([[CPCommonInfo sharedInfo] urlInfo][@"search_native"]) {
            url = [[CPCommonInfo sharedInfo] urlInfo][@"search_native"];
        }
        else {
            url = APP_SEARCH_NATIVE_URL;
        }
        
        NSString *encKeyword = [searchKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        url = [url stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:encKeyword];
    }
    
    if (url) {
        currentUrl = url;
        parentUrl = url;
        
        [[CPRESTClient sharedClient] requestProductListWithUrl:url
                                                       success:productListSuccess
                                                       failure:productListFailure];
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
                [self.view insertSubview:lineBannerView aboveSubview:listCollectionView];
                
                //NO animation
                [UIView setAnimationsEnabled:NO];
                
                //섹션헤더 리로드
                [listCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
                
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

- (void)sendPowerLinkWithUrl:(NSMutableDictionary *)aPowerLinkInfo currentUrl:(NSString *)aCurrentUrl referrer:(NSString *)aReferrer;
{
    void (^powerLinkSuccess)(NSDictionary *);
    powerLinkSuccess = ^(NSDictionary *powerLinkData) {
        
        powerLinkView = [[CPPowerLinkView alloc] initWithFrame:CGRectMake(0, 0, powerLinkView.width, powerLinkView.height)
                                                 powerLinkInfo:powerLinkData
                                                   listingType:listingType];
        [powerLinkView setDelegate:self];
        
        [listCollectionView reloadData];
    };
    
    void (^powerLinkFailure)(NSError *);
    powerLinkFailure = ^(NSError *error) {
        
    };
    
    NSString *url = aPowerLinkInfo[@"url"];
    
    NSString *powerLinkParam = @"";
    powerLinkParam = [powerLinkParam stringByAppendingFormat:@"&referrer=%@", aReferrer];
    powerLinkParam = [powerLinkParam stringByAppendingFormat:@"&pageUrl=%@", aCurrentUrl];
    url = [url stringByReplacingOccurrencesOfString:@"{{powerLinkParam}}" withString:powerLinkParam];
    
    if (url) {
        [[CPRESTClient sharedClient] requestPowerLinkWithUrl:url
                                                     success:powerLinkSuccess
                                                     failure:powerLinkFailure];
    }
}

#pragma mark - Private Methods

- (void)openWebViewControllerWithUrl:(NSString *)url isPop:(BOOL)isPop
{
    if ([url isMatchedByRegex:@"/MW/Product/productBasicInfo.tmall"]) {
        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
        
        CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo isPop:isPop];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url isPop:isPop];
        [self.navigationController pushViewController:viewControlelr animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginStatusDidChange)
                                                     name:WebViewControllerNotification
                                                   object:nil];
    }
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

- (UIImage *)getRankImage:(NSInteger)count
{
    UIImage *image;
    
    if (count < 0) {
        image = [UIImage imageNamed:@"ic_s_rank_down.png"];
    }
    else if (count == 0) {
        image = [UIImage imageNamed:@"ic_s_rank_nor.png"];
    }
    else if (count > 0) {
        image = [UIImage imageNamed:@"ic_s_rank_up.png"];
    }
    
    return image;
}

- (NSString *)makeUrl:(NSString *)url key:(NSString *)key replaceString:(NSString *)replaceString
{
    NSArray *urlArray = [url componentsSeparatedByString:@"?"];
    NSArray *queryStrings = [urlArray.lastObject componentsSeparatedByString:@"&"];
    
    NSString *extractString = @"";
    for (NSString *keyValue in queryStrings) {
        NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
        
        if ([keyValueArray.firstObject isEqualToString:key]) {
            extractString = [NSString stringWithFormat:@"&%@", keyValue];
            break;
        }
    }
    
    NSString *returnUrl;
    if (!nilCheck(extractString)) {
        returnUrl = [url stringByReplacingOccurrencesOfString:extractString withString:replaceString];
    }
    else {
        returnUrl = [NSString stringWithFormat:@"%@%@", url, replaceString];
    }
    
    return returnUrl;
}

- (NSString *)makeUrl:(NSString *)url removeKey:(NSString *)removeKey
{
    NSString *resultUrl = [url componentsSeparatedByString:@"?"][0];
    NSArray *currentArray = [[url componentsSeparatedByString:@"?"][1] componentsSeparatedByString:@"&"];
    BOOL isFirstData = YES;
    
    for (NSString *keyValue in currentArray) {
        
        if ([keyValue rangeOfString:@"="].location != NSNotFound) {
            
            NSArray *key = [keyValue componentsSeparatedByString:@"="];
            if (![[key firstObject] isEqualToString:removeKey]) {
                
                NSString * value = @"";
                if ([[key firstObject] isEqualToString:@"searchKeyword"]) {
                    value = URLDecode([key lastObject]);
                    value = [Modules encodeAddingPercentEscapeString:value];
                }
                else {
                    value = [key lastObject];
                }
                
                resultUrl = [resultUrl stringByAppendingFormat:@"%@%@=%@", isFirstData ? @"?" : @"&", [key firstObject], value];
                isFirstData = NO;
            }
        }
    }
    
    return resultUrl;
}

- (BOOL)isSearchProductGridCellAlignment:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [listCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
    
    if (cell.frame.origin.x == 10) {
        return YES;
    }
    
    return NO;
}

- (void)touchSearchCaption:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    for (UIButton *adView in listCollectionView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == button.tag){
            return;
        }
    }
    
    if (searchCaptionInfo[@"adText"]) {
        
        UIImage *image = [[UIImage imageNamed:@"layer_s_popup_02.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
        
        UIButton *searchCaptionADView = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchCaptionADView setTag:button.tag];
        [searchCaptionADView setFrame:CGRectMake(8, listCollectionView.contentSize.height-listLayout.footerReferenceSize.height+hotProductView.frame.origin.y-2, kScreenBoundsWidth-14, 62)];
        [searchCaptionADView setBackgroundImage:image forState:UIControlStateNormal];
        [searchCaptionADView addTarget:self action:@selector(touchCloseADView:) forControlEvents:UIControlEventTouchUpInside];
        [listCollectionView addSubview:searchCaptionADView];
        
        NSString *ADtitle = searchCaptionInfo[@"adText"];
        
        UILabel *ADLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, CGRectGetWidth(searchCaptionADView.frame)-40, 40)];
        [ADLabel setBackgroundColor:[UIColor clearColor]];
        [ADLabel setFont:[UIFont systemFontOfSize:15]];
        [ADLabel setText:ADtitle];
        [ADLabel setTextColor:UIColorFromRGB(0xffffff)];
        [ADLabel setNumberOfLines:2];
        [searchCaptionADView addSubview:ADLabel];
        
        UIImageView *ADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchCaptionADView.frame)-36, 10, 14, 14)];
        [ADImageView setImage:[UIImage imageNamed:@"ic_s_close_02.png"]];
        [searchCaptionADView addSubview:ADImageView];
    }
    
}

- (void)moreUrlRequest
{
    if ([moreUrl rangeOfString:@"previousKwd"].location != NSNotFound) {
        
        //pageNo 추출
        NSString *pageNo = @"";
        NSArray *currentArray = [[moreUrl componentsSeparatedByString:@"?"][1] componentsSeparatedByString:@"&"];
        
        for (NSString *keyValue in currentArray) {
            
            if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                
                NSArray *key = [keyValue componentsSeparatedByString:@"="];
                if ([[key firstObject] isEqualToString:@"pageNo"]) {
                    pageNo = [pageNo stringByAppendingFormat:@"&%@=%@", [key firstObject], [key lastObject]];
                    break;
                }
            }
        }
        
        moreUrl = [currentUrl stringByReplacingOccurrencesOfString:@"&inKeyword" withString:@"&previousKwd"];
        moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"listing.tmall" withString:@"getMore.tmall"];
        moreUrl = [moreUrl stringByAppendingString:pageNo];
    }
    
    [self getProductList:moreUrl];
    
    //AccessLog - 페이징 처리 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE17"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE17"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPE04"];
    }
}

#pragma mark - ajaxCall

- (void)touchSearchProductAjaxCall:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    BOOL isExpanded = [collectionData.items[button.tag][@"isExpanded"] isEqualToString:@"Y"];
    if (isExpanded) {
        [self expandedSearchProductInfoSetting:sender];
        return;
    }
    
    NSDictionary *searchProductItems = collectionData.items[button.tag];
    NSString *ajaxUrl = searchProductItems[@"sellerInfoUrl"];
    
    [self startLoadingAnimation];
    [self sendSearchProductAjaxWithUrl:ajaxUrl sender:sender];
    
    //AccessLog - 셀러 더보기 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPH02"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPH02"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)expandedSearchProductInfoSetting:(id)sender
{
    UIButton *button = (UIButton *)sender;
    BOOL isExpanded = [collectionData.items[button.tag][@"isExpanded"] isEqualToString:@"Y"];
    
    //ExpandedInfo 셋팅
    [collectionData.items[button.tag] removeObjectForKey:@"isExpanded"];
    [collectionData.items[button.tag] setObject:isExpanded ? @"N" : @"Y" forKey:@"isExpanded"];
    
    //NO animation
    [UIView setAnimationsEnabled:NO];
    
    [listCollectionView performBatchUpdates:^{
        [listCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
}

- (void)sendSearchProductAjaxWithUrl:(NSString *)ajaxUrl sender:(id)sender
{
    void (^sellerInfoSuccess)(NSDictionary *);
    sellerInfoSuccess = ^(NSDictionary *sellerInfoData) {
        
//        if (sellerInfoData && [sellerInfoData count] > 0) {
        if (![sellerInfoData[@"rsCd"] isEqualToString:@"FAIL"]) {
            UIButton *button = (UIButton *)sender;

            collectionData.items[button.tag] = [collectionData.items[button.tag] mutableCopy];

            //ajax정보 셋팅
            [collectionData.items[button.tag] removeObjectForKey:@"sellerHmpgUrl"];
            [collectionData.items[button.tag] removeObjectForKey:@"sellerMemNo"];
            [collectionData.items[button.tag] removeObjectForKey:@"psmGrd"];
            [collectionData.items[button.tag] removeObjectForKey:@"psm"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"sellerHmpgUrl"] forKey:@"sellerHmpgUrl"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"sellerMemNo"] forKey:@"sellerMemNo"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"psmGrd"] forKey:@"psmGrd"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"psm"] forKey:@"psm"];

            [self expandedSearchProductInfoSetting:sender];
            [self stopLoadingAnimation];
        }
        else {
            [self stopLoadingAnimation];
        }
    };
    
    void (^sellerInfoFailure)(NSError *);
    sellerInfoFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    if (ajaxUrl) {
        [[CPRESTClient sharedClient] requestSellerInfoWithUrl:ajaxUrl
                                                     success:sellerInfoSuccess
                                                     failure:sellerInfoFailure];
    }
}

- (void)touchSearchProductBannerAjaxCall:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    BOOL isExpanded = [collectionData.items[button.tag][@"isExpanded"] isEqualToString:@"Y"];
    if (isExpanded) {
        [self expandedSearchProductBannerInfoSetting:sender];
        return;
    }
    
    NSDictionary *searchProductBannerItems = collectionData.items[button.tag];
    NSString *ajaxUrl = searchProductBannerItems[@"sellerInfoUrl"];
    
    [self startLoadingAnimation];
    [self sendSearchProductBannerAjaxWithUrl:ajaxUrl sender:sender];
}

- (void)expandedSearchProductBannerInfoSetting:(id)sender
{
    UIButton *button = (UIButton *)sender;
    BOOL isExpanded = [collectionData.items[button.tag][@"isExpanded"] isEqualToString:@"Y"];
    
    //ExpandedInfo 셋팅
    [collectionData.items[button.tag] removeObjectForKey:@"isExpanded"];
    [collectionData.items[button.tag] setObject:isExpanded ? @"N" : @"Y" forKey:@"isExpanded"];
    
    //NO animation
    [UIView setAnimationsEnabled:NO];
    
    [listCollectionView performBatchUpdates:^{
        [listCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
}

- (void)sendSearchProductBannerAjaxWithUrl:(NSString *)ajaxUrl sender:(id)sender
{
    void (^sellerInfoSuccess)(NSDictionary *);
    sellerInfoSuccess = ^(NSDictionary *sellerInfoData) {
        
//        if (sellerInfoData && [sellerInfoData count] > 0) {
        if (![sellerInfoData[@"rsCd"] isEqualToString:@"FAIL"]) {
            UIButton *button = (UIButton *)sender;
            
            collectionData.items[button.tag] = [collectionData.items[button.tag] mutableCopy];
            
            //ajax정보 셋팅
            [collectionData.items[button.tag] removeObjectForKey:@"sellerHmpgUrl"];
            [collectionData.items[button.tag] removeObjectForKey:@"sellerMemNo"];
            [collectionData.items[button.tag] removeObjectForKey:@"psmGrd"];
            [collectionData.items[button.tag] removeObjectForKey:@"psm"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"sellerHmpgUrl"] forKey:@"sellerHmpgUrl"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"sellerMemNo"] forKey:@"sellerMemNo"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"psmGrd"] forKey:@"psmGrd"];
            [collectionData.items[button.tag] setObject:[sellerInfoData objectForKey:@"psm"] forKey:@"psm"];
            
            [self expandedSearchProductBannerInfoSetting:sender];
            [self stopLoadingAnimation];
        }
        else {
            [self stopLoadingAnimation];
        }
    };
    
    void (^sellerInfoFailure)(NSError *);
    sellerInfoFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    if (ajaxUrl) {
        [[CPRESTClient sharedClient] requestSellerInfoWithUrl:ajaxUrl
                                                      success:sellerInfoSuccess
                                                      failure:sellerInfoFailure];
    }
}

#pragma mark - Selectos

- (void)touchFilterButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSString *key = filterItems[button.tag][@"key"];
    
    if (key) {
        [self didTouchFilterButton:key];
    }
}

- (void)touchSortTypeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *sortItemInfo = sortItems[button.tag];
    
    if (sortItemInfo) {
        NSString *url = sortItemInfo[@"url"];
        
        if (!(url && [[url trim] length] > 0)) {
            return;
        }
        
        NSString *otherParam = @"";
        NSString *keyword = @"";
        
        if ([url hasPrefix:@"app://gosearch/"]) {
            url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
            url = URLDecode(url);
//        url = [url stringByReplacingOccurrencesOfString:@"{{searchParameter}}" withString:searchParameter];
            
            //searchKeyword 추출 : 보낼 때 인코딩 한번 더 필요함.
            NSArray *currentArray = [searchParameter componentsSeparatedByString:@"&"];
            
            for (NSString *keyValue in currentArray) {
                
                if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                    
                    NSArray *key = [keyValue componentsSeparatedByString:@"="];
                    if ([[key firstObject] isEqualToString:@"searchKeyword"] || [[key firstObject] isEqualToString:@"previousKwd"] || [[key firstObject] isEqualToString:@"inKeyword"]) {
                        keyword = [keyword stringByAppendingFormat:@"&%@=%@", [key firstObject], [[key lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    if ([[key firstObject] isEqualToString:@"dlvType"] || [[key firstObject] isEqualToString:@"pointYN"] || [[key firstObject] isEqualToString:@"discountYN"] || [[key firstObject] isEqualToString:@"custBenefit"] || [[key firstObject] isEqualToString:@"myWay"] || [[key firstObject] isEqualToString:@"toPrice"] || [[key firstObject] isEqualToString:@"fromPrice"]) {
                        keyword = [keyword stringByAppendingFormat:@"%@%@=%@", @"&", [key firstObject], [key lastObject]];
                    }
                }
            }
            
            //searchKeyword 제거
            currentArray = [keyword componentsSeparatedByString:@"&"];
            for (NSString *keyValue in currentArray) {
                
                if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                    
                    NSArray *key = [keyValue componentsSeparatedByString:@"="];
                    if (![[key firstObject] isEqualToString:@"searchKeyword"] && ![[key firstObject] isEqualToString:@"previousKwd"] && ![[key firstObject] isEqualToString:@"sortCd"] && ![[key firstObject] isEqualToString:@"inKeyword"]) {
                        otherParam = [otherParam stringByAppendingFormat:@"%@%@=%@", @"&", [key firstObject], [key lastObject]];
                    }
                }
            }
            
//            searchParameter = [NSString stringWithFormat:@"%@%@", keyword, otherParam];
            searchParameter = [NSString stringWithFormat:@"%@", otherParam];
            url = [url stringByReplacingOccurrencesOfString:@"{{searchParameter}}" withString:searchParameter];
        }
        
        [self getProductList:url];
    }
    
    [self removeSortTypeContainerView];
    
    //AccessLog - 연관검색어 하단 텍스트 터치 시
    [[AccessLog sharedInstance] sendAccessLogWithCode:sortItemInfo[@"clickCd"]];
}

- (void)touchSortTypeInfoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self removeSortTypeContainerView];
    NSDictionary *sortInfo = collectionData.items[button.tag][@"sortInfo"];
    
    UIImage *image = [[UIImage imageNamed:@"layer_s_popup.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    CGFloat viewHeight = 0;
    
    UIButton *infoView = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoView setTag:SORTTYPE_INFOBUTTON_TAG];
    [infoView setBackgroundImage:image forState:UIControlStateNormal];
    [infoView addTarget:self action:@selector(closeSortTypeInfoButton:) forControlEvents:UIControlEventTouchUpInside];
    [listCollectionView addSubview:infoView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 200, 16)];
    [titleLabel setText:sortInfo[@"title"]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [infoView addSubview:titleLabel];
    
    viewHeight += CGRectGetMinY(titleLabel.frame) + CGRectGetHeight(titleLabel.frame);
    
    UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-48, 10, 18, 17)];
    [closeImageView setImage:[UIImage imageNamed:@"ic_s_close.png"]];
    [infoView addSubview:closeImageView];
    
    NSString *descStr = sortInfo[@"desc"];
    CGSize descSize = [descStr sizeWithFont:[UIFont boldSystemFontOfSize:13]];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, viewHeight+10, kScreenBoundsWidth-40, kScreenBoundsWidth-40 < descSize.width ? 32 : 14)];
    [descLabel setText:descStr];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    [descLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [descLabel setTextColor:UIColorFromRGB(0x333333)];
    [descLabel setNumberOfLines:0];
    [infoView addSubview:descLabel];
    
    viewHeight += 10 + CGRectGetHeight(descLabel.frame);
    
    if (sortInfo[@"subDesc1"] && sortInfo[@"subDesc2"] && sortInfo[@"subDesc3"]) {
        NSString *subDesc1Str = sortInfo[@"subDesc1"];
        CGSize subDesc1Size = [subDesc1Str sizeWithFont:[UIFont systemFontOfSize:13]];
        
        NSString *subDesc1DotStr = @"・ ";
        CGSize subDesc1DotSize = [subDesc1DotStr sizeWithFont:[UIFont systemFontOfSize:13]];
        
        UILabel *subDesc1DotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(descLabel.frame)+9, subDesc1DotSize.width, 14)];
        [subDesc1DotLabel setText:subDesc1DotStr];
        [subDesc1DotLabel setBackgroundColor:[UIColor clearColor]];
        [subDesc1DotLabel setFont:[UIFont systemFontOfSize:13]];
        [subDesc1DotLabel setTextColor:UIColorFromRGB(0x868ba8)];
        [infoView addSubview:subDesc1DotLabel];
        
        UILabel *subDesc1Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subDesc1DotLabel.frame), CGRectGetMaxY(descLabel.frame)+9, kScreenBoundsWidth-50-subDesc1DotSize.width, kScreenBoundsWidth-50-subDesc1DotSize.width < subDesc1Size.width ? 32 : 14)];
        [subDesc1Label setText:subDesc1Str];
        [subDesc1Label setBackgroundColor:[UIColor clearColor]];
        [subDesc1Label setFont:[UIFont systemFontOfSize:13]];
        [subDesc1Label setTextColor:UIColorFromRGB(0x868ba8)];
        [subDesc1Label setNumberOfLines:0];
        [infoView addSubview:subDesc1Label];
        
        viewHeight += 9 + CGRectGetHeight(subDesc1Label.frame);
        
        NSString *subDesc2Str = sortInfo[@"subDesc2"];
        CGSize subDesc2Size = [subDesc2Str sizeWithFont:[UIFont systemFontOfSize:13]];
        
        NSString *subDesc2DotStr = @"・ ";
        CGSize subDesc2DotSize = [subDesc2DotStr sizeWithFont:[UIFont systemFontOfSize:13]];
        
        UILabel *subDesc2DotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(subDesc1Label.frame)+3, subDesc2DotSize.width, 14)];
        [subDesc2DotLabel setText:subDesc2DotStr];
        [subDesc2DotLabel setBackgroundColor:[UIColor clearColor]];
        [subDesc2DotLabel setFont:[UIFont systemFontOfSize:13]];
        [subDesc2DotLabel setTextColor:UIColorFromRGB(0x868ba8)];
        [infoView addSubview:subDesc2DotLabel];
        
        UILabel *subDesc2Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subDesc2DotLabel.frame), CGRectGetMaxY(subDesc1Label.frame)+3, kScreenBoundsWidth-50-subDesc2DotSize.width, kScreenBoundsWidth-50-subDesc2DotSize.width < subDesc2Size.width ? 32 : 14)];
        [subDesc2Label setText:subDesc2Str];
        [subDesc2Label setBackgroundColor:[UIColor clearColor]];
        [subDesc2Label setFont:[UIFont systemFontOfSize:13]];
        [subDesc2Label setTextColor:UIColorFromRGB(0x868ba8)];
        [subDesc2Label setNumberOfLines:0];
        [infoView addSubview:subDesc2Label];
        
        viewHeight += 3 + CGRectGetHeight(subDesc2Label.frame);
        
        NSString *subDesc3Str = sortInfo[@"subDesc3"];
        CGSize subDesc3Size = [subDesc3Str sizeWithFont:[UIFont systemFontOfSize:13]];
        
        NSString *subDesc3DotStr = @"・ ";
        CGSize subDesc3DotSize = [subDesc3DotStr sizeWithFont:[UIFont systemFontOfSize:13]];
        
        UILabel *subDesc3DotLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(subDesc2Label.frame)+3, subDesc3DotSize.width, 14)];
        [subDesc3DotLabel setText:subDesc2DotStr];
        [subDesc3DotLabel setBackgroundColor:[UIColor clearColor]];
        [subDesc3DotLabel setFont:[UIFont systemFontOfSize:13]];
        [subDesc3DotLabel setTextColor:UIColorFromRGB(0x868ba8)];
        [infoView addSubview:subDesc3DotLabel];
        
        UILabel *subDesc3Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subDesc3DotLabel.frame), CGRectGetMaxY(subDesc2Label.frame)+3, kScreenBoundsWidth-50-subDesc3DotSize.width, kScreenBoundsWidth-50-subDesc3DotSize.width < subDesc3Size.width ? 32 : 14)];
        [subDesc3Label setText:subDesc3Str];
        [subDesc3Label setBackgroundColor:[UIColor clearColor]];
        [subDesc3Label setFont:[UIFont systemFontOfSize:13]];
        [subDesc3Label setTextColor:UIColorFromRGB(0x868ba8)];
        [subDesc3Label setNumberOfLines:0];
        [infoView addSubview:subDesc3Label];
        
        viewHeight += 3 + CGRectGetHeight(subDesc3Label.frame);
    }
    
    UICollectionViewCell *cell = [listCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[collectionData.sorting[0][@"dataIndex"] integerValue] inSection:0]];
    [infoView setFrame:CGRectMake(8, CGRectGetMaxY(cell.frame)-8, kScreenBoundsWidth-16, viewHeight+16)];
}

- (void)closeSortTypeInfoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    for (UIButton *adView in listCollectionView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == button.tag){
            [adView removeFromSuperview];
        }
    }
}

//popularSearch
- (void)touchPopularButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == CPPopularButtonTypeHot) {
        [popularSearchTextHotButton setSelected:YES];
        [popularSearchTextRisingButton setSelected:NO];
        [popularSearchTextPopularButton setSelected:NO];
        
//        for (UIView *view in popularSearchTextHotButton.subviews){
//            [view setHidden:[view isKindOfClass:[UIButton class]] && view.tag == 0];
//        }
    }
    else if (button.tag == CPPopularButtonTypeRising) {
        [popularSearchTextHotButton setSelected:NO];
        [popularSearchTextRisingButton setSelected:YES];
        [popularSearchTextPopularButton setSelected:NO];
        
//        for (UIView *view in popularSearchTextHotButton.subviews){
//            [view setHidden:[view isKindOfClass:[UIButton class]] && view.tag == 1];
//        }
    }
    else if (button.tag == CPPopularButtonTypePopular) {
        [popularSearchTextHotButton setSelected:NO];
        [popularSearchTextRisingButton setSelected:NO];
        [popularSearchTextPopularButton setSelected:YES];
        
//        for (UIView *view in popularSearchTextHotButton.subviews){
//            [view setHidden:[view isKindOfClass:[UIButton class]] && view.tag == 2];
//        }
    }
    
    [popularSearchTextiCarouselView scrollToItemAtIndex:button.tag animated:NO];
    
    //AccessLog - 핫테마 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        if (button.tag == CPPopularButtonTypeHot) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF01"];
        }
        else if (button.tag == CPPopularButtonTypeRising) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF03"];
        }
        else if (button.tag == CPPopularButtonTypePopular) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF05"];
        }
    }
    else if ([listingType isEqualToString:@"category"]) {
        if (button.tag == CPPopularButtonTypeHot) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF01"];
        }
        else if (button.tag == CPPopularButtonTypeRising) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF03"];
        }
        else if (button.tag == CPPopularButtonTypePopular) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF05"];
        }
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchHotKeywordButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger separator = button.tag / POPULAR_SEARCH_TEXT_TAG;
    NSInteger index = button.tag - separator*POPULAR_SEARCH_TEXT_TAG;
    NSString *separatorStr = @"hotItems";
    if (separator == 1) {
        separatorStr = @"risingItems";
    }
    else if (separator == 2) {
        separatorStr = @"popularItems";
    }
    
    //AccessLog - 핫테마 내부 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        if ([separatorStr isEqualToString:@"hotItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF02"];
        }
        else if ([separatorStr isEqualToString:@"risingItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF04"];
        }
        else if ([separatorStr isEqualToString:@"popularItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPF06"];
        }
    }
    else if ([listingType isEqualToString:@"category"]) {
        if ([separatorStr isEqualToString:@"hotItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF02"];
        }
        else if ([separatorStr isEqualToString:@"risingItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF04"];
        }
        else if ([separatorStr isEqualToString:@"popularItems"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPF06"];
        }
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
    
    NSArray *relatedSearchTextItems = popularSearchTextInfo[separatorStr];
    NSString *keyword = relatedSearchTextItems[index][@"keyword"];
    
    if (keyword) {
//        keyword = [Modules encodeAddingPercentEscapeString:keyword];
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:currentUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)touchRelatedKeywordButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSArray *relatedSearchTextItems = collectionData.relatedSearchText[0][@"items"];
    
    NSString *keyword = relatedSearchTextItems[button.tag-RELATED_SEARCH_BUTTON_TAG][@"text"];
    
    if (keyword) {
//        keyword = [Modules encodeAddingPercentEscapeString:keyword];
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:currentUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
    
    //AccessLog - 연관검색어 하단 텍스트 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA04"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)touchRelatedOpenButton:(id)sender
{
    BOOL isExpanded = [relatedSearchTextInfo[@"isExpanded"] isEqualToString:@"Y"];
    
    //ExpandedInfo 셋팅
    [relatedSearchTextInfo removeObjectForKey:@"isExpanded"];
    [relatedSearchTextInfo setObject:isExpanded ? @"N" : @"Y" forKey:@"isExpanded"];
    
    //NO animation
    [UIView setAnimationsEnabled:NO];
    
    //섹션헤더 리로드
    [listCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
    
    [UIView setAnimationsEnabled:YES];
    
    //AccessLog - 연관검색어 하단 더보기 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA05"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)didTouchNoSearchData:(NSString *)linkUrl
{
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:linkUrl keyword:nil referrer:currentUrl];
    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)loginStatusDidChange
{
    [cpFooterView reloadLoginStatus];
}

- (void)reloadAfterLogin
{
    //로그인 후 API재호출
    [self getProductList:currentUrl];
}

- (void)touchCloseADView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    for (UIButton *adView in listCollectionView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == button.tag){
            [adView removeFromSuperview];
        }
    }
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchMenuButton
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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

- (void)didTouchSearchButton:(NSString *)keywordUrl
{
    if (keywordUrl) {
        [self openWebViewControllerWithUrl:keywordUrl animated:YES];
    }
}

- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword
{
    if (![searchKeyword isEqualToString:keyword]) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:currentUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
}

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [viewController setWantsFullScreenLayout:YES];
//    }
    
//    viewController.defaultUrl = keywordUrl;
    viewController.isSearchText = YES;
    viewController.defaultText = [searchKeyword stringByReplacingPercentEscapesUsingEncoding:DEFAULT_ENCODING];
    
    [self presentViewController:viewController animated:NO completion:nil];
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:currentUrl];
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
            [self getProductList:currentUrl];
            break;
        case CPToolBarButtonTypeTop:
            [listCollectionView setContentOffset:CGPointZero animated:YES];
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
    BOOL isNoData = collectionData.items.count == 0 || noData[@"noData"];
    NSInteger bestItemCount = (isNoData ? 1 : collectionData.items.count);
    
    return bestItemCount;
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
        }
        @catch (NSException *exception) {
            headerView = saveHeaderView;
        }
        @finally {}
        
        for (UIView *subView in [headerView subviews]) {
            [subView removeFromSuperview];
        }
        
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
        
        CGFloat headerHeight = 0;
        
        if ([searchCaptionInfo count] > 0) {
            //searchCaption
            UIView *searchCaptionView = [[UIView alloc] initWithFrame:CGRectMake(10, headerHeight+5, kScreenBoundsWidth-20, 24)];
            [searchCaptionView setBackgroundColor:[UIColor clearColor]];
            [footerView addSubview:searchCaptionView];
            
            headerHeight += 19+CELL_GEP;
            
            NSString *title = [searchCaptionInfo objectForKey:@"title"];
            CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
            
            //title
            UILabel *searchCaptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, titleSize.width, 15)];
            [searchCaptionTitleLabel setBackgroundColor:[UIColor clearColor]];
            [searchCaptionTitleLabel setFont:[UIFont systemFontOfSize:14]];
            [searchCaptionTitleLabel setText:title];
            [searchCaptionTitleLabel setTextColor:UIColorFromRGB(0x333333)];
            [searchCaptionTitleLabel setTextAlignment:NSTextAlignmentLeft];
            [searchCaptionTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [searchCaptionView addSubview:searchCaptionTitleLabel];
            
            NSString *adTitle = @"AD";
            CGSize adTitleSize = [adTitle sizeWithFont:[UIFont systemFontOfSize:11]];
            
            //AD Button
            UIButton *searchCaptionADButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [searchCaptionADButton setFrame:CGRectMake(CGRectGetMaxX(searchCaptionView.frame)-adTitleSize.width-20, 0, adTitleSize.width+20, 26)];
            [searchCaptionADButton setTitle:@"AD" forState:UIControlStateNormal];
            [searchCaptionADButton setTitleColor:UIColorFromRGB(0x757b9c) forState:UIControlStateNormal];
            [searchCaptionADButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [searchCaptionADButton setTag:SEARCH_BUTTON_TAG];
            [searchCaptionADButton addTarget:self action:@selector(touchSearchCaption:) forControlEvents:UIControlEventTouchUpInside];
            [searchCaptionView addSubview:searchCaptionADButton];
        }
        
        if ([hotProductInfo count] > 0) {
            //hotProduct
            [hotProductView setFrame:CGRectMake(10, headerHeight+10, hotProductView.width, hotProductView.height+1)];
            [footerView addSubview:hotProductView];
            
            UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, hotProductView.height, hotProductView.width, 1)];
            [shadowView setBackgroundColor:UIColorFromRGB(0xd1d1d6)];
            [shadowView setAlpha:0.5];
            [hotProductView addSubview:shadowView];
            
            headerHeight += hotProductView.height + (hotProductView.height == 0 ? 0 : CELL_GEP);
        }
        
        //하단 연관검색어
        if ([relatedSearchTextInfo count] > 0) {
            
            UIView *relatedSearchTextCellContentView = [[UIView alloc] initWithFrame:CGRectMake(10, headerHeight+10, kScreenBoundsWidth-20, 37)];
            [relatedSearchTextCellContentView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
            [footerView addSubview:relatedSearchTextCellContentView];
            
            //icon
            UIImageView *relatedIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8.5f, 29, 19)];
            [relatedIconImageView setImage:[UIImage imageNamed:@"tag_s_01.png"]];
            [relatedSearchTextCellContentView addSubview:relatedIconImageView];
            
            //keyword                                                                CGRectGetHeight(self.relatedSearchTextView.frame))];
            UIView *relatedKeywordView = [[UIView alloc] initWithFrame:CGRectZero];
            [relatedSearchTextCellContentView addSubview:relatedKeywordView];
            
            //arrow button
            UIButton *relatedOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(relatedSearchTextCellContentView.frame)-35, 0, 35, 36)];
            [relatedOpenButton setBackgroundColor:[UIColor clearColor]];
            [relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_down_01.png"] forState:UIControlStateNormal];
            [relatedOpenButton addTarget:self action:@selector(touchRelatedOpenButton:) forControlEvents:UIControlEventTouchUpInside];
            [relatedSearchTextCellContentView addSubview:relatedOpenButton];
            
            //
            NSArray *relatedSearchTextItems = relatedSearchTextInfo[@"items"];
            
            NSInteger itemCount = ceilf([[NSNumber numberWithUnsignedInteger:relatedSearchTextItems.count] floatValue] / 2);
            
            for (UIView *subView in relatedKeywordView.subviews) {
                [subView removeFromSuperview];
            }
            
            if ([relatedSearchTextInfo[@"isExpanded"] isEqualToString:@"Y"]) {
                
                [relatedSearchTextCellContentView setFrame:CGRectMake(10, headerHeight+10, kScreenBoundsWidth-20, itemCount*36)];
                [relatedKeywordView setFrame:CGRectMake(CGRectGetMaxX(relatedIconImageView.frame)+8,
                                                        0,
                                                        CGRectGetWidth(relatedSearchTextCellContentView.frame)-(CGRectGetMaxX(relatedIconImageView.frame)+8+45),
                                                        itemCount*36)];
                [relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(relatedSearchTextCellContentView.frame)-35, CGRectGetHeight(relatedSearchTextCellContentView.frame)-36, 35, 36)];
                [relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_up.png"] forState:UIControlStateNormal];
                
                CGFloat buttonX = 0;
                CGFloat buttonY = 0;
                CGFloat buttonWidth = CGRectGetWidth(relatedKeywordView.frame)/2;
                
                for (NSInteger i = 0; i < relatedSearchTextItems.count; i++) {
                    NSString *keyword = relatedSearchTextItems[i][@"text"];
                    
                    UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [keywordButton setBackgroundColor:[UIColor clearColor]];
                    [keywordButton setFrame:CGRectMake(buttonX, buttonY, buttonWidth-5, 36)];
                    [keywordButton setTitle:keyword forState:UIControlStateNormal];
                    [keywordButton setTitleColor:UIColorFromRGB(0x255b84) forState:UIControlStateNormal];
                    [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                    [keywordButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
                    [keywordButton addTarget:self action:@selector(touchRelatedKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
                    [keywordButton setTag:i+RELATED_SEARCH_BUTTON_TAG];
                    [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                    [relatedKeywordView addSubview:keywordButton];
                    
                    buttonX += buttonWidth;
                    NSLog(@"%@", NSStringFromCGRect(keywordButton.frame));
                    if ((i + 1) % 2 == 0) {
                        buttonY += 36;
                        buttonX = 0;
                    }
                }
            }
            else {
                [relatedSearchTextCellContentView setFrame:CGRectMake(10, headerHeight+10, kScreenBoundsWidth-20, 36)];
                [relatedKeywordView setFrame:CGRectMake(CGRectGetMaxX(relatedIconImageView.frame)+8,
                                                        0,
                                                        CGRectGetWidth(relatedSearchTextCellContentView.frame)-(CGRectGetMaxX(relatedIconImageView.frame)+8+45),
                                                        CGRectGetHeight(relatedSearchTextCellContentView.frame))];
                [relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(relatedSearchTextCellContentView.frame)-35, 0, 35, 36)];
                [relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_down_01.png"] forState:UIControlStateNormal];
                
                CGFloat buttonX = 0;
                NSInteger lastIndex = 0;
                
                for (NSInteger i = 0; i < relatedSearchTextItems.count; i++) {
                    NSMutableString *keyword = [[NSMutableString alloc] init];
                    [keyword appendString:relatedSearchTextItems[i][@"text"]];
                    [keyword appendString:@","];
                    
                    CGSize labelSize = [keyword sizeWithFont:[UIFont systemFontOfSize:14]];
                    
                    CGFloat buttonWidth = labelSize.width+5;
                    
                    UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [keywordButton setBackgroundColor:[UIColor clearColor]];
                    [keywordButton setFrame:CGRectMake(buttonX, 0, buttonWidth, CGRectGetHeight(relatedSearchTextCellContentView.frame))];
                    [keywordButton setTitleColor:UIColorFromRGB(0x255b84) forState:UIControlStateNormal];
                    [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                    [keywordButton addTarget:self action:@selector(touchRelatedKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
                    [keywordButton setTag:i+RELATED_SEARCH_BUTTON_TAG];
                    [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                    [keywordButton setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width+13, 0, 0)];
                    
                    buttonX += buttonWidth;
                    
                    //            NSLog(@"%@, %@", NSStringFromCGRect(keywordButton.frame), NSStringFromCGRect(self.relatedKeywordView.frame));
                    //            NSLog(@"%f, %f", CGRectGetMaxX(keywordButton.frame), CGRectGetMinX(self.relatedOpenButton.frame));
                    if (CGRectGetMaxX(keywordButton.frame)+30 >= CGRectGetMinX(relatedOpenButton.frame)) {
                        [relatedOpenButton setHidden:NO];
                        break;
                    }
                    else {
                        [keywordButton setTitle:keyword forState:UIControlStateNormal];
                        [relatedKeywordView addSubview:keywordButton];
                        [relatedOpenButton setHidden:YES];
                        lastIndex = i+RELATED_SEARCH_BUTTON_TAG;
                    }
                }
                
                NSString *keyword = relatedSearchTextItems[lastIndex-RELATED_SEARCH_BUTTON_TAG][@"text"];
                UIButton *lastKeywordButton = (UIButton *)[relatedKeywordView viewWithTag:lastIndex];
                [lastKeywordButton setTitle:keyword forState:UIControlStateNormal];
            }
            
            headerHeight += CGRectGetHeight(relatedSearchTextCellContentView.frame);
            
            UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(relatedSearchTextCellContentView.frame)-1, kScreenBoundsWidth-20, 1)];
            [underLineView setBackgroundColor:UIColorFromRGB(0xd1d1d6)];
            [relatedSearchTextCellContentView addSubview:underLineView];
            
            headerHeight += 10;
        }
        
        if ([popularSearchTextInfo count] > 0) {
            //popularSearchText
            UIView *popularSearchTextCellContentView = [[UIView alloc] initWithFrame:CGRectMake(10, headerHeight+11, kScreenBoundsWidth-20, ktPopularSearchText)];
            [popularSearchTextCellContentView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
            [footerView addSubview:popularSearchTextCellContentView];
            
            headerHeight += ktPopularSearchText+CELL_GEP;
            
            [popularSearchTextHotButton setFrame:CGRectMake(0, 0, CGRectGetWidth(popularSearchTextCellContentView.frame)/3-1, 40)];
            [popularSearchTextHotButton setTag:CPPopularButtonTypeHot];
            [popularSearchTextHotButton setTitle:@"HOT 테마" forState:UIControlStateNormal];
            [popularSearchTextHotButton setBackgroundImage:[UIImage imageNamed:@"bg_eeeeee.png"] forState:UIControlStateNormal];
            [popularSearchTextHotButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateHighlighted];
            [popularSearchTextHotButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateSelected];
            [popularSearchTextHotButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [popularSearchTextHotButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
            [popularSearchTextHotButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateSelected];
            [popularSearchTextHotButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [popularSearchTextHotButton addTarget:self action:@selector(touchPopularButton:) forControlEvents:UIControlEventTouchUpInside];
            [popularSearchTextCellContentView addSubview:popularSearchTextHotButton];
            
//            UIView *firstUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(popularSearchTextHotButton.frame)-1, CGRectGetWidth(popularSearchTextHotButton.frame), 1)];
//            [firstUnderLineView setTag:0];
//            [firstUnderLineView setHidden:YES];
//            [firstUnderLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
//            [popularSearchTextHotButton addSubview:firstUnderLineView];
            
            UIView *firstMidLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(popularSearchTextHotButton.frame), 0, 1, CGRectGetHeight(popularSearchTextHotButton.frame))];
            [firstMidLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
            [popularSearchTextCellContentView addSubview:firstMidLineView];
            
            [popularSearchTextRisingButton setFrame:CGRectMake(CGRectGetWidth(popularSearchTextCellContentView.frame)/3, 0, CGRectGetWidth(popularSearchTextCellContentView.frame)/3-1, 40)];
            [popularSearchTextRisingButton setTag:CPPopularButtonTypeRising];
            [popularSearchTextRisingButton setTitle:@"급상승" forState:UIControlStateNormal];
            [popularSearchTextRisingButton setBackgroundImage:[UIImage imageNamed:@"bg_eeeeee.png"] forState:UIControlStateNormal];
            [popularSearchTextRisingButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateHighlighted];
            [popularSearchTextRisingButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateSelected];
            [popularSearchTextRisingButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [popularSearchTextRisingButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
            [popularSearchTextRisingButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateSelected];
            [popularSearchTextRisingButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [popularSearchTextRisingButton addTarget:self action:@selector(touchPopularButton:) forControlEvents:UIControlEventTouchUpInside];
            [popularSearchTextCellContentView addSubview:popularSearchTextRisingButton];
            
//            UIView *secondUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(popularSearchTextRisingButton.frame)-1, CGRectGetWidth(popularSearchTextRisingButton.frame), 1)];
//            [secondUnderLineView setTag:1];
//            [secondUnderLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
//            [popularSearchTextRisingButton addSubview:secondUnderLineView];
            
            UIView *secondMidLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(popularSearchTextRisingButton.frame), 0, 1, CGRectGetHeight(popularSearchTextRisingButton.frame))];
            [secondMidLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
            [popularSearchTextCellContentView addSubview:secondMidLineView];
            
            [popularSearchTextPopularButton setFrame:CGRectMake(CGRectGetWidth(popularSearchTextCellContentView.frame)/3*2, 0, CGRectGetWidth(popularSearchTextCellContentView.frame)/3, 40)];
            [popularSearchTextPopularButton setTag:CPPopularButtonTypePopular];
            [popularSearchTextPopularButton setTitle:@"인기" forState:UIControlStateNormal];
            [popularSearchTextPopularButton setBackgroundImage:[UIImage imageNamed:@"bg_eeeeee.png"] forState:UIControlStateNormal];
            [popularSearchTextPopularButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateHighlighted];
            [popularSearchTextPopularButton setBackgroundImage:[UIImage imageNamed:@"bg_ffffff.png"] forState:UIControlStateSelected];
            [popularSearchTextPopularButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [popularSearchTextPopularButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateHighlighted];
            [popularSearchTextPopularButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateSelected];
            [popularSearchTextPopularButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [popularSearchTextPopularButton addTarget:self action:@selector(touchPopularButton:) forControlEvents:UIControlEventTouchUpInside];
            [popularSearchTextCellContentView addSubview:popularSearchTextPopularButton];
            
//            UIView *thirdUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(popularSearchTextPopularButton.frame)-1, CGRectGetWidth(popularSearchTextPopularButton.frame), 1)];
//            [thirdUnderLineView setTag:2];
//            [thirdUnderLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
//            [popularSearchTextPopularButton addSubview:thirdUnderLineView];
            
            [popularSearchTextiCarouselView setFrame:CGRectMake(0, 40, kScreenBoundsWidth-20, 238)];
            [popularSearchTextiCarouselView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
            [popularSearchTextiCarouselView setType:iCarouselTypeLinear];
            [popularSearchTextiCarouselView setDataSource:self];
            [popularSearchTextiCarouselView setDelegate:self];;
            [popularSearchTextiCarouselView setClipsToBounds:YES];
            [popularSearchTextiCarouselView setPagingEnabled:NO];
            [popularSearchTextiCarouselView setScrollEnabled:NO];
            [popularSearchTextCellContentView addSubview:popularSearchTextiCarouselView];
            
            UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(popularSearchTextiCarouselView.frame)-1, kScreenBoundsWidth-20, 1)];
            [shadowView setBackgroundColor:UIColorFromRGB(0xd1d1d6)];
            [shadowView setAlpha:0.5];
            [popularSearchTextCellContentView addSubview:shadowView];
        }
        
        //powerLink
        [powerLinkView setFrame:CGRectMake(10, headerHeight+10, powerLinkView.width, powerLinkView.height)];
        [footerView addSubview:powerLinkView];
        
        headerHeight += powerLinkView.height + (powerLinkView.height == 0 ? 0 : CELL_GEP);
        
        //Line Banner
        CPBannerView *footerLineBannerView = [[CPBannerView alloc] initWithFrame:CGRectMake(0, headerHeight+10, kScreenBoundsWidth, kLineBannerHeight) bannerInfo:lineBannerInfo];
        [footerLineBannerView setFrame:CGRectMake(0, headerHeight+10, footerLineBannerView.width, footerLineBannerView.height)];
        [footerLineBannerView setDelegate:self];
        [footerView addSubview:footerLineBannerView];
        
        headerHeight += footerLineBannerView.height+CELL_GEP;
        
        //footerView
        [cpFooterView setFrame:CGRectMake(0, headerHeight, cpFooterView.width, cpFooterView.height)];
        [cpFooterView setDelegate:self];
        [footerView addSubview:cpFooterView];
        
        headerHeight += cpFooterView.height;
        
        [listLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, headerHeight)];
        reusableview = footerView;
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = @"noData";
    
    if (collectionData.items.count > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic = collectionData.items[indexPath.row];
        groupName = dic[@"groupName"];
        
        if ([groupName isEqualToString:@"noSearchData"]) {
            //NASRPH01 검색결과없음 노출
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPH01"];
        }
    }
    
    [[CPCommonInfo sharedInfo] setGroupName:groupName];
    CPCollectionViewCommonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:groupName forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setData:collectionData indexPath:indexPath];
    
    if ([groupName isEqualToString:@"searchFilter"]) {
        filterCellIndexPath = indexPath;
    }
    
    if (indexPath.row >= collectionData.items.count-10 && needsRefresh) {
        //scroll에 대한 상품 더보기 처리
        needsRefresh = NO;
        if (isMore) {
            [self getProductList:moreUrl];
//            [self moreUrlRequest];
            
            //AccessLog - 페이징 처리 시
            if ([listingType isEqualToString:@"search"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE17"];
            }
            else if ([listingType isEqualToString:@"category"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE17"];
            }
            else if ([listingType isEqualToString:@"model"]) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPE04"];
            }
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
   
}

#pragma mark - CPCollectionViewCommonCellDelegate

- (void)didTouchTopTabButton:(NSDictionary *)dic
{
    NSString *url = dic[@"url"];
    if ([url hasPrefix:@"app://gosearch/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        url = URLDecode(url);
    }
    
    if (url && [[url trim] length] > 0) {
        [self getProductList:url];
    }
    
    //AccessLog - 전체상품, 가격비교
    if ([listingType isEqualToString:@"search"]) {
        if ([dic[@"text"] isEqualToString:@"전체상품"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPC02"];
        }
        else if ([dic[@"text"] isEqualToString:@"가격비교"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPC03"];
        }
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        if ([dic[@"text"] isEqualToString:@"전체상품"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPC02"];
        }
        else if ([dic[@"text"] isEqualToString:@"가격비교"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPC03"];
        }
    }
}

- (void)didTouchRelatedOpenButton:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listCollectionView];
    NSIndexPath *indexPath = [listCollectionView indexPathForItemAtPoint:buttonPosition];
    
    NSLog(@"%ld", (long)indexPath.row);
    
//    CPCollectionViewCommonCell *cell = (CPCollectionViewCommonCell *)[listCollectionView cellForItemAtIndexPath:indexPath];
    
    BOOL isExpanded = [collectionData.items[indexPath.row][@"isExpanded"] isEqualToString:@"Y"];

    //ExpandedInfo 셋팅
    [collectionData.items[indexPath.row] removeObjectForKey:@"isExpanded"];
    [collectionData.items[indexPath.row] setObject:isExpanded ? @"N" : @"Y" forKey:@"isExpanded"];
    
    //NO animation
    [UIView setAnimationsEnabled:NO];
    
    [listCollectionView performBatchUpdates:^{
        [listCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]]];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    
    //AccessLog - 연관검색어 상단 더보기 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA03"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA03"];
    }
}

- (void)didTouchRelatedKeywordButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSArray *relatedSearchTextItems = relatedSearchTextInfo[@"items"];
    
    NSString *keyword = relatedSearchTextItems[button.tag-RELATED_SEARCH_BUTTON_TAG][@"text"];
    
    if (keyword) {
//        keyword = [Modules encodeAddingPercentEscapeString:keyword];
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:currentUrl];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
    
    //AccessLog - 연관검색어 상단 텍스트 터치 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA02"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA02"];
    }
}

- (void)didTouchRecommendKeywordButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listCollectionView];
    NSIndexPath *indexPath = [listCollectionView indexPathForItemAtPoint:buttonPosition];
    
    NSArray *relatedSearchTextItems = collectionData.items[indexPath.row][@"items"];
    
    NSString *url = relatedSearchTextItems[button.tag][@"url"];
    
    if (url) {
        [self openWebViewControllerWithUrl:url animated:YES];
    }
    
    //AccessLog - 추천 바로가기
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPA07"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPA05"];
    }
}

- (void)didTouchCategoryNaviButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listCollectionView];
    NSIndexPath *indexPath = [listCollectionView indexPathForItemAtPoint:buttonPosition];
    
    NSArray *categoryNaviItems = collectionData.items[indexPath.row][@"items"];
    
    NSString *url = categoryNaviItems[button.tag][@"url"];
    
    if ([url hasPrefix:@"app://gocategory/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gocategory/" withString:@""];
        url = URLDecode(url);
        
        CPCategoryDetailViewController *viewConroller = [[CPCategoryDetailViewController alloc] initWithUrl:url];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
    else if ([url hasPrefix:@"app://gosearch/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        url = URLDecode(url);
        
//        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithUrl:url keyword:nil];
//        [self.navigationController pushViewController:viewConroller animated:YES];
        [self getProductList:url];
    }
    
    //AccessLog - 카테고리 네비게이션
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPA01"];
}

- (void)didTouchFilterButton:(NSString *)key
{
    //searchFilter 그룹의 key를 전달
    NSString *selectedKey = key;
    
    filterView = [[CPProductFilterView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight) metaInfo:searchMetaInfo selectedKey:selectedKey];
    [filterView setDelegate:self];
    [self.navigationController.view addSubview:filterView];
    
//    //AccessLog - 탭 클릭 시
//    if ([listingType isEqualToString:@"search"]) {
//        if ([key isEqualToString:@"category"]) {
//            //AccessLog - 카테고리 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB01"];
//        }
//        else if ([key isEqualToString:@"brand"]) {
//            //AccessLog - 브랜드 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB04"];
//        }
//        else if ([key isEqualToString:@"partner"]) {
//            //AccessLog - 파트너스 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB07"];
//        }
//        else if ([key isEqualToString:@"detail"]) {
//            //AccessLog - 상세검색 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPB10"];
//        }
//    }
//    else if ([listingType isEqualToString:@"category"]) {
//        if ([key isEqualToString:@"category"]) {
//            //AccessLog - 카테고리 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB01"];
//        }
//        else if ([key isEqualToString:@"brand"]) {
//            //AccessLog - 브랜드 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB04"];
//        }
//        else if ([key isEqualToString:@"partner"]) {
//            //AccessLog - 파트너스 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB07"];
//        }
//        else if ([key isEqualToString:@"detail"]) {
//            //AccessLog - 상세검색 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPB10"];
//        }
//    }
//    else if ([listingType isEqualToString:@"model"]) {
//        if ([key isEqualToString:@"category"]) {
//            //AccessLog - 카테고리 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB01"];
//        }
//        else if ([key isEqualToString:@"detail"]) {
//            //AccessLog - 상세검색 탭 터치 시
//            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPB04"];
//        }
//    }
}

- (void)didTouchSortTypeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    topButton = button;
    topButton.selected = !topButton.selected;
    
    //AccessLog - 정렬조건 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPD01"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPD01"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPD01"];
    }
    
    if (sortTypeContainerView) {
        [self removeSortTypeContainerView];
        return;
    }
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:listCollectionView];
    NSIndexPath *indexPath = [listCollectionView indexPathForItemAtPoint:buttonPosition];
    
    sortItems = collectionData.items[indexPath.row][@"sortItems"];
    
    if (sortItems.count > 0 && !sortTypeContainerView) {
        
        //selected 처리
        srotingCell = (CPCollectionViewCommonCell *)[listCollectionView cellForItemAtIndexPath:indexPath];
        [srotingCell.sortingSortTypeButton setTitleColor:UIColorFromRGB(0xbdbdc0) forState:UIControlStateNormal];
        [srotingCell.sortingArrowImageView setImage:[UIImage imageNamed:@"bt_s_arrow_up_02.png"]];
        
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
//        sortTypeContainerView = [UIButton buttonWithType:UIButtonTypeCustom];
        sortTypeContainerView = [[UIView alloc] init];
        [sortTypeContainerView setFrame:CGRectMake(buttonPosition.x, buttonPosition.y-listCollectionView.contentOffset.y, 112, 30*(sortItems.count+2))];
//        [sortTypeContainerView setBackgroundImage:backImage forState:UIControlStateNormal];
        [self.view insertSubview:sortTypeContainerView aboveSubview:listCollectionView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:backImage];
        [imgView setFrame:CGRectMake(0, 0, CGRectGetWidth(sortTypeContainerView.frame), CGRectGetHeight(sortTypeContainerView.frame))];
        [sortTypeContainerView addSubview:imgView];
        
        NSString *sortTypeStr = @"";
        for (NSDictionary *sortInfo in sortItems) {
            if ([sortInfo[@"selected"] isEqualToString:@"Y"]) {
                sortTypeStr = sortInfo[@"text"];
                break;
            }
        }
        
        UIButton *sortingTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sortingTopButton setFrame:CGRectMake(1, 1, 110, 31)];
        [sortingTopButton setTitle:sortTypeStr forState:UIControlStateNormal];
        [sortingTopButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [sortingTopButton setTitleColor:UIColorFromRGB(0xbdbdc0) forState:UIControlStateNormal];
        [sortingTopButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
        [sortingTopButton setContentEdgeInsets:UIEdgeInsetsMake(-1, 7, 0, 0)];
        [sortingTopButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [sortingTopButton addTarget:self action:@selector(removeSortTypeContainerView) forControlEvents:UIControlEventTouchUpInside];
        [sortTypeContainerView addSubview:sortingTopButton];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(sortingTopButton.frame)-19, 12.5f, 11, 6)];
        [arrowImageView setImage:[UIImage imageNamed:@"bt_s_arrow_up_02.png"]];
        [sortingTopButton addSubview:arrowImageView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sortingTopButton.frame)-3, 110, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
        [sortingTopButton addSubview:lineView];
        
        for (int i = 0; i < sortItems.count; i++) {
            NSDictionary *sortItemInfo = sortItems[i];
            
//            UIImage *backgroundImage = [[UIImage imageNamed:@"layer_s_filterbg_nor.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            
            UIButton *sortingSortTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [sortingSortTypeButton setFrame:CGRectMake(1, (i+1)*30, 110, 31)];
            [sortingSortTypeButton setTitle:sortItemInfo[@"text"] forState:UIControlStateNormal];
            [sortingSortTypeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [sortingSortTypeButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [sortingSortTypeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [sortingSortTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [sortingSortTypeButton addTarget:self action:@selector(touchSortTypeButton:) forControlEvents:UIControlEventTouchUpInside];
            [sortingSortTypeButton setTag:i];
            [sortTypeContainerView addSubview:sortingSortTypeButton];
            
            if ([sortItemInfo[@"selected"] isEqualToString:@"Y"]) {
                UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                //                    [selectedButton setFrame:CGRectMake(1, 1, 110, 29)];
                [selectedButton setFrame:CGRectMake(0, 0, 110, 30)];
                [selectedButton setTitle:sortItemInfo[@"text"] forState:UIControlStateNormal];
                [selectedButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [selectedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [selectedButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
                [selectedButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
                [selectedButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [selectedButton addTarget:self action:@selector(touchSortTypeButton:) forControlEvents:UIControlEventTouchUpInside];
                [selectedButton setTag:i];
                [sortingSortTypeButton addSubview:selectedButton];
            }
            else {
                [sortingSortTypeButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            }
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sortingSortTypeButton.frame)-2, 110, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
            [sortingSortTypeButton addSubview:lineView];
        }
        
        //안내버튼
        NSDictionary *sortInfo = collectionData.items[indexPath.row][@"sortInfo"];
        
        if ([[sortInfo allKeys] containsObject:@"btnText"]) {
            
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [infoButton setFrame:CGRectMake(1, (sortItems.count+1)*30, 110, 28)];
            [infoButton setTitle:sortInfo[@"btnText"] forState:UIControlStateNormal];
            [infoButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [infoButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [infoButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [infoButton setContentEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
            [infoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [infoButton addTarget:self action:@selector(touchSortTypeInfoButton:) forControlEvents:UIControlEventTouchUpInside];
            [infoButton setTag:indexPath.row];
            [sortTypeContainerView addSubview:infoButton];
            
            UIImageView *infoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(infoButton.frame)-24, 6, 19, 19)];
            [infoImageView setImage:[UIImage imageNamed:@"ic_s_notice_02.png"]];
            [infoButton addSubview:infoImageView];
        }
    }
}

- (void)didTouchViewTypeButton:(NSString *)url
{
    if (!(url && [[url trim] length] > 0)) {
        return;
    }
    
    NSString *otherParam = @"";
    NSString *keyword = @"";
    
    if ([url hasPrefix:@"app://gosearch/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        url = URLDecode(url);
        //        url = [url stringByReplacingOccurrencesOfString:@"{{searchParameter}}" withString:searchParameter];
        
        //searchKeyword 추출 : 보낼 때 인코딩 한번 더 필요함.
        NSArray *currentArray = [searchParameter componentsSeparatedByString:@"&"];
        
        for (NSString *keyValue in currentArray) {
            
            if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                
                NSArray *key = [keyValue componentsSeparatedByString:@"="];
                if ([[key firstObject] isEqualToString:@"searchKeyword"] || [[key firstObject] isEqualToString:@"previousKwd"] || [[key firstObject] isEqualToString:@"inKeyword"]) {
                    keyword = [keyword stringByAppendingFormat:@"&%@=%@", [key firstObject], [[key lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
                
                if ([[key firstObject] isEqualToString:@"dlvType"] || [[key firstObject] isEqualToString:@"pointYN"] || [[key firstObject] isEqualToString:@"discountYN"] || [[key firstObject] isEqualToString:@"custBenefit"] || [[key firstObject] isEqualToString:@"myWay"] || [[key firstObject] isEqualToString:@"toPrice"] || [[key firstObject] isEqualToString:@"fromPrice"]) {
                    keyword = [keyword stringByAppendingFormat:@"%@%@=%@", @"&", [key firstObject], [key lastObject]];
                }
            }
        }
        
        //searchKeyword 제거
        currentArray = [keyword componentsSeparatedByString:@"&"];
        for (NSString *keyValue in currentArray) {
            
            if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                
                NSArray *key = [keyValue componentsSeparatedByString:@"="];
                if (![[key firstObject] isEqualToString:@"searchKeyword"] && ![[key firstObject] isEqualToString:@"previousKwd"] && ![[key firstObject] isEqualToString:@"sortCd"] && ![[key firstObject] isEqualToString:@"inKeyword"]) {
                    otherParam = [otherParam stringByAppendingFormat:@"%@%@=%@", @"&", [key firstObject], [key lastObject]];
                }
            }
        }
        
        //            searchParameter = [NSString stringWithFormat:@"%@%@", keyword, otherParam];
        searchParameter = [NSString stringWithFormat:@"%@", otherParam];
        url = [url stringByReplacingOccurrencesOfString:@"{{searchParameter}}" withString:searchParameter];
    }
    
    [self getProductList:url];
    
    //AccessLog - 뷰타입 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPD09"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPD09"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)didTouchSearchMore:(id)sender
{
    needsRefresh = YES;
    //더보기 버튼 제거
//    [collectionData.items removeObject:[collectionData.items lastObject]];
    for (NSDictionary *dic in collectionData.items) {
        if ([[dic objectForKey:@"groupName"] isEqualToString:@"searchMore"]) {
            [collectionData.items removeObject:dic];
            break;
        }
    }
    
//    [self moreUrlRequest];
    [self getProductList:moreUrl];
    [self initPagingView];
    
    //AccessLog - 더보기 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE16"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE16"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPE03"];
    }
}

- (void)didTouchSearchHotProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
    
    //AccessLog - HOT클릭 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE19"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE19"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)didTouchSearchProductSellerButton:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
    
    //AccessLog - 셀러 클릭 시
    if ([listingType isEqualToString:@"search"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPH03"];
    }
    else if ([listingType isEqualToString:@"category"]) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPH03"];
    }
    else if ([listingType isEqualToString:@"model"]) {
        
    }
}

- (void)didTouchSearchProductBannerSellerButton:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didOnTouchBanner:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchShockingDealProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchSearchCaptionPageMoveButton:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)didTouchModelSearchProduct:(NSString *)url;
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)showSearchCaptionAD:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    for (UIButton *adView in listCollectionView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == button.tag){
            return;
        }
    }
    
    if (collectionData.items[button.tag][@"adText"]) {
        
        UICollectionViewCell *cell = [listCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
        
        UIImage *image = [[UIImage imageNamed:@"layer_s_popup_02.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
        
        UIButton *searchCaptionADView = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchCaptionADView setTag:button.tag];
        [searchCaptionADView setFrame:CGRectMake(8, cell.frame.origin.y+31, kScreenBoundsWidth-14, 62)];
        [searchCaptionADView setBackgroundImage:image forState:UIControlStateNormal];
        [searchCaptionADView addTarget:self action:@selector(touchCloseADView:) forControlEvents:UIControlEventTouchUpInside];
        [listCollectionView addSubview:searchCaptionADView];
        
        NSString *ADtitle = collectionData.items[button.tag][@"adText"];
        
        UILabel *ADLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, CGRectGetWidth(searchCaptionADView.frame)-50, 40)];
        [ADLabel setBackgroundColor:[UIColor clearColor]];
        [ADLabel setFont:[UIFont systemFontOfSize:15]];
        [ADLabel setText:ADtitle];
        [ADLabel setTextColor:UIColorFromRGB(0xffffff)];
        [ADLabel setNumberOfLines:2];
        [searchCaptionADView addSubview:ADLabel];
        
        UIImageView *ADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchCaptionADView.frame)-36, 10, 14, 14)];
        [ADImageView setImage:[UIImage imageNamed:@"ic_s_close_02.png"]];
        [searchCaptionADView addSubview:ADImageView];
    }
}

- (void)removeViewTypeContainerView
{
    if (viewTypeContainerView) {
        [viewTypeContainerView removeFromSuperview];
        viewTypeContainerView = nil;
    }
}

- (void)removeSortTypeContainerView
{
    if (sortTypeContainerView) {
        topButton.selected = NO;
        
        [srotingCell.sortingSortTypeButton setTitleColor:UIColorFromRGB(0x242529) forState:UIControlStateNormal];
        [srotingCell.sortingArrowImageView setImage:[UIImage imageNamed:@"bt_s_arrow_down_02.png"]];
        
        [sortTypeContainerView removeFromSuperview];
        sortTypeContainerView = nil;
    }
}

- (NSString *)getSearchKeywordFromCommonCellSuperView
{
    return [navigationBarView getSearchTextField];
}

#pragma mark - CPProductFilterViewDelegate - Category

- (void)didTouchCategoryButton:(NSString *)url
{
    if ([url hasPrefix:@"app://gosearch/"]) {
        url = [url stringByReplacingOccurrencesOfString:@"app://gosearch/" withString:@""];
        url = URLDecode(url);
    }
    
    needCategoryRefresh = YES;
    [self getProductList:url];
}

#pragma mark - CPProductFilterViewDelegate - Detail Search

- (void)didTouchDetailSearchButton:(NSString *)parameter
{
    if (currentUrl) {
        
        NSString *detailSearchUrl = [currentUrl componentsSeparatedByString:@"?"][0];
        NSArray *currentArray = [[currentUrl componentsSeparatedByString:@"?"][1] componentsSeparatedByString:@"&"];
        BOOL isFirstData = YES;
        
        for (NSString *keyValue in currentArray) {
            
            if ([keyValue rangeOfString:@"="].location != NSNotFound) {
                
                NSArray *key = [keyValue componentsSeparatedByString:@"="];
                if (!([[key firstObject] isEqualToString:@"fromPrice"] || [[key firstObject] isEqualToString:@"toPrice"] || [[key firstObject] isEqualToString:@"previousKwd"] || [[key firstObject] isEqualToString:@"dlvType"] || [[key firstObject] isEqualToString:@"custBenefit"] || [[key firstObject] isEqualToString:@"inKeyword"] || [[key firstObject] isEqualToString:@"myWay"])) {
                    
                    NSString * value = @"";
                    if ([[key firstObject] isEqualToString:@"searchKeyword"]) {
                        value = URLDecode([key lastObject]);
                        value = [Modules encodeAddingPercentEscapeString:value];
                    }
                    else {
                        value = [key lastObject];
                    }
                    
                    detailSearchUrl = [detailSearchUrl stringByAppendingFormat:@"%@%@=%@", isFirstData ? @"?" : @"&", [key firstObject], value];
                    isFirstData = NO;
                }
            }
        }
        
        
        NSArray *replaceStrings = [parameter componentsSeparatedByString:@"&"];
        
        for (NSString *keyValue in replaceStrings) {
            NSLog(@"keyValue: %@", keyValue);
            if (!nilCheck(keyValue)) {
                NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
                
                detailSearchUrl = [self makeUrl:detailSearchUrl key:keyValueArray.firstObject replaceString:[NSString stringWithFormat:@"&%@", keyValue]];
            }
        }
        
        
        detailSearchUrl = [self makeUrl:detailSearchUrl removeKey:@"pageNo"];
        detailSearchUrl = [detailSearchUrl stringByReplacingOccurrencesOfString:@"getMore.tmall" withString:@"listing.tmall"];
        
//        NSString *detailSearchUrl = [self makeUrl:currentUrl key:@"sellerNo" replaceString:parameter];
        needCategoryRefresh = YES;
        [self getProductList:detailSearchUrl];
    }
}

#pragma mark - CPProductFilterViewDelegate - Partner

- (void)didTouchPartnerCheckButton:(NSString *)parameter
{
    if (currentUrl) {
        NSString *partnerUrl = [self makeUrl:currentUrl key:@"sellerNos" replaceString:parameter];
        partnerUrl = [self makeUrl:partnerUrl removeKey:@"pageNo"];
        partnerUrl = [partnerUrl stringByReplacingOccurrencesOfString:@"getMore.tmall" withString:@"listing.tmall"];
        needFilterTabRefresh = YES;
        [self getProductList:partnerUrl];
    }
}

#pragma mark - CPProductFilterViewDelegate - Brand

- (void)didTouchBrandCheckButton:(NSString *)parameter
{
    if (currentUrl) {
        NSString *brandUrl = [self makeUrl:currentUrl key:@"brandCd" replaceString:parameter];
        brandUrl = [self makeUrl:brandUrl removeKey:@"pageNo"];
        brandUrl = [brandUrl stringByReplacingOccurrencesOfString:@"getMore.tmall" withString:@"listing.tmall"];
        needFilterTabRefresh = YES;
        [self getProductList:brandUrl];
    }
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 3;
}

#pragma mark - iCarouselDelegate

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 238)];
    
    switch (index) {
        case CPPopularButtonTypeHot:
            
            for (NSDictionary *dic in popularSearchTextInfo[@"hotItems"]) {
                
                if ([popularSearchTextInfo[@"hotItems"] indexOfObject:dic] == 0) {
                    
                    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 37)];
                    [view addSubview:bannerView];
                    
                    //backgroundColor
                    NSString *colorValue = dic[@"bnnrBGColor"];
                    if (colorValue.length >= 7) {
                        unsigned colorInt = 0;
                        [[NSScanner scannerWithString:[colorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
                        [bannerView setBackgroundColor:UIColorFromRGB(colorInt)];
                    }
                    
                    //backgroundImage
                    CPBlurImageView *bannerImageView = [[CPBlurImageView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-300)/2-10, 0, 300, 37)];
                    [bannerImageView setUserInteractionEnabled:YES];
                    [bannerView addSubview:bannerImageView];
                    
                    //backgroundImage
                    NSString *imgUrl = dic[@"bnnrImgUrl"];
                    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
                    
                    if ([imgUrl length] > 0) {
                        NSRange strRange = [imgUrl rangeOfString:@"http"];
                        if (strRange.location == NSNotFound) {
                            imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
                        }
                        strRange = [imgUrl rangeOfString:@"{{img_width}}"];
                        if (strRange.location != NSNotFound) {
                            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 600]];
                        }
                        strRange = [imgUrl rangeOfString:@"{{img_height}}"];
                        if (strRange.location != NSNotFound) {
                            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 600]];
                        }
                        
                        [bannerImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
                    }
                    else {
                        [bannerImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
                    }
                    
                    //bannerLabel
                    UILabel *bannerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bannerImageView.frame), CGRectGetHeight(bannerImageView.frame))];
                    [bannerLabel setText:dic[@"bnnrTitle"]];
                    [bannerLabel setBackgroundColor:[UIColor clearColor]];
                    [bannerLabel setFont:[UIFont systemFontOfSize:14]];
                    [bannerLabel setTextAlignment:NSTextAlignmentCenter];
                    //bannerLable set color
                    NSString *labelColorValue = dic[@"bnnrTxtColor"];
                    if (labelColorValue.length >= 7) {
                        unsigned colorInt = 0;
                        [[NSScanner scannerWithString:[labelColorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
                        [bannerLabel setTextColor:UIColorFromRGB(colorInt)];
                    }else{
                        [bannerLabel setTextColor:[UIColor blackColor]];
                    }
                    
                    [bannerImageView addSubview:bannerLabel];
                }
                else {
                    
                    view.backgroundColor = UIColorFromRGB(0xffffff);
                    
                    int x = [popularSearchTextInfo[@"hotItems"] indexOfObject:dic]%2 == 1 ? 0 : (kScreenBoundsWidth-20)/2;
                    int y = 37 + (int)(([popularSearchTextInfo[@"hotItems"] indexOfObject:dic]-1)/2)*40;
                    int width = (kScreenBoundsWidth-20)/2;
                    int height = 40;
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.textColor = UIColorFromRGB(0x333333);
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.numberOfLines = 1;
                    textLabel.text = [NSString stringWithFormat:@"  %@", dic[@"keyword"]];
                    [view addSubview:textLabel];
                    
                    NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
                    [actionDict setValue:dic[@"keyword"] forKey:@"keyword"];
                    [actionDict setValue:currentUrl forKey:@"reff"];

                    NSString *wiseLogCode = @"";
                    if ([listingType isEqualToString:@"search"])        wiseLogCode = @"NASRPF02";
                    else if ([listingType isEqualToString:@"category"]) wiseLogCode = @"NACLPF02";
                    
                    CPTouchActionView *actionView = [[CPTouchActionView alloc] init];
                    actionView.frame = CGRectMake(x, y, width, height);
                    actionView.actionType = CPButtonActionTypeGoSearchKeyword;
                    actionView.actionItem = actionDict;
                    actionView.wiseLogCode = wiseLogCode;
                    [view addSubview:actionView];
                    
                    NSInteger index = [popularSearchTextInfo[@"hotItems"] indexOfObject:dic];
                    
                    //underLine
                    if (index%2 == 0) {
                        if ([popularSearchTextInfo[@"hotItems"] count] > index+2) {
                            UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, y+height-1, kScreenBoundsWidth-20, 1)];
                            [underLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
                            [view addSubview:underLineView];
                        }
                    }
                }
            }
            break;
        case CPPopularButtonTypeRising:
            
            for (NSDictionary *dic in popularSearchTextInfo[@"risingItems"]) {
                
                if (![dic isEqualToDictionary:[popularSearchTextInfo[@"risingItems"] lastObject]]) {
                    
                    int y = (int)[popularSearchTextInfo[@"risingItems"] indexOfObject:dic]*40;

                    UIView *keywordView = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreenBoundsWidth-20, 40)];
                    keywordView.backgroundColor = UIColorFromRGB(0xffffff);
                    [view addSubview:keywordView];
                    
                    NSString *countText = popularSearchTextInfo[@"risingItems"][[popularSearchTextInfo[@"risingItems"] indexOfObject:dic]][@"searchRankOrder"];
                    CGSize countTextSize = [countText sizeWithFont:[UIFont boldSystemFontOfSize:13]];

                    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(keywordView.frame)-23-countTextSize.width, 0, countTextSize.width, CGRectGetHeight(keywordView.frame))];
                    [countLabel setText:countText];
                    [countLabel setBackgroundColor:[UIColor clearColor]];
                    [countLabel setFont:[UIFont boldSystemFontOfSize:13]];
                    [countLabel setTextColor:UIColorFromRGB(0x999999)];
                    [keywordView addSubview:countLabel];

                    UIImage *rankImage = [self getRankImage:[countText integerValue]];

                    UIImageView *rankImageView = [[UIImageView alloc] initWithImage:rankImage];
                    [rankImageView setFrame:CGRectMake(CGRectGetWidth(keywordView.frame)-20, 13, 10, 13)];
                    [keywordView addSubview:rankImageView];

                    UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, y, countLabel.frame.origin.x-25, 40)];
                    keywordLabel.backgroundColor = [UIColor clearColor];
                    keywordLabel.textColor = UIColorFromRGB(0x333333);
                    keywordLabel.font = [UIFont systemFontOfSize:15];
                    keywordLabel.numberOfLines = 1;
                    keywordLabel.text = dic[@"keyword"];
                    [view addSubview:keywordLabel];

                    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, y+39, kScreenBoundsWidth-20, 1)];
                    [underLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
                    [view addSubview:underLineView];

                    NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
                    [actionDict setValue:dic[@"keyword"] forKey:@"keyword"];
                    [actionDict setValue:currentUrl forKey:@"reff"];
                    
                    NSString *wiseLogCode = @"";
                    if ([listingType isEqualToString:@"search"])        wiseLogCode = @"NASRPF04";
                    else if ([listingType isEqualToString:@"category"]) wiseLogCode = @"NACLPF04";
                    
                    CPTouchActionView *actionView = [[CPTouchActionView alloc] init];
                    actionView.frame = CGRectMake(0, y, keywordView.frame.size.width, keywordView.frame.size.height);
                    actionView.actionType = CPButtonActionTypeGoSearchKeyword;
                    actionView.actionItem = actionDict;
                    actionView.wiseLogCode = wiseLogCode;
                    [view addSubview:actionView];
                }
                else {
                    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 197, kScreenBoundsWidth-20, 40)];
                    [underLineView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
                    [view addSubview:underLineView];
                    
                    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenBoundsWidth-35, 40)];
                    [dateLabel setText:popularSearchTextInfo[@"risingItems"][[popularSearchTextInfo[@"risingItems"] indexOfObject:dic]][@"date"]];
                    [dateLabel setBackgroundColor:[UIColor clearColor]];
                    [dateLabel setTextColor:UIColorFromRGB(0x8c6239)];
                    [dateLabel setFont:[UIFont systemFontOfSize:12]];
                    [underLineView addSubview:dateLabel];
                }
            }
            break;
        case CPPopularButtonTypePopular:
            
            for (NSDictionary *dic in popularSearchTextInfo[@"popularItems"]) {
                
                if ([dic isEqualToDictionary:[popularSearchTextInfo[@"popularItems"] lastObject]]) {
                    
                    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 197, kScreenBoundsWidth-20, 40)];
                    [underLineView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
                    [view addSubview:underLineView];
                    
                    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenBoundsWidth-35, 40)];
                    [dateLabel setText:popularSearchTextInfo[@"popularItems"][[popularSearchTextInfo[@"popularItems"] indexOfObject:dic]][@"date"]];
                    [dateLabel setBackgroundColor:[UIColor clearColor]];
                    [dateLabel setTextColor:UIColorFromRGB(0x8c6239)];
                    [dateLabel setFont:[UIFont systemFontOfSize:12]];
                    [underLineView addSubview:dateLabel];
                }
                else {
                    
                    view.backgroundColor = UIColorFromRGB(0xffffff);
                    
                    int x = [popularSearchTextInfo[@"popularItems"] indexOfObject:dic]%2 == 0 ? 0 : (kScreenBoundsWidth-20)/2;
                    int y = (int)([popularSearchTextInfo[@"popularItems"] indexOfObject:dic]/2)*40;
                    int width = (kScreenBoundsWidth-20)/2;
                    int height = 40;
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.textColor = UIColorFromRGB(0x333333);
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.numberOfLines = 1;
                    textLabel.text = [NSString stringWithFormat:@"  %@", dic[@"keyword"]];
                    [view addSubview:textLabel];
                    
                    NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
                    [actionDict setValue:dic[@"keyword"] forKey:@"keyword"];
                    [actionDict setValue:currentUrl forKey:@"reff"];
                    
                    NSString *wiseLogCode = @"";
                    if ([listingType isEqualToString:@"search"])        wiseLogCode = @"NASRPF06";
                    else if ([listingType isEqualToString:@"category"]) wiseLogCode = @"NACLPF06";
                    
                    CPTouchActionView *actionView = [[CPTouchActionView alloc] init];
                    actionView.frame = CGRectMake(x, y, width, height);
                    actionView.actionType = CPButtonActionTypeGoSearchKeyword;
                    actionView.actionItem = actionDict;
                    actionView.wiseLogCode = wiseLogCode;
                    [view addSubview:actionView];
                    
                    //underLine
                    if ([popularSearchTextInfo[@"popularItems"] indexOfObject:dic]%2 == 1) {
                        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, y+height-1, kScreenBoundsWidth-20, 1)];
                        [underLineView setBackgroundColor:UIColorFromRGBA(0xb9b9b9, 0.3)];
                        [view addSubview:underLineView];
                    }
                }
            }
            break;
        default:
            
            break;
    }
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 237, kScreenBoundsWidth-20, 1)];
    [underLineView setBackgroundColor:UIColorFromRGBA(0xd1d1d6, 0.5)];
    [view addSubview:underLineView];
    
    return view;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 정렬버튼 비노출
    [self removeSortTypeContainerView];
    [self removeViewTypeContainerView];

    // 필터탭 플로팅
    CPCollectionViewCommonCell *filterCell = (CPCollectionViewCommonCell *)[listCollectionView cellForItemAtIndexPath:filterCellIndexPath];
//    CGRect buttonRect = [sender convertRect:CGRectZero toView:listCollectionView];
    CGPoint buttonPosition = [filterCell convertPoint:CGPointZero toView:listCollectionView];
//    NSLog(@"scrollViewDidScroll : %ld, %@, %f",  (long)filterCellIndexPath.row, NSStringFromCGPoint(buttonPosition), listCollectionView.contentOffset.y);
    
    if ((listCollectionView.contentOffset.y >= buttonPosition.y) && listCollectionView.contentOffset.y > 0) {
        [filterTabView setHidden:NO];
    }
    else {
        [filterTabView setHidden:YES];
    }
    
    NSInteger contentOffset = scrollView.contentOffset.y;
    // 스크롤뷰가 바운스되는 경우는 상황에서 제외
    if (contentOffset < 0 || contentOffset > scrollView.contentSize.height - scrollView.frame.size.height) {
        return;
    }
    
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
            // 라인배너 처리
            [lineBannerView setHidden:YES];
        }
        isScrollingToUp = YES;
    }
    
    lastContentOffset = scrollView.contentOffset.y;
    
    if (scrollView.contentSize.height-scrollView.frame.size.height-50 <= scrollView.contentOffset.y && isMore) {
        [self getProductList:moreUrl];
//        [self moreUrlRequest];
        
        //AccessLog - 페이징 처리 시
        if ([listingType isEqualToString:@"search"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASRPE17"];
        }
        else if ([listingType isEqualToString:@"category"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACLPE17"];
        }
        else if ([listingType isEqualToString:@"model"]) {
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NASCPE04"];
        }
    }
    
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
    
    [self performSelectorInBackground:@selector(getProductList:) withObject:currentUrl];
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
