//
//  setAlramViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 25..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "setAlramViewController.h"
#import "NavigationBarView.h"

@interface setAlramViewController ()
{
    __weak IBOutlet UIButton *contentsButton;
    
    __weak IBOutlet UIButton *eventButton;
    __weak IBOutlet UILabel *eventLabel;
    __weak IBOutlet UILabel *titleLabel;
    
    __weak IBOutlet UILabel *contentsLabel;
     NavigationBarView *navigationBarView;
}
@end

@implementation setAlramViewController
- (IBAction)contentsBtnClick:(id)sender {
}
- (IBAction)eventBtnClick:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self resetNavigationBarView:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) type:navigationType title:@"아이디 찾기"];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
