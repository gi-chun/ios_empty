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
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *realMainView;
@property (weak, nonatomic) IBOutlet UIScrollView *realScrollView;

@end

@implementation configViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *subView in [self.view subviews]) {
        [subView setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];
    // Do any additional setup after loading the view from its nib.
//    self.
//    for (UIView *subView in self.view) {
//        
//        if ([subView isKindOfClass:[NavigationBarView class]]) {
//            [subView removeFromSuperview];
//        }
//    }

    
//    CGFloat marginY = (kScreenBoundsWidth > 320)?100:0;
//    [self.mainView setFrame:CGRectMake(0+marginY, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
////    [self.myScrollView setFrame:CGRectMake(0,0+marginY,kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
//    
//    [self.myScrollView addSubview:self.contentView];
//    self.myScrollView.contentSize = self.contentView.frame.size;
//    self.myScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height+100);
//    //((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?25:0;
    CGFloat marginY = (kScreenBoundsWidth > 320)?70:0;
    
    if(kScreenBoundsWidth > 320){
        
        [self.realScrollView addSubview:self.contentView];
        self.realScrollView.contentSize = self.contentView.frame.size;
        self.realScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height);
        
        [self.realMainView addSubview:self.realScrollView];
        
        [self.mainView addSubview:self.realMainView];
        [self.realMainView setFrame:CGRectMake(0+marginX, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        
        for (UIView *subView in [self.view subviews]) {
            [subView setBackgroundColor:UIColorFromRGB(0xffffff)];
        }
        
        [self.view setBackgroundColor:UIColorFromRGB(0xffffff)];

    }else{
        
        //CGFloat marginY = (kScreenBoundsWidth > 320)?100:0;
        //[self.mainView setFrame:CGRectMake(0+marginY, 0+marginY, kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        //    [self.myScrollView setFrame:CGRectMake(0,0+marginY,kScreenBoundsWidth, kScreenBoundsHeight-marginY)];
        
        [self.myScrollView addSubview:self.contentView];
        self.myScrollView.contentSize = self.contentView.frame.size;
        self.myScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height+150);
        //((UIScrollView *)self.view).contentSize = self.contentView.frame.size;
        
    }
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
