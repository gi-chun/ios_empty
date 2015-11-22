//
//  datePickerViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 22..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBarView.h"

@protocol datePickerViewControllerDelegate;

@interface datePickerViewController : UIViewController

@property (nonatomic, weak) id<datePickerViewControllerDelegate> delegate;

@end

@protocol datePickerViewControllerDelegate <NSObject>
@optional
- (void)didTouchPicker;
@end

