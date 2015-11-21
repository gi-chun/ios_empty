//
//  personModifyViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "personModifyViewController.h"
#import "pwdChangeViewController.h"
#import "memberOutViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "SBJson.h"
#import "NavigationBarView.h"

@interface personModifyViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
    UITextField* currentEditingTextField;
    __weak IBOutlet UILabel *cardNmLabel;
    __weak IBOutlet UITextField *emailTxt;
    __weak IBOutlet UILabel *idLabel;

}
@end

@implementation personModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetNavigationBarView:1];
    [self setDelegateText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Navigation : viewDidLoad에서 한번, viewDidAppear에서 한번 더 한다.
    //[self.navigationItem setHidesBackButton:YES];
    [self resetNavigationBarView:1];
}

- (IBAction)emailSummit:(id)sender {
    
}

- (IBAction)pwdChange:(id)sender {
    
    pwdChangeViewController *pwdChangeController = [[pwdChangeViewController alloc] init];
    //[pwdChangeController setDelegate:self];
    
//    [self.navigationController pushViewController:pwdChangeController animated:YES];
//    [self.navigationController setNavigationBarHidden:NO];
    
//    MYDetailViewController *dvc = [[MYDetailViewController alloc] initWithNibName:@"MYDetailViewController" bundle:[NSBundle mainBundle]];
    [pwdChangeController setDelegate:self];
    
    [pwdChangeController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:pwdChangeController animated:YES completion:nil];

    
    //////
    /*
    MYDetailViewController *dvc = [[MYDetailViewController alloc] initWithNibName:@"MYDetailViewController" bundle:[NSBundle mainBundle]];
    [dvc setDelegate:self];
    [dvc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:dvc animated:YES completion:nil];
    
    
    -(void)dismiss
    {
        [self.presentingViewController dissmissViewControllerAnimated:YES completion:nil];
    }
     */
    
}

- (IBAction)memberOutClick:(id)sender {
    
    memberOutViewController *pwdChangeController = [[memberOutViewController alloc] init];
    //[pwdChangeController setDelegate:self];
    [self.navigationController pushViewController:pwdChangeController animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - text delegate
// Automatically register fields
-(void)setDelegateText
{
    [emailTxt setDelegate:self];
    
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
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:SETINFO_TITLE_KO];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
