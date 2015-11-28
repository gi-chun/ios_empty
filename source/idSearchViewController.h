//
//  idSearchViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol idSearchViewControllerDelegate;

@interface idSearchViewController : UIViewController

@property (nonatomic, weak) id<idSearchViewControllerDelegate> delegate;

@end

@protocol idSearchViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end
