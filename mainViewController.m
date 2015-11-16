//
//  mainViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "mainViewController.h"
#import "secondViewController.h"
#import "leftMenuView.h"

@interface mainViewController ()

@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

@end
