//
//  CPHomeTalkStyleProductItemView.m
//  11st
//
//  Created by saintsd on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeTalkStyleProductItemView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"
#import "RegexKitLite.h"

#define BOTTOM_HEIGHT  88
@interface CPHomeTalkStyleProductItemView ()
{
	CPThumbnailView *_bannerImageView;
	UIView *_middleLine;
	UILabel *_bottomTextLabel;
	UILabel *_bottomCategoryLabel;
	UIImageView *_arrowView;
	
	UIView *_bottomLine;
	
	CPTouchActionView *_touchView;
	CPTouchActionView *_touchCategoryView;
}

@end

@implementation CPHomeTalkStyleProductItemView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-BOTTOM_HEIGHT)];
	[self addSubview:_bannerImageView];
	
	_middleLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerImageView.frame), self.frame.size.width, 1)];
	_middleLine.backgroundColor = UIColorFromRGB(0xf0f2f3);
	[self addSubview:_middleLine];
	
	_bottomTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (self.frame.size.height-BOTTOM_HEIGHT)+10.f, self.frame.size.width-30.f, 0)];
	_bottomTextLabel.backgroundColor = [UIColor clearColor];
	_bottomTextLabel.textColor = UIColorFromRGB(0x333333);
	_bottomTextLabel.font = [UIFont systemFontOfSize:18];
	_bottomTextLabel.numberOfLines = 2;
	[self addSubview:_bottomTextLabel];

	_bottomCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.frame.size.height-30, 0, 20)];
	_bottomCategoryLabel.backgroundColor = [UIColor clearColor];
	_bottomCategoryLabel.textColor = UIColorFromRGB(0x1695ea);
	_bottomCategoryLabel.font = [UIFont systemFontOfSize:14];
	_bottomCategoryLabel.numberOfLines = 1;
	[self addSubview:_bottomCategoryLabel];

	_arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, 7, 12)];
	_arrowView.image = [UIImage imageNamed:@"bt_home_arrow_recommand.png"];
	[self addSubview:_arrowView];
	
	_bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
	_bottomLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self addSubview:_bottomLine];
	
	_touchView = [[CPTouchActionView alloc] initWithFrame:self.bounds];
	[self addSubview:_touchView];
	
	_touchCategoryView = [[CPTouchActionView alloc] initWithFrame:CGRectZero];
	[self addSubview:_touchCategoryView];
	
	
	_bottomTextLabel.hidden = YES;
	_bottomCategoryLabel.hidden = YES;
	_arrowView.hidden = YES;
	_touchCategoryView.hidden = YES;
}

- (void)setItem:(NSDictionary *)item
{
	NSString *lnkBnnrImgUrl = item[@"lnkBnnrImgUrl"];
	NSString *dispObjNm = item[@"dispObjNm"];
	NSString *subDispObjNm = item[@"subDispObjNm"];
	NSString *dispObjLnkUrl = item[@"dispObjLnkUrl"];
	NSString *dispObjLnkUrl2 = item[@"dispObjLnkUrl2"];
	
	if (lnkBnnrImgUrl && [lnkBnnrImgUrl length] > 0) {
		[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:lnkBnnrImgUrl]];
	}
	
	if (dispObjNm && [dispObjNm length] > 0) {
		_bottomTextLabel.text = dispObjNm;
		[_bottomTextLabel sizeToFitWithVersionHoldWidth];
		_bottomTextLabel.hidden = NO;
	}
	
	if (subDispObjNm && [subDispObjNm length] > 0) {
		_bottomCategoryLabel.text = subDispObjNm;
		[_bottomCategoryLabel sizeToFitWithVersionHoldHeight];
		_bottomCategoryLabel.hidden = NO;
		
		_arrowView.frame = CGRectMake(CGRectGetMaxX(_bottomCategoryLabel.frame)+6,
									  _bottomCategoryLabel.frame.origin.y+4,
									  _arrowView.frame.size.width,
									  _arrowView.frame.size.height);
		_arrowView.hidden = NO;
	}
	
	if (dispObjLnkUrl && [dispObjLnkUrl length] > 0) {
		_touchView.actionType = CPButtonActionTypeOpenSubview;
		_touchView.actionItem = dispObjLnkUrl;
        [_touchView setAccessibilityLabel:dispObjNm Hint:@""];
	}

	if (dispObjLnkUrl2 && [dispObjLnkUrl2 length] > 0) {
		
		if (!_bottomCategoryLabel.hidden)
		{
			_touchCategoryView.frame = CGRectMake(_bottomCategoryLabel.frame.origin.x-5,
												  _bottomCategoryLabel.frame.origin.y-2,
												  _bottomCategoryLabel.frame.size.width+6+_arrowView.frame.size.width+10,
												  _bottomCategoryLabel.frame.size.height+4);
			_touchCategoryView.hidden = NO;
			
			if ([dispObjLnkUrl2 isMatchedByRegex:@"^app://"]) {
				_touchCategoryView.actionType = CPButtonActionTypeAppScheme;
				_touchCategoryView.actionItem = dispObjLnkUrl2;
			}
			else {
                _touchCategoryView.actionType = CPButtonActionTypeOpenSubview;
				_touchCategoryView.actionItem = dispObjLnkUrl2;
			}
            [_touchCategoryView setAccessibilityLabel:subDispObjNm Hint:@""];
		}
	}
}

@end
