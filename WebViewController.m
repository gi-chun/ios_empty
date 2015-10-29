//
//  WebViewController.m
//
//  Created by gclee on 2015. 10. 28..
//  Copyright (c) 2015년 gclee. All rights reserved.
//

#import "WebViewController.h"
//#import "CPMartSearchViewController.h"
//#import "CPSearchViewController.h"
//#import "CPPopupViewController.h"
//#import "CPContactViewController.h"
//#import "CPShareViewController.h"
//#import "CPSnapshotViewController.h"
//#import "CPSnapshotListViewController.h"
//#import "CPProductListViewController.h"
//#import "PhotoReviewController.h"
//#import "SetupController.h"
//#import "SetupNotifyController.h"
//#import "SetupOtpController.h"
//#import "CPWebView.h"
//#import "CPPopupBrowserView.h"
//#import "CPNavigationBarView.h"
//#import "CPVideoPopupView.h"
//#import "CPVideoInfo.h"
//#import "CPSchemeManager.h"
#import "WebView.h"
//#import "CPCommonInfo.h"
#import "NavigationBarView.h"
//#import "CPMartSearchViewController.h"
//#import "CPMenuViewController.h"
//#import "CPDeveloperInfo.h"
//#import "CPCategoryMainViewController.h"
//#import "CPCategoryDetailViewController.h"
//#import "CPProductListViewController.h"
//#import "CPProductViewController.h"
//#import "CPHomeViewController.h"
//
//#import "Modules.h"
//#import "UIViewController+MMDrawerController.h"
//#import "AccessLog.h"
//#import "RegexKitLite.h"
//#import "ShakeModule.h"
//#import "ImageViewer.h"
//#import "ActionSheet.h"
//#import "ShakeModule.h"
//#import "SBJSON.h"
//#import "NSString+SBJSON.h"
//#import "LocalNotification.h"
//
//#import <MediaPlayer/MediaPlayer.h>
@interface WebViewController () <WebViewDelegate>
{
    NSString *webViewUrl;
    NSURLRequest *webViewRequest;
    
    BOOL isSearchText;
    
    //CPPopupBrowserView *popUpBrowserView;
    
    NSString *zoomViewerScheme;
    
    //ShakeModule *shakeModule;
    
    NavigationBarView *navigationBarView;
    //CPWebviewControllerFullScreenMode fullScreenMode;
    
    BOOL isSkipParent;
    BOOL isIgnore;
    BOOL isProduct;
}

//@property (nonatomic, strong) CPNavigationBarView *navigationBarView;

@end

@implementation WebViewController

- (id)initWithUrl:(NSString *)url
{
    if (self = [super init]) {
        webViewUrl = url;
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop
{
    if (self = [self initWithUrl:url]) {
        isSkipParent = isPop;
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore
{
    if (self = [self initWithUrl:url]) {
        isSkipParent = isPop; //백버튼을 눌렀을때 WebViewController 패스
        isIgnore = ignore; //상품상세 url이 들어왔을 경우 무한루프 방지
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore isProduct:(BOOL)product
{
    if (self = [self initWithUrl:url]) {
        isSkipParent = isPop; //백버튼을 눌렀을때 WebViewController 패스
        isIgnore = ignore; //상품상세 url이 들어왔을 경우 무한루프 방지
        isProduct = product; //상품상세 native에서 들어왔을 경우 웹뷰내에 상품상세url이 호출되면 navigation pop (ex. 주문에서 history back)
    }
    
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request
{
    if (self = [super init]) {
        webViewRequest = request;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];

    // Layout
    [self initLayout];
    
    //fullScreenMode
    //fullScreenMode = CPWebviewControllerFullScreenModeNone;
    
    // setCurrentWebViewController
    //[[CPCommonInfo sharedInfo] setCurrentWebViewController:self];
    
    // CPSchemeManager delegate
    //[[CPSchemeManager sharedManager] setDelegate:self];
    NSLog(@"CPSchemeManager setDelegate WebViewController");
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
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];

    //Exception URL은 풀스크린으로 보여줌 (저장된 상태값으로 보여줌. PC보기에서 URL을 체킹하지 못하는 오류가 있음.)
//    if (fullScreenMode != CPWebviewControllerFullScreenModeNone) {
//        [self setExceptionFrame:(fullScreenMode == CPWebviewControllerFullScreenModeOn)];
//    }
    
    if (isSkipParent) {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        
        if (viewControllers.count >= 2) {
            [viewControllers removeObjectAtIndex:viewControllers.count-2];
            self.navigationController.viewControllers = viewControllers;
        }
        
        isSkipParent = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // setCurrentWebViewController
    //[[CPCommonInfo sharedInfo] setCurrentWebViewController:nil];
    
    [self.webView setHiddenPopover:YES];
}

- (void)didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initLayout
{
    self.webView = [[WebView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-kNavigationHeight) isSub:YES];
    [self.webView setDelegate:self];
    [self.webView setHiddenToolBarView:NO];
    [self.view addSubview:self.webView];
    
    if (webViewRequest) {
        [self.webView loadRequest:webViewRequest];
    }
    else {
        if (webViewUrl) {
            [self.webView open:webViewUrl];
        }
    }
}

- (NavigationBarView *)navigationBarView:(NSInteger)navigationType
{
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44) type:navigationType];
    [navigationBarView setDelegate:self];

    
    //    // 개발자모드 진입점
    //    [self initDeveloperInfo:logoButton];
    //    //    }
    
    return navigationBarView;
}

#pragma mark - Private Methods

- (void)openWebView:(NSString *)url request:(NSURLRequest *)request
{
    //BOOL isException = [CPCommonInfo isExceptionalUrl:url];
    BOOL isException = false;
    CGRect webViewFrame;
    
    // Exception URL은 네비게이션바없는 풀화면으로 보여줌
    if (isException) {
        [self.navigationController setNavigationBarHidden:YES];
        
        if ([SYSTEM_VERSION intValue] > 6) {
            webViewFrame = CGRectMake(0, STATUSBAR_HEIGHT, kScreenBoundsWidth, kScreenBoundsHeight-STATUSBAR_HEIGHT);
        }
        else {
            webViewFrame = CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-STATUSBAR_HEIGHT);
        }
    }
    else {
        [self.navigationController setNavigationBarHidden:NO];
        webViewFrame = CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-64);
    }
    
    if (self.webView) {
        [self.webView setFrame:webViewFrame];
        [self.webView updateFrame];
        
        if (request) {
            [self.webView loadRequest:request];
        }
        else {
            [self.webView open:url];
        }
    }
    else {
        self.webView = [[WebView alloc] initWithFrame:webViewFrame isSub:YES];
        [self.webView setDelegate:self];
        [self.webView open:url];
        [self.webView setHiddenToolBarView:NO];
        [self.view addSubview:self.webView];
    }
}

- (void)openSettingViewController
{
//    SetupController *viewController = [[SetupController alloc] init];
//    viewController.delegate = self;
//    
//    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSString *)removeQueryStringWithUrl:(NSString *)url
{
//    NSString *appVCA = [APP_VERSION stringByReplacingOccurrencesOfRegex:@"[^0-9]+" withString:@""];
//    NSString *appVersionSet = [NSString stringWithFormat:@"%@&appVCA=%@&appVersion=%@&deviceId=%@", URL_QUERY_VARS, appVCA, APP_VERSION, DEVICE_ID];
//    
//    if (url && ![[url trim] isEqualToString:@""]) {
//        NSMutableString *tempUrl = [[NSMutableString alloc] initWithString:url];
//        
//        return [tempUrl stringByReplacingOccurrencesOfString:appVersionSet withString:@""];
//    }
    
    return url;
}

- (void)openProductViewController:(NSString *)prdNo isPop:(BOOL)isPop parameters:(NSDictionary *)parameters
{
//    CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo
//                                                                                               isPop:isPop
//                                                                                          parameters:parameters];
//    [self.navigationController pushViewController:viewController animated:NO];
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchMenuButton
{
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        
//        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        CPMenuViewController *menuViewController = app.menuViewController;
//        
//        [menuViewController didTouchInMart];
//        
//        //AccessLog - 사이드메뉴
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0001"];
//    }
}

- (void)didTouchBasketButton
{
    //NSString *cartUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cart"];
    
    NSString *cartUrl = @"http://www.daum.net";
    [self openWebView:cartUrl request:nil];
}

- (void)didTouchLogoButton
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeNotification object:self];
}

- (void)didTouchMartButton
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    CPHomeViewController *homeViewController = app.homeViewController;
//    
//    [homeViewController didTouchMartButton];
//    [homeViewController goToPageAction:@"MART"];
}

- (void)didTouchMyInfoButton
{
    //[self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)didTouchSearchButton:(NSString *)keywordUrl;
{
    if (keywordUrl) {
        [self openWebView:keywordUrl request:nil];
    }
}

- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword
{
//    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:webViewUrl];
//    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)didTouchMartSearchButton
{
//    CPMartSearchViewController *viewController = [[CPMartSearchViewController alloc] init];
//    [viewController setDelegate:self];
////    [self.navigationController pushViewController:viewController animated:NO];
////    [self.navigationController setNavigationBarHidden:YES];
//    [self presentViewController:viewController animated:NO completion:nil];
}

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
//    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
//    [viewController setDelegate:self];
//    
////    if ([SYSTEM_VERSION intValue] < 7) {
////        [viewController setWantsFullScreenLayout:YES];
////    }
//    
////    viewController.defaultUrl = keywordUrl;
////    viewController.isSearchText = isSearchText;
////    
////    if (isSearchText) {
////        viewController.defaultText = keyword;
////    }
//    
//    [self presentViewController:viewController animated:NO completion:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
//    [self.navigationController setNavigationBarHidden:YES];
}
    
- (void)searchTextFieldShouldBeginEditing
{
    
}

#pragma mark - WebViewDelegate - WebView

- (BOOL)webView:(WebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
{
    NSString *url = request ? request.URL.absoluteString : nil;
    
    NSLog(@"url:%@", url);
    
    //앱링크로 리다이렉트
//    if ([url isMatchedByRegex:@"/MW/html/category/grp.html"]) {
//        CPCategoryMainViewController *viewController = [[CPCategoryMainViewController alloc] init];
//        [self.navigationController pushViewController:viewController animated:NO];
//        return NO;
//    }
//    else if ([url isMatchedByRegex:@"/MW/Category/displayCategory1Depth.tmall"]) {
//        NSString *categoryUrl = APP_CATEGORY_URL;
//        NSString *dispCtgrNo = [Modules extractingParameterWithUrl:url key:@"dispCtgrNo"];
//        categoryUrl = [categoryUrl stringByReplacingOccurrencesOfString:@"{{dispCtgrNo}}" withString:dispCtgrNo];
//        
//        CPCategoryDetailViewController *viewController = [[CPCategoryDetailViewController alloc] initWithUrl:categoryUrl];
//        [self.navigationController pushViewController:viewController animated:NO];
//        return NO;
//    }
//    else if ([url isMatchedByRegex:@"/MW/Category/displayCategory2Depth.tmall"]) {
//        NSString *listUrl = APP_CATEGORY_LIST_URL;
//        NSString *dispCtgrNo = [Modules extractingParameterWithUrl:url key:@"dispCtgrNo"];
//        listUrl = [listUrl stringByReplacingOccurrencesOfString:@"{{dispCtgrNo}}" withString:dispCtgrNo];
//        
//        CPProductListViewController *viewController = [[CPProductListViewController alloc] initWithUrl:listUrl keyword:nil referrer:webViewUrl];
//        [self.navigationController pushViewController:viewController animated:NO];
//        return NO;
//    }
//    else if ([url isMatchedByRegex:@"/MW/Category/displayCategory3Depth.tmall"]) {
//        NSString *listUrl = APP_CATEGORY_LIST_URL;
//        NSString *dispCtgrNo = [Modules extractingParameterWithUrl:url key:@"dispCtgrNo"];
//        listUrl = [listUrl stringByReplacingOccurrencesOfString:@"{{dispCtgrNo}}" withString:dispCtgrNo];
//        
//        CPProductListViewController *viewController = [[CPProductListViewController alloc] initWithUrl:listUrl keyword:nil referrer:webViewUrl];
//        [self.navigationController pushViewController:viewController animated:NO];
//        return NO;
//    }
//    else if ([url isMatchedByRegex:@"/MW/Search/searchProduct.tmall"]) {
//        NSString *searchUrl = APP_SEARCH_NATIVE_URL;
//
//        NSString *keyword = [Modules extractingParameterWithUrl:url key:@"searchKeyword"];
//        
//        searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:keyword];
//        
//        if (keyword) {
//            keyword = [keyword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            keyword = [keyword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//        
//        CPProductListViewController *viewController = [[CPProductListViewController alloc] initWithUrl:searchUrl keyword:keyword referrer:webViewUrl];
//        [self.navigationController pushViewController:viewController animated:NO];
//        return NO;
//    }
//    else if ([url isMatchedByRegex:@"/MW/Product/productBasicInfo.tmall"] && !isIgnore) {
//        //상품상세 native에서 들어왔을 경우 웹뷰내에 상품상세url이 호출되면 navigation pop (ex. 주문에서 history back)
//
//        NSString *productNum = @"";
//        if (self.navigationController.viewControllers.count >= 2) {
//            UIViewController *controller = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
//            
//            if ([controller isKindOfClass:[CPProductViewController class]]) {
//                productNum = [(CPProductViewController *)controller productNumber];
//            }
//        }
//        
//        //현재 뷰컨트롤러 이전 뷰컨트롤러가 상품상세일 경우 이동하려는 상품과 같은지 확인 후 같을 경우 navigation Pop을 한다.
//        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
//        if ([productNum isEqualToString:prdNo]) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else {
//            //현재 페이지가 빈 페이지인지 확인한다.
//            NSString *documentStr = [webView.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].innerHTML"];
//            documentStr = [documentStr stringByReplacingOccurrencesOfString:@"<head></head><body></body>" withString:@""];
//            BOOL isEmpty = (documentStr == nil || [documentStr length] == 0);
//            if (!isEmpty) isEmpty = ([documentStr length] <= 20 ? YES : NO);
//            
//            //상품정보
//            NSString *mallType = [Modules extractingParameterWithUrl:url key:@"mallType"];
//            NSString *ctlgStockNo = [Modules extractingParameterWithUrl:url key:@"ctlgStockNo"];
//            
//            NSDictionary *parameters = @{@"mallType" : mallType, @"ctlgStockNo" : ctlgStockNo};
//            
//            //Unbalanced calls to begin/end appearance transitions for <UIViewController> 에러 적용
//            double delayInSeconds = 0.5f;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [self openProductViewController:prdNo isPop:isEmpty parameters:parameters];
//            });
//        }
//        
//        return NO;
//    }
    
    //BOOL isHidden = [CPCommonInfo isHomeMenuUrl:url];
    BOOL isHidden = false;
    
    //각 상황별 히든처리를 하면 안되는 경우가 있어서 조정한다.
    if (!self.webView) {
        //메인탭의 웹뷰일 경우 툴바 안보이도록 고정
        [webView setHiddenToolBarView:YES];
    }
    //서브웹뷰일 경우
    else {
        //a.st / app.st 는 단순 로그생성을 위한 URL이다. 따라서 로그를 찍을 때는 웹페이지 설정을 변경하지않는다.
//        if (![url isMatchedByRegex:@"/a.st?"] && ![url isMatchedByRegex:@"/app.st?"]) {
//            [webView destoryProductOption];
////            if (webView.toggleButtonHiddenStatus == YES) {
////                [webView setHiddenToolBarView:isHidden];
////            }
//        }
    }
    
    NSLog(@"WebView url:%@, hidden:%@, tag:%li", url, isHidden?@"Y":@"N", (long)webView.tag);
    
    //메인탭에서 서브웹뷰를 오픈할 경우에는 shouldStartLoad를 NO로 리턴
    if (!isHidden && !self.webView) {
        [webView stop];
        
        //request가 있으면 request를 다시 만들지 않고 loadRequest를 한다.
        [self openWebView:url request:request];
        
        return NO;
    }
    
    //Exception URL은 풀스크린으로 보여줌
//    BOOL isException = [CPCommonInfo isExceptionalUrl:url];
//    [self setExceptionFrame:isException];
//    
//    // 검색결과페이지에서 검색창 터치시 검색어 자동완성 노출
//    NSString *searchUrl = [[CPCommonInfo sharedInfo] urlInfo][@"search"];
//    NSArray *searchUrls = [searchUrl componentsSeparatedByString:@"?"];
//    NSString *searchPrefixUrl = searchUrls[0];
    
//    if ([url hasPrefix:searchPrefixUrl]) {
//        isSearchText = YES;
//    }
//    else {
//        isSearchText = NO;
//    }
    
    //외부 URL 체크
//    [self isExternalUrl:url];
    
    return YES;
}

- (void)setExceptionFrame:(BOOL)isException
{
    CGRect subWebViewFrame;
    
    if (isException) {
        [self.navigationController setNavigationBarHidden:YES];
        
        if ([SYSTEM_VERSION intValue] > 6) {
            subWebViewFrame = CGRectMake(0, STATUSBAR_HEIGHT, kScreenBoundsWidth, kScreenBoundsHeight-STATUSBAR_HEIGHT);
        }
        else {
            subWebViewFrame = CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-STATUSBAR_HEIGHT);
        }
    }
    else {
        [self.navigationController setNavigationBarHidden:NO];
        subWebViewFrame = CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight-64);
    }
    
    if (self.webView) {
        [self.webView setFrame:subWebViewFrame];
        [self.webView updateFrame];
        [self.webView setHiddenToolBarView:NO];
    }
    
//    if (isException) fullScreenMode = CPWebviewControllerFullScreenModeOn;
//    else             fullScreenMode = CPWebviewControllerFullScreenModeOff;
}

- (BOOL)webView:(WebView *)webView openUrlScheme:(NSString *)urlScheme
{
//    return [[CPSchemeManager sharedManager] openUrlScheme:urlScheme sender:nil changeAnimated:YES];
    return false;
}

#pragma mark - WebViewDelegate - Navigation Bar

- (void)initNavigation:(NSInteger)navigationType
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[NavigationBarView class]]) {
            [subView removeFromSuperview];
//            NSLog(@"CPNavigationBarView removeFromSuperview");
        }
    }
    
    switch (navigationType) {
        case 2:
            [self.navigationController.navigationBar addSubview:[self navigationBarView:2]];
            [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
            break;
        case 1:
        default:
            [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
            [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
            break;
    }
    
}


#pragma mark - WebViewDelegate - Button

- (void)didTouchZoomViewerButton
{
//    if (!zoomViewerScheme || [@"" isEqualToString:[zoomViewerScheme trim]]) {
//        return;
//    }
//    
//    [[CPSchemeManager sharedManager] openUrlScheme:[NSString stringWithFormat:@"app://popupBrowser/%@", zoomViewerScheme] sender:nil changeAnimated:NO];
}

#pragma mark - WebViewDelegate - Toolbar

- (void)webViewGoBack
{
    [self.navigationController setNavigationBarHidden:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didTouchToolBarButton:(UIButton *)button;
{
//    NSLog(@"currentWebView.tag:%li, currentNaviType:%li", (long)currentHomeTab, (long)[[CPCommonInfo sharedInfo] currentNavigationType]);
    //홈이거나 백버튼(히스토리없을 경우)
    if (button.tag == 5) {
        [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popToRootViewControllerAnimated:NO];
//        [self reloadHomeTab];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeNotification object:self];
    }
    else if (button.tag == 1) {
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (button.tag == 2) {
//        [self.navigationController pushViewController:[[CPCommonInfo sharedInfo] lastViewController] animated:YES];
//        [self.navigationController.navigationBar addSubview:[self navigationBarView:[Modules isMatchedGNBUrl:[self.webView url]]]];
    }
}

- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
//    switch (button.tag) {
//        case CPSnapshotPopOverMenuTypeHome:
//        {
//            CPSnapshotViewController *viewController = [[CPSnapshotViewController alloc] init];
//            
//            NSString *title = [self.webView execute:@"document.title"];
//            
//            [viewController setCaptureTargetView:self.view];
//            [viewController setBrowserTitle:title];
//            [viewController setBrowserUrl:[self.webView url]];
//            
//            [self.navigationController pushViewController:viewController animated:YES];
//            break;
//        }
//        case CPSnapshotPopOverMenuTypeList:
//        {
//            CPSnapshotListViewController *viewController = [[CPSnapshotListViewController alloc] init];
//            [self.navigationController pushViewController:viewController animated:YES];
//            break;
//        }
//        default:
//            break;
//    }
}

- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
//    switch (button.tag) {
//        case CPPopOverMenuTypeRecent:
//        {
//            NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"todayProduct"];
//            [self openWebView:url request:nil];
//            break;
//        }
//        case CPPopOverMenuTypeFavorite:
//        {
//            NSString *url = [[CPCommonInfo sharedInfo] urlInfo][@"interest"];
//            [self openWebView:url request:nil];
//            break;
//        }
//        case CPPopOverMenuTypeShare:
//        {
//            CPShareViewController *viewController = [[CPShareViewController alloc] init];
//            NSString *shareTitle = self.navigationItem.title;
//            
//            if (!shareTitle || [[shareTitle trim] isEqualToString:@""]) {
//                shareTitle = [self.webView execute:@"document.title"];
//            }
//            
//            [viewController setShareTitle:shareTitle];
//            [viewController setShareUrl:[self.webView url]];
//            
//            [self.navigationController pushViewController:viewController animated:YES];
//            break;
//        }
//        case CPPopOverMenuTypeSetting:
//        {
//            [self openSettingViewController];
//            break;
//        }
//        case CPPopOverMenuTypeBrowser:
//        {
//            NSString *requestUrl = [self removeQueryStringWithUrl:[self.webView url]];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestUrl]];
//            break;
//        }
//        default:
//            break;
//    }
}

#pragma mark - CPMartSearchViewControllerDelegate

- (void)martSearchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
//    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
//    
//    if (keyword) {
//        NSString *searchUrl = [[CPCommonInfo sharedInfo] urlInfo][@"martSearch"];
//        searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:keyword];
//        
//        [self openWebView:searchUrl request:nil];
//    }
    
//    isCloseSearch = YES;
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
//    if (keyword) {
//        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:webViewUrl];
//        [self.navigationController pushViewController:viewConroller animated:YES];
//        
//    }
}

- (void)reloadWebViewData
{
    [self.webView reload];
}

- (void)searchWithAdvertisement:(NSString *)url
{
    [self.webView open:url];
}

#pragma mark - CPPopupViewControllerDelegate

- (void)popupViewControllerCloseAndMoveUrl:(NSString *)url
{
    [self openWebView:url request:nil];
}

- (void)popupviewControllerOpenOtpController:(NSString *)option
{
//    [self otp:option];
}

- (void)popupviewControllerMoveHome:(NSString *)option
{
//    [self moveToHome:option];
}

- (void)popupviewControllerOpenBrowser:(NSString *)option
{
//    [self openBrowser:option];
}

#pragma mark - CPContactViewControllerDelegate

- (void)didTouchContactConfirmButton:(NSString *)jsonData;
{
    NSString *javascript = [NSString stringWithFormat:@"contactList('{\"contactList\":%@}')", jsonData];
    [self.webView execute:javascript];
    
//    isCloseContact = YES;
}

#pragma mark - CPPopupBrowserViewDelegate

- (void)popupBrowserViewOpenUrlScheme:(NSString *)urlScheme
{
    //[[CPSchemeManager sharedManager] openUrlScheme:urlScheme sender:nil changeAnimated:YES];
}

#pragma mark - CPVideoPopupViewDelegate

- (void)didTouchProductButton:(NSString *)productUrl
{
//    if (popUpBrowserView) {
//        [popUpBrowserView removePopupBrowserView];
//    }
//    
//    [self openWebView:productUrl request:nil];
}

//- (void)didTouchFullScreenButton:(CPMoviePlayerViewController *)player
//{
//    //[self presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player];
//}


#pragma mark - SetupControllerDelegate

//- (void)setupController:(SetupController *)controller gotoWebPageWithUrlString:(NSString *)urlString
//{
//    [self.webView open:urlString];
//}

#pragma mark - CPSchemeManagerDelegate

//ads
- (void)setSearchTextField:(NSString *)keyword
{   
    [navigationBarView setSearchTextField:keyword];
}

//- (void)openPopupViewController:(NSString *)linkUrl
//{
//    CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
//    [popViewController setTitle:@""];
//    [popViewController setIsLoginType:NO];
//    [popViewController setRequestUrl:linkUrl];
//    [popViewController setDelegate:self];
//    [popViewController initLayout];
//
//    [self presentViewController:popViewController animated:YES completion:nil];
//}
//
////photoReview
//- (void)openPhotoReviewController:(NSDictionary *)reviewInfo
//{
//    PhotoReviewController *viewController = [[PhotoReviewController alloc] init];
//    [viewController setProperties:reviewInfo];
//    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [viewController setWantsFullScreenLayout:YES];
//    }
//    
//    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
//    [self presentViewController:naviController animated:YES completion:nil];
//}
//
////contact
//- (void)openContactViewController:(NSDictionary *)contactInfo
//{
//    CPContactViewController *viewController = [[CPContactViewController alloc] initWithContact:contactInfo];
//    [viewController setDelegate:self];
//    
//    [self presentViewController:viewController animated:YES completion:nil];
//}
//
//- (void)closeContactViewController
//{
//    UIViewController *viewController = [self presentedViewController];
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//}
//
////popupBrowser
//- (void)openPopupBrowserView:(NSDictionary *)popupInfo
//{
//    //구매옵션이 열려있으면 닫아준다.
//    if (self.webView) {
//        [self.webView closeProductOption];
//    }
//
//    CGFloat statusBarY = [SYSTEM_VERSION intValue] >= 7 ? 20.f : 0.f;
//    CGFloat statusBarHeight = 20.f;
//    
//    popUpBrowserView = [[CPPopupBrowserView alloc] initWithFrame:CGRectMake(0,
//                                                                            kScreenBoundsHeight,
//                                                                            kScreenBoundsWidth,
//                                                                            kScreenBoundsHeight-statusBarHeight)
//                                                       popupInfo:popupInfo
//                                                  executeWebView:self.webView];
//    
//    [popUpBrowserView setDelegate:self];
//    [self.navigationController.view addSubview:popUpBrowserView];
//    
//    popUpBrowserView.backgroundColor = [UIColor clearColor];
//    
//    CGRect frame = popUpBrowserView.frame;
//    frame.origin.y -= (kScreenBoundsHeight-statusBarY);
//    
//    [UIView animateWithDuration:0.3f animations:^{
//        [popUpBrowserView setFrame:frame];
//    }];
//}
//
//- (void)closePopupBrowserView:(NSDictionary *)popupInfo
//{
//    if (popUpBrowserView) {
//        [popUpBrowserView removePopupBrowserView];
//        
//        NSString *type = [popupInfo objectForKey:@"pType"];
//        NSString *action = [popupInfo objectForKey:@"pAction"];
//        
//        if ([@"script" isEqualToString:type]) {
//            if (action) {
//                [self.webView execute:action];
//            }
//        }
//        
//        if ([@"url" isEqualToString:type]) {
//            if (action) {
//                [self openWebView:action request:nil];
//            }
//        }
//    }
//}

//zoomViewer
- (void)setZoomViewer:(NSArray *)options
{
    zoomViewerScheme = [@"open/" stringByAppendingString:options[1]];
    
    if ([[options objectAtIndex:0] isEqualToString:@"show"]) {
        [self.webView.zoomViewerButton setHidden:NO];
    }
    
    if ([[options objectAtIndex:0] isEqualToString:@"hide"]) {
        [self.webView.zoomViewerButton setHidden:YES];
    }
}

//canOpenApp
//- (void)executeCanOpenApplication:(NSString *)option
//{
//    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URLDecode(option)]];
//    
//    [self.webView execute:[NSString stringWithFormat:@"canOpenApplication('%d', '%@')", canOpen, URLDecode(option)]];
//}

- (void)openWebView:(NSString *)url
{
    [self.webView open:url];
}

//toolbar action
- (void)webViewToolbarAction:(NSString *)option
{
    if ([option isEqualToString:@"top"]) {
        [self.webView actionTop];
    }
    else if ([option isEqualToString:@"back"]) {
        [self.webView actionBackWord];
    }
    else if ([option isEqualToString:@"forward"]) {
        [self.webView actionForward];
    }
    else if ([option isEqualToString:@"reload"] || [option isEqualToString:@"refresh"]) {
        [self.webView actionReload];
    }
    else if ([option isEqualToString:@"close"]) {
        [self.navigationController popViewControllerAnimated:NO];
//        [self removeSubWebView];
    }
    else if ([option hasPrefix:@"external"]) {
        NSString *requestUrl = [self removeQueryStringWithUrl:[self.webView url]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestUrl]];
    }
}

//movie popup
//- (void)openVideoPopupView:(NSDictionary *)productInfo
//{
//    NSDictionary *urlInfo = [[CPCommonInfo sharedInfo] urlInfo];
//    CPVideoInfo *videoInfo = [CPVideoInfo initWithMovieInfo:productInfo[@"movie"]];
//    
//    CPVideoPopupView *videoPopupView = [[CPVideoPopupView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)
//                                                                   productInfo:productInfo
//                                                                       urlInfo:urlInfo
//                                                                     videoInfo:videoInfo];
//    [videoPopupView setDelegate:self];
//    [videoPopupView setUserInteractionEnabled:YES];
//    [videoPopupView setMovieWithVideoInfo:videoInfo];
//    [videoPopupView playWithVideoInfo:videoInfo];
//    
//    [self.navigationController.view addSubview:videoPopupView];
//}

//imageView
//- (void)openImageView:(NSDictionary *)imageInfo
//{
//    CGRect mainFrame = [UIScreen mainScreen].bounds;
//    ImageViewer *viewer = [[ImageViewer alloc] initWithFrame:CGRectMake(0, -mainFrame.size.height, mainFrame.size.width, mainFrame.size.height)];
//    
//    [viewer setTitle:[imageInfo objectForKey:@"title"]];
//    [viewer setImages:[imageInfo objectForKey:@"list"]];
//    [viewer open];
//}

//pasteBoard
- (void)pasteClipBoard:(NSArray *)options
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    if ([[options objectAtIndex:0] isEqualToString:@"copy"]) {
        if ([[options objectAtIndex:1] isEqualToString:@"url"]) {
            [pasteBoard setURL:[NSURL URLWithString:self.webView.url]];
        }
    }
}

//executeJavascript
- (void)executeJavascript:(NSString *)command
{
    [self execute:command properties:nil sender:nil];
}

//product
- (void)setProductOption:(BOOL)isEnable
{
    //웹뷰에 붙어있는 서랍옵션은 제거
//    //상품 상세 URL이 아니면 서랍옵션 비노출
//    if (!isEnable || ![Modules isMatchedProductUrl:[self.webView url]]) {
//        //서랍제거
//        [self.webView destoryProductOption];
//        return;
//    }
//    
//    // 서랍활성화
//    [self.webView makeProductOption];
}

//setting
- (void)setSettingViewController:(NSString *)option animated:(BOOL)animated
{
//    if ([option isEqualToString:@"setup"] || [option isEqualToString:@"preference"]) {
//        [self openSettingViewController];
//    }
//    else if ([option isEqualToString:@"notification"]) {
//        SetupNotifyController *viewController = [[SetupNotifyController alloc] init];
//        [self presentViewController:viewController animated:animated completion:nil];
//    }
//    else if ([option hasPrefix:@"appLogin"]) {
//        /*
//         NSString *loginUrl = [option stringByMatching:@"([^/]+)/(.*)" capture:2];
//         
//         SetupLoginController *viewController = [[SetupLoginController alloc] init];
//         
//         if ([SYSTEM_VERSION intValue] < 7) {
//         [viewController setWantsFullScreenLayout:YES];
//         }
//         
//         [self presentViewController:viewController animated:animated completion:nil];
//         
//         [viewController setTitle:NSLocalizedString(@"SetupLoginController", nil)];
//         [viewController openUrl:[Modules urlWithQueryString:loginUrl]];
//         [viewController setDelegate:sender];
//         */
//    }
}

//otp
- (void)setOtp:(NSString *)otpStr
{
    //등록된 OTP 단말인지 확인
//    NSString *otpID = [[NSUserDefaults standardUserDefaults] stringForKey:@"otpRegisterID"];
//    
//    if (!otpID || [otpID length] == 0) {
//        return [Modules alert:NSLocalizedString(@"AlertTitle", nil) message:NSLocalizedString(@"SetupOtpNoRegisterID", nil)];
//    }
//    
//    SetupOtpController *otpController = [[SetupOtpController alloc] init];
//    
//    SBJSON *json = [[SBJSON alloc] init];
//    NSDictionary *otpDic = nil;
//    
//    otpStr = [otpStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    otpDic = [json objectWithString:otpStr];
//    
//    //외부 스킴으로 호출시 인코딩이 한번 더 되기때문에(UTF-8 이중 인코딩) 두번 풀어야한다.
//    if (!otpDic) {
//        otpStr = [otpStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        otpDic = [json objectWithString:otpStr];
//    }
//    
//    if (!otpDic || !otpDic[@"url"]) {
//        return [Modules alert:NSLocalizedString(@"AlertTitle", nil) message:NSLocalizedString(@"OtpGeneratorOpenFailed", nil)];
//    }
//    
//    [otpController setPopupMode:YES];
//    [otpController setActivationCodeInput:NO];
//    [otpController setUserID:otpID];
//    [otpController setOtpLayoutUrl:otpDic[@"url"]];
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otpController];
//    [self performSelector:@selector(presentOtpGeneratorController:) withObject:navigationController afterDelay:1.0f];
}

- (void)presentOtpGeneratorController:(UIViewController *)otpController
{
    if (self.presentedViewController) {
        UIViewController *controller = (UIViewController *)self.presentedViewController;

        if ([controller respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [controller presentViewController:otpController animated:YES completion:nil];
        }
    }
    else {
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self presentViewController:otpController animated:YES completion:nil];
        }
    }
}

//shakemotion
- (void)shakemotion:(NSString *)option
{
    if ([option hasPrefix:@"start"]) {
        [self startAccelerometerForDelay];
    }
    else {
        [self stopAccelerometer];
    }
}

//eventAlarm
- (void)eventAlarmAddAction:(NSDictionary *)jsonData
{
//    NSString *eventId	= [jsonData objectForKey:@"eventid"];
//    NSString *message	= [jsonData objectForKey:@"message"];
//    NSString *dateStr	= [jsonData objectForKey:@"date"];
//    NSString *eventUrl	= [jsonData objectForKey:@"eventurl"];
//    
//    if ([[eventId trim] length] > 0 && [[message trim] length] > 0 && [[dateStr trim] length] > 0) {
//        BOOL bResult = [LOCAL_ALARM addLocalNotification:eventId
//                                                 message:message
//                                                    date:dateStr
//                                                     url:eventUrl];
//        
//        if (bResult == NO) {
//            //실패 메세지 호출
//            NSString *javascript = @"javascript:failedAddLocalAlarm()";
//            [self.webView execute:javascript];
//        } else {
//            //성공 메세지 호출
//            NSString *javascript = @"javascript:finishedAddLocalAlarm()";
//            [self.webView execute:javascript];
//            
//            [LOCAL_ALARM addInsertEventAlarmLogWithEventId:eventId];
//        }
//    }
}

- (void)eventAlarmRemoveAction:(NSDictionary *)jsonData
{
//    NSString *eventId = [jsonData objectForKey:@"eventid"];
//    
//    if ([[eventId trim] length] > 0) {
//        BOOL bResult = [LOCAL_ALARM removeLocalNotification:eventId];
//        
//        if (bResult == NO) {
//            //실패 메세지 호출
//            NSString *javascript = @"javascript:failedRemoveLocalAlarm()";
//            [self.webView execute:javascript];
//        } else {
//            //성공 메세지 호출
//            NSString *javascript = @"javascript:finishedRemoveLocalAlarm()";
//            [self.webView execute:javascript];
//        }
//    }
}

//moveToHome
- (void)moveToHomeAction:(NSString *)option
{
    if ([option isEqualToString:@"home"]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:WebViewControllerNotification object:self];
//        
//        [self.subWebView removeFromSuperview];
//        
//        [self reloadHomeTab];
    }
}

#pragma mark - Javascript 호출

- (void)execute:(NSString *)command properties:(id)properties sender:(id)sender
{
//    if (!command || [[command trim] isEqualToString:@""]) {
//        return;
//    }
//    
//    if ([command isMatchedByRegex:URL_PATTERN]) {
//        [[CPSchemeManager sharedManager] openUrlScheme:command sender:sender changeAnimated:YES];
//    }
//    else {
//        SBJSON *json = [[SBJSON alloc] init];
//        NSString *javaScript = [command stringByMatching:@"javascript:(.+)" capture:1], *fullScript;
//        
//        if (javaScript) {
//            if (properties) {
//                if ([properties isKindOfClass:[NSDictionary class]]) {
//                    fullScript = [NSString stringWithFormat:@"%@(%@);", javaScript, [json stringWithObject:properties]];
//                }
//                else if ([json objectWithString:URLDecode(properties)]) {
//                    fullScript = [NSString stringWithFormat:@"%@(%@);", javaScript, URLDecode(properties)];
//                }
//                else {
//                    fullScript = [NSString stringWithFormat:@"%@(\"%@\");", javaScript, properties];
//                }
//            }
//            else {
//                if ([javaScript hasSuffix:@";"] || [javaScript hasSuffix:@")"]) {
//                    fullScript = javaScript;
//                }
//                else {
//                    fullScript = [NSString stringWithFormat:@"%@()", javaScript];
//                }
//            }
//            
//            [self.webView execute:fullScript];
//        }
//        else {
//            [self.webView open:command];
//        }
//    }
}

#pragma mark - ShakeModuleDelegate

- (void)startAccelerometerForDelay
{
//    if (shakeModule) {
//        [self stopAccelerometer];
//    }
//    
//    shakeModule = [[ShakeModule alloc] init];
//    [shakeModule setDelegate:self];
//    [shakeModule startAccelerometerUpdate];
}

- (void)stopAccelerometer
{
//    if (shakeModule) {
//        [shakeModule setDelegate:nil];
//        [shakeModule stopAccelerometerUpdate];
//        shakeModule = nil;
//    }
}

- (void)shakeModuleSuccCount
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStart()";
    [self.webView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
}

- (void)shakeModuleCancel
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStop()";
    [self.webView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
    
    [self stopAccelerometer];
}

- (void)shakeModuleError
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStop()";
    [self.webView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
    
    [self stopAccelerometer];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ShockingDealTitle", nil)
                                                    message:@"지원하지않는 장비입니다."
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"확인", nil)
                                          otherButtonTitles:nil, nil];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

@end
