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
    
    completeViewController *completeCtl = [[completeViewController alloc] init];
    //[setInforCtl setDelegate:self];
    [self.navigationController pushViewController:completeCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];

    
}
- (IBAction)confirmID:(id)sender {
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
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:_datepicker.date]]);
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
