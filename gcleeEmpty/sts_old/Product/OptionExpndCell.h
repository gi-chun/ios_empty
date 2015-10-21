//
//  OptionExpndCell.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, OptionItemCheckStatus)
{
    OptionItemCheckNone,
    OptionItemCheckSelected,
    OptionItemCheckDisable
};

@interface OptionExpndCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIImageView *selectedView;

@property (nonatomic, assign) NSInteger checkStatus;
@property (nonatomic, strong) NSString *priceStr;
@property (nonatomic, strong) NSString *titleStr;

@end

