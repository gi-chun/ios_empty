//
//  AppDelegate.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "AppDelegate.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface AppDelegate ()
{
    UINavigationController  *_navigation;
}
@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    //MYViewController *introductionView = [[MYViewController alloc] init];
    self.introductionView = [[MYViewController alloc] init];
    self.introductionView.delegate = self;
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
//                                          green:173.0/255.0
//                                           blue:234.0/255.0
//                                          alpha:1.0];
//    [self.window setTintColor:tintColor];
    
    //[self.window addSubview:_introductionView.view];
    
    [self.window setRootViewController:self.introductionView];
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //////////////////////////////////////////////////////////////////////////////
    // 앱의 푸쉬 수신여부 설정
//    if (IsAtLeastiOSVersion(@"8.0")) {
//        UIUserNotificationType types = UIUserNotificationTypeBadge |
//        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//        
//        UIUserNotificationSettings *mySettings =
//        [UIUserNotificationSettings settingsForTypes:types categories:nil];
//        
//        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//        
//    }else{
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//    }
    
    
     //////////////////////////////////////////////////////////////////////////////
    
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor magentaColor];
//    [self.window makeKeyAndVisible];
    
//    SplashViewController *splashVC = [[SplashViewController alloc] initWithNibName:NibName(@"SplashViewController") bundle:nil];
//    _navigation = [[UINavigationController alloc] initWithRootViewController:splashVC];
    
//    mainViewController *mainViewCnr = [[mainViewController alloc] init];
//    _navigation = [[UINavigationController alloc] initWithRootViewController:mainViewCnr];
//    [_navigation setNavigationBarHidden:YES];
//    
//    self.window.rootViewController = _navigation;
//    [self.window makeKeyAndVisible];

    //    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - APNS Notification Regist Results
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"APNS 디바이스 토큰 등록 성공 : %@", deviceToken);
    //[[SettingManager sharedInstance] setDeviceToken:[NSString stringWithFormat:@"%@", deviceToken]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"APNS 디바이스 토큰 등록 실패 : %@", error);
}

#pragma mark - Recieve Push Notifications
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 포그라운드에서의 푸쉬 처리
    [self receiveRemoteNotification:userInfo withAppState:YES];
}

- (void)receiveRemoteNotification:(NSDictionary *)info withAppState:(BOOL)onForeground
{
    NSLog(@"푸쉬 들어옴 %@", info);
    // 데이터가 없는 경우는 처리하지 않는다
    if (!info)
        return;
    
//    _pushOpenUrl = @"";
//    
//    // 앱 실행중일 떄
//    if (onForeground) {
//        
//        _pushOpenUrl = [info objectForKey:@"linkUrl"];
//        
//        if ([_pushOpenUrl rangeOfString:@"mail."].location != NSNotFound) {
//            
//            _pushOpenUrl = [_pushOpenUrl stringByReplacingOccurrencesOfString:@"mail."
//                                                                   withString:@"mmail."];
//            
//        }
//        
//        // url이 없는 경우
//        if ([_pushOpenUrl isEqualToString:@""] || !_pushOpenUrl) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[info objectForKey:@"aps"] objectForKey:@"alert"]
//                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//        
//        // url이 있는 경우
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[info objectForKey:@"aps"] objectForKey:@"alert"]
//                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"열기", nil];
//            [alert show];
//            
//            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_pushOpenUrl
//            //                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"열기", nil];
//            //            [alert show];
//            
//            
//        }
//    }
//    
//    // 앱 실행중이 아닐 때
//    else {
//        _pushOpenUrl = [[info objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"linkUrl"];
//        
//        if ([_pushOpenUrl rangeOfString:@"mail."].location != NSNotFound) {
//            
//            _pushOpenUrl = [_pushOpenUrl stringByReplacingOccurrencesOfString:@"mail."
//                                                                   withString:@"mmail."];
//            
//        }
//        
//        [self pushAction];
//    }
}

#pragma mark - Intro
- (void)didFinishIntro
{
    NSLog(@"finish intro ");
    
    UIViewController * leftSideDrawerViewController = [[mainViewController alloc] init];
    UIViewController * centerViewController = [[secondViewController alloc] init];
    
    //    UIViewController * rightSideDrawerViewController = [[MMExampleRightSideDrawerViewController alloc] init];
    
    //    UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:centerViewController];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    
    //    UINavigationController * rightSideNavController = [[UINavigationController alloc] initWithRootViewController:rightSideDrawerViewController];
    //    [rightSideNavController setRestorationIdentifier:@"MMExampleRightNavigationControllerRestorationKey"];
    
    UINavigationController * leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
    [leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:navigationController
                             leftDrawerViewController:leftSideNavController
                             rightDrawerViewController:nil];
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumRightDrawerWidth:150.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    [self.window setRootViewController:self.drawerController];
}



@end
