//
//  CPNavigationBarView.m
//  11st
//
//  Created by spearhead on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPNavigationBarView.h"
#import "CPCommonInfo.h"
#import "AccessLog.h"

@interface CPNavigationBarView () <UITextFieldDelegate>
{
    UITextField *searchTextField;
}
@end

@implementation CPNavigationBarView

- (id)initWithFrame:(CGRect)frame type:(CPNavigationType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (type == CPNavigationTypeDefault) {
            [self setBackgroundColor:UIColorFromRGB(0xf33143)];
//            [self setBackgroundColor:UIColorFromRGB(0xf62a42)];
            
            // left button
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:CGRectMake(4, 4, 36, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_side_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_side_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setAccessibilityLabel:@"메뉴" Hint:@"왼쪽 메뉴로 이동합니다"];
            [self addSubview:menuButton];
            
            self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+10, 4, 54, 36)];
            [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_nor.png"] forState:UIControlStateNormal];
            [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_press.png"] forState:UIControlStateHighlighted];
            [self.logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
            [self.logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
            [self addSubview:self.logoButton];
            
            UIImage *searchImage = [UIImage imageNamed:@"gnb_search_bg.png"];
            searchImage = [searchImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchImage.size.height / 2, searchImage.size.width / 2, searchImage.size.height / 2, searchImage.size.width / 2)];
            
            UIImageView *searchBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.logoButton.frame)+6, 4, kScreenBoundsWidth-206, 36)];
            [searchBackgroundImageView setImage:searchImage];
            [searchBackgroundImageView setUserInteractionEnabled:YES];
            [self addSubview:searchBackgroundImageView];
            
            searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(searchBackgroundImageView.frame)-46, 36)];
            [searchTextField setDelegate:self];
            [searchTextField setTextColor:UIColorFromRGB(0x666666)];
            [searchTextField setFont:[UIFont systemFontOfSize:12]];
            [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [searchBackgroundImageView addSubview:searchTextField];
            
            if ([[CPCommonInfo sharedInfo] currentAdKeyword]) {
                [searchTextField setText:[[CPCommonInfo sharedInfo] currentAdKeyword]];
            }
            
            UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [searchButton setFrame:CGRectMake(CGRectGetWidth(searchBackgroundImageView.frame)-32, 2, 32, 32)];
            [searchButton setImage:[UIImage imageNamed:@"ic_search_nor.png"] forState:UIControlStateNormal];
            [searchButton setImage:[UIImage imageNamed:@"ic_search_press.png"] forState:UIControlStateHighlighted];
            [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
            [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
            [searchBackgroundImageView addSubview:searchButton];
            
            // right button
            UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [myInfoButton setFrame:CGRectMake(kScreenBoundsWidth-40, 4, 36, 36)];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_nor.png"] forState:UIControlStateNormal];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_press.png"] forState:UIControlStateHighlighted];
            [myInfoButton addTarget:self action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
            [myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
            [self addSubview:myInfoButton];
            
            UIButton *basketButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [basketButton setFrame:CGRectMake(kScreenBoundsWidth-86, 4, 36, 36)];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_nor.png"] forState:UIControlStateNormal];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_press.png"] forState:UIControlStateHighlighted];
            [basketButton addTarget:self action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
            [basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
            [self addSubview:basketButton];
        }
        else if (type == CPNavigationTypeBack) {
            [self setBackgroundColor:UIColorFromRGB(0xf33143)];
//            [self setBackgroundColor:UIColorFromRGB(0xf62a42)];
//            [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_gnb_red"]]];
            
            // left button
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:CGRectMake(4, 4, 36, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bt_gnb_back_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bt_gnb_back_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
            [self addSubview:menuButton];
            
            self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+10, 4, 54, 36)];
            [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_nor.png"] forState:UIControlStateNormal];
            [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo_press.png"] forState:UIControlStateHighlighted];
            [self.logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
            [self.logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
            [self addSubview:self.logoButton];
            
            UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [searchButton setFrame:CGRectMake(kScreenBoundsWidth-132, 4, 36, 36)];
            [searchButton setImage:[UIImage imageNamed:@"bt_gnb_search_nor.png"] forState:UIControlStateNormal];
            [searchButton setImage:[UIImage imageNamed:@"bt_gnb_search_press.png"] forState:UIControlStateHighlighted];
            [searchButton addTarget:self action:@selector(touchDetailSearchButton) forControlEvents:UIControlEventTouchUpInside];
            [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
            [self addSubview:searchButton];
            
            UIButton *basketButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [basketButton setFrame:CGRectMake(kScreenBoundsWidth-86, 4, 36, 36)];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_nor.png"] forState:UIControlStateNormal];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"ic_basket_press.png"] forState:UIControlStateHighlighted];
            [basketButton addTarget:self action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
            [basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
            [self addSubview:basketButton];
            
            // right button
            UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [myInfoButton setFrame:CGRectMake(kScreenBoundsWidth-40, 4, 36, 36)];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_nor.png"] forState:UIControlStateNormal];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"ic_my11_press.png"] forState:UIControlStateHighlighted];
            [myInfoButton addTarget:self action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
            [myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
            [self addSubview:myInfoButton];
        }
        else if (type == CPNavigationTypeMart) {
            CGFloat margin = 2;
            if (kScreenBoundsWidth > 320) {
                margin = 10;
            }
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
            [backgroundImageView setImage:[UIImage imageNamed:@"gnb_bgcolor.png"]];
            [self addSubview:backgroundImageView];
            
            // left button
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:CGRectMake(4, 4, 36, 36)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cate_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cate_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:self action:@selector(touchMenuButton) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setAccessibilityLabel:@"메뉴" Hint:@"왼쪽 메뉴로 이동합니다"];
            [self addSubview:menuButton];
            
            UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+margin, 4, 54, 36)];
            [logoButton setBackgroundImage:[UIImage imageNamed:@"gnb_bi_11st_nor.png"] forState:UIControlStateNormal];
            [logoButton setBackgroundImage:[UIImage imageNamed:@"gnb_bi_11st_press.png"] forState:UIControlStateHighlighted];
            [logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
            [logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
            [self addSubview:logoButton];
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleButton setFrame:CGRectMake(CGRectGetMaxX(logoButton.frame)+margin, 4, 120, 36)];
            [titleButton setImage:[UIImage imageNamed:@"gnb_btn_mart11_nor.png"] forState:UIControlStateNormal];
            [titleButton setImage:[UIImage imageNamed:@"gnb_btn_mart11_press.png"] forState:UIControlStateHighlighted];
            [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [titleButton addTarget:self action:@selector(touchMartButton) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:titleButton];
            
            // right button
            UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [myInfoButton setFrame:CGRectMake(kScreenBoundsWidth-40, 4, 36, 36)];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_my_nor.png"] forState:UIControlStateNormal];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_my_press.png"] forState:UIControlStateHighlighted];
            [myInfoButton addTarget:self action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
            [myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
            [self addSubview:myInfoButton];
            
            UIButton *basketButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [basketButton setFrame:CGRectMake(kScreenBoundsWidth-(76+margin), 4, 36, 36)];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cart_nor.png"] forState:UIControlStateNormal];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cart_press.png"] forState:UIControlStateHighlighted];
            [basketButton addTarget:self action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
            [basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
            [self addSubview:basketButton];
            
            UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [searchButton setFrame:CGRectMake(kScreenBoundsWidth-(112+margin+margin), 4, 36, 36)];
            [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_nor.png"] forState:UIControlStateNormal];
            [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_press.png"] forState:UIControlStateHighlighted];
            [searchButton addTarget:self action:@selector(touchMartSearchButton) forControlEvents:UIControlEventTouchUpInside];
            [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
            [self addSubview:searchButton];
        }
        else if (type == CPNavigationTypeMartBack) {
            CGFloat margin = 2;
            if (kScreenBoundsWidth > 320) {
                margin = 10;
            }
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
            [backgroundImageView setImage:[UIImage imageNamed:@"gnb_bgcolor.png"]];
            [self addSubview:backgroundImageView];
            
            // left button
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:CGRectMake(4, 4, 34, 34)];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bt_gnb_back_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"bt_gnb_back_press.png"] forState:UIControlStateHighlighted];
            [menuButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setAccessibilityLabel:@"백버튼" Hint:@"뒤로 이동합니다"];
            [self addSubview:menuButton];
            
            UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [logoButton setFrame:CGRectMake(CGRectGetMaxX(menuButton.frame)+margin, 4, 54, 36)];
            [logoButton setBackgroundImage:[UIImage imageNamed:@"gnb_bi_11st_nor.png"] forState:UIControlStateNormal];
            [logoButton setBackgroundImage:[UIImage imageNamed:@"gnb_bi_11st_press.png"] forState:UIControlStateHighlighted];
            [logoButton addTarget:self action:@selector(touchLogoButton) forControlEvents:UIControlEventTouchUpInside];
            [logoButton setAccessibilityLabel:@"로고" Hint:@"홈으로 이동합니다"];
            [self addSubview:logoButton];
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [titleButton setFrame:CGRectMake(CGRectGetMaxX(logoButton.frame)+margin, 4, 120, 36)];
            [titleButton setImage:[UIImage imageNamed:@"gnb_btn_mart11_nor.png"] forState:UIControlStateNormal];
            [titleButton setImage:[UIImage imageNamed:@"gnb_btn_mart11_press.png"] forState:UIControlStateHighlighted];
            [titleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [titleButton addTarget:self action:@selector(touchMartButton) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:titleButton];
            
            // right button
            UIButton *myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [myInfoButton setFrame:CGRectMake(kScreenBoundsWidth-40, 4, 36, 36)];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_my_nor.png"] forState:UIControlStateNormal];
            [myInfoButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_my_press.png"] forState:UIControlStateHighlighted];
            [myInfoButton addTarget:self action:@selector(touchMyInfoButton) forControlEvents:UIControlEventTouchUpInside];
            [myInfoButton setAccessibilityLabel:@"내정보" Hint:@"내정보로 이동합니다"];
            [self addSubview:myInfoButton];
            
            UIButton *basketButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [basketButton setFrame:CGRectMake(kScreenBoundsWidth-(76+margin), 4, 36, 36)];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cart_nor.png"] forState:UIControlStateNormal];
            [basketButton setBackgroundImage:[UIImage imageNamed:@"gnb_btn_cart_press.png"] forState:UIControlStateHighlighted];
            [basketButton addTarget:self action:@selector(touchBasketButton) forControlEvents:UIControlEventTouchUpInside];
            [basketButton setAccessibilityLabel:@"장바구니" Hint:@"장바구니로 이동합니다"];
            [self addSubview:basketButton];
            
            UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [searchButton setFrame:CGRectMake(kScreenBoundsWidth-(112+margin+margin), 4, 36, 36)];
            [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_nor.png"] forState:UIControlStateNormal];
            [searchButton setImage:[UIImage imageNamed:@"gnb_btn_search_press.png"] forState:UIControlStateHighlighted];
            [searchButton addTarget:self action:@selector(touchMartSearchButton) forControlEvents:UIControlEventTouchUpInside];
            [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
            [self addSubview:searchButton];
        }
        else if (type == CPNavigationTypePlain) {
            [self setBackgroundColor:UIColorFromRGB(0x374263)];
        }
        else {
            [self setBackgroundColor:UIColorFromRGB(0x374263)];
        }
        
    }
    
    return self;
}

#pragma mark - Selectors

- (void)touchMenuButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMenuButton)]) {
        [self.delegate didTouchMenuButton];
    }
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 사이드메뉴
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0001"];
    }
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
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 장바구니 in 마트
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0005"];
    }
    else {
        //AccessLog - 장바구니
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGD0100"];
    }
}

- (void)touchLogoButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchLogoButton)]) {
        [self.delegate didTouchLogoButton];
    }
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 로고 in 마트
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0002"];
    }
    else {
        //AccessLog - 로고
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGA0100"];
    }
}

- (void)touchMartButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMartButton)]) {
        [self.delegate didTouchMartButton];
    }
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 마트
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0003"];
    }
}

- (void)touchMyInfoButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchMyInfoButton)]) {
        [self.delegate didTouchMyInfoButton];
    }
    
    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 나의11번가 in 마트
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0006"];
    }
}

- (void)touchSearchButton
{
    NSMutableDictionary *searchKeyWordInfo = [[CPCommonInfo sharedInfo] searchKeyWordInfo];
    
    //keyword 광고
    if (searchKeyWordInfo) {
        
        NSString *keywordTrim = [searchKeyWordInfo[@"name"] trim];
        
        if([[searchTextField.text trim] length] > 0 && [searchTextField.text isEqualToString:keywordTrim]) {
            NSString *keywordUrl = [searchKeyWordInfo objectForKey:@"link"];
            
            if ([self.delegate respondsToSelector:@selector(didTouchSearchButton:)]) {
                [self.delegate didTouchSearchButton:keywordUrl];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(didTouchSearchButtonWithKeyword:)] && searchTextField.text) {
                [self.delegate didTouchSearchButtonWithKeyword:searchTextField.text];
            }
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didTouchSearchButtonWithKeyword:)] && searchTextField.text) {
            [self.delegate didTouchSearchButtonWithKeyword:searchTextField.text];
        }
    }
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

    if ([[CPCommonInfo sharedInfo] currentNavigationType] == CPNavigationTypeMart) {
        //AccessLog - 마트 검색
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAMART0004"];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSString *keyword = @"";
    NSString *keywordUrl = @"";
    
    NSMutableDictionary *searchKeyWordInfo = [[CPCommonInfo sharedInfo] searchKeyWordInfo];
    
    //keyword광고인지 확인한다.
    if (searchKeyWordInfo) {
        NSString *keywordTrim = [[searchKeyWordInfo objectForKey:@"name"] trim];
        if([[textField.text trim] length] > 0 && [textField.text isEqualToString:keywordTrim]) {
            keywordUrl = [searchKeyWordInfo objectForKey:@"link"];
        }
    }
    
    if ([[textField.text trim] length] > 0) {
        keyword = textField.text;
    }
    
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
