//
//  CPLoadingView.m
//
//  Created by gclee on 2015. 10. 28..
//  Copyright (c) 2015년 gclee. All rights reserved.
//

#import "CPLoadingView.h"

@interface CPLoadingView()
{
	UIImageView *loadingView;
    UILabel *loadingLabel;
}
@end

@implementation CPLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [bgImageView setImage:[UIImage imageNamed:@"bg_loading.png"]];
        [self addSubview:bgImageView];
        
        UIImage *iconImage1 = [UIImage imageNamed:@"intro_img.png"];
        UIImage *iconImage2 = [UIImage imageNamed:@"icon-76.png"];
        UIImage *iconImage3 = [UIImage imageNamed:@"intro_img.png"];
        UIImage *iconImage4 = [UIImage imageNamed:@"icon-76.png"];
        UIImage *iconImage5 = [UIImage imageNamed:@"intro_img.png"];
        UIImage *iconImage6 = [UIImage imageNamed:@"icon-76.png"];
        
        loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
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
