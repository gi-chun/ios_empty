//
//  CPProductBenefitView.m
//  11st
//
//  Created by spearhead on 2015. 6. 26..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductBenefitView.h"
#import "CPRESTClient.h"
#import "AccessLog.h"

#define kBenefitDefaultHeight  70

@interface CPProductBenefitView()
{
    NSDictionary *product;
    NSDictionary *benefitInfo;
    NSArray *benefitItems;
    NSString *benefitAdText;
    NSString *benefitAdUrl;
    
    UIImageView *arrowImageView;
    UIView *lineView;
    
    UIView *containerView;
    
    CGFloat frameHeight;
}

@end

@implementation CPProductBenefitView

- (void)releaseItem
{
    if (product)        product = nil;
    if (benefitInfo)    benefitInfo = nil;
    if (benefitItems)   benefitItems = nil;
    if (benefitAdText)  benefitAdText = nil;
    if (benefitAdUrl)   benefitAdUrl = nil;
    if (arrowImageView) arrowImageView = nil;
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
        
        if (product[@"bnfBenefit"]) {
            benefitInfo = [product[@"bnfBenefit"] copy];
            
            benefitItems = [NSArray arrayWithArray:benefitInfo[@"benefitLayer"]];
            
            [self getBenefitAdLinkData];
//            [self initLayout];
            
//            frameHeight = 75;
        }
        else {
            frameHeight = 0;
            
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
    [self setBackgroundColor:[UIColor clearColor]];;
    
    //혜택
    NSString *title = @"혜택";//benefitInfo[@"label"];
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont boldSystemFontOfSize:15], kScreenBoundsWidth);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, labelSize.width, 0)];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setText:title];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    NSString *detailString = benefitInfo[@"text"];
    CGSize detailLabelSize = GET_STRING_SIZE(detailString, [UIFont systemFontOfSize:15], CGRectGetWidth(self.frame)-(CGRectGetMaxX(titleLabel.frame)+30));
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+7, 15, detailLabelSize.width, 0)];
    [detailLabel setTextColor:UIColorFromRGB(0x52bbff)];
    [detailLabel setBackgroundColor:[UIColor clearColor]];
    [detailLabel setFont:[UIFont systemFontOfSize:15]];
    [detailLabel setTextAlignment:NSTextAlignmentLeft];
    [detailLabel setText:detailString];
    [detailLabel setNumberOfLines:0];
    [detailLabel sizeToFit];
    [self addSubview:detailLabel];
    
    NSString *link = benefitAdText;//benefitInfo[@"adLinkText"];
//    NSMutableAttributedString *linkString = [[NSMutableAttributedString alloc] initWithString:link];
//    [linkString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [linkString length])];
    
    CGSize linkLabelSize = GET_STRING_SIZE(link, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
    
    UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkButton setFrame:CGRectMake(CGRectGetMinX(detailLabel.frame), CGRectGetMaxY(detailLabel.frame)+6, linkLabelSize.width, 18)];
    [linkButton addTarget:self action:@selector(touchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
//    [linkButton setAttributedTitle:linkString forState:UIControlStateNormal];
    [linkButton setTitle:link forState:UIControlStateNormal];
    [linkButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [linkButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [linkButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [linkButton setBackgroundColor:[UIColor clearColor]];
    [self addSubview:linkButton];
    
    //AttributedString은 밑줄이 완전치 않음
    UIView *underlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 17, CGRectGetWidth(linkButton.frame), 1)];
    [underlineView setBackgroundColor:UIColorFromRGB(0x999999)];
    [linkButton addSubview:underlineView];
    
    arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-25, 18, 15, 8)];
    //    [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_02.png"]];
    [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down.png"]];
    [self addSubview:arrowImageView];
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 44)];
    [blankButton setBackgroundColor:[UIColor clearColor]];
    [blankButton addTarget:self action:@selector(touchBenefitButton:) forControlEvents:UIControlEventTouchUpInside];
    [blankButton setSelected:NO];
    [self addSubview:blankButton];
    
    //구분선
    lineView = [[UIView alloc] init];
    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [self addSubview:lineView];
    
    if (benefitAdText) {
        [lineView setFrame:CGRectMake(0, CGRectGetMaxY(linkButton.frame)+14, kScreenBoundsWidth, 1)];
    }
    else {
        [lineView setFrame:CGRectMake(0, CGRectGetMaxY(detailLabel.frame)+14, kScreenBoundsWidth, 1)];
    }
    
    //프레임 재설정
    frameHeight = CGRectGetMaxY(lineView.frame);
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            frameHeight);
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
        [self.delegate didTouchExpandButton:CPProductViewTypeBenefit height:frameHeight+CGRectGetHeight(containerView.frame)];
    }
    
//
    //상세내역 - benefitLayer
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 0)];
    [containerView setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [containerView setClipsToBounds:YES];
    [self addSubview:containerView];
    
    CGFloat originY = 7;
    
    for (NSInteger i = 0; i < benefitItems.count; i++) {
        NSDictionary *itemInfo = benefitItems[i];
        
        CGFloat originX = 8;
        
        //기본 레이블
        if (itemInfo[@"label"]) {
            NSString *title = itemInfo[@"label"];
            CGSize labelSize = GET_STRING_SIZE(title, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY+i*30, labelSize.width, 30)];
            [titleLabel setTextColor:UIColorFromRGB(0x333333)];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:14]];
            [titleLabel setTextAlignment:NSTextAlignmentLeft];
            [titleLabel setText:title];
            [containerView addSubview:titleLabel];
            
            originX = CGRectGetMaxX(titleLabel.frame);
            
            if (i == benefitItems.count -1) {
                UIView *containerViewLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+6, kScreenBoundsWidth, 1)];
                [containerViewLineView setBackgroundColor:UIColorFromRGB(0xededed)];
                [containerView addSubview:containerViewLineView];
            }
        }
        
        //상세 레이블
        if (itemInfo[@"bfText"]) {
            NSString *desc = itemInfo[@"bfText"];
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
        if (itemInfo[@"helpLinkUrl"] && !nilCheck(itemInfo[@"helpLinkUrl"])) {
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [infoButton setFrame:CGRectMake(originX+2, originY+i*30-1, 32, 32)];
            [infoButton setImage:[UIImage imageNamed:@"ic_pd_information.png"] forState:UIControlStateNormal];
            [infoButton addTarget:self action:@selector(touchInfoButton:) forControlEvents:UIControlEventTouchUpInside];
            [infoButton setTag:i];
            [containerView addSubview:infoButton];
            
            originX = CGRectGetMaxX(infoButton.frame);
        }
        
        //이벤트
        if (itemInfo[@"cpnLinkText"]) {
            
            NSString *link = itemInfo[@"cpnLinkText"];
            CGSize linkLabelSize = GET_STRING_SIZE(link, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
            
            UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [linkButton setFrame:CGRectMake(originX+5, originY+i*30-1, linkLabelSize.width, 30)];
            [linkButton setTitle:link forState:UIControlStateNormal];
            [linkButton addTarget:self action:@selector(touchEventLinkButton:) forControlEvents:UIControlEventTouchUpInside];
            [linkButton setTag:i];
            [linkButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            [linkButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [containerView addSubview:linkButton];
            
            UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 23, linkButton.frame.size.width, 1)];
            [underLineView setBackgroundColor:UIColorFromRGB(0x999999)];
            [linkButton addSubview:underLineView];
        }
    }
}

#pragma mark - API

- (void)getBenefitAdLinkData
{
    void (^benefitAdLinkSuccess)(NSDictionary *);
    benefitAdLinkSuccess = ^(NSDictionary *benefitAdLinkData) {
        
        if (benefitAdLinkData && [benefitAdLinkData count] > 0) {
            benefitAdText = benefitAdLinkData[@"TEXT"];
            benefitAdUrl = benefitAdLinkData[@"LURL1"];
        }
        
        [self initLayout];
    };
    
    void (^benefitAdLinkFailure)(NSError *);
    benefitAdLinkFailure = ^(NSError *error) {
        [self initLayout];
    };
    
    NSString *url = product[@"benefitAdLinkUrl"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:benefitAdLinkSuccess
                                                         failure:benefitAdLinkFailure];
    }
    else {
        [self initLayout];
    }
}

#pragma mark - Selectors

- (void)touchBenefitButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.isSelected) {
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down.png"]];
        [containerView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 0)];
    }
    else {
        [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_up_01.png"]];
        [containerView setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), CGRectGetWidth(self.frame), 14+benefitItems.count*30)];
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchExpandButton: height:)]) {
        [self.delegate didTouchExpandButton:CPProductViewTypeBenefit height:frameHeight+CGRectGetHeight(containerView.frame)];
    }
    
    [button setSelected:!button.isSelected];
    
    //AccessLog - 혜택 영역 열기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPD01"];
}

- (void)touchInfoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *itemInfo = benefitItems[button.tag];
    
    if (!nilCheck(itemInfo[@"helpLinkUrl"]) && [self.delegate respondsToSelector:@selector(didTouchBenefitInfoButton:helpTitle:)]) {
        [self.delegate didTouchBenefitInfoButton:itemInfo[@"helpLinkUrl"] helpTitle:itemInfo[@"helpTitle"]];
    }
    
    //AccessLog - 무이자할부 레이어 열기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPD02"];
}

- (void)touchLinkButton:(id)sender
{
//    if (!nilCheck(benefitInfo[@"adLinkUrl"]) && [self.delegate respondsToSelector:@selector(didTouchBenefitLinkButton:)]) {
//        [self.delegate didTouchBenefitLinkButton:benefitInfo[@"adLinkUrl"]];
//    }
    if (!nilCheck(benefitAdUrl) && [self.delegate respondsToSelector:@selector(didTouchBenefitLinkButton:)]) {
        [self.delegate didTouchBenefitLinkButton:benefitAdUrl];
    }
    
    //AccessLog - 텍스트광고 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPD03"];
}

- (void)touchEventLinkButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *linkUrl = benefitItems[button.tag][@"cpnLinkUrl"];

    if ([self.delegate respondsToSelector:@selector(didTouchEventLinkButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchEventLinkButton:linkUrl];
        }
    }
}

@end
