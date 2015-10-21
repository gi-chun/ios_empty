//
//  StickerView.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 5. 7..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnStickerStatusChangedDelegate.h"
#import "StickerHeader.h"

@interface StickerView : UIView <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, assign) id <OnStickerStatusChangedDelegate> delegate;

/**
 * @brief ￼Add Sticker
 * @param (UIImage *)sticker : 스티커 이미지
 * @returns ￼returns Sticker index
 * @author Kiwiple.
 */
- (NSInteger)addSticker:(UIImage *)sticker;

/**
 * @brief ￼Remove Sticker
 * @param (NSInteger)index : 스티커 인덱스
 * @author Kiwiple.
 */
- (void)removeSticker:(NSInteger)index;

/**
 * @brief ￼스티커 수 반환
 * @returns ￼returns Sticker Count
 * @author Kiwiple.
 */
- (NSInteger)getStickerCount;

/**
 * @brief ￼선택된 스티커 인덱스 반환
 * @returns ￼returns Selected Sticker Count
 * @author Kiwiple.
 */
- (NSInteger)getSelectedStickerIndex;

/**
 * @brief ￼선택된 스티커 제거
 * @author Kiwiple.
 */
- (void)removeSelectedSticker;

/**
 * @brief ￼선택된 스티커 해제
 * @author Kiwiple.
 */
- (void)deselectSticker;

/**
 * @brief 스티커 스케일 설정
 * @param (CGFloat)minScale : 최저 비율, (CGFloat)maxScale : 최고 비율
 * @author Kiwiple.
 */
- (void)setStickerScale:(CGFloat)minScale withMaxScale:(CGFloat)maxScale;

/**
 * @brief 스티커 선택 색상 설정
 * @param (UIColor *)color : 선택 색상
 * @author Kiwiple.
 */
- (void)setStickerSelectionColor:(UIColor *)color;

/**
 * @brief 스티커 선택 색상 및 width설정
 * @param (UIColor *)color : 선택 색상, (CGFloat)width : 선택 width
 * @author Kiwiple.
 */
- (void)setStickerSelectionColor:(UIColor *)color WithSelectionWidth:(CGFloat)width;

/**
 * @brief 스티커 삭제 버튼 이미지 설정
 * @param (UIImage *)normalImage : 일반이미지, (UIImage *)pressedImage : 선택 중 이미지
 * @author Kiwiple.
 */
- (void)setCloseImage:(UIImage *)normalImage withPressedImage:(UIImage *)pressedImage;

/**
 * @brief 스티커 스케일 조정 버튼 이미지 설정
 * @param (UIImage *)normalImage : 일반이미지, (UIImage *)pressedImage : 선택 중 이미지
 * @author Kiwiple.
 */
- (void)setScaleImage:(UIImage *)normalImage withPressedImage:(UIImage *)pressedImage;

/**
 * @brief 텍스트 편집 버튼 이미지 설정
 * @param (UIImage *)normalImage : 일반이미지, (UIImage *)pressedImage : 선택 중 이미지
 * @author Kiwiple.
 */
- (void)setEditImage:(UIImage *)normalImage withPressedImage:(UIImage *)pressedImage;

/**
 * @brief 스티커 삭제 버튼 위치 조절
 * @param (STIKER_ITEM_LOCATION)location : 위치 정보
 * @author Kiwiple.
 */
- (void)setCloseButtonLocation:(STICKER_BUTTON_LOCATION)location;

/**
 * @brief 스티커 스케일 조정 버튼 위치 조절
 * @param (STIKER_ITEM_LOCATION)location : 위치 정보
 * @author Kiwiple.
 */
- (void)setScaleButtonLocation:(STICKER_BUTTON_LOCATION)location;

/**
 * @brief 스티커 편집 버튼 위치 조절
 * @param (STIKER_ITEM_LOCATION)location : 위치 정보
 * @author Kiwiple.
 */
- (void)setEditButtonLocation:(STICKER_BUTTON_LOCATION)location;

/**
 * @brief 스티커 이동 영역 제한
 * @param (CGPoint)paddingPoint : 스티커 이동 영역 제한 x,y 값 (없을 시 디폴트 20,20)
 * @author Kiwiple.
 */
- (void)setTranslationPadding:(CGPoint)padding;


/**
 * @brief 스티커 이미지 반환
 * @param (NSInteger)size : 이미지 사이즈
 * @returns 조합된 스티커 이미지 반환
 * @author Kiwiple.
 */
- (UIImage *)getStickerImage:(NSInteger)size;

#pragma mark - 텍스트 스티커 전용
/**
 * @brief 텍스트 입력 인터페이스 생성 (버튼이 디폴트값으로 설정된다.)
 * @author Kiwiple.
 */
- (void)addTextSticker;

/**
 * @brief 텍스트 입력 인터페이스 설정
 *  주의 : addTarget:action:forControlEvents: 메소드 사용시 에러의 원인이 될 수 있음
 (가급적 사용하지 않기를 권함)
 * @param (UIButton *)confirmButton : 완료 버튼, (UIButton *)cancelButton : 취소 버튼
 * @author Kiwiple.
 */
- (void)setTextStickerWithConfirmButton:(UIButton *)confirmButton WithCancelButton:(UIButton *)cancelButton;

/**
 * @brief 텍스트 폰트 설정
 * @param (NSString *)fontName : 폰트 이름
 * @author Kiwiple.
 */
- (void)setTextStickerFont:(NSString *)fontName;

/**
 * @brief 텍스트 색상 설정
 * @param (UIColor *)color : 색
 * @author Kiwiple.
 */
- (void)setTextStickerTextColor:(UIColor *)color;

/**
 * @brief 텍스트 기본 색상 설정
 * @param (UIColor *)color : 색
 * @author Kiwiple.
 */
- (void)setTextStickerDefaultTextColor:(UIColor *)color;

/**
 * @brief 텍스트 배경화면 설정
 * @param (UIImage *)background : 배경 이미지
 * @author Kiwiple.
 */
- (void)setTextStickerBackground:(UIImage *)background;

/**
 * @brief 텍스트 전체 제한길이 설정 (설정 없을 시 50자 제한)
 * @param (NSInteger)limitLength : 제한할 길이
 * @author Kiwiple.
 */
- (void)setTextStickerLimitLength:(NSInteger)limitLength;

/**
 * @brief 텍스트 입력창 테두리 색상 설정
 * @param (UIColor *)color : 입력창 테두리 색상, (CGFloat)width : 입력창 테두리 width
 * @author Kiwiple.
 */
- (void)setTextInputBorderColor:(UIColor *)color WithInputBorderWidth:(CGFloat)width;

@end
