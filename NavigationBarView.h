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
@property (nonatomic) NSString*  title;


- (id)initWithFrame:(CGRect)frame type:(NSInteger)type;
- (id)initWithFrame:(CGRect)frame type:(NSInteger)type title:(NSString*)title;
- (void)setSearchTextField:(NSString *)keyword;
- (NSString *)getSearchTextField;

@end

@protocol NavigationBarViewDelegate <NSObject>
@optional
- (void)didTouchMenuButton;
- (void)didTouchBackButton;
- (void)didTouchBankButton;
- (void)didTouchSunnyButton;
- (void)didTouchSearchButton:(NSString *)keywordUrl;
- (void)searchTextFieldShouldBeginEditing:(NSString *)keyword keywordUrl:(NSString *)keywordUrl;

@end
