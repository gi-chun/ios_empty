//
//  OptionExpndCell.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "OptionExpndCell.h"

@implementation OptionExpndCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    self.backgroundColor = [UIColor clearColor];
    self.checkStatus = OptionItemCheckNone;
    
    self.selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 18, 18)];
    self.selectedView.backgroundColor = [UIColor clearColor];
    
    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.priceLabel.font = [UIFont systemFontOfSize:15.f];
    self.priceLabel.textColor = UIColorFromRGB(0x222222);
    self.priceLabel.backgroundColor = [UIColor clearColor];
    self.priceLabel.textAlignment = NSTextAlignmentRight;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.titleLabel.textColor = UIColorFromRGB(0x222222);
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomLineView.backgroundColor = UIColorFromRGB(0xe9e9e9);
    
    
    [self addSubview:self.selectedView];
    [self addSubview:self.priceLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bottomLineView];
}

- (void)layoutSubviews
{
    self.selectedView.frame = CGRectMake(9,
                                         (self.frame.size.height/2)-(self.selectedView.frame.size.height/2),
                                         self.selectedView.frame.size.width,
                                         self.selectedView.frame.size.height);
    
    self.priceLabel.text = self.priceStr;
    self.priceLabel.frame = CGRectMake(self.frame.size.width-82.f-9.f, 0, 82.f, 0.f);
    [self.priceLabel sizeToFitWithVersionHoldWidth];
    self.priceLabel.frame = CGRectMake(self.priceLabel.frame.origin.x,
                                       (self.frame.size.height/2)-(self.priceLabel.frame.size.height/2),
                                       self.priceLabel.frame.size.width,
                                       self.priceLabel.frame.size.height);
    
    CGFloat titleWidth = self.frame.size.width - (self.priceLabel.frame.size.width+CGRectGetMaxX(self.selectedView.frame)+18.f);
    
    self.titleLabel.text = self.titleStr;
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.selectedView.frame)+9.f, 0,
                                       titleWidth, 0);
    [self.titleLabel sizeToFitWithVersionHoldWidth];
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.selectedView.frame)+9.f,
                                       (self.frame.size.height/2)-(self.titleLabel.frame.size.height/2),
                                       self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    
    self.bottomLineView.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    if (self.checkStatus == OptionItemCheckNone)
    {
        UIImage *icon = [UIImage imageNamed:@"optionbar_selectbox_radio_bg.png"];
        self.selectedView.image = icon;
        
        self.titleLabel.textColor = UIColorFromRGB(0x222222);
        self.priceLabel.textColor = UIColorFromRGB(0x222222);
    }
    else if (self.checkStatus == OptionItemCheckSelected)
    {
        UIImage *icon = [UIImage imageNamed:@"optionbar_selectbox_radio_on.png"];
        self.selectedView.image = icon;
        
        self.titleLabel.textColor = UIColorFromRGB(0xff1b23);
        self.priceLabel.textColor = UIColorFromRGB(0xff1b23);
    }
    else
    {
        UIImage *icon = [UIImage imageNamed:@"optionbar_selectbox_radio_bg.png"];
        self.selectedView.image = icon;
        
        self.titleLabel.textColor = UIColorFromRGB(0xbbbbbb);
        self.priceLabel.textColor = UIColorFromRGB(0xbbbbbb);
    }
}

@end