//
//  FilterInfo.h
//  ImageFrameworkForiOS
//
//  Created by 윤석 진 on 13. 4. 10..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KWPNonFilterId	-1

@interface FilterInfo : NSObject

@property (assign, nonatomic) NSInteger filterId;
@property (retain, nonatomic) NSString *filterTitle;
@property (retain, nonatomic) NSString *filterDesc;
@property (retain, nonatomic) NSDictionary *filterInfo;


/**
 * @brief Set filter info
 * @param (NSString *)filePath : filter JSON file path
 * @returns 필터 경로가 정확한 것인지 확인
 * @author Kiwiple.
 */
- (void)setFilter:(NSDictionary *)info;

/**
 * @brief old filterinfo change new filterinfo
 * @param (KWPImageFilterInfo *)info : filter info
 * @returns returns new filterinfo
 * @author Kiwiple.
 */
+ (FilterInfo *)imageFilterInfo:(FilterInfo *)info;
@end
