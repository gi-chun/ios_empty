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
    NSInteger _viewType;
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

- (id)initWithFrame:(CGRect)frame title:(NSString *)title viewType:(NSInteger)viewType
{
    if (self = [super initWithFrame:frame])
    {
        //[self setBackgroundColor:UIColorFromRGB(0xa9a9a9)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _title = title;
        _viewType = viewType;
        
        [self showContents];
        
    }
    
    
    return self;
}

#pragma showContents
- (void)showContents
{
    [self removeContents];
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?15:0;
    
//    if(_viewType == 5){
//        
//        labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, meWidth-(35+30), 60)]; //94/2
//        [labelMenu setBackgroundColor:[UIColor clearColor]];
//        [labelMenu setTextColor:UIColorFromRGB(0xffffff)];
//        [labelMenu setFont:[UIFont systemFontOfSize:15]];
//        //[labelMenu setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
//        //setFont:[UIFont systemFontOfSize:15]];
//        //    [labelMenu setShadowColor:[UIColor whiteColor]];
//        //    [labelMenu setShadowOffset:CGSizeMake(0,2)];
//        [labelMenu setTextAlignment:NSTextAlignmentLeft];
//        [labelMenu setNumberOfLines:0];
//        //[labelMenu sizeToFit];
//        [labelMenu setText:_title];
//        [self addSubview:labelMenu];
//        
//        //button
//        UIButton* famAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [famAppButton setFrame:[self bounds]];
//        [famAppButton setBackgroundColor:[UIColor clearColor]];
//        
//        UIImage *scaledImg = [self getScaledImage:[UIImage imageNamed:@"shinhanvn.png"] insideButton:famAppButton];
//        [famAppButton setBackgroundImage:scaledImg forState:UIControlStateHighlighted];
////        UIImage *scaledImg_ = [self getScaledImage:[UIImage imageNamed:@"shinhavn.png"] insideButton:famAppButton];
//        
//        [famAppButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
//        [famAppButton setTitle:_title forState:UIControlStateNormal];
//        [famAppButton setTitle:_title forState:UIControlStateHighlighted];
//        [famAppButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
//        [famAppButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [famAppButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//        [famAppButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [self addSubview:famAppButton];
//        [famAppButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 70+marginX, 0, 0)];
//        
//        //button
//        UIButton* famAppButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [famAppButton2 setFrame:[self bounds]];
//        [famAppButton2 setBackgroundColor:[UIColor clearColor]];
//        
//        UIImage *scaledImg2 = [self getScaledImage:[UIImage imageNamed:@"shinhanvn.png"] insideButton:famAppButton2];
//        [famAppButton setBackgroundImage:scaledImg2 forState:UIControlStateHighlighted];
//        //        UIImage *scaledImg_ = [self getScaledImage:[UIImage imageNamed:@"shinhavn.png"] insideButton:famAppButton];
//        
//        [famAppButton2 addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
//        [famAppButton2 setTitle:_title forState:UIControlStateNormal];
//        [famAppButton2 setTitle:_title forState:UIControlStateHighlighted];
//        [famAppButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
//        [famAppButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [famAppButton2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//        [famAppButton2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [self addSubview:famAppButton2];
//        [famAppButton2 setTitleEdgeInsets:UIEdgeInsetsMake(0, 70+marginX, 0, 0)];
//        
//    }
    
//    CGFloat meWidth = self.frame.size.width;
//    CGFloat meHeight = self.frame.size.height;
//    CGFloat meY = self.bounds.origin.y;
    
//    NSString* highLightFile;
//    NSString* nomalFile;
//    if(_viewType == 1){
//        highLightFile = @"total_menu_first.png";
//        nomalFile = @"total_menu_first_press.png";
//    }
//    if(_viewType == 2){
//        highLightFile = @"total_menu_second.png";
//        nomalFile = @"total_menu_second_press.png";
//    }
//    if(_viewType == 3){
//        highLightFile = @"total_menu_third.png";
//        nomalFile = @"total_menu_third_press.png";
//    }
//    if(_viewType == 4){
//        highLightFile = @"total_menu_firth.png";
//        nomalFile = @"total_menu_firth_press.png";
//    }
//
//    //icon
//    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, [self bounds].size.height)];
//    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [iconImageView setImage:[UIImage imageNamed:@"test@x1.png"]]; // total_menu_ex01
//    [self addSubview:iconImageView];
//    
//    //label
//    // 100, 26
//    UILabel* labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, 100, 26)];
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
//    //[emptyButton setBackgroundColor:[UIColor clearColor]];
//    //UIColorFromRGB(0xf68a1e)
////    emptyButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5];
//    //emptyButton.backgroundColor = UIColorFromRGB(0xf68a1e);
//    
////    [emptyButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
//    [emptyButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:emptyButton];
    
    //////////////////////////////////
    //button
    UIButton* emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emptyButton setFrame:[self bounds]];
        [emptyButton setBackgroundColor:[UIColor clearColor]];
    
    //[emptyButton setBackgroundColor:[UIColor clearColor]];
//    [emptyButton setImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
//    [emptyButton setImage:[UIImage imageNamed:@"btn_setting_menu.png"] forState:UIControlStateHighlighted];
    
    
    NSString* highLightFile;
    NSString* nomalFile;
    if(_viewType == 1){
        highLightFile = @"total_menu_01.png";
        nomalFile = @"total_menu_01_press.png";
    }
    if(_viewType == 2){
        highLightFile = @"total_menu_02.png";
        nomalFile = @"total_menu_02_press.png";
    }
    if(_viewType == 3){
        highLightFile = @"total_menu_03.png";
        nomalFile = @"total_menu_03_press.png";
    }
    if(_viewType == 4){
        highLightFile = @"total_menu_04.png";
        nomalFile = @"total_menu_04_press.png";
    }

    UIImage *scaledImg = [self getScaledImage:[UIImage imageNamed:highLightFile] insideButton:emptyButton];
    [emptyButton setBackgroundImage:scaledImg forState:UIControlStateHighlighted];
    UIImage *scaledImg_ = [self getScaledImage:[UIImage imageNamed:nomalFile] insideButton:emptyButton];
    [emptyButton setBackgroundImage:scaledImg_ forState:UIControlStateNormal];
    
    [emptyButton addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
    [emptyButton setTitle:_title forState:UIControlStateNormal];
    [emptyButton setTitle:_title forState:UIControlStateHighlighted];
    [emptyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [emptyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [emptyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [emptyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    //[emptyButton setImage:[UIImage imageNamed:@"total_menu_first.png"] forState:UIControlStateNormal];
   
    [self addSubview:emptyButton];
    
    //UIImage *buttonImage = emptyButton.imageView.image;
    //[emptyButton setImageEdgeInsets:UIEdgeInsetsMake(0,10,0,0)];
    [emptyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 70+marginX, 0, 0)];
    
}

- (UIImage *) getScaledImage:(UIImage *)img insideButton:(UIButton *)btn {
    
    // Check which dimension (width or height) to pay respect to and
    // calculate the scale factor
    CGFloat imgRatio = img.size.width / img.size.height,
    btnRatio = btn.frame.size.width / btn.frame.size.height,
    scaleFactor = (imgRatio > btnRatio)?img.size.width/btn.frame.size.width:img.size.height/btn.frame.size.height;
    
    // Create image using scale factor
    UIImage *scaledImg = [UIImage imageWithCGImage:[img CGImage]
                                             scale:scaleFactor
                                       orientation:UIImageOrientationUp];
    return scaledImg;
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
    [self didTouchMenuItem:_viewType];
}

#pragma mark - Selectors
- (void)didTouchMenuItem:(NSInteger)menuType
{
    if ([self.delegate respondsToSelector:@selector(didTouchMenuItem:)]) {
        [self.delegate didTouchMenuItem:menuType];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRec)rect {
    // Drawing code
}
*/

@end

