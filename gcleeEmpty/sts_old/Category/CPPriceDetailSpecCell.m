//
//  CPPriceDetailSpecCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 7..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailSpecCell.h"

@interface CPPriceDetailSpecCell ()
{
    UIView *_contentView;
    UIView *_lineView;
}

@end

@implementation CPPriceDetailSpecCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSString *text = _item[@"content"];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 10, _contentView.frame.size.width-22, 0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = UIColorFromRGB(0x333333);
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.numberOfLines = 99;
    textLabel.text = text;
    [textLabel sizeToFitWithVersionHoldWidth];
    [_contentView addSubview:textLabel];
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}


@end
