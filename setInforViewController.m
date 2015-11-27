//
//  setInforViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//


#import "setInforViewController.h"
#import "NavigationBarView.h"
#import "dataPickerViewController.h"
#import "completeViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"
#import "datePickerViewController.h"
#import "CPLoadingView.h"


@interface setInforViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
    UIView *yourDatePickerView;
    
    __weak IBOutlet UITextView *inforText;
    UITextField* currentEditingTextField;
    __weak IBOutlet UITextField *idText;
    __weak IBOutlet UITextField *nameText;
    __weak IBOutlet UITextField *pwdText;
    __weak IBOutlet UITextField *pwdCnfirmText;
    __weak IBOutlet UITextField *yearText;
    __weak IBOutlet UISwitch *okSwitch;
    __weak IBOutlet UILabel *labelInfor;
    __weak IBOutlet UILabel *labelID;
    __weak IBOutlet UILabel *labelName;
    
    __weak IBOutlet UILabel *labelYear;
    __weak IBOutlet UILabel *labelPwd;
    __weak IBOutlet UILabel *labelPwdCheck;
    __weak IBOutlet UIButton *btnSummit;
    
    __weak IBOutlet UIButton *confirmBtn;
    NSInteger isTwoChk;
    
    CPLoadingView *loadingView;
    
}

@end


@implementation setInforViewController

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

- (IBAction)btnSummitClick:(id)sender {
    
    if([idText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check ID please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
        return;
    }
    
    if([nameText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check Name please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
        return;
    }
    
    if([yearText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check input data please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
        return;
    }
    
    if([pwdText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check password please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
        return;
    }
    
    if([pwdCnfirmText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check password please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
        return;
    }
   
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [self startLoadingAnimation];

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
    
    NSString *strAgree;
    if ([okSwitch isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAgreeOk];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        strAgree = @"Y";
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAgreeOk];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        strAgree = @"N";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"동의 필요" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    if( isTwoChk == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"아이디 중복 확인필요" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
     [btnSummit setEnabled:false];
    
    //회원가입
    [rootDic setObject:@"" forKey:@"task"];
    [rootDic setObject:@"" forKey:@"action"];
    [rootDic setObject:@"M2000N" forKey:@"serviceCode"];
    [rootDic setObject:@"S_SNYM2000" forKey:@"requestMessage"];
    [rootDic setObject:@"R_SNYM2000" forKey:@"responseMessage"];
    
    [indiv_infoDic setObject:@"Y" forKey:@"agree_yn"];
    [indiv_infoDic setObject:idText.text forKey:@"email_id"];
    [indiv_infoDic setObject:pwdText.text forKey:@"pinno"];
    [indiv_infoDic setObject:nameText.text forKey:@"user_nm"];
    
    NSString* strParma = [yearText.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    [indiv_infoDic setObject:strParma forKey:@"birth"];
    [indiv_infoDic setObject:@"I" forKey:@"os_d"]; // ios -> I
    

    //생년월일, lang_c, push ..
    if([[NSUserDefaults standardUserDefaults] stringForKey:kUUID]){
        [indiv_infoDic setObject:[[NSUserDefaults standardUserDefaults] stringForKey:kUUID] forKey:@"tmn_unq_no"];
    }
    strParma = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    [indiv_infoDic setObject:strParma forKey:@"lang_c"];
    [indiv_infoDic setObject:@"" forKey:@"push_tmn_refno"]; //APNS
    strParma = ([[NSUserDefaults standardUserDefaults] stringForKey:kPushY])?[[NSUserDefaults standardUserDefaults] stringForKey:kPushY]:@"N";
    [indiv_infoDic setObject:@"N" forKey:@"push_rec_yn"];
    
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
        NSLog(@"Response ==> %@", responseData);
        
        //warning
        NSDictionary *dicItems = [dicResponse objectForKey:@"WARNING"];
        
        if(dicItems){
            NSString* sError = dicItems[@"msg"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:sError delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            
            
            //to json
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            
            NSString *jsonString = [jsonWriter stringWithObject:jsonArray];
            NSLog(@"jsonString ==> %@", jsonString);
            ///////////////////////////////
            
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
            {
                NSLog(@"name: '%@'\n",   [cookie name]);
                NSLog(@"value: '%@'\n",  [cookie value]);
                NSLog(@"domain: '%@'\n", [cookie domain]);
                NSLog(@"path: '%@'\n",   [cookie path]);
            }
            
            NSLog(@"getCookie end ==>" );
            
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [self stopLoadingAnimation];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"가입 완료" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            
            [alert show];
            
             [btnSummit setEnabled:true];
            
            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController setNavigationBarHidden:NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
         [btnSummit setEnabled:true];
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self stopLoadingAnimation];
        
    }];
    
//    completeViewController *completeCtl = [[completeViewController alloc] init];
//    //[setInforCtl setDelegate:self];
//    [self.navigationController pushViewController:completeCtl animated:YES];
//    [self.navigationController setNavigationBarHidden:NO];

    
}

- (IBAction)confirmID:(id)sender {
    
    if([idText.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Check ID please" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
        [alert show];
        [idText becomeFirstResponder];
        
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

    [confirmBtn setEnabled:false];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *indiv_infoDic = [NSMutableDictionary dictionary];
    
    //가입여부 - 중복확인
    [rootDic setObject:@"sfg.sunny.task.user.UserTask" forKey:@"task"];
    [rootDic setObject:@"getUserYn" forKey:@"action"];
    [rootDic setObject:@"" forKey:@"serviceCode"];
    [rootDic setObject:@"" forKey:@"requestMessage"];
    [rootDic setObject:@"" forKey:@"responseMessage"];
    
    [indiv_infoDic setObject:idText.text forKey:@"email_id"];
    
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
        NSLog(@"Response ==> %@", responseData);
        
        //warning
        NSDictionary *dicItems = [dicResponse objectForKey:@"WARNING"];
        
        if(dicItems){
            NSString* sError = dicItems[@"msg"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:sError delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            
            //to json
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            
            NSString *jsonString = [jsonWriter stringWithObject:jsonArray];
            NSLog(@"jsonString ==> %@", jsonString);
            ///////////////////////////////
            
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
            {
                NSLog(@"name: '%@'\n",   [cookie name]);
                NSLog(@"value: '%@'\n",  [cookie value]);
                NSLog(@"domain: '%@'\n", [cookie domain]);
                NSLog(@"path: '%@'\n",   [cookie path]);
            }
            
            NSLog(@"getCookie end ==>" );
            isTwoChk = 1;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"ID 등록가능" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            [alert show];
            
            [confirmBtn setEnabled:true];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        [confirmBtn setEnabled:true];
    }];
}

#pragma mark - text delegate
// Automatically register fields

-(void)setDelegateText
{
    [idText setDelegate:self];
    [nameText setDelegate:self];
    [pwdText setDelegate:self];
    [pwdCnfirmText setDelegate:self];
    [yearText setDelegate:self];
}

// UITextField Protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 3){
        
        [self.view endEditing:YES];
        
//        if(yourDatePickerView){
//            for (UIView *subView in yourDatePickerView.subviews) {
//                [subView removeFromSuperview];
//            }
//            [yourDatePickerView removeFromSuperview];
//        }
//        yourDatePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenBoundsHeight-250, kScreenBoundsWidth, 250)];
//        [yourDatePickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
//        //date picker
//        _datepicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, kScreenBoundsHeight-200*3, kScreenBoundsWidth, 200)];
//        _datepicker.datePickerMode = UIDatePickerModeDate;
//        _datepicker.hidden = NO;
//        _datepicker.date = [NSDate date];
//        [_datepicker addTarget:self action:@selector(LabelChange:) forControlEvents:UIControlEventValueChanged];
//        [yourDatePickerView addSubview:_datepicker];
//        //close button
//        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [closeButton setFrame:CGRectMake(0, kScreenBoundsHeight-600, kScreenBoundsWidth, 50)];
//        [closeButton setBackgroundColor:[UIColor clearColor]];
//        [closeButton setBackgroundImage:[UIImage imageNamed:@"login_btn_press.png"] forState:UIControlStateHighlighted];
//        [closeButton setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
//        [closeButton addTarget:self action:@selector(dateCloseBtn) forControlEvents:UIControlEventTouchUpInside];
//        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
//        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
//        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        [yourDatePickerView addSubview:closeButton];
//        [self showView];

        datePickerViewController *myPickerController = [[datePickerViewController alloc] init];
        [myPickerController setDelegate:self];
        
        [myPickerController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:myPickerController animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

- (void)didTouchPicker
{
    [yearText setText: [[NSUserDefaults standardUserDefaults] stringForKey:kYYYYMMDD]];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentEditingTextField = textField;
    
    
}

- (void) dateCloseBtn
{
    [self hideView];
}

- (void) showView
{
    //CGRectMake(0, kScreenBoundsHeight-500, kScreenBoundsWidth, 500)
    //(0, -250, 320, 50);
    //(0, 152, 320, 260);
    
    [self.view addSubview:yourDatePickerView];
    yourDatePickerView.frame = CGRectMake(0, kScreenBoundsHeight-250, kScreenBoundsWidth, 250);
    [UIView animateWithDuration:1.0
                     animations:^{
                         yourDatePickerView.frame = CGRectMake(0, kScreenBoundsHeight-250, kScreenBoundsWidth, 250);
                     }];
}

- (void) hideView
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         yourDatePickerView.frame = CGRectMake(0, kScreenBoundsHeight-250, kScreenBoundsWidth, 250);
                     } completion:^(BOOL finished) {
                         [yourDatePickerView removeFromSuperview];
                     }];
}


-(void)dateSave:(id)sender
{
    self.navigationItem.rightBarButtonItem=nil;
    [_datepicker removeFromSuperview];
}

-(void)LabelChange:(id)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateStyle = NSDateFormatterMediumStyle;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyymmdd"];
    NSString *date = [dateFormat stringFromDate:_datepicker.date];
    NSLog(@"date is >>> , %@",date);
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:_datepicker.date]]);
   
    //[yearText setText: [df stringFromDate:_datepicker.date]];
    [yearText setText: date];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    currentEditingTextField = NULL;
    
    if(textField.tag == 3){
       [self hideView];
    }
    
    [self hideView];
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField.tag == 4 || textField.tag == 5){
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

-(BOOL)textFieldValueIsValid:(UITextField*)textField
{
    return YES;
}

-(void)initScreenView{
    
//    __weak IBOutlet UITextView *inforText;
//    UITextField* currentEditingTextField;
//    __weak IBOutlet UITextField *idText;
//    __weak IBOutlet UITextField *nameText;
//    __weak IBOutlet UITextField *pwdText;
//    __weak IBOutlet UITextField *pwdCnfirmText;
//    __weak IBOutlet UITextField *yearText;
//    __weak IBOutlet UISwitch *okSwitch;
//    __weak IBOutlet UILabel *labelInfor;
//    __weak IBOutlet UILabel *labelID;
//    __weak IBOutlet UILabel *labelName;
//    
//    __weak IBOutlet UILabel *labelYear;
//    __weak IBOutlet UILabel *labelPwd;
//    __weak IBOutlet UILabel *labelPwdCheck;
//    __weak IBOutlet UIButton *btnSummit;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    isTwoChk = 0;
    [pwdText setKeyboardType:UIKeyboardTypeNumberPad ];
    [pwdCnfirmText setKeyboardType:UIKeyboardTypeNumberPad ];
    
    [self resetNavigationBarView:1];
    [self initSetItem];
    [self setDelegateText];
    
    idText.text = [[NSUserDefaults standardUserDefaults] stringForKey:kId] ;
    nameText.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNm] ;
    
    NSString* temp;
    temp = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    if([temp isEqualToString:@"ko"]){
        [self initScreenView_ko];
    }else if([temp isEqualToString:@"vi"]){
        [self initScreenView_vi];
    }else{
        temp = @"EN";
    }
    
    [idText becomeFirstResponder];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //[self.navigationItem setHidesBackButton:YES];
    [self resetNavigationBarView:1];
    [self initSetItem];

    
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
        navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:SETINFO_TITLE_KO];
        [navigationBarView setDelegate:self];
    }else if([temp isEqualToString:@"vi"]){
        navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:SETINFO_TITLE_VI];
        [navigationBarView setDelegate:self];
    }else{
        temp = @"EN";
    }

    
    
    
    return navigationBarView;
}

#pragma mark - inner fuction

- (void)initSetItem
{
    [inforText setContentOffset:CGPointZero animated:YES];
    [[self view]endEditing:YES];
    
}

#pragma mark - CPNavigationBarViewDelegate

- (void)didTouchBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
    
//    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
//        [self.delegate didTouchBackButton];
//    }
}

#pragma mark -initScreenView
-(void)initScreenView_ko{
    
    [self resetNavigationBarView:1];
    [inforText setText:SETINFO_TEXT_KO];
    [labelInfor setText:SETINFO_AGREE_KO];
    [labelID setText:SETINFO_ID_KO];
    [labelName setText:SETINFO_NAME_KO];
    [labelYear setText:SETINFO_YEAR_KO];
    [labelPwd setText:SETINFO_PWD_KO];
    [labelPwdCheck setText:SETINFO_PWDCON_KO];
    [btnSummit setTitle:SETINFO_CONFIRM_KO forState:UIControlStateNormal];
    [confirmBtn setTitle:SETINFO_CONFIRM_KO forState:UIControlStateNormal];
    [btnSummit setTitle:LOGIN_SUMMIT_KO forState:UIControlStateNormal];
    
}

-(void)initScreenView_vi{
    
    [self resetNavigationBarView:1];
    [inforText setText:SETINFO_TEXT_VI];
    [labelInfor setText:SETINFO_AGREE_VI];
    [labelID setText:SETINFO_ID_VI];
    [labelName setText:SETINFO_NAME_VI];
    [labelYear setText:SETINFO_YEAR_VI];
    [labelPwd setText:SETINFO_PWD_VI];
    [labelPwdCheck setText:SETINFO_PWDCON_VI];
    [btnSummit setTitle:SETINFO_CONFIRM_VI forState:UIControlStateNormal];
    [confirmBtn setTitle:SETINFO_CONFIRM_VI forState:UIControlStateNormal];
    [btnSummit setTitle:LOGIN_SUMMIT_VI forState:UIControlStateNormal];
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
