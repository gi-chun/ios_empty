//
//  CPHomeViewController.m
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPHomeViewController.h"
#import "UIAlertView+Blocks.h"
#import "CPShareViewController.h"
#import "CPSnapshotPopOverView.h"
#import "CPPopupViewController.h"
#import "CPSearchViewController.h"
#import "CPContactViewController.h"
#import "CPMartSearchViewController.h"
#import "CPWebViewController.h"
#import "CPSnapshotViewController.h"
#import "CPSnapshotListViewController.h"
#import "CPProductListViewController.h"
#import "CPPriceDetailViewController.h"
#import "CPMenuViewController.h"
#import "CPProductViewController.h"

#import "CPBarButtonItem.h"
#import "CPWebView.h"
#import "CPTabMenuView.h"
#import "CPPopOverView.h"
#import "CPPopupBrowserView.h"
#import "CPPayment.h"
#import "CPCommonInfo.h"
#import "CPDeveloperInfo.h"
#import "CPVideoPopupView.h"
#import "CPNavigationBarView.h"
#import "CPSchemeManager.h"

#import "CPHomeView.h"
#import "CPMartView.h"
#import "CPBrandView.h"
#import "CPBestView.h"
#import "CPShockingDealView.h"
#import "CPTalkView.h"
#import "CPTrendView.h"
#import "CPCurationView.h"
#import "CPEventView.h"
#import "CPHiddenView.h"
#import "CPTouchActionView.h"

#import "SetupController.h"
#import "SetupNotifyController.h"
#import "SetupOtpController.h"
#import "PhotoReviewController.h"
#import "InAppMessageView.h"
#import "ShakeModule.h"
#import "ImageViewer.h"
#import "ActionSheet.h"
#import "RegexKitLite.h"
#import "Reachability.h"
#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "HttpRequest.h"
#import "AccessLog.h"
#import "LocalNotification.h"
#import "CPRESTClient.h"

#import "Reachability.h"
#import "iCarousel.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface CPHomeViewController () <CPBarButtonItemDelegate,
                                    CPWebViewDelegate,
                                    CPBestViewDelegate,
                                    CPShockingDealDelegate,
                                    CPTabMenuViewDelegate,
                                    CPPopOverViewViewDelegate,
                                    CPSnapshotPopOverViewDelegate,
                                    CPPopupBrowserViewDelegate,
									CPHomeViewDelegate,
									CPHiddenViewDelegate,
									CPMartViewDelegate,
                                    CPBrandViewDelegate,
									CPTalkViewDelegate,
									CPTrendViewDelegate,
									CPCurationViewDelegate,
									CPEventViewDelegate,
                                    CPPaymentDelegate,
                                    CPSearchViewControllerDelegate,
                                    CPMartSearchViewControllerDelegate,
                                    CPVideoPopupViewDelegate,
                                    CPPopupViewControllerDelegate,
                                    CPContactViewControllerDelegate,
                                    SetupControllerDelegate,
                                    ShakeModuleDelegate,
                                    iCarouselDataSource,
                                    iCarouselDelegate,
                                    UITextFieldDelegate,
                                    UIScrollViewDelegate,
                                    UIGestureRecognizerDelegate,
                                    HttpRequestDelegate,
                                    CPNavigationBarViewDelegate,
                                    CPSchemeManagerDelegate>
{
    NSDictionary *menuInfo;
    
    iCarousel *contentsView;
    
    NSArray *menuTitles;
    NSMutableArray *menuContents;
    CPTabMenuView *tabMenuView;
    NSMutableArray *tabWebViewArray;

    NSString *subWebViewUrl;
    
    CPWebView *hiddenWebView;
    
    CPPopupBrowserView *popUpBrowserView;
    
    UITextField *searchTextField;
    NSMutableDictionary *searchKeyWordInfo;
    NSString *currentAdKeyword;
    
    NSInteger currentHomeTab;
    NSInteger currentSubWebViewIndex;
    
    ShakeModule *_shakeModule;
    
    NSString *zoomViewerScheme;
    
    BOOL isEnalbeLogoButton;
    NSInteger tabWebViewLoadCount;
    
    BOOL isSearchText;
    
    UIView *tutorialView;
    UIScrollView *tutorialScrollView;
    
    BOOL isCloseContact;
    BOOL isCloseSearch;
    
    NSInteger productWebViewCount;
    
    CPNavigationBarView *navigationBarView;
	
	UIView *_freeView;
    
    BOOL _disableSearchKeyword;
}

@end

@implementation CPHomeViewController

- (id)init
{
    if (self = [super init]) {
        
        tabWebViewArray = [NSMutableArray array];
		
		self.trendImageHeightArray = [NSMutableArray array];
        
        //탭 배열 설정
        [self initTabArray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    //네비게이션 Enable back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];
    
    NSLog(@"home controller viewDidLoad");
    [self loadContentsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHomeTab)
                                                 name:ReloadHomeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // CPSchemeManager delegate
    [[CPSchemeManager sharedManager] setDelegate:self];
	
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.isFinishedHomeLoad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLoginStatus" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startHomeTabTimer" object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
    //상품상세의 구매버튼이 네비게이션뷰에 붙어있는 경우가 있어서 제거한다.
    for (UIView *subview in self.navigationController.view.subviews) {
        if (subview.tag == 1999998 || subview.tag == 1999997) {
            [subview removeFromSuperview];
        }
    }

    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];

    //네비게이션바가 없어진 상태라면 복구시킨다.
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
	//로그인 페이지에서 -> 설정 -> 로그인완료 -> 백버튼 과 같은 경로 이동시 오류를 방지하기위해 새로고침 해준다.
    //연락처 연동할때는 예외
    //상품상세URL도 예외
	if (self.subWebView.hidden == NO && !isCloseContact && !isCloseSearch) {
        
        if ([Modules isMatchedProductUrl:[self.subWebView url]]) {
            return;
        }
        
		[self.subWebView reload];
	}

    //홈탭이 로드되었다고 AppDelegate에 알려준다. 그 후 deeplink를 실행하기 때문에 매우 중요.
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app && [app respondsToSelector:@selector(finishedLoadHomeView)]) {
        [app finishedLoadHomeView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stopHomeTabTimer" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-  (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReloadHomeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - foreground / background notification

- (void)didEnterBackgroundNotification
{
    NSLog(@"didEnterBackgroundNotification");
    
    //백그라운드에 진입하는 시간을 기록한다.
    [[CPCommonInfo sharedInfo] setInBackgroundTime:[NSDate date]];
}

- (void)willEnterForegroundNotification
{
    NSLog(@"willEnterForegroundNotification");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!app.isFinishedHomeLoad) return;
    
    //홈뷰컨트롤러가 첫페이지가 아니라면 리턴
    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[CPHomeViewController class]]) return;
    
    //백그라운드에 진입한 내용이 없다면 리턴 (앱 최초실행시)
    NSDate *inBackGroundTime = [[CPCommonInfo sharedInfo] inBackgroundTime];
    if (!inBackGroundTime) return;
    
    //현재 시간을 가져온다.
    NSDate *currentTime = [NSDate date];
    NSInteger distanceSec = [Modules getDistanceDateWithStartDate:inBackGroundTime EndDate:currentTime];
    
    NSInteger distanceStandard = (NSInteger)(60 * 5);
    
#if DEBUG
    //개발일 경우 5초 리프레쉬 시켜준다.
    distanceStandard = 5;
#endif
    
    if (distanceSec >= distanceStandard) {
        //데이터 리플래쉬!!
        if (!contentsView || contentsView.numberOfItems == 0)   return;
        
        NSInteger itemCount = contentsView.numberOfItems;

        for (NSInteger i=0; i<itemCount; i++) {
            UIView *view = [contentsView itemViewAtIndex:i];
            
            //gclee
            for (UIView *carouselSubview in view.subviews) {
                if ([carouselSubview isKindOfClass:[CPHomeView class]]
                    || [carouselSubview isKindOfClass:[CPBestView class]]
                    || [carouselSubview isKindOfClass:[CPShockingDealView class]]
                    || [carouselSubview isKindOfClass:[CPMartView class]]
                    || [carouselSubview isKindOfClass:[CPMartView class]]
                    || [carouselSubview isKindOfClass:[CPBrandView class]]
                    || [carouselSubview isKindOfClass:[CPBrandView class]]
                    || [carouselSubview isKindOfClass:[CPTalkView class]]
                    || [carouselSubview isKindOfClass:[CPTrendView class]]
                    || [carouselSubview isKindOfClass:[CPCurationView class]]
                    || [carouselSubview isKindOfClass:[CPEventView class]]
                    || [carouselSubview isKindOfClass:[CPHiddenView class]]) {
                    
                    if ([carouselSubview respondsToSelector:@selector(reloadDataWithIgnoreCache:)]) {
                        
                        NSInteger distance = [self getDistanceCurrentIndex:contentsView.currentItemIndex
                                                                 pageIndex:i
                                                                  maxCount:itemCount];
                        
                        CGFloat delay = distance * 0.5f;
                        [carouselSubview performSelector:@selector(reloadDataWithIgnoreCache:) withObject:[NSNumber numberWithFloat:delay]];
                    }
                    break;
                }
            }
        }
    }
}

//현재 화면을 기준으로 각 페이지들의 거리를 구한다.
- (NSInteger)getDistanceCurrentIndex:(NSInteger)currentIndex pageIndex:(NSInteger)pageIndex maxCount:(NSInteger)maxCount
{
    if (currentIndex == pageIndex) return 0;
    
    NSInteger hCount = 0;
    NSInteger searchIndex = pageIndex;
    while (1) {
        if (currentIndex == searchIndex)
        {
            break;
        }
        else
        {
            hCount++;
            searchIndex++;
            
            if (searchIndex >= maxCount) searchIndex = 0;
        }
    }

    NSInteger lCount = 0;
    searchIndex = pageIndex;
    while (1) {
        if (currentIndex == searchIndex)
        {
            break;
        }
        else
        {
            lCount++;
            searchIndex--;
            
            if (searchIndex < 0) searchIndex = maxCount-1;
        }
    }
    
    return (hCount > lCount ? lCount : hCount);
}

#pragma mark - Init

- (void)initTabArray
{
    //탭 배열 설정
    NSArray *mainTabs = [[CPCommonInfo sharedInfo] mainTabs];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type != 'hidden' && type != 'hidden_native')"];
    menuTitles= [mainTabs filteredArrayUsingPredicate:predicate];
    
    menuContents = [NSMutableArray array];
    NSMutableArray *homeMenuItems = [NSMutableArray array];
    
    for (NSDictionary *tab in mainTabs) {
        //멀티탭일 경우 자식들에게 부모의 키값을 전달해줌(탭의 하이라이트를 키값으로 매칭하기위해)
        if ([tab[@"type"] isEqualToString:@"multiple"]) {
            for (NSDictionary *child in tab[@"child"]) {
                NSMutableDictionary *newChild = [NSMutableDictionary dictionaryWithDictionary:child];
                [newChild setValue:tab[@"key"] forKey:@"parent"];
                
                [menuContents addObject:newChild];
                
                if (child[@"url"]) {
                    [homeMenuItems addObject:child[@"url"]];
                }
            }
        }
        else {
            [menuContents addObject:tab];
            if (tab[@"url"]) {
                [homeMenuItems addObject:tab[@"url"]];
            }
            
//            //히든탭은 init됐을때 만들어 놓고 계속 사용한다.
//            if ([tab[@"type"] isEqualToString:@"hidden"]) {
//                [self makeHiddenWebView];
//            }
        }
    }
    
    //메인탭에서 리다이렉트를 막자
    [homeMenuItems addObject:[[@"http://" stringByAppendingString:BASE_DOMAIN] stringByAppendingString:@"/MW"]];
    [homeMenuItems addObject:[[@"http://" stringByAppendingString:BASE_DOMAIN] stringByAppendingString:@"/MW/"]];
    [homeMenuItems addObject:[[@"http://" stringByAppendingString:BASE_DOMAIN] stringByAppendingString:@"/MW/index.html"]];
    [homeMenuItems addObject:[[@"http://" stringByAppendingString:BASE_DOMAIN] stringByAppendingString:@"/MW/html/main.html"]];
    [homeMenuItems addObject:[[@"http://" stringByAppendingString:BASE_DOMAIN] stringByAppendingString:@"/MW/Hybrid/app.html"]];
    
    [[CPCommonInfo sharedInfo] setHomeMenuItems:homeMenuItems];
}

- (void)initDeveloperInfo:(UIButton *)buttonItem
{
    if (buttonItem == nil) {
        return;
    }
	
	self.developerInfo = [[CPDeveloperInfo alloc] init];
	[self.developerInfo addLongPressedGestureInButtonItem:buttonItem];
}

- (void)loadContentsView
{
    for (UIView *subView in [self.view subviews]) {
        [subView removeFromSuperview];
    }

    if (self.navigationController.navigationBar.isHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    tabWebViewLoadCount = 0;
    contentsView = nil;
    _subWebView = nil;
    
    // Tab Menu
    tabMenuView = [[CPTabMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kTabMenuHeight) menuTitleItems:menuTitles menuContentsItems:menuContents];
    [tabMenuView setDelegate:self];
    [self.view addSubview:tabMenuView];
    
    // Shadow
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame)+0.1f, kScreenBoundsWidth, 4)];
    [shadowImageView setImage:[UIImage imageNamed:@"gnb_menu_shadow.png"]];
    [self.view addSubview:shadowImageView];
    
    //gclee
    // ContentsView iCarousel
//        NSLog(@"kScreenBoundsWidth: %f, %f", kScreenBoundsHeight, CGRectGetMaxY(tabMenuView.frame));
    contentsView = [[iCarousel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tabMenuView.frame)+0.1f, kScreenBoundsWidth, kScreenBoundsHeight-(64+CGRectGetHeight(tabMenuView.frame)))];
    [contentsView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [contentsView setType:iCarouselTypeLinear];
    [contentsView setDataSource:self];
    [contentsView setDelegate:self];
    [contentsView setDecelerationRate:0.7f];
    [contentsView setScrollSpeed:1.0f];
    [contentsView setBounceDistance:0.5f];
    [contentsView setPagingEnabled:YES];
    [self.view insertSubview:contentsView belowSubview:shadowImageView];
    
    //튜토리얼
    if (NO == [[NSUserDefaults standardUserDefaults] boolForKey:@"tutorial"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self makeTutorialView];
    }
}

- (void)addSubWebViewWithFrame:(CGRect)frame url:(NSString *)url request:(NSURLRequest *)request
{
    [self removeSubWebView];
    
    CPWebView *subWebView = [[CPWebView alloc] initWithFrame:frame isSub:YES];
    [subWebView setDelegate:self];
    
    //request가 있으면 request를 다시 만들지 않고 loadRequest를 한다.
    if (request) {
        [subWebView loadRequest:request];
    }
    else {
        [subWebView open:url];
    }
    
    [self.view addSubview:subWebView];
    
    self.subWebView = subWebView;
}

- (void)removeSubWebView
{
    if (self.subWebView) {
        
        [self.subWebView removeFromSuperview];
        self.subWebView = nil;
    }
}

- (void)forwardSubWebView
{
    if (self.navigationController.navigationBar.isHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [self removeSubWebView];
}

- (void)reloadHomeTab
{
    if (self.subWebView) {
        currentSubWebViewIndex = 0;
        self.subWebView = nil;
    }
    
    [tabMenuView tabMenuCurrentItemIndexDidChange:0];
    [contentsView scrollToItemAtIndex:0 animated:NO];
    
    if ([[CPCommonInfo sharedInfo] searchKeyWordInfo]) {
        NSMutableDictionary *keyWordInfo = [[CPCommonInfo sharedInfo] searchKeyWordInfo];
        [navigationBarView setSearchTextField:keyWordInfo[@"name"]];
    }
}

- (void)showDataFreeView:(NSString *)linkUrl
{
	CGFloat bannerWidth = 352;
	CGFloat bannerHeight = 133;
	
	CGFloat detailBtnWidth = 110;
	CGFloat detailBtnHeight = 30;
	
	
	if (kScreenBoundsWidth == 320) {
		bannerWidth = (NSInteger)(bannerWidth * 0.9);
		bannerHeight = (NSInteger)(bannerHeight * 0.9);
		
		detailBtnWidth = (NSInteger)(detailBtnWidth * 0.9);
		detailBtnHeight = (NSInteger)(detailBtnHeight * 0.9);
	}
	
	_freeView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(bannerWidth/2), 0, bannerWidth, bannerHeight)];
    [_freeView setClipsToBounds:YES];
	[self.view addSubview:_freeView];

	UIImageView *bgView = [[UIImageView alloc] initWithFrame:_freeView.bounds];
	bgView.image = [UIImage imageNamed:@"img_home_banner_skt.png"];
	[_freeView addSubview:bgView];

	UIImageView *detailBtnView = [[UIImageView alloc] initWithFrame:CGRectMake((_freeView.frame.size.width/2)-(detailBtnWidth/2),
																			   (_freeView.frame.size.height * 0.65),
																			   detailBtnWidth, detailBtnHeight)];
	detailBtnView.image = [UIImage imageNamed:@"bt_home_banner_skt_view.png"];
	[_freeView addSubview:detailBtnView];
	
	UIImage *arrowImg = [UIImage imageNamed:@"bt_home_banner_skt_arrow.png"];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = UIColorFromRGB(0xffffff);
	label.font = [UIFont systemFontOfSize:14];
	label.text = @"자세히보기";
	[label sizeToFitWithVersion];
	[detailBtnView addSubview:label];
	
	label.frame = CGRectMake((detailBtnView.frame.size.width/2)-((label.frame.size.width+5+arrowImg.size.width)/2),
							 (detailBtnView.frame.size.height/2)-(label.frame.size.height/2),
							 label.frame.size.width, label.frame.size.height);
	
	
	UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame)+5, label.frame.origin.y+2,
																		   arrowImg.size.width, arrowImg.size.height)];
	arrowView.image = arrowImg;
	[detailBtnView addSubview:arrowView];
	
	if (linkUrl && [linkUrl length] > 0) {
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:detailBtnView.frame];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = linkUrl;
		[_freeView addSubview:actionView];
	}
	
	UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	closeBtn.frame = CGRectMake(_freeView.frame.size.width-35, 5, 30, 30);
	[closeBtn setImage:[UIImage imageNamed:@"bt_home_banner_skt_close.png"] forState:UIControlStateNormal];
	[closeBtn addTarget:self action:@selector(onTouchCloseDataFreeView:) forControlEvents:UIControlEventTouchUpInside];
	[_freeView addSubview:closeBtn];
	
    CGRect afterFrame = _freeView.frame;
    _freeView.frame = CGRectMake((self.view.frame.size.width/2)-(_freeView.frame.size.width/2),
                                 _freeView.frame.origin.y, 0, _freeView.frame.size.height);

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _freeView.frame = afterFrame;
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(hideDataFreeView) withObject:nil afterDelay:3.5f];
                     }];
}

- (void)hideDataFreeView
{
	if (_freeView) {
		_freeView.userInteractionEnabled = NO;
		
        CGRect afterFrame = CGRectMake((self.view.frame.size.width/2)-(_freeView.frame.size.width/2),
                                       _freeView.frame.origin.y, 0, _freeView.frame.size.height);

        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _freeView.frame = afterFrame;
                         } completion:^(BOOL finished) {
                             [_freeView removeFromSuperview];
                             _freeView = nil;
                         }];
	}
}

- (void)onTouchCloseDataFreeView:(id)sender
{
	if (_freeView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideDataFreeView) object:nil];
		[_freeView removeFromSuperview];
		_freeView = nil;
	}
}

#pragma mark - Public Mehtods

- (void)gotoNativeTab:(NSString *)ac
{
    NSInteger moveIndex = 0;
    
    for (NSDictionary *dic in menuContents) {
        if ([[dic objectForKey:@"type"] isEqualToString:@"native"]) {
            //모바일베스트텝으로 이동
            if ([ac isEqualToString:@"AGB0901"] && [[dic objectForKey:@"key"] isEqualToString:@"RANK"]) {
                moveIndex = [menuContents indexOfObject:dic];
                break;
            }
        }
    }
    
    [contentsView scrollToItemAtIndex:moveIndex animated:NO];
}

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    if ([url isMatchedByRegex:@"/MW/Product/productBasicInfo.tmall"]) {
        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
        
        NSString *mallType = [Modules extractingParameterWithUrl:url key:@"mallType"];
        NSString *ctlgStockNo = [Modules extractingParameterWithUrl:url key:@"ctlgStockNo"];
        
        NSDictionary *parameters = @{@"mallType" : mallType, @"ctlgStockNo" : ctlgStockNo};
        
        CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo
                                                                                                   isPop:NO
                                                                                              parameters:parameters];
        [self.navigationController pushViewController:viewController animated:animated];
    }
    else {
        if ([[CPCommonInfo sharedInfo] currentWebViewController]) {
            [[[CPCommonInfo sharedInfo] currentWebViewController].webView open:url];
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
}

- (void)openWebViewControllerWithRequest:(NSURLRequest *)request
{
    if ([request.URL.absoluteString isMatchedByRegex:@"/MW/Product/productBasicInfo.tmall"]) {
        NSString *url = request.URL.absoluteString;
        
        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
        
        NSString *mallType = [Modules extractingParameterWithUrl:url key:@"mallType"];
        NSString *ctlgStockNo = [Modules extractingParameterWithUrl:url key:@"ctlgStockNo"];
        
        NSDictionary *parameters = @{@"mallType" : mallType, @"ctlgStockNo" : ctlgStockNo};
        
        CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo
                                                                                                   isPop:NO
                                                                                              parameters:parameters];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        if ([[CPCommonInfo sharedInfo] currentWebViewController]) {
            [[[CPCommonInfo sharedInfo] currentWebViewController].webView loadRequest:request];
        }
        else {
            CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithRequest:request];
            [self.navigationController pushViewController:viewControlelr animated:YES];
        }
    }
}

- (void)openSubWebView:(NSString *)url
{
    [self openSubWebView:url request:nil];
}

- (void)openSubWebView:(NSString *)url request:(NSURLRequest *)request
{
    BOOL isException = [CPCommonInfo isExceptionalUrl:url];
    CGRect subWebViewFrame;
    
    // Exception URL은 네비게이션바없는 풀화면으로 보여줌
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
    
    if (self.subWebView) {
        [self.subWebView setFrame:subWebViewFrame];
        [self.subWebView updateFrame];
        [self.subWebView open:url];
    }
    else {
        [self addSubWebViewWithFrame:subWebViewFrame url:url request:request];
    }
}

- (void)openSettingViewController
{
    SetupController *viewController = [[SetupController alloc] init];
    viewController.delegate = self;
	
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openLoginViewController
{   
    NSString *loginUrl = [[CPCommonInfo sharedInfo] urlInfo][@"login"];
    NSString *loginUrlString = [Modules urlWithQueryString:loginUrl];
	
	CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
	
	[popViewController setTitle:@"로그인"];
	[popViewController setIsLoginType:YES];
	[popViewController setRequestUrl:loginUrlString];
	[popViewController setDelegate:self];
	[popViewController initLayout];
	
	if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[self presentViewController:popViewController animated:YES completion:nil];
	}
}

- (void)openOTP:(NSString *)option
{
    [self setOtp:option];
}

// ads 스킴.
// popup : 광고페이지를 전면
// searchKeywords : JSON 데이터 중 랜덤으로 검색창에 노출.
// searchText : 전달된 텍스를 검색창에 노출
- (void)advertisement:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && [separatedOption count] < 2) {
        return;
    }
    
    if ([[separatedOption objectAtIndex:0] isEqualToString:@"popup"]) {
        if ([separatedOption count] > 1) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *props = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
            
            if (props && [[props objectForKey:@"errCode"] intValue] == 0) {
                NSMutableArray *inAppPopUpMgr = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:@"inAppPopUpId"]];
                
                if (inAppPopUpMgr) {
                    for (NSMutableDictionary *dic in inAppPopUpMgr) {
                        if ([[dic objectForKey:@"adPopupId"] isEqualToString:[props objectForKey:@"id"]]) {
                            return;
                        }
                    }
                }

                //튜토리얼이 실행중일 경우는 전면팝업을 보여주지 않는다.
                if (tutorialView) {
                    return;
                }
                
                //타입이 03 : 풀스크린 팝업일 경우만 보여준다.
                if ([[props objectForKey:@"dispType"] isEqualToString:@"03"]) {
                    NSString *linkUrl = [props objectForKey:@"linkUrl"];
                    
                    CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
                    
                    [popViewController setTitle:@""];
                    [popViewController setIsLoginType:NO];
                    [popViewController setRequestUrl:linkUrl];
                    [popViewController setDelegate:self];
                    [popViewController initLayout];
                    
                    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                        [self presentViewController:popViewController animated:YES completion:nil];
                    }
                }
                
                //일정 시간이 지난 ID는 저장된 데이터에서 삭제한다.
                NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
                
                [object setObject:[props objectForKey:@"id"] forKey:@"adPopupId"];
                [object setObject:[props objectForKey:@"expiredTime"] forKey:@"expiredTime"];
                
                [inAppPopUpMgr addObject:object];
                
                [userDefaults setObject:inAppPopUpMgr forKey:@"inAppPopUpId"];
                [userDefaults synchronize];
                
                for (NSMutableDictionary *dic in inAppPopUpMgr) {
                    if ([[dic objectForKey:@"adPopupId"] isEqualToString:[props objectForKey:@"id"]]) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                        NSDate *date = [dateFormat dateFromString:[dic objectForKey:@"expiredTime"]];;
                        
                        if ([date timeIntervalSinceNow] < 0) {
                            [inAppPopUpMgr removeObject:dic];
                        }
                    }
                }
                
                [userDefaults setObject:inAppPopUpMgr forKey:@"inAppPopUpId"];
                [userDefaults synchronize];
            }
        }
    }
}

//애니메이션이 없는 url
- (BOOL)needsNoAnimationUrl:(NSString *)url
{
    if ([url isMatchedByRegex:@"returnURL=http%3A%2F%2Fm.11st.co.kr%2FMW%2FHybrid%2Ftab%2Fhome.html"]) {
        return YES;
    }
    else if ([url isMatchedByRegex:@"/html/main.html"]) {
        return YES;
    }
    else if ([url isMatchedByRegex:@"method=getProvision&anncCd=01"]) {
        return YES;
    }
    else if ([url isMatchedByRegex:@"method=getProvision&anncCd=03"]) {
        return YES;
    }
    
    return NO;
}

- (void)goProductDetail:(NSString *)prdNo
{
    CPProductViewController *viewController = [[CPProductViewController alloc] initWithProductNumber:prdNo];
    [self.navigationController pushViewController:viewController animated:NO];
}

- (void)goSearchKeyword:(NSString *)keyword referrer:(NSString *)referrer
{
	CPProductListViewController *searchView = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:referrer];
	[self.navigationController pushViewController:searchView animated:YES];
}

- (void)goPriceCompareDetail:(NSString *)modelNo keyword:(NSString *)keyword
{
    if (!modelNo || [modelNo length] == 0) return;
    
    CPPriceDetailViewController *viewController = [[CPPriceDetailViewController alloc] init];
    viewController.modelNo = modelNo;
    viewController.keyword = keyword;
    [self.navigationController pushViewController:viewController animated:NO];
}

- (void)setGnbSearchKeyword
{
    if (_disableSearchKeyword) return;
    
    NSString *gnbTextAppScheme = [[CPCommonInfo sharedInfo] gnbTextAppScheme];
    if (!nilCheck(gnbTextAppScheme)) {
        [[CPSchemeManager sharedManager] openUrlScheme:gnbTextAppScheme sender:nil changeAnimated:NO];
    }
    
    _disableSearchKeyword = YES;
    [self performSelector:@selector(enableSearchKeyword) withObject:nil afterDelay:5.f];
}

- (void)enableSearchKeyword
{
    _disableSearchKeyword = NO;
}

#pragma mark - NavigationBar

- (CPNavigationBarView *)navigationBarView:(CPNavigationType)navigationType
{
    if (navigationBarView) {
        [navigationBarView removeFromSuperview];
    }
    
    navigationBarView = [[CPNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44) type:navigationType];
    [navigationBarView setDelegate:self];
    
    // 개발자모드 진입점
    [self initDeveloperInfo:navigationBarView.logoButton];
    
    return navigationBarView;
}

#pragma mark - Selectors

- (void)loginStatusDidChange
{
    [self reloadHomeTab];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return  menuContents.count;
}

- (BOOL)isTabWebViewItem:(NSInteger)tag
{
    BOOL isTabWebView = NO;
    
    for (CPWebView *item in tabWebViewArray) {
        if (item.tag == tag) {
            return YES;
        }
    }
    
    return isTabWebView;
}

- (CPWebView *)findTabWebViewItem:(NSInteger)tag
{
    CPWebView *webView;
    
    for (CPWebView *item in tabWebViewArray) {
        if (item.tag == tag) {
            return item;
        }
    }
    
    return webView;
}

- (void)setTabWebViewScrollsToTop
{
    //모든 탭의 웹뷰 스크롤뷰 setScrollsToTop NO로 초기화
    for (CPWebView *tabWebView in tabWebViewArray) {
        [tabWebView.webView.scrollView setScrollsToTop:NO];
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
    [view setBackgroundColor:[UIColor clearColor]];

	NSDictionary *menuContentInfo = menuContents[index];
	
    if ([menuContentInfo[@"type"] isEqualToString:@"web"] || [menuContentInfo[@"type"] isEqualToString:@"hidden"]) {
//    if (!([menuContentInfo[@"key"] isEqualToString:@"RANK"] || [menuContentInfo[@"key"] isEqualToString:@"WRANK"])) {
        CPWebView *tabWebView = [[CPWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
        [tabWebView setTag:index];
        [tabWebView setDelegate:self];
        
        //    [view addSubview:tabWebView];
        
        if (tabWebViewArray.count > 0) {
            
            if ([self isTabWebViewItem:index]) {
                [view addSubview:[self findTabWebViewItem:index]];
            }
            else {
                [tabWebView open:menuContentInfo[@"url"]];
                [view addSubview:tabWebView];
                
                @synchronized(tabWebViewArray) {
                    [tabWebViewArray addObject:tabWebView];
                }
            }
        }
        else {
            [tabWebView open:menuContentInfo[@"url"]];
            [view addSubview:tabWebView];
            
            @synchronized(tabWebViewArray) {
                [tabWebViewArray addObject:tabWebView];
            }
        }
        
        if (index == 0) {
            self.subWebView = tabWebView;
            
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [panGestureRecognizer setDelegate:self];
            [self.subWebView addGestureRecognizer:panGestureRecognizer];
            
//            //AccessLog - 메인탭
//            NSDictionary *menuContentInfo = menuContents[carousel.currentItemIndex];
//            NSString *accessLogCode = menuContentInfo[@"ac"];
//            if (accessLogCode) {
//                [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
//            }
        }
    }
    else if ([menuContentInfo[@"type"] isEqualToString:@"native"]) {
		
		if ([menuContentInfo[@"key"] isEqualToString:@"HOME"])
		{
			CPHomeView *homeView = [[CPHomeView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [homeView setTag:CPTabButtonTypeHome];
			[homeView setInfo:menuContentInfo];
			[homeView setDelegate:self];
			[view addSubview:homeView];
		}
        else if ([menuContentInfo[@"key"] isEqualToString:@"DEAL"]) {
            CPShockingDealView *shockingDealView = [[CPShockingDealView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [shockingDealView setTag:CPTabButtonTypeShockingDeal];
            [shockingDealView setInfo:menuContentInfo];
            [shockingDealView setDelegate:self];
            [view addSubview:shockingDealView];
        }
        else if ([menuContentInfo[@"key"] isEqualToString:@"RANK"] || [menuContentInfo[@"key"] isEqualToString:@"WRANK"]) {
            CPBestView *bestView = [[CPBestView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [bestView setTag:[menuContentInfo[@"key"] isEqualToString:@"RANK"] ? CPTabButtonTypeMobileBest : CPTabButtonTypeElevenstBest];
            [bestView setInfo:menuContentInfo];
            [bestView setDelegate:self];
            [view addSubview:bestView];
        }
		else if ([menuContentInfo[@"key"] isEqualToString:@"TALK"]) {
            CPTalkView *talkView = [[CPTalkView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [talkView setTag:CPTabButtonTypeTalk];
			[talkView setInfo:menuContentInfo];
			[talkView setDelegate:self];
			[view addSubview:talkView];
		}
		else if ([menuContentInfo[@"key"] isEqualToString:@"EVENT"]) {
            CPEventView *eventView = [[CPEventView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [eventView setTag:CPTabButtonTypeEvent];
			[eventView setInfo:menuContentInfo];
			[eventView setDelegate:self];
			[eventView setViewType:@"EVENT"];
			[view addSubview:eventView];
		}
		else if ([menuContentInfo[@"key"] isEqualToString:@"PLAN"]) {
            CPEventView *eventView = [[CPEventView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [eventView setTag:CPTabButtonTypePlan];
			[eventView setInfo:menuContentInfo];
			[eventView setDelegate:self];
			[eventView setViewType:@"PLAN"];
			[view addSubview:eventView];
		}
		else if ([menuContentInfo[@"key"] isEqualToString:@"TREND"]) {
			CPTrendView *trendView = [[CPTrendView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [trendView setTag:CPTabButtonTypeTrend];
			[trendView setInfo:menuContentInfo];
			[trendView setDelegate:self];
			[view addSubview:trendView];
		}
		else if ([menuContentInfo[@"key"] isEqualToString:@"CURATION"]) {
			CPCurationView *curationView = [[CPCurationView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [curationView setTag:CPTabButtonTypeCuration];
			[curationView setInfo:menuContentInfo];
			[curationView setDelegate:self];
			[view addSubview:curationView];
		}
		else if ([menuContentInfo[@"key"] isEqualToString:@"MART"]) {
			CPMartView *martView = [[CPMartView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [martView setTag:CPTabButtonTypeMart];
			[martView setInfo:menuContentInfo];
			[martView setDelegate:self];
			[view addSubview:martView];
		}
        else if ([menuContentInfo[@"key"] isEqualToString:@"BRAND"]) {
            //gclee
            CPBrandView *brandView = [[CPBrandView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [brandView setTag:CPTabButtonTypeMart];
            [brandView setInfo:menuContentInfo];
            [brandView setDelegate:self];
            [view addSubview:brandView];
        }

        //현재 탭의 웹뷰의 스크롤뷰만 setScrollsToTop 허용해줌
        for (UIView *subView in [view subviews]) {
            if ([subView isKindOfClass:[CPWebView class]]) {
                CPWebView *tapWebView = (CPWebView *)subView;
                [tapWebView.webView.scrollView setScrollsToTop:YES];
            }
        }
        
//        //AccessLog - 메인탭
//        NSDictionary *menuContentInfo = menuContents[carousel.currentItemIndex];
//        NSString *accessLogCode = menuContentInfo[@"ac"];
//        if (accessLogCode) {
//            [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
//        }
    }
	else if ([menuContentInfo[@"type"] isEqualToString:@"hidden_native"]) {
		if ([menuContentInfo[@"key"] isEqualToString:@"HIDDEN"]) {
			CPHiddenView *hiddenView = [[CPHiddenView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
            [hiddenView setTag:CPTabButtonTypeHidden];
			[hiddenView setInfo:menuContentInfo];
			[hiddenView setDelegate:self];
			[view addSubview:hiddenView];
		}
	}
	
    return view;
}

#pragma mark - iCarouselDelegate
//gclee
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case iCarouselOptionWrap:
            return YES;
            break;
        case iCarouselOptionVisibleItems:
            value = menuContents.count;
//            value = 3;
            break;
        case iCarouselOptionSpacing:
//            if (carousel == menuView) {
//                return value * 1.05f;
//            }
            break;
        default:
            break;
    }
    
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
//    NSLog(@"carouselCurrentItemIndexDidChange:%i, %i", carousel.currentItemIndex, currentHomeTab);

//    [contentsView scrollToItemAtIndex:carousel.currentItemIndex animated:YES];
    [tabMenuView tabMenuCurrentItemIndexDidChange:carousel.currentItemIndex];
    
    //모든 탭의 웹뷰 스크롤뷰 setScrollsToTop NO로 초기화
    [self setTabWebViewScrollsToTop];
    
    // 현재 웹뷰로 설정
    for (UIView *subView in [[contentsView itemViewAtIndex:carousel.currentItemIndex] subviews]) {
        if ([subView isKindOfClass:[CPWebView class]]) {
            CPWebView *tabWebView = (CPWebView *)subView;
            if (tabWebView.tag == carousel.currentItemIndex) {
                self.subWebView = tabWebView;

                currentHomeTab = tabWebView.tag;
                
                //현재 탭의 웹뷰의 스크롤뷰만 setScrollsToTop 허용해줌
                [tabWebView.webView.scrollView setScrollsToTop:YES];
            }
        }
        else {
            currentHomeTab = carousel.currentItemIndex;
            
            UIView *carouselView = carousel.currentItemView;
            
            //swipe 할 경우 해당 페이지의 데이터가 없을 경우 데이터를 리로드한다.
            for (UIView *carouselSubview in carouselView.subviews) {
                //gclee
                if ([carouselSubview isKindOfClass:[CPHomeView class]]
                    || [carouselSubview isKindOfClass:[CPBestView class]]
                    || [carouselSubview isKindOfClass:[CPShockingDealView class]]
                    || [carouselSubview isKindOfClass:[CPMartView class]]
                    || [carouselSubview isKindOfClass:[CPMartView class]]
                    || [carouselSubview isKindOfClass:[CPBrandView class]]
                    || [carouselSubview isKindOfClass:[CPBrandView class]]
                    || [carouselSubview isKindOfClass:[CPTalkView class]]
                    || [carouselSubview isKindOfClass:[CPTrendView class]]
                    || [carouselSubview isKindOfClass:[CPCurationView class]]
                    || [carouselSubview isKindOfClass:[CPEventView class]]
                    || [carouselSubview isKindOfClass:[CPHiddenView class]]) {
                    
                    if ([carouselSubview respondsToSelector:@selector(reloadDataWithErrorRequest)]) {
                        [carouselSubview performSelector:@selector(reloadDataWithErrorRequest) withObject:nil];
                    }
                    break;
                }
            }
        }
    }
    
    //AccessLog - 메인탭
    NSDictionary *menuContentInfo = menuContents[carousel.currentItemIndex];
    NSString *accessLogCode = menuContentInfo[@"ac"];
    if (accessLogCode) {
        [[AccessLog sharedInstance] sendAccessLogWithCode:accessLogCode];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *keyword = @"";
    NSString *keywordUrl = @"";
    //keyword광고인지 확인한다.
    if (searchKeyWordInfo) {
        NSString *keywordTrim = [[searchKeyWordInfo objectForKey:@"name"] trim];
        if([[textField.text trim] length] > 0 && [textField.text isEqualToString:keywordTrim]) {
            keywordUrl = [searchKeyWordInfo objectForKey:@"link"];
        }
    }
		
    if ([[textField.text trim] length] > 0) {
        keyword = textField.text;
    }
	
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [viewController setWantsFullScreenLayout:YES];
//    }
    
    viewController.defaultUrl = keywordUrl;
    viewController.isSearchText = isSearchText;
    
    if (isSearchText) {
        viewController.defaultText = keyword;
    }
    
    [self.navigationController pushViewController:viewController animated:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    isCloseSearch = NO;
    
    return NO;
}

#pragma mark - UIGestureRecognizerDelegate

// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //    NSLog(@"%@", otherGestureRecognizer);
    if([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        
        UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)otherGestureRecognizer;
        if(tapRecognizer.numberOfTapsRequired == 2 && tapRecognizer.numberOfTouchesRequired == 1) {
            otherGestureRecognizer.enabled = NO;
        }
    }
    
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        //        NSLog(@"userDidPanWebView UIGestureRecognizerStateBegan %@", contentsView.scrollEnabled ? @"y":@"n");
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        //        NSLog(@"userDidPanWebView UIGestureRecognizerStateChanged %@", contentsView.scrollEnabled ? @"y":@"n");
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded) {
        contentsView.scrollEnabled = YES;
        //        NSLog(@"userDidPanWebView UIGestureRecognizerStateEnded %@", contentsView.scrollEnabled ? @"y":@"n");
    }
}

//- (void)handleLeftEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture
//{
//    if (gesture.state == UIGestureRecognizerStateEnded) {
//        
//        //서브툴바의 백버튼과 동일한 기능
//        if (self.subWebView && [self.subWebView.webView canGoBack]) {
//            if (![self.subWebView.zoomViewerButton isHidden]) {
//                [self.subWebView.zoomViewerButton setHidden:YES];
//            }
//            
//            [self.subWebView.webView goBack];
//        }
//        else {
//            [self removeSubWebView];
//            [contentsView scrollToItemAtIndex:currentHomeTab animated:NO];
//            isSearchText = NO;
//        }
//    }
//}

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
    [self initNavigation:CPNavigationTypeDefault];
    
    [self reloadHomeTab];
    
    //모든 화면의 스크롤을 위로 끌어올린다.
    if (contentsView) {
        for (NSInteger i=0; i<contentsView.numberOfItems; i++) {
            UIView *scrollSubview = [contentsView itemViewAtIndex:i];
            
            for (UIView *subview in scrollSubview.subviews) {
                //gclee
                if ([subview isKindOfClass:[CPHomeView class]]
                    || [subview isKindOfClass:[CPBestView class]]
                    || [subview isKindOfClass:[CPShockingDealView class]]
                    || [subview isKindOfClass:[CPMartView class]]
                    || [subview isKindOfClass:[CPMartView class]]
                    || [subview isKindOfClass:[CPBrandView class]]
                    || [subview isKindOfClass:[CPBrandView class]]
                    || [subview isKindOfClass:[CPTalkView class]]
                    || [subview isKindOfClass:[CPTrendView class]]
                    || [subview isKindOfClass:[CPCurationView class]]
                    || [subview isKindOfClass:[CPEventView class]]
                    || [subview isKindOfClass:[CPHiddenView class]]) {
                    
                    if ([subview respondsToSelector:@selector(goToTopScroll)]) {
                        [subview performSelector:@selector(goToTopScroll) withObject:nil afterDelay:0.3f];
                    }
                    break;
                }
            }
        }
    }
    
    isEnalbeLogoButton = NO;
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 로고 in 마트
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0002"];
    }
    else {
        //AccessLog - 로고
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGA0100"];
    }
}

- (void)didTouchMartButton
{
    [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeMart]];
    
    NSString *martUrl = [[CPCommonInfo sharedInfo] urlInfo][@"mart"];
    
    [self openWebViewControllerWithUrl:martUrl animated:NO];
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
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:subWebViewUrl];
    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)didTouchMartSearchButton
{
    CPMartSearchViewController *viewController = [[CPMartSearchViewController alloc] init];
    [viewController setDelegate:self];
//    [self.navigationController pushViewController:viewController animated:NO];
//    [self.navigationController setNavigationBarHidden:YES];
    [self presentViewController:viewController animated:NO completion:nil];
}

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
    [viewController setDelegate:self];
    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [viewController setWantsFullScreenLayout:YES];
//    }
    
//    viewController.defaultUrl = keywordUrl;
//    viewController.isSearchText = isSearchText;
//    
//    if (isSearchText) {
//        viewController.defaultText = keyword;
//    }
    
//    [self.navigationController pushViewController:viewController animated:NO];
//    [self.navigationController setNavigationBarHidden:YES];
    [self presentViewController:viewController animated:NO completion:nil];
}

#pragma mark - CPTabMenuViewDelegate

- (void)didTouchTabMenuButton:(NSInteger)index
{
    //gclee
    [contentsView scrollToItemAtIndex:index animated:NO];
    
    if ([contentsView itemViewAtIndex:index]) {
        for (UIView *subView in [[contentsView itemViewAtIndex:index] subviews]) {
            if ([subView isKindOfClass:[CPWebView class]]) {
                CPWebView *tabWebView = (CPWebView *)subView;
                tabWebView.isScrolling = NO;
            }
        }
    }
}

#pragma mark - CPPopOverViewViewDelegate

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
        case CPPopOverMenuTypeShare:
        {
            CPShareViewController *viewController = [[CPShareViewController alloc] init];
            NSString *shareTitle = self.navigationItem.title;

            if (!shareTitle || [[shareTitle trim] isEqualToString:@""]) {
                shareTitle = [self.subWebView execute:@"document.title"];
            }
            
            [viewController setShareTitle:shareTitle];
            [viewController setShareUrl:[self.subWebView url]];
            
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case CPPopOverMenuTypeSetting:
        {
            [self openSettingViewController];
            break;
        }
        case CPPopOverMenuTypeBrowser:
        {
            NSString *requestUrl = [self removeQueryStringWithUrl:[self.subWebView url]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestUrl]];
            break;
        }
        default:
            break;
    }
}

#pragma mark - CPContactViewControllerDelegate

- (void)didTouchContactConfirmButton:(NSString *)jsonData;
{
    NSString *javascript = [NSString stringWithFormat:@"contactList('{\"contactList\":%@}')", jsonData];
    [self.subWebView execute:javascript];
    
    isCloseContact = YES;
}

#pragma mark - CPSnapshotPopOverViewViewDelegate

- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    switch (button.tag) {
        case CPSnapshotPopOverMenuTypeHome:
        {
            CPSnapshotViewController *viewController = [[CPSnapshotViewController alloc] init];
            
            NSString *title = [self.subWebView execute:@"document.title"];
            
            [viewController setCaptureTargetView:self.view];
            [viewController setBrowserTitle:title];
            [viewController setBrowserUrl:[self.subWebView url]];
            
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
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

#pragma mark - CPWebViewDelegate - WebView

- (BOOL)webView:(CPWebView *)webView shouldStartLoadForProduct:(NSURLRequest *)request
{
    NSString *url = request ? request.URL.absoluteString : nil;
    
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:viewControlelr animated:YES];
    return NO;
}

- (BOOL)webView:(CPWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
{
    NSString *url = request ? request.URL.absoluteString : nil;
    
    BOOL isHidden = [CPCommonInfo isHomeMenuUrl:url];
    
    if (!isHidden) {
        CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
        [self.navigationController pushViewController:viewControlelr animated:[self needsNoAnimationUrl:url]?NO:YES];
        return NO;
    }

    //각 상황별 히든처리를 하면 안되는 경우가 있어서 조정한다.
    if (!self.subWebView) {
        //메인탭의 웹뷰일 경우 툴바 안보이도록 고정
        [webView setHiddenToolBarView:YES];
    }
    
    NSLog(@"CPWebView url:%@, hidden:%@, tag:%li", url, isHidden?@"Y":@"N", (long)webView.tag);
    
    //서브웹뷰 다시 메인 웹뷰를 호출했을 경우(ex. 메인에서 로그인)
    if (isHidden && self.subWebView) {
        [self loadContentsView];
    }
    
    //메인탭에서 서브웹뷰를 오픈할 경우에는 shouldStartLoad를 NO로 리턴
    if (!isHidden && !self.subWebView) {
        [webView stop];
        
        //request가 있으면 request를 다시 만들지 않고 loadRequest를 한다.
        [self openSubWebView:url request:request];
        
        return NO;
    }
    
    //Exception URL은 풀스크린으로 보여줌
    BOOL isException = [CPCommonInfo isExceptionalUrl:url];
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
    
    if (self.subWebView) {
        [self.subWebView setFrame:subWebViewFrame];
		[self.subWebView updateFrame];
        [self.subWebView setHiddenToolBarView:NO];
    }
    
    // 검색결과페이지에서 검색창 터치시 검색어 자동완성 노출
    NSString *searchUrl = [[CPCommonInfo sharedInfo] urlInfo][@"search"];
    NSArray *searchUrls = [searchUrl componentsSeparatedByString:@"?"];
    NSString *searchPrefixUrl = searchUrls[0];
    
    if ([url hasPrefix:searchPrefixUrl]) {
        isSearchText = YES;
    }
    else {
        isSearchText = NO;
    }
    
    //외부 URL 체크
    [self isExternalUrl:url];
    
    return YES;
}

- (void)webViewDidFinishLoad:(CPWebView *)aWebView
{
//    NSLog(@"webViewDidFinishLoad tag:%i", aWebView.tag);
    
    //로고 버튼의 무한 클릭을 막자
    tabWebViewLoadCount++;
    
    if (tabWebViewLoadCount == menuContents.count) {
        isEnalbeLogoButton = YES;
    }
}

- (void)webView:(CPWebView *)webView didFailLoadWithError:(NSError *)error
{
    tabWebViewLoadCount++;
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
                                                        message:NSLocalizedString(@"NetworkErrMsg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (BOOL)webView:(CPWebView *)webView openUrlScheme:(NSString *)urlScheme
{
    return [[CPSchemeManager sharedManager] openUrlScheme:urlScheme sender:nil changeAnimated:YES];
}

- (void)webViewGoBack
{
    // history:back 스킴인데 히스토리가 없는 경우
    [self removeSubWebView];
}

#pragma mark - CPWebViewDelegate - Button

- (void)didTouchZoomViewerButton
{
    if (!zoomViewerScheme || [@"" isEqualToString:[zoomViewerScheme trim]]) {
        return;
    }
    
    [[CPSchemeManager sharedManager] openUrlScheme:[NSString stringWithFormat:@"app://popupBrowser/%@", zoomViewerScheme] sender:nil changeAnimated:NO];
}

#pragma mark - CPWebViewDelegate - Toolbar

- (void)didTouchToolBarButton:(UIButton *)button;
{
    NSLog(@"currentWebView.tag:%li, currentNaviType:%li", (long)currentHomeTab, (long)[[CPCommonInfo sharedInfo] currentNavigationType]);
    //홈이거나 백버튼(히스토리없을 경우)
    if (button.tag == CPToolBarButtonTypeHome) {
        [self initNavigation:CPNavigationTypeDefault];
        
        [self reloadHomeTab];
    }
    else if (button.tag == CPToolBarButtonTypeBack) {
        [contentsView scrollToItemAtIndex:currentHomeTab animated:NO];
        
        [self initNavigation:[Modules isMatchedGNBUrl:[self.subWebView url]]];
        
        isSearchText = NO;
    }
    else if (button.tag == CPToolBarButtonTypeForward) {
        [self forwardSubWebView];
        
        [self initNavigation:[Modules isMatchedGNBUrl:[self.subWebView url]]];
    }
}

#pragma mark - CPWebViewDelegate - Navigation Bar

- (void)initNavigation:(CPNavigationType)navigationType
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[CPNavigationBarView class]]) {
            [subView removeFromSuperview];
//            NSLog(@"CPNavigationBarView removeFromSuperview");
        }
    }
    
    switch (navigationType) {
        case CPNavigationTypeMart:
            [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeMart]];
            [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
            break;
        case CPNavigationTypeDefault:
        default:
            [self.navigationController.navigationBar addSubview:[self navigationBarView:CPNavigationTypeDefault]];
            [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
            break;
    }
    
    [[CPCommonInfo sharedInfo] setCurrentNavigationType:navigationType];
}

#pragma mark - CPPopupBrowserViewDelegate

- (void)popupBrowserViewOpenUrlScheme:(NSString *)urlScheme
{
    [[CPSchemeManager sharedManager] openUrlScheme:urlScheme sender:nil changeAnimated:YES];
}

#pragma mark - CPSearchViewControllerDelegate

- (void)searchWithKeyword:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
    
    //인코딩
//    keyword = [Modules encodeAddingPercentEscapeString:keyword];
    
    if (keyword) {
        CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:nil];
        [self.navigationController pushViewController:viewConroller animated:YES];
    }
    
    isCloseSearch = YES;
}

- (void)reloadWebViewData
{
    [self.subWebView reload];
}

- (void)searchWithAdvertisement:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
    
    isCloseSearch = YES;
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
    
    isCloseSearch = YES;
}

#pragma mark - CPVideoPopupViewDelegate

- (void)didTouchProductButton:(NSString *)productUrl
{
    if (popUpBrowserView) {
        [popUpBrowserView removePopupBrowserView];
    }
    
    [self openWebViewControllerWithUrl:productUrl animated:YES];
}

- (void)didTouchFullScreenButton:(CPMoviePlayerViewController *)player
{
    [self presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player];
}

#pragma mark - CPPaymentDelegate

- (void)paymentExecuteScript:(NSString *)script
{
    if ([[CPCommonInfo sharedInfo] currentWebViewController]) {
        [[[CPCommonInfo sharedInfo] currentWebViewController].webView execute:script];
    }
    else {
        CPWebViewController *viewControlelr = [[CPWebViewController alloc] init];
        [viewControlelr.webView execute:script];
    }
}

- (void)paymentRequest:(NSURLRequest *)request
{
    [self openWebViewControllerWithRequest:request];
}

#pragma mark - SetupControllerDelegate

- (void)setupController:(SetupController *)controller gotoWebPageWithUrlString:(NSString *)urlString
{
    [self handleOpenURL:urlString];
}

#pragma mark - CPPopupViewControllerDelegate

- (void)popupViewControllerCloseAndMoveUrl:(NSString *)url
{
    [self openWebViewControllerWithUrl:url animated:YES];
}

- (void)popupviewControllerOpenOtpController:(NSString *)option
{
//	[self otp:option];
    [self setOtp:option];
}

- (void)popupviewControllerMoveHome:(NSString *)option
{
//    [self moveToHome:option];
    [self moveToHomeAction:option];
}

- (void)popupviewControllerOpenBrowser:(NSString *)option
{
    [self openBrowser:option];
}

- (void)popupViewControllerDidSuccessLogin
{

}

- (void)popupViewControllerAfterSuccessLogin
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLoginStatus" object:nil];
}

#pragma mark - CPBestViewDelegate

- (void)didTouchButtonWithUrl:(NSString *)productUrl
{
    BOOL isException = [CPCommonInfo isExceptionalUrl:productUrl];
    [self openWebViewControllerWithUrl:productUrl animated:!isException];
}

- (void)didTouchButtonWithUrl:(NSString *)productUrl animated:(BOOL)animated
{
    [self openWebViewControllerWithUrl:productUrl animated:animated];
}

- (void)didTouchTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *menuContentInfo = menuContents[contentsView.currentItemIndex];
    
    if ([menuContentInfo[@"key"] isEqualToString:@"RANK"] && button.tag == CPTabButtonTypeElevenstBest) {
        [contentsView scrollToItemAtIndex:currentHomeTab+1 animated:NO];
    } else if ([menuContentInfo[@"key"] isEqualToString:@"WRANK"] && button.tag == CPTabButtonTypeMobileBest) {
        [contentsView scrollToItemAtIndex:currentHomeTab-1 animated:NO];
    }
}

#pragma mark - CPShockingDealDelegate

- (void)onMoviePopup:(NSDictionary *)dic
{
    NSDictionary *urlInfo = [[CPCommonInfo sharedInfo] urlInfo];
    CPVideoInfo *videoInfo = [CPVideoInfo initWithMovieInfo:dic[@"movie"]];
    
    CPVideoPopupView *videoPopupView = [[CPVideoPopupView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)
                                                                   productInfo:dic
                                                                       urlInfo:urlInfo
                                                                     videoInfo:videoInfo];
    [videoPopupView setDelegate:self];
    [videoPopupView setUserInteractionEnabled:YES];
    [videoPopupView setMovieWithVideoInfo:videoInfo];
    [videoPopupView playWithVideoInfo:videoInfo autoPlay:NO];
    
    [self.navigationController.view addSubview:videoPopupView];
}

- (void)onPopupBrowser:(NSDictionary *)dic
{
    NSDictionary *props = [dic copy];
    
    CGFloat statusBarY = [SYSTEM_VERSION intValue] >= 7 ? 20.f : 0.f;
    CGFloat statusBarHeight = 20.f;
    
    popUpBrowserView = [[CPPopupBrowserView alloc] initWithFrame:CGRectMake(0,
                                                                            kScreenBoundsHeight,
                                                                            kScreenBoundsWidth,
                                                                            kScreenBoundsHeight-statusBarHeight)
                                                       popupInfo:props
                                                  executeWebView:self.subWebView];
    
    [popUpBrowserView setDelegate:self];
    [self.navigationController.view addSubview:popUpBrowserView];
    
    popUpBrowserView.backgroundColor = [UIColor redColor];
    
    
    CGRect frame = popUpBrowserView.frame;
    //            frame.origin.x -= kScreenBoundsWidth;
    frame.origin.y -= (kScreenBoundsHeight-statusBarY);
    
    [UIView animateWithDuration:0.3f animations:^{
        [popUpBrowserView setFrame:frame];
    }];
}

#pragma mark - handleOpenURL

- (void)handleOpenURL:(NSString *)url
{
	if ([self isExternalUrl:url]) {
        return;
    }

	url = [AppDelegate isAppUrlScheme:url shouldEqual:NO] ? [url stringByReplacingOccurrencesOfRegex:@"[^/]+://(.*)" withString:[NSString stringWithFormat:@"%@$1", URL_SCHEME]] : [Modules urlWithQueryString:url];
	
    [self openWebViewControllerWithUrl:url animated:NO];
}

- (NSString *)removeQueryStringWithUrl:(NSString *)url
{
	NSString *appVCA = [APP_VERSION stringByReplacingOccurrencesOfRegex:@"[^0-9]+" withString:@""];
	NSString *appVersionSet = [NSString stringWithFormat:@"%@&appVCA=%@&appVersion=%@&deviceId=%@", URL_QUERY_VARS, appVCA, APP_VERSION, DEVICE_ID];
	
	if (url && ![[url trim] isEqualToString:@""]) {
		NSMutableString *tempUrl = [[NSMutableString alloc] initWithString:url];
		
		return [tempUrl stringByReplacingOccurrencesOfString:appVersionSet withString:@""];
	}
	
	return url;
}

#pragma mark - 외부 URL 체크

- (BOOL)isExternalUrl:(NSString *)url
{
//	if (![self urlWithProperties:url]) return YES;
	
	if (![url isMatchedByRegex:@"^(https?|about|mailto|tel|mecard|geo|smsto):.*"] && ![url isMatchedByRegex:URL_PATTERN]) {
		CPPayment *payment = [CPPayment getInstance];
		[payment setDelegate:self];
        
		if ([payment isPaymentUrl:url]) {
			[payment openPayment:url];
			
			return YES;
		}
		
		if (url) {
			BOOL isElevenScheme = [AppDelegate isAppUrlScheme:url shouldEqual:NO];
			
			if (isElevenScheme) {
                NSString *schemeElevenst = [NSString stringWithString:url];
				
                schemeElevenst = [schemeElevenst stringByReplacingOccurrencesOfString:@"elevenst://" withString:@""];
                
				if ([@"" isEqualToString:schemeElevenst]) {
                    return YES;
                }
                
				NSString *tokenString = [NSString stringWithFormat:@"%@%@", APP_URL_SCHEME, @"://"];
				NSArray *separatedArray = [url componentsSeparatedByString:tokenString];
				NSInteger separatedCount = [separatedArray count];
				
				if (separatedArray && separatedCount > 1) {
					tokenString = @"loadurl?";
					
					if ([[separatedArray objectAtIndex:1] hasPrefix:tokenString]) {
						separatedArray = [url componentsSeparatedByString:tokenString];
						separatedCount = [separatedArray count];
						 
						if (separatedArray && separatedCount > 1) {
							NSString *domain = nil;
							NSString *requestUrl = nil;
                            NSString *xSiteCode = nil;
							NSString *urlString = [separatedArray objectAtIndex:1];
							
							if (urlString && [urlString hasPrefix:@"domain="]) {
								NSArray *stringArray = [urlString componentsSeparatedByString:@"domain="];
								
								if (stringArray && [stringArray count] > 1) {
									domain = [stringArray objectAtIndex:1];
								}
								
								if ([domain rangeOfString:@"&url="].location > 0) {
									stringArray = [domain componentsSeparatedByString:@"&url="];
									
									if (stringArray && [stringArray count] > 1) {
										requestUrl = [stringArray objectAtIndex:1];
									}
								}
                                
                                if (!nilCheck(requestUrl) && [requestUrl rangeOfString:@"&XSITE="].location > 0)
                                {
                                    stringArray = [requestUrl componentsSeparatedByString:@"&XSITE="];
                                    
                                    if (stringArray && [stringArray count] > 1) {
                                        xSiteCode = [stringArray objectAtIndex:1];
                                        
                                        //xSite 뒤의 파라메터를 제거한다.
                                        NSInteger findNum = [xSiteCode indexOf:@"&"];
                                        if (findNum != -1) {
                                            xSiteCode = [xSiteCode substringWithRange:NSMakeRange(0, findNum)];
                                        }

                                        if (!nilCheck(xSiteCode)) {
                                            requestUrl = [requestUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&XSITE=%@", xSiteCode] withString:@""];
                                        }
                                    }
                                }
  							}
							else if (urlString && [urlString hasPrefix:@"url="]) {
								NSArray *stringArray = [urlString componentsSeparatedByString:@"url="];
								
								if (stringArray && [stringArray count] > 1) {
									requestUrl = [stringArray objectAtIndex:1];
								}

                                if (!nilCheck(requestUrl) && [requestUrl rangeOfString:@"&XSITE="].location > 0)
                                {
                                    stringArray = [requestUrl componentsSeparatedByString:@"&XSITE="];
                                    
                                    if (stringArray && [stringArray count] > 1) {
                                        xSiteCode = [stringArray objectAtIndex:1];
                                        
                                        //xSite 뒤의 파라메터를 제거한다.
                                        NSInteger findNum = [xSiteCode indexOf:@"&"];
                                        if (findNum != -1) {
                                            xSiteCode = [xSiteCode substringWithRange:NSMakeRange(0, findNum)];
                                        }
                                        
                                        if (!nilCheck(xSiteCode)) {
                                            requestUrl = [requestUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&XSITE=%@", xSiteCode] withString:@""];
                                        }
                                    }
                                }
							}
                            
                            NSString *encodingUrl = nil;
                            if (!nilCheck(requestUrl)) {
                                encodingUrl = [URLDecode(requestUrl) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            }
                            
                            if (!nilCheck(encodingUrl) && nilCheck(xSiteCode))
                            {
                                // URL 이동
                                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodingUrl]];
                                [self openWebViewControllerWithRequest:request];
                            }
                            else if (!nilCheck(encodingUrl) && !nilCheck(xSiteCode))
                            {
                                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                                params[@"apiUrl"] = [XSITE_REQUEST_URL stringByReplacingOccurrencesOfString:@"{{XSITE_REF}}" withString:xSiteCode];

                                [[CPRESTClient sharedClient] requestCacheWithParam:params
                                                                           success:^(NSDictionary *result) {
                                                                               NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodingUrl]];
                                                                               [self openWebViewControllerWithRequest:request];
                                                                           } failure:^(NSError *error) {
                                                                               NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodingUrl]];
                                                                               [self openWebViewControllerWithRequest:request];
                                                                           }];
                            }
						}
					}
                    
                    //카카오톡
                    tokenString = @"kakaolink?executeurl=";
                    
                    if ([[separatedArray objectAtIndex:1] hasPrefix:tokenString]) {
                        separatedArray = [url componentsSeparatedByString:tokenString];
                        
                        NSString *requestUrl = [separatedArray objectAtIndex:1];
                        
                        if ([requestUrl hasPrefix:@"http://"]) {
                            [self openWebViewControllerWithUrl:URLDecode(requestUrl) animated:NO];
                        }
                    }
				}
                else {
//                    elevenst://goproduct?prdNo=
                    //elevenst://gocategory
                    //elevenst://gosearch
                    if ([url isMatchedByRegex:@"elevenst://goproduct"]) {
                        NSString *prdNo = [Modules extractingParameterWithUrl:url key:@"prdNo"];
                        
                        [self goProductDetail:prdNo];
                        return NO;
                    }
                }
			}
			else {
				if (![url hasPrefix:URL_SCHEME] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
				}
			}
            
			return YES;
		}
	}
	
	return NO;
}

#pragma mark - Javascript 호출

- (void)execute:(NSString *)command properties:(id)properties sender:(id)sender
{
    if (!command || [[command trim] isEqualToString:@""]) {
        return;
    }

    if ([command isMatchedByRegex:URL_PATTERN]) {
        [[CPSchemeManager sharedManager] openUrlScheme:command sender:sender changeAnimated:YES];
    }
	else {
        SBJSON *json = [[SBJSON alloc] init];
        NSString *javaScript = [command stringByMatching:@"javascript:(.+)" capture:1], *fullScript;

        if (javaScript) {
            if (properties) {
                if ([properties isKindOfClass:[NSDictionary class]]) {
                    fullScript = [NSString stringWithFormat:@"%@(%@);", javaScript, [json stringWithObject:properties]];
                }
				else if ([json objectWithString:URLDecode(properties)]) {
                    fullScript = [NSString stringWithFormat:@"%@(%@);", javaScript, URLDecode(properties)];
                }
				else {
					fullScript = [NSString stringWithFormat:@"%@(\"%@\");", javaScript, properties];
				}
            }
			else {
                if ([javaScript hasSuffix:@";"] || [javaScript hasSuffix:@")"]) {
                    fullScript = javaScript;
                }
                else {
                    fullScript = [NSString stringWithFormat:@"%@()", javaScript];
                }
            }

            [self.subWebView execute:fullScript];
        }
		else {
            [self.subWebView open:command];
        }
    }
}

#pragma mark - CPSchemeManagerDelegate

//ads
- (void)setSearchTextField:(NSString *)keyword
{
    [navigationBarView setSearchTextField:keyword];
}

- (void)openPopupViewController:(NSString *)linkUrl
{
    CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
    [popViewController setTitle:@""];
    [popViewController setIsLoginType:NO];
    [popViewController setRequestUrl:linkUrl];
    [popViewController setDelegate:self];
    [popViewController initLayout];
    
    [self presentViewController:popViewController animated:YES completion:nil];
}

//photoReview
- (void)openPhotoReviewController:(NSDictionary *)reviewInfo
{
    PhotoReviewController *viewController = [[PhotoReviewController alloc] init];
    [viewController setProperties:reviewInfo];
    
    if ([SYSTEM_VERSION intValue] < 7) {
        [viewController setWantsFullScreenLayout:YES];
    }
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:naviController animated:YES completion:nil];
}

//contact
- (void)openContactViewController:(NSDictionary *)contactInfo
{
    CPContactViewController *viewController = [[CPContactViewController alloc] initWithContact:contactInfo];
    [viewController setDelegate:self];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)closeContactViewController
{
    UIViewController *viewController = [self presentedViewController];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//popupBrowser
- (void)openPopupBrowserView:(NSDictionary *)popupInfo
{
    //구매옵션이 열려있으면 닫아준다.
    if (self.subWebView) {
        [self.subWebView closeProductOption];
    }
    
    CGFloat statusBarY = [SYSTEM_VERSION intValue] >= 7 ? 20.f : 0.f;
    CGFloat statusBarHeight = 20.f;
    
    popUpBrowserView = [[CPPopupBrowserView alloc] initWithFrame:CGRectMake(0,
                                                                            kScreenBoundsHeight,
                                                                            kScreenBoundsWidth,
                                                                            kScreenBoundsHeight-statusBarHeight)
                                                       popupInfo:popupInfo
                                                  executeWebView:self.subWebView];
    
    [popUpBrowserView setDelegate:self];
    [self.navigationController.view addSubview:popUpBrowserView];
    
    popUpBrowserView.backgroundColor = [UIColor redColor];
    
    CGRect frame = popUpBrowserView.frame;
    frame.origin.y -= (kScreenBoundsHeight-statusBarY);
    
    [UIView animateWithDuration:0.3f animations:^{
        [popUpBrowserView setFrame:frame];
    }];
}

- (void)closePopupBrowserView:(NSDictionary *)popupInfo
{
    if (popUpBrowserView) {
        [popUpBrowserView removePopupBrowserView];
        
        NSString *type = [popupInfo objectForKey:@"pType"];
        NSString *action = [popupInfo objectForKey:@"pAction"];
        
        if ([@"script" isEqualToString:type]) {
            if (action) {
                [self.subWebView execute:action];
            }
        }
        
        if ([@"url" isEqualToString:type]) {
            if (action) {
                [self openWebViewControllerWithUrl:action animated:NO];
            }
        }
    }
}

//zoomViewer
- (void)setZoomViewer:(NSArray *)options
{
    zoomViewerScheme = [@"open/" stringByAppendingString:options[1]];
    
    if ([[options objectAtIndex:0] isEqualToString:@"show"]) {
        [self.subWebView.zoomViewerButton setHidden:NO];
    }
    
    if ([[options objectAtIndex:0] isEqualToString:@"hide"]) {
        [self.subWebView.zoomViewerButton setHidden:YES];
    }
}

//canOpenApp
- (void)executeCanOpenApplication:(NSString *)option
{
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URLDecode(option)]];
    
    [self.subWebView execute:[NSString stringWithFormat:@"canOpenApplication('%d', '%@')", canOpen, URLDecode(option)]];
}

- (void)openWebView:(NSString *)url
{
    [self.subWebView open:url];
}

//toolbar action
- (void)webViewToolbarAction:(NSString *)option
{
    if ([option isEqualToString:@"top"]) {
        [self.subWebView actionTop];
    }
    else if ([option isEqualToString:@"back"]) {
        [self.subWebView actionBackWord];
    }
    else if ([option isEqualToString:@"forward"]) {
        [self.subWebView actionForward];
    }
    else if ([option isEqualToString:@"reload"] || [option isEqualToString:@"refresh"]) {
        [self.subWebView actionReload];
    }
    else if ([option isEqualToString:@"close"]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if ([option hasPrefix:@"external"]) {
        NSString *requestUrl = [self removeQueryStringWithUrl:[self.subWebView url]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestUrl]];
    }
}

//movie popup
- (void)openVideoPopupView:(NSDictionary *)productInfo
{
    BOOL isShowAlert = YES;
    
    if (isShowAlert)    isShowAlert = ![Modules isSktCustomerWithCurrier];
    if (isShowAlert)    isShowAlert = !([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi);
    if (isShowAlert)    isShowAlert = ![[CPCommonInfo sharedInfo] checkedVideoDataAlert];
    
    if (isShowAlert) {
        [UIAlertView showWithTitle:@"11번가"
                           message:@"이동통신망(3G/4G LTE)를 이용하여 동영상을 재생하면 별도의 데이터 통화료가 부과될 수 있습니다."
                 cancelButtonTitle:@"취소"
                 otherButtonTitles:@ [ @"재생" ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              
                              if (buttonIndex != alertView.cancelButtonIndex) {
                                  NSDictionary *urlInfo = [[CPCommonInfo sharedInfo] urlInfo];
                                  CPVideoInfo *videoInfo = [CPVideoInfo initWithMovieInfo:productInfo[@"movie"]];
                                  
                                  CPVideoPopupView *videoPopupView = [[CPVideoPopupView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)
                                                                                                 productInfo:productInfo
                                                                                                     urlInfo:urlInfo
                                                                                                   videoInfo:videoInfo];
                                  [videoPopupView setDelegate:self];
                                  [videoPopupView setUserInteractionEnabled:YES];
                                  [videoPopupView setMovieWithVideoInfo:videoInfo];
                                  [videoPopupView playWithVideoInfo:videoInfo];
                                  
                                  [self.navigationController.view addSubview:videoPopupView];
                                  
                                  [[CPCommonInfo sharedInfo] setCheckedVideoDataAlert:YES];
                              }
                          }];
    }
    else {
        NSDictionary *urlInfo = [[CPCommonInfo sharedInfo] urlInfo];
        CPVideoInfo *videoInfo = [CPVideoInfo initWithMovieInfo:productInfo[@"movie"]];
        
        CPVideoPopupView *videoPopupView = [[CPVideoPopupView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)
                                                                       productInfo:productInfo
                                                                           urlInfo:urlInfo
                                                                         videoInfo:videoInfo];
        [videoPopupView setDelegate:self];
        [videoPopupView setUserInteractionEnabled:YES];
        [videoPopupView setMovieWithVideoInfo:videoInfo];
        [videoPopupView playWithVideoInfo:videoInfo];
        
        [self.navigationController.view addSubview:videoPopupView];
    }
}

//imageView
- (void)openImageView:(NSDictionary *)imageInfo
{
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    ImageViewer *viewer = [[ImageViewer alloc] initWithFrame:CGRectMake(0, -mainFrame.size.height, mainFrame.size.width, mainFrame.size.height)];
    
    [viewer setTitle:[imageInfo objectForKey:@"title"]];
    [viewer setImages:[imageInfo objectForKey:@"list"]];
    [viewer open];
}

//pasteBoard
- (void)pasteClipBoard:(NSArray *)options
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    if ([[options objectAtIndex:0] isEqualToString:@"copy"]) {
        if ([[options objectAtIndex:1] isEqualToString:@"url"]) {
            [pasteBoard setURL:[NSURL URLWithString:self.subWebView.url]];
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
//    if (!isEnable || ![Modules isMatchedProductUrl:[self.subWebView url]]) {
//        //서랍제거
//        [self.subWebView destoryProductOption];
//        return;
//    }
//    
//    // 서랍활성화
//    [self.subWebView makeProductOption];
}

//setting
- (void)setSettingViewController:(NSString *)option animated:(BOOL)animated
{
    if ([option isEqualToString:@"setup"] || [option isEqualToString:@"preference"]) {
        [self openSettingViewController];
    }
    else if ([option isEqualToString:@"notification"]) {
        SetupNotifyController *viewController = [[SetupNotifyController alloc] init];
        [self presentViewController:viewController animated:animated completion:nil];
    }
    else if ([option hasPrefix:@"appLogin"]) {
        /*
         NSString *loginUrl = [option stringByMatching:@"([^/]+)/(.*)" capture:2];
         
         SetupLoginController *viewController = [[SetupLoginController alloc] init];
         
         if ([SYSTEM_VERSION intValue] < 7) {
         [viewController setWantsFullScreenLayout:YES];
         }
         
         [self presentViewController:viewController animated:animated completion:nil];
         
         [viewController setTitle:NSLocalizedString(@"SetupLoginController", nil)];
         [viewController openUrl:[Modules urlWithQueryString:loginUrl]];
         [viewController setDelegate:sender];
         */
    }
}

//otp
- (void)setOtp:(NSString *)otpStr
{
    //등록된 OTP 단말인지 확인
    NSString *otpID = [[NSUserDefaults standardUserDefaults] stringForKey:@"otpRegisterID"];
    
    if (!otpID || [otpID length] == 0) {
        return [Modules alert:NSLocalizedString(@"AlertTitle", nil) message:NSLocalizedString(@"SetupOtpNoRegisterID", nil)];
    }
    
    SetupOtpController *otpController = [[SetupOtpController alloc] init];
    
    SBJSON *json = [[SBJSON alloc] init];
    NSDictionary *otpDic = nil;
    
    otpStr = [otpStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    otpDic = [json objectWithString:otpStr];
    
    //외부 스킴으로 호출시 인코딩이 한번 더 되기때문에(UTF-8 이중 인코딩) 두번 풀어야한다.
    if (!otpDic) {
        otpStr = [otpStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        otpDic = [json objectWithString:otpStr];
    }
    
    if (!otpDic || !otpDic[@"url"]) {
        return [Modules alert:NSLocalizedString(@"AlertTitle", nil) message:NSLocalizedString(@"OtpGeneratorOpenFailed", nil)];
    }
    
    [otpController setPopupMode:YES];
    [otpController setActivationCodeInput:NO];
    [otpController setUserID:otpID];
    [otpController setOtpLayoutUrl:otpDic[@"url"]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:otpController];
    [self performSelector:@selector(presentOtpGeneratorController:) withObject:navigationController afterDelay:1.0f];
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
    NSString *eventId	= [jsonData objectForKey:@"eventid"];
    NSString *message	= [jsonData objectForKey:@"message"];
    NSString *dateStr	= [jsonData objectForKey:@"date"];
    NSString *eventUrl	= [jsonData objectForKey:@"eventurl"];
    
    if ([[eventId trim] length] > 0 && [[message trim] length] > 0 && [[dateStr trim] length] > 0) {
        BOOL bResult = [LOCAL_ALARM addLocalNotification:eventId
                                                 message:message
                                                    date:dateStr
                                                     url:eventUrl];
        
        if (bResult == NO) {
            //실패 메세지 호출
            NSString *javascript = @"javascript:failedAddLocalAlarm()";
            [self.subWebView execute:javascript];
        } else {
            //성공 메세지 호출
            NSString *javascript = @"javascript:finishedAddLocalAlarm()";
            [self.subWebView execute:javascript];
            
            [LOCAL_ALARM addInsertEventAlarmLogWithEventId:eventId];
        }
    }
}

- (void)eventAlarmRemoveAction:(NSDictionary *)jsonData
{
    NSString *eventId = [jsonData objectForKey:@"eventid"];
    
    if ([[eventId trim] length] > 0) {
        BOOL bResult = [LOCAL_ALARM removeLocalNotification:eventId];
        
        if (bResult == NO) {
            //실패 메세지 호출
            NSString *javascript = @"javascript:failedRemoveLocalAlarm()";
            [self.subWebView execute:javascript];
        } else {
            //성공 메세지 호출
            NSString *javascript = @"javascript:finishedRemoveLocalAlarm()";
            [self.subWebView execute:javascript];
        }
    }
}

//goPage
- (void)goToPageAction:(NSString *)option
{
    NSInteger index;
    for (NSDictionary *item in menuContents) {
        if ([option isEqualToString:item[@"key"]]) {
            index = [menuContents indexOfObject:item];
            [contentsView scrollToItemAtIndex:index animated:NO];

            if ([contentsView itemViewAtIndex:index]) {
                for (UIView *subView in [[contentsView itemViewAtIndex:index] subviews]) {
                    if ([subView isKindOfClass:[CPWebView class]]) {
                        CPWebView *tabWebView = (CPWebView *)subView;
                        tabWebView.isScrolling = NO;
                    }
                }
            }

            break;
        }
    }
}

//moveToHome
- (void)moveToHomeAction:(NSString *)option
{
    if ([option isEqualToString:@"home"]) {
        [self.subWebView removeFromSuperview];

        [self reloadHomeTab];
    }
}

//doNotInterceptSwipe
- (void)doNotInterceptSwipe:(NSString *)option
{
    //    NSLog(@"option:%@, %@", option, contentsView.scrollEnabled ? @"y":@"n");
    // 웹뷰내에서 스와이프 되는 동안에는 iCarousel의 스크롤을 막는다
    if ([option isEqualToString:@"dontIntercept"]) {
        contentsView.scrollEnabled = NO;
    }
}

// 하단 툴바 더보기>브라우저 실행시
- (void)openBrowser:(NSString *)option
{
    if (option) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLDecode(option)]];
    }
}

#pragma mark - HttpRequestDelegate

- (void)request:(HttpRequest *)request didSuccessWithReceiveData:(NSString *)data
{
    if (request.requestParameterType == RequestActionKeywordViewLog || request.requestParameterType == RequestActionKeywordClickLog) {
        return;
    }
}

- (void)request:(HttpRequest *)request didFailWithError:(NSError *)error
{
	//
}

#pragma mark - ShakeModuleDelegate

- (void)startAccelerometerForDelay
{
    if (_shakeModule) {
        [self stopAccelerometer];
    }
    
    _shakeModule = [[ShakeModule alloc] init];
    [_shakeModule setDelegate:self];
    [_shakeModule startAccelerometerUpdate];
}

- (void)stopAccelerometer
{
    if (_shakeModule) {
        [_shakeModule setDelegate:nil];
        [_shakeModule stopAccelerometerUpdate];
        _shakeModule = nil;
    }
}

- (void)shakeModuleSuccCount
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStart()";
	[self.subWebView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
}

- (void)shakeModuleCancel
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStop()";
    [self.subWebView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
	
    [self stopAccelerometer];
}

- (void)shakeModuleError
{
    //쉐이크를 GCD로 진행하기떄문에 메인스레드로 호출해줘야 함.
    NSString *javascript = @"javascript:shakeStop()";
    [self.subWebView performSelectorOnMainThread:@selector(execute:) withObject:javascript waitUntilDone:YES];
    
    [self stopAccelerometer];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ShockingDealTitle", nil)
                                                    message:@"지원하지않는 장비입니다."
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"확인", nil)
                                          otherButtonTitles:nil, nil];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

#pragma override presentViewController func.
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_USEC), dispatch_get_main_queue(),
				   ^{
					   [super presentViewController:viewControllerToPresent animated:flag completion:completion];
				   });
}

#pragma mark - Tutorials

- (void)makeTutorialView
{
    tutorialView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    tutorialView.backgroundColor = UIColorFromRGBA(0x000000, 0.75);
    [self.navigationController.view addSubview:tutorialView];
    
    //워크스루에서 코치마크로 변경
    UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tutorialButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    [tutorialButton setBackgroundColor:[UIColor clearColor]];
    [tutorialButton setImage:[UIImage imageNamed:@"coach.jpg"] forState:UIControlStateNormal];
    [tutorialButton addTarget:self action:@selector(tutorialClose:) forControlEvents:UIControlEventTouchUpInside];
    [tutorialView addSubview:tutorialButton];
    
//    tutorialScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
//    [tutorialScrollView setPagingEnabled:YES];
//    [tutorialScrollView setContentSize:CGSizeMake(kScreenBoundsWidth*4, kScreenBoundsHeight)];
//    [tutorialScrollView setShowsHorizontalScrollIndicator:NO];
//    [tutorialView addSubview:tutorialScrollView];
//    
//    for (int i = 0; i < 4; i++) {
//        CGFloat spaceHeight = (IS_IPHONE_4 ? 20 : 0);
//        
//        UIImageView *tutorialImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2-150+(kScreenBoundsWidth*i),
//                                                                                       kScreenBoundsHeight/2-(216+spaceHeight),
//                                                                                       300,
//                                                                                       452)];
//        tutorialImageView.backgroundColor = [UIColor clearColor];
//        tutorialImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorial_img_%i", i]];
//        [tutorialImageView setUserInteractionEnabled:YES];
//        [tutorialScrollView addSubview:tutorialImageView];
//        
//        UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [blankButton setFrame:CGRectMake(kScreenBoundsWidth*i, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
//        [blankButton setBackgroundColor:[UIColor clearColor]];
//        [blankButton setTag:i];
//        [tutorialScrollView addSubview:blankButton];
//        
//        if (i == 3) {
//            [blankButton addTarget:self action:@selector(tutorialClose:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else {
//            [blankButton addTarget:self action:@selector(touchNext:) forControlEvents:UIControlEventTouchUpInside];
//        }
//    }
}

- (void)touchNext:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [tutorialScrollView scrollRectToVisible:CGRectMake(kScreenBoundsWidth*(button.tag+1), 0, kScreenBoundsWidth, 452) animated:YES];
}

- (void)tutorialClose:(id)sender
{
    [tutorialView removeFromSuperview];
}

@end
