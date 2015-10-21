//
//  CPTotalBillGroupBannerCell.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTotalBillGroupBannerCell.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPTotalBillGroupBannerCell()
{
	CPThumbnailView *_bannerImageView;
	CPTouchActionView *_actionView;
}

@end

@implementation CPTotalBillGroupBannerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor = [UIColor clearColor];

	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
	_bannerImageView.showAnimation = NO;
	[self.contentView addSubview:_bannerImageView];
	
	_actionView = [[CPTouchActionView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:_actionView];
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	
	CGRect viewRt = self.bounds;
	
	CGFloat screenWidth = (IS_IPAD ? 360 : self.frame.size.width-20);
	CGFloat height = [Modules getRatioHeight:CGSizeMake(340, 170) screebWidth:screenWidth];
	
	_bannerImageView.frame = CGRectMake((viewRt.size.width/2)-(screenWidth/2), 0, screenWidth, height);
	[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:self.item[@"lnkBnnrImgUrl"]]];
	
	_actionView.frame = _bannerImageView.frame;
	_actionView.actionType = CPButtonActionTypeOpenSubview;
	_actionView.actionItem = self.item[@"dispObjLnkUrl"];
    _actionView.wiseLogCode = self.wiseLogCode;
}

@end
