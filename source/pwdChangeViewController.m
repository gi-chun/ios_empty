//
//  pwdChangeViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "pwdChangeViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"
#import "NavigationBarView.h"

@interface pwdChangeViewController ()
{
    NavigationBarView *navigationBarView;
    UITextField* currentEditingTextField;
    __weak IBOutlet UITextField *confirmTxt;
    __weak IBOutlet UITextField *newPwdTxt;
    __weak IBOutlet UITextField *oldPwdTxt;
}
@end

@implementation pwdChangeViewController

- (IBAction)saveClick:(id)sender {
    
    if([confirmTxt.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check Password please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [confirmTxt becomeFirstResponder];
        
        return;
    }
    if([newPwdTxt.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check Password please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [newPwdTxt becomeFirstResponder];
        
        return;
    }
    if([oldPwdTxt.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check Password please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [oldPwdTxt becomeFirstResponder];
        
        return;
    }
    
    if( ![newPwdTxt.text isEqualToString:confirmTxt.text] ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check Password ! input value different" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [newPwdTxt becomeFirstResponder];
        
        return;
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
    
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"M2020N" forKey:@"serviceCode"];
    [rootDic setObject:@"S_SNYM2020" forKey:@"requestMessage"];
    [rootDic setObject:@"S_SNYM2020" forKey:@"responseMessage"];
    
    //회원번호
    //아이디
    //단말기고유번고
    //변경전 PIN
    //변경후 PIN
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:kCardCode]){
        [indiv_infoDic setObject:[[NSUserDefaults standardUserDefaults] stringForKey:kCardCode] forKey:@"user_seq"];
    }
    if([[NSUserDefaults standardUserDefaults] stringForKey:kId]){
        [indiv_infoDic setObject:[[NSUserDefaults standardUserDefaults] stringForKey:kEmail_id] forKey:@"email_id"];
    }
    if([[NSUserDefaults standardUserDefaults] stringForKey:kUUID]){
        [indiv_infoDic setObject:[[NSUserDefaults standardUserDefaults] stringForKey:kUUID] forKey:@"tmn_unq_no"];
    }
    [indiv_infoDic setObject:oldPwdTxt.text forKey:@"bf_pinno"];
    [indiv_infoDic setObject:newPwdTxt.text forKey:@"af_pinno"];
    
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
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:sError delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            
            //to json
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            NSString *jsonString = [jsonWriter stringWithObject:jsonArray];
            NSLog(@"jsonString ==> %@", jsonString);
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            NSHTTPCookie *cookie;
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:@"locale_" forKey:NSHTTPCookieName];
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"비밀번호변경 완료" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            
            //set kCardCode
            [[NSUserDefaults standardUserDefaults] setObject:newPwdTxt.text forKey:kPwd];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //emailTxt.text = strEmail;
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Fail %@", error] delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];

    
     //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetNavigationBarView:1];
    [self setDelegateText];
    
    [confirmTxt setKeyboardType:UIKeyboardTypeNumberPad ];
    [newPwdTxt setKeyboardType:UIKeyboardTypeNumberPad ];
    [oldPwdTxt setKeyboardType:UIKeyboardTypeNumberPad ];
    
    [oldPwdTxt setText:[[NSUserDefaults standardUserDefaults] stringForKey:kPwd]];
}
/////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //[self.navigationItem setHidesBackButton:YES];
    [self resetNavigationBarView:1];
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - text delegate
// Automatically register fields
-(void)setDelegateText
{
    [confirmTxt setDelegate:self];
    [newPwdTxt setDelegate:self];
    [oldPwdTxt setDelegate:self];
}
// UITextField Protocol
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentEditingTextField = textField;
}
-(void)dateSave:(id)sender
{
    self.navigationItem.rightBarButtonItem=nil;
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
    
    if(textField.tag == 1 || textField.tag == 2 || textField.tag == 3){
        if (textField.text.length >= PWD_MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else if(textField.text.length >= PWD_MAX_LENGTH && range.length == 0){
            
            return NO; // return NO to not change text
        }
    }
    
    return YES;
    
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

/////////////////////////////////////////////////////////////////////
//navigation
#pragma mark - CPNavigationBarView
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
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:@"비밀번호 변경"];
    [navigationBarView setDelegate:self];
    
    return navigationBarView;
}

- (void)didTouchBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
    //        [self.delegate didTouchBackButton];
    //    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -initScreenView
-(void)initScreenView_ko{
    
//    [self resetNavigationBarView:1];
//    [idLabel setText:LOGIN_ID_KO];
//    [pwdLabel setText:LOGIN_PWD_KO];
//    [labelAuto setText:LOGIN_AUTO_KO];
//    [loginBtn setTitle:LOGIN_BTN_KO forState:UIControlStateNormal];
//    [labelNoti setText:LOGIN_NOTI_KO];
//    [btnSummit setTitle:LOGIN_SUMMIT_KO forState:UIControlStateNormal];
//    [idSearchLabel setText:LOGIN_ID_FIND_KO];
//    [pwdSearchLabel setText:LOGIN_PWD_FIND_KO];
    
}

-(void)initScreenView_vi{
    
//    [self resetNavigationBarView:1];
//    [idLabel setText:LOGIN_ID_VI];
//    [pwdLabel setText:LOGIN_PWD_VI];
//    [labelAuto setText:LOGIN_AUTO_VI];
//    [loginBtn setTitle:LOGIN_BTN_VI forState:UIControlStateNormal];
//    [labelNoti setText:LOGIN_NOTI_VI];
//    [btnSummit setTitle:LOGIN_SUMMIT_VI forState:UIControlStateNormal];
//    [idSearchLabel setText:LOGIN_ID_FIND_VI];
//    [pwdSearchLabel setText:LOGIN_PWD_FIND_VI];
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
