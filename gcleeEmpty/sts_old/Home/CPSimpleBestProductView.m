//
//  CPSimpleBestProductView.m
//  11st
//
//  Created by saintsd on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPSimpleBestProductView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPString+Formatter.h"
#import "CPTouchActionView.h"

@interface CPSimpleBestProductView ()
{
	NSDictionary *_item;
	
	CPThumbnailView *_bannerImageView;
	UIView *_middleLine;
	UILabel *_titleLabel;
	UILabel *_priceLabel;
    UIView *_priceMidLine;
    UILabel *_finalPriceLable;
    UILabel *_finalPriceWonLabel;
    UILabel *_freeShipLabel;
    
	CPTouchActionView *_actionView;
}

@end

@implementation CPSimpleBestProductView

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item
{
	if (self = [super initWithFrame:frame]) {
		if (item) _item = [[NSDictionary alloc] initWithDictionary:item];
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	CGFloat imageHeight = [Modules getRatioHeight:CGSizeMake(330, 300) screebWidth:self.frame.size.width];
	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, imageHeight)];
	[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:_item[@"prdImgUrl"]]];
	[self addSubview:_bannerImageView];
	
	_middleLine = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight-1, self.frame.size.width, 1)];
	_middleLine.backgroundColor = UIColorFromRGB(0xf0f2f3);
	[self addSubview:_middleLine];

	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageHeight + 9, self.frame.size.width-20.f, 35)];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont systemFontOfSize:14];
	_titleLabel.textColor = UIColorFromRGB(0x333333);
	_titleLabel.numberOfLines = 1;
	_titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	[self addSubview:_titleLabel];
    
    if (!nilCheck(_item[@"prdNm"])) {
        NSString *str = _item[@"prdNm"];
        NSInteger index = 0;
        
        for (int i = 0; i < [str length]; i++) {
            CGSize size = [[str substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(_titleLabel.frame)) lineBreakMode:_titleLabel.lineBreakMode];
            
            if (size.width > CGRectGetWidth(_titleLabel.frame)) {
                break;
            }
            index = i;
        }
        
        [_titleLabel setText:[str substringWithRange:NSMakeRange(0, index)]];
    }
	
	NSString *priceString = [_item[@"selPrc"] formatThousandComma];
	_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height-35.f, 0, 0)];
	_priceLabel.backgroundColor = [UIColor clearColor];
	_priceLabel.font = [UIFont boldSystemFontOfSize:10];
	_priceLabel.textColor = UIColorFromRGB(0xa5a5af);
	_priceLabel.textAlignment = NSTextAlignmentLeft;
	_priceLabel.text = [NSString stringWithFormat:@"%@원", priceString];
	[_priceLabel sizeToFitWithFloor];
	[self addSubview:_priceLabel];

    _priceMidLine = [[UIView alloc] initWithFrame:CGRectMake(_priceLabel.frame.origin.x-1,
                                                             _priceLabel.frame.origin.y+(_priceLabel.frame.size.height/2),
                                                             _priceLabel.frame.size.width+2, 1)];
    _priceMidLine.backgroundColor = UIColorFromRGB(0xa5a5af);
    [self addSubview:_priceMidLine];
    
    NSString *finalPriceStr = [_item[@"finalDscPrc"] formatThousandComma];
    _finalPriceLable = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height-25.f, 0, 0)];
    _finalPriceLable.backgroundColor = [UIColor clearColor];
    _finalPriceLable.textColor = UIColorFromRGB(0x000000);
    _finalPriceLable.font = [UIFont boldSystemFontOfSize:16];
    _finalPriceLable.text = finalPriceStr;
    [_finalPriceLable sizeToFitWithFloor];
    [self addSubview:_finalPriceLable];

    _finalPriceWonLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_finalPriceLable.frame),
                                                                    _finalPriceLable.frame.origin.y+4,
                                                                    0, 0)];
    _finalPriceWonLabel.backgroundColor = [UIColor clearColor];
    _finalPriceWonLabel.textColor = UIColorFromRGB(0x000000);
    _finalPriceWonLabel.font = [UIFont boldSystemFontOfSize:11];
    _finalPriceWonLabel.textAlignment = NSTextAlignmentLeft;
    _finalPriceWonLabel.text = @"원";
    [_finalPriceWonLabel sizeToFitWithFloor];
    [self addSubview:_finalPriceWonLabel];

    _freeShipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-51, CGRectGetMaxY(self.frame)-25, 44, 17)];
    _freeShipLabel.backgroundColor = [UIColor clearColor];
    _freeShipLabel.textColor = UIColorFromRGB(0x4e66c4);
    _freeShipLabel.font = [UIFont systemFontOfSize:10];
    _freeShipLabel.textAlignment = NSTextAlignmentCenter;
    _freeShipLabel.layer.borderWidth = 1;
    _freeShipLabel.layer.borderColor = UIColorFromRGB(0x506bd1).CGColor;
    _freeShipLabel.text = @"무료배송";
    [self addSubview:_freeShipLabel];
    
    NSInteger nFinalDscPrc = [_item[@"finalDscPrc"] integerValue];
    NSInteger nSelPrc = [_item[@"selPrc"] integerValue];
    
    if (nFinalDscPrc == nSelPrc)
    {
        _priceLabel.hidden = YES;
        _priceMidLine.hidden = YES;
    }
    else
    {
        _priceLabel.hidden = NO;
        _priceMidLine.hidden = NO;
    }

    BOOL isShowIcon = NO;
    NSArray *icons = _item[@"icons"];
    if (icons) {
        for (NSString *str in icons) {
            if ([str isEqualToString:@"freeDlv"]) {
                isShowIcon = YES;
                break;
            }
        }
    }
    
    if (isShowIcon) _freeShipLabel.hidden = NO;
    else            _freeShipLabel.hidden = YES;
    
	_actionView = [[CPTouchActionView alloc] initWithFrame:self.bounds];
	_actionView.actionType = CPButtonActionTypeOpenSubview;
	_actionView.actionItem = _item[@"linkUrl"];
    _actionView.wiseLogCode = @"MAJ0401";
    [_actionView setAccessibilityLabel:[NSString stringWithFormat:@"상품 %@, %@원", _item[@"prdNm"], _item[@"finalDscPrc"]] Hint:@""];
	[self addSubview:_actionView];
}

@end
