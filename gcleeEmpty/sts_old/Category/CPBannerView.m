//
//  CPBannerView.m
//  11st
//
//  Created by spearhead on 2015. 6. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPBannerView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPRESTClient.h"

@interface CPBannerView()
{
    NSMutableDictionary* bannerInfo;
}

@end

@implementation CPBannerView

@synthesize width = _width;
@synthesize height = _height;

- (id)initWithFrame:(CGRect)frame bannerInfo:(NSMutableDictionary *)aBannerInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        
        bannerInfo = aBannerInfo;
        
        if (![bannerInfo[@"rsCd"] isEqualToString:@"FAIL"] && [bannerInfo[@"CONTENTS"] isKindOfClass:[NSDictionary class]]) {
            NSString *imageUrl = bannerInfo[@"CONTENTS"][@"IMG1"];
            NSString *bgColor = bannerInfo[@"CONTENTS"][@"BGCOLOR"];
            
            if (bgColor.length >= 7) {
                unsigned colorRgb = 0;
                [[NSScanner scannerWithString:[bgColor substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorRgb];
                [self setBackgroundColor:UIColorFromRGB(colorRgb)];
            }
            
            CPThumbnailView *bannerView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-320)/2, 0, 320, 48)];
            [bannerView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
            [self addSubview:bannerView];
            
            UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [bannerButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 48)];
            [bannerButton setBackgroundColor:[UIColor clearColor]];
            [bannerButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x000000)] forState:UIControlStateHighlighted];
            [bannerButton setAlpha:0.3];
            [bannerButton addTarget:self action:@selector(touchBanner) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:bannerButton];
            
            self.width = kScreenBoundsWidth;
            self.height = kLineBannerHeight;
        }
        else {
            self.width = 0;
            self.height = 0;
        }
    }
    return self;
}

#pragma mark - Selectors

- (void)touchBanner
{
    NSString *linkUrl = bannerInfo[@"CONTENTS"][@"LURL1"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchLineBannerButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchLineBannerButton:linkUrl];
        }
    }
}

@end
