//
//  personModifyViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 21..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol personModifyViewControllerDelegate;

@interface personModifyViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<personModifyViewControllerDelegate> delegate;

-(BOOL)textFieldValueIsValid:(UITextField*)textField;
-(void)endEdit;

@end

@protocol personModifyViewControllerDelegate <NSObject>
@optional
- (void)didTouchBackButton;
@end
