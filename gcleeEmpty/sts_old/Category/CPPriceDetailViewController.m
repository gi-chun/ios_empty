//
//  CPPriceDetailViewController.m
//  11st
//
//  Created by spearhead on 2015. 6. 23..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailViewController.h"
#import "CPProductListViewController.h"
#import "CPWebViewController.h"
#import "CPHomeViewController.h"
#import "CPSearchViewController.h"
#import "CPSnapshotListViewController.h"
#import "SetupController.h"

#import "AppDelegate.h"
#import "CPHomeViewController.h"
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
#import "CPSchemeManager.h"

#import "CPPriceDetailModelInfoCell.h"
#import "CPPriceDetailRelatedModelsCell.h"
#import "CPPriceDetailSpecCell.h"
#import "CPPriceDetailCompPrcListCell.h"
#import "CPPriceDetailReviewItemCell.h"
#import "CPPriceDetailSatisfyScoreCell.h"
#import "CPPriceDetailSaleGraphCell.h"
#import "CPPriceDetailSameCategoryModelsCell.h"
#import "CPPriceDetailBestProductCell.h"

#import "CPPriceDetailHeaderView.h"

@interface CPPriceDetailViewController () < CPToolBarViewDelegate,
                                            CPNavigationBarViewDelegate,
                                            CPErrorViewDelegate,
                                            CPFooterViewDelegate,
                                            CPSearchViewControllerDelegate,
                                            CPBannerManagerDelegate,
                                            CPBannerViewDelegate,
                                            CPPriceDetailModelInfoCellDelegate,
                                            CPPriceDetailRelatedModelsCellDelegate,
                                            CPPriceDetailCompPrcListCellDelegate,
                                            CPPriceDetailHeaderViewDelegate,
                                            CPPriceDetailReviewItemCellDelegate,
                                            CPPriceDetailSaleGraphCellDelegate,
                                            CPPriceDetailSameCategoryModelsCellDelegate,
                                            CPPriceDetailBestProductCellDelegate,
                                            CPSchemeManagerDelegate,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            UIScrollViewDelegate>
{
    CPLoadingView *loadingView;
    CPToolBarView *toolBarView;
    CPBannerView *lineBannerView;
    CPNavigationBarView *navigationBarView;
    UIView *mdnBannerView;
    
    UITableView *_tableView;
    CPErrorView *_errorView;
    
    UIView *_filterView;
    
    CGFloat footerHeight;
    
    NSMutableArray *_items;
    NSMutableDictionary *_modelInfo;
    NSMutableDictionary *_relatedModels;
    NSMutableDictionary *_spec;
    NSMutableDictionary *_compPrcList;
    NSMutableDictionary *_reviewList;
    NSMutableDictionary *_satisfyScore;
    NSMutableDictionary *_saleGraph;
    NSMutableDictionary *_sameCategoryModels;
    NSMutableDictionary *_sameBrandModels;
    NSMutableDictionary *_bestProducts;
}

@end

@implementation CPPriceDetailViewController

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
    [self requestItem:self.modelNo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[CPSchemeManager sharedManager] setDelegate:self];
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
    
    [self closePopupFilterView];
    
    [toolBarView setHiddenPopover:YES];
    
    [[CPBannerManager sharedManager] removeBannerView];
}

-  (void)dealloc
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initLayout
{
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
    [self stopLoadingAnimation];
}

- (UIView *)navigationBarView:(CPNavigationType)navigationType
{
    if (navigationBarView) {
        [navigationBarView removeFromSuperview];
    }
    
    navigationBarView = [[CPNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44) type:navigationType];
    [navigationBarView setDelegate:self];
    [navigationBarView setSearchTextField:self.keyword];
    
    //    // 개발자모드 진입점
    //    [self initDeveloperInfo:logoButton];
    //    //    }
    
    return navigationBarView;
}

#pragma showContents
- (void)showContents
{
    [self removeErrorView];
    [self removeContents];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)
                                              style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = NO;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = UIColorFromRGB(0xe3e3e8);
    _tableView.sectionHeaderHeight = 0.f;
    _tableView.sectionFooterHeight = 10.f;
    [self.view addSubview:_tableView];

    CPFooterView *fView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [fView setFrame:CGRectMake(0, 0, fView.width, fView.height)];
    [fView setDelegate:self];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fView.frame.size.width, CGRectGetMaxY(fView.frame))];
    [footerView addSubview:fView];
    [_tableView setTableFooterView:footerView];
    
    [self.view bringSubviewToFront:toolBarView];
}

- (void)removeContents
{
    if (_tableView) {
        [_tableView removeFromSuperview];
        _tableView.dataSource = nil;
        _tableView.delegate = nil;
        _tableView = nil;
    }
}

#pragma mark - Error View
- (void)showErrorView
{
    [self removeErrorView];
    [self removeContents];
    
    _errorView = [[CPErrorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kToolBarHeight)];
    [_errorView setDelegate:self];
    [self.view addSubview:_errorView];
}

- (void)removeErrorView
{
    if (_errorView) {
        [_errorView removeFromSuperview];
        _errorView.delegate = nil;
        _errorView = nil;
    }
}

#pragma mark - API

- (void)requestItem:(NSString *)modelNo
{
    if (modelNo && [modelNo length] > 0) {
        if (![self.modelNo isEqualToString:modelNo]) self.modelNo = modelNo;
        
        NSString *url = [PRICE_COMPARE_DETAIL_URL stringByReplacingOccurrencesOfString:@"{{modelNo}}" withString:modelNo];
        [self requestItemWithUrl:url];
    }
}

- (void)requestItemWithUrl:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^requestSuccess)(NSDictionary *);
    requestSuccess = ^(NSDictionary *requestData) {
        
        if (!requestData || !requestData[@"data"] || [requestData count] == 0) {
            [self showErrorView];
            [self stopLoadingAnimation];
            return;
        }
        
        NSArray *dataArray = requestData[@"data"];
        if (!dataArray) {
            [self showErrorView];
            [self stopLoadingAnimation];
            return;
        }
        
        [self resetItems];
        [self parseItems:dataArray];
        _items = [self combinationItems];
        
        [self showContents];
        [self stopLoadingAnimation];
    };
    
    void (^requestFailure)(NSError *);
    requestFailure = ^(NSError *failureData) {

        [self showErrorView];
        [self stopLoadingAnimation];
    };

    if (url) {
        [[CPRESTClient sharedClient] requestCategoryMainWithUrl:url
                                                        success:requestSuccess
                                                        failure:requestFailure];
    }
}

- (void)requestRelatedModelsMoreItems:(NSString *)moreUrl page:(NSInteger)pageNum
{
    [self startLoadingAnimation];
    
    void (^requestSuccess)(NSDictionary *);
    requestSuccess = ^(NSDictionary *requestData) {
        
        if (!requestData || [requestData count] == 0) {
            [self stopLoadingAnimation];
            return;
        }
        
        NSArray *dataArray = requestData[@"data"];
        if (!dataArray || [dataArray count] == 0) {
            [self stopLoadingAnimation];
            return;
        }
        
        //데이터를 수정한다.
        NSArray *items = nil;
        NSString *isMore = @"";
        for (NSInteger i=0; i<[dataArray count]; i++) {
            NSString *groupName = dataArray[i][@"groupName"];
            if ([@"relatedModels" isEqualToString:groupName]) {
                items = dataArray[i][@"items"];
                isMore = dataArray[i][@"isMore"];
                break;
            }
        }

        if (items) {
            NSMutableDictionary *tempRelatedModels = _relatedModels[@"relatedModels"];
            
            NSMutableArray *tempArr = tempRelatedModels[@"items"];
            
            if (pageNum == 1) {
                [tempArr removeAllObjects];
            }
            
            [tempArr addObjectsFromArray:[items mutableCopy]];
            
            [tempRelatedModels setValue:isMore forKey:@"isMore"];
            [tempRelatedModels setValue:tempArr forKey:@"items"];
            [tempRelatedModels setValue:[NSString stringWithFormat:@"%ld", (long)pageNum] forKey:@"currentPage"];
            
            [_relatedModels setValue:tempRelatedModels forKey:@"relatedModels"];
            
            _items = [self combinationItems];
            
            if (_items) [_tableView reloadData];
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^requestFailure)(NSError *);
    requestFailure = ^(NSError *failureData) {
        [self stopLoadingAnimation];
    };
    
    if (moreUrl) {
        [[CPRESTClient sharedClient] requestCategoryMainWithUrl:moreUrl
                                                        success:requestSuccess
                                                        failure:requestFailure];
    }
}

- (void)requestFilterItem:(NSInteger)currentPage sortCd:(NSString *)sortCd dlvTypeCd:(NSString *)dlvTypeCd
{
    NSString *moreUrl = _compPrcList[@"compPrcList"][@"moreUrl"];
    
    moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:[NSString stringWithFormat:@"%ld", (long)currentPage]];
    moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"{{sortCd}}" withString:sortCd];
    moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"{{dlvType}}" withString:dlvTypeCd];
    
    [self startLoadingAnimation];
    
    void (^requestSuccess)(NSDictionary *);
    requestSuccess = ^(NSDictionary *requestData) {
        
        if (!requestData || [requestData count] == 0) {
            [self stopLoadingAnimation];
            return;
        }
        
        NSArray *dataArray = requestData[@"data"];
        if (!dataArray) {
            [self stopLoadingAnimation];
            return;
        }
        
        //데이터를 수정한다.
        NSArray *items = nil;
        NSString *isMore = @"";
        for (NSInteger i=0; i<[dataArray count]; i++) {
            NSString *groupName = dataArray[i][@"groupName"];
            if ([@"compPrcList" isEqualToString:groupName]) {
                items = dataArray[i][@"items"];
                isMore = dataArray[i][@"isMore"];
                break;
            }
        }
        
        if (items) {
            NSMutableDictionary *tempCompPrcList = _compPrcList[@"compPrcList"];
            
            NSMutableArray *tempArr = tempCompPrcList[@"items"];
            
            if (currentPage == 1) {
                [tempArr removeAllObjects];
            }
            
            [tempArr addObjectsFromArray:[items mutableCopy]];
            
            [tempCompPrcList setValue:isMore forKey:@"isMore"];
            [tempCompPrcList setValue:tempArr forKey:@"items"];
            [tempCompPrcList setValue:[NSString stringWithFormat:@"%ld", (long)currentPage] forKey:@"currentPage"];
            
            //sortCds를 변경한다.
            NSArray *sortCds = tempCompPrcList[@"sortCds"];
            NSMutableArray *tempSortCds = [NSMutableArray array];
            for (NSInteger i=0; i<[sortCds count]; i++) {
                NSMutableDictionary *item = [sortCds[i] mutableCopy];
                
                NSString *code = item[@"code"];
                if ([code isEqualToString:sortCd])  [item setValue:@"Y" forKey:@"selected"];
                else                                [item setValue:@"N" forKey:@"selected"];
                
                [tempSortCds addObject:item];
            }
            [tempCompPrcList setValue:tempSortCds forKey:@"sortCds"];
            
            //dlvTypes를 변경한다.
            NSArray *dlvTypes = tempCompPrcList[@"dlvTypes"];
            NSMutableArray *tempDlvTypes = [NSMutableArray array];
            for (NSInteger i=0; i<[dlvTypes count]; i++) {
                NSMutableDictionary *item = [dlvTypes[i] mutableCopy];
                
                NSString *code = item[@"code"];
                if ([code isEqualToString:dlvTypeCd])  [item setValue:@"Y" forKey:@"selected"];
                else                                    [item setValue:@"N" forKey:@"selected"];
                
                [tempDlvTypes addObject:item];
            }
            [tempCompPrcList setValue:tempDlvTypes forKey:@"dlvTypes"];
            [_compPrcList setValue:tempCompPrcList forKey:@"compPrcList"];
            
            _items = [self combinationItems];
            
            if (_items) [_tableView reloadData];
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^requestFailure)(NSError *);
    requestFailure = ^(NSError *failureData) {
        [self stopLoadingAnimation];
    };
    
    if (moreUrl) {
        [[CPRESTClient sharedClient] requestCategoryMainWithUrl:moreUrl
                                                        success:requestSuccess
                                                        failure:requestFailure];
    }
}

#pragma mark - dataSource
- (void)resetItems
{
    if (_modelInfo)             [_modelInfo removeAllObjects], _modelInfo = nil;
    if (_relatedModels)         [_relatedModels removeAllObjects], _relatedModels = nil;
    if (_spec)                  [_spec removeAllObjects], _spec = nil;
    if (_compPrcList)           [_compPrcList removeAllObjects], _compPrcList = nil;
    if (_reviewList)            [_reviewList removeAllObjects], _reviewList = nil;
    if (_satisfyScore)          [_satisfyScore removeAllObjects], _satisfyScore = nil;
    if (_saleGraph)             [_saleGraph removeAllObjects], _saleGraph = nil;
    if (_sameCategoryModels)    [_sameCategoryModels removeAllObjects], _sameCategoryModels = nil;
    if (_sameBrandModels)       [_sameBrandModels removeAllObjects], _sameBrandModels = nil;
    if (_bestProducts)          [_bestProducts removeAllObjects], _bestProducts = nil;
}

- (void)parseItems:(NSArray *)items
{
    for (NSInteger i=0; i<[items count]; i++) {
        
        NSString *groupName = items[i][@"groupName"];
        
        if ([groupName isEqualToString:@"modelInfo"]) {
            _modelInfo = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
        }
        else if ([groupName isEqualToString:@"relatedModels"]) {
            _relatedModels = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempRelatedModels = [_relatedModels[@"relatedModels"] mutableCopy];
            
            NSMutableArray *tempArray = [NSMutableArray array];
            NSArray *exArr = tempRelatedModels[@"items"];
            
            for (NSInteger j=0; j<[exArr count]; j++) {
                [tempArray addObject:[exArr[j] mutableCopy]];
            }
            
            [tempRelatedModels setValue:tempArray forKey:@"items"];
            [tempRelatedModels setValue:@"1" forKey:@"currentPage"];
            
            [_relatedModels setValue:tempRelatedModels forKey:@"relatedModels"];
        }
        else if ([groupName isEqualToString:@"spec"]) {
            _spec = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempSpec = [_spec[@"spec"] mutableCopy];
            [_spec setValue:tempSpec forKey:@"spec"];
        }
        else if ([groupName isEqualToString:@"compPrcList"]) {
            _compPrcList = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempCompPrcList = [_compPrcList[@"compPrcList"] mutableCopy];
            
            NSMutableArray *tempItems = [NSMutableArray array];
            NSArray *exArr01 = tempCompPrcList[@"items"];
            
            for (NSInteger j=0; j<[exArr01 count]; j++) {
                [tempItems addObject:[exArr01[j] mutableCopy]];
            }
            
            NSMutableArray *tempSortCds = [NSMutableArray array];
            NSArray *exArr02 = tempCompPrcList[@"sortCds"];
            
            for (NSInteger j=0; j<[exArr02 count]; j++) {
                [tempSortCds addObject:[exArr02[j] mutableCopy]];
            }
            
            NSMutableArray *tempdlvTypes = [NSMutableArray array];
            NSArray *exArr03 = tempCompPrcList[@"dlvTypes"];
            
            for (NSInteger j=0; j<[exArr03 count]; j++) {
                [tempdlvTypes addObject:[exArr03[j] mutableCopy]];
            }
            
            [tempCompPrcList setValue:tempItems forKey:@"items"];
            [tempCompPrcList setValue:tempSortCds forKey:@"sortCds"];
            [tempCompPrcList setValue:tempdlvTypes forKey:@"dlvTypes"];
            [tempCompPrcList setValue:@"1" forKey:@"currentPage"];
            
            [_compPrcList setValue:tempCompPrcList forKey:@"compPrcList"];
        }
        else if ([groupName isEqualToString:@"reviewList"]) {
            _reviewList = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempReviewList = [_reviewList[@"reviewList"] mutableCopy];
            NSMutableArray *tempTabs = [NSMutableArray array];
            
            NSArray *tabs = tempReviewList[@"tabs"];
            for (NSInteger j=0; j<[tabs count]; j++) {
                [tempTabs addObject:[tabs[j] mutableCopy]];
            }
            
            [tempReviewList setValue:tempTabs forKey:@"tabs"];
            [_reviewList setValue:tempReviewList forKey:@"reviewList"];
        }
        else if ([groupName isEqualToString:@"satisfyScore"]) {
            _satisfyScore = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
          
            NSMutableDictionary *tempSatisfyScore = [_satisfyScore[@"satisfyScore"] mutableCopy];
            [_satisfyScore setValue:tempSatisfyScore forKey:@"satisfyScore"];
        }
        else if ([groupName isEqualToString:@"saleGraph"]) {
            _saleGraph = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempSaleGraph = [_saleGraph[@"saleGraph"] mutableCopy];
            NSMutableArray *tempItems = [NSMutableArray array];
            
            NSArray *items = tempSaleGraph[@"items"];
            for (NSInteger i=0; i<[items count]; i++) {
                [tempItems addObject:[items[i] mutableCopy]];
            }
            
            [tempSaleGraph setValue:tempItems forKey:@"items"];
            [_saleGraph setValue:tempSaleGraph forKey:@"saleGraph"];
        }
        else if ([groupName isEqualToString:@"sameCategoryModels"])
        {
            _sameCategoryModels = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempSameCategoryModels = [_sameCategoryModels[@"sameCategoryModels"] mutableCopy];
            NSMutableArray *tempItems = [NSMutableArray array];
            
            NSArray *items = tempSameCategoryModels[@"items"];
            for (NSInteger i=0; i<[items count]; i++) {
                [tempItems addObject:[items[i] mutableCopy]];
            }
            
            [tempSameCategoryModels setValue:tempItems forKey:@"items"];
            [_sameCategoryModels setValue:tempSameCategoryModels forKey:@"sameCategoryModels"];
        }
        else if ([groupName isEqualToString:@"sameBrandModels"])
        {
            _sameBrandModels = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempSameBrandModels = [_sameBrandModels[@"sameBrandModels"] mutableCopy];
            NSMutableArray *tempItems = [NSMutableArray array];
            
            NSArray *items = tempSameBrandModels[@"items"];
            for (NSInteger i=0; i<[items count]; i++) {
                [tempItems addObject:[items[i] mutableCopy]];
            }
            
            [tempSameBrandModels setValue:tempItems forKey:@"items"];
            [_sameBrandModels setValue:tempSameBrandModels forKey:@"sameBrandModels"];
        }
        else if ([groupName isEqualToString:@"bestProducts"])
        {
            _bestProducts = [[NSMutableDictionary alloc] initWithDictionary:items[i]];
            
            NSMutableDictionary *tempBestProducts = [_bestProducts[@"bestProducts"] mutableCopy];
            NSMutableArray *tempItems = [NSMutableArray array];
            
            NSArray *items = tempBestProducts[@"items"];
            for (NSInteger i=0; i<[items count]; i++) {
                [tempItems addObject:[items[i] mutableCopy]];
            }
            
            [tempBestProducts setValue:tempItems forKey:@"items"];
            [_bestProducts setValue:tempBestProducts forKey:@"bestProducts"];
        }
    }
}

- (NSMutableArray *)combinationItems
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (_modelInfo)             [array addObject:_modelInfo];
    if (_relatedModels)         [array addObject:_relatedModels];
    if (_spec)                  [array addObject:_spec];
    if (_compPrcList)           [array addObject:_compPrcList];
    if (_reviewList)            [array addObject:_reviewList];
    if (_satisfyScore)          [array addObject:_satisfyScore];
    if (_saleGraph)             [array addObject:_saleGraph];
    if (_sameCategoryModels)    [array addObject:_sameCategoryModels];
    if (_sameBrandModels)       [array addObject:_sameBrandModels];
    if (_bestProducts)          [array addObject:_bestProducts];
    
    return array;
}

#pragma mark - TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    NSString *groupName = _items[section][@"groupName"];
    if ([groupName isEqualToString:@"modelInfo"])
    {
        numberOfRows = 1;
    }
    else if ([groupName isEqualToString:@"relatedModels"])
    {
        
        NSString *openYn = _items[section][@"relatedModels"][@"selected"];
        if ([openYn isEqualToString:@"N"]) {
            numberOfRows = 0;
        }
        else {
            NSInteger maxCount = [_items[section][@"relatedModels"][@"items"] count];
            NSString *isMore = _items[section][@"relatedModels"][@"isMore"];
            
            if ([isMore isEqualToString:@"Y"])  numberOfRows = maxCount+1;
            else                                numberOfRows = maxCount;
        }
    }
    else if ([groupName isEqualToString:@"spec"])
    {
        NSString *openYn = _items[section][@"spec"][@"selected"];
        if ([openYn isEqualToString:@"N"]) {
            numberOfRows = 0;
        }
        else {
            numberOfRows = 1;
        }
    }
    else if ([groupName isEqualToString:@"compPrcList"])
    {
        NSInteger maxCount = [_items[section][@"compPrcList"][@"items"] count];

        NSString *isMore = _items[section][@"compPrcList"][@"isMore"];
        
        if ([@"Y" isEqualToString:isMore])  numberOfRows = maxCount + 1;
        else                                numberOfRows = maxCount;
    }
    else if ([groupName isEqualToString:@"reviewList"])
    {
        NSArray *tabs = _reviewList[@"reviewList"][@"tabs"];
        
        NSInteger selectIdx = 0;
        for (NSInteger i=0; i<[tabs count]; i++) {
            NSString *selected = tabs[i][@"selected"];
            
            if ([@"Y" isEqualToString:selected]) {
                selectIdx = i;
                break;
            }
        }
        
        NSArray *items = tabs[selectIdx][@"items"];
        NSString *isMore = tabs[selectIdx][@"isMore"];

        if ([items count] > 0) {
            numberOfRows = [items count];
            if ([isMore isEqualToString:@"Y"]) {
                numberOfRows += 1;
            }
        }
        else {
            numberOfRows = 1;
        }
    }
    else if ([groupName isEqualToString:@"satisfyScore"])
    {
        numberOfRows = 1;
    }
    else if ([groupName isEqualToString:@"saleGraph"])
    {
        numberOfRows = 1;
    }
    else if ([groupName isEqualToString:@"sameCategoryModels"])
    {
        numberOfRows = 1;
    }
    else if ([groupName isEqualToString:@"sameBrandModels"])
    {
        numberOfRows = 1;
    }
    else if ([groupName isEqualToString:@"bestProducts"])
    {
        numberOfRows = 1;
    }

    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;
    
    NSString *groupName = _items[section][@"groupName"];
    
    if ([@"modelInfo" isEqualToString:groupName]) {
        height = 10.f;
    }
    else if ([@"relatedModels" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"spec" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"compPrcList" isEqualToString:groupName]) {
        height = 87.f;
    }
    else if ([@"reviewList" isEqualToString:groupName]) {
        height = 93.f;
    }
    else if ([@"satisfyScore" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"saleGraph" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"sameCategoryModels" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"sameBrandModels" isEqualToString:groupName]) {
        height = 40.f;
    }
    else if ([@"bestProducts" isEqualToString:groupName]) {
        height = 40.f;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor clearColor];
    
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, height);

    CPPriceDetailHeaderType headerType = CPPriceDetailHeaderTypeNone;
    NSDictionary *headerItem = nil;
    
    NSString *groupName = _items[section][@"groupName"];
    if ([@"relatedModels" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeRelatedModels;
        headerItem = _items[section][@"relatedModels"];
    }
    else if ([@"spec" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeSpec;
        headerItem = _items[section][@"spec"];
    }
    else if ([@"compPrcList" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeCompPrcList;
        headerItem = _items[section][@"compPrcList"];
    }
    else if ([@"reviewList" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeReviewList;
        headerItem = _items[section][@"reviewList"];
    }
    else if ([@"satisfyScore" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeSatisfyScore;
        headerItem = _items[section][@"satisfyScore"];
    }
    else if ([@"saleGraph" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeSaleGraph;
        headerItem = _items[section][@"saleGraph"];
    }
    else if ([@"sameCategoryModels" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeSameCategoryModels;
        headerItem = _items[section][@"sameCategoryModels"];
    }
    else if ([@"sameBrandModels" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeSameBrandModels;
        headerItem = _items[section][@"sameBrandModels"];
    }
    else if ([@"bestProducts" isEqualToString:groupName]) {
        headerType = CPPriceDetailHeaderTypeBestProducts;
        headerItem = _items[section][@"bestProducts"];
    }
    
    
    CPPriceDetailHeaderView *view = [[CPPriceDetailHeaderView alloc] initWithFrame:CGRectMake(headerView.frame.origin.x+10, 0,
                                                                                              headerView.frame.size.width-20.f,
                                                                                              headerView.frame.size.height)];
    view.type = headerType;
    view.item = headerItem;
    view.delegate = self;
    
    [headerView addSubview:view];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = _items[indexPath.section][@"groupName"];
    
    UITableViewCell *cell = nil;
    
    if ([@"modelInfo" isEqualToString:groupName]) {
        cell = [self getModelInfoCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"relatedModels" isEqualToString:groupName]) {
        cell = [self getRelatedModelsCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"spec" isEqualToString:groupName]) {
        cell = [self getSpecCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"compPrcList" isEqualToString:groupName]) {
        cell = [self getCompPrcListCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"reviewList" isEqualToString:groupName]) {
        cell = [self getReviewListCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"satisfyScore" isEqualToString:groupName])
    {
        cell = [self getSatisfyScoreCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"saleGraph" isEqualToString:groupName])
    {
        cell = [self getSaleGraphCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"sameCategoryModels" isEqualToString:groupName])
    {
        cell = [self getSameCategoryModelsCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"sameBrandModels" isEqualToString:groupName])
    {
        cell = [self getSameBrandModelsCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else if ([@"bestProducts" isEqualToString:groupName])
    {
        cell = [self getBestProductCell:tableView cellForRowAtIndexPath:indexPath];
    }
    else {
        NSString *ideneifier = @"defaultCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UITableViewCell *)getModelInfoCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"modelInfo";
    
    NSDictionary *item = _items[indexPath.section][@"modelInfo"];
    
    CPPriceDetailModelInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailModelInfoCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    
    return cell;
}

- (UITableViewCell *)getRelatedModelsCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"relatedModels";
    
    NSInteger currentPageNum = [_items[indexPath.section][@"relatedModels"][@"currentPage"] integerValue];
    NSInteger maxCount = (currentPageNum * 5);

    BOOL isMore = NO;
    if (indexPath.row >= maxCount)  isMore = YES;
    else                            isMore = NO;

    NSDictionary *item = (isMore ? nil : _items[indexPath.section][@"relatedModels"][@"items"][indexPath.row]);
    
    CPPriceDetailRelatedModelsCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailRelatedModelsCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    cell.isMore = isMore;
    cell.isLastCell = (indexPath.row+1 >= maxCount ? NO : [_items[indexPath.section][@"relatedModels"][@"items"] count]-1 == indexPath.row);
    
    return cell;
}

- (UITableViewCell *)getSpecCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"spec";

    NSDictionary *item = _items[indexPath.section][@"spec"];
    
    CPPriceDetailSpecCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailSpecCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.item = item;
    
    return cell;
}

- (UITableViewCell *)getCompPrcListCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"compPrcList";
    
    NSInteger currentPageNum = [_items[indexPath.section][@"compPrcList"][@"currentPage"] integerValue];
    NSInteger maxCount = (currentPageNum * 5);
    
    BOOL isMore = NO;
    if (indexPath.row >= maxCount)  isMore = YES;
    else                            isMore = NO;
    
    NSDictionary *item = (isMore ? nil : _items[indexPath.section][@"compPrcList"][@"items"][indexPath.row]);
    
    CPPriceDetailCompPrcListCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailCompPrcListCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    cell.isMore = isMore;
    cell.isLastCell = (indexPath.row+1 >= maxCount ? NO : [_items[indexPath.section][@"compPrcList"][@"items"] count]-1 == indexPath.row);
    
    return cell;
}

- (UITableViewCell *)getReviewListCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"reviewList";

    NSArray *tabs = _reviewList[@"reviewList"][@"tabs"];
    
    NSInteger selectIdx = 0;
    for (NSInteger i=0; i<[tabs count]; i++) {
        NSString *selected = tabs[i][@"selected"];
        
        if ([@"Y" isEqualToString:selected]) {
            selectIdx = i;
            break;
        }
    }

    NSArray *items = tabs[selectIdx][@"items"];
    NSDictionary *item = nil;
    
    BOOL isMore = NO;
    BOOL isNoItem = NO;
    if ([items count] > 0) {
        if (indexPath.row >= [items count]) {
            isMore = YES;
        }
        else {
            isMore = NO;
            item = items[indexPath.row];
        }
        isNoItem = NO;
    }
    else
    {
        isNoItem = YES;
    }

    CPPriceDetailReviewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailReviewItemCell alloc] initWithReuseIdentifier:ideneifier];
    
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    cell.isMore = isMore;
    cell.isNoItem = isNoItem;
    cell.tabIdx = selectIdx;
    cell.isLastCell = ([tabs[selectIdx][@"isMore"] isEqualToString:@"Y"] ? NO : [items count]-1 == indexPath.row);
    
    return cell;
}

- (UITableViewCell *)getSatisfyScoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"satisfyScore";
    
    NSDictionary *item = _items[indexPath.section][@"satisfyScore"];
    
    CPPriceDetailSatisfyScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailSatisfyScoreCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.item = item;
    
    return cell;
}

- (UITableViewCell *)getSaleGraphCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"saleGraph";
    
    NSDictionary *item = _items[indexPath.section][@"saleGraph"];
    
    CPPriceDetailSaleGraphCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailSaleGraphCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    
    return cell;
}

- (UITableViewCell *)getSameCategoryModelsCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"sameCategoryModels";
    
    NSDictionary *item = _items[indexPath.section][@"sameCategoryModels"];
    
    CPPriceDetailSameCategoryModelsCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailSameCategoryModelsCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    cell.groupName = @"sameCategoryModels";
    
    return cell;
}

- (UITableViewCell *)getSameBrandModelsCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"sameBrandModels";
    
    NSDictionary *item = _items[indexPath.section][@"sameBrandModels"];
    
    CPPriceDetailSameCategoryModelsCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailSameCategoryModelsCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    cell.groupName = @"sameBrandModels";
    
    return cell;
}

- (UITableViewCell *)getBestProductCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"bestProducts";
    
    NSDictionary *item = _items[indexPath.section][@"bestProducts"];
    
    CPPriceDetailBestProductCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPPriceDetailBestProductCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.item = item;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    NSString *groupName = _items[indexPath.section][@"groupName"];
    
    if ([groupName isEqualToString:@"modelInfo"]) {
        
        if (kScreenBoundsWidth < 414)   height = 10+100+9+36+10;
        else                            height = 10+140+10+1;
    }
    else if ([groupName isEqualToString:@"relatedModels"]) {
        
        NSInteger currentPageNum = [_items[indexPath.section][@"relatedModels"][@"currentPage"] integerValue];
        NSInteger maxCount = (currentPageNum * 5);
        
        BOOL isMore = NO;
        if (indexPath.row >= maxCount)      isMore = YES;
        else                                isMore = NO;
        
        if (isMore) {
            height = 58.f;
        }
        else {
            NSDictionary *item = _items[indexPath.section][@"relatedModels"][@"items"][indexPath.row];
            NSString *text = item[@"modelNm"];
            
            //상하단 마진
            height = 20.f;
            
            //옵션명 높이
            height += [Modules getLabelHeightWithText:text
                                                frame:CGRectMake(0, 0, tableView.frame.size.width-42, 0)
                                                 font:[UIFont systemFontOfSize:14]
                                                lines:2
                                        textAlignment:NSTextAlignmentLeft];
            height += 4;
            
            //가격 높이 : 가격이 중요한 것이 아니라 높이가 중요하기 때문에 1글자만 넣는다.
            height += [Modules getLabelHeightWithText:@"0"
                                                frame:CGRectMake(0, 0, tableView.frame.size.width-42, 0)
                                                 font:[UIFont boldSystemFontOfSize:16]
                                                lines:1
                                        textAlignment:NSTextAlignmentLeft];
        }
    }
    else if ([groupName isEqualToString:@"spec"]) {
        
        NSDictionary *item = _items[indexPath.section][@"spec"];
        NSString *text = item[@"content"];
        height = [Modules getLabelHeightWithText:text
                                           frame:CGRectMake(0, 0, tableView.frame.size.width-42, 0)
                                            font:[UIFont systemFontOfSize:14]
                                           lines:99
                                   textAlignment:NSTextAlignmentLeft];
        height += 22.f;
    }
    else if ([groupName isEqualToString:@"compPrcList"]) {
        height = 48;
    }
    else if ([groupName isEqualToString:@"reviewList"]) {
        
        NSArray *tabs = _reviewList[@"reviewList"][@"tabs"];
        
        NSInteger selectIdx = 0;
        for (NSInteger i=0; i<[tabs count]; i++) {
            NSString *selected = tabs[i][@"selected"];
            
            if ([@"Y" isEqualToString:selected]) {
                selectIdx = i;
                break;
            }
        }
        
        NSArray *items = tabs[selectIdx][@"items"];
        if ([items count] > 0) {
            BOOL isMore = NO;

            if (indexPath.row >= [items count]) isMore = YES;
            else                                isMore = NO;
            
            height = (isMore ? 58 : 104);
        }
        else {
            height = 46 + 43+12+49+16;
        }
    }
    else if ([groupName isEqualToString:@"satisfyScore"]) {
        height = 122 + 181;
    }
    else if ([groupName isEqualToString:@"saleGraph"]) {
        height = 227;
    }
    else if ([groupName isEqualToString:@"sameCategoryModels"]) {
        height = 227;
    }
    else if ([groupName isEqualToString:@"sameBrandModels"]) {
        height = 227;
    }
    else if ([groupName isEqualToString:@"bestProducts"]) {
        height = 198;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Private Methods

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
    
    if (homeViewController && [homeViewController respondsToSelector:@selector(openWebViewControllerWithUrl:animated:)]) {
        [homeViewController openWebViewControllerWithUrl:url animated:animated];
    }
}

- (NSInteger)getIndexPathFromGroupName:(NSString *)groupName
{
    NSInteger index = -1;
    
    for (NSInteger i=0; i<[_items count]; i++) {
        
        NSString *gName = _items[i][@"groupName"];
        
        if ([gName isEqualToString:groupName]) {
            index = i;
            break;
        }
    }
    
    return index;
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

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
    if ([SYSTEM_VERSION intValue] < 7) {
        [viewController setWantsFullScreenLayout:YES];
    }
    
    viewController.isSearchText = YES;
    viewController.defaultText = [self.keyword stringByReplacingPercentEscapesUsingEncoding:DEFAULT_ENCODING];
    [self presentViewController:viewController animated:NO completion:nil];
}

- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword
{
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:@""];
    [self.navigationController pushViewController:viewConroller animated:YES];
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:@""];
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
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case CPToolBarButtonTypeForward:
            if ([button isEnabled]) {
            }
            break;
        case CPToolBarButtonTypeReload:
            [self requestItem:self.modelNo];
            break;
        case CPToolBarButtonTypeTop:
            [_tableView setContentOffset:CGPointZero animated:YES];
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
            [self openWebViewControllerWithUrl:url animated:YES];
            break;
        }
        case CPPopOverMenuTypeSetting:
        {
            SetupController *viewController = [[SetupController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self closePopupFilterView];
    
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

#pragma mark - CPErrorViewDelegate

- (void)didTouchRetryButton
{
    if (self.modelNo && [self.modelNo length] > 0) {
        [self removeErrorView];
        [self performSelectorInBackground:@selector(requestItem:) withObject:self.modelNo];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
                                                            message:NSLocalizedString(@"NetworkTemporaryErrMsg", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

#pragma mark - CPBannerManagerDelegate

- (void)didTouchBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

#pragma mark - CPBannerViewDelegate

- (void)didTouchLineBannerButton:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
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

#pragma mark - filterPopup Methods
- (void)openPopupFilterView:(NSString *)filterTypeStr frame:(CGRect)frame
{
    if ([filterTypeStr isEqualToString:@"dlvTypes"])    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDE01"];
    else                                                [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDF01"];
    
    //뷰가 열려있으면 닫는다.
    [self closePopupFilterView];
    
    NSArray *items = _compPrcList[@"compPrcList"][filterTypeStr];
    
    CGFloat height = 32 * ([items count] + 1);
    frame.size.height = height;
    
    _filterView = [[UIView alloc] initWithFrame:frame];
    _filterView.backgroundColor = UIColorFromRGB(0xffffff);
    [_tableView addSubview:_filterView];
    
    CGFloat offsetY = 0.f;
    
    //첫번째 ITEM
    NSString *firstStr = @"";
    for (NSInteger i=0; i<[items count]; i++) {
        NSString *selected = items[i][@"selected"];
        if ([@"Y" isEqualToString:selected]) {
            firstStr = items[i][@"title"];
            break;
        }
    }
    
    UIButton *firstBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    firstBtn.frame = CGRectMake(0, offsetY, _filterView.frame.size.width, 32);
    [firstBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
                                                   width:firstBtn.frame.size.width
                                                  height:firstBtn.frame.size.height]
                        forState:UIControlStateHighlighted];
    [firstBtn addTarget:self action:@selector(closePopupFilterView) forControlEvents:UIControlEventTouchUpInside];
    [firstBtn setAccessibilityLabel:@"변경하지 않기" Hint:@""];
    [_filterView addSubview:firstBtn];
    
    UIImage *dropDownImg = [UIImage imageNamed:@"bt_s_arrow_down_02.png"];
    UIImageView *dlvDropView = [[UIImageView alloc] initWithFrame:CGRectMake(firstBtn.frame.size.width-8-dropDownImg.size.width,
                                                                             (firstBtn.frame.size.height/2)-(dropDownImg.size.height/2),
                                                                             dropDownImg.size.width, dropDownImg.size.height)];
    dlvDropView.image = dropDownImg;
    [firstBtn addSubview:dlvDropView];
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    firstLabel.backgroundColor = [UIColor clearColor];
    firstLabel.textColor = UIColorFromRGB(0xBDBDC0);
    firstLabel.font = [UIFont systemFontOfSize:14];
    firstLabel.text = firstStr;
    [firstLabel sizeToFitWithVersion];
    [firstBtn addSubview:firstLabel];
    
    firstLabel.frame = CGRectMake(7, (firstBtn.frame.size.height/2)-(firstLabel.frame.size.height/2),
                                  firstLabel.frame.size.width, firstLabel.frame.size.height);
    
    UIView *firstLine = [[UIView alloc] initWithFrame:CGRectMake(0, firstBtn.frame.size.height-1, firstBtn.frame.size.width, 1)];
    firstLine.backgroundColor = UIColorFromRGB(0xe6e6e8);
    [firstBtn addSubview:firstLine];
    
    offsetY = CGRectGetMaxY(firstBtn.frame);
    
    //두번째 부터는 실제 데이터를 뿌린다.
    for (NSInteger i=0; i<[items count]; i++)
    {
        NSString *selectedYn = items[i][@"selected"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, offsetY, _filterView.frame.size.width, 32);
        
        if ([@"Y" isEqualToString:selectedYn]) {
            [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x5D5FD6)
                                                      width:btn.frame.size.width
                                                     height:btn.frame.size.height]
                           forState:UIControlStateNormal];
        }
        else {
            [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xffffff)
                                                      width:btn.frame.size.width
                                                     height:btn.frame.size.height]
                           forState:UIControlStateNormal];
        }
        
        [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
                                                  width:btn.frame.size.width
                                                 height:btn.frame.size.height]
                       forState:UIControlStateHighlighted];
        
        if ([filterTypeStr isEqualToString:@"dlvTypes"]) {
            [btn addTarget:self action:@selector(onTouchOpenPopupDlvFilter:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [btn addTarget:self action:@selector(onTouchOpenPopupSortFilter:) forControlEvents:UIControlEventTouchUpInside];
        }
        [btn setTag:i];
        [btn setAccessibilityLabel:[NSString stringWithFormat:@"%@ 보기", items[i][@"title"]] Hint:@""];
        [_filterView addSubview:btn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = ([@"Y" isEqualToString:selectedYn] ? UIColorFromRGB(0xFFFFFF) : UIColorFromRGB(0x4D4D4D));
        label.font = [UIFont systemFontOfSize:14];
        label.text = items[i][@"title"];
        [label sizeToFitWithVersion];
        [btn addSubview:label];
        
        label.frame = CGRectMake(7, (btn.frame.size.height/2)-(label.frame.size.height/2),
                                 label.frame.size.width, label.frame.size.height);
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, btn.frame.size.height-1, btn.frame.size.width, 1)];
        line.backgroundColor = UIColorFromRGB(0xe6e6e8);
        [btn addSubview:line];
        
        offsetY = CGRectGetMaxY(btn.frame);
    }
    
    UIView *tLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _filterView.frame.size.width, 1)];
    tLine.backgroundColor = UIColorFromRGB(0x747277);
    [_filterView addSubview:tLine];
    
    UIView *bLine = [[UIView alloc] initWithFrame:CGRectMake(0, _filterView.frame.size.height-1, _filterView.frame.size.width, 1)];
    bLine.backgroundColor = UIColorFromRGB(0x747277);
    [_filterView addSubview:bLine];
    
    UIView *lLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _filterView.frame.size.height)];
    lLine.backgroundColor = UIColorFromRGB(0x747277);
    [_filterView addSubview:lLine];
    
    UIView *rLine = [[UIView alloc] initWithFrame:CGRectMake(_filterView.frame.size.width-1, 0, 1, _filterView.frame.size.height)];
    rLine.backgroundColor = UIColorFromRGB(0x747277);
    [_filterView addSubview:rLine];
}

- (void)closePopupFilterView
{
    if (_filterView)
    {
        [_filterView removeFromSuperview];
        _filterView = nil;
    }
}

- (void)onTouchOpenPopupSortFilter:(id)sender
{
    NSInteger selectedIndex = [sender tag];
    
    NSInteger currentPage = 1;
    
    NSString *sortCd = @"";
    NSString *dlvTypeCd = @"";
    
    //sortCd를 찾는다.
    NSArray *sortCds = _compPrcList[@"compPrcList"][@"sortCds"];
    sortCd = sortCds[selectedIndex][@"code"];
    
    //dlvTypeCode를 찾는다.
    NSArray *dlvTypes = _compPrcList[@"compPrcList"][@"dlvTypes"];
    for (NSInteger i=0; i<[dlvTypes count]; i++)
    {
        NSString *selected = dlvTypes[i][@"selected"];
        
        if ([@"Y" isEqualToString:selected])
        {
            dlvTypeCd = dlvTypes[i][@"code"];
            break;
        }
    }
    
    if ([sortCd isEqualToString:@"NP"])         [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDF03"];
    else if ([sortCd isEqualToString:@"L"])     [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDF02"];
    else if ([sortCd isEqualToString:@"H"])     [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDF04"];
    else if ([sortCd isEqualToString:@"I"])     [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDF05"];
    
    [self requestFilterItem:currentPage sortCd:sortCd dlvTypeCd:dlvTypeCd];
    [self closePopupFilterView];
}

- (void)onTouchOpenPopupDlvFilter:(id)sender
{
    NSInteger selectedIndex = [sender tag];
    
    NSInteger currentPage = 1;
    
    NSString *sortCd = @"";
    NSString *dlvTypeCd = @"";
    
    //sortCd를 찾는다.
    NSArray *sortCds = _compPrcList[@"compPrcList"][@"sortCds"];
    for (NSInteger i=0; i<[sortCds count]; i++)
    {
        NSString *selected = sortCds[i][@"selected"];
        
        if ([@"Y" isEqualToString:selected])
        {
            sortCd = sortCds[i][@"code"];
            break;
        }
    }
    
    //dlvTypeCode를 찾는다.
    NSArray *dlvTypes = _compPrcList[@"compPrcList"][@"dlvTypes"];
    dlvTypeCd = dlvTypes[selectedIndex][@"code"];
    
    if ([dlvTypeCd isEqualToString:@"ALL"])         [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDE02"];
    else if ([dlvTypeCd isEqualToString:@"FREE"])   [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDE03"];
    else if ([dlvTypeCd isEqualToString:@"NOFREE"]) [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDE04"];
    
    
    [self requestFilterItem:currentPage sortCd:sortCd dlvTypeCd:dlvTypeCd];
    [self closePopupFilterView];
}

#pragma mark - CPPriceDetailHeaderViewDelegate
- (void)priceDetailHeaderOnTouchOpenYn:(BOOL)isOpen type:(CPPriceDetailHeaderType)type
{
    if (type == CPPriceDetailHeaderTypeRelatedModels) {
        if (_relatedModels) {
            
            NSMutableDictionary *tempRelatedModels = _relatedModels[@"relatedModels"];
            [tempRelatedModels setValue:(isOpen ? @"Y" : @"N") forKey:@"selected"];
            [_relatedModels setValue:tempRelatedModels forKey:@"relatedModels"];
            
            _items = [self combinationItems];

            if (_items) [_tableView reloadData];
            
            if (isOpen) {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDC06"];
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDC02"];
                
                if ([@"Y" isEqualToString:tempRelatedModels[@"isMore"]]) {
                    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDC04"];    
                }
            }
            else {
                [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDC01"];
            }
        }
    }
    else if (type == CPPriceDetailHeaderTypeSpec) {
        if (_spec) {
            NSMutableDictionary *tempSpec = _spec[@"spec"];
            [tempSpec setValue:(isOpen ? @"Y" : @"N") forKey:@"selected"];
            [_spec setValue:tempSpec forKey:@"spec"];
            
            _items = [self combinationItems];
            
            if (_items) [_tableView reloadData];
            
            if (isOpen) [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDD01"];
            else        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDD02"];
        }
    }
    else if (type == CPPriceDetailHeaderTypeBestProducts) {
        NSMutableDictionary *tempBestProducts = _bestProducts[@"bestProducts"];
        NSString *linkUrl = tempBestProducts[@"linkUrl"];
        
        if (!nilCheck(linkUrl)) {
            [self openWebViewControllerWithUrl:linkUrl animated:YES];
        }
    }
}

- (void)priceDetailHeaderOnTouchFilterPopup:(NSString *)filterTypeStr
{
    NSInteger section = [self getIndexPathFromGroupName:@"compPrcList"];
    
    if (section != -1) {
        //헤더뷰의 높이를 구함.
        CGRect frame = [_tableView rectForHeaderInSection:section];

        //헤더뷰를 기준으로 눌린 버튼의 영역을 구함.
        CGRect viewFrame = CGRectMake(([filterTypeStr isEqualToString:@"dlvTypes"] ? 20 : 20+((frame.size.width-40-8)/2)+8),
                                      frame.origin.y+49, (frame.size.width-40-8)/2, 0);
 
        [self openPopupFilterView:filterTypeStr frame:viewFrame];
    }
}

- (void)priceDetailHeaderOnTOuchReviewTabs:(NSInteger)selectIdx
{
    NSMutableDictionary *tempReviewList = _reviewList[@"reviewList"];
    
    NSMutableArray *tempTabs = [NSMutableArray array];
    NSArray *tabs = tempReviewList[@"tabs"];
    
    for (NSInteger i=0; i<[tabs count]; i++) {
        NSMutableDictionary *item = [tabs[i] mutableCopy];
        [item setValue:(i == selectIdx ? @"Y" : @"N") forKey:@"selected"];
        
        [tempTabs addObject:item];
    }
    
    [tempReviewList setValue:tempTabs forKey:@"tabs"];
    [_reviewList setValue:tempReviewList forKey:@"reviewList"];
    
    _items = [self combinationItems];
    
    if (_items) [_tableView reloadData];
}

#pragma mark - CPPriceDetailRelatedModelsCellDelegate
- (void)priceDetailRelatedModelsCell:(CPPriceDetailRelatedModelsCell *)cell onTouchChangeModel:(NSString *)modelNo
{
    [self requestItem:modelNo];
}

- (void)relatedModelsCellShowNextItem
{
    NSMutableDictionary *tempRelatedModels = _relatedModels[@"relatedModels"];
    
    NSInteger nextPage = [tempRelatedModels[@"currentPage"] integerValue]+1;
    NSString *moreUrl = tempRelatedModels[@"moreUrl"];
    
    if (!nilCheck(moreUrl)) {
        moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:[NSString stringWithFormat:@"%ld", (long)nextPage]];
        moreUrl = [moreUrl stringByReplacingOccurrencesOfString:@"{{modelNo}}" withString:self.modelNo];
        [self requestRelatedModelsMoreItems:moreUrl page:nextPage];
    }
}

#pragma mark - CPPriceDetailCompPrcListCellDelegate
- (void)compPrcListCellShowNextItem
{
    NSInteger currentPage = [_compPrcList[@"compPrcList"][@"currentPage"] integerValue];
    currentPage++;
    
    NSString *sortCd = @"";
    NSString *dlvTypeCd = @"";
    
    //sortCd를 찾는다.
    NSArray *sortCds = _compPrcList[@"compPrcList"][@"sortCds"];
    for (NSInteger i=0; i<[sortCds count]; i++)
    {
        NSString *selected = sortCds[i][@"selected"];
        
        if ([@"Y" isEqualToString:selected])
        {
            sortCd = sortCds[i][@"code"];
            break;
        }
    }
    
    //dlvTypeCode를 찾는다.
    NSArray *dlvTypes = _compPrcList[@"compPrcList"][@"dlvTypes"];
    for (NSInteger i=0; i<[dlvTypes count]; i++)
    {
        NSString *selected = dlvTypes[i][@"selected"];
        
        if ([@"Y" isEqualToString:selected])
        {
            dlvTypeCd = dlvTypes[i][@"code"];
            break;
        }
    }
    
    [self requestFilterItem:currentPage sortCd:sortCd dlvTypeCd:dlvTypeCd];
}

#pragma mark - CPPriceDetailReviewItemCellDelegate
- (void)reviewItemCellShowMoreItem:(NSInteger)tabIdx
{
    if (tabIdx == 0)    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDJ07"];
    else                [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDK07"];

    NSString *moreUrl = _reviewList[@"reviewList"][@"tabs"][tabIdx][@"linkUrl"];
    
    if (!nilCheck(moreUrl)) {
        [[CPSchemeManager sharedManager] openUrlScheme:moreUrl sender:nil changeAnimated:NO];
    }
}

#pragma mark - CPPriceDetailSaleGraphCellCell Delegate
- (void)saleGraphCellSelectedIndex:(NSInteger)index
{
    NSMutableDictionary *tempSaleGraph = _saleGraph[@"saleGraph"];
    NSMutableArray *tempItems = [NSMutableArray array];

    NSArray *items = tempSaleGraph[@"items"];
    for (NSInteger i=0; i<[items count]; i++) {
        NSMutableDictionary *item = [items[i] mutableCopy];
        [item setValue:(i == index ? @"Y" : @"N") forKey:@"selected"];

        [tempItems addObject:item];
    }
    
    [tempSaleGraph setValue:tempItems forKey:@"items"];
    [_saleGraph setValue:tempSaleGraph forKey:@"saleGraph"];
    
    _items = [self combinationItems];
    
    if (_items) [_tableView reloadData];
}

#pragma mark - CPPriceDetailSameCategoryModelsCellDelegate
- (void)priceDetailSameCategoryModelsCell:(CPPriceDetailSameCategoryModelsCell *)cell onTouchChangeModel:(NSString *)modelNo
{
    [self requestItem:modelNo];
}

#pragma mark - CPPriceDetailBestProductCellDelegate
- (void)priceDetailBestProductCell:(CPPriceDetailBestProductCell *)cell onTouchMoreLink:(NSString *)linkUrl
{
    if (!nilCheck(linkUrl)) {
        [self openWebViewControllerWithUrl:linkUrl animated:YES];
    }
}

#pragma mark - CPSchemeManagerDelegate
- (void)openPopupBrowserView:(NSDictionary *)popupInfo
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
    
    if (homeViewController && [homeViewController respondsToSelector:@selector(openPopupBrowserView:)]) {
        [homeViewController openPopupBrowserView:popupInfo];
    }
}

@end
