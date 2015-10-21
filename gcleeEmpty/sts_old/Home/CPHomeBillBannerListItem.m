//
//  CPHomeBillBannerListItem.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeBillBannerListItem.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPHomeBillBannerListItem ()
{
	CPThumbnailView *_bannerImageView;
	CPTouchActionView *_selectionView;
}

@end

@implementation CPHomeBillBannerListItem

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	_bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
	[self addSubview:_bannerImageView];
	
	
	_selectionView = [[CPTouchActionView alloc] initWithFrame:CGRectZero];
	[self addSubview:_selectionView];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect rectClient = self.bounds;
	
	_bannerImageView.frame = rectClient;
	_selectionView.frame = rectClient;
}

- (void)setItem:(NSDictionary *)item
{
	if (_item != item) {
		_item = item;
		
		[self updateView];
	}
}

- (void)updateView
{
	NSString *bannerUrl = _item[@"homeBillBanner"][@"lnkBnnrImgUrl"];
    NSString *dispObjNm = _item[@"homeBillBanner"][@"dispObjNm"];
    
	[_bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:bannerUrl]];
	
	[_selectionView setActionType:CPButtonActionTypeOpenSubview];
	[_selectionView setActionItem:_item[@"homeBillBanner"][@"dispObjLnkUrl"]];
    [_selectionView setWiseLogCode:self.wiseLogCode];
    [_selectionView setAccessibilityLabel:dispObjNm Hint:@""];
	[self setNeedsLayout];
}

@end
