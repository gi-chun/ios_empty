//
//  CPProductInfoSmartOptionButtonView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductSmartOptionModel.h"

@interface CPProductInfoSmartOptionButtonView : UIView

+ (CGFloat)contentHeight;

@property (nonatomic, strong) UIButton *optionDetailButton;
@property (nonatomic, strong) UIButton *optionSelectButton;
@property (nonatomic, assign) BOOL showOptionDetailButton;
@property (nonatomic, assign) ProductSmartOptionCellType productSmartOptionCellType;

@end
