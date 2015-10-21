//
//  CPMartProductView.m
//  11st
//
//  Created by saintsd on 2015. 6. 30..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMartProductView.h"
#import "CPThumbnailView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPMartProductView ()
{
	NSDictionary *_item;
	
	CPThumbnailView *_bannerImageView;
	UIView *_benefitView;
	UILabel *_productNmLabel;
	UIView *_pointView;
	UILabel *_reviewCountLabel;
	UILabel *_sellerNmLabel;
	UIView *_bottomView;
	UILabel *_discountLabel;
	UILabel *_discountPerLabel;
	UILabel *_finalPriceLabel;
	UILabel *_finalPriceWonLabel;
	UILabel *_selPriceLabel;
	UIView *_selPriceLine;
	UIImageView *_badgeView;
	CPTouchActionView *_actionView;
}

@end

@implementation CPMartProductView

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
	self.backgroundColor = UIColorFromRGB(0xffffff);
	
	//썸네일
	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(10, 10, 130, 130)];
	[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:_item[@"prdImgUrl"]]];
	[self addSubview:_bannerImageView];

	//혜택
	NSArray *icons = _item[@"icons"];
	if (icons && icons.count > 1) {
		NSInteger myWayRt = [_item[@"myWayRt"] integerValue];
		_benefitView = [self getBenefitIconView:icons myWayRt:myWayRt];
		_benefitView.frame = CGRectMake(CGRectGetMaxX(_bannerImageView.frame)+10, 18, _benefitView.frame.size.width, _benefitView.frame.size.height);
		[self addSubview:_benefitView];
	}
	
	//상품명
	NSString *productNm = _item[@"prdNm"];
	_productNmLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bannerImageView.frame)+10, 18+19+7,
																self.frame.size.width-(CGRectGetMaxX(_bannerImageView.frame)+10)-10,
																0)];
	_productNmLabel.backgroundColor = [UIColor clearColor];
	_productNmLabel.textColor = UIColorFromRGB(0x111111);
	_productNmLabel.font = [UIFont systemFontOfSize:16];
	_productNmLabel.numberOfLines = 2;
	_productNmLabel.text = productNm;
	[_productNmLabel sizeToFitWithVersionHoldWidth];
	[self addSubview:_productNmLabel];
	
	//별점
	NSString *reviewCount = _item[@"reviewCount"];
	if (![reviewCount isEqualToString:@"0"] && reviewCount.length > 0) {
		CGFloat prdTotScor = [_item[@"prdTotScor"] floatValue];
		_pointView = [self getStarPointView:prdTotScor];
		_pointView.frame = CGRectMake(CGRectGetMaxX(_bannerImageView.frame)+10, self.frame.size.height-44-14-15-16,
									  _pointView.frame.size.width, _pointView.frame.size.height);
		[self addSubview:_pointView];
		
		_reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_reviewCountLabel.backgroundColor = [UIColor clearColor];
		_reviewCountLabel.textColor = UIColorFromRGB(0x5f5f5f);
		_reviewCountLabel.font = [UIFont systemFontOfSize:13];
		_reviewCountLabel.numberOfLines = 1;
		_reviewCountLabel.text = [NSString stringWithFormat:@"(%@)", reviewCount];
		[_reviewCountLabel sizeToFitWithVersion];
		[self addSubview:_reviewCountLabel];

		_reviewCountLabel.frame = CGRectMake(CGRectGetMaxX(_pointView.frame)+4,
											 _pointView.center.y-(_reviewCountLabel.frame.size.height/2),
											 _reviewCountLabel.frame.size.width,
											 _reviewCountLabel.frame.size.height);
	}
	
	//셀러이름
	NSString *sellerNm = _item[@"sellerNm"];
	_sellerNmLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bannerImageView.frame)+10,
															   self.frame.size.height-44-14-15,
															   self.frame.size.width-(CGRectGetMaxX(_bannerImageView.frame)+10)-10, 0)];
	_sellerNmLabel.backgroundColor = [UIColor clearColor];
	_sellerNmLabel.textColor = UIColorFromRGB(0x5f5f5f);
	_sellerNmLabel.font = [UIFont systemFontOfSize:14];
	_sellerNmLabel.numberOfLines = 1;
	_sellerNmLabel.text = sellerNm;
	[_sellerNmLabel sizeToFitWithVersionHoldWidth];
	[self addSubview:_sellerNmLabel];

	
	//하단 가격정보
	_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-44, self.frame.size.width, 44)];
	_bottomView.backgroundColor = UIColorFromRGB(0xf8f8f8);
	[self addSubview:_bottomView];

	CGFloat priceOffsetX = 10;
	NSString *discountText = _item[@"discountRate"];
	if ([discountText isEqualToString:@"특별가"]) {
		_discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_discountLabel.backgroundColor = [UIColor clearColor];
		_discountLabel.textColor = UIColorFromRGB(0xff272f);
		_discountLabel.font = [UIFont systemFontOfSize:20];
		_discountLabel.text = discountText;
		[_discountLabel sizeToFitWithVersion];
		[_bottomView addSubview:_discountLabel];
		
		_discountLabel.frame = CGRectMake(priceOffsetX, (_bottomView.frame.size.height/2)-(_discountLabel.frame.size.height/2),
										  _discountLabel.frame.size.width, _discountLabel.frame.size.height);
		
		priceOffsetX = CGRectGetMaxX(_discountLabel.frame)+9;
	}
	else {
		discountText = [discountText stringByReplacingOccurrencesOfString:@"%" withString:@""];
		_discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_discountLabel.backgroundColor = [UIColor clearColor];
		_discountLabel.textColor = UIColorFromRGB(0xff272f);
		_discountLabel.font = [UIFont boldSystemFontOfSize:24];
		_discountLabel.text = discountText;
		[_discountLabel sizeToFitWithVersion];
		[_bottomView addSubview:_discountLabel];
		
		_discountLabel.frame = CGRectMake(priceOffsetX, (_bottomView.frame.size.height/2)-(_discountLabel.frame.size.height/2),
										  _discountLabel.frame.size.width, _discountLabel.frame.size.height);
		
		priceOffsetX = CGRectGetMaxX(_discountLabel.frame)+1;
		
		_discountPerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_discountPerLabel.backgroundColor = [UIColor clearColor];
		_discountPerLabel.textColor = UIColorFromRGB(0xff272f);
		_discountPerLabel.font = [UIFont boldSystemFontOfSize:18];
		_discountPerLabel.text = @"%";
		[_discountPerLabel sizeToFitWithVersion];
		[_bottomView addSubview:_discountPerLabel];
		
		_discountPerLabel.frame = CGRectMake(priceOffsetX, _discountLabel.frame.origin.y+5,
											_discountPerLabel.frame.size.width, _discountPerLabel.frame.size.height);
		
		priceOffsetX = CGRectGetMaxX(_discountPerLabel.frame)+9;
	}
	
	//최종가격
	NSString *finalPrc = _item[@"finalDscPrc"];
	
	_finalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_finalPriceLabel.backgroundColor = [UIColor clearColor];
	_finalPriceLabel.textColor = UIColorFromRGB(0x292929);
	_finalPriceLabel.font = [UIFont boldSystemFontOfSize:18];
	_finalPriceLabel.text = finalPrc;
	[_finalPriceLabel sizeToFitWithVersion];
	[_bottomView addSubview:_finalPriceLabel];
	
	_finalPriceLabel.frame = CGRectMake(priceOffsetX, (_bottomView.frame.size.height/2)-(_finalPriceLabel.frame.size.height/2)+2,
										_finalPriceLabel.frame.size.width, _finalPriceLabel.frame.size.height);
	
	priceOffsetX = CGRectGetMaxX(_finalPriceLabel.frame);
	
	_finalPriceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_finalPriceWonLabel.backgroundColor = [UIColor clearColor];
	_finalPriceWonLabel.textColor = UIColorFromRGB(0x292929);
	_finalPriceWonLabel.font = [UIFont systemFontOfSize:12];
	_finalPriceWonLabel.text = @"원";
	[_finalPriceWonLabel sizeToFitWithVersion];
	[_bottomView addSubview:_finalPriceWonLabel];

	_finalPriceWonLabel.frame = CGRectMake(priceOffsetX, _finalPriceLabel.frame.origin.y+6,
										   _finalPriceWonLabel.frame.size.width, _finalPriceWonLabel.frame.size.height);
	
	priceOffsetX = CGRectGetMaxX(_finalPriceWonLabel.frame)+2.f;

	NSString *selPrc = _item[@"selPrc"];
	if (![finalPrc isEqualToString:selPrc] && ![@"0" isEqualToString:selPrc] && selPrc.length > 0) {
		
		_selPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_selPriceLabel.backgroundColor = [UIColor clearColor];
		_selPriceLabel.textColor = UIColorFromRGB(0x292929);
		_selPriceLabel.font = [UIFont systemFontOfSize:12];
		_selPriceLabel.text = [NSString stringWithFormat:@"(%@원)", selPrc];
		[_selPriceLabel sizeToFitWithVersion];
		[_bottomView addSubview:_selPriceLabel];
		
		_selPriceLabel.frame = CGRectMake(priceOffsetX, _finalPriceWonLabel.frame.origin.y,
										  _selPriceLabel.frame.size.width, _selPriceLabel.frame.size.height);
		
		_selPriceLine = [[UIView alloc] initWithFrame:CGRectMake(_selPriceLabel.frame.origin.x-1,
																 _selPriceLabel.center.y,
																 _selPriceLabel.frame.size.width+2,
																 1)];
		_selPriceLine.backgroundColor = UIColorFromRGB(0x292929);
		[_bottomView addSubview:_selPriceLine];
	}

	//터치
	_actionView = [[CPTouchActionView alloc] initWithFrame:self.bounds];
	_actionView.actionType = CPButtonActionTypeOpenSubview;
	_actionView.actionItem = _item[@"linkUrl"];
    _actionView.wiseLogCode = @"MAP0501";
    [_actionView setAccessibilityLabel:[NSString stringWithFormat:@"%@, %@원", _item[@"prdNm"], _item[@"finalDscPrc"]] Hint:@""];
	[self addSubview:_actionView];

	//Bedge
	NSString *badgeType = _item[@"badge"];
	if (badgeType && [badgeType length] > 0) {
		
		_badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 50, 50)];
		[self addSubview:_badgeView];
		
		if ([badgeType isEqualToString:@"sale"]) {
			_badgeView.image = [UIImage imageNamed:@"img_mart_sale.png"];
		}
		else if ([badgeType isEqualToString:@"frgft"]) {
			_badgeView.image = [UIImage imageNamed:@"img_mart_freebie.png"];
		}
		else if ([badgeType isEqualToString:@"plus"]) {
			_badgeView.image = [UIImage imageNamed:@"img_mart_plus.png"];
		}
		else if ([badgeType isEqualToString:@"hot"]) {
			_badgeView.image = [UIImage imageNamed:@"img_mart_hot.png"];
		}
	}
}

- (UIView *)getBenefitIconView:(NSArray *)icons myWayRt:(NSInteger)myWayRt
{
	UIView *iconsView = [[UIView alloc] initWithFrame:CGRectZero];
	
	
//	당일배송 : todayDlv
//	무료배송 : freeDlv
//	포인트 : point
//	내맘대로 : myWay
//	T멤버십 : tMember
//	OK캐쉬백 : ocb
//	마일리지 : mileage
//	카드할인 : discountCard


	NSInteger loopCount = icons.count;
	if (kScreenBoundsWidth <= 320) loopCount = (icons.count > 2 ? 2 : icons.count);
	
	CGFloat offsetX = 0.f;
	
	for (NSInteger i=0; i<loopCount; i++) {
		
		NSString *iconType = icons[i];
		
		UIColor *lineColor = UIColorFromRGB(0xffffff);
		UIColor *textColor = UIColorFromRGB(0xffffff);
		NSString *text = @"";
		UIFont *font = [UIFont boldSystemFontOfSize:12];
		BOOL isMyWay = NO;
		
		if ([@"freeDlv" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xb6c6ff);
			textColor = UIColorFromRGB(0x6989ff);
			text = @"무료배송";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"myWay" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xff3b0e);
			textColor = UIColorFromRGB(0xffffff);
			text = [NSString stringWithFormat:@"내맘대로 %ld%%", (long)myWayRt];
			font = [UIFont boldSystemFontOfSize:12];
			isMyWay = YES;
		}
		else if ([@"point" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xffb483);
			textColor = UIColorFromRGB(0xff822f);
			text = @"포인트";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"todayDlv" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xb6c6ff);
			textColor = UIColorFromRGB(0x6989ff);
			text = @"당일배송";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"tMember" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xffaa9e);
			textColor = UIColorFromRGB(0xff411c);
			text = @"T멤버십";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"ocb" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xffb483);
			textColor = UIColorFromRGB(0xff822f);
			text = @"OK캐쉬백";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"mileage" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xffb483);
			textColor = UIColorFromRGB(0xff822f);
			text = @"마일리지";
			font = [UIFont boldSystemFontOfSize:12];
		}
		else if ([@"discountCard" isEqualToString:iconType]) {
			lineColor = UIColorFromRGB(0xffb483);
			textColor = UIColorFromRGB(0xff822f);
			text = @"카드할인";
			font = [UIFont boldSystemFontOfSize:12];
		}

		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 0, 19)];
		[iconsView addSubview:bgView];
		
		if (isMyWay) {
			bgView.backgroundColor = lineColor;
		}
		else {
			bgView.layer.borderWidth = 1;
			bgView.layer.borderColor = lineColor.CGColor;
		}
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 19)];
		label.backgroundColor = [UIColor clearColor];
		label.font = font;
		label.textColor = textColor;
		label.text = text;
		[label sizeToFitWithVersionHoldHeight];
		[bgView addSubview:label];

		bgView.frame = CGRectMake(offsetX, 0, (isMyWay ? label.frame.size.width+4 : 50), 19);
		label.frame = CGRectMake((bgView.frame.size.width/2)-(label.frame.size.width/2), 0, label.frame.size.width, 19);
		
		offsetX += bgView.frame.size.width+1;
	}
	
	iconsView.frame = CGRectMake(0, 0, offsetX, 19);
	
	return iconsView;
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

@end
