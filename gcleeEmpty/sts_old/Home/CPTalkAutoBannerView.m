//
//  CPTalkAutoBanner.m
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTalkAutoBannerView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "NSTimer+Blocks.h"
#import "CPTouchActionView.h"

@interface CPTalkAutoBannerView ()
{
	NSArray *_items;
	NSInteger _index;
	CPThumbnailView *_thumbnailView;
	CPTouchActionView *_touchButton;

	NSString *_extraColor;
	NSString *_lnkBnnrImgUrl;
	NSString *_dispObjLnkUrl;
	NSString *_dispObjNm;
	
	NSTimer *_timer;
}

@end

@implementation CPTalkAutoBannerView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		_index = 0;

		[self initSubviews];
		[self setBannerItem:_index];
		
		if ([_items count] > 1) {
			[self updateTimer];
		}
	}
	return self;
}

- (void)dealloc {
	[self stopTimer];
}

- (void)removeFromSuperview
{
	[self stopTimer];
	
	[super removeFromSuperview];
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	_thumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-150, 0, 300, 60)];
	_thumbnailView.backgroundColor = [UIColor clearColor];
	[self addSubview:_thumbnailView];
	
	_touchButton = [[CPTouchActionView alloc] init];
	[_touchButton setFrame:self.bounds];
	[self addSubview:_touchButton];
}

- (void)setBannerItem:(NSInteger)index
{
	[self setBannerData:index];
	
	if (_extraColor && [_extraColor length] >= 7) {
		unsigned colorInt = 0;
		[[NSScanner scannerWithString:[_extraColor substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
		[self setBackgroundColor:UIColorFromRGB(colorInt)];
	}
	
	if (_lnkBnnrImgUrl && [_lnkBnnrImgUrl length] > 0) {
		[_thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:_lnkBnnrImgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	
	if (_dispObjLnkUrl && [_dispObjLnkUrl length] > 0) {
		_touchButton.actionType = CPButtonActionTypeOpenSubview;
		_touchButton.actionItem = _dispObjLnkUrl;
		_touchButton.wiseLogCode = @"MAF0500";
		
		if (_dispObjNm) {
			[_touchButton setAccessibilityLabel:_dispObjNm Hint:@""];
		}
	}
}

- (void)setBannerData:(NSInteger)index
{
	if ([_items count] <= index) return;
	
	NSString *groupName = _items[index][@"groupName"];
	if ([groupName isEqualToString:@"lineBanner"]) {
		
		NSString *extraText = (_items[index][@"lineBanner"][@"extraText"] ? _items[index][@"lineBanner"][@"extraText"] : @"#ffffff");
		NSString *dispObjLnkUrl = _items[index][@"lineBanner"][@"dispObjLnkUrl"];
		NSString *lnkBnnrImgUrl = _items[index][@"lineBanner"][@"lnkBnnrImgUrl"];
		NSString *dispObjNm = _items[index][@"lineBanner"][@"dispObjNm"];
		
		if (extraText)		_extraColor = [[NSString alloc] initWithString:extraText];
		if (dispObjLnkUrl)	_dispObjLnkUrl = [[NSString alloc] initWithString:dispObjLnkUrl];
		if (lnkBnnrImgUrl)	_lnkBnnrImgUrl = [[NSString alloc] initWithString:lnkBnnrImgUrl];
		if (dispObjNm)		_dispObjNm = [[NSString alloc] initWithString:dispObjNm];
	}
}

- (NSInteger)setNextIndex:(NSInteger)cIndex items:(NSArray *)items
{
	if (cIndex >= [items count]) return 0;
	if (cIndex < 0) return 0;
	
	return cIndex;
}

#pragma timer
- (void)updateTimer
{
	_timer = [NSTimer scheduledTimerWithTimeInterval:5.f block:^{
		_index = [self setNextIndex:_index+1 items:_items];
		[self setBannerItem:_index];
	} repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
	if (_timer && _timer.isValid)
	{
		[_timer invalidate];
		_timer = nil;
	}
}

@end
