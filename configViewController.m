//
//  configViewController.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 18..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "configViewController.h"

@interface configViewController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end

@implementation configViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.
//    for (UIView *subView in self.view) {
//        
//        if ([subView isKindOfClass:[NavigationBarView class]]) {
//            [subView removeFromSuperview];
//        }
//    }

    [self.myScrollView addSubview:self.contentView];
    self.myScrollView.contentSize = self.contentView.frame.size;
    //((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*
     - (void)viewDidLoad {
     [super viewDidLoad];
     [self.view addSubview:self.contentView];
     ((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
     }

     - (void)viewDidUnload {
     self.contentView = nil;
     [super viewDidUnload];
     }
     
     */
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
