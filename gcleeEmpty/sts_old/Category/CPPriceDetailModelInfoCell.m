//
//  CPPriceDetailModelInfoCell.m
//  11st
//
//  Created by 11st_mac_17 on 2015. 7. 6..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailModelInfoCell.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPPriceDetailModelInfoCell ()
{
    UIView *_contentView;
    UIView *_lineView;
}

@end

@implementation CPPriceDetailModelInfoCell

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
    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (kScreenBoundsWidth < 414 )  [self layoutSubviewsLowDisplay];
    else                            [self layoutSubviewsHighDisplay];
}

- (void)layoutSubviewsLowDisplay
{
    NSString *bannerImgUrl = _item[@"imageUrl"];
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    bannerImageView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [bannerImageView sd_setImageWithURL:[NSURL URLWithString:bannerImgUrl]];
    [_contentView addSubview:bannerImageView];
    
    CGFloat offsetX = CGRectGetMaxX(bannerImageView.frame)+10;
    
    NSString *brandNm = _item[@"brandNm"];
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 10, _contentView.frame.size.width-offsetX-10, 15)];
    brandLabel.backgroundColor = [UIColor clearColor];
    brandLabel.textColor = UIColorFromRGB(0x979696);
    brandLabel.font = [UIFont systemFontOfSize:12];
    brandLabel.text = brandNm;
    [_contentView addSubview:brandLabel];
    
    NSString *modelNm = _item[@"modelNm"];
    UILabel *modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, CGRectGetMaxY(brandLabel.frame)+3,
                                                                    _contentView.frame.size.width-offsetX-10, 0)];
    modelLabel.backgroundColor = [UIColor clearColor];
    modelLabel.textColor = UIColorFromRGB(0x262626);
    modelLabel.font = [UIFont systemFontOfSize:16];
    modelLabel.text = modelNm;
    modelLabel.numberOfLines = 2;
    [modelLabel sizeToFitWithVersionHoldWidth];
    [_contentView addSubview:modelLabel];
    
    NSString *price = _item[@"price"];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, modelLabel.frame.origin.y+39,
                                                                    0, 0)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textColor = UIColorFromRGB(0x292929);
    priceLabel.font = [UIFont boldSystemFontOfSize:18];
    priceLabel.text = [Modules numberFormatComma:price];
    priceLabel.numberOfLines = 1;
    [priceLabel sizeToFitWithVersion];
    [_contentView addSubview:priceLabel];
    
    UILabel *priceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    priceWonLabel.textColor = UIColorFromRGB(0x292929);
    priceWonLabel.font = [UIFont systemFontOfSize:13];
    priceWonLabel.text = @"원~";
    priceWonLabel.numberOfLines = 1;
    [priceWonLabel sizeToFitWithVersion];
    [_contentView addSubview:priceWonLabel];
    
    priceWonLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), CGRectGetMaxY(priceLabel.frame)-priceWonLabel.frame.size.height-2,
                                     priceWonLabel.frame.size.width, priceWonLabel.frame.size.height);
    
    
    CGFloat startScore = [_item[@"starScore"] floatValue];
    UIView *starView = [self getStarPointView:startScore];
    starView.frame = CGRectMake(offsetX, CGRectGetMaxY(priceWonLabel.frame)+8, starView.frame.size.width, starView.frame.size.height);
    [_contentView addSubview:starView];
    
    NSInteger reviewCount = [_item[@"reviewCount"] integerValue];
    if (reviewCount > 0) {
        NSString *rCount = [Modules numberFormat:reviewCount];
        UILabel *reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        reviewCountLabel.backgroundColor = [UIColor clearColor];
        reviewCountLabel.textColor = UIColorFromRGB(0x5f5f5f);
        reviewCountLabel.font = [UIFont systemFontOfSize:14];
        reviewCountLabel.text = [NSString stringWithFormat:@"(%@)", rCount];
        [reviewCountLabel sizeToFitWithVersion];
        [_contentView addSubview:reviewCountLabel];
        
        reviewCountLabel.frame = CGRectMake(CGRectGetMaxX(starView.frame)+3,
                                            starView.center.y-(reviewCountLabel.frame.size.height/2),
                                            reviewCountLabel.frame.size.width, reviewCountLabel.frame.size.height);
    }
    else {
        starView.hidden = YES;
    }
    
    UIImage *btnBg = [UIImage imageNamed:@"bt_price_buy.png"];
    btnBg = [btnBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btnLowPrice = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLowPrice setFrame:CGRectMake(10, CGRectGetMaxY(bannerImageView.frame)+9, _contentView.frame.size.width-20, btnBg.size.height)];
    [btnLowPrice setBackgroundImage:btnBg forState:UIControlStateNormal];
    [btnLowPrice setTitle:@"최저가 상품 구매" forState:UIControlStateNormal];
    [btnLowPrice setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [btnLowPrice.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnLowPrice addTarget:self action:@selector(onTouchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btnLowPrice];
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, CGRectGetMaxY(_contentView.frame)-1, _contentView.frame.size.width, 1);
}

- (void)layoutSubviewsHighDisplay
{
    NSString *bannerImgUrl = _item[@"imageUrl"];
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 140, 140)];
    bannerImageView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [bannerImageView sd_setImageWithURL:[NSURL URLWithString:bannerImgUrl]];
    [_contentView addSubview:bannerImageView];
    
    CGFloat offsetX = CGRectGetMaxX(bannerImageView.frame)+10;

    NSString *brandNm = _item[@"brandNm"];
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 10, _contentView.frame.size.width-offsetX-10, 15)];
    brandLabel.backgroundColor = [UIColor clearColor];
    brandLabel.textColor = UIColorFromRGB(0x979696);
    brandLabel.font = [UIFont systemFontOfSize:12];
    brandLabel.text = brandNm;
    [_contentView addSubview:brandLabel];
    
    NSString *modelNm = _item[@"modelNm"];
    UILabel *modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, CGRectGetMaxY(brandLabel.frame)+3,
                                                                    _contentView.frame.size.width-offsetX-10, 0)];
    modelLabel.backgroundColor = [UIColor clearColor];
    modelLabel.textColor = UIColorFromRGB(0x262626);
    modelLabel.font = [UIFont systemFontOfSize:16];
    modelLabel.text = modelNm;
    modelLabel.numberOfLines = 2;
    [modelLabel sizeToFitWithVersionHoldWidth];
    [_contentView addSubview:modelLabel];
    
    NSString *price = _item[@"price"];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, modelLabel.frame.origin.y+39,
                                                                    0, 0)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textColor = UIColorFromRGB(0x292929);
    priceLabel.font = [UIFont boldSystemFontOfSize:18];
    priceLabel.text = [Modules numberFormatComma:price];
    priceLabel.numberOfLines = 1;
    [priceLabel sizeToFitWithVersion];
    [_contentView addSubview:priceLabel];
    
    UILabel *priceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    priceWonLabel.textColor = UIColorFromRGB(0x292929);
    priceWonLabel.font = [UIFont systemFontOfSize:13];
    priceWonLabel.text = @"원~";
    priceWonLabel.numberOfLines = 1;
    [priceWonLabel sizeToFitWithVersion];
    [_contentView addSubview:priceWonLabel];
    
    priceWonLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), CGRectGetMaxY(priceLabel.frame)-priceWonLabel.frame.size.height-2,
                                     priceWonLabel.frame.size.width, priceWonLabel.frame.size.height);
    
    
    CGFloat startScore = [_item[@"starScore"] floatValue];
    UIView *starView = [self getStarPointView:startScore];
    starView.frame = CGRectMake(offsetX, CGRectGetMaxY(priceWonLabel.frame)+8, starView.frame.size.width, starView.frame.size.height);
    [_contentView addSubview:starView];
    
    NSInteger reviewCount = [_item[@"reviewCount"] integerValue];
    if (reviewCount > 0) {
        NSString *rCount = [Modules numberFormat:reviewCount];
        UILabel *reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        reviewCountLabel.backgroundColor = [UIColor clearColor];
        reviewCountLabel.textColor = UIColorFromRGB(0x5f5f5f);
        reviewCountLabel.font = [UIFont systemFontOfSize:14];
        reviewCountLabel.text = [NSString stringWithFormat:@"(%@)", rCount];
        [reviewCountLabel sizeToFitWithVersion];
        [_contentView addSubview:reviewCountLabel];
        
        reviewCountLabel.frame = CGRectMake(CGRectGetMaxX(starView.frame)+3,
                                            starView.center.y-(reviewCountLabel.frame.size.height/2),
                                            reviewCountLabel.frame.size.width, reviewCountLabel.frame.size.height);
    }
    else {
        starView.hidden = YES;
    }

    UIImage *btnBg = [UIImage imageNamed:@"bt_price_buy.png"];
    btnBg = [btnBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *btnLowPrice = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLowPrice setFrame:CGRectMake(offsetX, CGRectGetMaxY(bannerImageView.frame)-btnBg.size.height,
                                     _contentView.frame.size.width-30-bannerImageView.frame.size.width, btnBg.size.height)];
    [btnLowPrice setBackgroundImage:btnBg forState:UIControlStateNormal];
    [btnLowPrice setTitle:@"최저가 상품 구매" forState:UIControlStateNormal];
    [btnLowPrice setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [btnLowPrice.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnLowPrice addTarget:self action:@selector(onTouchLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:btnLowPrice];
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, CGRectGetMaxY(_contentView.frame)-1, _contentView.frame.size.width, 1);
}

- (UIView *)getStarPointView:(CGFloat)pointNum
{
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54, 9)];
    
    NSInteger fCount = (NSInteger)pointNum;
    CGFloat hCount = pointNum - fCount;
    
    CGFloat offsetX = 0.f;
    for (NSInteger i=0; i<5; i++) {
        UIImageView *bgStarView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, 10, 9)];
        bgStarView.image = [UIImage imageNamed:@"ic_mart_star_off.png"];
        [pointView addSubview:bgStarView];
        
        if (fCount > 0) {
            UIImageView *starView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, 10, 9)];
            starView.image = [UIImage imageNamed:@"ic_mart_star_on.png"];
            [pointView addSubview:starView];
            
            fCount--;
        }
        else {
            if (hCount > 0) {
                UIImageView *hStarView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, 10, 9)];
                hStarView.image = [UIImage imageNamed:@"ic_mart_star_half.png"];
                [pointView addSubview:hStarView];
                
                hCount = 0;
            }
        }
        
        offsetX += 11;
    }
    
    return pointView;
}

- (void)onTouchLinkButton:(id)sender
{
    NSString *linkUrl = _item[@"prdLink"];
    
    if (linkUrl && [linkUrl length] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchBannerButton:)]) {
            [self.delegate didTouchBannerButton:linkUrl];
        }
    }
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDB01"];
}

@end
