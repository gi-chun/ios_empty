//
//  CPLoadingView.h
//
//  Created by gclee on 2015. 10. 28..
//  Copyright (c) 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPLoadingView : UIView

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end