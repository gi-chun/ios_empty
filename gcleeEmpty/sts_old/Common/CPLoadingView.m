//
//  CPLoadingView.m
//  11st
//
//  Created by spearhead on 2014. 9. 18..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
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
        
        UIImage *iconImage1 = [UIImage imageNamed:@"ic_pageloading01.png"];
        UIImage *iconImage2 = [UIImage imageNamed:@"ic_pageloading02.png"];
        UIImage *iconImage3 = [UIImage imageNamed:@"ic_pageloading03.png"];
        UIImage *iconImage4 = [UIImage imageNamed:@"ic_pageloading04.png"];
        UIImage *iconImage5 = [UIImage imageNamed:@"ic_pageloading05.png"];
        UIImage *iconImage6 = [UIImage imageNamed:@"ic_pageloading06.png"];
        
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
