//
//  CPMartSearchViewController.h
//  11st
//
//  Created by spearhead on 2015. 3. 31..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPMartSearchViewControllerDelegate;

@interface CPMartSearchViewController : UIViewController

@property (nonatomic, weak) id<CPMartSearchViewControllerDelegate> delegate;

@end

@protocol CPMartSearchViewControllerDelegate <NSObject>
@optional

- (void)martSearchWithKeyword:(NSString *)keyword;

@end