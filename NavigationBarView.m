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

- (id)initWithFrame:(CGRect)frame type:(NSInteger)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        CGFloat margin = 2;
        if (screenWidth > 320) {
            margin = 10;
        }
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
        [backgroundImageView setImage:[UIImage imageNamed:@"gnb_back.png"]];
        [self addSubview:backgroundImageView];
        
        // left button
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(4, 4, 62, 57)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn.png"] forState:UIControlStateNormal];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"total_menu_btn_press.png"] forState:UIControlStateHighlighted];
        [menuButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
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
        
        // search
        UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myInfoButton setFrame:CGRectMake(screenWidth-40, 4, 92, 40)];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo.png"] forState:UIControlStateNormal];
        [myInfoButton setBackgroundImage:[UIImage imageNamed:@"top_tap_logo_press.png"] forState:UIControlStateHighlighted];
        [myInfoButton addTarget:self action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
        //[myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
        [self addSubview:myInfoButton];
        
        //sunny bank
        UIButton *basketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [basketButton setFrame:CGRectMake(screenWidth-(76+margin), 4, 62, 57)];
        [basketButton setBackgroundImage:[UIImage imageNamed:@"Search_icon.png"] forState:UIControlStateNormal];
        [basketButton setBackgroundImage:[UIImage imageNamed:@"Search_icon_press.png"] forState:UIControlStateHighlighted];
        [basketButton addTarget:self action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
        //[basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
        [self addSubview:basketButton];
        
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

- (void)touchBasketButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchBasketButton)]) {
        [self.delegate didTouchBasketButton];
    }
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 장바구니 in 마트
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0005"];
//    }
//    else {
//        //AccessLog - 장바구니
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGD0100"];
//    }
}

- (void)touchLogoButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogoButton)]) {
        [self.delegate didTouchLogoButton];
    }
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 로고 in 마트
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0002"];
//    }
//    else {
//        //AccessLog - 로고
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGA0100"];
//    }
}

- (void)touchMartButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMartButton)]) {
        [self.delegate didTouchMartButton];
    }
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 마트
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0003"];
//    }
}

- (void)touchMyInfoButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMyInfoButton)]) {
        [self.delegate didTouchMyInfoButton];
    }
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 나의11번가 in 마트
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0006"];
//    }
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

- (void)touchDetailSearchButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchSearchButton:)]) {
        [self.delegate didTouchSearchButton:nil];
    }
}

- (void)touchMartSearchButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMartSearchButton)]) {
        [self.delegate didTouchMartSearchButton];
    }
    
    //    CPMartSearchViewController *viewController = [[CPMartSearchViewController alloc] init];
    //    [viewController setDelegate:self];
    //    [self.navigationController pushViewController:viewController animated:NO];
    //    [self.navigationController setNavigationBarHidden:YES];
    
//    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
//        //AccessLog - 마트 검색
//        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0004"];
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

