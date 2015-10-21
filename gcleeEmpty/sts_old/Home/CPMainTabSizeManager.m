//
//  CPMainTabSizeManager.m
//  11st
//
//  Created by saintsd on 2015. 6. 18..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMainTabSizeManager.h"
#import "CPFooterButtonView.h"
#import "CPCurationItemView.h"
#import "CPEventWinnerView.h"
#import "CPMartServiceAreaListView.h"
#import "CPHomeDirectServiceAreaView.h"
#import "CPHomeShadowTitleView.h"
#import "CPHomeTalkStyleListView.h"
#import "CPHomePopularKeywordView.h"

#define SHADOW_HEIGHT	1


@implementation CPMainTabSizeManager

+ (CGRect)getFrameWithGroupName:(NSString *)groupName item:(id)item
{
	CGSize size = [self getSizeWithGroupName:groupName item:item];
	
	return CGRectMake(0, 0, size.width, size.height);
}

+ (CGSize)getSizeWithGroupName:(NSString *)groupName item:(id)item
{
	CGSize _size = CGSizeZero;
	
	if ([@"noData" isEqualToString:groupName])							_size = [self noData];
	else if ([@"commonProduct" isEqualToString:groupName])				_size = [self commonProduct];
	else if ([@"bestProductCategory" isEqualToString:groupName])		_size = [self bestProductCategory];
	else if ([@"lineBanner" isEqualToString:groupName])					_size = [self lineBanner];
	else if ([@"autoBannerArea" isEqualToString:groupName])				_size = [self autoBannerArea];
	else if ([@"bannerProduct" isEqualToString:groupName])				_size = [self bannerProduct];
	else if ([@"shockingDealAppLink" isEqualToString:groupName])		_size = [self shockingDealAppLink];
	else if ([@"specialBestArea" isEqualToString:groupName])			_size = [self specialBestArea:item];
	else if ([@"specialTalkArea" isEqualToString:groupName])			_size = [self specialTalkArea:item];
	else if ([@"middleServiceArea" isEqualToString:groupName])			_size = [self middleServiceArea:item];
	else if ([@"bottomTalkArea" isEqualToString:groupName])				_size = [self bottomTalkArea:item];
	else if ([@"commonMoreView" isEqualToString:groupName])				_size = [self commonMoreView];
	else if ([@"curationRightGroup" isEqualToString:groupName])			_size = [self curationRightGroup];
	else if ([@"curationLeftGroup" isEqualToString:groupName])			_size = [self curationLeftGroup];
	else if ([@"martBillBannerList" isEqualToString:groupName])			_size = [self martBillBannerList];
	else if ([@"martLineBanner" isEqualToString:groupName])				_size = [self martLineBanner];
	else if ([@"martProduct" isEqualToString:groupName])				_size = [self martProduct];
	else if ([@"subEventTwoTab" isEqualToString:groupName])				_size = [self subEventTwoTab];
	else if ([@"eventPlanBanner" isEqualToString:groupName])			_size = [self eventPlanBanner];
	else if ([@"eventZoneGroupBanner" isEqualToString:groupName])		_size = [self eventZoneGroupBanner];
	else if ([@"eventWinner" isEqualToString:groupName])				_size = [self eventWinner:item];
	else if ([@"subStyleTwoTab" isEqualToString:groupName])				_size = [self subStyleTwoTab];
	else if ([@"genderRadioArea" isEqualToString:groupName])			_size = [self genderRadioArea];
	else if ([@"talkBanner" isEqualToString:groupName])					_size = [self talkBanner:item];
	else if ([@"serviceAreaList" isEqualToString:groupName])			_size = [self serviceAreaList];
	else if ([@"martServiceAreaList" isEqualToString:groupName])		_size = [self martServiceAreaList:item];
	else if ([@"bottomMartArea" isEqualToString:groupName])				_size = [self bottomMartArea];
	else if ([@"homeDirectServiceArea" isEqualToString:groupName])		_size = [self homeDirectServiceArea:item];
	else if ([@"textLine" isEqualToString:groupName])					_size = [self textLine];
	else if ([@"randomBannerArea" isEqualToString:groupName])			_size = [self randomBannerArea];
	else if ([@"homeTalkAndStyleGroup" isEqualToString:groupName])		_size = [self homeTalkAndStyleGroup:item];
	else if ([@"homePopularKeywordGroup" isEqualToString:groupName])	_size = [self homePopularKeywordGroup:item];
	else if ([@"cornerBanner" isEqualToString:groupName])				_size = [self cornerBanner];
	else if ([@"simpleBestProduct" isEqualToString:groupName])			_size = [self simpleBestProduct];
	
	return _size;
}

+ (CGSize)noData
{
	return CGSizeMake(kScreenBoundsWidth-20, 215);
}

+ (CGSize)commonProduct
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	
	return CGSizeMake(cellWidth, cellWidth+75+SHADOW_HEIGHT);
}

+ (CGSize)bestProductCategory
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	return CGSizeMake(cellWidth, cellWidth+75+SHADOW_HEIGHT);
}

+ (CGSize)lineBanner
{
	return CGSizeMake(kScreenBoundsWidth-20, 60+SHADOW_HEIGHT);
}

+ (CGSize)autoBannerArea
{
	return CGSizeMake(kScreenBoundsWidth-20, 60+SHADOW_HEIGHT);
}

+ (CGSize)bannerProduct
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = productWidth/1.78+121+SHADOW_HEIGHT;
	
	return CGSizeMake(productWidth, productHeight);
}

+ (CGSize)shockingDealAppLink
{
	return CGSizeMake(kScreenBoundsWidth-20, 34+SHADOW_HEIGHT);
}

+ (CGSize)specialBestArea:(NSDictionary *)item
{
	NSArray *items = item[@"items"];
	NSInteger columnCount = [item[@"columnCount"] integerValue];
	
	return [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount];
}

+ (CGSize)specialTalkArea:(NSDictionary *)item
{
	NSArray *items = item[@"items"];
	NSInteger columnCount = [item[@"columnCount"] integerValue];
	
	return [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount];
}

+ (CGSize)middleServiceArea:(NSDictionary *)item
{
	NSArray *items = item[@"middleServiceArea"];
	NSInteger columnCount = [item[@"columnCount"] integerValue];
	
	return [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount];
}

+ (CGSize)bottomTalkArea:(NSDictionary *)item
{
    CGFloat columnCount = (IS_IPAD ? 4 : 2);
    CGFloat columnWidth = (kScreenBoundsWidth-20) / columnCount;
    
    CGFloat lineHeight = [Modules getRatioHeight:CGSizeMake(170, 74) screebWidth:columnWidth];
	
    return CGSizeMake(kScreenBoundsWidth-20, lineHeight * (IS_IPAD ? 2 : 4));
}

+ (CGSize)commonMoreView
{
	return CGSizeMake(kScreenBoundsWidth-20, 34+SHADOW_HEIGHT);
}

+ (CGSize)curationRightGroup
{
	return CGSizeMake(kScreenBoundsWidth-20, [CPCurationItemView viewHeight:kScreenBoundsWidth-20]);
}

+ (CGSize)curationLeftGroup
{
	return CGSizeMake(kScreenBoundsWidth-20, [CPCurationItemView viewHeight:kScreenBoundsWidth-20]);
}

+ (CGSize)martBillBannerList
{
	return CGSizeMake(kScreenBoundsWidth-20, [Modules getRatioHeight:CGSizeMake(720, 330) screebWidth:kScreenBoundsWidth-20]+SHADOW_HEIGHT);
}

+ (CGSize)martLineBanner
{
	return CGSizeMake(kScreenBoundsWidth-20, 55+SHADOW_HEIGHT);
}

+ (CGSize)martProduct
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = 150 + 44;
	
	return CGSizeMake(productWidth, productHeight+SHADOW_HEIGHT);
}

+ (CGSize)subEventTwoTab
{
	return CGSizeMake(kScreenBoundsWidth-20, 36+SHADOW_HEIGHT);
}

+ (CGSize)eventPlanBanner
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = [Modules getRatioHeight:CGSizeMake(720, 360) screebWidth:productWidth];
	
	return CGSizeMake(productWidth, productHeight+SHADOW_HEIGHT);
}

+ (CGSize)eventZoneGroupBanner
{
	return CGSizeMake(kScreenBoundsWidth-20, 122+SHADOW_HEIGHT);
}

+ (CGSize)eventWinner:(NSDictionary *)item
{
	NSArray *items = item[@"eventWinner"];
	return CGSizeMake(kScreenBoundsWidth-20, [CPEventWinnerView getViewHeight:items]+SHADOW_HEIGHT);
	
}

+ (CGSize)subStyleTwoTab
{
	return CGSizeMake(kScreenBoundsWidth-20, 36+SHADOW_HEIGHT);
}

+ (CGSize)genderRadioArea
{
	return CGSizeMake(kScreenBoundsWidth-20, 22);
}

+ (CGSize)talkBanner:(NSDictionary *)item
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = 0.f;
	
	CGFloat widthMargin = (productWidth == 300 ? 10 : 16);
	
	//기본 썸네일 높이 + 타이틀 영역 + 태그영역
	// Header 높이 계산
	//타이틀
	NSString *title = item[@"talkBanner"][@"title"];
	NSString *dispObjNm = item[@"talkBanner"][@"dispObjNm"];
	//조회수
	NSString *dispObjBgnDy = item[@"talkBanner"][@"dispObjBgnDy"];
	NSString *clickCnt = item[@"talkBanner"][@"clickCnt"];
	//썸네일 / 텍스트
	NSString *imageUrl = item[@"talkBanner"][@"lnkBnnrImgUrl"];
	NSString *lnkBnnrTxt = [item[@"talkBanner"][@"lnkBnnrTxt"] trim];
	
	if (IS_IPAD || (imageUrl && [imageUrl length] > 0)) {
		productHeight = [Modules getRatioHeight:CGSizeMake(676, 400) screebWidth:productWidth];
	}
	else {
		productHeight = [Modules getLabelHeightWithText:lnkBnnrTxt
												  frame:CGRectMake(0, 0, productWidth-60.f, 0)
												   font:[UIFont boldSystemFontOfSize:19]
												  lines:5
										  textAlignment:NSTextAlignmentLeft];
		productHeight += 40; //상하단 마진 20픽셀씩.
	}
	
	productHeight += 11;	//margin
	productHeight += [Modules getLabelHeightWithText:[NSString stringWithFormat:@"%@ %@", title, dispObjNm]
											   frame:CGRectMake(widthMargin, 0, productWidth-(widthMargin*2), 0.f)
												font:[UIFont systemFontOfSize:16.f]
											   lines:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7") && !IS_IPAD ? 2 : 1)
									   textAlignment:NSTextAlignmentLeft];
	
	productHeight += 3.f;	//margin
	productHeight += [Modules getLabelHeightWithText:[NSString stringWithFormat:@"%@ | %@", dispObjBgnDy, clickCnt]
											   frame:CGRectMake(widthMargin, 0, productWidth-(widthMargin*2), 0.f)
												font:[UIFont systemFontOfSize:13.f]
											   lines:1
									   textAlignment:NSTextAlignmentLeft];
	productHeight += 10.f;	//margin
	
	// Footer 높이 계산
	NSArray *tagItems = item[@"talkBanner"][@"tagList"];
	if ((!tagItems || [tagItems count] == 0) && !IS_IPAD) {
		productHeight += 1.f;
	}
	else {
		productHeight += 35.f;
	}
	
	return CGSizeMake(productWidth, productHeight+SHADOW_HEIGHT);
}

+ (CGSize)serviceAreaList
{
	return CGSizeMake(kScreenBoundsWidth-20, 40+SHADOW_HEIGHT);
}

+ (CGSize)martServiceAreaList:(NSDictionary *)item
{
	NSArray *array = item[@"martServiceAreaList"];
	
	//데이터 가공
	NSMutableArray *items = [NSMutableArray array];
	for (NSInteger i=0; i<[array count]; i++) {
		NSMutableDictionary *dict = [array[i] mutableCopy];
		
		if ([@"전체보기" isEqualToString:[dict[@"dispObjNm"] trim]])	[dict setValue:@"totalPage" forKey:@"type"];
		else														[dict setValue:@"webImage" forKey:@"type"];
		
		[dict setValue:@"1" forKey:@"weight"];
		[items addObject:dict];
	}
	
	//첫번째 데이터 삽입
	NSMutableDictionary *firstDict = [NSMutableDictionary dictionary];
	[firstDict setValue:@"localImage" forKey:@"type"];
	[firstDict setValue:@"2" forKey:@"weight"];
	[firstDict setValue:@"인기브랜드" forKey:@"dispObjNm"];
	[firstDict setValue:@"" forKey:@"dispObjLnkUrl"];
	[items insertObject:firstDict atIndex:0];

	CGSize size = [CPMartServiceAreaListView viewSizeWithData:items columnCount:(IS_IPAD ? 6 : 4)];
	return CGSizeMake(size.width, size.height);
}

+ (CGSize)bottomMartArea
{
	return CGSizeMake(kScreenBoundsWidth-20, 40+SHADOW_HEIGHT);
}

+ (CGSize)homeDirectServiceArea:(NSDictionary *)item
{
	NSArray *array = item[@"homeDirectServiceArea"];
	NSInteger columnCount = (IS_IPAD ? 6 : 3);
	
	CGSize size = [CPHomeDirectServiceAreaView viewSizeWithData:array width:kScreenBoundsWidth-20 columnCount:columnCount];
	
	return CGSizeMake(size.width, size.height+SHADOW_HEIGHT);
}

+ (CGSize)textLine
{
	return CGSizeMake(kScreenBoundsWidth-20, 35);
}

+ (CGSize)randomBannerArea
{
	return CGSizeMake(kScreenBoundsWidth-20, 60+SHADOW_HEIGHT);
}

+ (CGSize)homeTalkAndStyleGroup:(NSDictionary *)item
{
	CGFloat width = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20 columnCount:(IS_IPAD ? 2 : 1)];
	CGFloat height = 0.f;
	
	NSDictionary *halfTextLine = item[@"halfTextLine"];
	NSArray *homeTalkStyleList = item[@"homeTalkStyleList"];
	NSArray *homeDirectTabArea = item[@"homeDirectTabArea"];
	
	if (halfTextLine)		height += [CPHomeShadowTitleView viewSizeWithData:width].height;
	if (homeTalkStyleList)	height += [CPHomeTalkStyleListView viewSizeWithData:width].height;
	if (homeDirectTabArea)  height += ([CPHomeDirectServiceAreaView viewSizeWithData:homeDirectTabArea
																			   width:width
																		 columnCount:[homeDirectTabArea count]].height)+10;
	
	return CGSizeMake(width, height);
}

+ (CGSize)homePopularKeywordGroup:(NSDictionary *)item
{
	CGFloat width = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20 columnCount:(IS_IPAD ? 2 : 1)];
	CGFloat height = 0.f;
	
	//패드일 경우 옆의 셀과 높이를 맞춰준다.
	if (IS_IPAD ) {
		height = [item[@"talkStyleHeight"] floatValue];
		return CGSizeMake(width, height);
	}
	
	//아이폰인 경우에는 계산한다.
	NSArray *popularKeywordArea = item[@"popularKeywordArea"];
	if (popularKeywordArea) {
		
		NSString *popularKeywordOpenYn = item[@"openYn"];
		CGSize keywordSize = [CPHomePopularKeywordView viewSizeWithData:width
																  items:popularKeywordArea
																 isOpen:([popularKeywordOpenYn isEqualToString:@"Y"])];
		
		height += keywordSize.height;
	}

	NSArray *homeDirectBottomArea = item[@"homeDirectBottomArea"];
	if (homeDirectBottomArea) {
		CGSize serviceSize = [CPHomeDirectServiceAreaView viewSizeWithData:homeDirectBottomArea width:width columnCount:4];
		
		height += serviceSize.height + 10;
	}
	
	return CGSizeMake(width, height);
}

+ (CGSize)cornerBanner
{
	CGFloat width = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20 columnCount:(IS_IPAD ? 2 : 1)];
	CGFloat height = 0.f;
	
	height += [Modules getRatioHeight:CGSizeMake(700, 400) screebWidth:width];
	height += 63.f;
	
	return CGSizeMake(width, height+SHADOW_HEIGHT);
}

+ (CGSize)simpleBestProduct
{
    CGFloat screenWidth = kScreenBoundsWidth-20;
    CGFloat columnCount = IS_IPAD ? 4 : 2;
    
    CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
    
    return CGSizeMake(cellWidth, cellWidth+70+SHADOW_HEIGHT);
}

@end
