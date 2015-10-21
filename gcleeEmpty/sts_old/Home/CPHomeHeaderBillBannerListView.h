//
//  CPHomeHeaderBillBannerListView.h
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHomeHeaderBillBannerListViewDelegate;

@interface CPHomeHeaderBillBannerListView : UIView

@property (nonatomic, weak) id <CPHomeHeaderBillBannerListViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end

@protocol CPHomeHeaderBillBannerListViewDelegate <NSObject>
@optional
- (void)homeHeaderBillBannerOnTouchButton;
@end
