//
//  idResultViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 25..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol idResultViewControllerDelegate;

@interface idResultViewController : UIViewController

@property (nonatomic, weak) id<idResultViewControllerDelegate> delegate;

@end

@protocol idResultViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end