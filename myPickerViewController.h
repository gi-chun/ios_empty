//
//  myPickerViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 22..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol myPickerViewControllerDelegate;

@interface myPickerViewController : UIViewController

@property (nonatomic, weak) id<myPickerViewControllerDelegate> delegate;


@end

@protocol myPickerViewControllerDelegate <NSObject>
@optional
- (void)didTouchPicker;
@end
