//
//  CPProductDiscountView.m
//  11st
//
//  Created by spearhead on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductDiscountView.h"
#import "NSString+URLEncodedString.h"
#import "AccessLog.h"

#define kDiscountDefaultHeight  44

@interface CPProductDiscountView()
{
    CPProductViewType viewType;
    
    NSDictionary *product;
    NSDictionary *discountInfo;
    NSMutableArray *discountItems;
    NSString *titleStr;
    NSString *descStr;
    NSString *helpLinkStr;
    
    UILabel *titleLabel;
    UILabel *titleDetailLabel;
    UIImageView *arrowImageView;
    UIView *lineView;
    
    UIView *containerView;
    UIView *underLineView;
}

@end

@implementation CPProductDiscountView

- (void)releaseItem
{
    if (product)            product = nil;
    if (discountInfo)       discountInfo = nil;
    if (discountItems)      discountItems = nil;
    if (titleStr)           titleStr = nil;
    if (descStr)            descStr = nil;
    if (helpLinkStr)        helpLinkStr = nil;
    if (titleLabel)         titleLabel = nil;
    if (titleDetailLabel)   titleDetailLabel = nil;
    if (arrowImageView)     arrowImageView = nil;
    if (lineView)           lineView = nil;
    if (containerView)      containerView = nil;
    if (underLineView)      underLineView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct viewType:(CPProductViewType)aViewType
{
    if (self = [super initWithFrame:frame]) {
        
        viewType = aViewType;
        
        product = [aProduct copy];
        discountItems = [NSMutableArray array];
        
        CGFloat frameHeight = 44;
        
        if (viewType == CPProductViewTypeMyDiscount) {
            if (product[@"bnfMyDiscount"]) {
                discountInfo = [product[@"bnfMyDiscount"] copy];
                
                discountItems = [discountInfo[@"myDiscountLayer"] mutableCopy];
                titleStr = @"내맘대로할인";
                descStr = @"내맘대로 할인이란";
                
                [self initLayout];
            }
            else {
                frameHeight = 0;
            }
        }
        else {
            if (product[@"bnfAddDiscount"]) {
                discountInfo = [product[@"bnfAddDiscount"] copy];
                
                discountItems = [discountInfo[@"addDiscountLayer"] mutableCopy];
                titleStr = @"추가 할인가";
                descStr = @"가격정보";
                
                [self initLayout];
            }
            else {
                frameHeight = 0;
            }
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
    [self setBackgroundColor:[UIColor clearColor]];;
    
    //추가할인가
    NSString *title = titleStr;//discountInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, labelSize.width, kDiscountDefaultHeight)];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [self addSubview:titleLabel];
    
    titleDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+6, 0, 200, kDiscountDefaultHeight)];
    [titleDetailLabel setTextColor:UIColorFromRGB(0x52bbff)];
    [titleDetailLabel setBackgroundColor:[UIColor clearColor]];
    [titleDetailLabel setFont:[UIFont systemFontOfSize:15]];
    [titleDetailLabel setTextAlignment:NSTextAlignmentLeft];
    [titleDetailLabel setText:discountInfo[@"text"]];
    [self addSubview:titleDetailLabel];
    
    arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-25, 18, 15, 8)];
//    [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_02.png"]];
    [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down.png"]];
    [self addSubview:arrowImageView];
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDiscountDefaultHeight)];
    [blankButton addTarget:self action:@selector(touchDiscountButton:) forControlEvents:UIControlEventTouchUpInside];
    [blankButton setSelected:NO];
    [self addSubview:blankButton];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [self addSubview:lineView];
    
    //상세내역 - myDiscountLayer
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 0)];
    [containerView setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [containerView setClipsToBounds:YES];
    [self addSubview:containerView];
    
    [self setContainerView];
    
//    [productNameLabel sizeToFitWithVersionHoldWidth];
//    
//    //가격정보
//    [self initPriceView];
//    
//    //    isShockingDeal = [@"y" isEqualToString:[item[@"isDealPrd"] lowercaseString]];
//    isShockingDeal = [item[@"isDealPrd"] boolValue];
//    
//    if (isShockingDeal) {
//        //쇼킹딜 - isDealPrd, dealSelEndTime, dealSelQty
//        [self initShockingDealView];
//    }
//    
//    //만족도, 리뷰 영역 - prdSatisfy, prdReview, prdPost
//    [self initReviewView];
    
//    self.frame = CGRectMake(self.frame.origin.x,
//                            self.frame.origin.y,
//                            self.frame.size.width,
//                            orginY);
}

- (void)setContainerView
{
    CGFloat originY = 7;
    NSInteger discountItemsCount = discountInfo[@"helpLinkUrl"]?discountItems.count+1:discountItems.count;
    
    for (NSInteger i = 0; i < discountItemsCount; i++) {
        
        if (discountItems.count != i) {
            NSDictionary *itemInfo = discountItems[i];
            
            CGFloat originX = 8;
            
            //기본 레이블
            if (itemInfo[@"label"]) {
                NSString *title = itemInfo[@"label"];
                CGSize labelSize = GET_STRING_SIZE(title, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
                
                UILabel *aTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY+i*30, labelSize.width, 30)];
                [aTitleLabel setTextColor:UIColorFromRGB(0x333333)];
                [aTitleLabel setBackgroundColor:[UIColor clearColor]];
                [aTitleLabel setFont:[UIFont systemFontOfSize:14]];
                [aTitleLabel setTextAlignment:NSTextAlignmentLeft];
                [aTitleLabel setText:title];
                [containerView addSubview:aTitleLabel];
                
                originX = CGRectGetMaxX(aTitleLabel.frame);
                
//                if (i == discountItems.count -1) {
//                    UIView *containerViewLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+6, kScreenBoundsWidth, 1)];
//                    [containerViewLineView setBackgroundColor:UIColorFromRGB(0xededed)];
//                    [containerView addSubview:containerViewLineView];
//                }
            }
            
            //상세 레이블
            if (itemInfo[@"dscText"]) {
                NSString *desc = itemInfo[@"dscText"];
                CGSize descLabelSize = GET_STRING_SIZE(desc, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
                
                CGFloat margin = 3;
                
                if (originX == 10) {
                    margin = 0;
                }
                
                UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX+margin, originY+i*30, descLabelSize.width, 30)];
                [detailLabel setTextColor:UIColorFromRGB(0x999999)];
                [detailLabel setBackgroundColor:[UIColor clearColor]];
                [detailLabel setFont:[UIFont systemFontOfSize:14]];
                [detailLabel setTextAlignment:NSTextAlignmentLeft];
                [detailLabel setText:desc];
                [containerView addSubview:detailLabel];
                
                originX = CGRectGetMaxX(detailLabel.frame);
            }
            
            //정보 팝업링크
            if (itemInfo[@"helpLinkUrl"]) {
                UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [infoButton setFrame:CGRectMake(originX, originY+i*30-1, 32, 32)];
                [infoButton setImage:[UIImage imageNamed:@"ic_pd_information.png"] forState:UIControlStateNormal];
                [infoButton addTarget:self action:@selector(touchSaleInfoButton:) forControlEvents:UIControlEventTouchUpInside];
                [infoButton setTag:i];
                [containerView addSubview:infoButton];
                
                originX = CGRectGetMaxX(infoButton.frame);
            }
            
            //쿠폰받기
            if (itemInfo[@"cpnLinkText"]) {
                
                NSString *link = itemInfo[@"cpnLinkText"];
                CGSize linkLabelSize = GET_STRING_SIZE(link, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
                
                UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [linkButton setFrame:CGRectMake(originX+5, originY+i*30-1, linkLabelSize.width, 30)];
                [linkButton setTitle:link forState:UIControlStateNormal];
                [linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
                [linkButton setTag:i];
                [linkButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
                [linkButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [containerView addSubview:linkButton];
                
                UIView *linkUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 23, linkButton.frame.size.width, 1)];
                [linkUnderLineView setBackgroundColor:UIColorFromRGB(0x999999)];
                [linkButton addSubview:linkUnderLineView];
            }
            
            //가격정보
            if (itemInfo[@"price"]) {
                NSString *price = itemInfo[@"price"];
                CGSize priceLabelSize = GET_STRING_SIZE(price, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
                
                UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-(priceLabelSize.width+10), originY+i*30, priceLabelSize.width, 30)];
                [priceLabel setTextColor:UIColorFromRGB(0x333333)];
                [priceLabel setBackgroundColor:[UIColor clearColor]];
                [priceLabel setFont:[UIFont systemFontOfSize:14]];
                [priceLabel setTextAlignment:NSTextAlignmentRight];
                [priceLabel setText:price];
                [containerView addSubview:priceLabel];
                //                NSLog(@"priceLabel:%@", NSStringFromCGRect(priceLabel.frame));
            }
        }
        else {
            //설명
            if (discountItems.count == i && discountInfo[@"helpLinkUrl"]) {
                NSString *desc = descStr;
                CGSize descLabelSize = GET_STRING_SIZE(desc, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
                
                UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY+i*30, descLabelSize.width, 30)];
                [descLabel setTextColor:UIColorFromRGB(0x333333)];
                [descLabel setBackgroundColor:[UIColor clearColor]];
                [descLabel setFont:[UIFont systemFontOfSize:14]];
                [descLabel setTextAlignment:NSTextAlignmentLeft];
                [descLabel setText:desc];
                [containerView addSubview:descLabel];
                
                UIButton *descButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [descButton setFrame:CGRectMake(CGRectGetMaxX(descLabel.frame)+5, originY+i*30-1, 32, 32)];
                [descButton setImage:[UIImage imageNamed:@"ic_pd_information.png"] forState:UIControlStateNormal];
                [descButton addTarget:self action:@selector(touchHelpInfoButton:) forControlEvents:UIControlEventTouchUpInside];
                [containerView addSubview:descButton];
            }
        }
    }
    
    underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, kDiscountDefaultHeight+CGRectGetHeight(containerView.frame)-1, kScreenBoundsWidth, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [containerView addSubview:underLineView];
}

- (void)reloadLayout:(NSDictionary *)dict viewType:(CPProductViewType)aViewType
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [self releaseItem];
    
    viewType = aViewType;
    product = [dict copy];
    discountItems = [NSMutableArray array];
    
    CGFloat frameHeight = 44;
    
    if (viewType == CPProductViewTypeMyDiscount) {
        if (dict) {
            discountInfo = [dict copy];
            
            discountItems = [discountInfo[@"myDiscountLayer"] mutableCopy];
            titleStr = @"내맘대로할인";
            descStr = @"내맘대로 할인이란";
            
            [self initLayout];
        }
        else {
            frameHeight = 0;
        }
    }
    else {
        if (dict) {
            discountInfo = [dict copy];
            
            discountItems = [discountInfo[@"addDiscountLayer"] mutableCopy];
            titleStr = @"추가 할인가";
            descStr = @"가격정보";
            
            [self initLayout];
        }
        else {
            frameHeight = 0;
        }
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            frameHeight);
}

#pragma mark - Selectors

- (void)touchDiscountButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.isSelected) {
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down.png"]];
        [containerView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 0)];
    }
    else {
        NSInteger discountItemsCount = discountInfo[@"helpLinkUrl"]?discountItems.count+1:discountItems.count;
        
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_01.png"]];
        [containerView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 14+discountItemsCount*30)];
        [underLineView setFrame:CGRectMake(0, CGRectGetHeight(containerView.frame)-1, kScreenBoundsWidth, 1)];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
        [self.delegate didTouchExpandButton:viewType height:kDiscountDefaultHeight+CGRectGetHeight(containerView.frame)];
    }
    
    [button setSelected:!button.isSelected];
    
    //AccessLog - 추가할인가 영역 열기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPC01"];
}

- (void)touchSaleInfoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *helpLinkUrl = discountItems[button.tag][@"helpLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSaleInfoButton:title:)]) {
        if (helpLinkUrl && [[helpLinkUrl trim] length] > 0) {
            [self.delegate didTouchSaleInfoButton:helpLinkUrl title:titleStr];
        }
    }
}

- (void)touchHelpInfoButton:(id)sender
{
    NSString *helpLinkUrl = discountInfo[@"helpLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchHelpInfoButton:title:)]) {
        if (helpLinkUrl && [[helpLinkUrl trim] length] > 0) {
            [self.delegate didTouchHelpInfoButton:helpLinkUrl title:discountInfo[@"helpTitle"]];
        }
    }
}

- (void)touchLinkButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *linkUrl = discountItems[button.tag][@"cpnLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchLinkButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchLinkButton:linkUrl];
        }
    }
    
    //AccessLog - 단골쿠폰받기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPC02"];
}

@end
