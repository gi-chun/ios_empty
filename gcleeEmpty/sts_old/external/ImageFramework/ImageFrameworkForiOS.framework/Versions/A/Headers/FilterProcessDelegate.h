//
//  FilterManagerProtocol.h
//  ImageFrameworkForiOS
//
//  Created by 윤석 진 on 13. 4. 10..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FilterProcessDelegate <NSObject>
@required
/**
 * @brief ￼Complete filtered image
 * @param ￼(UIImage *)image : filtered Image
 *		  (NSInteger)filterId : use Filter Id
 *        (id)userInfo : FilterManager의 applyFilterImage 메서드에서 입력한 userInfo
 * @author Kiwiple.
 */

- (void)completeFilterProcess:(UIImage *)image filterId:(NSInteger)filterId userInfo:(id)userInfo;
/**
 * @brief Fail filtered image
 * @param (NSString *)errorCode : error code
 *        (NSInteger)filterId : filter id
 *        (id)userInfo : FilterManager의 applyFilterImage 메서드에서 입력한 userInfo
 * @author Kiwiple.
 *
 */
- (void)failureFilterProcess:(NSString *)errorCode filterId:(NSInteger)filterId userInfo:(id)userInfo;
@end
