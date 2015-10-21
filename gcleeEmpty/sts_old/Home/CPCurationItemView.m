//
//  CPCurationItemView.m
//  11st
//
//  Created by saintsd on 2015. 6. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCurationItemView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

#define ITEM_MARGIN		6

@interface CPCurationItemView ()
{
	NSArray *_items;
	BOOL _isLeft;
	BOOL _isMale;
	
	CGFloat _defaultWidth;
}

@end

@implementation CPCurationItemView

+ (CGFloat)viewHeight:(CGFloat)screenWidth
{
	CGFloat itemSize = (screenWidth - (ITEM_MARGIN * 2)) / 3;
	
	return (itemSize * 4) + (ITEM_MARGIN * 3);
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items isLeft:(BOOL)isLeft isMale:(BOOL)isMale
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		_isLeft = isLeft;
		_isMale = isMale;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	_defaultWidth = (self.frame.size.width - (ITEM_MARGIN * 2)) / 3;
	
	for (NSInteger i=0; i<[_items count]; i++)
	{
		CGRect viewFrame = CGRectZero;
		if (_isLeft)	viewFrame = [self getLeftItemFrameWithIndex:i];
		else			viewFrame = [self getRightItemFrameWithIndex:i];
		
		UIView *itemView = [self createItemViewWithIndex:i frame:viewFrame];
		[self addSubview:itemView];
	}
}

- (CGRect)getLeftItemFrameWithIndex:(NSInteger)index
{
	CGRect frame = CGRectZero;
	
	if (index == 0)
	{
		frame.origin.x = 0.f;
		frame.origin.y = 0.f;
		frame.size.width = (_defaultWidth * 2) + ITEM_MARGIN;
		frame.size.height = frame.size.width;
	}
	else if (index == 1)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = 0.f;
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 2)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = _defaultWidth + ITEM_MARGIN;
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 3)
	{
		frame.origin.x = 0.f;
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 4)
	{
		frame.origin.x = _defaultWidth + ITEM_MARGIN;
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 5)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 6)
	{
		frame.origin.x = 0.f;
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 7)
	{
		frame.origin.x = _defaultWidth + ITEM_MARGIN;
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 8)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	
	return frame;
}

- (CGRect)getRightItemFrameWithIndex:(NSInteger)index
{
	CGRect frame = CGRectZero;
	
	if (index == 0)
	{
		frame.origin.x = _defaultWidth + ITEM_MARGIN;
		frame.origin.y = 0.f;
		frame.size.width = (_defaultWidth * 2) + ITEM_MARGIN;
		frame.size.height = frame.size.width;
	}
	else if (index == 1)
	{
		frame.origin.x = 0.f;
		frame.origin.y = 0.f;
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 2)
	{
		frame.origin.x = 0.f;
		frame.origin.y = _defaultWidth + ITEM_MARGIN;
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 3)
	{
		frame.origin.x = 0.f;
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 4)
	{
		frame.origin.x = _defaultWidth + ITEM_MARGIN;
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 5)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 6)
	{
		frame.origin.x = 0.f;
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 7)
	{
		frame.origin.x = _defaultWidth + ITEM_MARGIN;
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	else if (index == 8)
	{
		frame.origin.x = (_defaultWidth * 2) + (ITEM_MARGIN * 2);
		frame.origin.y = (_defaultWidth * 3) + (ITEM_MARGIN * 3);
		frame.size.width = _defaultWidth;
		frame.size.height = _defaultWidth;
	}
	
	return frame;
}

- (UIView *)createItemViewWithIndex:(NSInteger)index frame:(CGRect)frame
{
	NSString *imgUrl = _items[index][@"lnkBnnrImgUrl"];
	
	UIView *view = [[UIView alloc] initWithFrame:frame];
	
	CPThumbnailView *thumbnailView = [[CPThumbnailView alloc] initWithFrame:view.bounds];
	[thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	[view addSubview:thumbnailView];
	
	//button
	CPTouchActionView *btn = [[CPTouchActionView alloc] init];
	[btn setFrame:view.bounds];
	[btn setTag:index];
	[btn setActionType:CPButtonActionTypeOpenPupup];
	[btn setActionItem:_items[index]];
	[btn setWiseLogCode:(_isMale ? @"MAH0601" : @"MAH0501")];
	[view addSubview:btn];
	
	[btn setAccessibilityLabel:_items[index][@"popupTitle"] Hint:@""];
	
	//테두리 라인
	UIView *tLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
	tLine.backgroundColor = UIColorFromRGBA(0x000000, 0.25);
	[view addSubview:tLine];

	UIView *lLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, view.frame.size.height)];
	lLine.backgroundColor = UIColorFromRGBA(0x000000, 0.25);
	[view addSubview:lLine];

	UIView *rLine = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width-1, 0, 1, view.frame.size.height)];
	rLine.backgroundColor = UIColorFromRGBA(0x000000, 0.25);
	[view addSubview:rLine];

	UIView *bLine = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-1, view.frame.size.width, 1)];
	bLine.backgroundColor = UIColorFromRGBA(0x000000, 0.25);
	[view addSubview:bLine];
	
	return view;
}

@end
