//
//  leftMenuItemView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 6..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftMenuItemViewDelegate;

@interface leftMenuItemView : UIView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end

@protocol leftMenuItemViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end