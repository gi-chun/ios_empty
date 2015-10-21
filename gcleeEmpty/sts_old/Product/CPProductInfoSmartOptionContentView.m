//
//  CPProductInfoSmartOptionContentView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductInfoSmartOptionContentView.h"
#import "UIImageView+WebCache.h"
#import "HEXColor.h"
#import "CPProductInfoSmartOptionButtonView.h"

#import "ProductSmartOptionModel.h"

@interface CPProductInfoSmartOptionContentView ()
{
    UIImageView *_imageView;
    CPProductInfoSmartOptionButtonView *_buttonView;
    UIView *_headerDisplayLabelView; // header image 하단에 옵션 시작 텍스트
    UILabel *_headerDisplayLabel;
    
    UIView *_soldOutBackgroundView;
    UIImageView *_soldOutImageView;
    
    UIView *_backgroundView;
}

@property (nonatomic, assign) BOOL showButtonView;
@property (nonatomic, assign) BOOL showDisplayLabel;
@property (nonatomic, assign) BOOL soldOut;
@property (nonatomic, assign) CGFloat cellMargin;
@property (nonatomic, assign) CGFloat imageViewHeight;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) ProductSmartOptionCellType productSmartOptionCellType;

- (void)initSubviews;

- (void)updateCell;

@end

@implementation CPProductInfoSmartOptionContentView

#pragma mark - Class Methods

+ (CGFloat)contentHeight
{
    return (kProductInfoSmartOptionImageHeight + kProductInfoSmartOptionCellMargin + kProductInfoSmartOptionButtonHeight + (kProductInfoSmartOptionLineHeight * 2));
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)initSubviews
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
    
    _buttonView = [[CPProductInfoSmartOptionButtonView alloc] initWithFrame:CGRectZero];
    [_buttonView.optionDetailButton addTarget:self action:@selector(onClickedOptionDetailButton:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView.optionSelectButton addTarget:self action:@selector(onClickedOptionSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonView];
    
    _headerDisplayLabelView = [[UIView alloc] initWithFrame:CGRectZero];
    _headerDisplayLabelView.backgroundColor = [UIColor colorWithHexString:@"7a7d8e"];
    [self addSubview:_headerDisplayLabelView];
    
    _headerDisplayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _headerDisplayLabel.font = BOLDFONTSIZE(16);
    _headerDisplayLabel.text = @"옵션선택";
    _headerDisplayLabel.textColor = [UIColor whiteColor];
    _headerDisplayLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_headerDisplayLabel];
    
    _soldOutBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _soldOutBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    [self addSubview:_soldOutBackgroundView];
    _soldOutBackgroundView.hidden = YES;
    
    _soldOutImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_soldout_option.png"]];
    [self addSubview:_soldOutImageView];
    _soldOutImageView.hidden = YES;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
//    _backgroundView.backgroundColor = [UIColor shCellHighlightedColor];
    _backgroundView.alpha = 0.0f;
    [self addSubview:_backgroundView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rectClient = self.bounds;
    
    CGFloat buttonViewHeight = _showButtonView ? [CPProductInfoSmartOptionButtonView contentHeight] : 0.0f;
    CGRect rectButtonView = CGRectMake(0.0f,
                                       rectClient.size.height - _cellMargin - buttonViewHeight,
                                       rectClient.size.width,
                                       buttonViewHeight);
    [_buttonView setFrame:rectButtonView];
    
    CGFloat displayLabelHeight = _showDisplayLabel ? [CPProductInfoSmartOptionButtonView contentHeight] : 0.0f;
    CGRect rectHeaderDisplayLabel = CGRectMake(0.0f,
                                               rectClient.size.height - _cellMargin - displayLabelHeight,
                                               rectClient.size.width,
                                               displayLabelHeight);
    [_headerDisplayLabelView setFrame:rectHeaderDisplayLabel];
    [_headerDisplayLabel setFrame:CGRectInset(rectHeaderDisplayLabel, 10.0f, 0.0f)];
    
    CGRect rectImageView = CGRectMake(0.0f,
                                      0.0f,
                                      rectClient.size.width,
                                      _imageViewHeight);
    [_imageView setFrame:rectImageView];
    
    CGRect rectSoldOutBackgroundView = CGRectMake(0.0f,
                                                  0.0f,
                                                  rectClient.size.width,
                                                  rectButtonView.origin.y + rectButtonView.size.height);
    [_soldOutBackgroundView setFrame:rectSoldOutBackgroundView];
    [_backgroundView setFrame:rectSoldOutBackgroundView];
    
    CGFloat imageWidth = _soldOutImageView.image.size.width;
    CGFloat imageHeight = _soldOutImageView.image.size.height;
    CGRect rectSoldOutImageView = CGRectMake((rectSoldOutBackgroundView.size.width - imageWidth) / 2,
                                             (rectSoldOutBackgroundView.size.height - imageHeight) / 2,
                                             imageWidth,
                                             imageHeight);
    [_soldOutImageView setFrame:rectSoldOutImageView];
}

#pragma mark - Property

- (void)setItem:(ProductSmartOptionModel *)item
{
    if (_item != item)
    {
        _item = item;
        if (_item)
        {
            _viewWidth = (item.cellType == ProductSmartOptionCellTypeList) ? kScreenBoundsWidth : (kScreenBoundsWidth / 2 - 14.0f);
            
            _soldOut = _item.soldOut;
            _soldOutBackgroundView.hidden = _soldOutImageView.hidden = !_soldOut;
            
            _showButtonView = (_item.sectionType == ProductSmartOptionSectionTypeOption || _item.sectionType == ProductSmartOptionSectionTypeOptionDetail);
            _buttonView.hidden = !_showButtonView;
            _buttonView.showOptionDetailButton = (_item.sectionType == ProductSmartOptionSectionTypeOption);
            _buttonView.productSmartOptionCellType = _item.cellType;
            
            _showDisplayLabel = (_item.sectionType == ProductSmartOptionSectionTypeHeaderImage);
            _headerDisplayLabelView.hidden = _headerDisplayLabel.hidden = !_showDisplayLabel;
            
            _cellMargin = (_item.optionType == ProductOptionTypeAllImages) ? 0.0f : kProductInfoSmartOptionCellMargin;
            
            [self updateCell];
        }
    }
}

#pragma mark - Private Methods

- (void)updateCell
{
    [_imageView sd_setImageWithURL:_item.imageUrl
                  placeholderImage:[UIImage imageNamed:@"thum_loading_2.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             
                             CGFloat cellHeight = 0.0f;
                             if (!error && image)
                             {
                                 CGSize imageSize = image.size;
                                 CGFloat ratio = imageSize.width / _viewWidth;
                                 _imageViewHeight = ceil(imageSize.height / ratio);
                             }
                             else
                             {
                                 NSLog(@"image download url = [%@], failed = [%@]", imageURL.absoluteString, error.localizedDescription);
                                 
                                 _imageViewHeight = kProductInfoSmartOptionImageHeight;
                             }
                             
                             cellHeight = _imageViewHeight + _cellMargin;
                             cellHeight += _showButtonView ? [CPProductInfoSmartOptionButtonView contentHeight] : 0.0f;
                             cellHeight += _showDisplayLabel ? [CPProductInfoSmartOptionButtonView contentHeight] : 0.0f;
                             cellHeight = ceil(cellHeight);
                             
                             DELEGATE_CALL2(_delegate,
                                            productInfoSmartOptionContentViewImageDownloadedAtIndex
                                            : withHeight:,
                                            _index,
                                            @(cellHeight));
                             
                             [self setNeedsLayout];
                         }];
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (_item.sectionType == ProductSmartOptionSectionTypeOption && _item.soldOut == NO)
    {
//        _backgroundView.alpha = CELL_HIGHLIGHTED_ALPHA;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if (_item.sectionType == ProductSmartOptionSectionTypeOption && _item.soldOut == NO)
    {
        _backgroundView.alpha = 0.0f;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_item.sectionType == ProductSmartOptionSectionTypeOption && _item.soldOut == NO)
    {
        _backgroundView.alpha = 0.0f;
    }
}

#pragma mark - UITapGestureRecognizer

- (void)doSingleTap
{
    if (_soldOut || _item.sectionType != ProductSmartOptionSectionTypeOption)
        return;
    
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionContentView
                   : didClickedOptionDetailButton:,
                   self,
                   _item);
}

#pragma mark - UIButton Target-Action

- (void)onClickedOptionDetailButton:(id)sender
{
    if (_soldOut)
        return;
    
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionContentView
                   : didClickedOptionDetailButton:,
                   self,
                   _item);
}

- (void)onClickedOptionSelectButton:(id)sender
{
    if (_soldOut)
        return;
    
    DELEGATE_CALL2(_delegate,
                   productInfoSmartOptionContentView
                   : didClickedOptionSelectButton:,
                   self,
                   _item);
}

@end