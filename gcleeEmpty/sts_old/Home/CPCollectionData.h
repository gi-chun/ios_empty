//
//  CPCollectionData.h
//  11st
//
//  Created by hjcho86 on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPCollectionData : NSObject

@property (nonatomic, strong) NSMutableArray *items;                //셀 데이터
@property (nonatomic, strong) NSMutableDictionary *allGroupName;    //포함되어있는 GroupName
@property (nonatomic, strong) NSMutableArray *commonProduct;
@property (nonatomic, strong) NSMutableArray *bestProductCategory;
@property (nonatomic, strong) NSMutableArray *bannerProduct;
@property (nonatomic, strong) NSMutableArray *lineBanner;
@property (nonatomic, strong) NSMutableArray *shockingDealAppLink;
@property (nonatomic, strong) NSMutableArray *ctgrHotClick;
@property (nonatomic, strong) NSMutableArray *ctgrBest;
@property (nonatomic, strong) NSMutableArray *ctgrDealBest;
@property (nonatomic, strong) NSMutableArray *searchProduct;
@property (nonatomic, strong) NSMutableArray *searchProductGrid;
@property (nonatomic, strong) NSMutableArray *searchProductBanner;
@property (nonatomic, strong) NSMutableArray *relatedSearchText;
@property (nonatomic, strong) NSMutableArray *searchFilter;
@property (nonatomic, strong) NSMutableArray *sorting;
@property (nonatomic, strong) NSMutableArray *categoryNavi;
@property (nonatomic, strong) NSMutableArray *noData;

- (id)init;
- (id)initWithData:(NSArray *)dataArray;
- (void)setData:(NSArray *)dataArray;
- (void)setAddData:(NSArray *)dataArray;
- (CGSize)getSizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)getAllGroupName;
- (void)removeAllObjects;

@end
