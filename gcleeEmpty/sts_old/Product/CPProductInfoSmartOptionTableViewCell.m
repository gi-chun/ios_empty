//
//  CPProductInfoSmartOptionTableViewCell.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductInfoSmartOptionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HEXColor.h"
#import "CPProductInfoSmartOptionContentView.h"

@interface CPProductInfoSmartOptionTableViewCell () <CPProductInfoSmartOptionContentViewDelegate>
{
    // list는 left만 / grid는 left, right
    CPProductInfoSmartOptionContentView *_leftView;
    CPProductInfoSmartOptionContentView *_rightView;
}

@property (nonatomic, assign) BOOL showButtonView;

- (void)initSubviews;

@end

@implementation CPProductInfoSmartOptionTableViewCell

#pragma mark - Class Methods

+ (CGFloat)contentHeight
{
    return [CPProductInfoSmartOptionContentView contentHeight];
}

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubviews];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"ebebeb"];
    }
    return self;
}

#pragma mark - Subviews

- (void)initSubviews
{
    _leftView = [[CPProductInfoSmartOptionContentView alloc] initWithFrame:CGRectZero];
    _leftView.delegate = self;
    [self.contentView addSubview:_leftView];
    
    _rightView = [[CPProductInfoSmartOptionContentView alloc] initWithFrame:CGRectZero];
    _rightView.delegate = self;
    [self.contentView addSubview:_rightView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.contentView.bounds;
    if (_productSmartOptionCellType == ProductSmartOptionCellTypeGrid)
    {
        CGFloat margin = 10.0f;
        CGFloat cellXMargin = 4.0f;
        CGRect rectSection = CGRectMake(margin,
                                        0.0f,
                                        (rectClient.size.width / 2) - margin - cellXMargin,
                                        rectClient.size.height);
        [_leftView setFrame:rectSection];
        
        rectSection.origin.x = (rectClient.size.width / 2) + cellXMargin;
        [_rightView setFrame:rectSection];
    }
    else
    {
        [_leftView setFrame:rectClient];
        [_rightView setFrame:CGRectZero];
    }
}

#pragma mark - Property

- (void)setIndex:(NSNumber *)index
{
    if (_index != index)
    {
        _index = index;
        
        _leftView.index = _index;
        _rightView.index = _index;
    }
}

- (void)setItems:(NSArray *)items
{
    if (_items != items)
    {
        _items = items;
        
        _leftView.hidden = NO;
        _rightView.hidden = YES;
        
        if (_productSmartOptionCellType == ProductSmartOptionCellTypeGrid)
        {
            _leftView.item = _items[0];
            
            if (_items.count > 1)
            {
                _rightView.hidden = NO;
                _rightView.item = _items[1];
            }
        }
        else
        {
            _leftView.item = _items[0];
        }
    }
}

#pragma mark - ProductInfoSmartOptionContentViewDelegate

- (void)productInfoSmartOptionContentViewImageDownloadedAtIndex:(NSNumber *)index withHeight:(NSNumber *)height
{
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionTableViewCellImageDownloadedAtIndex
                   : withHeight:,
                   index,
                   height);
}

- (void)productInfoSmartOptionContentView:(CPProductInfoSmartOptionContentView *)cell didClickedOptionDetailButton:(ProductSmartOptionModel *)option
{
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionTableViewCell
                   : didClickedOptionDetailButton:,
                   self,
                   option);
}

- (void)productInfoSmartOptionContentView:(CPProductInfoSmartOptionContentView *)cell didClickedOptionSelectButton:(ProductSmartOptionModel *)option
{
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionTableViewCell
                   : didClickedOptionSelectButton:,
                   self,
                   option);
}

@end