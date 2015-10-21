//
//  CPCategoryMainViewController.m
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCategoryMainViewController.h"
#import "CPCategoryDetailViewController.h"
#import "CPProductListViewController.h"
#import "CPWebViewController.h"
#import "CPHomeViewController.h"
#import "CPSearchViewController.h"
#import "CPSnapshotListViewController.h"
#import "SetupController.h"

#import "CPToolBarView.h"
#import "CPNavigationBarView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"
#import "CPThumbnailView.h"
#import "CPFooterView.h"
#import "CPBannerView.h"

#import "CPRESTClient.h"
#import "CPCommonInfo.h"
#import "CPBannerManager.h"
#import "AccessLog.h"
#import "Modules.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+WebCache.h"

#define CELL_CONTENTVIEW_TAG			901
#define CELL_ICON_TAG                   902
#define CELL_TITLE_TAG                  903
#define CELL_ARROW_TAG                  904
#define CELL_DEPTH_TAG                  905
#define CELL_BOTTOMVIEW_TAG             906

typedef NS_ENUM(NSUInteger, CPCategoryImageType){
    CPCategoryImageTypeNormal = 0,  //normal
    CPCategoryImageTypePressed,     //pressed,highlighted
};

@interface CPCategoryMainViewController () <CPToolBarViewDelegate,
                                            CPNavigationBarViewDelegate,
                                            CPErrorViewDelegate,
                                            CPFooterViewDelegate,
                                            SetupControllerDelegate,
                                            CPSearchViewControllerDelegate,
                                            CPBannerManagerDelegate,
                                            CPBannerViewDelegate,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            UIScrollViewDelegate>
{
    NSString *categoryUrl;
    
    UITableView *categoryTableView;
    
    CPLoadingView *loadingView;
    CPErrorView *errorView;
    
    //footerView
    CPFooterView *cpFooterView;
    CGFloat footerHeight;
    
    NSInteger currentExpandedIndex;
    NSInteger preExpandedIndex;
    
    BOOL isOpenChild;
    
    //JSON API 정보
    NSMutableDictionary *metaCategoryTreeInfo;
    NSMutableDictionary *noData;
    NSMutableDictionary *lineBannerInfo;
    
    //네크웤 다시시도를 위한 url임시저장
    NSString *tempUrl;
    
    CPToolBarView *toolBarView;
    UIView *mdnBannerView;
    CPBannerView *lineBannerView;
    
    CPNavigationBarView *navigationBarView;
}

@end

@implementation CPCategoryMainViewController

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
    
    [self.view setBackgroundColor:UIColorFromRGB(0xd6d6dd)];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];

    // Layout
    [self initLayout];
    
    // API
    [self getCategoryMainData:categoryUrl];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initLayout
{
    currentExpandedIndex = -1;
    
    //Init dictionary
    metaCategoryTreeInfo = [NSMutableDictionary dictionary];
    lineBannerInfo = [NSMutableDictionary dictionary];
    
    //Footer
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setFrame:CGRectMake(0, 0, cpFooterView.width, cpFooterView.height)];
    [cpFooterView setDelegate:self];
    [cpFooterView setParentViewController:self];
    
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

- (void)setTableView
{
    if (categoryTableView) {
        [categoryTableView removeFromSuperview];
        categoryTableView = nil;
    }
    
    //카테고리 테이블뷰
    categoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight)) style:UITableViewStyleGrouped];
    [categoryTableView setDelegate:self];
    [categoryTableView setDataSource:self];
    [categoryTableView setBackgroundColor:UIColorFromRGB(0xd6d6dd)];
    [categoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [categoryTableView setSectionHeaderHeight:0];
    [categoryTableView setSectionFooterHeight:0];
    [self.view insertSubview:categoryTableView belowSubview:toolBarView];
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

#pragma mark - API

- (void)getCategoryMainData:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^categoryMainSuccess)(NSDictionary *);
    categoryMainSuccess = ^(NSDictionary *categoryMainData) {
        
        if (categoryMainData && [categoryMainData count] > 0) {
            
            NSArray *dataArray = categoryMainData[@"data"];
            
            [metaCategoryTreeInfo removeAllObjects];
            
            NSPredicate *metaCategoryPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"metaCategoryTree"];
            if ([dataArray filteredArrayUsingPredicate:metaCategoryPredicate].count > 0) {
                metaCategoryTreeInfo = [[dataArray filteredArrayUsingPredicate:metaCategoryPredicate][0] mutableCopy];
            }
            
            //line banner
            NSArray *footerDataArray = categoryMainData[@"footerData"];
            
            NSPredicate *bannerPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"adLineBanner"];
            if ([footerDataArray filteredArrayUsingPredicate:bannerPredicate].count > 0) {
                
                NSMutableDictionary *lineBannerUrlInfo = [[footerDataArray filteredArrayUsingPredicate:bannerPredicate][0] mutableCopy];
                
                if (lineBannerUrlInfo[@"url"]) {
                    [self getLineBannerWithUrl:lineBannerUrlInfo[@"url"]];
                }
            }
        }
        
        //멀티쓰레드 문제로 tableView init은 이곳에서 처리
        [self setTableView];
        [categoryTableView reloadData];
        [self stopLoadingAnimation];
        
        //Offer Banner
        mdnBannerView = [[CPBannerManager sharedManager] makeOfferBannerView];
        [[CPBannerManager sharedManager] setDelegate:self];
        [self.view insertSubview:mdnBannerView aboveSubview:categoryTableView];
        
    };
    
    void (^categoryMainFailure)(NSError *);
    categoryMainFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        
        errorView = [[CPErrorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)];
        [errorView setDelegate:self];
        [self.view insertSubview:errorView belowSubview:toolBarView];
    };
    
    NSRange range = [url rangeOfString:@"http"];
    url = [url substringFromIndex:range.location];
    if (!(url && url.length > 0)) {
        url = APP_META_CATEGORY_URL;
    }
    
    tempUrl = url;
    
    if (url) {
        [[CPRESTClient sharedClient] requestCategoryMainWithUrl:url
                                                          success:categoryMainSuccess
                                                          failure:categoryMainFailure];
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
//                lineBannerView = [[CPBannerView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-(kNavigationHeight+kToolBarHeight+kLineBannerHeight), kScreenBoundsWidth, kLineBannerHeight) bannerInfo:lineBannerInfo];
//                [lineBannerView setDelegate:self];
//                [self.view insertSubview:lineBannerView aboveSubview:categoryTableView];
            
                //섹션 리로드
                [categoryTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:viewControlelr animated:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange)
                                                 name:WebViewControllerNotification
                                               object:nil];

}

- (void)expandItemAtIndex:(NSInteger)index
{
    NSInteger insertPos = index + 1;
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSArray *currentSubItems = metaCategoryTreeInfo[@"items"][index][@"child"];
    
    for (NSInteger i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    
    [categoryTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self performSelector:@selector(didFinishAnimationExpand:) withObject:[NSIndexPath indexPathForRow:index inSection:0] afterDelay:0.1f];
}

- (void)collapseSubItemsAtIndex:(NSInteger)index
{
    UITableViewCell *cell = [categoryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIImageView *iconImageView = (UIImageView *)[cell viewWithTag:CELL_ICON_TAG];
    [iconImageView setImage:[self getCategoryIcon:CPCategoryImageTypeNormal index:preExpandedIndex]];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    NSInteger subItemCount = [metaCategoryTreeInfo[@"items"][index][@"child"] count];
    for (NSInteger i = index + 1; i <= index + subItemCount; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [categoryTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self performSelector:@selector(didFinishAnimationCollapse:) withObject:[NSIndexPath indexPathForRow:index inSection:0] afterDelay:0.1f];
}

- (void)didFinishAnimationCollapse:(NSIndexPath *)indexPath
{
    for (UITableViewCell *cell in categoryTableView.visibleCells) {
        UIView *contentView = (UIView *)[cell.contentView viewWithTag:CELL_CONTENTVIEW_TAG];
        UILabel *textLabel = (UILabel *)[cell viewWithTag:CELL_TITLE_TAG];
        UIImageView *arrowImageView = (UIImageView *)[cell viewWithTag:CELL_ARROW_TAG];
        UIView *bottomLineView = (UIView *)[cell.contentView viewWithTag:CELL_BOTTOMVIEW_TAG];
        
        [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [textLabel setTextColor:UIColorFromRGB(0x3d4050)];
        [arrowImageView setImage:[UIImage imageNamed:@"bt_c_arrow_down_01"]];
        [bottomLineView setBackgroundColor:UIColorFromRGB(0xe3e4ea)];
    }
}

- (void)didFinishAnimationExpand:(NSIndexPath *)indexPath
{
    [categoryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    UITableViewCell *cell = [categoryTableView cellForRowAtIndexPath:indexPath];
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:CELL_CONTENTVIEW_TAG];
    UIImageView *iconImageView = (UIImageView *)[cell viewWithTag:CELL_ICON_TAG];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:CELL_TITLE_TAG];
    UIImageView *arrowImageView = (UIImageView *)[cell viewWithTag:CELL_ARROW_TAG];
    UIView *bottomLineView = (UIView *)[cell.contentView viewWithTag:CELL_BOTTOMVIEW_TAG];
    
    [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [iconImageView setImage:[self getCategoryIcon:CPCategoryImageTypePressed index:indexPath.row]];
    [textLabel setTextColor:UIColorFromRGB(0x5e6dff)];
    [arrowImageView setImage:[UIImage imageNamed:@"bt_c_arrow_up.png"]];
    [bottomLineView setBackgroundColor:UIColorFromRGB(0xcfcfd7)];
}

- (UIImage *)getCategoryIcon:(NSInteger)type index:(NSInteger)index
{
    UIImage *image;
    
    switch (index) {
        case 0:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_brand_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 1:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_clothing_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 2:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_beauty_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 3:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_food_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 4:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_lifestyle_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 5:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_sports_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 6:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_digital_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
        case 7:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_hobby_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
            
        default:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_c_brand_%@.png", (type == CPCategoryImageTypeNormal ? @"nor" : @"press")]];
            break;
    }
    
    return image;
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
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Selectos

- (void)touchCategoryItem:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSUInteger childIndex = button.tag - currentExpandedIndex - 1;
    NSString *link = metaCategoryTreeInfo[@"items"][currentExpandedIndex][@"child"][childIndex][@"url"];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        BOOL isAppLink = [AppDelegate isAppUrlScheme:link shouldEqual:NO];
        
        if (isAppLink) {
            
            NSString *url = link;
            
            if ([url hasPrefix:@"app://gocategory/"]) {
                url = [url stringByReplacingOccurrencesOfString:@"app://gocategory/" withString:@""];
                url = URLDecode(url);
            }
            
            CPCategoryDetailViewController *viewController = [[CPCategoryDetailViewController alloc] initWithUrl:url];
            [homeViewController.navigationController pushViewController:viewController animated:NO];
        }
        else {
            [homeViewController openWebViewControllerWithUrl:link animated:YES];
        }
    }];
    
    //AccessLog - 대카테고리
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGA02"];
}

- (void)touchBanner
{
    NSString *linkUrl = lineBannerInfo[@"CONTENTS"][@"LURL1"];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        [self openWebViewControllerWithUrl:linkUrl animated:YES];
    }
}

- (void)loginStatusDidChange
{
    [cpFooterView reloadLoginStatus];
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
            [self getCategoryMainData:categoryUrl];
            break;
        case CPToolBarButtonTypeTop:
            [categoryTableView setContentOffset:CGPointZero animated:YES];
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

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 46;
    }
    else if (section == 1) {
        return lineBannerView.height+10;
    }
    else {
        return cpFooterView.height-20;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [metaCategoryTreeInfo[@"items"] count] + ((currentExpandedIndex > -1) ? [metaCategoryTreeInfo[@"items"][currentExpandedIndex][@"child"] count] : 0);
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isChild = indexPath.section == 0 && currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [metaCategoryTreeInfo[@"items"][currentExpandedIndex][@"child"] count];
    
    if (isChild) {
        return 42;
    }
    else {
        return 49;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    
    if (section == 0) {
        //Title
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 36)];
        [titleView setBackgroundColor:[UIColor whiteColor]];
        [sectionView addSubview:titleView];
        
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
    }
    else if (section == 1) {
        lineBannerView = [[CPBannerView alloc] initWithFrame:CGRectMake(0, 10, kScreenBoundsWidth, kLineBannerHeight) bannerInfo:lineBannerInfo];
        [lineBannerView setFrame:CGRectMake(0, 10, lineBannerView.width, lineBannerView.height)];
        [lineBannerView setDelegate:self];
        [sectionView addSubview:lineBannerView];
    }
    else {
        //Footer
        [sectionView addSubview:cpFooterView];
    }
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *parentCellIdentifier = @"ParentCell";
    static NSString *childCellIdentifier = @"ChildCell";
    
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell;
    
    BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + [[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"child"] count];
    
    if (isChild) {
        cell = [tableView dequeueReusableCellWithIdentifier:childCellIdentifier];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:parentCellIdentifier];
    }
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentCellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xd6d6dd)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // 서브카테고리
    if (isChild) {
        // contetnView
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake([SYSTEM_VERSION intValue] < 7 ? 0 : 10, 0, tableView.frame.size.width-20, rowHeight)];
        [contentView setBackgroundColor:UIColorFromRGB(0xf5f5f8)];
        [cell.contentView addSubview:contentView];
        
        
        // title
        NSString *title = [[[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"child"] objectAtIndex:indexPath.row - currentExpandedIndex - 1] objectForKey:@"name"];
        
        CGFloat edgeLeft = 17;
        
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
        
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleButton setFrame:CGRectMake(0, 0, tableView.frame.size.width-20, rowHeight)];
        [titleButton setImage:[UIImage imageNamed:@"ic_c_lowlist_nor.png"] forState:UIControlStateNormal];
        [titleButton setImage:[UIImage imageNamed:@"ic_c_lowlist_press.png"] forState:UIControlStateHighlighted];
        [titleButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
        [titleButton setTitle:title forState:UIControlStateNormal];
        [titleButton setTitleColor:UIColorFromRGB(0x1e1e1e) forState:UIControlStateNormal];
        [titleButton setTitleColor:UIColorFromRGB(0x5161ff) forState:UIControlStateHighlighted];
        [titleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLeft+16, 0, 0)];
        [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, edgeLeft, 0, 0)];
        [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [titleButton addTarget:self action:@selector(touchCategoryItem:) forControlEvents:UIControlEventTouchUpInside];
        [titleButton setAccessibilityLabel:title Hint:@"해당 카테고리로 이동합니다"];
        [titleButton setTag:indexPath.row];
        [contentView addSubview:titleButton];
        
        // discount
        NSInteger discount = [[[[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"child"] objectAtIndex:indexPath.row - currentExpandedIndex - 1] objectForKey:@"tMemRate"] integerValue];
        NSString *discountText = [NSString stringWithFormat:@"~%ld%%", (long)discount];
        if (discountText && discountText.length > 0 && (discount != 0)) {
            UIImage *tImage = [UIImage imageNamed:@"ic_c_t_sale.png"];
            UIImageView *tImageView = [[UIImageView alloc] initWithImage:tImage];
            [tImageView setFrame:CGRectMake(edgeLeft + titleSize.width + 36, (rowHeight - tImage.size.height) / 2, tImage.size.width, tImage.size.height)];
            [contentView addSubview:tImageView];
            
            UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [discountLabel setTextColor:UIColorFromRGB(0xea0000)];
            [discountLabel setFont:[UIFont systemFontOfSize:11]];
            [discountLabel setBackgroundColor:[UIColor clearColor]];
            [discountLabel setText:discountText];
            [discountLabel sizeToFit];
            [discountLabel setFrame:CGRectMake(CGRectGetMaxX(tImageView.frame) + 3, 0, discountLabel.frame.size.width, discountLabel.frame.size.height)];
            [discountLabel setCenter:CGPointMake(discountLabel.center.x, tImageView.center.y)];
            [contentView addSubview:discountLabel];
        }
        
        NSInteger lastIndex = [metaCategoryTreeInfo[@"items"] count] + ((currentExpandedIndex > -1) ? [metaCategoryTreeInfo[@"items"][currentExpandedIndex][@"child"] count] : 0);
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(titleButton.frame)-1, kScreenBoundsWidth-20, 1)];
        [lineView setBackgroundColor:lastIndex==indexPath.row?UIColorFromRGB(0xc5c5ce):UIColorFromRGB(0xdddde1)];
        [contentView addSubview:lineView];
    }
    else // 대카테고리
    {
        NSInteger topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex) ? indexPath.row - [[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"child"] count] : indexPath.row;
        
        // contentView
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake([SYSTEM_VERSION intValue] < 7 ? 0 : 10, 0, tableView.frame.size.width-20, rowHeight)];
        [contentView setTag:CELL_CONTENTVIEW_TAG];
        [contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [cell.contentView addSubview:contentView];
        
        //icon
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 21, 21)];
        [iconImageView setTag:CELL_ICON_TAG];
        [iconImageView setImage:[self getCategoryIcon:CPCategoryImageTypeNormal index:topIndex]];
        [contentView addSubview:iconImageView];
        
        // arrow
        UIImage *arrowImage = currentExpandedIndex == indexPath.row ? [UIImage imageNamed:@"bt_c_arrow_up.png"] : [UIImage imageNamed:@"bt_c_arrow_down_01.png"];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame) - arrowImage.size.width-12, (rowHeight - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
        [arrowImageView setImage:arrowImage];
        [arrowImageView setTag:CELL_ARROW_TAG];
        [contentView addSubview:arrowImageView];
        
        // title
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setTag:CELL_TITLE_TAG];
        [textLabel setTextColor:UIColorFromRGB(0x3d4050)];
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setText:[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:topIndex] objectForKey:@"name"]];
        [textLabel sizeToFit];
        [textLabel setFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+13, 0, textLabel.frame.size.width, textLabel.frame.size.height)];
        [textLabel setCenter:CGPointMake(textLabel.center.x, iconImageView.center.y)];
        [contentView addSubview:textLabel];
        
        // discount
        NSInteger discount = [[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:topIndex] objectForKey:@"tMemRate"] integerValue];
        NSString *discountText = [NSString stringWithFormat:@"~%ld%%", (long)[[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:topIndex] objectForKey:@"tMemRate"] integerValue]];
        if (discountText && discountText.length > 0 && (discount != 0)) {
            UIImage *tImage = [UIImage imageNamed:@"ic_c_t_sale.png"];
            UIImageView *tImageView = [[UIImageView alloc] initWithImage:tImage];
            [tImageView setFrame:CGRectMake(textLabel.frame.origin.x + textLabel.frame.size.width + 8, 0, tImage.size.width, tImage.size.height)];
            [tImageView setCenter:CGPointMake(tImageView.center.x, textLabel.center.y)];
            [contentView addSubview:tImageView];
            
            UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [discountLabel setTextColor:UIColorFromRGB(0xea0000)];
            [discountLabel setFont:[UIFont systemFontOfSize:11]];
            [discountLabel setBackgroundColor:[UIColor clearColor]];
            [discountLabel setText:discountText];
            [discountLabel sizeToFit];
            [discountLabel setFrame:CGRectMake(tImageView.frame.origin.x + tImageView.frame.size.width + 3.0f, 0, discountLabel.frame.size.width, discountLabel.frame.size.height)];
            [discountLabel setCenter:CGPointMake(discountLabel.center.x, tImageView.center.y)];
            [contentView addSubview:discountLabel];
        }
        
        BOOL isExpandedCell = currentExpandedIndex == indexPath.row;
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, rowHeight-1, kScreenBoundsWidth-20, 1.0f)];
        [bottomLineView setTag:CELL_BOTTOMVIEW_TAG];
        [bottomLineView setBackgroundColor:isExpandedCell?UIColorFromRGB(0xc5c5ce):UIColorFromRGB(0xe3e4ea)];
        [contentView addSubview:bottomLineView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        preExpandedIndex = currentExpandedIndex;
        
        [categoryTableView beginUpdates];
        
        if (currentExpandedIndex == indexPath.row) {
            [self collapseSubItemsAtIndex:currentExpandedIndex];
            
            isOpenChild = NO;
            currentExpandedIndex = -1;
        }
        else {
            BOOL shouldCollapse = currentExpandedIndex > -1;
            
            if (shouldCollapse) {
                [self collapseSubItemsAtIndex:currentExpandedIndex];
            }
            
            currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - [[[[metaCategoryTreeInfo objectForKey:@"items"] objectAtIndex:currentExpandedIndex] objectForKey:@"child"] count] : indexPath.row;
            
            [self expandItemAtIndex:currentExpandedIndex];
            
            isOpenChild = YES;
        }
        
        [categoryTableView endUpdates];
    }
    
    //AccessLog - 메타카테고리
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGA01"];
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
    
    [self performSelectorInBackground:@selector(getCategoryMainData:) withObject:tempUrl];
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
