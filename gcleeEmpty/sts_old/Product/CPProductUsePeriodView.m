//
//  CPProductUsePeriodView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductUsePeriodView.h"

#define kSeriesDefaultHeight  44

@interface CPProductUsePeriodView()
{
    NSDictionary *product;
    NSDictionary *usePeriodInfo;
}

@end

@implementation CPProductUsePeriodView

- (void)releaseItem
{
    if (product)        product = nil;
    if (usePeriodInfo)  usePeriodInfo = nil;
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
        
        CGFloat frameHeight = 0;
        
        if (product[@"prdUsePeriod"]) {
            usePeriodInfo = [product[@"prdUsePeriod"] copy];
            
            [self initLayout];
            
            frameHeight = 44;
        }
        else {
            frameHeight = 0;
        }
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                frameHeight);
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];;
    
    NSString *title = usePeriodInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSeriesDefaultHeight)];
    [titleView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self addSubview:titleView];
    
    //label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labelSize.width, CGRectGetHeight(titleView.frame))];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleView addSubview:titleLabel];
    
    NSString *text = usePeriodInfo[@"text"];
    CGSize textSize = GET_STRING_SIZE(text, [UIFont systemFontOfSize:15], kScreenBoundsWidth);
    
    //text
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+7, 0, textSize.width, CGRectGetHeight(titleView.frame))];
    [textLabel setTextColor:UIColorFromRGB(0x52bbff)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont systemFontOfSize:15]];
    [textLabel setTextAlignment:NSTextAlignmentLeft];
    [textLabel setText:text];
    [titleView addSubview:textLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(titleView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [titleView addSubview:lineView];
}

@end