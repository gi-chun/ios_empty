//
//  CPProductLikeView.m
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductLikeView.h"
#import "AccessLog.h"

@interface CPProductLikeView()
{
    NSDictionary *product;
    NSDictionary *likeInfo;
    
    UIView *lineView;
    
    UIView *containerView;
    
    CGFloat itemHeight;
}

@end

@implementation CPProductLikeView

- (void)releaseItem
{
    if (product)        product = nil;
    if (likeInfo)       likeInfo = nil;
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
        
        if (product[@"prdLike"]) {
            likeInfo = [product[@"prdLike"] copy];
            
            [self initLayout];
        }
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];;
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:lineView];
    
    CGFloat buttonWidth = CGRectGetWidth(self.frame)/3;
    
    //선물하기는 비노출인 경우도 있다
    if ([product[@"giftYn"] isEqualToString:@"N"]) {
        buttonWidth = CGRectGetWidth(self.frame)/2;
    }
    
    UIImage *likeImage;
    NSString *likeTitie;
    UIColor *likeTitleColor;
    
    if ([likeInfo[@"likeYn"] isEqualToString:@"Y"] || [likeInfo[@"islike"] isEqualToString:@"Y"]) {
        likeImage = [UIImage imageNamed:@"ic_pd_like_full.png"];
        likeTitie = likeInfo[@"likeCnt"];
        likeTitleColor = UIColorFromRGB(0xff2434);
    }
    else {
        likeImage = [UIImage imageNamed:@"ic_pd_like.png"];
        likeTitleColor = UIColorFromRGB(0x333333);
        
        if ([likeInfo[@"likeCnt"] integerValue] > 0) {
            likeTitie = likeInfo[@"likeCnt"];
        }
        else {
            likeTitie = @"좋아요";
        }
    }
    
    //좋아요
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton setFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), buttonWidth-1, 44)];
    [_likeButton setImage:likeImage forState:UIControlStateNormal];
    [_likeButton setTitle:likeTitie forState:UIControlStateNormal];
    [_likeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_likeButton setTitleColor:likeTitleColor forState:UIControlStateNormal];
    [_likeButton setBackgroundColor:UIColorFromRGB(0xffffff)];
    [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_likeButton addTarget:self action:@selector(touchLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_likeButton];
    
    UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_likeButton.frame), CGRectGetMaxY(lineView.frame), 1, 44)];
    [verticalLineView setBackgroundColor:UIColorFromRGB(0xededed)];
    [self addSubview:verticalLineView];
    
    //공유하기
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setFrame:CGRectMake(buttonWidth*2, CGRectGetMaxY(lineView.frame), buttonWidth-1, 44)];
    [shareButton setImage:[UIImage imageNamed:@"ic_pd_share.png"] forState:UIControlStateNormal];
    [shareButton setTitle:@"공유하기" forState:UIControlStateNormal];
    [shareButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [shareButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [shareButton setBackgroundColor:UIColorFromRGB(0xffffff)];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [shareButton addTarget:self action:@selector(touchShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    //선물하기
    if ([product[@"giftYn"] isEqualToString:@"Y"]) {
        UIButton *giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [giftButton setFrame:CGRectMake(buttonWidth, CGRectGetMaxY(lineView.frame), buttonWidth-1, 44)];
        [giftButton setImage:[UIImage imageNamed:@"ic_pd_present.png"] forState:UIControlStateNormal];
        [giftButton setTitle:@"선물하기" forState:UIControlStateNormal];
        [giftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [giftButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [giftButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [giftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [giftButton addTarget:self action:@selector(touchGiftButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:giftButton];
        
        verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(giftButton.frame), CGRectGetMaxY(lineView.frame), 1, 44)];
        [verticalLineView setBackgroundColor:UIColorFromRGB(0xededed)];
        [self addSubview:verticalLineView];
    }
    else {
        [shareButton setFrame:CGRectMake(buttonWidth, CGRectGetMaxY(lineView.frame), buttonWidth-1, 44)];
    }
    
    //구분선
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 52, kScreenBoundsWidth, 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xdbdbe1)];
    [self addSubview:lineView];
}

#pragma mark - Public Methods

- (void)setLikeButtonStatus:(NSDictionary *)info
{
    BOOL isLike = [info[@"likeYn"] isEqualToString:@"Y"] ? YES : NO;
    
    if (isLike) {
        [self.likeButton setImage:[UIImage imageNamed:@"ic_pd_like_full.png"] forState:UIControlStateNormal];
        [self.likeButton setTitle:info[@"likeCntStr"] forState:UIControlStateNormal];
        [self.likeButton setTitleColor:UIColorFromRGB(0xff2434) forState:UIControlStateNormal];
    }
}

#pragma mark - Selectors

- (void)touchLikeButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchLikeButton)]) {
        [self.delegate didTouchLikeButton];
    }
    
    //AccessLog - 좋아요 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH01"];
    
    // 1. 레코픽 로그 호출
    NSString *recopickLogUrl = product[@"recopickLogUrl"];
    
    if (recopickLogUrl && [[recopickLogUrl trim] length] > 0) {
        
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"like"];
        recopickLogUrl = [recopickLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:@""];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:recopickLogUrl];
    }
    
    // 2. 시럽AD로그 호출
    NSString *syrupAdLogUrl = product[@"syrupAdLogUrl"];
    
    if (syrupAdLogUrl && [[syrupAdLogUrl trim] length] > 0) {
        
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{action}}" withString:@"wish"];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{count}}" withString:@"1"];
        syrupAdLogUrl = [syrupAdLogUrl stringByReplacingOccurrencesOfString:@"{{total_sales}}" withString:[NSString stringWithFormat:@"%ld", (long)[product[@"prdPrice"][@"finalDscPrc"] integerValue]]];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:syrupAdLogUrl];
    }
    
    // 3. Hot Click 전환수 측정 로그 호출
    NSString *ad11stPrdLogUrl = product[@"ad11stPrdLogUrl"];
    
    if (ad11stPrdLogUrl && [[ad11stPrdLogUrl trim] length] > 0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{actionType}}" withString:@"jjim"];
        ad11stPrdLogUrl = [ad11stPrdLogUrl stringByReplacingOccurrencesOfString:@"{{logTime}}" withString:strDate];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:ad11stPrdLogUrl];
    }
    
    // 4. Hot Click Pairing 로그 호출
    NSString *hotClickPairingLogUrl = product[@"hotClickPairingLogUrl"];
    
    if (hotClickPairingLogUrl && [[hotClickPairingLogUrl trim] length] > 0) {
        hotClickPairingLogUrl = [hotClickPairingLogUrl stringByReplacingOccurrencesOfString:@"{{method}}" withString:@"zzim"];
        [[AccessLog sharedInstance] sendAccessLogWithFullUrl:hotClickPairingLogUrl];
    }
}

- (void)touchGiftButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchGiftButton)]) {
        [self.delegate didTouchGiftButton];
    }
    
    //AccessLog - 선물하기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH02"];
}

- (void)touchShareButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchShareButton)]) {
        [self.delegate didTouchShareButton];
    }
    
    //AccessLog - 공유하기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH03"];
}

@end
