//
//  CPLikePopupView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPLikePopupView.h"

@interface CPLikePopupView ()
{
    UIView *_bodyView;
    UIImageView *_bgView;
    UIButton *_gotoMyLikedListButton;
    UIButton *_closeButton;
}

@property (nonatomic, assign) LikePopupType type;

- (void)initSubviews;

@end

@implementation CPLikePopupView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame popupType:(LikePopupType)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _type = type;
        [self initSubviews];
        
        self.backgroundColor = UIColorFromRGBA(0x000000, 0.7f);
    }
    
    return self;
}

#pragma mark - Subviews

- (void)initSubviews
{
    _bodyView = [[UIView alloc] initWithFrame:CGRectZero];
    _bodyView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bodyView];
    
    _bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_bodyView addSubview:_bgView];
    
    UIImage *imgLikeButton = [UIImage imageNamed:@"detail_like_btn_all.png"];
    imgLikeButton = [imgLikeButton resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    NSString *myLikedListString = @"전체보기";
    _gotoMyLikedListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gotoMyLikedListButton setBackgroundImage:imgLikeButton forState:UIControlStateNormal];
    [_gotoMyLikedListButton setTitle:myLikedListString forState:UIControlStateNormal];
    [_gotoMyLikedListButton setTitleColor:UIColorFromRGB(0xff4047) forState:UIControlStateNormal];
    _gotoMyLikedListButton.titleLabel.font = BOLDFONTSIZE(14);
    
    if (_type == LikePopupTypeProduct) {
        [_gotoMyLikedListButton addTarget:self action:@selector(onClickedGotoMyLikedProductListButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [_gotoMyLikedListButton addTarget:self action:@selector(onClickedGotoMyLikedPlanningListButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_bodyView addSubview:_gotoMyLikedListButton];
    
    UIImage *imgCloseButton = [UIImage imageNamed:@"detail_like_btn_close.png"];
    imgCloseButton = [imgCloseButton resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setBackgroundImage:imgCloseButton forState:UIControlStateNormal];
    [_closeButton setTitle:@"닫기" forState:UIControlStateNormal];
    [_closeButton setTitleColor:UIColorFromRGB(0x6e6e6e) forState:UIControlStateNormal];
    _closeButton.titleLabel.font = BOLDFONTSIZE(14);
    [_closeButton addTarget:self action:@selector(onClickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bodyView addSubview:_closeButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.bounds;
    
    UIImage *imgBg = [UIImage imageNamed:(self.likeSuccess ? @"detail_like_frame_complete.png" : @"detail_like_frame_repeated.png")];
    
    CGFloat bodyWidth = imgBg.size.width;
    CGFloat bodyHeight = imgBg.size.height;
    
    CGRect rectBody = CGRectMake((rectClient.size.width - bodyWidth) / 2,
                                 (rectClient.size.height - bodyHeight) / 2,
                                 bodyWidth,
                                 bodyHeight);
    [_bodyView setFrame:rectBody];
    
    _bgView.frame = _bodyView.bounds;
    _bgView.image = imgBg;
    
    CGFloat buttonOffsetY = _bodyView.frame.size.height - 11.f - 34.f;
    _closeButton.frame = CGRectMake(11.f, buttonOffsetY, 99.f, 34.f);
    _gotoMyLikedListButton.frame = CGRectMake(CGRectGetMaxX(_closeButton.frame) + 6.f, buttonOffsetY, 116, 34.f);
}

#pragma mark - UIButton Target-Action

- (void)onClickedGotoMyLikedProductListButton:(id)sender
{
    DELEGATE_CALL2(_delegate,
                   likeStatusPopupView
                   : didClickedButton:,
                   self,
                   @(LikeStatusPopupButtonMyLikedProductList));
}

- (void)onClickedGotoMyLikedPlanningListButton:(id)sender
{
    DELEGATE_CALL2(_delegate,
                   likeStatusPopupView
                   : didClickedButton:,
                   self,
                   @(LikeStatusPopupButtonMyLikedPlanningList));
}

- (void)onClickedCloseButton:(id)sender
{
    [self removeFromSuperview];
}

@end
