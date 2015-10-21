//
//  CPBookSeriesView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPBookSeriesView.h"

#define kSeriesDefaultHeight  44

@interface CPBookSeriesView()
{
    NSDictionary *product;
    NSDictionary *bookInfo;
    NSArray *bookSeries;
    
    UIView *containerView;
}

@end

@implementation CPBookSeriesView

- (void)releaseItem
{
    if (product)        product = nil;
    if (bookInfo)       bookInfo = nil;
    if (bookSeries)     bookSeries = nil;
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
        
        CGFloat frameHeight = 0;
        
        if (product[@"prdBookSeries"]) {
            bookInfo = [product[@"prdBookSeries"] copy];
            bookSeries = [NSArray arrayWithArray:bookInfo[@"bookSeriesLayer"]];
            
            [self initLayout];
        }
        else {
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.frame.size.width,
                                    frameHeight);
        }
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];;
    
    //시리즈상품
    NSString *title = bookInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSeriesDefaultHeight)];
    [titleView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labelSize.width, CGRectGetHeight(titleView.frame))];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(titleView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [titleView addSubview:lineView];
    
    CGFloat detailViewY = 0;
    for (int i = 0; i < bookSeries.count; i++) {
        NSDictionary *series = bookSeries[i];
        
        NSString *detailString = series[@"label"];
        CGSize labelSize = GET_STRING_SIZE(detailString, [UIFont systemFontOfSize:14], CGRectGetWidth(self.frame)-(80+20+17));
        labelSize.height += 28; //위아래 여백
        
        UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 44+detailViewY, CGRectGetWidth(self.frame), labelSize.height)];
        [detailView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [self addSubview:detailView];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labelSize.width, CGRectGetHeight(detailView.frame))];
        [detailLabel setTextColor:UIColorFromRGB(0x666666)];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setFont:[UIFont systemFontOfSize:14]];
        [detailLabel setTextAlignment:NSTextAlignmentLeft];
        [detailLabel setText:series[@"label"]];
        [detailLabel setNumberOfLines:0];
        [detailView addSubview:detailLabel];
        
        //상세보기
        UILabel *arrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(detailView.frame)-(80+22), 0, 80, CGRectGetHeight(detailView.frame))];
        [arrowLabel setTextColor:UIColorFromRGB(0x283593)];
        [arrowLabel setBackgroundColor:[UIColor clearColor]];
        [arrowLabel setFont:[UIFont systemFontOfSize:13]];
        [arrowLabel setTextAlignment:NSTextAlignmentRight];
        [arrowLabel setText:@"상세보기"];
        [detailView addSubview:arrowLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(detailView.frame)-17, CGRectGetHeight(detailView.frame)/2-5.5f, 6, 11)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_right.png"]];
        [detailView addSubview:arrowImageView];
        
        UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(detailView.frame), kSeriesDefaultHeight)];
        [blankButton addTarget:self action:@selector(touchSeriesDetailButton:) forControlEvents:UIControlEventTouchUpInside];
        [blankButton setTag:i];
        [detailView addSubview:blankButton];
        
        if (i < bookSeries.count -1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(detailView.frame)-1, CGRectGetWidth(detailView.frame), 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
            [detailView addSubview:lineView];
        }
        
        detailViewY += labelSize.height;
    }
    
    CGFloat frameHeight = 44+8+detailViewY;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            frameHeight);
}

#pragma mark - Selectors

- (void)touchSeriesDetailButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *series = bookSeries[button.tag];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSeriesDetailButton:)]) {
        [self.delegate didTouchSeriesDetailButton:series[@"linkUrl"]];
    }
}

@end