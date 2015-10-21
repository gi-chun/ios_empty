//
//  OptionItemCell.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionItemCell : UITableViewCell

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIView *countView;

@property (nonatomic, strong) UIButton *minusButton;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UITextField *countTextField;

@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *priceWonLabel;

@end
