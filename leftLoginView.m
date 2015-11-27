//
//  leftLoginView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 10..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "leftLoginView.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"
#import "CPLoadingView.h"


@interface leftLoginView ()
{
    //NSDictionary *_item;
    //NSMutableDictionary *_AreaItem;
    NSString * _title;
    UILabel* labelMenu;
    UILabel* labelMailId;
    UILabel* labelId;
    UILabel* labelCardNumber;
    UIImageView *cardImageView;
    UIImageView *idImageView;
    UIButton* loginButton;
    UIButton* logoutButton;
    CPLoadingView *loadingView;
}
@end

@implementation leftLoginView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xf68a1e)];
        //[self setBackgroundColor:[UIColor clearColor]];
        
        //[self showContents];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xf68a1e)];
        //[self setBackgroundColor:[UIColor clearColor]];
        
        //LoadingView
        loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
                                                                      CGRectGetHeight(self.frame)/2-40,
                                                                      80,
                                                                      80)];
        
        _title = title;
        
        BOOL isAuto = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin];
        if(isAuto == YES)
        {
            [self loginProcess];
        }
        
        [self showContents];
        
        NSString* temp;
        temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
        if([temp isEqualToString:@"ko"]){
            [self initScreenView_ko];
        }else if([temp isEqualToString:@"vi"]){
            [self initScreenView_vi];
        }else{
            temp = @"EN";
        }

    }
    
    return self;
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self addSubview:loadingView];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

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

    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self startLoadingAnimation];
    
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
        
        [self showContents];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self stopLoadingAnimation];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Login Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        //        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self stopLoadingAnimation];
        
    }];
}

- (void) setDataAfterlogout
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kPwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserNm];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kEmail];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kEmail_id];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kPushY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kCardCode];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void) logoutProcess
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
    
    //
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"A3130U" forKey:@"serviceCode"];
    [rootDic setObject:@"" forKey:@"requestMessage"];
    [rootDic setObject:@"" forKey:@"responseMessage"];
    
//    NSString *strId = [[NSUserDefaults standardUserDefaults] stringForKey:kId];
//    NSString *strPwd = [[NSUserDefaults standardUserDefaults] stringForKey:kPwd];
//    if([[NSUserDefaults standardUserDefaults] stringForKey:kId] == nil){
//        return;
//    }
//    
//    [indiv_infoDic setObject:strId forKey:@"email_id"];
//    [indiv_infoDic setObject:strPwd forKey:@"pinno"];
    
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
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
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
            
            [self setVisableItem];
            
            [self setDataAfterlogout];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Logout Success" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];

            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Login Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        //        [alert show];
        
        //[self showContentsLogout];
        [self showContents];

        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
    
    
    [loginButton setEnabled:true];
    
    
}


#pragma showContents
- (void)showContents
{
    [self removeContents];
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES)
    {
        _loginStatus = 1;
    }else{
        _loginStatus = 0;
    }
    
    //150
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    CGFloat meY = self.bounds.origin.y;
    
    //360
    // 320 * 40
    /*
     const static CGFloat ICON_HEIGHT     =     50;
     const static CGFloat ICON_WIDTH      =    50;
     const static CGFloat LABEL_WIDTH     =    100;
     */
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?30:0;
    CGFloat labelMarginX = (kScreenBoundsWidth > 320)?2:0;
    CGFloat logoutMarginX = (kScreenBoundsWidth > 320)?0:0;
    
    //label
    // 100, 26
    labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, meWidth-(35+30), 60)]; //94/2
    [labelMenu setBackgroundColor:[UIColor clearColor]];
    [labelMenu setTextColor:UIColorFromRGB(0xffffff)];
    [labelMenu setFont:[UIFont systemFontOfSize:15]];
    //[labelMenu setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    //setFont:[UIFont systemFontOfSize:15]];
    //    [labelMenu setShadowColor:[UIColor whiteColor]];
    //    [labelMenu setShadowOffset:CGSizeMake(0,2)];
    [labelMenu setTextAlignment:NSTextAlignmentLeft];
    [labelMenu setNumberOfLines:0];
    //[labelMenu sizeToFit];
    [labelMenu setText:_title];
    [self addSubview:labelMenu];
    
    //login button
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(20, CGRectGetMaxY(labelMenu.frame)+20, meWidth-(45+40), 50)];
    [loginButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn_press.png"] forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn.png"] forState:UIControlStateNormal];
    //[emptyButton setImage:[UIImage imageNamed:@"icon_main_login.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(didTouchLogInBtn) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"로그인" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateHighlighted];
    
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self addSubview:loginButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // id image
    idImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 12, 13)];
    //[idImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    idImageView.contentMode = UIViewContentModeScaleAspectFit;
    [idImageView setImage:[UIImage imageNamed:@"total_menu_email_icon.png"]];
    [self addSubview:idImageView];
    
    //id label
    labelId = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, meWidth-100, 20) ];
    [labelId setBackgroundColor:[UIColor clearColor]];
    [labelId setTextColor:UIColorFromRGB(0xffffff)];
    [labelId setFont:[UIFont systemFontOfSize:15]];
    [labelId setTextAlignment:NSTextAlignmentLeft];
    [labelId setNumberOfLines:0];
     _stringId = (_loginStatus == 1)?[[NSUserDefaults standardUserDefaults] stringForKey:kUserNm]:@"";
    [labelId setText:_stringId];
    [self addSubview:labelId];
    
    //mail id label
    labelMailId = [[UILabel alloc] initWithFrame:CGRectMake(35, 16, meWidth-100, 20) ];
    [labelMailId setBackgroundColor:[UIColor clearColor]];
    [labelMailId setTextColor:UIColorFromRGB(0xffffff)];
    [labelMailId setFont:[UIFont systemFontOfSize:13]];
    [labelMailId setTextAlignment:NSTextAlignmentLeft];
    [labelMailId setNumberOfLines:0];
    _mailId = (_loginStatus == 1)?[[NSUserDefaults standardUserDefaults] stringForKey:kEmail_id]:@"";
    [labelMailId setText:_mailId];
    [self addSubview:labelMailId];
    
    //logout button
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setFrame:CGRectMake(kScreenBoundsWidth - (80+logoutMarginX), 5, 30, 30)];
    [logoutButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateHighlighted];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(didTouchLogOutBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoutButton];
    
    // card image
    cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-marginX, 36, meWidth-40, 135)];
    //[cardImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    cardImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cardImageView setImage:[UIImage imageNamed:@"total_menu_card_img.png"]];
    [self addSubview:cardImageView];
    
    //card number label
    _cardNumber =  [[NSUserDefaults standardUserDefaults] stringForKey:kCardCode] ;
    labelCardNumber = [[UILabel alloc] initWithFrame:CGRectMake(100-labelMarginX, 100+10, meWidth-65, 40) ];
    [labelCardNumber setBackgroundColor:[UIColor clearColor]];
    [labelCardNumber setTextColor:UIColorFromRGB(0xffffff)];
    [labelCardNumber setFont:[UIFont systemFontOfSize:15]];
    [labelCardNumber setTextAlignment:NSTextAlignmentLeft];
    [labelCardNumber setNumberOfLines:0];
    [labelCardNumber setText:_cardNumber];
    [self addSubview:labelCardNumber];
    
    [self setVisableItem];
    
    
}

- (void)showContentsLogout
{
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    if(isLogin == YES)
    {
        _loginStatus = 1;
    }else{
        _loginStatus = 0;
    }
    
    [self removeContents];
    
    //150
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    CGFloat meY = self.bounds.origin.y;
    
    //360
    // 320 * 40
    /*
     const static CGFloat ICON_HEIGHT     =     50;
     const static CGFloat ICON_WIDTH      =    50;
     const static CGFloat LABEL_WIDTH     =    100;
     */
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?30:0;
    CGFloat labelMarginX = (kScreenBoundsWidth > 320)?2:0;
    CGFloat logoutMarginX = (kScreenBoundsWidth > 320)?60:0;
    
    //label
    // 100, 26
    labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, meWidth-(35+30), 60)]; //94/2
    [labelMenu setBackgroundColor:[UIColor clearColor]];
    [labelMenu setTextColor:UIColorFromRGB(0xffffff)];
    [labelMenu setFont:[UIFont systemFontOfSize:15]];
    //[labelMenu setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    //setFont:[UIFont systemFontOfSize:15]];
    //    [labelMenu setShadowColor:[UIColor whiteColor]];
    //    [labelMenu setShadowOffset:CGSizeMake(0,2)];
    [labelMenu setTextAlignment:NSTextAlignmentLeft];
    [labelMenu setNumberOfLines:0];
    //[labelMenu sizeToFit];
    [labelMenu setText:_title];
    [self addSubview:labelMenu];
    
    //login button
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(20, CGRectGetMaxY(labelMenu.frame)+20, meWidth-(45+40), 50)];
    [loginButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn_press.png"] forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn.png"] forState:UIControlStateNormal];
    //[emptyButton setImage:[UIImage imageNamed:@"icon_main_login.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(didTouchLogInBtn) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"로그인" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateHighlighted];
    
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self addSubview:loginButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // id image
    idImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 12, 13)];
    //[idImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    idImageView.contentMode = UIViewContentModeScaleAspectFit;
    [idImageView setImage:[UIImage imageNamed:@"total_menu_email_icon.png"]];
    [self addSubview:idImageView];
    
    //id label
    labelId = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, meWidth-100, 20) ];
    [labelId setBackgroundColor:[UIColor clearColor]];
    [labelId setTextColor:UIColorFromRGB(0xffffff)];
    [labelId setFont:[UIFont systemFontOfSize:15]];
    [labelId setTextAlignment:NSTextAlignmentLeft];
    [labelId setNumberOfLines:0];
    _stringId = (_loginStatus == 1)?[[NSUserDefaults standardUserDefaults] stringForKey:kUserNm]:@"";
    [labelId setText:_stringId];
    [self addSubview:labelId];
    
    //mail id label
    labelMailId = [[UILabel alloc] initWithFrame:CGRectMake(35, 16, meWidth-100, 20) ];
    [labelMailId setBackgroundColor:[UIColor clearColor]];
    [labelMailId setTextColor:UIColorFromRGB(0xffffff)];
    [labelMailId setFont:[UIFont systemFontOfSize:13]];
    [labelMailId setTextAlignment:NSTextAlignmentLeft];
    [labelMailId setNumberOfLines:0];
    _mailId = (_loginStatus == 1)?[[NSUserDefaults standardUserDefaults] stringForKey:kId]:@"";
    [labelMailId setText:_mailId];
    [self addSubview:labelMailId];
    
    //logout button
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setFrame:CGRectMake(kScreenBoundsWidth - (80+logoutMarginX), 5, 30, 30)];
    [logoutButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateHighlighted];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(didTouchLogOutBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoutButton];
    
    // card image
    cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-marginX, 36, meWidth-40, 135)];
    //[cardImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    cardImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cardImageView setImage:[UIImage imageNamed:@"total_menu_card_img.png"]];
    [self addSubview:cardImageView];
    
    //card number label
    _cardNumber =  [[NSUserDefaults standardUserDefaults] stringForKey:kCardCode] ;
    labelCardNumber = [[UILabel alloc] initWithFrame:CGRectMake(100-labelMarginX, 100+10, meWidth-65, 40) ];
    [labelCardNumber setBackgroundColor:[UIColor clearColor]];
    [labelCardNumber setTextColor:UIColorFromRGB(0xffffff)];
    [labelCardNumber setFont:[UIFont systemFontOfSize:15]];
    [labelCardNumber setTextAlignment:NSTextAlignmentLeft];
    [labelCardNumber setNumberOfLines:0];
    [labelCardNumber setText:_cardNumber];
    [self addSubview:labelCardNumber];
    
    [self setVisableItem];
    
}


- (void)removeContents
{
    if(labelMenu){
        [labelMenu removeFromSuperview];
        labelMenu = nil;
    }
    
    if(labelMailId){
        [labelMailId removeFromSuperview];
        labelMailId = nil;
    }
    if(cardImageView){
        [cardImageView removeFromSuperview];
        cardImageView = nil;
    }
    if(idImageView){
        [idImageView removeFromSuperview];
        idImageView = nil;
    }
    if(loginButton){
        [loginButton removeFromSuperview];
        loginButton = nil;
    }
}

- (void)onClickButton
{
    
}

- (void)onLogOut
{
    
}

- (void)setVisableItem
{
    //_loginStatus = 0;
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kLoginY];
    
    if(isLogin == YES)
    {
        _loginStatus = 1;
    }else{
        _loginStatus = 0;
    }
    
    if(_loginStatus){ //log on
        
        [idImageView setHidden:false];
        [labelId setHidden:false];
        [labelMailId setHidden:false];
        [cardImageView setHidden:false];
        [logoutButton setHidden:false];
        [labelCardNumber setHidden:false];
        
        [labelMenu setHidden:true];
        [loginButton setHidden:true];
        
        
    }else{            //log off
        
        [idImageView setHidden:true];
        [labelId setHidden:true];
        [labelMailId setHidden:true];
        [logoutButton setHidden:true];
        [cardImageView setHidden:true];
        [labelCardNumber setHidden:true];
        
        [labelMenu setHidden:false];
        [loginButton setHidden:false];
    }
}

#pragma mark - Selectors
- (void)didTouchLogOutBtn
{
    [loginButton setEnabled:false];
    //log out
    [self logoutProcess];
    
//    if ([self.delegate respondsToSelector:@selector(didTouchLogOutBtn)]) {
//        [self.delegate didTouchLogOutBtn];
//    }
    
}
- (void)didTouchLogInBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogInBtn)]) {
        [self.delegate didTouchLogInBtn];
    }
    
}

#pragma mark -initScreenView
-(void)initScreenView_ko{
    
    [labelMenu setText:LEFT_DES_KO];
    [loginButton setTitle:LEFT_LOGIN_KO forState:UIControlStateNormal];
    
}

-(void)initScreenView_vi{
    
    [labelMenu setText:LEFT_DES_VI];
    [loginButton setTitle:LEFT_LOGIN_VI forState:UIControlStateNormal];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
