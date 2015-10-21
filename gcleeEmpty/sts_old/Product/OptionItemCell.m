//
//  OptionItemCell.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "OptionItemCell.h"

@implementation OptionItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countView = [[UIView alloc] initWithFrame:CGRectZero];
    self.minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.priceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    //BG
    UIImage *imgBg = [UIImage imageNamed:@"layer_optionbar_selectedbox_nor.png"];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.bgImageView.image = imgBg;
    
    //DELETE BUTTON
    UIImage *imgDeleteBtnIcon = [UIImage imageNamed:@"bt_optionbar_close.png"];
    [self.deleteButton setBackgroundImage:imgDeleteBtnIcon forState:UIControlStateNormal];
    [self.deleteButton setFrame:CGRectMake(0, 0, imgDeleteBtnIcon.size.width, imgDeleteBtnIcon.size.height)];
    [self.deleteButton setAccessibilityLabel:@"선택된 옵션 삭제" Hint:nil];
    
    //TITLE LABEL
    [self.titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setNumberOfLines:3];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    
    //COUNT VIEW
    CGFloat numberWidth = 40.f;
    UIImage* imgMinusBg = [UIImage imageNamed:@"bt_optionbar_counter_minus.png"];
    UIImage* imgNumberBg = [UIImage imageNamed:@"bt_optionbar_counterbg.png"];
    UIImage* imgPlusBg = [UIImage imageNamed:@"bt_optionbar_counter_plus.png"];
    
    imgNumberBg = [imgNumberBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    
    [self.countView setFrame:CGRectMake(0, 0, imgMinusBg.size.width+numberWidth+imgPlusBg.size.width, imgMinusBg.size.height)];
    
    [self.minusButton setBackgroundImage:imgMinusBg forState:UIControlStateNormal];
    [self.minusButton setFrame:CGRectMake(0, 0, imgMinusBg.size.width, imgMinusBg.size.height)];
    [self.minusButton setAccessibilityLabel:@"옵션 수량 감소" Hint:nil];
    
    [self.countTextField setText:@"0"];
    [self.countTextField setFont:[UIFont systemFontOfSize:15.f]];
    [self.countTextField setTextAlignment:NSTextAlignmentCenter];
    [self.countTextField setTextColor:UIColorFromRGB(0x212121)];
    [self.countTextField setBackgroundColor:[UIColor clearColor]];
    [self.countTextField setBackground:imgNumberBg];
    [self.countTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.countTextField setFrame:CGRectMake(CGRectGetMaxX(self.minusButton.frame), 0, numberWidth, imgNumberBg.size.height)];
    
    [self.plusButton setBackgroundImage:imgPlusBg forState:UIControlStateNormal];
    [self.plusButton setFrame:CGRectMake(CGRectGetMaxX(self.countTextField.frame), 0, imgPlusBg.size.width, imgPlusBg.size.height)];
    [self.plusButton setAccessibilityLabel:@"옵션 수량 증가" Hint:nil];
    
    [self.countView addSubview:self.minusButton];
    [self.countView addSubview:self.countTextField];
    [self.countView addSubview:self.plusButton];
    
    //PRICE LABEL
    [self.priceLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.priceLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.priceLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceLabel setNumberOfLines:1];
    [self.priceLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.priceWonLabel setText:@"원"];
    [self.priceWonLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.priceWonLabel setFont:[UIFont systemFontOfSize:14]];
    [self.priceWonLabel setBackgroundColor:[UIColor clearColor]];
    [self.priceWonLabel setNumberOfLines:1];
    [self.priceWonLabel setTextAlignment:NSTextAlignmentLeft];
    [self.priceWonLabel sizeToFitWithFloor];
    
    [self addSubview:self.bgImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.deleteButton];
    [self addSubview:self.countView];
    [self addSubview:self.priceLabel];
    [self addSubview:self.priceWonLabel];
}

- (void)layoutSubviews
{
    self.bgImageView.frame = CGRectMake(10, -1, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame)+1);
}

@end
