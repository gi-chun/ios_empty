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
    
}

@end


@implementation setInforViewController

- (IBAction)btnSummitClick:(id)sender {
    
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
    [indiv_infoDic setObject:@"11111111111" forKey:@"tmn_unq_no"];
    strParma = [[NSUserDefaults standardUserDefaults] stringForKey:klang];
    [indiv_infoDic setObject:strParma forKey:@"lang_c"];
    [indiv_infoDic setObject:@"APNS" forKey:@"push_tmn_refno"];
    strParma = ([[NSUserDefaults standardUserDefaults] stringForKey:kPushY])?[[NSUserDefaults standardUserDefaults] stringForKey:kPushY]:@"N";
    [indiv_infoDic setObject:strParma forKey:@"push_rec_yn"];
    
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"가입 완료" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
    completeViewController *completeCtl = [[completeViewController alloc] init];
    //[setInforCtl setDelegate:self];
    [self.navigationController pushViewController:completeCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];

    
}

- (IBAction)confirmID:(id)sender {
    
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
    
    [indiv_infoDic setObject:@"springgclee@gmail.com" forKey:@"email_id"];
    
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
        ///////////////////////////////
        
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            NSLog(@"name: '%@'\n",   [cookie name]);
            NSLog(@"value: '%@'\n",  [cookie value]);
            NSLog(@"domain: '%@'\n", [cookie domain]);
            NSLog(@"path: '%@'\n",   [cookie path]);
        }
        
        NSLog(@"getCookie end ==>" );
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
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
        
        if(yourDatePickerView){
            for (UIView *subView in yourDatePickerView.subviews) {
                [subView removeFromSuperview];
            }
            
            [yourDatePickerView removeFromSuperview];
        }
        
        yourDatePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenBoundsHeight-250, kScreenBoundsWidth, 250)];
        
        [yourDatePickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
        
        
        //date picker
        _datepicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, kScreenBoundsHeight-200*3, kScreenBoundsWidth, 200)];
        _datepicker.datePickerMode = UIDatePickerModeDate;
        _datepicker.hidden = NO;
        _datepicker.date = [NSDate date];
        [_datepicker addTarget:self action:@selector(LabelChange:) forControlEvents:UIControlEventValueChanged];
        [yourDatePickerView addSubview:_datepicker];
        
        //close button
        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0, kScreenBoundsHeight-600, kScreenBoundsWidth, 50)];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"login_btn_press.png"] forState:UIControlStateHighlighted];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(dateCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [yourDatePickerView addSubview:closeButton];
        
        [self showView];
        return NO;
    }
    
    return YES;
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

-(BOOL)textFieldValueIsValid:(UITextField*)textField
{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetNavigationBarView:1];
    [self initSetItem];
    [self setDelegateText];
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
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:SETINFO_TITLE_KO];
    [navigationBarView setDelegate:self];
    
    
    
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
