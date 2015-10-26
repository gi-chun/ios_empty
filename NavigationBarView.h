//
//  NavigationBarView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 26..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPNavigationBarViewDelegate;

@interface NavigationBarView : UIView

@property (nonatomic, weak) id<CPNavigationBarViewDelegate> delegate;

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
