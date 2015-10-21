//
//  OnFrameStatusChangedDelegate.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 4. 24..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OnFrameStatusChangedDelegate <NSObject>
@required
/**
 * @brief ￼프레임이 선택이 되었는지 확인후 반환
 * @param (BOOL)selected : 프레임 선택 유/무..
 * @author Kiwiple.
 */
- (void)onFrameSelected:(BOOL)selected;

/**
 * @brief 드래그된 사진 위치 반환
 * @param (NSInteger)from : 현재 위치한 프레임 인덱스, (NSInteger)to : 옮기는 위치의 프레임 인덱스
 * @returns ￼returns CollageView instance valuable
 * @author Kiwiple.
 */
- (void)onFrameDragAndDrop:(NSInteger)from To:(NSInteger)to;

@end
