//
//  setInforViewController.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 17..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface setInforViewController : UIViewController <UITextFieldDelegate>

//@property (nonatomic,retain) UIPopoverController *popoverController;
@property (nonatomic,retain) UIDatePicker *datepicker;

-(BOOL)textFieldValueIsValid:(UITextField*)textField;
-(void)endEdit;

@end
