//
//  CPMainTabCollectionData.h
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMainTabCollectionData : NSObject

@property (nonatomic, strong) NSMutableArray *items;                //셀 데이터
@property (nonatomic, strong) NSMutableDictionary *allGroupName;    //포함되어있는 GroupName
@property (nonatomic, strong) NSMutableArray *noData;

- (id)init;
- (id)initWithData:(NSArray *)dataArray;
- (void)setData:(NSArray *)dataArray;
- (CGSize)getSizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)getAllGroupName;
- (void)removeAllObjects;

@end
