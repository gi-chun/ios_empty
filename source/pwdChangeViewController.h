//
//  pwdChangeViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol pwdChangeViewControllerDelegate;

@interface pwdChangeViewController : UIViewController

@property (nonatomic, weak) id<pwdChangeViewControllerDelegate> delegate;

@end

@protocol pwdChangeViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end

