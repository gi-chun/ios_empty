//
//  secondViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 26..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "secondViewController.h"
#import "NavigationBarView.h"
#import "WebViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MYViewController.h"

@interface secondViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
}
@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadContentsView];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadContentsView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContentsView
{
    for (UIView *subView in [self.view subviews]) {
        [subView removeFromSuperview];
    }
    
    if (self.navigationController.navigationBar.isHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2, 36, 36)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_login.png"] forState:UIControlStateHighlighted];
    [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
    //[menuButton setAccessibilityLabel:@"메뉴" Hint:@"왼쪽 메뉴로 이동합니다"];
    [self.view addSubview:menuButton];
    
    //    self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+10, 4, 54, 36)];
    //    [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_nor.png"] forState:UIControlStateNormal];
    //    [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_press.png"] forState:UIControlStateHighlighted];
    //    [self.logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
    //    [self.logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
    //    [self addSubview:self.logoButton];
    
    //    UIImage *searchImage = [UIImage imageNamed:@"gnb_search_bg.png"];
    //    searchImage = [searchImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchImage.size.height / 2, searchImage.size.width / 2, searchImage.size.height / 2, searchImage.size.width / 2)];
    //
    //    UIImageView *searchBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.logoButton.frame)+6, 4, kScreenBoundsWidth-206, 36)];
    //    [searchBackgroundImageView setImage:searchImage];
    //    [searchBackgroundImageView setUserInteractionEnabled:YES];
    //    [self addSubview:searchBackgroundImageView];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(reloadHomeTab)
    //                                                 name:ReloadHomeNotification
    //                                               object:nil];
    
    //[self initNavigation:1];
    
}

- (void)touchMenuButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"ok ^^"                                             delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
    [alert show];
    
    //NSString *url = @"http://m.naver.com";
    //NSString *url = @"https://vntst.shinhanglobal.com/sunny/index3.jsp";
    NSString *url = @"https://vntst.shinhanglobal.com/sunny/faq_test2.jsp";
    //NSString *url = @"https://vntst.shinhanglobal.com/sunny/faq_test.jsp";
    
    WebViewController *viewControlelr = [[WebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:viewControlelr animated:YES];
}

- (void)initNavigation:(NSInteger)navigationType
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[NavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (NavigationBarView *)navigationBarView:(NSInteger)navigationType
{
    if (navigationBarView) {
        [navigationBarView removeFromSuperview];
    }
    
    CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44) type:navigationType];
    [navigationBarView setDelegate:self];
    
    return navigationBarView;
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchBackButton
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didTouchMenuButton
{
    //[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didTouchBasketButton
{
//    NSString *cartUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cart"];
//    [self openWebViewControllerWithUrl:cartUrl animated:NO];
}

- (void)didTouchLogoButton
{
//    [self initNavigation:1];
    
//    [self reloadHomeTab];
//    
//    //모든 화면의 스크롤을 위로 끌어올린다.
//    if (contentsView) {
//        for (NSInteger i=0; i<contentsView.numberOfItems; i++) {
//            UIView *scrollSubview = [contentsView itemViewAtIndex:i];
//            
//            for (UIView *subview in scrollSubview.subviews) {
//                //gclee
//                if ([subview isKindOfClass:[CPHomeView class]]
//                    || [subview isKindOfClass:[CPBestView class]]
//                    || [subview isKindOfClass:[CPShockingDealView class]]
//                    || [subview isKindOfClass:[CPMartView class]]
//                    || [subview isKindOfClass:[CPMartView class]]
//                    || [subview isKindOfClass:[CPBrandView class]]
//                    || [subview isKindOfClass:[CPBrandView class]]
//                    || [subview isKindOfClass:[CPTalkView class]]
//                    || [subview isKindOfClass:[CPTrendView class]]
//                    || [subview isKindOfClass:[CPCurationView class]]
//                    || [subview isKindOfClass:[CPEventView class]]
//                    || [subview isKindOfClass:[CPHiddenView class]]) {
//                    
//                    if ([subview respondsToSelector:@selector(goToTopScroll)]) {
//                        [subview performSelector:@selector(goToTopScroll) withObject:nil afterDelay:0.3f];
//                    }
//                    break;
//                }
//            }
//        }
//    }
//    
//    isEnalbeLogoButton = NO;
//    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 로고 in 마트
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0002"];
//    }
//    else {
//        //AccessLog - 로고
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGA0100"];
//    }
}

- (void)didTouchMartButton
{
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
    
//    NSString *martUrl = [[CPCommonInfo sharedInfo] urlInfo][@"mart"];
//    
//    [self openWebViewControllerWithUrl:martUrl animated:NO];
}

- (void)didTouchMyInfoButton
{
    //[self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)didTouchSearchButton:(NSString *)keywordUrl;
{
//    if (keywordUrl) {
//        [self openWebViewControllerWithUrl:keywordUrl animated:YES];
//    }
}

- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword
{
//    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:keyword referrer:subWebViewUrl];
//    [self.navigationController pushViewController:viewConroller animated:YES];
}

- (void)didTouchMartSearchButton
{
//    CPMartSearchViewController *viewController = [[CPMartSearchViewController alloc] init];
//    [viewController setDelegate:self];
//    //    [self.navigationController pushViewController:viewController animated:NO];
//    //    [self.navigationController setNavigationBarHidden:YES];
//    [self presentViewController:viewController animated:NO completion:nil];
}

- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl
{
//    CPSearchViewController *viewController = [[CPSearchViewController alloc] init];
//    [viewController setDelegate:self];
//    
//    //    if ([SYSTEM_VERSION intValue] < 7) {
//    //        [viewController setWantsFullScreenLayout:YES];
//    //    }
//    
//    //    viewController.defaultUrl = keywordUrl;
//    //    viewController.isSearchText = isSearchText;
//    //
//    //    if (isSearchText) {
//    //        viewController.defaultText = keyword;
//    //    }
//    
//    //    [self.navigationController pushViewController:viewController animated:NO];
//    //    [self.navigationController setNavigationBarHidden:YES];
//    [self presentViewController:viewController animated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
