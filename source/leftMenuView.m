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
#import "leftViewController.h"
#import "AppDelegate.h"

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
    
//    BOOL isAuto = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin];
//    if(isAuto)
//    {
//        [self loginProcess];
//    }
    
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
    
    NSString* strLoginTitle;
    
    NSString* temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        strLoginTitle = LEFT_DES_KO;
        
    }else if([temp isEqualToString:@"vi"]){
        strLoginTitle = LEFT_DES_VI;
    }

    
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
    
    NSString* strNotiTitle;
    NSString* strConfigTitle;
    
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        
        strNotiTitle = LEFT_LOGIN_NOTI_KO;
        strConfigTitle = LEFT_CONFIG_KO;
        
    }else if([temp isEqualToString:@"vi"]){
        
        strNotiTitle = LEFT_LOGIN_NOTI_VI;
        strConfigTitle = LEFT_CONFIG_VI;
    }
    
    leftMenuItemView *menuItemView1 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginView.frame)+5, meWidth, MENU_HEIGHT) title:@"Sunny CLUB" viewType:1];
    [self addSubview:menuItemView1];
    [menuItemView1 setDelegate:self];
    
    leftMenuItemView *menuItemView2 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView1.frame), meWidth, MENU_HEIGHT) title:@"Sunny BANK" viewType:2];
    [self addSubview:menuItemView2];
    [menuItemView2 setDelegate:self];
    
    leftMenuItemView *menuItemView3 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView2.frame), meWidth, MENU_HEIGHT) title:strNotiTitle viewType:3];
    [self addSubview:menuItemView3];
    [menuItemView3 setDelegate:self];
    
    leftMenuItemView *menuItemView4 = [[leftMenuItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuItemView3.frame), meWidth, MENU_HEIGHT) title:strConfigTitle viewType:4];
    [self addSubview:menuItemView4];
    [menuItemView4 setDelegate:self];
    
    //ADView
    UIView* ADView = [[UIView alloc] initWithFrame:CGRectMake(-40-marginX/2,kScreenBoundsHeight-AD_HEIGHT, kScreenBoundsWidth+40-marginX/2, AD_HEIGHT)];
    [ADView setBackgroundColor:UIColorFromRGB(0x2881C0)]; //[self setBackgroundColor:UIColorFromRGB(0xffffff)]; //0x2881C0
    
    UIImageView *adImageView = [[UIImageView alloc] initWithFrame:ADView.bounds];
     [adImageView setImage:[UIImage imageNamed:@"total_menu_banner.png"]];
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
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    [likeImageView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [likeImageView setImage:[UIImage imageNamed:@"intro_img.png"]];
    [self addSubview:likeImageView];
    [self bringSubviewToFront:likeImageView];
    
    if ([SYSTEM_VERSION intValue] > 7) {
        likeImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:3.0f
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

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indiv_infoDic = [NSMutableDictionary dictionary];
    
    //회원가입
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"M2010N" forKey:@"serviceCode"];
    [rootDic setObject:@"S_SNYM2010" forKey:@"requestMessage"];
    [rootDic setObject:@"R_SNYM2010" forKey:@"responseMessage"];
    
    NSString *strId = [[NSUserDefaults standardUserDefaults] stringForKey:kId];
    NSString *strPwd = [[NSUserDefaults standardUserDefaults] stringForKey:kPwd];
    if([[NSUserDefaults standardUserDefaults] stringForKey:kId] == nil){
        return;
    }
   
    [indiv_infoDic setObject:strId forKey:@"email_id"];
    [indiv_infoDic setObject:strPwd forKey:@"pinno"];
    
    [sendDic setObject:rootDic forKey:@"root_info"];
    [sendDic setObject:indiv_infoDic forKey:@"indiv_info"];//////
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [jsonWriter stringWithObject:sendDic];
    NSLog(@"request json: %@", jsonString);
    
    NSDictionary *parameters = @{@"plainJSON": jsonString};
    
    [manager POST:API_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSString *responseData = (NSString*) responseObject;
        NSArray *jsonArray = (NSArray *)responseData;
        NSDictionary * dicResponse = (NSDictionary *)responseData;
        
        //warning
        NSDictionary *dicItems = [dicResponse objectForKey:@"WARNING"];
        
        if(dicItems){
            NSString* sError = dicItems[@"msg"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            
            dicItems = nil;
            dicItems = [dicResponse objectForKey:@"indiv_info"];
            NSString* sCardNm = dicItems[@"user_seq"];
            
            //set kCardCode
            [[NSUserDefaults standardUserDefaults] setObject:sCardNm forKey:kCardCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString* sUserNm = dicItems[@"user_nm"];
            [[NSUserDefaults standardUserDefaults] setObject:sUserNm forKey:kUserNm];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //mail
            NSString* sEmail = dicItems[@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:sEmail forKey:kEmail];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //mail id
            NSString* sEmail_id = dicItems[@"email_id"];
            [[NSUserDefaults standardUserDefaults] setObject:sEmail_id forKey:kEmail_id];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"Response ==> %@", responseData);
            
            //to json
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            NSString *jsonString = [jsonWriter stringWithObject:jsonArray];
            NSLog(@"jsonString ==> %@", jsonString);
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            NSHTTPCookie *cookie;
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:@"locale_" forKey:NSHTTPCookieName];
            //        [cookieProperties setObject:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] forKey:NSHTTPCookieValue];
            //////////////////////////////////////
            [cookieProperties setObject:@"KO" forKey:NSHTTPCookieValue];
            [cookieProperties setObject:@"vntst.shinhanglobal.com" forKey:NSHTTPCookieDomain];
            [cookieProperties setObject:@"vntst.shinhanglobal.com" forKey:NSHTTPCookieOriginURL];
            [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
            [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
            // set expiration to one month from now
            [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
            cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            
            for (cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
                NSLog(@"%@=%@", cookie.name, cookie.value);
            }
            
            //        //json
            //        SBJsonParser *jsonParser = [SBJsonParser new];
            //        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseObject error:nil];
            //        NSLog(@"%@",jsonData);
            //        NSInteger success = [(NSNumber *) [jsonData objectForKey:@"result"] integerValue];
            //        NSLog(@"%d",success);
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //
            //        [cookie setValue:@"KO" forKey:@"locale_"];
            //
            //        //add cookie
            //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            //
            //        //
            //        NSMutableArray* cookieDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"cookieArray"];
            //        NSLog(@"cookie dictionary found is %@",cookieDictionary);
            //
            //        for (int i=0; i < cookieDictionary.count; i++)
            //        {
            //            NSLog(@"cookie found is %@",[cookieDictionary objectAtIndex:i]);
            //            NSMutableDictionary* cookieDictionary1 = [[NSUserDefaults standardUserDefaults] valueForKey:[cookieDictionary objectAtIndex:i]];
            //            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDictionary1];
            //            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            //
            //        }
            //
            
            NSLog(@"getCookie end ==>" );
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Login Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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

