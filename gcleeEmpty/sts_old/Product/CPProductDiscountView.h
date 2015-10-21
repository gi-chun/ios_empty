//
//  CPProductDiscountView.h
//  11st
//
//  Created by spearhead on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductDiscountViewDelegate;

@interface CPProductDiscountView : UIView

@property (nonatomic, weak) id<CPProductDiscountViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct viewType:(CPProductViewType)aViewType;
- (void)reloadLayout:(NSDictionary *)dict viewType:(CPProductViewType)aViewType;

@end

@protocol CPProductDiscountViewDelegate <NSObject>
@optional
- (void)didTouchExpandButton:(CPProductViewType)viewType height:(CGFloat)height;
- (void)didTouchSaleInfoButton:(NSString *)linkUrl title:(NSString *)title;
- (void)didTouchHelpInfoButton:(NSString *)linkUrl title:(NSString *)title;
- (void)didTouchLinkButton:(NSString *)url;

@end