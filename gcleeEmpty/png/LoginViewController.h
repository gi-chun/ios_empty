//
//  LoginViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end
