//
//  CPProductPriceView.m
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductPriceView.h"
#import "NSTimer+Blocks.h"
#import "NSString+URLEncodedString.h"
#import "AccessLog.h"

@interface CPProductPriceView ()
{
    NSDictionary *product;
    
    //상품명
    UILabel *productNameLabel;
    
    //가격영역
    UIView *priceView;
    UILabel *discountRateLabel;
    UILabel *discountRateWonLabel;
    UILabel *discountTextLabel;
    
    UILabel *finalPriceLabel;
    UILabel *finalPriceWonLabel;
    
    UILabel *originalPriceLabel;
    UIView *originalPriceLine;
    
    UILabel *perPriceLabel;
    
    //쿠폰가격영역
    UIView *couponPriceView;
    UILabel *couponTextLabel;
    UILabel *couponPriceLabel;
    UILabel *couponPriceWonLabel;
    
    //상품 상태정보 영역
    UIView *statementView;
    
    //쇼킹딜 영역
    UIView *shockingdealView;
    UIView *timeContainerView;
    UIImageView *timeImageView;
    UILabel *timeLabel;
    UILabel *dayLabel;
    UILabel *hourLabel;
    UIView *middleLineView;
    UILabel *sellCountLabel;
    NSTimer *timer;
    
    //만족도 & 리뷰후기 영역
    UIView *reviewView;
    
    BOOL isSmallScreen;
    BOOL isShockingDeal;
    
    CGFloat orginY;
}

@end

@implementation CPProductPriceView

- (void)releaseItem
{
    if (product) product = nil;
    if (productNameLabel) productNameLabel = nil;
    if (priceView) priceView = nil;
    if (discountRateLabel) discountRateLabel = nil;
    if (discountRateWonLabel) discountRateWonLabel = nil;
    if (discountTextLabel) discountTextLabel = nil;
    if (finalPriceLabel) finalPriceLabel = nil;
    if (finalPriceWonLabel) finalPriceWonLabel = nil;
    if (originalPriceLabel) originalPriceLabel = nil;
    if (originalPriceLine) originalPriceLine = nil;
    if (perPriceLabel) perPriceLabel = nil;
    if (couponPriceView) couponPriceView = nil;
    if (couponTextLabel) couponTextLabel = nil;
    if (couponPriceLabel) couponPriceLabel = nil;
    if (couponPriceWonLabel) couponPriceWonLabel = nil;
    if (statementView) statementView = nil;
    if (shockingdealView) shockingdealView = nil;
    if (timeContainerView) timeContainerView = nil;
    if (timeImageView) timeImageView = nil;
    if (timeLabel) timeLabel = nil;
    if (dayLabel) dayLabel = nil;
    if (hourLabel) hourLabel = nil;
    if (middleLineView) middleLineView = nil;
    if (sellCountLabel) sellCountLabel = nil;
    if (timer) timer = nil;
    if (reviewView) reviewView = nil;
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
        
        [self initLayout];
        
        [self startCountDown];
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];;
    
    isSmallScreen = ([UIScreen mainScreen].bounds.size.height <= 568 ? YES : NO);
    
    NSString *prdNm = @"";
    if ([product[@"prdNm"] isKindOfClass:[NSString class]]) {
        prdNm = product[@"prdNm"];
    }
    else {
        prdNm = product[@"prdNm"][0];
    }

    //상품 이름
    productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0)];
    [productNameLabel setTextColor:UIColorFromRGB(0x1f1f1f)];
    [productNameLabel setBackgroundColor:[UIColor clearColor]];
    [productNameLabel setFont:[UIFont systemFontOfSize:15]];
    [productNameLabel setTextAlignment:NSTextAlignmentLeft];
    [productNameLabel setNumberOfLines:2];
    [productNameLabel setText:prdNm];
    [self addSubview:productNameLabel];
    
    [productNameLabel sizeToFitWithVersionHoldWidth];
    
    //상품 상태에 따라 분기
    if (product[@"selStatStmt"] && [@"N" isEqualToString:product[@"optDrawerYn"]]) {
        //상품 상태정보
        [self initStatementView];
    }
    else {
        //가격정보
        [self initPriceView];
    }

    //쇼킹딜 - isDealPrd, dealSelEndTime, dealSelQty
    [self initShockingDealView];
    
    //만족도, 리뷰 영역 - prdSatisfy, prdReview, prdPost
    [self initReviewView];
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            orginY);
}

- (void)reloadLayout
{
    if (!(product[@"selStatStmt"] && [@"N" isEqualToString:product[@"optDrawerYn"]])) {
        [self initPriceView];
        
        [self initShockingDealView];
        
        [self initReviewView];
    }
}

- (void)initStatementView
{
    // 예: 102:전시중, 103:판매중, 104:품절, 105:판매중지, 106:판매종료, 107:판매강제종료, 108:판매금지
    NSString *selStatStmt = product[@"selStatStmt"];
    
    statementView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productNameLabel.frame)+9, CGRectGetWidth(self.frame), 46)];
    [statementView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:statementView];
    
    UILabel *statementLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, CGRectGetWidth(statementView.frame)+20, CGRectGetHeight(statementView.frame)-9)];
    [statementLabel setText:selStatStmt];
    [statementLabel setFont:[UIFont systemFontOfSize:14]];
    [statementLabel setTextColor:UIColorFromRGB(0x999999)];
    [statementLabel setTextAlignment:NSTextAlignmentCenter];
    [statementLabel setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [statementView addSubview:statementLabel];
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(statementView.frame)-1, CGRectGetWidth(statementView.frame)+20, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [statementView addSubview:underLineView];
    
    orginY = CGRectGetMaxY(statementView.frame);
}

- (void)initPriceView
{
    NSDictionary *priceInfo = product[@"prdPrice"];
    
    for (UIView *subView in priceView.subviews) {
        [subView removeFromSuperview];
    }
    
    priceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productNameLabel.frame)+9, CGRectGetWidth(self.frame), 46)];
    [priceView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:priceView];
    
    //특별가 및 할인가
    NSInteger discountRateResult;
    NSString *discountRate = @"";
    if ([Modules isInteger:priceInfo[@"discountRate"] result:&discountRateResult]) {
        
        //쇼킹딜 상품만 5%이하일대 특별가
        if (discountRateResult <= 5 && [product[@"dealPrdYn"] isEqualToString:@"Y"]) {
            discountRateResult = -1;
            discountRate = @"특별가";
        }
        else {
            discountRate = [NSString stringWithFormat:@"%ld", (long)discountRateResult];
        }
    }
    else {
        discountRate = priceInfo[@"discountRate"];
    }
    
    discountRateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    discountRateLabel.textColor = UIColorFromRGB(0xf62e3d);
    [discountRateLabel setBackgroundColor:[UIColor clearColor]];
//    discountRateLabel.font = [UIFont systemFontOfSize:(isSmallScreen ? 32 : 46)];
    discountRateLabel.font = [UIFont systemFontOfSize:46];
    discountRateLabel.numberOfLines = 1;
    discountRateLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:discountRateLabel];
    
    discountRateWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    discountRateWonLabel.textColor = UIColorFromRGB(0xf62e3d);
    discountRateWonLabel.font = [UIFont systemFontOfSize:26];
    discountRateWonLabel.numberOfLines = 1;
    discountRateWonLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:discountRateWonLabel];
    
    discountTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    discountTextLabel.textColor = [discountRate isEqualToString:@"판매가"] ? UIColorFromRGB(0x666666) : UIColorFromRGB(0xf62e3d);
    discountTextLabel.font = [UIFont boldSystemFontOfSize:(isSmallScreen ? 22 : 25)];
    discountTextLabel.numberOfLines = 1;
    discountTextLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:discountTextLabel];
    
    CGFloat offsetX = 0.f;
    if (discountRateResult == -1) {
        //문자일 경우
        discountTextLabel.text = discountRate;
        [discountTextLabel sizeToFitWithFloor];
        
        discountTextLabel.frame = CGRectMake(0,
                                             CGRectGetHeight(priceView.frame)-CGRectGetHeight(discountTextLabel.frame)-6,
                                             CGRectGetWidth(discountTextLabel.frame),
                                             CGRectGetHeight(discountTextLabel.frame));
        discountTextLabel.hidden = NO;
        discountRateLabel.hidden = YES;
        discountRateWonLabel.hidden = YES;
        
        offsetX = CGRectGetMaxX(discountTextLabel.frame) + 8;
    }
    else {
        discountRateLabel.text = discountRate;
        [discountRateLabel sizeToFitWithFloor];
        
        if (isSmallScreen) {
            discountRateWonLabel.font = [UIFont systemFontOfSize:18];
        }
        
        discountRateWonLabel.text = @"%";
        [discountRateWonLabel sizeToFitWithFloor];
        
        CGFloat rateLabelOffsetY = CGRectGetHeight(priceView.frame)-CGRectGetHeight(discountRateLabel.frame);
        if (isSmallScreen) {
            rateLabelOffsetY = rateLabelOffsetY - 4;
        }
        
        discountRateLabel.frame = CGRectMake(0, rateLabelOffsetY, CGRectGetWidth(discountRateLabel.frame), CGRectGetHeight(discountRateLabel.frame));
        
        CGFloat rateWonLabelOffsetY = CGRectGetHeight(priceView.frame)-CGRectGetHeight(discountRateWonLabel.frame)-4;
        if (isSmallScreen) {
            rateWonLabelOffsetY = rateWonLabelOffsetY - 2;
        }
        
        discountRateWonLabel.frame = CGRectMake(CGRectGetMaxX(discountRateLabel.frame),
                                                rateWonLabelOffsetY,
                                                CGRectGetWidth(discountRateWonLabel.frame),
                                                CGRectGetHeight(discountRateWonLabel.frame));
        
        discountTextLabel.hidden = YES;
        discountRateLabel.hidden = NO;
        discountRateWonLabel.hidden = NO;
        
        offsetX = CGRectGetMaxX(discountRateWonLabel.frame) + 8;
    }
    
    //최종 할인가
    finalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    finalPriceLabel.textColor = UIColorFromRGB(0x333333);
    finalPriceLabel.backgroundColor = [UIColor clearColor];
    finalPriceLabel.font = [UIFont boldSystemFontOfSize:27];
    finalPriceLabel.numberOfLines = 1;
    finalPriceLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:finalPriceLabel];
    
    finalPriceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    finalPriceWonLabel.textColor = UIColorFromRGB(0x333333);
    finalPriceWonLabel.font = [UIFont systemFontOfSize:17];
    finalPriceWonLabel.numberOfLines = 1;
    finalPriceWonLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:finalPriceWonLabel];
    
    finalPriceLabel.text = [[NSString stringWithFormat:@"%ld",
                              (long)[priceInfo[@"finalDscPrc"] integerValue]] stringByInsertingComma];
    [finalPriceLabel sizeToFitWithFloor];
    
    finalPriceWonLabel.text = @"원";
    [finalPriceWonLabel sizeToFitWithFloor];
    
    finalPriceLabel.frame = CGRectMake(offsetX,
                                       CGRectGetHeight(priceView.frame)-CGRectGetHeight(finalPriceLabel.frame)-4,
                                       CGRectGetWidth(finalPriceLabel.frame),
                                       CGRectGetHeight(finalPriceLabel.frame));
    
    finalPriceWonLabel.frame = CGRectMake(CGRectGetMaxX(finalPriceLabel.frame)+1,
                                          CGRectGetHeight(priceView.frame)-CGRectGetHeight(finalPriceWonLabel.frame)-7,
                                          CGRectGetWidth(finalPriceWonLabel.frame),
                                          CGRectGetHeight(finalPriceWonLabel.frame));
    
    //원가
    originalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    originalPriceLabel.textColor = UIColorFromRGB(0xafafaf);
    originalPriceLabel.backgroundColor = [UIColor clearColor];
    originalPriceLabel.font = [UIFont systemFontOfSize:15];
    originalPriceLabel.numberOfLines = 1;
    originalPriceLabel.textAlignment = NSTextAlignmentLeft;
    [priceView addSubview:originalPriceLabel];
    
    NSString *originalPriceStr = [[NSString stringWithFormat:@"%ld",
                                   (long)[priceInfo[@"selPrc"] integerValue]] stringByInsertingComma];
    originalPriceLabel.text = [NSString stringWithFormat:@"%@원", originalPriceStr];
    [originalPriceLabel sizeToFitWithFloor];
    
//    originalPriceLabel.frame = CGRectMake(CGRectGetMaxX(finalPriceWonLabel.frame)+5,
//                                          CGRectGetMaxY(finalPriceWonLabel.frame)-CGRectGetHeight(originalPriceLabel.frame),
//                                          CGRectGetWidth(originalPriceLabel.frame),
//                                          CGRectGetHeight(originalPriceLabel.frame));
    originalPriceLabel.frame = CGRectMake(offsetX,
                                          -2,
                                          CGRectGetWidth(originalPriceLabel.frame),
                                          CGRectGetHeight(originalPriceLabel.frame));
    
    originalPriceLine = [[UIView alloc] initWithFrame:CGRectMake(originalPriceLabel.frame.origin.x-1,
                                                                 originalPriceLabel.center.y,
                                                                 originalPriceLabel.frame.size.width+2,
                                                                 1)];
    originalPriceLine.backgroundColor = UIColorFromRGB(0x999999);
    [priceView addSubview:originalPriceLine];
    
//    if (discountRateResult == -1) {
    if (priceInfo[@"selPrc"] && [priceInfo[@"selPrc"] integerValue] == [priceInfo[@"finalDscPrc"] integerValue]) {
        originalPriceLabel.hidden = YES;
        originalPriceLine.hidden = YES;
    }
    
    //개당 가격
    if (priceInfo[@"catalogPerPrc"]) {
        perPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        perPriceLabel.textColor = UIColorFromRGB(0x333333);
        perPriceLabel.font = [UIFont systemFontOfSize:16];
        perPriceLabel.numberOfLines = 1;
        perPriceLabel.textAlignment = NSTextAlignmentLeft;
        [priceView addSubview:perPriceLabel];
        
        perPriceLabel.text = [NSString stringWithFormat:@"(%@)", priceInfo[@"catalogPerPrc"]];
        [perPriceLabel sizeToFitWithFloor];
        
        perPriceLabel.frame = CGRectMake(CGRectGetMaxX(finalPriceWonLabel.frame)+5,
                                         CGRectGetHeight(priceView.frame)-CGRectGetHeight(perPriceLabel.frame)-6.5f,
                                         CGRectGetWidth(perPriceLabel.frame),
                                         CGRectGetHeight(perPriceLabel.frame));
    }
    
    orginY = CGRectGetMaxY(priceView.frame);
    
    //쿠폰적용가 영역
    if ([Modules checkLoginFromCookie] && self.couponInfo) {
    
        if (couponPriceView) {
            [couponPriceView removeFromSuperview];
            
            for (UIView *subView in couponPriceView.subviews) {
                [subView removeFromSuperview];
            }
        }
    
        couponPriceView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, CGRectGetWidth(self.frame), 40)];
        [couponPriceView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:couponPriceView];
        
        //쿠폰적용가
        couponTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        couponTextLabel.textColor = UIColorFromRGB(0x656565);
        couponTextLabel.font = [UIFont systemFontOfSize:(isSmallScreen ? 11 : 13)];
        couponTextLabel.numberOfLines = 1;
        couponTextLabel.textAlignment = NSTextAlignmentLeft;
        couponTextLabel.text = @"쿠폰적용가";
        [couponPriceView addSubview:couponTextLabel];
    
        couponPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        couponPriceLabel.textColor = UIColorFromRGB(0x333333);
        couponPriceLabel.font = [UIFont boldSystemFontOfSize:19];
        couponPriceLabel.numberOfLines = 1;
        couponPriceLabel.textAlignment = NSTextAlignmentLeft;
        [couponPriceView addSubview:couponPriceLabel];
        
        couponPriceLabel.text = [[NSString stringWithFormat:@"%ld",
                                  (long)[self.couponInfo[@"TOTAL_AMT"] integerValue]] stringByInsertingComma];
    
        couponPriceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        couponPriceWonLabel.textColor = UIColorFromRGB(0x333333);
        couponPriceWonLabel.font = [UIFont systemFontOfSize:13];
        couponPriceWonLabel.numberOfLines = 1;
        couponPriceWonLabel.textAlignment = NSTextAlignmentLeft;
        couponPriceWonLabel.text = @"원";
        [couponPriceView addSubview:couponPriceWonLabel];
        
        [couponTextLabel sizeToFitWithFloor];
        [couponPriceLabel sizeToFitWithFloor];
        [couponPriceWonLabel sizeToFitWithFloor];
        
        couponTextLabel.frame = CGRectMake(0,
                                           CGRectGetHeight(couponPriceView.frame)-CGRectGetHeight(couponTextLabel.frame)-14,
                                           CGRectGetWidth(couponTextLabel.frame),
                                           CGRectGetHeight(couponTextLabel.frame));
        
        couponPriceLabel.frame = CGRectMake(CGRectGetMinX(finalPriceLabel.frame),
                                           CGRectGetHeight(couponPriceView.frame)-CGRectGetHeight(couponPriceLabel.frame)-12,
                                           CGRectGetWidth(couponPriceLabel.frame),
                                           CGRectGetHeight(couponPriceLabel.frame));
        
        couponPriceWonLabel.frame = CGRectMake(CGRectGetMaxX(couponPriceLabel.frame),
                                              CGRectGetHeight(couponPriceView.frame)-CGRectGetHeight(couponPriceWonLabel.frame)-14,
                                              CGRectGetWidth(couponPriceWonLabel.frame),
                                              CGRectGetHeight(couponPriceWonLabel.frame));
        
        
        orginY = CGRectGetMaxY(couponPriceView.frame);
        
        if (![@"y" isEqualToString:[product[@"dealPrdYn"] lowercaseString]]) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(couponPriceView.frame)-1, kScreenBoundsWidth, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
            [couponPriceView addSubview:lineView];
        }
    }
    else {
        if (![@"y" isEqualToString:[product[@"dealPrdYn"] lowercaseString]]) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(priceView.frame)-1, kScreenBoundsWidth, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
            [priceView addSubview:lineView];
        }
    }
}

- (void)initShockingDealView
{
    isShockingDeal = [@"y" isEqualToString:[product[@"dealPrdYn"] lowercaseString]];
    
    if (isShockingDeal) {
        
        if (shockingdealView) {
            [shockingdealView removeFromSuperview];
            
            for (UIView *subView in shockingdealView.subviews) {
                [subView removeFromSuperview];
            }
        }
        
        shockingdealView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY+4, CGRectGetWidth(self.frame), 37)];
        [shockingdealView setBackgroundColor:UIColorFromRGB(0xffecea)];
        [self addSubview:shockingdealView];
        
        //로고
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 57, 23)];
        [logoImageView setImage:[UIImage imageNamed:@"logo_pd_shockingdeal.png"]];
        [shockingdealView addSubview:logoImageView];
        
        timeContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoImageView.frame), 0, CGRectGetWidth(shockingdealView.frame)-CGRectGetMaxX(logoImageView.frame), 37)];
        [timeContainerView setBackgroundColor:[UIColor clearColor]];
        [shockingdealView addSubview:timeContainerView];
        
        timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoImageView.frame)+15, 11, 15, 15)];
        [timeImageView setImage:[UIImage imageNamed:@"ic_pd_time.png"]];
        [timeContainerView addSubview:timeImageView];
        
        //남은 시간 설정
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, CGRectGetHeight(timeContainerView.frame))];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = UIColorFromRGB(0xff1313);
        timeLabel.font = [UIFont systemFontOfSize:14];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [timeContainerView addSubview:timeLabel];
        
        timeLabel.text = @"";
        
        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.center.x-56, 0, 23, CGRectGetHeight(timeContainerView.frame))];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.font = [UIFont systemFontOfSize:14];
        dayLabel.textColor = UIColorFromRGB(0xff1313);
        dayLabel.textAlignment = NSTextAlignmentRight;
        [timeContainerView addSubview:dayLabel];
        
        hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.center.x-21, 0, 23, CGRectGetHeight(timeContainerView.frame))];
        hourLabel.backgroundColor = [UIColor clearColor];
        hourLabel.font = [UIFont systemFontOfSize:14];
        hourLabel.textColor = UIColorFromRGB(0xff1313);
        hourLabel.textAlignment = NSTextAlignmentRight;
        [timeContainerView addSubview:hourLabel];
        
        //라인
        middleLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeLabel.frame)+13, 11.5f, 1, 14)];
        middleLineView.backgroundColor = UIColorFromRGBA(0xa80a00, 0.15f);
        [timeContainerView addSubview:middleLineView];
        
        //구매 갯수
        NSInteger count = [product[@"dealSelQty"] integerValue];
        NSString *sellCountString;
        if (count > 0) {
            NSString *countString = [[NSString stringWithFormat:@"%ld", (long)count] stringByInsertingComma];
            sellCountString = [countString stringByAppendingString:@"개 구매"];
        }
        else {
            sellCountString = @"쇼킹딜 추천상품";
        }
        
        CGSize labelSize = GET_STRING_SIZE(sellCountString, [UIFont systemFontOfSize:14], kScreenBoundsWidth/2);
        sellCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(middleLineView.frame)+12, 0, labelSize.width, CGRectGetHeight(timeContainerView.frame))];
        sellCountLabel.backgroundColor = [UIColor clearColor];
        sellCountLabel.textColor = UIColorFromRGB(0xff1313);
        sellCountLabel.font = [UIFont systemFontOfSize:14];
        sellCountLabel.textAlignment = NSTextAlignmentCenter;
        sellCountLabel.text = sellCountString;
        [timeContainerView addSubview:sellCountLabel];
        
        orginY = CGRectGetMaxY(shockingdealView.frame)+11;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(shockingdealView.frame)+10, kScreenBoundsWidth, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
        [shockingdealView addSubview:lineView];
    }
}

- (void)initReviewView
{
    if (reviewView) {
        [reviewView removeFromSuperview];
        
        for (UIView *subView in reviewView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    reviewView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, CGRectGetWidth(self.frame), 44)];
    [reviewView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:reviewView];
    
    //만족도 70% 미만은 비노출
    if (product[@"prdSatisfy"]) {
        CGFloat rating = [product[@"prdSatisfy"] floatValue];
        if (rating < 3.5) {
            
            [reviewView setFrame:CGRectMake(0, orginY, CGRectGetWidth(self.frame), 1)];
            
//            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 1)];
////            [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
//            [lineView setBackgroundColor:[UIColor redColor]];
//            [reviewView addSubview:lineView];
            
            orginY = CGRectGetMaxY(reviewView.frame);
            return;
        }
    }
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 1)];
//    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
//    [reviewView addSubview:lineView];
    
    UIView *ratingView = [[UIView alloc] initWithFrame:CGRectZero];
    [reviewView addSubview:ratingView];
    
    //만족도 - prdSatisfy
    NSString *title = @"만족도";
    CGSize labelSize = GET_STRING_SIZE(title, [UIFont systemFontOfSize:15], kScreenBoundsWidth);
    
    UILabel *ratingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, CGRectGetHeight(reviewView.frame))];
    [ratingTitleLabel setText:title];
    [ratingTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [ratingTitleLabel setTextColor:UIColorFromRGB(0x333333)];
    [ratingView addSubview:ratingTitleLabel];
    
    CGFloat orginX = CGRectGetMaxX(ratingTitleLabel.frame) + 5;
    if (product[@"prdSatisfy"]) {
        UIImage *starImage = [UIImage imageNamed:@"ic_pd_star_on.png"];
        CGFloat rating = [product[@"prdSatisfy"] floatValue];
        
        for (int i = 0; i < 5; i++) {
            
            if (i >= rating) {
                starImage = [UIImage imageNamed:@"ic_pd_star_off.png"];
            }
            if (i+0.5f == rating) {
                starImage = [UIImage imageNamed:@"ic_pd_star_half.png"];
            }
            
            UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(orginX+(12*i), 16.5f, 11, 11)];
            [starImageView setImage:starImage];
            [ratingView addSubview:starImageView];
        }
    }
    
    [ratingView setFrame:CGRectMake(0, 0, orginX+60, CGRectGetHeight(reviewView.frame))];
    [ratingView setCenter:CGPointMake(CGRectGetWidth(reviewView.frame)/4, CGRectGetHeight(reviewView.frame)/2)];
    
    UIView *verticalineView = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2, 0, 1, 44)];
    [verticalineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [reviewView addSubview:verticalineView];
    
    //리뷰/후기 - prdReview, prdPost
    UIView *reviewCountView = [[UIView alloc] initWithFrame:CGRectZero];
    [reviewView addSubview:reviewCountView];
    
    NSString *countTitle = @"리뷰/후기";
    CGSize countLabelSize = GET_STRING_SIZE(countTitle, [UIFont systemFontOfSize:15], kScreenBoundsWidth);
    
    UILabel *countTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, countLabelSize.width, CGRectGetHeight(reviewView.frame))];
    [countTitleLabel setText:countTitle];
    [countTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [countTitleLabel setTextColor:UIColorFromRGB(0x333333)];
    [reviewCountView addSubview:countTitleLabel];
    
    NSInteger reviewCount = [product[@"prdReview"][@"totalCount"] integerValue];
    NSInteger postCount = [product[@"prdPost"][@"totalCount"] integerValue];
    
    NSString *countString = [NSString stringWithFormat:@"%@건", [[NSString stringWithFormat:@"%ld", (long)reviewCount+postCount] stringByInsertingComma]];//@"2,390건";
    if (reviewCount+postCount > 99999) countString = @"99,999+건";
    
    CGSize countStringLabelSize = GET_STRING_SIZE(countString, [UIFont systemFontOfSize:13], kScreenBoundsWidth);
    
    UILabel *countStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(countTitleLabel.frame)+7, 0, countStringLabelSize.width, CGRectGetHeight(reviewView.frame))];
    [countStringLabel setText:countString];
    [countStringLabel setFont:[UIFont systemFontOfSize:13]];
    [countStringLabel setTextColor:UIColorFromRGB(0x5460de)];
    [reviewCountView addSubview:countStringLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(countStringLabel.frame)+6, 16.5f, 6, 11)];
    [arrowImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_right.png"]];
    [reviewCountView addSubview:arrowImageView];
    
    [reviewCountView setFrame:CGRectMake(0, 0, CGRectGetMaxX(arrowImageView.frame), CGRectGetHeight(reviewView.frame))];
    [reviewCountView setCenter:CGPointMake(CGRectGetMaxX(verticalineView.frame) + (kScreenBoundsWidth-20-CGRectGetMaxX(verticalineView.frame))/2 + 4, CGRectGetHeight(reviewView.frame)/2)];
    
    UIButton *reviewCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reviewCountButton setFrame:reviewCountView.frame];
    [reviewCountButton setBackgroundColor:[UIColor clearColor]];
    [reviewCountButton addTarget:self action:@selector(touchReivewButton:) forControlEvents:UIControlEventTouchUpInside];
    [reviewView addSubview:reviewCountButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, 43, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [reviewView addSubview:lineView];
    
    orginY = CGRectGetMaxY(reviewView.frame);
}

#pragma mark - Selectors

- (void)touchReivewButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchReviewButton)]) {
        [self.delegate didTouchReviewButton];
    }
    
    //AccessLog - 리뷰/후기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPB01"];
}

#pragma mark - Timer

- (void)startCountDown
{
    //11번가 상품일 경우 리턴
    if (!isShockingDeal) {
        return;
    }
    
    if (!timer && !nilCheck(product[@"dealSelEndTime"])) {
        [self updateCountDown:product[@"dealSelEndTime"]];
//        [self updateCountDown:@"20150711191059"];
    }
    else {
        [self closeProductItem];
    }
}

- (void)stopCountDown
{
    if (timer && timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)displayCountDown:(NSString *)restTime
{
    NSString *endTime = restTime;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now = [NSDate date], *dateFromString = nil;
    
    NSDateFormatter *nowFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [nowFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    dateFromString = [dateFormatter dateFromString:endTime];
    
    NSDateComponents *componentsDaysDiff = [gregorianCalendar components:NSCalendarUnitDay fromDate:now toDate:dateFromString options:0];
    NSDateComponents *componentsHourDiff = [gregorianCalendar components:NSCalendarUnitHour fromDate:now toDate:dateFromString options:0];
    NSDateComponents *componentsMintDiff = [gregorianCalendar components:NSCalendarUnitMinute fromDate:now toDate:dateFromString options:0];
    NSDateComponents *componentsSecDiff = [gregorianCalendar components:NSCalendarUnitSecond fromDate:now toDate:dateFromString options:0];
    
    [dayLabel setHidden:NO];
    [hourLabel setHidden:NO];
    
    if (componentsDaysDiff.day > 0) {
        dayLabel.frame = CGRectMake(timeLabel.center.x-56, 0, 23, CGRectGetHeight(timeContainerView.frame));
        hourLabel.frame = CGRectMake(timeLabel.center.x-21, 0, 23, CGRectGetHeight(timeContainerView.frame));
        hourLabel.textAlignment = NSTextAlignmentRight;
        
//        timeLabel.text = @"     일      시간 남음";
        dayLabel.text = [NSString stringWithFormat:@"%ld", (long)componentsDaysDiff.day];
        hourLabel.text = [NSString stringWithFormat:@"%ld", (long)(componentsHourDiff.hour - componentsDaysDiff.day * 24)];
        
        timeLabel.text = [NSString stringWithFormat:@"%@일 %@시간 남음", dayLabel.text, hourLabel.text];
        CGSize timeLabelSize = GET_STRING_SIZE(timeLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        CGSize sellCountLabelSize = GET_STRING_SIZE(sellCountLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        CGFloat firstLabelWidth = CGRectGetWidth(timeImageView.frame)+5+timeLabelSize.width;
        CGFloat secondLabelWidth = sellCountLabelSize.width;
        CGFloat marginWidth = (CGRectGetWidth(timeContainerView.frame)-firstLabelWidth-secondLabelWidth)/4;
        
        [timeImageView setFrame:CGRectMake(marginWidth, 11, 15, 15)];
        [timeLabel setFrame:CGRectMake(CGRectGetMaxX(timeImageView.frame)+5, 0, timeLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
        [middleLineView setFrame:CGRectMake(CGRectGetMaxX(timeLabel.frame)+marginWidth, 11.5f, 1, 14)];
        [sellCountLabel setFrame:CGRectMake(CGRectGetMaxX(middleLineView.frame)+marginWidth, 0, sellCountLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
        
        [dayLabel setHidden:YES];
        [hourLabel setHidden:YES];
    }
    else if (componentsDaysDiff.day <= 0 && componentsHourDiff.hour >= 1) {
        dayLabel.frame = CGRectZero;
        hourLabel.frame = CGRectMake(timeLabel.center.x-40, 0, 23, CGRectGetHeight(timeContainerView.frame));
        hourLabel.textAlignment = NSTextAlignmentRight;
        
//        timeLabel.text = @"    시간 남음";
        dayLabel.text = @"";
        hourLabel.text = [NSString stringWithFormat:@"%ld", (long)(componentsHourDiff.hour - componentsDaysDiff.day * 24)];
        
        timeLabel.text = [NSString stringWithFormat:@"%@시간 남음", hourLabel.text];
        CGSize timeLabelSize = GET_STRING_SIZE(timeLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        CGSize sellCountLabelSize = GET_STRING_SIZE(sellCountLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        CGFloat firstLabelWidth = CGRectGetWidth(timeImageView.frame)+5+timeLabelSize.width;
        CGFloat secondLabelWidth = sellCountLabelSize.width;
        CGFloat marginWidth = (CGRectGetWidth(timeContainerView.frame)-firstLabelWidth-secondLabelWidth)/4;
        
        [timeImageView setFrame:CGRectMake(marginWidth, 11, 15, 15)];
        [timeLabel setFrame:CGRectMake(CGRectGetMaxX(timeImageView.frame)+5, 0, timeLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
        [middleLineView setFrame:CGRectMake(CGRectGetMaxX(timeLabel.frame)+marginWidth, 11.5f, 1, 14)];
        [sellCountLabel setFrame:CGRectMake(CGRectGetMaxX(middleLineView.frame)+marginWidth, 0, sellCountLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
        
        [dayLabel setHidden:YES];
        [hourLabel setHidden:YES];
    }
    else if (componentsDaysDiff.day <= 0 && componentsHourDiff.hour < 1 && (componentsMintDiff.minute + componentsSecDiff.second) > 0) {
        dayLabel.frame = CGRectZero;
        hourLabel.frame = timeLabel.frame;
        hourLabel.textAlignment = NSTextAlignmentCenter;
        
        dayLabel.text = @"";
        timeLabel.text = @"";
        
        hourLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                                (long)(componentsHourDiff.hour - componentsDaysDiff.day * 24),
                                (long)(componentsMintDiff.minute - componentsHourDiff.hour * 60),
                                (long)(componentsSecDiff.second - componentsMintDiff.minute * 60)];

        
        CGSize timeLabelSize = GET_STRING_SIZE(hourLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        CGSize sellCountLabelSize = GET_STRING_SIZE(sellCountLabel.text, [UIFont systemFontOfSize:14], kScreenBoundsWidth);
        
        CGFloat firstLabelWidth = CGRectGetWidth(timeImageView.frame)+5+timeLabelSize.width;
        CGFloat secondLabelWidth = sellCountLabelSize.width;
        CGFloat marginWidth = (CGRectGetWidth(timeContainerView.frame)-firstLabelWidth-secondLabelWidth)/4;
        
        [timeImageView setFrame:CGRectMake(marginWidth, 11, 15, 15)];
        [hourLabel setFrame:CGRectMake(CGRectGetMaxX(timeImageView.frame)+5, 0, timeLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
        [middleLineView setFrame:CGRectMake(CGRectGetMaxX(hourLabel.frame)+marginWidth, 11.5f, 1, 14)];
        [sellCountLabel setFrame:CGRectMake(CGRectGetMaxX(middleLineView.frame)+marginWidth, 0, sellCountLabelSize.width, CGRectGetHeight(timeContainerView.frame))];
    }
    else {
        [self closeProductItem];
    }
}

- (void)updateCountDown:(NSString *)restTime
{
    __weak NSString *endTime = restTime;
    
    [self displayCountDown:restTime];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.f block:^{
        [self displayCountDown:endTime];
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)closeProductItem
{
    dayLabel.frame = CGRectZero;
    hourLabel.frame = timeLabel.frame;
    hourLabel.textAlignment = NSTextAlignmentCenter;
    
    dayLabel.text = @"";
    timeLabel.text = @"";
    
    hourLabel.text = @"쇼킹딜 종료";
    
    [self stopCountDown];
    [self callDelegateMessage];
}

- (void)callDelegateMessage
{
    //DELEGATE 가 등록되기전 클로즈판단이 되었을 경우 대기한다.
//    if (!self.delegate) {
//        [self performSelector:@selector(callDelegateMessage) withObject:nil afterDelay:0.1f];
//        return;
//    }
//    
//    DELEGATE_CALL2(self.delegate,
//                   ProductItemPriceView:closeSellItem:,
//                   self,
//                   nil);
}

@end
