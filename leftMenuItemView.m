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
        //[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self showContents];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame])
    {
        //[self setBackgroundColor:UIColorFromRGB(0xa9a9a9)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _title = title;
        
        [self showContents];
        
    }
    
    
    return self;
}

#pragma showContents
- (void)showContents
{
    [self removeContents];
    
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    CGFloat meY = self.bounds.origin.y;
    
    // 320 * 40
    /*
     const static CGFloat ICON_HEIGHT     =     50;
     const static CGFloat ICON_WIDTH      =    50;
     const static CGFloat LABEL_WIDTH     =    100;
     */
    
    //icon
//    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, [self bounds].size.height)];
//    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [iconImageView setImage:[UIImage imageNamed:@"icon_navi_home.png"]];
//    [self addSubview:iconImageView];
//    
//    //label
//    // 100, 26
//    UILabel* labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+10, 8, 100, 26)];
//    [labelMenu setBackgroundColor:[UIColor clearColor]];
//    [labelMenu setTextColor:UIColorFromRGB(0x8c6239)];
//    [labelMenu setFont:[UIFont systemFontOfSize:13]];
//    //[labelMenu setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
//    //setFont:[UIFont systemFontOfSize:15]];
////    [labelMenu setShadowColor:[UIColor whiteColor]];
////    [labelMenu setShadowOffset:CGSizeMake(0,2)];
//    [labelMenu setTextAlignment:NSTextAlignmentLeft];
//    //[labelMenu setNumberOfLines:0];
//    //[labelMenu sizeToFit];
//    [labelMenu setText:_title];
//    [self addSubview:labelMenu];
//    
//    //button
//    UIButton* emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [emptyButton setFrame:[self bounds]];
//    [emptyButton setBackgroundColor:[UIColor clearColor]];
//    //emptyButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5];
//    [emptyButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
//    [emptyButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:emptyButton];
    
    //////////////////////////////////
    //button
    UIButton* emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton setFrame:[self bounds]];
    [emptyButton setBackgroundColor:[UIColor clearColor]];
    //emptyButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5];
    //[emptyButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
    [emptyButton setImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
    [emptyButton setImage:[UIImage imageNamed:@"btn_setting_menu.png"] forState:UIControlStateHighlighted];
    [emptyButton setBackgroundImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateHighlighted];
    [emptyButton setBackgroundImage:[UIImage imageNamed:@"icon_main_login.png"] forState:UIControlStateNormal];
    [emptyButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
    [emptyButton setTitle:_title forState:UIControlStateNormal];
    [emptyButton setTitle:_title forState:UIControlStateHighlighted];
    [emptyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [emptyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:emptyButton];
    
    UIImage *buttonImage = emptyButton.imageView.image;
    [emptyButton setImageEdgeInsets:UIEdgeInsetsMake(0,10,0,0)];
    [emptyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, buttonImage.size.width + 10, 0, 0)];
    
}

- (void)removeContents
{
    //    if (_topScrollButton) {
    //        if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
    //        _topScrollButton = nil;
    //    }
}

- (void)onClickButton
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRec)rect {
    // Drawing code
}
*/

@end

