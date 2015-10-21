//
//  CPShockingDealBenefitView.m
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPShockingDealBenefitView.h"
#import "AccessLog.h"

@interface CPShockingDealBenefitView()
{
    NSDictionary *product;
    NSDictionary *benefitInfo;
    
    UIView *lineView;
    
    UIView *containerView;
    
    CGFloat itemHeight;
}

@end

@implementation CPShockingDealBenefitView

- (void)releaseItem
{
    if (product)        product = nil;
    if (benefitInfo)    benefitInfo = nil;
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
        
        if (product[@"bnfDealApp"]) {
            benefitInfo = [product[@"bnfDealApp"] copy];
        }
        
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];;
    
    //쇼킹딜앱 혜택
    if (product[@"bnfDealApp"]) {
        NSString *title = benefitInfo[@"label"];
        CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, labelSize.width, 0)];
        [titleLabel setTextColor:UIColorFromRGB(0x333333)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setText:title];
        [titleLabel sizeToFit];
        [self addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+7, 14, CGRectGetWidth(self.frame)-(CGRectGetMaxX(titleLabel.frame)+92), 0)];
        [detailLabel setTextColor:UIColorFromRGB(0x52bbff)];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setFont:[UIFont systemFontOfSize:15]];
        [detailLabel setTextAlignment:NSTextAlignmentLeft];
        [detailLabel setText:benefitInfo[@"text"]];
        [detailLabel setNumberOfLines:0];
        [detailLabel sizeToFit];
        [detailLabel setNumberOfLines:2];
        [self addSubview:detailLabel];
        
        UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [linkButton setFrame:CGRectMake(CGRectGetWidth(self.frame)-75, 15, 65, 18)];
        [linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
        [linkButton setTitle:@"앱바로가기" forState:UIControlStateNormal];
        [linkButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [linkButton setTitleColor:UIColorFromRGB(0x283593) forState:UIControlStateNormal];
        [linkButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [linkButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:linkButton];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(linkButton.frame)-6, 3.5f, 6, 11)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_right.png"]];
        [linkButton addSubview:arrowImageView];
        
        itemHeight = CGRectGetHeight(detailLabel.frame)+28;
        
        //구분선
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, itemHeight-1, kScreenBoundsWidth, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
        [self addSubview:lineView];
    }
    else {
        itemHeight = 0;
    }
    
    
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              itemHeight)];
}

#pragma mark - Selectors

- (void)touchLinkButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchShockDealButton)]) {
        [self.delegate didTouchShockDealButton];
    }
    
    //AccessLog - 앱바로가기 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPF01"];
}

@end
