//
//  CPTrendLineBannerCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendLineBannerCell.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPTrendLineBannerCell ()
{
	UIView *_contentView;
	UIView *_lineView;
}

@end

@implementation CPTrendLineBannerCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.contentView.backgroundColor = [UIColor clearColor];
	
	_contentView = [[UIView alloc] init];
	_contentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_contentView];
	
	_lineView = [[UIView alloc] init];
	_lineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
	NSString *imageUrl = self.item[@"lnkBnnrImgUrl"];
	NSString *dispObjNm = self.item[@"dispObjNm"];
	
	self.contentView.frame = self.bounds;
	_contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-11);

	//backgroundColor
	NSString *colorValue = self.item[@"extraText"];
	if (colorValue.length >= 7) {
		unsigned colorInt = 0;
		[[NSScanner scannerWithString:[colorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
		[_contentView setBackgroundColor:UIColorFromRGB(colorInt)];
	}
	else {
		[_contentView setBackgroundColor:[UIColor whiteColor]];
	}
	
	for (UIView *subview in _contentView.subviews) {
		[subview removeFromSuperview];
	}

	CGRect bannerRect = CGRectMake((_contentView.frame.size.width/2)-150, 0, 300, 60);
	
	CPThumbnailView *thumbnailView = [[CPThumbnailView alloc] initWithFrame:bannerRect];
	[_contentView addSubview:thumbnailView];
	[thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];

	CPTouchActionView *btn = [[CPTouchActionView alloc] init];
	[btn setFrame:_contentView.bounds];
	btn.actionType = CPButtonActionTypeOpenSubview;
	btn.actionItem = self.item[@"dispObjLnkUrl"];
	btn.wiseLogCode = @"";
	[btn setAccessibilityLabel:dispObjNm Hint:@""];
	[_contentView addSubview:btn];
	
	[_lineView setFrame:CGRectMake(_contentView.frame.origin.x,
								   CGRectGetMaxY(_contentView.frame),
								   _contentView.frame.size.width,
								   1)];
}

@end
