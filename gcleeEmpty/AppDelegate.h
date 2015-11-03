//
//  AppDelegate.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "secondViewController.h"
#import "MMDrawerController.h"
#import "MYViewController.h"

//@class mainViewController;
#define IsAtLeastiOSVersion(X) ([[[UIDevice currentDevice] systemVersion] compare:X options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) MMDrawerController * drawerController;
//@property (strong, nonatomic) mainViewController *mainViewController;
@property (nonatomic, strong) MYViewController *introductionView;

@end

