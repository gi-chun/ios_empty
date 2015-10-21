//
//  DesignTemplateManager.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 4. 22..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TemplateInfo;

@interface DesignTemplateManager : NSObject {
}

/**
 * @brief ￼Make Manager (Singleton)
 * @returns ￼returns static KWPImageFilterManager￼
 * @author Kiwiple.
 */
+ (DesignTemplateManager *)getInstance;

/**
 * @brief Set Template info
 * @param (NSString *)filePath : Template JSON file path
 * @returns 템플릿 경로가 정확한 것인지 확인
 * @author Kiwiple.
 */
- (BOOL)setTemplateFile:(NSString *)filePath;

/**
 * @brief Get All Template Array
 * @returns All Template Array
 * @author Kiwiple.
 */
- (NSArray *)getTemplateArray;

/**
 * @brief 프레임 수에 따라서 템플릿 배열을 얻어옴
 * @param (NSInteger)numOfFrame : 프레임의 수
 * @returns 템플릿 배열 리턴
 * @author Kiwiple.
 */
- (NSArray *)getTemplateArray:(NSInteger)numOfFrame;

/**
 * @brief Get Template info
 * @param (NSInteger)infoId : info id
 * @returns returns TemplateInfo
 * @author Kiwiple.
 */
- (TemplateInfo *)getTemplateInfo:(NSInteger)infoId;

/**
 * @brief Set SVG File Base Path
 * @param (NSString *)path : 파일 이름 전까지의 path
 * @author Kiwiple.
 */
- (void)setBasePath:(NSString *)path;

/**
 * @brief Get SVG File Base Path
 * @returns returns SVG File Base Path
 * @author Kiwiple.
 */
- (NSString *)getBasePath;

@end
