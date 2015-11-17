//
//  setInforViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//


#import "setInforViewController.h"
#import "NavigationBarView.h"


@interface setInforViewController () <NavigationBarViewDelegate>
{
    NavigationBarView *navigationBarView;
}
@end


@implementation setInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self resetNavigationBarView:1];
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
