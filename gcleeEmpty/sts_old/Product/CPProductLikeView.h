//
//  CPProductLikeView.h
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface CPProductLikeView : UIView
//
//- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
//
//@end


@protocol CPProductLikeViewDelegate;

@interface CPProductLikeView : UIView

@property (nonatomic, weak) id<CPProductLikeViewDelegate> delegate;
@property (nonatomic, strong) UIButton *likeButton;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
- (void)setLikeButtonStatus:(NSDictionary *)info;

@end

@protocol CPProductLikeViewDelegate <NSObject>
@optional
- (void)didTouchLikeButton;
- (void)didTouchGiftButton;
- (void)didTouchShareButton;
@end