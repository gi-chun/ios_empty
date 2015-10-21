//
//  CPProductOptionLoadingView.h
//  11st
//
//  Created by spearhead on 2015. 1. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPProductOptionLoadingView : UIView

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end
