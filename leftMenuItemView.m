//
//  leftMenuItemView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 6..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "leftMenuItemView.h"

const static CGFloat ICON_HEIGHT     =     50;
const static CGFloat ICON_WIDTH      =    50;
const static CGFloat LABEL_WIDTH     =    100;

@interface leftMenuItemView ()
{
    //NSDictionary *_item;
    //NSMutableDictionary *_AreaItem;
    NSString * _title;
}
@end

@implementation leftMenuItemView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
        
        [self showContents];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
        
        _title = title;
        
        [self showContents];
        
    }
    
    
    return self;
}

#pragma showContents
- (void)showContents
{
    [self removeContents];
    
    //icon
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_HEIGHT)];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [iconImageView setImage:[UIImage imageNamed:@"icon_navi_home.png"]];
    [self addSubview:iconImageView];
    
    //label
    UILabel* labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, CGRectGetMinY(iconImageView.frame), ICON_HEIGHT, LABEL_WIDTH)];
    [labelMenu setText:_title];
    [self addSubview:labelMenu];
}

- (void)removeContents
{
    //    if (_topScrollButton) {
    //        if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
    //        _topScrollButton = nil;
    //    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRec)rect {
    // Drawing code
}
*/

@end

