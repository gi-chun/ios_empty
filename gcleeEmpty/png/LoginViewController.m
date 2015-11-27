//
//  LoginViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NavigationBarView.h"
#import "setInforViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"
#import "leftViewController.h"
#import "idSearchViewController.h"
#import "pwdSearchViewController.h"

@interface LoginViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
    UITextField* currentEditingTextField;
    UIActivityIndicatorView* spinner;
    __weak IBOutlet UIButton *loginBtn;
    __weak IBOutlet UITextField *txtID;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UISwitch *switchAuto;
    __weak IBOutlet UILabel *labelAuto;
    __weak IBOutlet UIButton *btnIDSearch;
    __weak IBOutlet UIButton *btnPwdSearch;
    __weak IBOutlet UILabel *labelNoti;
    __weak IBOutlet UIButton *btnSummit;
    MYLoginType myLoginType;
    __weak IBOutlet UILabel *idLabel;
    __weak IBOutlet UILabel *pwdLabel;
    __weak IBOutlet UILabel *idSearchLabel;
    __weak IBOutlet UILabel *pwdSearchLabel;
    
}

@end

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //[self.navigationItem setHidesBackButton:YES];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(kScreenBoundsWidth/2.0, kScreenBoundsHeight/2.0)]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // spinner is not visible until started
    
    //txtPwd set
    
    [self resetNavigationBarView:1];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //myLoginType = LoginTypeDefault;
    
    [txtPwd setKeyboardType:UIKeyboardTypeNumberPad ];
    
    txtID.text = [[NSUserDefaults standardUserDefaults] stringForKey:kId] ;
    txtPwd.text = [[NSUserDefaults standardUserDefaults] stringForKey:kPwd] ;
    
    //set auto login
    if([[NSUserDefaults standardUserDefaults] boolForKey:kAutoLogin] == YES)
    {
        [switchAuto setOn:true];
    }else{
        [switchAuto setOn:false];
    }
    
    [self resetNavigationBarView:1];
    [self setDelegateText];
    
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        [self initScreenView_ko];
    }else if([temp isEqualToString:@"vi"]){
        [self initScreenView_vi];
    }else{
        temp = @"EN";
    }

    [txtID becomeFirstResponder];
    
}

- (void)setLoginType{
    
    myLoginType = LoginTypeConfig;
    
}

- (IBAction)pwdSearchClick:(id)sender {
    
    pwdSearchViewController *pwdSearchCtl = [[pwdSearchViewController alloc] init];
    //[setInforCtl setDelegate:self];
    [self.navigationController pushViewController:pwdSearchCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}
- (IBAction)setInforClick:(id)sender {
    
    setInforViewController *setInforCtl = [[setInforViewController alloc] init];
    //[setInforCtl setDelegate:self];
    [self.navigationController pushViewController:setInforCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (IBAction)autoLoginClick:(id)sender {
    
    if ([switchAuto isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)idSearchClick:(id)sender {
    
    idSearchViewController *idSearchController = [[idSearchViewController alloc] init];
    //[pwdChangeController setDelegate:self];
    [self.navigationController pushViewController:idSearchController animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)autoLogin{
//    [spinner setHidden:false];
//    [spinner startAnimating];
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    [likeImageView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [likeImageView setImage:[UIImage imageNamed:@"intro_img.png"]];
    [self.view addSubview:likeImageView];
    [self.view bringSubviewToFront:likeImageView];
    
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
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indiv_infoDic = [NSMutableDictionary dictionary];
    
    //회원가입
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"M2010N" forKey:@"serviceCode"];
    [rootDic setObject:@"S_SNYM2010" forKey:@"requestMessage"];
    [rootDic setObject:@"R_SNYM2010" forKey:@"responseMessage"];
    
    //    [indiv_infoDic setObject:@"springgclee@gmail.com" forKey:@"email_id"];
    //    [indiv_infoDic setObject:@"1111" forKey:@"pinno"];
    
    [indiv_infoDic setObject:txtID.text forKey:@"email_id"];
    [indiv_infoDic setObject:txtPwd.text forKey:@"pinno"];
    
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
            
//            [spinner setHidden:true];
//            [spinner stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:sError delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            leftViewController *leftViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).gLeftViewController;
            [leftViewController setViewLogin];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            
            dicItems = nil;
            dicItems = [dicResponse objectForKey:@"indiv_info"];
            NSString* sCardNm = dicItems[@"user_seq"];
            
            //set kCardCode
            [[NSUserDefaults standardUserDefaults] setObject:sCardNm forKey:kCardCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //set id, pwd
            [[NSUserDefaults standardUserDefaults] setObject:txtID.text forKey:kId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:txtPwd.text forKey:kPwd];
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
            
//            [spinner setHidden:true];
//            [spinner stopAnimating];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Login Success" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            leftViewController *leftViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).gLeftViewController;
            
            [leftViewController setViewLogin];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
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
        
        [spinner setHidden:true];
        [spinner stopAnimating];
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Login Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];

    
}
- (IBAction)loginBtnClick:(id)sender {
    
//    [spinner setHidden:false];
//    [spinner startAnimating];
    
    if([txtID.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check ID please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [txtID becomeFirstResponder];
        
        return;
    }
    if([txtPwd.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check PWD please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [txtPwd becomeFirstResponder];
        
        return;
    }
    
    
    //set auto login
    if ([switchAuto isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAutoLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAutoLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    [likeImageView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [likeImageView setImage:[UIImage imageNamed:@"intro_img.png"]];
    [self.view addSubview:likeImageView];
    [self.view bringSubviewToFront:likeImageView];
    
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
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indiv_infoDic = [NSMutableDictionary dictionary];
    
    //회원가입
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"M2010N" forKey:@"serviceCode"];
    [rootDic setObject:@"S_SNYM2010" forKey:@"requestMessage"];
    [rootDic setObject:@"R_SNYM2010" forKey:@"responseMessage"];
    
//    [indiv_infoDic setObject:@"springgclee@gmail.com" forKey:@"email_id"];
//    [indiv_infoDic setObject:@"1111" forKey:@"pinno"];
    
    [indiv_infoDic setObject:txtID.text forKey:@"email_id"];
    [indiv_infoDic setObject:txtPwd.text forKey:@"pinno"];
    
    [indiv_infoDic setObject:txtID.text forKey:@"email_id"];
    [indiv_infoDic setObject:txtPwd.text forKey:@"pinno"];
    
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
            
            [spinner setHidden:true];
            [spinner stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:sError delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            leftViewController *leftViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).gLeftViewController;
            [leftViewController setViewLogin];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
        
            dicItems = nil;
            dicItems = [dicResponse objectForKey:@"indiv_info"];
            NSString* sCardNm = dicItems[@"user_seq"];
            
            //set kCardCode
            [[NSUserDefaults standardUserDefaults] setObject:sCardNm forKey:kCardCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //set id, pwd
            [[NSUserDefaults standardUserDefaults] setObject:txtID.text forKey:kId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:txtPwd.text forKey:kPwd];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:dicItems[@"email"] forKey:kEmail];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:dicItems[@"email_id"] forKey:kEmail_id];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString* sUserNm = dicItems[@"user_nm"];
            [[NSUserDefaults standardUserDefaults] setObject:sUserNm forKey:kUserNm];
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
            
            [spinner setHidden:true];
            [spinner stopAnimating];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Login Success" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            leftViewController *leftViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).gLeftViewController;
            
            [leftViewController setViewLogin];
            
            if(myLoginType == LoginTypeConfig){
                [self.navigationController popViewControllerAnimated:YES];
                if ([self.delegate respondsToSelector:@selector(didLoginAfter)]) {
                    [self.delegate didLoginAfter];
                }
                
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
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
        
        [spinner setHidden:true];
        [spinner stopAnimating];
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Login Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
}

- (void)resetNavigationBarView:(NSInteger) type
{
    [self.navigationItem setHidesBackButton:YES];
    
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
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:LOGIN_TITLE_KO];
        [navigationBarView setDelegate:self];
    }else if([temp isEqualToString:@"vi"]){
        navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:LOGIN_TITLE_VI];
        [navigationBarView setDelegate:self];
    }else{
        temp = @"EN";
    }
    return navigationBarView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchBackButton
{
    //[self resetNavigationBarView:0];

    if(myLoginType == LoginTypeConfig){
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
            [self.delegate didTouchBackButton];
        }
    }
}

#pragma mark - text delegate
// Automatically register fields

-(void)setDelegateText
{
    [txtID setDelegate:self];
    [txtPwd setDelegate:self];
}

// UITextField Protocol

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentEditingTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    currentEditingTextField = NULL;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEdit];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (txtPwd.text.length >= PWD_MAX_LENGTH && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {return YES;}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self textFieldValueIsValid:textField]) {
        [self endEdit];
        return YES;
    } else {
        return NO;
    }
}

// Own functions

-(void)endEdit
{
    if (currentEditingTextField) {
        [currentEditingTextField endEditing:YES];
        currentEditingTextField = NULL;
    }
}


// Override this in your subclass to handle eventual values that may prevent validation.

-(BOOL)textFieldValueIsValid:(UITextField*)textField
{
    return YES;
}

#pragma mark -initScreenView
-(void)initScreenView_ko{
    
    [self resetNavigationBarView:1];
    [idLabel setText:LOGIN_ID_KO];
    [pwdLabel setText:LOGIN_PWD_KO];
    [labelAuto setText:LOGIN_AUTO_KO];
    [loginBtn setTitle:LOGIN_BTN_KO forState:UIControlStateNormal];
    [labelNoti setText:LOGIN_NOTI_KO];
    [btnSummit setTitle:LOGIN_SUMMIT_KO forState:UIControlStateNormal];
    [idSearchLabel setText:LOGIN_ID_FIND_KO];
    [pwdSearchLabel setText:LOGIN_PWD_FIND_KO];
    
}

-(void)initScreenView_vi{
    
    [self resetNavigationBarView:1];
    [idLabel setText:LOGIN_ID_VI];
    [pwdLabel setText:LOGIN_PWD_VI];
    [labelAuto setText:LOGIN_AUTO_VI];
    [loginBtn setTitle:LOGIN_BTN_VI forState:UIControlStateNormal];
    [labelNoti setText:LOGIN_NOTI_VI];
    [btnSummit setTitle:LOGIN_SUMMIT_VI forState:UIControlStateNormal];
    [idSearchLabel setText:LOGIN_ID_FIND_VI];
    [pwdSearchLabel setText:LOGIN_PWD_FIND_VI];
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
