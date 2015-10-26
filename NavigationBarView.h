//
//  NavigationBarView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 26..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavigationBarViewDelegate;

@interface NavigationBarView : UIView

@property (nonatomic, weak) id<NavigationBarViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame type:(NSInteger)type;
- (void)setSearchTextField:(NSString *)keyword;
- (NSString *)getSearchTextField;

@end

@protocol NavigationBarViewDelegate <NSObject>
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
