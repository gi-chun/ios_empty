//
//  CPCategoryDetailViewController.h
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPCategoryDetailViewDelegate;

@interface CPCategoryDetailViewController : UIViewController

@property (nonatomic, weak) id<CPCategoryDetailViewDelegate> delegate;

- (id)initWithUrl:(NSString *)aUrl;

@end

@protocol CPCategoryDetailViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end