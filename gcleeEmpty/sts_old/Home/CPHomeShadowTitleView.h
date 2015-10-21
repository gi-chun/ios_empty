//
//  CPHomeShadowTitleView.h
//  11st
//
//  Created by saintsd on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPHomeShadowTitleView : UIView

+ (CGSize)viewSizeWithData:(CGFloat)width;
- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item font:(UIFont *)font textColor:(UIColor *)tColor shadowColor:(UIColor *)sColor;

@end
