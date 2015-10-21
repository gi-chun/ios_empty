//
//  CPPriceDetailCompPrcListCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailCompPrcListCell.h"
#import "AccessLog.h"

@interface CPPriceDetailCompPrcListCell ()
{
    UIView *_contentView;
    UIView *_lineView;
    UIView *_touchView;
}

@end

@implementation CPPriceDetailCompPrcListCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = UIColorFromRGB(0xededed);
    [self.contentView addSubview:_lineView];
    
    _touchView = [[UIView alloc] initWithFrame:CGRectZero];
    _touchView.backgroundColor = UIColorFromRGBA(0xe5e5e5, 0.5);
    [self.contentView addSubview:_touchView];
    
    [self setIsTouchView:NO];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    _touchView.frame = _contentView.frame;
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    
    if (self.isMore) {
        UIImage *arrowImg = [UIImage imageNamed:@"ic_pd_arrow_down_02.png"];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = UIColorFromRGB(0x283593);
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.numberOfLines = 1;
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.text = @"더보기";
        [textLabel sizeToFitWithVersion];
        [_contentView addSubview:textLabel];
        
        textLabel.frame = CGRectMake((_contentView.frame.size.width/2)-((textLabel.frame.size.width+7+arrowImg.size.width)/2),
                                     (_contentView.frame.size.height/2)-(textLabel.frame.size.height/2),
                                     textLabel.frame.size.width, textLabel.frame.size.height);
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textLabel.frame)+7,
                                                                               (_contentView.frame.size.height/2)-(arrowImg.size.height/2),
                                                                               arrowImg.size.width, arrowImg.size.height)];
        arrowView.image = arrowImg;
        [_contentView addSubview:arrowView];
        
        _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    }
    else {
        
        //원
        UILabel *wonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        wonLabel.backgroundColor = [UIColor clearColor];
        wonLabel.textColor = UIColorFromRGB(0x000000);
        wonLabel.font = [UIFont boldSystemFontOfSize:12];
        wonLabel.numberOfLines = 1;
        wonLabel.textAlignment = NSTextAlignmentLeft;
        wonLabel.text = @"원";
        [wonLabel sizeToFitWithVersion];
        [_contentView addSubview:wonLabel];
        
        wonLabel.frame = CGRectMake(_contentView.frame.size.width-10-wonLabel.frame.size.width,
                                    ((_contentView.frame.size.height/2)-(wonLabel.frame.size.height/2))+1,
                                    wonLabel.frame.size.width, wonLabel.frame.size.height);
        
        //가격
        NSInteger priceNum = [_item[@"price"] integerValue];
        NSString *price = [Modules numberFormatter:(int)priceNum];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = UIColorFromRGB(0x000000);
        priceLabel.font = [UIFont systemFontOfSize:15];
        priceLabel.numberOfLines = 1;
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.text = price;
        [priceLabel sizeToFitWithVersion];
        [_contentView addSubview:priceLabel];
        
        priceLabel.frame = CGRectMake(wonLabel.frame.origin.x-priceLabel.frame.size.width,
                                      (_contentView.frame.size.height/2)-(priceLabel.frame.size.height/2),
                                      priceLabel.frame.size.width, priceLabel.frame.size.height);

        
        
        //배송료 :배송료는 X축 고정
        NSString *dlvTypeCd = _item[@"dlvTypeCd"];
        NSString *dlvPrice = @"";
        
        if ([dlvTypeCd isEqualToString:@"01"])      dlvPrice = @"무료배송";
        else if ([dlvTypeCd isEqualToString:@"02"]) dlvPrice = @"해외배송";
        else if ([dlvTypeCd isEqualToString:@"03"]) dlvPrice = [NSString stringWithFormat:@"%@원",[Modules numberFormatComma:_item[@"delivery"]]];
        
        UILabel *dlvLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dlvLabel.backgroundColor = [UIColor clearColor];
        dlvLabel.textColor = UIColorFromRGB(0x52bbff);
        dlvLabel.font = [UIFont systemFontOfSize:12];
        dlvLabel.numberOfLines = 1;
        dlvLabel.textAlignment = NSTextAlignmentLeft;
        dlvLabel.text = dlvPrice;
        [dlvLabel sizeToFitWithVersion];
        [_contentView addSubview:dlvLabel];
        
        dlvLabel.frame = CGRectMake(_contentView.frame.size.width-89-15-45,
                                    (_contentView.frame.size.height/2)-(dlvLabel.frame.size.height/2),
                                    dlvLabel.frame.size.width, dlvLabel.frame.size.height);
        
        //무료배송 아이콘
        UIImage *dlvImg = [UIImage imageNamed:@"ic_price_delevery.png"];
        UIImageView *dlvView = [[UIImageView alloc] initWithFrame:CGRectMake(dlvLabel.frame.origin.x-4-dlvImg.size.width,
                                                                             (_contentView.frame.size.height/2)-(dlvImg.size.height/2),
                                                                             dlvImg.size.width, dlvImg.size.height)];
        dlvView.image = dlvImg;
        [_contentView addSubview:dlvView];
        
        //판매자 최대 넓이 : 뷰넓이 - 배송비 뒷부분 넓이 - 앞부분 마진 - 뒷부분 마진 - 아이콘 두개사이즈 - 아이콘 마진
        UIImage *crownImg = [UIImage imageNamed:@"ic_price_crown.png"];
        UIImage *diamondImg = [UIImage imageNamed:@"ic_price_diamond.png"];
        
        CGFloat nameMaxWidth = dlvView.frame.origin.x-11-10-crownImg.size.width-diamondImg.size.width-7;
        
        //판매자
        NSString *sellerNckNm = _item[@"sellerNckNm"];
        
        UILabel *sellerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sellerLabel.backgroundColor = [UIColor clearColor];
        sellerLabel.textColor = UIColorFromRGB(0x333333);
        sellerLabel.font = [UIFont systemFontOfSize:14];
        sellerLabel.numberOfLines = 1;
        sellerLabel.textAlignment = NSTextAlignmentLeft;
        sellerLabel.text = sellerNckNm;
        [sellerLabel sizeToFitWithVersion];
        [_contentView addSubview:sellerLabel];
        
        CGRect nameFrame = sellerLabel.frame;
        nameFrame.size.width = (sellerLabel.frame.size.width > nameMaxWidth ? nameMaxWidth : sellerLabel.frame.size.width);
        
        sellerLabel.frame = CGRectMake(11, (_contentView.frame.size.height/2)-(nameFrame.size.height/2),
                                       nameFrame.size.width, nameFrame.size.height);
        
        //판매자 아이콘
        CGFloat offsetX = CGRectGetMaxX(sellerLabel.frame)+5;
        NSString *saleBest = _item[@"saleBest"];
        if ([@"Y" isEqualToString:saleBest]) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX,
                                                                                  (_contentView.frame.size.height/2)-(crownImg.size.height/2),
                                                                                  crownImg.size.width, crownImg.size.height)];
            iconView.image = crownImg;
            [_contentView addSubview:iconView];
            
            offsetX = CGRectGetMaxX(iconView.frame)+2;
        }

        NSString *custSatify = _item[@"custSatify"];
        if ([@"Y" isEqualToString:custSatify]) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX,
                                                                                  (_contentView.frame.size.height/2)-(diamondImg.size.height/2),
                                                                                  diamondImg.size.width, diamondImg.size.height)];
            iconView.image = diamondImg;
            [_contentView addSubview:iconView];
        }
        
        if (self.isLastCell)    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
        else                    _lineView.backgroundColor = UIColorFromRGB(0xededed);
    }
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}

- (void)setIsTouchView:(BOOL)isTouch
{
    BOOL touchYn = !isTouch;
    
    _touchView.hidden = touchYn;
}

- (void)onTouchView
{
    if (self.isMore) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(compPrcListCellShowNextItem)]) {
            [self.delegate compPrcListCellShowNextItem];
        }
        
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDH02"];
    }
    else {
        NSString *url = [_item[@"prdLink"] trim];
        
        if (url && [url length] > 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchBannerButton:)]) {
                [self.delegate didTouchBannerButton:url];
            }
        }
        
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDG02"];
    }
}

#pragma touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setIsTouchView:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setIsTouchView:NO];
    [self onTouchView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setIsTouchView:NO];
}

@end
