//
//  ZoomAndCropImageView.h
//  ImageFrameworkForiOS
//
//  Created by kiwiple on 13. 4. 4..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomAndCropImageView : UIView


/**
 * @brief ￼Make Crop Image
 * @param ￼(CGRect)frame : Screen Frame
 *		  (UIImage *)image : original Image
 * @returns ￼ZoomAndCropImageView instance valueable
 * @author Kiwiple.
 */
- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

/**
 * @brief set crop ratio
 * @param ￼(NSInteger)aspectRatio : Crop Type (ref GlobalHeader)
 * @author Kiwiple.
 */
- (void)setImageRatio:(NSInteger)aspectRatio;

/**
 * @brief 크롭된 이미지 반환
 * @returns ￼returns croped Image
 * @author Kiwiple.
 */
- (UIImage *)cropBitmap;

/**
 * @brief 이미지 반전
 * @author Kiwiple.
 */
- (void)flipImage;

/**
 * @brief 이미지 회전(90도)
 * @author Kiwiple.
 */
- (void)rotateImage;

@end
