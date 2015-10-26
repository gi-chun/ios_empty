//
//  secondViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 26..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "secondViewController.h"
#import "NavigationBarView.h"

@interface secondViewController () <NavigationBarViewDelegate>

@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadContentsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContentsView
{
    for (UIView *subView in [self.view subviews]) {
        [subView removeFromSuperview];
    }
    
    if (self.navigationController.navigationBar.isHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2, 36, 36)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_login.png"] forState:UIControlStateHighlighted];
    [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
    //[menuButton setAccessibilityLabel:@"메뉴" Hint:@"왼쪽 메뉴로 이동합니다"];
    [self.view addSubview:menuButton];
    
    //    self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+10, 4, 54, 36)];
    //    [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_nor.png"] forState:UIControlStateNormal];
    //    [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_press.png"] forState:UIControlStateHighlighted];
    //    [self.logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
    //    [self.logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
    //    [self addSubview:self.logoButton];
    
    //    UIImage *searchImage = [UIImage imageNamed:@"gnb_search_bg.png"];
    //    searchImage = [searchImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchImage.size.height / 2, searchImage.size.width / 2, searchImage.size.height / 2, searchImage.size.width / 2)];
    //
    //    UIImageView *searchBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.logoButton.frame)+6, 4, kScreenBoundsWidth-206, 36)];
    //    [searchBackgroundImageView setImage:searchImage];
    //    [searchBackgroundImageView setUserInteractionEnabled:YES];
    //    [self addSubview:searchBackgroundImageView];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(reloadHomeTab)
    //                                                 name:ReloadHomeNotification
    //                                               object:nil];
    
}

- (void)touchMenuButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"ok ^^"                                             delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)initNavigation:(NSInteger)navigationType
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[NavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [self.navigationController.navigationBar addSubview:[self navigationBarView:1]];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
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
