//
//  configViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 18..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBarView.h"

@protocol configViewControllerDelegate;

@interface configViewController : UIViewController
@property (nonatomic) NavigationBarView *navigationBarView;
@property (nonatomic, weak) id<configViewControllerDelegate> delegate;
@property (nonatomic) NSString *preLang;

@end

@protocol configViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
- (void)didTouchHelpButton;
- (void)didTouchNewButton;
- (void)didLoginAfter;
@end

