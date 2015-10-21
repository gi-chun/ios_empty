//
//  CPContactViewController.h
//  11st
//
//  Created by spearhead on 2014. 12. 1..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPContactViewControllerDelegate;

@interface CPContactViewController : UIViewController

@property (nonatomic, weak) id<CPContactViewControllerDelegate> delegate;

- (id)initWithContact:(NSDictionary *)contact;

@end

@protocol CPContactViewControllerDelegate <NSObject>
@optional
- (void)didTouchContactConfirmButton:(NSString *)jsonData;
@end