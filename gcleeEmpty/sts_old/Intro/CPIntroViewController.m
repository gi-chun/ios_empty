//
//  CPIntroViewController.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPIntroViewController.h"
#import "QBAnimationSequence.h"
#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"

@interface CPIntroViewController ()
{
    QBAnimationSequence *sequence;
}

@end

@implementation CPIntroViewController

- (id)init
{
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = CGRectZero;
    CGRect bounds = CGRectZero;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat width = screenBounds.size.width;
    CGFloat height = screenBounds.size.height;

    frame =  CGRectMake(0, 0, width, height);
    bounds = CGRectMake(0, 0, width, height);
    
    UIView *intro = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [intro setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:intro];
    
    NSString *introImageName = [NSString stringWithFormat:@"animation_default%@%@.png", ([INCH4_HEIGHT isEqualToString:@"568"] ? @"-568" : @""), (IS_IPAD ? @"-ipad" : @"")];
    UIImage *introImage = [UIImage imageNamed:introImageName];
    
    UIImageView *introImageView = [[UIImageView alloc] initWithImage:introImage];
    [introImageView setTag:99];
    [introImageView setFrame:frame];
    [introImageView setBounds:bounds];
    [intro addSubview:introImageView];
    
    UIImage *iconImage1 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_beauty%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage2 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_brand%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage3 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_cloth%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage4 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_food%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage5 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_furniture%@", (IS_IPAD ? @"-ipad" : @"")]];
    UIImage *iconImage6 = [UIImage imageNamed:[NSString stringWithFormat:@"icon_leisure%@", (IS_IPAD ? @"-ipad" : @"")]];
    
    CGFloat iPadHeight = (IS_IPAD ? 425 : 250);
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2-(iconImage1.size.width/2),
                                                                               kScreenBoundsHeight-iPadHeight,
                                                                               iconImage1.size.width,
                                                                               iconImage1.size.height)];
    [intro addSubview:iconImageView];
    
    QBAnimationItem *item1 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage1];
    }];
    
    QBAnimationItem *item2 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage2];
    }];
    
    QBAnimationItem *item3 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage3];
    }];
    
    QBAnimationItem *item4 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage4];
    }];
    
    QBAnimationItem *item5 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage5];
    }];
    
    QBAnimationItem *item6 = [QBAnimationItem itemWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [iconImageView setImage:iconImage6];
    }];
    
    QBAnimationGroup *group1 = [QBAnimationGroup groupWithItems:@[item1]];
    QBAnimationGroup *group2 = [QBAnimationGroup groupWithItems:@[item2]];
    QBAnimationGroup *group3 = [QBAnimationGroup groupWithItems:@[item3]];
    QBAnimationGroup *group4 = [QBAnimationGroup groupWithItems:@[item4]];
    QBAnimationGroup *group5 = [QBAnimationGroup groupWithItems:@[item5]];
    QBAnimationGroup *group6 = [QBAnimationGroup groupWithItems:@[item6]];
    
    sequence = [[QBAnimationSequence alloc] initWithAnimationGroups:@[group1, group2, group3, group4, group5, group6] repeat:YES];
    [sequence start];
    
//    UIFont *versionFont = [UIFont boldSystemFontOfSize:18];
//    CGSize versionTextSize = [SYSTEM_VERSION intValue] >= 7 ? [APP_VERSION sizeWithAttributes:@{NSFontAttributeName:versionFont}] : [APP_VERSION sizeWithFont:versionFont];
//    
//    UILabel *introVersion = [[UILabel alloc] initWithFrame:CGRectZero];
//    [introVersion setText:APP_VERSION];
//    [introVersion setFont:versionFont];
//    [introVersion setTextColor:[UIColor whiteColor]];
//    [introVersion setBackgroundColor:[UIColor clearColor]];
//    [introVersion setAlpha:0.5f];
//    [introVersion setTag:97];
//    [introVersion setFrame:CGRectMake((bounds.size.width - versionTextSize.width) / 2, introIndicator.frame.origin.y + introIndicator.frame.size.height + versionGap, versionTextSize.width, versionTextSize.height)];
//    [introImageView addSubview:introVersion];

//        initialized = YES;
//        [self setStartMode:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [sequence stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
