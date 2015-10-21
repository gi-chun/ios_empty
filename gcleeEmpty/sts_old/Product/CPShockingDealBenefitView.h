//
//  CPShockingDealBenefitView.h
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface CPShockingDealBenefitView : UIView
//
//- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
//
//@end

@protocol CPShockingDealBenefitViewDelegate;

@interface CPShockingDealBenefitView : UIView

@property (nonatomic, weak) id<CPShockingDealBenefitViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPShockingDealBenefitViewDelegate <NSObject>
@optional
- (void)didTouchShockDealButton;
@end