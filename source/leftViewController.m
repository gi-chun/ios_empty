//
//  leftViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "UIViewController+MMDrawerController.h"
#import "leftViewController.h"
#import "secondViewController.h"
#import "leftMenuView.h"
#import "LoginViewController.h"
#import "configViewController.h"
#import "amsLibrary.h"

@interface leftViewController ()

@end

@implementation leftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    amsLibrary *ams = [[amsLibrary alloc] init];
//    NSInteger result = [ams a3142:@"AHN_3379024345_TK"]; //AHN_3379024345_TK, 201 크면 안되면
//    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
//    NSInteger roundedValue = round(interval);
//    
//    NSLog(@"Jailbreak Result : %ld" , (long)result);
//    NSLog(@"time interval  : %ld" , (long)roundedValue);
//    NSLog(@"checking Result : %ld" , (long)(result - roundedValue));
//    NSInteger lastResult = (result - roundedValue);
//    
//    if(lastResult > 200)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"This App Jailbreak phone NO Service. App Stop" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//        [alert show];
//        
//        UIApplication *app = [UIApplication sharedApplication];
//        [app performSelector:@selector(suspend)];
//        
//        //wait 2 seconds while app is going background
//        [NSThread sleepForTimeInterval:2.0];
//        //exit app when app is in background
//        
//        exit(0);
//    }

    
    [self loadContentsView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    if (self.navigationController.navigationBar.isHidden) {
//        [self.navigationController setNavigationBarHidden:YES];
//    }
    [self.navigationController setNavigationBarHidden:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchMenuButton
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"ok ^^"                                             delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
//    [alert show];
    
    secondViewController *seconViewCtl = [[secondViewController alloc] init];
    [self.navigationController pushViewController:seconViewCtl animated:YES];
}

- (void)setViewLogin
{
    
    [self loadContentsView];
}

- (void)setViewLogout
{
    [self setDataAfterlogout];
    [self loadContentsView];
}


- (void) setDataAfterlogout
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:klang];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kAutoLogin];
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
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kLoginY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kCardCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kAgreeOk];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kPushY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kYYYYMMDD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kCurrentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUpdateVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kTutoY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (void)loadContentsView
{
    for (UIView *subView in [self.view subviews]) {
        [subView removeFromSuperview];
    }
    
//    if (self.navigationController.navigationBar.isHidden) {
//        [self.navigationController setNavigationBarHidden:YES];
//    }
    [self.navigationController setNavigationBarHidden:YES];
    
    //[self.view setBackgroundColor:[UIColor blueColor]];
    
    //150.0
//    leftMenuView* menuView = [[leftMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-150.0, kScreenBoundsHeight)];
    
    leftMenuView* menuView = [[leftMenuView alloc] initWithFrame:self.view.frame];
    [menuView setDelegate:self];
    [self.view addSubview:menuView];
    
//    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [menuButton setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2, 36, 36)];
//    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
//    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_login.png"] forState:UIControlStateHighlighted];
//    [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
//    //[menuButton setAccessibilityLabel:@"메뉴" Hint:@"왼쪽 메뉴로 이동합니다"];
//    [self.view addSubview:menuButton];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - total menu delegate

- (void)didTouchMenuItem:(NSInteger)menuType
{
    //#1 Sunny Club
    //#2 Sunny Bank
    //#3 Event / 공지
    //#4 설정
    
//    configViewController* configController = [[configViewController alloc] init];
//    //[loginController setDelegate:self];
//    [self.navigationController pushViewController:configController animated:YES];
//    [self.navigationController setNavigationBarHidden:NO];
    
    
    //[self.mm_drawerController toggleDrawerSide:MMDrawerSideNone animated:YES completion:nil];
    [self.mm_drawerController closeDrawerAnimated:true completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(didTouchMenuItem:)]) {
        [self.delegate didTouchMenuItem:menuType];
    }
    
//    NSString *strMenuType = [NSString stringWithFormat:@"didTouchMenuItem menuType %d", menuType];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:strMenuType delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//    [alert show];
//    
//    //setting
//    if(menuType == 4){
//        LoginViewController *loginController = [[LoginViewController alloc] init];
//        //[loginController setDelegate:self];
//        [self.navigationController pushViewController:loginController animated:YES];
//        [self.navigationController setNavigationBarHidden:NO];
//        
//    }
}

- (void)didTouchCloseBtn
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"didTouchCloseBtn" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//    [alert show];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCloseBtn)]) {
        [self.delegate didTouchCloseBtn];
    }
    
}

- (void)didTouchLogOutBtn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"didTouchLogOutBtn" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)didTouchLogInBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogOutBtn)]) {
        [self.delegate didTouchLogInBtn];
    }
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"didTouchLogInBtn" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//    [alert show];
    
}

- (void)didTouchAD
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"didTouchAD" delegate:self cancelButtonTitle:@"close" otherButtonTitles:nil, nil];
//    [alert show];
    
    [self.mm_drawerController closeDrawerAnimated:true completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(didTouchAD)]) {
        [self.delegate didTouchAD];
    }
    
}

@end
