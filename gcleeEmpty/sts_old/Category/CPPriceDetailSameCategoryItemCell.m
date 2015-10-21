//
//  CPPriceDetailSameCategoryItemCellCollectionViewCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailSameCategoryItemCell.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"

@interface CPPriceDetailSameCategoryItemCell ()
{
    CPThumbnailView *_bannerImageView;
    UILabel *_titleLabel;
    UILabel *_priceLabel;
    UIImageView *_compareView;
    UIView *_selectedView;
}

@end

@implementation CPPriceDetailSameCategoryItemCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    _bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
    _bannerImageView.backgroundColor = UIColorFromRGB(0xeeeeee);
    [self.contentView addSubview:_bannerImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x333333);
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.backgroundColor = [UIColor clearColor];
    _priceLabel.textColor = UIColorFromRGB(0x333333);
    _priceLabel.font = [UIFont boldSystemFontOfSize:15];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.numberOfLines = 1;
    [self.contentView addSubview:_priceLabel];

    _compareView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_compareView];
    
    _selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedView.backgroundColor = UIColorFromRGBA(0xe5e5e5, 0.3);
    [self.contentView addSubview:_selectedView];
    
    [self setTouchViewSelectedYn:NO];
}

- (void)layoutSubviews
{
    CGRect viewRect = self.contentView.bounds;
    
    //셀렉트 뷰
    _selectedView.frame = viewRect;
    
    //썸네일
    NSString *imageUrl = _item[@"imageUrl"];
    [_bannerImageView setFrame:CGRectMake(0, 0, viewRect.size.width, viewRect.size.width)];
    [_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
 
    //상풍명
    NSString *modelNm = _item[@"modelNm"];
    _titleLabel.text = modelNm;
    _titleLabel.frame = CGRectMake(10, CGRectGetMaxY(_bannerImageView.frame)+6, viewRect.size.width-20, 0);
    [_titleLabel sizeToFitWithVersionHoldWidth];
    
    //가격
    NSString *priceNum = [Modules numberFormat:[_item[@"price"] integerValue]];
    _priceLabel.text = [NSString stringWithFormat:@"%@원~", priceNum];
    _priceLabel.frame = CGRectMake(10, CGRectGetMaxY(_titleLabel.frame), viewRect.size.width-20, 0);
    [_priceLabel sizeToFitWithVersionHoldWidth];
    
    [self setAccessibilityLabel:[NSString stringWithFormat:@"%@, %@원", modelNm, priceNum] Hint:@""];
    
    //가격비교 영역
    for (UIView *subviews in _compareView.subviews) {
        [subviews removeFromSuperview];
    }
    
    UIImage *compareBgImg = [UIImage imageNamed:@"bt_s_pricelist.png"];
    compareBgImg = [compareBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
   
    UIImage *compareArrowImg = [UIImage imageNamed:@"bt_s_arrow_right_02.png"];
    
    UILabel *compareLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    compareLabel.backgroundColor = [UIColor clearColor];
    compareLabel.textColor = UIColorFromRGB(0x5d5d73);
    compareLabel.font = [UIFont systemFontOfSize:12];
    compareLabel.textAlignment = NSTextAlignmentCenter;
    compareLabel.numberOfLines = 1;
    compareLabel.text = @"가격비교";
    [compareLabel sizeToFitWithVersion];
    [_compareView addSubview:compareLabel];

    NSInteger compareNum = [_item[@"prdCount"] integerValue];
    UILabel *compareCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    compareCountLabel.backgroundColor = [UIColor clearColor];
    compareCountLabel.textColor = UIColorFromRGB(0x333333);
    compareCountLabel.font = [UIFont boldSystemFontOfSize:14];
    compareCountLabel.textAlignment = NSTextAlignmentCenter;
    compareCountLabel.numberOfLines = 1;
    compareCountLabel.text = (compareNum > 999 ? @"999+" : [NSString stringWithFormat:@"%ld", (long)compareNum]);
    [compareCountLabel sizeToFitWithVersion];
    [_compareView addSubview:compareCountLabel];

    CGFloat compareWidth = 8+compareLabel.frame.size.width+3+compareCountLabel.frame.size.width+4+compareArrowImg.size.width+6;
    
    compareLabel.frame = CGRectMake(8, 12-(compareLabel.frame.size.height/2),
                                    compareLabel.frame.size.width, compareLabel.frame.size.height);
    compareCountLabel.frame = CGRectMake(CGRectGetMaxX(compareLabel.frame)+3, 12-(compareCountLabel.frame.size.height/2),
                                         compareCountLabel.frame.size.width, compareCountLabel.frame.size.height);
    UIImageView *compareArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(compareCountLabel.frame)+4,
                                                                                  12-(compareArrowImg.size.height/2),
                                                                                  compareArrowImg.size.width, compareArrowImg.size.height)];
    compareArrowView.image = compareArrowImg;
    [_compareView addSubview:compareArrowView];
    
    _compareView.image = compareBgImg;
    _compareView.frame = CGRectMake((self.contentView.frame.size.width/2)-(compareWidth/2),
                                    self.contentView.frame.size.height-5-24,
                                    compareWidth, 24);
    
    
}

- (void)updateCell
{
    [self layoutSubviews];
}

- (void)setTouchViewSelectedYn:(BOOL)isSelected
{
    _selectedView.hidden = !isSelected;
}

- (void)onTouchView
{
    NSString *modelNo = _item[@"modelNo"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailSameCategoryItemCell:onTouchChangeModel:)]) {
        [self.delegate priceDetailSameCategoryItemCell:self onTouchChangeModel:modelNo];
    }
    
    if ([_groupName isEqualToString:@"sameCategoryModels"]) [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDN02"];
    else                                                    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDO02"];
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
