//
//  CPCurationItemView.h
//  11st
//
//  Created by saintsd on 2015. 6. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPCurationItemView : UIView

+ (CGFloat)viewHeight:(CGFloat)screenWidth;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items isLeft:(BOOL)isLeft isMale:(BOOL)isMale;

@end
