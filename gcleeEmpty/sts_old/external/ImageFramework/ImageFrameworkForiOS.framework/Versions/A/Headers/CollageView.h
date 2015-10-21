//
//  CollageView.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 4. 23..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnFrameStatusChangedDelegate.h"

#define MaskViewTag -2000

@class TemplateInfo;

@interface CollageView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <OnFrameStatusChangedDelegate> delegate;

/**
 * @brief ￼Make CollageView
 * @param (CGRect)frame : collageView frame(프레임의 가로길이 기준으로 설정됩니다.), (id <OnFrameStatusChangedDelegate>)delegates : delegate
 * @returns ￼returns CollageView instance valuable
 * @author Kiwiple.
 */
- (id)initWithFrame:(CGRect)frame withDelegate:(id <OnFrameStatusChangedDelegate>)delegates;

/**
 * @brief ￼Set Template Info
 * @param (TemplateInfo *)templateInfo : DesignTemplateManager에서 받아온 TemplateInfo Set
 * @author Kiwiple.
 */
- (void)setTemplateInfo:(TemplateInfo *)templateInfo;

/**
 * @brief ￼Set Frame Image Array
 * @param (NSArray *)images : Image Array
 * @author Kiwiple.
 */
- (BOOL)setFrameImages:(NSArray *)images;

/**
 * @brief ￼Set a Frame Image
 * @param (UIImage *)image : Image
 * @author Kiwiple.
 */
- (BOOL)setFrameImage:(UIImage *)image;

/**
 * @brief ￼Set a Frame Image Without Initialize
 * @param (UIImage *)image : Image
 * @author Kiwiple.
 */
- (BOOL)changeFrameImage:(UIImage *)image;

/**
 * @brief ￼Set a Frame Image Without Initialize
 * @param (UIImage *)image : Image , (NSInteger)index : Index
 * @author Kiwiple.
 */
- (BOOL)changeFrameImage:(UIImage *)image WithIndex:(NSInteger)index;

/**
 * @brief ￼Set a Frame Image Without Initialize
 * @param (NSArray *)images : Images (UIImage's Array)
 * @author Kiwiple.
 */
- (BOOL)changeFrameImages:(NSArray *)images;

/**
 * @brief Get Frame Image Array
 * @returns ￼returns Frame Image Array
 * @author Kiwiple.
 */
- (NSArray *)getFrameImages;

/**
 * @brief Get Selected Frame Index
 * @returns ￼returns Frame Index
 * @author Kiwiple.
 */
- (NSInteger)getSelectedFrameIndex;

/**
 * @brief Deselect Frame
 * @author Kiwiple.
 */
- (void)deselectFrame;

/**
 * @brief Selected Frame Image Rotate
 * @author Kiwiple.
 */
- (void)rotateImage;

/**
 * @brief Selected Frame Image Flip
 * @author Kiwiple.
 */
- (void)flipImage;

/**
 * @brief Request Transparent Frame
 * @param (NSInteger)index : Selected Frame Index
 * @author Kiwiple.
 */
- (void)requestTransparentFrame:(NSInteger)index withEnabled:(BOOL)enable;

/**
 * @brief ￼Get Collage Image
 * @param (NSInteger)size : Image Size
 * @returns ￼returns CollageView Captured Image
 * @author Kiwiple.
 */
- (UIImage *)getCollageImage:(NSInteger)size;

/**
 * @brief ￼Set Frame Image Scale
 * @param (CGFloat)minScale : 최소 줌 scale, (CGFloat)maxScale : 최대 줌 scale
 * @author Kiwiple.
 */
- (void)setFrameImageScale:(CGFloat)minScale withMaxScale:(CGFloat)maxScale;

/**
 * @brief ￼Set Template Background Color
 * @param (UIColor *)color : 백그라운드에 설정할 색
 * @author Kiwiple.
 */
- (void)setTemplateBackgroundColor:(UIColor *)color;

/**
 * @brief ￼Set Template Background Pattern Image
 * @param (UIImage *)image : 백그라운드에 패턴 설정할 이미지
 * @author Kiwiple.
 */
- (void)setTemplateBackgroundPattern:(UIImage *)image;

/**
 * @brief ￼Set Selection Frame Color
 * @param (UIColor *)color : 선택한 프레임 주변부 색
 * @author Kiwiple.
 */
- (void)setFrameSelectionColor:(UIColor *)color;

/**
 * @brief ￼Set Drag And Drop Frame Color
 * @param (UIColor *)color : 드래그앤드롭할때 생기는 프레임의 색
 * @author Kiwiple.
 */
- (void)setFrameDragNDropColor:(UIColor *)color;

/**
 * @brief ￼Set Frame Background Color
 * @param (UIColor *)color : 프레임 내부의 색 설정
 * @author Kiwiple.
 */
- (void)setFrameBackgroundColor:(UIColor *)color;

/**
 * @brief Get Selected Frame Rect
 * @author Kiwiple.
 */
- (CGRect)getSelectedFrameRect;

/**
 * @brief Get Selected Frame Rect
 * @param (NSInteger)index : 프레임의 고유번호
 * @author Kiwiple.
 */
- (CGRect)getFrameRect:(NSInteger)index;


/**
 * @brief Get All Frame Rect. 각 요소는 NSValue이며, 값을 이용하기 위하여 NSValue를 CGRect로 변환해야함. (프레임이 없을 경우 nil)
 * @author Kiwiple.
 */
- (NSArray *)getFrameRects;

/**
 * @brief set Frame Drag & Drop Enable Flag
 * @param (BOOL)enabled : 드래그앤 드랍이 가능하게 할것인가 아닌가
 * @author Kiwiple.
 */
- (void)setFrameDragNDropEnabled:(BOOL)enabled;

@end
