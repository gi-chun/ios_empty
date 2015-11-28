//
//  setAlramViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 25..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol setAlramViewControllerDelegate;

@interface setAlramViewController : UIViewController

@property (nonatomic, weak) id<setAlramViewControllerDelegate> delegate;

@end

@protocol setAlramViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end
