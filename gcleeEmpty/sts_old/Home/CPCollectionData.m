//
//  CPCollectionData.m
//  11st
//
//  Created by hjcho86 on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCollectionData.h"

#define CELL_LINESPACING    10

@implementation CPCollectionData

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
        self.commonProduct = [NSMutableArray array];
        self.bestProductCategory = [NSMutableArray array];
        self.bannerProduct = [NSMutableArray array];
        self.lineBanner = [NSMutableArray array];
        self.shockingDealAppLink = [NSMutableArray array];
        self.ctgrHotClick = [NSMutableArray array];
        self.ctgrBest = [NSMutableArray array];
        self.ctgrDealBest = [NSMutableArray array];
        self.searchProduct = [NSMutableArray array];
        self.searchProductGrid = [NSMutableArray array];
        self.searchProductBanner = [NSMutableArray array];
        self.relatedSearchText = [NSMutableArray array];
        self.searchFilter = [NSMutableArray array];
        self.sorting = [NSMutableArray array];
        self.categoryNavi = [NSMutableArray array];
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

- (void)setAddData:(NSArray *)dataArray
{
    [self dataParser:dataArray];
}

- (void)dataParser:(NSArray *)dataArray
{
    NSPredicate *itemsPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@) || (groupName == %@)", @"commonProduct", @"bestProductCategory", @"bannerProduct", @"lineBanner", @"shockingDealAppLink", @"noData", @"ctgrHotClick", @"ctgrBest", @"ctgrDealBest", @"searchProduct", @"searchProductGrid", @"searchProductBanner", @"shockingDealProduct", @"searchCaption", @"relatedSearchText", @"recommendSearchText", @"searchFilter", @"searchTopTab", @"sorting", @"searchMore", @"modelSearchProduct", @"noSearchData", @"categoryNavi", @"searchHotProduct", @"tworldDirect"];
    
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
            
            //ctgrHotClick
            if ([dicItem[@"groupName"] isEqualToString:@"ctgrHotClick"]) {
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.ctgrHotClick count]] forKey:@"cellIndex"];
                [self.ctgrHotClick addObject:dicItem];
            }
            
            //ctgrBest
            if ([dicItem[@"groupName"] isEqualToString:@"ctgrBest"]) {
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.ctgrBest count]] forKey:@"cellIndex"];
                [self.ctgrBest addObject:dicItem];
            }
            
            //ctgrDealBest
            if ([dicItem[@"groupName"] isEqualToString:@"ctgrDealBest"]) {
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.ctgrDealBest count]] forKey:@"cellIndex"];
                [self.ctgrDealBest addObject:dicItem];
            }
            
            //searchProduct
            if ([dicItem[@"groupName"] isEqualToString:@"searchProduct"]) {
                [dicItem setValue:@"N" forKey:@"isExpanded"];
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.searchProduct count]] forKey:@"cellIndex"];
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dic]] forKey:@"dataIndex"];
                [self.searchProduct addObject:dicItem];
            }
            
            //searchProductGrid
            if ([dicItem[@"groupName"] isEqualToString:@"searchProductGrid"]) {
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.searchProductGrid count]] forKey:@"cellIndex"];
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dic]] forKey:@"dataIndex"];
                [self.searchProductGrid addObject:dicItem];
            }
            
            //searchProductBanner
            if ([dicItem[@"groupName"] isEqualToString:@"searchProductBanner"]) {
                [dicItem setValue:@"N" forKey:@"isExpanded"];
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.searchProductBanner count]] forKey:@"cellIndex"];
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dic]] forKey:@"dataIndex"];
                [self.searchProductBanner addObject:dicItem];
            }
            
            //relatedSearchText
            if ([dicItem[@"groupName"] isEqualToString:@"relatedSearchText"]) {
                [dicItem setValue:@"N" forKey:@"isExpanded"];
                [self.relatedSearchText addObject:dicItem];
            }
            
            //searchFilter
            if ([dicItem[@"groupName"] isEqualToString:@"searchFilter"]) {
                [dicItem setValue:@"N" forKey:@"selected"];
                [self.searchFilter addObject:dicItem];
            }
            
            //sorting
            if ([dicItem[@"groupName"] isEqualToString:@"sorting"]) {
                [dicItem setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[array indexOfObject:dic]] forKey:@"dataIndex"];
                [self.sorting addObject:dicItem];
            }
            
            //categoryNavi
            if ([dicItem[@"groupName"] isEqualToString:@"categoryNavi"]) {
                [self.categoryNavi addObject:dicItem];
            }
        }
    }
}

//return cellsize
- (CGSize)getSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(0, 0);
 
    if (self.items.count > 0) {
        NSString *cellType = self.items[indexPath.row][@"groupName"];
        
        //검색결과가 없을 경우
        if ([cellType isEqualToString:@"noData"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 215);
            return size;
        }
        
        if ([cellType isEqualToString:@"commonProduct"]) {
            size = CGSizeMake([Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth]+75+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"bestProductCategory"]) {
            size = CGSizeMake([Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth]+75+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"lineBanner"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 60+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"bannerProduct"]) {
            NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+9)*2 : kScreenBoundsWidth - 20;
            NSInteger productHeight = productWidth/1.78+121;
            
            size = CGSizeMake(productWidth, productHeight+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"shockingDealAppLink"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 34+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"ctgrHotClick"]) {
            NSArray *itemArray = self.ctgrHotClick[0][@"items"];
            NSInteger itemCount = itemArray.count;
            
            if (itemCount < 3) {
                return size;
            }
            size = CGSizeMake(kScreenBoundsWidth-20, (itemCount > 3 ? 350+[Modules getCategoryItemHeight]*2 : 198+[Modules getCategoryItemHeight])+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"ctgrBest"]) {
            NSArray *itemArray = self.ctgrBest[0][@"items"];
            NSInteger itemCount = itemArray.count;
            if (itemCount < 3) {
                return size;
            }
            
            size = CGSizeMake(kScreenBoundsWidth-20, 198+[Modules getCategoryItemHeight]+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"ctgrDealBest"]) {
            NSArray *itemArray = self.ctgrDealBest[0][@"items"];
            NSInteger itemCount = itemArray.count;
            if (itemCount < 3) {
                return size;
            }
            if (itemCount < 3) {
                return size;
            }
            
            size = CGSizeMake(kScreenBoundsWidth-20, 198+[Modules getCategoryItemHeight]+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"searchProduct"]) {
            NSDictionary *searchProductDic = self.items[indexPath.row];
            size = CGSizeMake(kScreenBoundsWidth-20, ([[searchProductDic objectForKey:@"isExpanded"] isEqualToString:@"Y"] ? 174 : 140)+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"searchProductGrid"]) {
            CGFloat height = [Modules getBestLayoutItemWidth]*1.85+CELL_LINESPACING;
            if (IS_IPAD) {
                height = [Modules getBestLayoutItemWidth]*1.70+CELL_LINESPACING;
            }
            else if (IS_IPHONE_6) {
                height = [Modules getBestLayoutItemWidth]*1.70+CELL_LINESPACING;
            }
            else if (IS_IPHONE_6PLUS) {
                height = [Modules getBestLayoutItemWidth]*1.65+CELL_LINESPACING;
            }
            
            size = CGSizeMake([Modules getBestLayoutItemWidth], height);
        }
        else if ([cellType isEqualToString:@"searchProductBanner"]) {
            NSDictionary *searchProductBannerDic = self.items[indexPath.row];
            NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+8)*2 : kScreenBoundsWidth - 20;
            NSInteger productHeight = [[searchProductBannerDic objectForKey:@"isExpanded"] isEqualToString:@"Y"] ? 450 : 416;
            if (IS_IPAD) {
                productHeight = 485;
            }
            else if (IS_IPHONE_6) {
                productHeight = [[searchProductBannerDic objectForKey:@"isExpanded"] isEqualToString:@"Y"] ? 504 : 470;
            }
            else if (IS_IPHONE_6PLUS) {
                productHeight = [[searchProductBannerDic objectForKey:@"isExpanded"] isEqualToString:@"Y"] ? 544 : 510;
            }
            
            size = CGSizeMake(productWidth, productHeight+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"shockingDealProduct"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 165+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"searchCaption"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 29);
        }
        else if ([cellType isEqualToString:@"relatedSearchText"]) {
            NSDictionary *relatedSearchTextDic = self.relatedSearchText[0];
            NSArray *relatedSearchTextItems = self.relatedSearchText[0][@"items"];
            NSInteger itemCount = ceilf([[NSNumber numberWithUnsignedInteger:relatedSearchTextItems.count] floatValue] / 2);
            size = CGSizeMake(kScreenBoundsWidth-20, [[relatedSearchTextDic objectForKey:@"isExpanded"] isEqualToString:@"Y"] ? itemCount*36 : 36);
        }
        else if ([cellType isEqualToString:@"recommendSearchText"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 36);
        }
        else if ([cellType isEqualToString:@"searchFilter"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 39);
        }
        else if ([cellType isEqualToString:@"searchTopTab"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 41);
        }
        else if ([cellType isEqualToString:@"sorting"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 45+CELL_LINESPACING/2);
        }
        else if ([cellType isEqualToString:@"searchMore"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 45+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"modelSearchProduct"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 140+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"noSearchData"]) {
            NSDictionary *noSearchDataDic = self.items[indexPath.row];
            size = CGSizeMake(kScreenBoundsWidth-20, ([noSearchDataDic objectForKey:@"recommendKeyword"] ? 295 : 235)+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"categoryNavi"]) {
            NSArray *categoryNaviItems = self.items[indexPath.row][@"items"];
            
            CGFloat arrowWidth = 26;
            CGFloat cellWidtgh = kScreenBoundsWidth-20;
            CGFloat tempSize = 0;
            NSInteger headerLineCount = 1;
            
            for (NSDictionary *dic in categoryNaviItems) {
                CGSize labelSize = [[dic objectForKey:@"dispCtgrNm"] sizeWithFont:[UIFont systemFontOfSize:14]];
                tempSize += labelSize.width;
                
                if (tempSize >= cellWidtgh) {
                    tempSize = 0;
                    headerLineCount++;
                    tempSize += labelSize.width;
                }
                
                //arrow
                tempSize += arrowWidth;
                
                if (tempSize >= cellWidtgh) {
                    tempSize = 0;
                    headerLineCount++;
                    tempSize += arrowWidth;
                }
            }
            
            size = CGSizeMake(kScreenBoundsWidth-20, 30+(headerLineCount-1)*31);
        }
        else if ([cellType isEqualToString:@"searchHotProduct"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, (kScreenBoundsWidth-20)/1.621+(kScreenBoundsWidth-20)/15+CELL_LINESPACING);
        }
        else if ([cellType isEqualToString:@"tworldDirect"]) {
            size = CGSizeMake(kScreenBoundsWidth-20, 34+140+CELL_LINESPACING/2);
        }
    }
    else {
        size = CGSizeMake(kScreenBoundsWidth-20, 215+CELL_LINESPACING);
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
    [self.commonProduct removeAllObjects];
    [self.bestProductCategory removeAllObjects];
    [self.bannerProduct removeAllObjects];
    [self.lineBanner removeAllObjects];
    [self.shockingDealAppLink removeAllObjects];
    [self.ctgrHotClick removeAllObjects];
    [self.ctgrBest removeAllObjects];
    [self.ctgrDealBest removeAllObjects];
    [self.searchProduct removeAllObjects];
    [self.searchProductGrid removeAllObjects];
    [self.searchProductBanner removeAllObjects];
    [self.relatedSearchText removeAllObjects];
    [self.sorting removeAllObjects];
    [self.categoryNavi removeAllObjects];
    [self.noData removeAllObjects];
}

@end