//
//  CPProductTabMenuView.m
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductTabMenuView.h"
#import "CPString+Formatter.h"
#import "AccessLog.h"

#define kProdutDescriptionButtonTag     100
#define kProductReivewButtonTag         101
#define kProductQnaButtonTag            102
#define kProductRefundButtonTag         103

#define kProductReviewLabelTag          200
#define kProductQnaLabelTag             201

@interface CPProductTabMenuView()
{
    NSDictionary *product;
    NSDictionary *bannerInfo;
    
    NSMutableArray *tabMenuItems;
    
    UIView *lineView;
    
    UIView *containerView;
}

@end

@implementation CPProductTabMenuView

- (void)releaseItem
{
    if (product) product = nil;
    if (bannerInfo) bannerInfo = nil;
    if (tabMenuItems) tabMenuItems = nil;
    if (lineView) lineView = nil;
    if (containerView) containerView = nil;
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
        
//        if (item[@"linkBanner"]) {
//            bannerInfo = [item[@"linkBanner"] copy];
        
        [self initData];
        
        [self initLayout];
//        }
    }
    return self;
}

- (void)initData
{
    tabMenuItems = [NSMutableArray array];
    
    [tabMenuItems addObject:@{@"key": @"produtDescription", @"title": @"상품정보", @"isSelected": @"Y"}];
    [tabMenuItems addObject:@{@"key": @"productReivew", @"title": @"리뷰/후기", @"isSelected": @"N"}];
    [tabMenuItems addObject:@{@"key": @"productQna", @"title": @"Q&A", @"isSelected": @"N"}];
    [tabMenuItems addObject:@{@"key": @"productRefund", @"title": @"반품/교환", @"isSelected": @"N"}];
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    
    CGFloat menuButtonWidth = kScreenBoundsWidth/tabMenuItems.count;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:lineView];
    
    //구분선
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGBA(0x000000, 0.15f)];
    [self addSubview:lineView];
    
    for (int i = 0; i < tabMenuItems.count; i++) {
        NSDictionary *menu = tabMenuItems[i];
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(menuButtonWidth*i, 1, menuButtonWidth, CGRectGetHeight(self.frame)-2)];
        [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [menuButton setTitle:menu[@"title"] forState:UIControlStateNormal];
        [menuButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [menuButton setTag:100+i];
        [menuButton addTarget:self action:@selector(touchTabMenuButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menuButton];
        
        //판매자 요청에 따른 리뷰/후기 노출여부
        BOOL reviewPostDispYN = [product[@"reviewPostDispYN"] isEqualToString:@"Y"];
        if (reviewPostDispYN) {
            if (100+i == kProductReivewButtonTag) {
                if (product[@"prdReview"][@"totalCount"] || product[@"prdPost"][@"totalCount"]) {
                    NSInteger reviewCount = [product[@"prdReview"][@"totalCount"] integerValue];
                    NSInteger postCount = [product[@"prdPost"][@"totalCount"] integerValue];
                    NSString *countString = [[NSString stringWithFormat:@"%li", (long)reviewCount+postCount] formatThousandComma];
                    if (reviewCount+postCount > 99999) countString = @"99,999+";
                    
                    if (reviewCount+postCount > 0) {
                        UILabel *reviewTotalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(menuButton.frame), 13)];
                        [reviewTotalCountLabel setBackgroundColor:[UIColor clearColor]];
                        [reviewTotalCountLabel setTag:kProductReviewLabelTag];
                        [reviewTotalCountLabel setText:countString];
                        [reviewTotalCountLabel setTextColor:UIColorFromRGB(0x999999)];
                        [reviewTotalCountLabel setTextAlignment:NSTextAlignmentCenter];
                        [reviewTotalCountLabel setFont:[UIFont systemFontOfSize:10]];
                        [menuButton addSubview:reviewTotalCountLabel];
                    }
                }
            }
            else if (100+i == kProductQnaButtonTag) {
                if (product[@"prdQna"][@"totalCount"]) {
                    
                    NSInteger postCount = [product[@"prdQna"][@"totalCount"] integerValue];
                    NSString *countString = [[NSString stringWithFormat:@"%li", (long)postCount] formatThousandComma];
                    if (postCount > 99999) countString = @"99,999+";
                    
                    if (postCount > 0) {
                        UILabel *qnaTotalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(menuButton.frame), 13)];
                        [qnaTotalCountLabel setBackgroundColor:[UIColor clearColor]];
                        [qnaTotalCountLabel setTag:kProductQnaLabelTag];
                        [qnaTotalCountLabel setText:countString];
                        [qnaTotalCountLabel setTextColor:UIColorFromRGB(0x999999)];
                        [qnaTotalCountLabel setTextAlignment:NSTextAlignmentCenter];
                        [qnaTotalCountLabel setFont:[UIFont systemFontOfSize:10]];
                        [menuButton addSubview:qnaTotalCountLabel];
                    }
                }
            }
        }
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(menuButton.frame)-2, CGRectGetWidth(menuButton.frame), 2)];
        [underLineView setBackgroundColor:UIColorFromRGB(0xf62d3d)];
        [underLineView setTag:200+i];
        [menuButton addSubview:underLineView];
        
        [self setButtonProperties:menuButton];
    }
    
    UIButton *button = (UIButton *)[self viewWithTag:kProdutDescriptionButtonTag];
    [self touchTabMenuButton:button];
}

#pragma mark - Private Methods

- (void)setButtonProperties:(UIButton *)button
{
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
    [button setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    
    if (button.tag == kProductReivewButtonTag) {
        UILabel *label = (UILabel *)[button viewWithTag:kProductReviewLabelTag];
        [label setFrame:CGRectMake(0, 30, CGRectGetWidth(button.frame), 13)];
    }
    else if (button.tag == kProductQnaButtonTag) {
        UILabel *label = (UILabel *)[button viewWithTag:kProductQnaLabelTag];
        [label setFrame:CGRectMake(0, 30, CGRectGetWidth(button.frame), 13)];
    }
    
    UIView *underLineView = (UIView *)[button viewWithTag:100+button.tag];
    [underLineView setHidden:YES];
}

- (void)setHighlightedButtonProperties:(UIButton *)button
{
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-2, 0, 0, 0)];
    [button setTitleColor:UIColorFromRGB(0xf62d3d) forState:UIControlStateNormal];
    
    if (button.tag == kProductReivewButtonTag) {
        UILabel *label = (UILabel *)[button viewWithTag:kProductReviewLabelTag];
        [label setFrame:CGRectMake(0, 30, CGRectGetWidth(button.frame), 13)];
    }
    else if (button.tag == kProductQnaButtonTag) {
        UILabel *label = (UILabel *)[button viewWithTag:kProductQnaLabelTag];
        [label setFrame:CGRectMake(0, 30, CGRectGetWidth(button.frame), 13)];
    }
    
    UIView *underLineView = (UIView *)[button viewWithTag:100+button.tag];
    [underLineView setHidden:NO];
    
    [self bringSubviewToFront:button];
}

#pragma mark - Selectors

- (void)touchTabMenuButton:(id)sender
{
    for (int i = 0; i < tabMenuItems.count; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:100+i];
        
        [self setButtonProperties:button];
    }
    
    UIButton *targetButton = (UIButton *)sender;
    targetButton = (UIButton *)[self viewWithTag:targetButton.tag];
    
    [self setHighlightedButtonProperties:targetButton];
    
//    NSString *linkUrl = bannerInfo[@"bannerLink"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchTabMenuButton:)]) {
        [self.delegate didTouchTabMenuButton:targetButton.tag-100];
    }
    
    //AccessLog
    switch (targetButton.tag-100) {
        case 0:
            //AccessLog - 상품정보 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ01"];
            break;
        case 1:
            //AccessLog - 리뷰/후기 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL01"];
            break;
        case 2:
            //AccessLog - Q&A 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPM01"];
            break;
        case 3:
            //AccessLog - 반품/교환 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPN01"];
            break;
    }
}

@end
