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
    UILabel* labelMenu;
    UILabel* labelMailId;
    UILabel* labelId;
    UILabel* labelCardNumber;
    UIImageView *cardImageView;
    UIImageView *idImageView;
    UIButton* loginButton;
    UIButton* logoutButton;
}
@end

@implementation leftLoginView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xf68a1e)];
        //[self setBackgroundColor:[UIColor clearColor]];
        
        [self showContents];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:UIColorFromRGB(0xf68a1e)];
        //[self setBackgroundColor:[UIColor clearColor]];
        
        _title = title;
        
        //
        _loginStatus = 0;
        
        [self showContents];
        
    }
    
    
    return self;
}

#pragma showContents
- (void)showContents
{
    [self removeContents];
    
    //_loginStatus = 1;
    
    //150
    CGFloat meWidth = self.frame.size.width;
    CGFloat meHeight = self.frame.size.height;
    CGFloat meY = self.bounds.origin.y;
    
    //360
    // 320 * 40
    /*
     const static CGFloat ICON_HEIGHT     =     50;
     const static CGFloat ICON_WIDTH      =    50;
     const static CGFloat LABEL_WIDTH     =    100;
     */
    
    CGFloat marginX = (kScreenBoundsWidth > 320)?30:0;
    CGFloat labelMarginX = (kScreenBoundsWidth > 320)?2:0;
    CGFloat logoutMarginX = (kScreenBoundsWidth > 320)?60:0;
    
    //label
    // 100, 26
    labelMenu = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, meWidth-(35+30), 60)]; //94/2
    [labelMenu setBackgroundColor:[UIColor clearColor]];
    [labelMenu setTextColor:UIColorFromRGB(0xffffff)];
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
    
    //login button
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(20, CGRectGetMaxY(labelMenu.frame)+20, meWidth-(45+40), 50)];
    [loginButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn_press.png"] forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"total_menu_login_btn.png"] forState:UIControlStateNormal];
    //[emptyButton setImage:[UIImage imageNamed:@"icon_main_login.png"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(didTouchLogInBtn) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"로그인" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorFromRGB(0xf05921) forState:UIControlStateHighlighted];
    
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self addSubview:loginButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // id image
    idImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 12, 13)];
    //[idImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    idImageView.contentMode = UIViewContentModeScaleAspectFit;
    [idImageView setImage:[UIImage imageNamed:@"total_menu_email_icon.png"]];
    [self addSubview:idImageView];
    
    //id label
    labelId = [[UILabel alloc] initWithFrame:CGRectMake(35, 2, meWidth-100, 20) ];
    [labelId setBackgroundColor:[UIColor clearColor]];
    [labelId setTextColor:UIColorFromRGB(0xffffff)];
    [labelId setFont:[UIFont systemFontOfSize:15]];
    [labelId setTextAlignment:NSTextAlignmentLeft];
    [labelId setNumberOfLines:0];
    _stringId = @"springgclee";
    [labelId setText:_stringId];
    [self addSubview:labelId];
    
    //mail id label
    labelMailId = [[UILabel alloc] initWithFrame:CGRectMake(35, 16, meWidth-100, 20) ];
    [labelMailId setBackgroundColor:[UIColor clearColor]];
    [labelMailId setTextColor:UIColorFromRGB(0xffffff)];
    [labelMailId setFont:[UIFont systemFontOfSize:13]];
    [labelMailId setTextAlignment:NSTextAlignmentLeft];
    [labelMailId setNumberOfLines:0];
    _mailId = @"springgclee@gmail.com";
    [labelMailId setText:_mailId];
    [self addSubview:labelMailId];
    
    //logout button
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setFrame:CGRectMake(kScreenBoundsWidth - (80+logoutMarginX), 5, 30, 30)];
    [logoutButton setBackgroundColor:[UIColor clearColor]]; //icon_main_login, btn_login_save.png
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateHighlighted];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"total_menu_logout_btn.png"] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(didTouchLogOutBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoutButton];
    
    // card image
    cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0-marginX, 36, meWidth-40, 135)];
    //[cardImageView setBackgroundColor:UIColorFromRGB(0x105921)];
    cardImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cardImageView setImage:[UIImage imageNamed:@"total_menu_card_img.png"]];
    [self addSubview:cardImageView];
    
    //card number label
    labelCardNumber = [[UILabel alloc] initWithFrame:CGRectMake(100-labelMarginX, 100+10, meWidth-65, 40) ];
    [labelCardNumber setBackgroundColor:[UIColor clearColor]];
    [labelCardNumber setTextColor:UIColorFromRGB(0xffffff)];
    [labelCardNumber setFont:[UIFont systemFontOfSize:15]];
    [labelCardNumber setTextAlignment:NSTextAlignmentLeft];
    [labelCardNumber setNumberOfLines:0];
    _cardNumber = @"S20150001";
    [labelCardNumber setText:_cardNumber];
    [self addSubview:labelCardNumber];
    
    [self setVisableItem];
}

- (void)removeContents
{
    if(labelMenu){
        [labelMenu removeFromSuperview];
        labelMenu = nil;
    }
    
    if(labelMailId){
        [labelMailId removeFromSuperview];
        labelMailId = nil;
    }
    if(cardImageView){
        [cardImageView removeFromSuperview];
        cardImageView = nil;
    }
    if(idImageView){
        [idImageView removeFromSuperview];
        idImageView = nil;
    }
    if(loginButton){
        [loginButton removeFromSuperview];
        loginButton = nil;
    }
}

- (void)onClickButton
{
    
}

- (void)onLogOut
{
    
}

- (void)setVisableItem
{
    //_loginStatus = 0;
    if(_loginStatus){ //log on
        
        [idImageView setHidden:false];
        [labelId setHidden:false];
        [labelMailId setHidden:false];
        [cardImageView setHidden:false];
        [logoutButton setHidden:false];
        [labelCardNumber setHidden:false];
        
        [labelMenu setHidden:true];
        [loginButton setHidden:true];
        
        
    }else{            //log off
        
        [idImageView setHidden:true];
        [labelId setHidden:true];
        [labelMailId setHidden:true];
        [logoutButton setHidden:true];
        [cardImageView setHidden:true];
        [labelCardNumber setHidden:true];
        
        [labelMenu setHidden:false];
        [loginButton setHidden:false];
    }
}

#pragma mark - Selectors
- (void)didTouchLogOutBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogOutBtn)]) {
        [self.delegate didTouchLogOutBtn];
    }
    
}
- (void)didTouchLogInBtn
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogInBtn)]) {
        [self.delegate didTouchLogInBtn];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
