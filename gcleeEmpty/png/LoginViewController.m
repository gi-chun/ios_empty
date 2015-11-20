//
//  LoginViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "LoginViewController.h"
#import "NavigationBarView.h"
#import "setInforViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"

@interface LoginViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
    UITextField* currentEditingTextField;
    __weak IBOutlet UIButton *loginBtn;
    __weak IBOutlet UITextField *txtID;
    __weak IBOutlet UITextField *txtPwd;
    __weak IBOutlet UISwitch *switchAuto;
    __weak IBOutlet UILabel *labelAuto;
    __weak IBOutlet UIButton *btnIDSearch;
    __weak IBOutlet UIButton *btnPwdSearch;
    __weak IBOutlet UILabel *labelNoti;
    __weak IBOutlet UIButton *btnSummit;
    
}
@end

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //[self.navigationItem setHidesBackButton:YES];
    [self resetNavigationBarView:1];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self resetNavigationBarView:1];
    [self setDelegateText];
    
}
- (IBAction)setInforClick:(id)sender {
    
    setInforViewController *setInforCtl = [[setInforViewController alloc] init];
    //[setInforCtl setDelegate:self];
    [self.navigationController pushViewController:setInforCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)loginBtnClick:(id)sender {
    
   
    
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
    
    [indiv_infoDic setObject:@"springgclee@gmail.com" forKey:@"email_id"];
    [indiv_infoDic setObject:@"1111" forKey:@"pinno"];
    
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
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
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:LOGIN_TITLE_KO];
    [navigationBarView setDelegate:self];
    
   
    
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

    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
        [self.delegate didTouchBackButton];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
