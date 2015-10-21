//
//  CPTrendAutoBannerCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 28..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendAutoBannerCell.h"
#import "CPThumbnailView.h"
#import "NSTimer+Blocks.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

@interface CPTrendAutoBannerCell ()
{
    NSInteger _index;
    UIView *_contentView;
    CPThumbnailView *_thumbnailView;
    UIView *_lineView;
    CPTouchActionView *_touchButton;
    
    NSString *_extraColor;
    NSString *_lnkBnnrImgUrl;
    NSString *_dispObjLnkUrl;
    NSString *_dispObjNm;
    
    NSTimer *_timer;
}

@end

@implementation CPTrendAutoBannerCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)removeFromSuperview
{
    [self stopTimer];
    
    [super removeFromSuperview];
}

- (void)initSubviews
{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_contentView];
    
    _thumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectZero];
    _thumbnailView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_thumbnailView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
    [_contentView addSubview:_lineView];
    
    _touchButton = [[CPTouchActionView alloc] initWithFrame:CGRectZero];
    [_contentView addSubview:_touchButton];
}

- (void)setItems:(NSArray *)items
{
    _items = items;

    [self stopTimer];
    
    _index = 0;
    [self setBannerItem:_index];
    if ([_items count] > 1) {
        [self updateTimer];
    }
}

- (void)layoutSubviews
{
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20, 61);
    _thumbnailView.frame = CGRectMake((_contentView.frame.size.width/2)-150.f, 0, 300, 60);
    _lineView.frame = CGRectMake(0, _contentView.frame.size.height-1, _contentView.frame.size.width, 1);
    _touchButton.frame = _contentView.bounds;
}

- (void)setBannerItem:(NSInteger)index
{
    [self setBannerData:index];
    
    if (_extraColor && [_extraColor length] >= 7) {
        unsigned colorInt = 0;
        [[NSScanner scannerWithString:[_extraColor substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
        [_contentView setBackgroundColor:UIColorFromRGB(colorInt)];
    }
    
    if (_lnkBnnrImgUrl && [_lnkBnnrImgUrl length] > 0) {
        [_thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:_lnkBnnrImgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
    }
    
    if (_dispObjLnkUrl && [_dispObjLnkUrl length] > 0) {
        _touchButton.actionType = CPButtonActionTypeOpenSubview;
        _touchButton.actionItem = _dispObjLnkUrl;
        
        if (_dispObjNm) {
            [_touchButton setAccessibilityLabel:_dispObjNm Hint:@""];
        }
    }
}

- (void)setBannerData:(NSInteger)index
{
    if ([_items count] <= index) return;
    
    NSString *groupName = _items[index][@"groupName"];
    if ([groupName isEqualToString:@"lineBanner"]) {
        
        NSString *extraText = (_items[index][@"lineBanner"][@"extraText"] ? _items[index][@"lineBanner"][@"extraText"] : @"#ffffff");
        NSString *dispObjLnkUrl = _items[index][@"lineBanner"][@"dispObjLnkUrl"];
        NSString *lnkBnnrImgUrl = _items[index][@"lineBanner"][@"lnkBnnrImgUrl"];
        NSString *dispObjNm = _items[index][@"lineBanner"][@"dispObjNm"];
        
        if (extraText)		_extraColor = [[NSString alloc] initWithString:extraText];
        if (dispObjLnkUrl)	_dispObjLnkUrl = [[NSString alloc] initWithString:dispObjLnkUrl];
        if (lnkBnnrImgUrl)	_lnkBnnrImgUrl = [[NSString alloc] initWithString:lnkBnnrImgUrl];
        if (dispObjNm)		_dispObjNm = [[NSString alloc] initWithString:dispObjNm];
    }
}

- (NSInteger)setNextIndex:(NSInteger)cIndex items:(NSArray *)items
{
    if (cIndex >= [items count]) return 0;
    if (cIndex < 0) return 0;
    
    return cIndex;
}

#pragma timer
- (void)updateTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f block:^{
        _index = [self setNextIndex:_index+1 items:_items];
        [self setBannerItem:_index];
    } repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    if (_timer && _timer.isValid)
    {
        [_timer invalidate];
        _timer = nil;
    }
}
@end
