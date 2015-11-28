//
//  pwdSearchViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 22..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol pwdSearchViewControllerDelegate;

@interface pwdSearchViewController : UIViewController

@property (nonatomic, weak) id<pwdSearchViewControllerDelegate> delegate;

@end

@protocol pwdSearchViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end