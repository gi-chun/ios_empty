//
//  CPHomeDirectServiceAreaView.m
//  11st
//
//  Created by saintsd on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeDirectServiceAreaView.h"
#import "CPTouchActionView.h"

#define BUTTON_HEIGHT	40

@interface CPHomeDirectServiceAreaView ()
{
	NSArray *_items;
	NSInteger _columnCount;
	UIFont *_font;
	UIColor *_tColor;
}

@end

@implementation CPHomeDirectServiceAreaView

+ (CGSize)viewSizeWithData:(NSArray *)items width:(CGFloat)width columnCount:(NSInteger)columnCount
{
	NSInteger weight = [items count];
	
	if (IS_IPAD) {
		if (weight % 2 != 0) weight = weight + 1;
	}
	
	NSInteger lineNumber = weight / columnCount;
	if ((weight/columnCount >= 1 && (weight % columnCount != 0))) lineNumber = lineNumber+1;
	
	if ([items count] <= columnCount) lineNumber = 1;
	
	return CGSizeMake(width, (BUTTON_HEIGHT*lineNumber));
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount font:(UIFont *)font textColor:(UIColor *)tColor
{
	if (self = [super initWithFrame:frame]) {
		if (font) _font = font;
		if (items) _items = [[NSArray alloc] initWithArray:items];
		if (tColor) _tColor = tColor;
		
		_columnCount = columnCount;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = UIColorFromRGB(0xf0f2f3);
	self.clipsToBounds = YES;
	
	NSInteger column = (_columnCount > [_items count] ? [_items count] : _columnCount);
	
	for (NSInteger i=0; i<[_items count]; i++) {

		NSInteger itemWidth = ((self.frame.size.width) / column) - 1;
		NSInteger itemX = (i % column) * itemWidth + (i % column) % column;
		NSInteger itemY = (i / column) * BUTTON_HEIGHT + (i / column);

		//뷰 뒷부분에 공백이 남는 부분을 임의로 채워준다.
		if (i != 0 && i % column == (column-1)) {
			itemWidth = (self.frame.size.width) - itemX;
		}

		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(itemX, itemY, itemWidth, BUTTON_HEIGHT)];
		view.backgroundColor = [UIColor whiteColor];
		[self addSubview:view];
		
		NSString *text = _items[i][@"text"];
		
		if ([self isArrowButton:text]) {

			UIImage *image = [UIImage imageNamed:@"bt_home_arrow_contents.png"];
			UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
			arrowView.image = image;
			[view addSubview:arrowView];
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = UIColorFromRGB(0x311b92);
			label.font = _font;
			label.textAlignment = NSTextAlignmentLeft;
			label.text = text;
			[label sizeToFitWithVersion];
			[view addSubview:label];
			
			label.frame = CGRectMake(((view.frame.size.width/2)-(label.frame.size.width/2))-((5+image.size.width)/2),
									 (view.frame.size.height/2)-(label.frame.size.height/2),
									 label.frame.size.width, label.frame.size.height);
			
			arrowView.frame = CGRectMake(CGRectGetMaxX(label.frame)+5,
										 label.center.y-(image.size.height/2),
										 image.size.width, image.size.height);
		}
		else {
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = _tColor;
			label.font = _font;
			label.textAlignment = NSTextAlignmentLeft;
			label.text = text;
			[label sizeToFitWithVersion];
			label.frame = CGRectMake((view.frame.size.width/2)-(label.frame.size.width/2),
									 (view.frame.size.height/2)-(label.frame.size.height/2),
									 label.frame.size.width, label.frame.size.height);
			[view addSubview:label];
		}

		NSString *linkUrl = _items[i][@"linkUrl"];
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:view.bounds];
		[view addSubview:actionView];
		
		if (linkUrl && [linkUrl length] > 0) {
			actionView.actionType = CPButtonActionTypeOpenSubview;
			actionView.actionItem = linkUrl;
		}
	}
}

- (BOOL)isArrowButton:(NSString *)text
{
	BOOL isArrowButton = NO;
	
	if ([@"기획전 홈" isEqualToString:[text trim]]) {
		isArrowButton = YES;
	}
	else if ([@"베스트 홈" isEqualToString:[text trim]]) {
		isArrowButton = YES;
	}
	else if ([@"쇼킹딜 홈" isEqualToString:[text trim]]) {
		isArrowButton = YES;
	}
	else if ([@"전체보기" isEqualToString:[text trim]]) {
		isArrowButton = YES;
	}
	
	return isArrowButton;
}

@end
