//
//  CPNavigationBarView.h
//  11st
//
//  Created by spearhead on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPNavigationBarViewDelegate;

@interface CPNavigationBarView : UIView

@property (nonatomic, weak) id<CPNavigationBarViewDelegate> delegate;
@property (nonatomic, strong) UIButton *logoButton;

- (id)initWithFrame:(CGRect)frame type:(CPNavigationType)type;
- (void)setSearchTextField:(NSString *)keyword;
- (NSString *)getSearchTextField;
@end

@protocol CPNavigationBarViewDelegate <NSObject>
@optional
- (void)didTouchMenuButton;
- (void)didTouchBackButton;
- (void)didTouchBasketButton;
- (void)didTouchLogoButton;
- (void)didTouchMartButton;
- (void)didTouchMyInfoButton;
- (void)didTouchSearchButton:(NSString *)keywordUrl;
- (void)didTouchSearchButtonWithKeyword:(NSString *)keyword;
- (void)didTouchMartSearchButton;
- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl;

@end
