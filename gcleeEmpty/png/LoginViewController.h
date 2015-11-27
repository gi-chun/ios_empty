//
//  LoginViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LoginTypeDefault = 0,
    LoginTypeConfig
}MYLoginType;


@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
- (id)appDelegate;
- (void)autoLogin;
- (void)setLoginType;

@end

@protocol LoginViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
- (void)didLoginAfter;
@end
