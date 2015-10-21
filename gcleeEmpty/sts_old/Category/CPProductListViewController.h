//
//  CPProductListViewController.h
//  11st
//
//  Created by spearhead on 2015. 5. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductListViewDelegate;

@interface CPProductListViewController : UIViewController

@property (nonatomic, weak) id<CPProductListViewDelegate> delegate;

- (id)initWithKeyword:(NSString *)keyword referrer:(NSString *)referrer;
- (id)initWithUrl:(NSString *)aUrl keyword:(NSString *)keyword referrer:(NSString *)referrer;

@end

@protocol CPProductListViewDelegate <NSObject>
@optional
- (void)touchSearchProductAjaxCall:(id)sender;
- (void)touchSearchProductBannerAjaxCall:(id)sender;
@end