//
//  OnStickerStatusChangedDelegate.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 5. 10..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STICKER_TYPE_IMAGE      0
#define STICKER_TYPE_TEXT       1

@protocol OnStickerStatusChangedDelegate <NSObject>
@required
/**
 * @brief ￼스티커가 선택이 되었는지 확인후 반환
 * @param (BOOL)selected : 스티커 선택 유/무..
 * @author Kiwiple.
 */
- (void)onStickerSeleted:(BOOL)selected withType:(NSInteger)stickerType;

/**
 * @brief 텍스트 스티커일 때, 글자의 길이제한을 넘기면 해당 델리게이트가 호출됨.
 * @author Kiwiple.
 */
- (void)onStickerTextLengthExceed;

@end
