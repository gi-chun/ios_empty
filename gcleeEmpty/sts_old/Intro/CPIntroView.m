//
//  CPIntroView.m
//  11st
//
//  Created by saintsd on 2014. 10. 28..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPIntroView.h"
#import "CPCommonInfo.h"
#import "UIImageView+WebCache.h"

@interface CPIntroView ()
{
    UIImageView *iconImageView;
}

@end

@implementation CPIntroView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initLayout];
    }
    
    return self;
}

- (void)initLayout {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = CGRectZero;
    CGRect bounds = CGRectZero;
    CGRect screenBounds = self.bounds;
    
    CGFloat width = screenBounds.size.width;
    CGFloat height = screenBounds.size.height;
    
    frame =  CGRectMake(0, 0, width, height);
    bounds = CGRectMake(0, 0, width, height);
    
    UIView *intro = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [intro setBackgroundColor:[UIColor clearColor]];
    [self addSubview:intro];
    
    NSString *imageName = @"";
    CGFloat spaceHeight;
    
    if (IS_IPAD) {
        spaceHeight = 425;
        imageName = @"";
    }
    else {
        if (IS_IPHONE_5) {
            imageName = @"-568";
            spaceHeight = 250;
        }
        else if (IS_IPHONE_6) {
            imageName = @"-667";
            spaceHeight = 280;
        }
        else if (IS_IPHONE_6PLUS) {
            imageName = @"-736";
            spaceHeight = 320;
        }
        else {
            imageName = @"";
            spaceHeight = 220;
        }
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SDImageCache* imgCache = [SDImageCache sharedImageCache];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *introImgName = [userDefaults objectForKey:@"introImgName"];
    
    UIImageView *launchImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage *image = [imgCache imageFromDiskCacheForKey:introImgName];
    
    if (image) {
        launchImageView.image = image;
    }
    
    if (!launchImageView.image || app.isOnlyLaunchImage) {
        NSString *introImageName = [NSString stringWithFormat:@"animation_default%@%@.png", imageName, (IS_IPAD ? @"-ipad" : @"")];
        UIImage *introImage = [UIImage imageNamed:introImageName];
        
        launchImageView = [[UIImageView alloc] initWithImage:introImage];
    }
    
    [launchImageView setTag:99];
    [launchImageView setFrame:frame];
    [launchImageView setBounds:bounds];
    [intro addSubview:launchImageView];
    
    UIImage *iconImage1 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_beauty%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage2 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_cloth%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage3 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_food%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage4 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_furniture%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage5 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_leisure%@", (IS_IPAD ? @"-ipad" : @"")]];
    
    iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2-(iconImage1.size.width/2),
                                                                  kScreenBoundsHeight-spaceHeight,
                                                                  iconImage1.size.width,
                                                                  iconImage1.size.height)];
    [intro addSubview:iconImageView];
    
    iconImageView.animationImages = [NSArray arrayWithObjects:
                                     iconImage1,
                                     iconImage2,
                                     iconImage3,
                                     iconImage4,
                                     iconImage5, nil];
    
    iconImageView.animationDuration = 1.0f;
    iconImageView.animationRepeatCount = 0;
    
    [iconImageView startAnimating];
}

- (void)stopAnimation
{
    if (iconImageView) [iconImageView stopAnimating];
}

@end
