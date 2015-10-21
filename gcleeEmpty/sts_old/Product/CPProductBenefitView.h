//
//  CPProductBenefitView.h
//  11st
//
//  Created by spearhead on 2015. 6. 26..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductBenefitViewDelegate;

@interface CPProductBenefitView : UIView

@property (nonatomic, weak) id<CPProductBenefitViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPProductBenefitViewDelegate <NSObject>
@optional
- (void)didTouchExpandButton:(CPProductViewType)viewType height:(CGFloat)height;
- (void)didTouchBenefitInfoButton:(NSString *)url helpTitle:(NSString *)helpTitle;
- (void)didTouchBenefitLinkButton:(NSString *)url;
- (void)didTouchEventLinkButton:(NSString *)url;
@end