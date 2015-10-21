//
//  CPHomeTalkStyleListView.m
//  11st
//
//  Created by saintsd on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeTalkStyleListView.h"
#import "CPHomeTalkStyleProductItemView.h"

@interface CPHomeTalkStyleListView ()
{
	NSArray *_items;
	
	CPHomeTalkStyleProductItemView *_productView01;
	CPHomeTalkStyleProductItemView *_productView02;
	CPHomeTalkStyleProductItemView *_productView03;
	CPHomeTalkStyleProductItemView *_productView04;
	CPHomeTalkStyleProductItemView *_productView05;
	CPHomeTalkStyleProductItemView *_productView06;
}

@end

@implementation CPHomeTalkStyleListView

+ (CGSize)viewSizeWithData:(CGFloat)width
{
	CGFloat itemWidth = (width/2)-5;
	
	CGFloat height = 0.f;

	//아이템 높이 계산===
	//첫번째 아이템
	height += [Modules getRatioHeight:CGSizeMake(145, 193) screebWidth:itemWidth];
	height += 88;
	
	//마진
	height += 10;
	
	//두번째 아이템
	height += [Modules getRatioHeight:CGSizeMake(145, 145) screebWidth:itemWidth];
	height += 88;

	//마진
	height += 10;
	
	//세번째 아이템
	height += [Modules getRatioHeight:CGSizeMake(145, 145) screebWidth:itemWidth];
	height += 88;

	return CGSizeMake(width, height);
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	CGFloat itemWidth = (self.frame.size.width-10)/2;
	
	CGFloat lHeight = [Modules getRatioHeight:CGSizeMake(145, 193) screebWidth:itemWidth] + 88;
	CGFloat sHeight = [Modules getRatioHeight:CGSizeMake(145, 145) screebWidth:itemWidth] + 88;
	
	//첫번째 베너
	_productView01 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, lHeight)];
	[self addSubview:_productView01];

	//두번째 베너
	_productView02 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(itemWidth+10, 0, itemWidth, sHeight)];
	[self addSubview:_productView02];

	//세번째 베너
	_productView03 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_productView01.frame)+10, itemWidth, sHeight)];
	[self addSubview:_productView03];

	//네번째 베너
	_productView04 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(itemWidth+10, CGRectGetMaxY(_productView02.frame)+10, itemWidth, sHeight)];
	[self addSubview:_productView04];

	//다섯번째 베너
	_productView05 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_productView03.frame)+10, itemWidth, sHeight)];
	[self addSubview:_productView05];

	//여섯번째 베너
	_productView06 = [[CPHomeTalkStyleProductItemView alloc] initWithFrame:CGRectMake(itemWidth+10, CGRectGetMaxY(_productView04.frame)+10, itemWidth, lHeight)];
	[self addSubview:_productView06];
	
	[self setBannerItems];
}

- (void)setBannerItems
{
	NSMutableArray *trendArray = nil;
	NSMutableArray *talkArray = nil;
	NSMutableArray *curationArray = nil;
	
	for (NSInteger i=0; i<[_items count]; i++) {
		
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"homeTalkBannerList" isEqualToString:groupName])			talkArray = [_items[i][groupName] mutableCopy];
		else if ([@"homeTrendBannerList" isEqualToString:groupName])	trendArray = [_items[i][groupName] mutableCopy];
		else if ([@"homeCurationBannerList" isEqualToString:groupName])	curationArray = [_items[i][groupName] mutableCopy];
	}
	
	NSInteger randNum = 0;
	
	//트랜드 배너 아이템 셋팅
	NSDictionary *trendItem01 = nil;
	NSDictionary *trendItem02 = nil;
	
	randNum = rand() % [trendArray count];
	trendItem01 = [[NSMutableDictionary alloc] initWithDictionary:trendArray[randNum]];
	[trendArray removeObjectAtIndex:randNum];

	randNum = rand() % [trendArray count];
	trendItem02 = [[NSMutableDictionary alloc] initWithDictionary:trendArray[randNum]];
	[trendArray removeObjectAtIndex:randNum];

	//톡 배너 아이템 셋팅
	NSDictionary *talkItem01 = nil;
	NSDictionary *talkItem02 = nil;
	
	randNum = rand() % [talkArray count];
	talkItem01 = [[NSMutableDictionary alloc] initWithDictionary:talkArray[randNum]];
	[talkArray removeObjectAtIndex:randNum];
	
	randNum = rand() % [talkArray count];
	talkItem02 = [[NSMutableDictionary alloc] initWithDictionary:talkArray[randNum]];
	[talkArray removeObjectAtIndex:randNum];
	
	//패션 신상 아이템 셋팅
	NSDictionary *curaItem01 = nil;
	NSDictionary *curaItem02 = nil;
	
	randNum = rand() % [curationArray count];
	curaItem01 = [[NSMutableDictionary alloc] initWithDictionary:curationArray[randNum]];
	[curationArray removeObjectAtIndex:randNum];
	
	randNum = rand() % [talkArray count];
	curaItem02 = [[NSMutableDictionary alloc] initWithDictionary:curationArray[randNum]];
	[curationArray removeObjectAtIndex:randNum];
	
	//최종 아이템 셋팅
	[_productView01 setItem:trendItem01];
	[_productView06 setItem:trendItem02];
	
	[_productView02 setItem:talkItem01];
	[_productView03 setItem:talkItem02];
	
	[_productView04 setItem:curaItem01];
	[_productView05 setItem:curaItem02];
}


@end
