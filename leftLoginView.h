//
//  leftLoginView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 10..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftLoginViewDelegate;

@interface leftLoginView : UIView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
@end

@protocol leftLoginViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end