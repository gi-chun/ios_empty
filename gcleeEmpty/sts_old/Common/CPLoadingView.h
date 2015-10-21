//
//  CPLoadingView.h
//  11st
//
//  Created by spearhead on 2014. 9. 18..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPLoadingView : UIView

@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;

@end