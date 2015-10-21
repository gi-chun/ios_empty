//
//  CPProductDetailBestProductItemCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductDetailBestProductItemCell.h"

#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPProductDetailBestProductItemCell ()
{
    UIView *_productItemView;
    UIView *_moreItemView;
    
    CPThumbnailView *_bannerImageView;
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UIView *_selectedView;
    
    UIImageView *_moreSelectedView;
    UILabel *_moreTextView;
}

@end

@implementation CPProductDetailBestProductItemCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    //상품 배너
    _productItemView = [[UIView alloc] initWithFrame:CGRectZero];
    _productItemView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_productItemView];
    
    _bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
    _bannerImageView.backgroundColor = UIColorFromRGB(0xeeeeee);
    [_productItemView addSubview:_bannerImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x333333);
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [_productItemView addSubview:_titleLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.backgroundColor = [UIColor clearColor];
    _priceLabel.textColor = UIColorFromRGB(0x333333);
    _priceLabel.font = [UIFont boldSystemFontOfSize:15];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.numberOfLines = 1;
    [_productItemView addSubview:_priceLabel];

    //더보기
    _moreItemView = [[UIView alloc] initWithFrame:CGRectZero];
    _moreItemView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_moreItemView];

    _moreSelectedView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_moreItemView addSubview:_moreSelectedView];
    
    _moreTextView = [[UILabel alloc] initWithFrame:CGRectZero];
    _moreTextView.backgroundColor = [UIColor clearColor];
    _moreTextView.textColor = UIColorFromRGB(0x2b3794);
    _moreTextView.font = [UIFont systemFontOfSize:13];
    _moreTextView.textAlignment = NSTextAlignmentCenter;
    _moreTextView.numberOfLines = 2;
    [_moreItemView addSubview:_moreTextView];
    
    _productItemView.hidden = YES;
    _moreItemView.hidden = YES;
    
    _selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedView.backgroundColor = UIColorFromRGBA(0xe5e5e5, 0.3);
    [self.contentView addSubview:_selectedView];
    
    [self setTouchViewSelectedYn:NO];
}

- (void)layoutSubviews
{
    CGRect viewRect = self.contentView.bounds;
    
    _productItemView.hidden = self.isMore;
    _moreItemView.hidden = !self.isMore;

    _productItemView.frame = viewRect;
    _moreItemView.frame = viewRect;
    
    //셀렉트 뷰
    _selectedView.frame = viewRect;
    
    if (!self.isMore) {
        //썸네일
        NSString *imageUrl = _item[@"imageUrl"];
        [_bannerImageView setFrame:CGRectMake(0, 0, viewRect.size.width, viewRect.size.width)];
        [_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        
        //상풍명
        NSString *modelNm = _item[@"prdNm"];
        _titleLabel.text = modelNm;
        _titleLabel.frame = CGRectMake(10, CGRectGetMaxY(_bannerImageView.frame)+6, viewRect.size.width-20, 0);
        [_titleLabel sizeToFitWithVersionHoldWidth];
        
        //가격
        NSString *priceNum = [Modules numberFormat:[_item[@"price"] integerValue]];
        _priceLabel.text = [NSString stringWithFormat:@"%@원", priceNum];
        _priceLabel.frame = CGRectMake(10, CGRectGetMaxY(_titleLabel.frame), viewRect.size.width-20, 0);
        [_priceLabel sizeToFitWithVersionHoldWidth];
        
        [self setAccessibilityLabel:[NSString stringWithFormat:@"%@, %@원", modelNm, priceNum] Hint:@""];
    }
    else {
        _moreSelectedView.frame = CGRectMake((_moreItemView.frame.size.width/2)-(29/2), 54, 29, 29);
        [self setMoreViewSelectedYn:NO];
        
        _moreTextView.text = @"베스트상품\n더보기";
        _moreTextView.frame = CGRectMake(10, CGRectGetMaxY(_moreSelectedView.frame)+7, viewRect.size.width-20, 40);
        
        self.layer.borderColor = UIColorFromRGB(0xededed).CGColor;
        self.layer.borderWidth = 1.f;
        
        [self setAccessibilityLabel:@"베스트상품 더보기" Hint:@""];
    }
}

- (void)updateCell
{
    [self layoutSubviews];
}

- (void)setTouchViewSelectedYn:(BOOL)isSelected
{
    _selectedView.hidden = !isSelected;
    
    if (self.isMore) {
        [self setMoreViewSelectedYn:isSelected];
    }
}

- (void)setMoreViewSelectedYn:(BOOL)isSelected
{
    UIImage *image = [UIImage imageNamed:(!isSelected ? @"bt_detail_more.png" : @"bt_detail_more_press.png")];
    _moreSelectedView.image = image;
}

- (void)onTouchView
{
    if (self.isMore) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(productDetailBestProductItemCellOnTouchMoreItem)]) {
            [self.delegate productDetailBestProductItemCellOnTouchMoreItem];
        }
    }
    else
    {
        NSString *prdLink = _item[@"prdLink"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(productDetailBestProductItemCell:onTouchLinkUrl:)]) {
            [self.delegate productDetailBestProductItemCell:self onTouchLinkUrl:prdLink];
        }
        
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDP02"];
    }
}

#pragma mark - touch Event Methods.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchViewSelectedYn:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchViewSelectedYn:NO];
    [self onTouchView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setTouchViewSelectedYn:NO];
}

@end
