//
//  CPMainTabCollectionData.m
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMainTabCollectionData.h"
#import "CPMainTabSizeManager.h"

@implementation CPMainTabCollectionData

- (id)init
{
	return [self initWithData:nil];
}

- (id)initWithData:(NSArray *)dataArray
{
	self = [super init];
	if (self) {
		self.items = [NSMutableArray array];
		self.allGroupName = [NSMutableDictionary dictionary];
		self.noData = [NSMutableArray array];
		
		if (dataArray) {
			[self dataParser:dataArray];
		}
	}
	return self;
}

- (void)setData:(NSArray *)dataArray
{
	[self removeAllObjects];
	[self dataParser:dataArray];
}

- (void)dataParser:(NSArray *)dataArray
{
	NSPredicate *itemsPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@)", @"noData", @"commonProduct", @"bestProductCategory", @"bannerProduct", @"lineBanner", @"shockingDealAppLink", @"talkBanner", @"specialBestArea", @"commonMoreView", @"eventPlanBanner", @"subEventTwoTab", @"eventZoneGroupBanner", @"eventWinner", @"autoBannerArea", @"subStyleTwoTab", @"genderRadioArea", @"curationLeftGroup", @"curationRightGroup", @"middleServiceArea", @"bottomTalkArea", @"martBillBannerList", @"martLineBanner", @"martProduct", @"serviceAreaList", @"martServiceAreaList", @"bottomMartArea", @"homeDirectServiceArea", @"textLine", @"randomBannerArea", @"homeTalkAndStyleGroup", @"homePopularKeywordGroup", @"cornerBanner", @"simpleBestProduct"];

	if ([dataArray filteredArrayUsingPredicate:itemsPredicate].count > 0) {
		NSArray *array = [dataArray filteredArrayUsingPredicate:itemsPredicate];
		for (NSMutableDictionary * dic in array) {
			NSMutableDictionary *dicItem = [dic mutableCopy];
			
			//groupName
			if (![self.allGroupName objectForKey:dicItem[@"groupName"]]) {
				[self.allGroupName setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dicItem]] forKey:dicItem[@"groupName"]];
			}
			
			//allData
			[dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dic]] forKey:@"dataIndex"];
			[dicItem setValue:[NSString stringWithFormat:@"%@", [self.allGroupName objectForKey:dicItem[@"groupName"]]] forKey:@"groupNameIndex"];
			[self.items addObject:dicItem];
		}
	}
}

//return cellsize
- (CGSize)getSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = CGSizeMake(0, 0);
 
	if (self.items.count > 0) {
		
		NSString *cellType = self.items[indexPath.row][@"groupName"];
		
		id item = nil;
		
		if ([cellType isEqualToString:@"specialBestArea"]
			|| [cellType isEqualToString:@"specialTalkArea"]
			|| [cellType isEqualToString:@"middleServiceArea"]
			|| [cellType isEqualToString:@"bottomTalkArea"]
			|| [cellType isEqualToString:@"eventWinner"]
			|| [cellType isEqualToString:@"martServiceAreaList"]
			|| [cellType isEqualToString:@"talkBanner"]
			|| [cellType isEqualToString:@"homeDirectServiceArea"]
			|| [cellType isEqualToString:@"homeTalkAndStyleGroup"]
			|| [cellType isEqualToString:@"homePopularKeywordGroup"] ) {

			item = self.items[indexPath.row];
		}
		
		size = [CPMainTabSizeManager getSizeWithGroupName:cellType item:item];
	}
	else {
		size = CGSizeMake(kScreenBoundsWidth-20, 215);
	}
	
	return size;
}

//return allGroupName
- (NSArray *)getAllGroupName
{
	return [self.allGroupName allKeys];
}

- (void)removeAllObjects
{
	[self.items removeAllObjects];
	[self.allGroupName removeAllObjects];
	[self.noData removeAllObjects];
}

@end
