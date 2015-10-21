//
//  CPProductOptionLoadingView.m
//  11st
//
//  Created by spearhead on 2015. 1. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductOptionLoadingView.h"

@interface CPProductOptionLoadingView()
{
    UIImageView *loadingView;
    UILabel *loadingLabel;
}
@end

@implementation CPProductOptionLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//        [bgImageView setImage:[UIImage imageNamed:@"bg_loading.png"]];
//        [self addSubview:bgImageView];
        
        UIImage *iconImage1 = [UIImage imageNamed:@"pageloading_01.png"];
        UIImage *iconImage2 = [UIImage imageNamed:@"pageloading_02.png"];
        UIImage *iconImage3 = [UIImage imageNamed:@"pageloading_03.png"];
        UIImage *iconImage4 = [UIImage imageNamed:@"pageloading_04.png"];
        UIImage *iconImage5 = [UIImage imageNamed:@"pageloading_05.png"];
        UIImage *iconImage6 = [UIImage imageNamed:@"pageloading_06.png"];
        
        loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self addSubview:loadingView];
        
        loadingView.animationImages = [NSArray arrayWithObjects:
                                       iconImage1,
                                       iconImage2,
                                       iconImage3,
                                       iconImage4,
                                       iconImage5,
                                       iconImage6, nil];
        
        loadingView.animationDuration = 1.0f;
        loadingView.animationRepeatCount = 0;
    }
    return self;
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    _isAnimating = loadingView.isAnimating;
}

- (void)startAnimation
{
    [loadingView startAnimating];
}

- (void)stopAnimation
{
    [loadingView stopAnimating];
}

@end
