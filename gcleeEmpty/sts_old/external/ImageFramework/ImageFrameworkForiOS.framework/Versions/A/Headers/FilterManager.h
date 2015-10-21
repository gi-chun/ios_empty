//
//  FilterManager.h
//  ImageFrameworkForiOS
//
//  Created by Kiwiple
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilterInfo.h"
#import "FilterProcessDelegate.h"

@interface FilterManager : NSObject

/**
 * @brief ￼Make Manager (Singleton)
 * @returns ￼returns static KWPImageFilterManager￼
 * @author Kiwiple.
 */
+ (FilterManager *)getInstance;

/**
 * @brief Set filter info
 * @param (NSString *)filePath : filter JSON file path
 * @returns 필터 경로가 정확한 것인지 확인
 * @author Kiwiple.
 */
- (BOOL)setFilter:(NSString *)filePath;

/**
 * @brief Set filter info
 * @param (NSString *)filterJsonString : filter JSON string
 * @returns 필터 JsonString이 정확한 것인지 확인
 * @author Kiwiple.
 */
- (BOOL)setFilterJsonString:(NSString *)filterJsonString;

/**
 * @brief filterid를 넣으면 filterinfo반환
 * @param (NSInteger)filterId : filter id
 * @returns returns filterinfo
 */
- (FilterInfo *)getFilterInfoWithFilterId:(NSInteger)filterId;

/**
 * @brief 필터 array 반환
 * @returns returns filter info array
 * @author Kiwiple.
 */
- (NSArray *)getFilterArray;

/**
 * @brief 필터를 사용할수 있는지 아닌지 판별하는 메서드. 사용가능하면 델리게이트 메서드 호출
 * @param ￼(UIImage *)image : original image
 *		  (NSInteger)filterId : 사용할 필터 id
 *        (id)userInfo : 델리게이트 메서드에서 사용할 객체
 *        (id<KWPImageFilterManagerProtocol>)delegate : KWPImageFilterManagerProtocol이 적용되어 있는 클래스
 * @returns 필터 이미지로 변환이 가능한지(YES or NO)
 * @author Kiwiple.
 */
- (BOOL)applyFilterImage:(UIImage *)image filterId:(NSInteger)filterId userInfo:(id)userInfo delegate:(id<FilterProcessDelegate>)delegate;
- (BOOL)applyFilterImage:(UIImage *)image filterInfo:(FilterInfo *)filterInfo userInfo:(id)userInfo delegate:(id<FilterProcessDelegate>)delegate;
- (BOOL)applyFilterImage:(UIImage *)image filterId:(NSInteger)filterId userInfo:(id)userInfo success:(void (^)(UIImage *image, NSInteger filterId, id userInfo))success failure:(void (^)(NSString *errorCode, NSInteger filterId, id userInfo))failure;


/**
 * @brief ￼프로세싱되고있는 필터 적용 취소
 * @author Kiwiple.
 */
- (void)cancelAllApplyFilter;
- (void)cancelApplyFilter:(id)identifier;
@end