//
//  CPCornerBannerView.m
//  11st
//
//  Created by saintsd on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCornerBannerView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPCornerBannerView ()
{
	NSDictionary *_item;
	
	CPThumbnailView *_bannerImageView;
	UIView *_middleLine;
	UILabel *_titleLabel;
	UILabel *_subTextLabel;
	UILabel *_categoryLabel;
	UIImageView *_arrowView;
	
	CPTouchActionView *_actionView;
	CPTouchActionView *_categoryActionView;
}

@end

@implementation CPCornerBannerView

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
	CGFloat imageHeight = [Modules getRatioHeight:CGSizeMake(700, 400) screebWidth:self.frame.size.width];
	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, imageHeight)];
	[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:_item[@"lnkBnnrImgUrl"]]];
	[self addSubview:_bannerImageView];
	
	_middleLine = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight-1, self.frame.size.width, 1)];
	_middleLine.backgroundColor = UIColorFromRGB(0xf0f2f3);
	[self addSubview:_middleLine];
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, imageHeight + 9, self.frame.size.width-30.f, 0)];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont systemFontOfSize:18];
	_titleLabel.textColor = UIColorFromRGB(0x333333);
	_titleLabel.numberOfLines = 1;
	_titleLabel.textAlignment = NSTextAlignmentLeft;
	_titleLabel.text = _item[@"dispObjNm"];
	[_titleLabel sizeToFitWithVersionHoldWidth];
	[self addSubview:_titleLabel];

	NSString *categoryStr = _item[@"linkNm"];
	
	if ([categoryStr length] > 7) categoryStr = [categoryStr substringWithRange:NSMakeRange(0, 7)];
	
	if (categoryStr && [categoryStr length] > 0) {
		UIImage *arrowIcon = [UIImage imageNamed:@"bt_home_arrow_recommand.png"];
		_arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-15-arrowIcon.size.width,
																   CGRectGetMaxY(_titleLabel.frame)+6,
																   arrowIcon.size.width, arrowIcon.size.height)];
		_arrowView.image = arrowIcon;
		[self addSubview:_arrowView];
		
		_categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(_arrowView.frame.origin.x-6, CGRectGetMaxY(_titleLabel.frame)+4, 0, 0)];
		_categoryLabel.backgroundColor = [UIColor clearColor];
		_categoryLabel.font = [UIFont systemFontOfSize:14];
		_categoryLabel.textColor = UIColorFromRGB(0x1695ea);
		_categoryLabel.numberOfLines = 1;
		_categoryLabel.textAlignment = NSTextAlignmentRight;
		_categoryLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_categoryLabel.text = categoryStr;
		[_categoryLabel sizeToFitWithVersion];
		[self addSubview:_categoryLabel];
		
		_categoryLabel.frame = CGRectMake(_arrowView.frame.origin.x-6-_categoryLabel.frame.size.width, CGRectGetMaxY(_titleLabel.frame)+4,
										  _categoryLabel.frame.size.width, _categoryLabel.frame.size.height);
	}
	
	CGFloat maxWidth =  0;
	if (_categoryLabel)	maxWidth = _categoryLabel.frame.origin.x-30.f;
	else				maxWidth = self.frame.size.width-30.f;
	
	_subTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleLabel.frame)+3, maxWidth, 0)];
	_subTextLabel.backgroundColor = [UIColor clearColor];
	_subTextLabel.font = [UIFont systemFontOfSize:15];
	_subTextLabel.textColor = UIColorFromRGB(0x666666);
	_subTextLabel.numberOfLines = 1;
	_subTextLabel.textAlignment = NSTextAlignmentLeft;
	_subTextLabel.text = _item[@"subDispObjNm"];
	[_subTextLabel sizeToFitWithVersionHoldWidth];
	[self addSubview:_subTextLabel];

	_actionView = [[CPTouchActionView alloc] initWithFrame:self.bounds];
	_actionView.actionType = CPButtonActionTypeOpenSubview;
	_actionView.actionItem = _item[@"dispObjLnkUrl"];
    _actionView.wiseLogCode = [self wiseLogCodeWithIndex:[_item[@"index"] integerValue]];
    [_actionView setAccessibilityLabel:_item[@"dispObjNm"] Hint:@""];
	[self addSubview:_actionView];
	
	if (_categoryLabel) {
		
		_categoryActionView = [[CPTouchActionView alloc] initWithFrame:CGRectMake(_categoryLabel.frame.origin.x-3,
																				  _categoryLabel.frame.origin.y-3,
																				  CGRectGetMaxX(_arrowView.frame)-_categoryLabel.frame.origin.x+6,
																				  _categoryLabel.frame.size.height+6)];
		_categoryActionView.actionType = CPButtonActionTypeOpenSubview;
		_categoryActionView.actionItem = _item[@"dispObjLnkUrl2"];
        [_categoryActionView setAccessibilityLabel:_item[@"subDispObjNm"] Hint:@""];
		[self addSubview:_categoryActionView];
	}
}

- (NSString *)wiseLogCodeWithIndex:(NSInteger)index
{
    NSString *wiseLogCode = @"";
    
    if (index == 0)         wiseLogCode = @"MAJ1001";
    else if (index == 1)    wiseLogCode = @"MAJ1003";
    else if (index == 2)    wiseLogCode = @"MAJ1004";
    else if (index == 3)    wiseLogCode = @"MAJ1005";
    else if (index == 4)    wiseLogCode = @"MAJ1006";
    else if (index == 5)    wiseLogCode = @"MAJ1007";
    else if (index == 6)    wiseLogCode = @"MAJ1008";
    else if (index == 7)    wiseLogCode = @"MAJ1009";
    
    return wiseLogCode;
}

@end
