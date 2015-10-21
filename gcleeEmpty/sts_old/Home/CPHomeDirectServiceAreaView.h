//
//  CPHomeDirectServiceAreaView.h
//  11st
//
//  Created by saintsd on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPHomeDirectServiceAreaView : UIView

+ (CGSize)viewSizeWithData:(NSArray *)items width:(CGFloat)width columnCount:(NSInteger)columnCount;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount font:(UIFont *)font textColor:(UIColor *)tColor;

@end
