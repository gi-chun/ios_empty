//
//  memberOutViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol memberOutViewControllerDelegate;

@interface memberOutViewController : UIViewController

@property (nonatomic, weak) id<memberOutViewControllerDelegate> delegate;

@end

@protocol memberOutViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end