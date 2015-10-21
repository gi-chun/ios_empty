//
//  CPProductBannerView.m
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductBannerView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPProductBannerView()
{
    NSDictionary *product;
    NSDictionary *bannerInfo;
    
    UIView *lineView;
    
    UIView *containerView;
    
    CGFloat itemHeight;
}

@end

@implementation CPProductBannerView

- (void)releaseItem
{
    if (product)        product = nil;
    if (bannerInfo)     bannerInfo = nil;
    if (lineView)       lineView = nil;
    if (containerView)  containerView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
        if (product[@"lineBanner"]) {
            bannerInfo = [product[@"lineBanner"] copy];
            
            [self initLayout];
        }
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];;
    
    NSString *imageUrl = bannerInfo[@"bannerImgUrl"];
    
    CGFloat frameHeight = 68;
    
    if (bannerInfo[@"bannerImgUrl"]) {
        NSString *bgColor = bannerInfo[@"bgColor"];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 60)];
        [self addSubview:backgroundImageView];
    
        if (bgColor.length >= 7) {
            unsigned colorRgb = 0;
            [[NSScanner scannerWithString:[bgColor substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorRgb];
            [backgroundImageView setBackgroundColor:UIColorFromRGB(colorRgb)];
        }
        
        CPThumbnailView *bannerView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-320)/2, 0, 320, 60)];
        [bannerView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
        [self addSubview:bannerView];
        
        UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bannerButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 60)];
        [bannerButton setBackgroundColor:[UIColor clearColor]];
        [bannerButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x000000)] forState:UIControlStateHighlighted];
        [bannerButton setAlpha:0.3];
        [bannerButton addTarget:self action:@selector(touchBanner) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bannerButton];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
        [self addSubview:lineView];
        
        //구분선
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenBoundsWidth, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
        [self addSubview:lineView];
    }
    else {
        frameHeight = 0;
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            frameHeight);
}

#pragma mark - Selectors

- (void)touchBanner
{
    NSString *linkUrl = bannerInfo[@"bannerLink"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchLineBannerButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchLineBannerButton:linkUrl];
        }
    }
    
    //AccessLog - 배너
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPI01"];
}

@end
