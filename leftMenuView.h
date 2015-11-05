//
//  leftMenuView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 5..
//  Copyright © 2015년 gclee. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol leftMenuViewDelegate;

@interface leftMenuView : UIView

@property (nonatomic, weak) id <leftMenuViewDelegate> delegate;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)goToTopScroll;

@end

@protocol leftMenuViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end

