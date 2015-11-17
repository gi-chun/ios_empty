//
//  leftMenuView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 5..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "leftMenuView.h"
#import "leftMenuItemView.h"
#import "leftLoginView.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"

const static CGFloat LOGO_HEIGHT   =      43;
const static CGFloat LOGIN_HEIGHT  =      180; //360/2
const static CGFloat MENU_HEIGHT   =      45;
const static CGFloat AD_HEIGHT     =      50;

@interface leftMenuView ()
{
    //CPLoadingView *_loadingView;
    //CPErrorView *_errorView;
    //UIButton *_topScrollButton;
    
    //NSDictionary *_item;
    //NSMutableDictionary *_AreaItem;
    
    UIView *logoView;
    leftLoginView *loginView;
    UIView *loginResultView;
    UIView *aDView;
}
@end

@implementation leftMenuView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
//        [self setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //self.menuItemScrollView.delegate = self;

        [self showContents];
        
        //NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[JSONstring dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:&error];
        

        
        //LoadingView
//        _loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
//                                                                       CGRectGetHeight(self.frame)/2-40,
//                                                                       80,
//                                                                       80)];
//        [self addSubview:_loadingView];
//        [self stopLoadingAnimation];
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info
{
//    if (info) {
//        _item = [info copy];
//        
//        //1.5초후 통신하도록 한다.
//        [self performSelector:@selector(reloadData) withObject:nil afterDelay:2.5];
//    }
//    else {
//        [self showErrorView];
//    }
}

- (void)reloadData
{
    //[self performSelectorInBackground:@selector(requestItems:) withObject:@NO];
}

- (void)reloadDataWithIgnoreCache:(NSNumber *)delay
{
    //[self performSelector:@selector(requestItems:) withObject:@YES afterDelay:[delay floatValue]];
}

- (void)goToTopScroll
{
    //[_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma showContents
- (void)showContents
{
    [self removeErrorView];
    [self removeContents];
    
    
    /*
     lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
     [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
     [self addSubview:lineView];
     */
    
    ////150
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    
    NSLog(@"left width %f", meWidth);
    NSLog(@"left heigth %f", meHeight);
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?60:0;
    
    //logoView
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kScreenBoundsWidth, LOGO_HEIGHT)];
    [logoView setBackgroundColor:UIColorFromRGB(0xf05921)];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 98, 25)];
    //[logoImageView setBackgroundColor:UIColorFromRGB(0xf05921)];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [logoImageView setImage:[UIImage imageNamed:@"total_menu_logo_img.png"]];
    [logoView addSubview:logoImageView];
    
    //close button
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(kScreenBoundsWidth - (70+marginX), 10, 15, 15)];
    [closeBtn setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"total_menu_close_btn.png"] forState:UIControlStateHighlighted];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"total_menu_close_btn.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(didTouchCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [logoView addSubview:closeBtn];
    
    [self addSubview:logoView];
    
    //login view
    loginView = [[leftLoginView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame), meWidth, LOGIN_HEIGHT) title:@"로그인을 하시면 Sunny Club의 다양한 서비스를 이용하실 수 있습니다."];
     [loginView setDelegate:self];
    
    [self addSubview:loginView];
    
//    if(isLowHeigth == 1){
//        //menuItem Scroll View
//        self.menuItemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(loginView.frame)+10, meWidth, (MENU_HEIGHT+10)*4)];
//        self.menuItemScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.menuItemScrollView.pagingEnabled = YES;
//        self.menuItemScrollView.delegate = self;
//        self.menuItemScrollView.showsHorizontalScrollIndicator = NO;
//        self.menuItemScrollView.showsVerticalScrollIndicator = YES;
//        [self addSubview:self.menuItemScrollView];
//        
//        leftMenuItemView *menuItemView1 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(loginView.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY CLUB"];
//        [self.menuItemScrollView addSubview:menuItemView1];
//        
//        leftMenuItemView *menuItemView2 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(menuItemView1.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY BANK"];
//        [self.menuItemScrollView addSubview:menuItemView2];
//        
//        leftMenuItemView *menuItemView3 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(menuItemView2.frame)+10, meWidth, MENU_HEIGHT) title:@"SUNNY EVENT"];
//        [self.menuItemScrollView addSubview:menuItemView3];
//        
//        leftMenuItemView *menuItemView4 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(menuItemView3.frame)+10, meWidth, MENU_HEIGHT) title:@"SETTING"];
//        [self.menuItemScrollView addSubview:menuItemView4];
//        
//        //[self.menuItemScrollView setContentSize:CGSizeMake(meWidth, (MENU_HEIGHT+10)*4)];
//        [self.menuItemScrollView setContentSize:CGSizeMake(meWidth, ((MENU_HEIGHT+10)*4)+50)];
//        [self.menuItemScrollView setContentOffset:CGPointMake(0,((MENU_HEIGHT+10)*4)+50)];
//    }else{
    
    leftMenuItemView *menuItemView1 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginView.frame)+5, meWidth, MENU_HEIGHT) title:@"Sunny CLUB" viewType:1];
    [self addSubview:menuItemView1];
    [menuItemView1 setDelegate:self];
    
    leftMenuItemView *menuItemView2 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView1.frame), meWidth, MENU_HEIGHT) title:@"Sunny BANK" viewType:2];
    [self addSubview:menuItemView2];
    [menuItemView2 setDelegate:self];
    
    leftMenuItemView *menuItemView3 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView2.frame), meWidth, MENU_HEIGHT) title:@"Event / 공지" viewType:3];
    [self addSubview:menuItemView3];
    [menuItemView3 setDelegate:self];
    
    leftMenuItemView *menuItemView4 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView3.frame), meWidth, MENU_HEIGHT) title:@"설정" viewType:4];
    [self addSubview:menuItemView4];
    [menuItemView4 setDelegate:self];
    
    //ADView
    UIView* ADView = [[UIView alloc] initWithFrame:CGRectMake(-40-marginX/2,kScreenBoundsHeight-AD_HEIGHT, kScreenBoundsWidth+40-marginX/2, AD_HEIGHT)];
    [ADView setBackgroundColor:UIColorFromRGB(0x3B98DE)];
    
    UIImageView *adImageView = [[UIImageView alloc] initWithFrame:ADView.bounds];
     [adImageView setImage:[UIImage imageNamed:@"ad_test.png"]];
    adImageView.contentMode = UIViewContentModeScaleAspectFit;
    [ADView addSubview:adImageView];
    
    //AD emptybutton
    UIButton* emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton setFrame:ADView.bounds];
    //[emptyButton setBackgroundColor:[UIColor clearColor]];
    [emptyButton setBackgroundImage:[UIImage imageNamed:@"ad_press_test.png"] forState:UIControlStateHighlighted];
    [emptyButton addTarget:self action:@selector(didTouchAD) forControlEvents:UIControlEventTouchUpInside];
    [ADView addSubview:emptyButton];
    [self addSubview:ADView];
    
    
    //[self loginProcess];


//    self.PanelDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightMargins, runningYOffset, frame.size.width - 2*kLeftRightMargins, panelDescriptionHeight)];
//    self.PanelDescriptionLabel.numberOfLines = 0;
//    self.PanelDescriptionLabel.text = self.PanelDescription;
//    self.PanelDescriptionLabel.font = kDescriptionFont;
//    self.PanelDescriptionLabel.textColor = kDescriptionTextColor;
//    self.PanelDescriptionLabel.alpha = 0;
//    self.PanelDescriptionLabel.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.PanelDescriptionLabel];
    
    
    //topScrollButton
//    CGFloat buttonWidth = kScreenBoundsWidth / 7;
//    CGFloat buttonHeight = kToolBarHeight;
    
//    _topScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_topScrollButton setFrame:CGRectMake(kScreenBoundsWidth-buttonWidth, CGRectGetHeight(self.frame)-buttonHeight, buttonWidth, buttonHeight)];
//    [_topScrollButton setImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateNormal];
//    [_topScrollButton addTarget:self action:@selector(onTouchTopScroll) forControlEvents:UIControlEventTouchUpInside];
//    [_topScrollButton setAccessibilityLabel:@"위로" Hint:@"화면을 위로 이동합니다"];
//    [_topScrollButton setHidden:YES];
//    [self addSubview:_topScrollButton];
    
    
    //[logoView addSubview:_headerMenuView];
}

- (void)removeContents
{
//    if (_collectionView) {
//        for (UIView *subview in [_collectionView subviews]) {
//            [subview removeFromSuperview];
//        }
//        
//        [_collectionView removeFromSuperview];
//        _collectionView.dataSource = nil;
//        _collectionView.delegate = nil;
//    }
    
//    if (_topScrollButton) {
//        if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
//        _topScrollButton = nil;
//    }
}

#pragma mark - click
- (void)onCloseButton
{
    
}

- (void)onLoginButton
{
    
}

#pragma mark - UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[_topScrollButton setHidden:0 < scrollView.contentOffset.y ? NO : YES];
}

//메뉴 클릭
- (void)onTouchMenuClicked:(id)sender
{
    //    NSInteger tag = [sender tag];
    //
    //    NSArray *tapItems = _topBrandAreaItem[@"topBrandArea"];
    //    NSString *linkUrl = tapItems[tag][@"linkUrl"];
    //
    //    if (linkUrl && [[linkUrl trim] length] > 0) {
    //        if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
    //            [self.delegate didTouchButtonWithUrl:linkUrl];
    //        }
    //    }
    //
    //    if (tag == 0)       [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0101"];
    //    else if (tag == 1)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0102"];
    //    else if (tag == 2)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0103"];
    //    else if (tag == 3)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0104"];
}

#pragma mark - Error View
- (void)showErrorView
{
    //    [self removeErrorView];
    //    [self removeContents];
    //
    //    _errorView = [[CPErrorView alloc] initWithFrame:self.frame];
    //    [_errorView setDelegate:self];
    //    [self addSubview:_errorView];
}

- (void)removeErrorView
{
    //    if (_errorView) {
    //        [_errorView removeFromSuperview];
    //        _errorView.delegate = nil;
    //        _errorView = nil;
    //    }
}

- (void)didTouchRetryButton
{
    //    if (_item) {
    //        [self removeErrorView];
    //        [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
    //    }
    //    else {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
    //                                                            message:NSLocalizedString(@"NetworkTemporaryErrMsg", nil)
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
    //                                                  otherButtonTitles:nil, nil];
    //
    //        [alertView show];
    //    }
}

#pragma mark - top button
- (void)onTouchTopScroll
{
    [self onTouchTopScroll:YES];
}

- (void)onTouchTopScroll:(BOOL)animation
{
    //[_collectionView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - CPLoadingView
- (void)startLoadingAnimation
{
    //    if (_loadingView.hidden == YES) {
    //        [_loadingView setHidden:NO];
    //        [_loadingView startAnimation];
    //
    //        [self bringSubviewToFront:_loadingView];
    //    }
}

- (void)stopLoadingAnimation
{
    //    if (_loadingView.hidden == NO) {
    //        [_loadingView stopAnimation];
    //        [_loadingView setHidden:YES];
    //    }
}

- (void) onClickADButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"test" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) onClickClose
{
    
}

#pragma mark - UICollectionViewDataSource
- (void) loginProcess
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.securityPolicy.allowInvalidCertificates = YES;
    //NSDictionary *parameters = @{@"foo": @"bar"};
    NSDictionary *parameters = @{@"plainJSON": @"{test}"};
    
    [manager POST:@"http://httpbin.org/post" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
//    [manager POST:@"https://vntst.shinhanglobal.com/sunny/jsp/callSunnyJsonTaskService.jsp" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
        NSLog(@"JSON: %@", responseObject);
        
        
        NSString *responseData = (NSString*) responseObject;
        NSArray *jsonArray = (NSArray *)responseData;
        NSLog(@"Response ==> %@", responseData);
        
        //json
//        SBJsonParser *jsonParser = [SBJsonParser new];
//        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
//        NSLog(@"%@",jsonData);
//        NSInteger success = [(NSNumber *) [jsonData objectForKey:@"result"] integerValue];
//        NSLog(@"%d",success);
        
        //to json
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        
        //NSString *jsonString = [jsonWriter stringWithObject:myDictionary];
        NSString *jsonString = [jsonWriter stringWithObject:jsonArray];
        NSLog(@"jsonString ==> %@", jsonString);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];

}

#pragma mark - Selectors
- (void)didTouchMenuItem:(NSInteger)menuType
{
    if ([self.delegate respondsToSelector:@selector(didTouchMenuItem:)]) {
        [self.delegate didTouchMenuItem:menuType];
    }

}
- (void)didTouchCloseBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchCloseBtn)]) {
        [self.delegate didTouchCloseBtn];
    }
    
}
- (void)didTouchLogOutBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogOutBtn)]) {
        [self.delegate didTouchLogOutBtn];
    }
    
}
- (void)didTouchLogInBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogInBtn)]) {
        [self.delegate didTouchLogInBtn];
    }
    
}
- (void)didTouchAD
{
    if ([self.delegate respondsToSelector:@selector(didTouchAD)]) {
        [self.delegate didTouchAD];
    }
    
}


@end

