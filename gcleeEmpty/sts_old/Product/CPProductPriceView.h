//
//  CPProductPriceView.h
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductPriceViewViewDelegate;

@interface CPProductPriceView : UIView

@property (nonatomic, weak) id<CPProductPriceViewViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *couponInfo;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
- (void)reloadLayout;
- (void)stopCountDown;

@end

@protocol CPProductPriceViewViewDelegate <NSObject>
@optional
- (void)didTouchReviewButton;
@end