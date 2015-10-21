//
//  CPProductInfoSmartOptionButtonView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductInfoSmartOptionButtonView.h"
//#import "UIImage+ImageWithColor.h"

@interface CPProductInfoSmartOptionButtonView ()
{
    UILabel *_optionDetailLabel;
    UIImageView *_optionDetailImageView;
    
    UILabel *_optionSelectLabel;
    UIImageView *_optionSelectImageView;
    
    UIView *_topLineView;
    UIView *_verticalLineView;
    UIView *_bottomLineView;
}

- (void)initSubviews;

@end

@implementation CPProductInfoSmartOptionButtonView

#pragma mark - Class Methods

+ (CGFloat)contentHeight
{
    return kProductInfoSmartOptionButtonHeight + (kProductInfoSmartOptionLineHeight * 2);
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubviews];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)initSubviews
{
    _optionDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_optionDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
//    [_optionDetailButton setBackgroundImage:[UIImage imageWithColor:[UIColor shDefaultBackgroundColor]] forState:UIControlStateHighlighted];
    [_optionDetailButton setAccessibilityLabel:@"옵션 자세히 보기" Hint:nil];
    [self addSubview:_optionDetailButton];
    
    _optionDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _optionDetailLabel.font = FONTSIZE(14);
    _optionDetailLabel.text = @"자세히";
//    _optionDetailLabel.textColor = [UIColor shTextGray2Color];
    _optionDetailLabel.textAlignment = NSTextAlignmentCenter;
    _optionDetailLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_optionDetailLabel];
    
    _optionDetailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_magiifier.png"]];
    [self addSubview:_optionDetailImageView];
    
    _optionSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_optionSelectButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
//    [_optionSelectButton setBackgroundImage:[UIImage imageWithColor:[UIColor shDefaultBackgroundColor]] forState:UIControlStateHighlighted];
    [_optionSelectButton setAccessibilityLabel:@"옵션담기" Hint:nil];
    [self addSubview:_optionSelectButton];
    
    _optionSelectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _optionSelectLabel.font = FONTSIZE(14);
    _optionSelectLabel.text = @"옵션담기";
//    _optionSelectLabel.textColor = [UIColor shTextGray2Color];
    _optionSelectLabel.textAlignment = NSTextAlignmentCenter;
    _optionSelectLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_optionSelectLabel];
    
    _optionSelectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_put_in.png"]];
    [self addSubview:_optionSelectImageView];
    
    _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
//    _topLineView.backgroundColor = [UIColor shLineColor];
    [self addSubview:_topLineView];
    
    _verticalLineView = [[UIView alloc] initWithFrame:CGRectZero];
//    _verticalLineView.backgroundColor = [UIColor shLineColor];
    [self addSubview:_verticalLineView];
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
//    _bottomLineView.backgroundColor = [UIColor shThickLineColor];
    [self addSubview:_bottomLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.bounds;
    
    CGRect rectLineView = CGRectMake(0.0f,
                                     0.0f,
                                     rectClient.size.width,
                                     1.0f);
    [_topLineView setFrame:rectLineView];
    
    rectLineView.origin.y = rectClient.size.height - 1.0f;
    [_bottomLineView setFrame:rectLineView];
    
    rectLineView = CGRectZero;
    if (_showOptionDetailButton)
    {
        rectLineView = CGRectMake(rectClient.size.width / 2 - 1.0f,
                                  0.0f,
                                  1.0f,
                                  rectClient.size.height);
        [_verticalLineView setFrame:rectLineView];
        
        CGRect rectButton = CGRectMake(0.0f,
                                       0.0f,
                                       rectLineView.origin.x,
                                       rectClient.size.height);
        [_optionDetailButton setFrame:rectButton];
        
        CGFloat margin = 5.0f;
        CGFloat sectionWidth = rectClient.size.width / 2;
        CGFloat imageWidth = _optionSelectImageView.image.size.width;
        CGFloat imageHeight = _optionSelectImageView.image.size.height;
        CGSize textSize = GET_STRING_SIZE(_optionDetailLabel.text, FONTSIZE(14), rectClient.size.width);
        CGFloat startX = (sectionWidth - (textSize.width + imageWidth + margin)) / 2;
        
        CGRect rectImage = CGRectMake(startX,
                                      (rectClient.size.height - imageHeight) / 2,
                                      imageWidth,
                                      imageHeight);
        [_optionDetailImageView setFrame:rectImage];
        
        CGRect rectLabel = CGRectMake(rectImage.origin.x + rectImage.size.width + margin,
                                      0.0f,
                                      textSize.width,
                                      rectClient.size.height);
        [_optionDetailLabel setFrame:rectLabel];
        
        rectButton.origin.x = rectClient.size.width / 2;
        [_optionSelectButton setFrame:rectButton];
        
        imageWidth = _optionSelectImageView.image.size.width;
        imageHeight = _optionSelectImageView.image.size.height;
        textSize = GET_STRING_SIZE(_optionSelectLabel.text, FONTSIZE(14), rectClient.size.width);
        startX = (sectionWidth - (textSize.width + imageWidth + margin)) / 2 + sectionWidth;
        
        rectImage = CGRectMake(startX,
                               (rectClient.size.height - imageHeight) / 2,
                               imageWidth,
                               imageHeight);
        [_optionSelectImageView setFrame:rectImage];
        
        rectLabel = CGRectMake(rectImage.origin.x + rectImage.size.width + margin,
                               0.0f,
                               textSize.width,
                               rectClient.size.height);
        [_optionSelectLabel setFrame:rectLabel];
    }
    else
    {
        [_verticalLineView setFrame:rectLineView];
        
        [_optionDetailButton setFrame:CGRectZero];
        [_optionDetailLabel setFrame:CGRectZero];
        [_optionDetailImageView setFrame:CGRectZero];
        
        [_optionSelectButton setFrame:rectClient];
        
        CGFloat margin = 5.0f;
        CGFloat imageWidth = _optionSelectImageView.image.size.width;
        CGFloat imageHeight = _optionSelectImageView.image.size.height;
        CGSize textSize = GET_STRING_SIZE(_optionSelectLabel.text, FONTSIZE(14), rectClient.size.width);
        CGFloat startX = (rectClient.size.width - (textSize.width + imageWidth + margin)) / 2;
        
        CGRect rectImage = CGRectMake(startX,
                                      (rectClient.size.height - imageHeight) / 2,
                                      imageWidth,
                                      imageHeight);
        [_optionSelectImageView setFrame:rectImage];
        
        CGRect rectLabel = CGRectMake(rectImage.origin.x + rectImage.size.width + margin,
                                      0.0f,
                                      textSize.width,
                                      rectClient.size.height);
        [_optionSelectLabel setFrame:rectLabel];
    }
}

#pragma mark - Property

- (void)setShowOptionDetailButton:(BOOL)showOptionDetailButton
{
    _showOptionDetailButton = showOptionDetailButton;
    
    _verticalLineView.hidden = _optionDetailButton.hidden = _optionDetailLabel.hidden = _optionDetailImageView.hidden = !_showOptionDetailButton;
    
    [self setNeedsLayout];
}

- (void)setProductSmartOptionCellType:(ProductSmartOptionCellType)productSmartOptionCellType
{
    _productSmartOptionCellType = productSmartOptionCellType;
    
    NSString *detailOptionString = (_productSmartOptionCellType == ProductSmartOptionCellTypeList) ? @"자세히 보기" : @"자세히";
    _optionDetailLabel.text = detailOptionString;
    
    [self setNeedsLayout];
}

@end