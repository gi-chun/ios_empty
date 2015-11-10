//
//  leftLoginView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 10..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "leftLoginView.h"

@interface leftLoginView ()
{
    //NSDictionary *_item;
    //NSMutableDictionary *_AreaItem;
    NSString * _title;
}
@end

@implementation leftLoginView

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
        [self setBackgroundColor:UIColorFromRGB(0xa9a9a9)];
        
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
    
    //label
    // 100, 26
    UILabel* labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, meWidth, 26*2)];
    [labelMenu setBackgroundColor:[UIColor clearColor]];
    [labelMenu setTextColor:UIColorFromRGB(0x8c6239)];
    [labelMenu setFont:[UIFont systemFontOfSize:15]];
    //[labelMenu setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    //setFont:[UIFont systemFontOfSize:15]];
    //    [labelMenu setShadowColor:[UIColor whiteColor]];
    //    [labelMenu setShadowOffset:CGSizeMake(0,2)];
    [labelMenu setTextAlignment:NSTextAlignmentLeft];
    [labelMenu setNumberOfLines:0];
    //[labelMenu sizeToFit];
    [labelMenu setText:_title];
    [self addSubview:labelMenu];
    
    //button
    UIButton* emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton setFrame:CGRectMake(20, CGRectGetMaxY(labelMenu.frame)+10, meWidth-50, 26*2)];
    [emptyButton setBackgroundColor:[UIColor clearColor]];
    [emptyButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
    [emptyButton setImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateNormal];
    [emptyButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
    [emptyButton setTitle:@"로그인" forState:UIControlStateNormal];
    [emptyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    emptyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    CGFloat spacing = 20; // the amount of spacing to appear between image and title
    emptyButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    emptyButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    [self addSubview:emptyButton];
    
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
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
