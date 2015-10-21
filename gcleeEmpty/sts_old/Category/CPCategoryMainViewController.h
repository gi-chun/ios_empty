//
//  CPCategoryMainViewController.h
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPCategoryMainViewDelegate;

@interface CPCategoryMainViewController : UIViewController

@property (nonatomic, weak) id<CPCategoryMainViewDelegate> delegate;

- (id)initWithUrl:(NSString *)aUrl;

@end

@protocol CPCategoryMainViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end