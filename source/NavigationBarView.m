//
//  NavigationBarView.m
//  gcleeEmpty
//
//  Created by gclee on 2015. 10. 26..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import "NavigationBarView.h"


@interface NavigationBarView () <UITextFieldDelegate>
{
    UITextField *searchTextField;
}
@end

@implementation NavigationBarView

- (id)initWithFrame:(CGRect)frame type:(NSInteger)type title:(NSString*) title
{
    self = [super initWithFrame:frame];
    
    
    if (self) {
        
        CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        CGFloat marginX = (screenWidth > 320)?0:30;
        
        [self setBackgroundColor:UIColorFromRGB(0xffffff)];
        if(type == 1){
            
            [self setBackgroundColor:UIColorFromRGB(0xf05921)];
            
            // prev button
            UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [prevButton setFrame:CGRectMake(13, 10, 31, 31)];
            [prevButton setBackgroundImage:[UIImage imageNamed:@"top_back_btn.png"] forState:UIControlStateNormal];
            [prevButton setBackgroundImage:[UIImage imageNamed:@"top_back_btn_press.png"] forState:UIControlStateHighlighted];
            [prevButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
            [prevButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
            [prevButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
            //[menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
            [self addSubview:prevButton];
            
            //label
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) ];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setTextColor:UIColorFromRGB(0xffffff)];
            [titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setNumberOfLines:0];
            [titleLabel setText:title];
            [self addSubview:titleLabel];
            
            return self;
        }
        
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kNavigationHeight)];
        [backgroundImageView setImage:[UIImage imageNamed:@"gnb_back.png"]];
        [backgroundImageView setFrame:CGRectMake(0, 0, screenWidth, kNavigationHeight)];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundImageView];
        
        // left button
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(13, 13, 31, 31)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn.png"] forState:UIControlStateNormal];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn_press.png"] forState:UIControlStateHighlighted];
        [menuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [menuButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
        //[menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
        [self addSubview:menuButton];
        
        //        UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+margin, 4, 54, 36)];
        //        [logoButton setBackgroundImage:[UIImage imageNamed:@"icon_main_login.png"] forState:UIControlStateNormal];
        //        [logoButton setBackgroundImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
        //        [logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
        //        //[logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
        //        [self addSubview:logoButton];
        
        //        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [titleButton setFrame:CGRectMake(CGRectGetMaxX(logoButton.frame)+margin, 4, 120, 36)];
        //        [titleButton setImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
        //        [titleButton setImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
        //        [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        //        [titleButton addTarget:self action:@selector(touchMartButton) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:titleButton];
        
        // sunny bank
        UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myInfoButton setFrame:CGRectMake(screenWidth-72+marginX, 13, 46, 20)];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo.png"] forState:UIControlStateNormal];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo_press.png"] forState:UIControlStateHighlighted];
        [myInfoButton addTarget:self action:@selector(touchBankButton) forControlEvents:UIControlEventTouchUpInside];
        //[myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
        [self addSubview:myInfoButton];
        
        //search
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:CGRectMake(screenWidth-(72+31+31)+marginX, 13, 31, 28)];
        [searchButton setBackgroundImage:[UIImage imageNamed:@"Search_icon.png"] forState:UIControlStateNormal];
        [searchButton setBackgroundImage:[UIImage imageNamed:@"Search_icon_press.png"] forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
        //[basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
        [self addSubview:searchButton];
        
        //        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [searchButton setFrame:CGRectMake(screenWidth-(112+margin+margin), 4, 36, 36)];
        //        [searchButton setImage:[UIImage imageNamed:@"icon_navi_home.png"] forState:UIControlStateNormal];
        //        [searchButton setImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateHighlighted];
        //        [searchButton addTarget:self action:@selector(touchMartSearchButton) forControlEvents:UIControlEventTouchUpInside];
        //        //[searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
        //        [self addSubview:searchButton];
        
    }
    
    return self;
    
}


- (id)initWithFrame:(CGRect)frame type:(NSInteger)type
{
    self = [super initWithFrame:frame];
   
    if (self) {
        
        CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        CGFloat marginX = (screenWidth > 320)?0:10;
        
        if(type == 1){ //back
            
            [self setBackgroundColor:UIColorFromRGB(0xf05921)]; //0xf05921
            
            // prev button
            UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [prevButton setFrame:CGRectMake(13, 5, 31, 31)];
            [prevButton setBackgroundImage:[UIImage imageNamed:@"top_back_btn.png"] forState:UIControlStateNormal];
            [prevButton setBackgroundImage:[UIImage imageNamed:@"top_back_btn_press.png"] forState:UIControlStateHighlighted];
            [prevButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
            [prevButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
            [prevButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
            //[menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
            [self addSubview:prevButton];
            
            //label
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kNavigationHeight) ];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setTextColor:UIColorFromRGB(0xf05921)];
            [titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [titleLabel setTextAlignment:NSTextAlignmentRight];
            [titleLabel setNumberOfLines:0];
            [titleLabel setText:_title];
            [self addSubview:titleLabel];
            
            return self;
        }else if(type == 3){ //bank
            [self setBackgroundColor:UIColorFromRGB(0xffffff)]; //0x2881C0
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
            [backgroundImageView setImage:[UIImage imageNamed:@"bank_gnb_back.png"]];
            [backgroundImageView setFrame:CGRectMake(0, -5, screenWidth, 60)];
            backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:backgroundImageView];
            
            // left button
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:CGRectMake(10, 6, 31, 31)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bank_total_menu_btn.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bank_total_menu_btn_press.png"] forState:UIControlStateHighlighted];
            [menuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
            [menuButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
            [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
            //[menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
            [self addSubview:menuButton];
            
            // sunny bank
            UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [myInfoButton setFrame:CGRectMake(screenWidth-72+marginX, 13, 46, 20)];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"bank_top_tap_logo.png"] forState:UIControlStateNormal];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"bank_top_tap_logo_press.png"] forState:UIControlStateHighlighted];
            [myInfoButton addTarget:self action:@selector(touchSunnyButton) forControlEvents:UIControlEventTouchUpInside];
            //[myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
            [self addSubview:myInfoButton];
            
//            //location
//            UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            [searchButton setFrame:CGRectMake(screenWidth-(72+31+31)+marginX, 13, 31, 28)];
//            [searchButton setBackgroundImage:[UIImage imageNamed:@"location_icon.png"] forState:UIControlStateNormal];
//            [searchButton setBackgroundImage:[UIImage imageNamed:@"location_icon_press.png"] forState:UIControlStateHighlighted];
//            [searchButton addTarget:self action:@selector(touchLocationButton) forControlEvents:UIControlEventTouchUpInside];
//            //[basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
//            [self addSubview:searchButton];
            
            return self;
        }else if(type == 4){ //hide
            
            [self setBackgroundColor:UIColorFromRGB(0xf05921)]; //0xf05921
            return self;
        }
       
        [self setBackgroundColor:UIColorFromRGB(0xffffff)]; //0x2881C0
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
        [backgroundImageView setImage:[UIImage imageNamed:@"gnb_back.png"]];
        [backgroundImageView setFrame:CGRectMake(0, -5, screenWidth, 60)];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
                [self addSubview:backgroundImageView];
        
        // left button
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(10, 6, 31, 31)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn.png"] forState:UIControlStateNormal];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn_press.png"] forState:UIControlStateHighlighted];
        [menuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [menuButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
        //[menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
        [self addSubview:menuButton];
        
        // sunny bank
        UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myInfoButton setFrame:CGRectMake(screenWidth-72+marginX, 13, 46, 20)];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo.png"] forState:UIControlStateNormal];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo_press.png"] forState:UIControlStateHighlighted];
        [myInfoButton addTarget:self action:@selector(touchBankButton) forControlEvents:UIControlEventTouchUpInside];
        //[myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
        [self addSubview:myInfoButton];
        
//        //search
//        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [searchButton setFrame:CGRectMake(screenWidth-(72+31+31)+marginX, 13, 31, 28)];
//        [searchButton setBackgroundImage:[UIImage imageNamed:@"Search_icon.png"] forState:UIControlStateNormal];
//        [searchButton setBackgroundImage:[UIImage imageNamed:@"Search_icon_press.png"] forState:UIControlStateHighlighted];
//        [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
//        //[basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
//        [self addSubview:searchButton];
        
    }
    
    return self;
    
}

#pragma mark - Selectors

- (void)touchMenuButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMenuButton)]) {
        [self.delegate didTouchMenuButton];
    }
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 사이드메뉴
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0001"];
//    }
}

- (void)touchBackButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
        [self.delegate didTouchBackButton];
    }
    
    //    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
    //        //AccessLog - 사이드메뉴
    //        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0001"];
    //    }
}

- (void)touchBankButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchBankButton)]) {
        [self.delegate didTouchBankButton];
    }
}

- (void)touchSunnyButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchSunnyButton)]) {
        [self.delegate didTouchSunnyButton];
    }
}

- (void)touchSearchButton
{
//    NSMutableDictionary *searchKeyWordInfo = [[CPCommonInfo sharedInfo] searchKeyWordInfo];
//    
//    //keyword 광고
//    if (searchKeyWordInfo) {
//        
//        NSString *keywordTrim = [searchKeyWordInfo[@"name"] trim];
//        
//        if([[searchTextField.text trim] length] > 0 && [searchTextField.text isEqualToString:keywordTrim]) {
//            NSString *keywordUrl = [searchKeyWordInfo objectForKey:@"link"];
//            
//            if ([self.delegate respondsToSelector:@selector(didTouchSearchButton:)]) {
//                [self.delegate didTouchSearchButton:keywordUrl];
//            }
//        }
//        else {
//            if ([self.delegate respondsToSelector:@selector(didTouchSearchButtonWithKeyword:)] && searchTextField.text) {
//                [self.delegate didTouchSearchButtonWithKeyword:searchTextField.text];
//            }
//        }
//    }
//    else {
//        if ([self.delegate respondsToSelector:@selector(didTouchSearchButtonWithKeyword:)] && searchTextField.text) {
//            [self.delegate didTouchSearchButtonWithKeyword:searchTextField.text];
//        }
//    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *keyword = @"";
    NSString *keywordUrl = @"";
    
//    NSMutableDictionary *searchKeyWordInfo = [[CPCommonInfo sharedInfo] searchKeyWordInfo];
//    
//    //keyword광고인지 확인한다.
//    if (searchKeyWordInfo) {
//        NSString *keywordTrim = [[searchKeyWordInfo objectForKey:@"name"] trim];
//        if([[textField.text trim] length] > 0 && [textField.text isEqualToString:keywordTrim]) {
//            keywordUrl = [searchKeyWordInfo objectForKey:@"link"];
//        }
//    }
    
//    if ([[textField.text trim] length] > 0) {
//        keyword = textField.text;
//    }
    
    if ([self.delegate respondsToSelector:@selector(searchTextFieldShouldBeginEditing:keywordUrl:)]) {
        [self.delegate searchTextFieldShouldBeginEditing:keyword keywordUrl:keywordUrl];
    }
    
    return NO;
}

#pragma mark - Public Mehtods

- (void)setSearchTextField:(NSString *)keyword
{
    searchTextField.adjustsFontSizeToFitWidth = YES;
    searchTextField.text = keyword;
}

- (NSString *)getSearchTextField
{
    return searchTextField.text;
}

@end

