//
//  CPHomeHeaderView.h
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHomeHeaderViewDelegate;

@interface CPHomeHeaderView : UIView

@property (nonatomic, weak) id <CPHomeHeaderViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item;
@end

@protocol CPHomeHeaderViewDelegate <NSObject>
@optional
- (void)resizeHomeHeaderViewFrame:(CGSize)viewSize;
- (void)homeHeaderBillBannerOnTouchButton;
@end