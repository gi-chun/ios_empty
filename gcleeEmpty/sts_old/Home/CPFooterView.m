//
//  CPFooterView.m
//  11st
//
//  Created by 조휘준 on 2015. 04. 08..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPFooterView.h"
#import "CPCommonInfo.h"
#import "UIAlertView+Blocks.h"
#import "TTTAttributedLabel.h"
#import "CPHomeViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "CPPopupViewController.h"

typedef NS_ENUM(NSUInteger, CPFooterButtonType){
    CPFooterButtonTypeLogin = 800,          //로그인
    CPFooterButtonTypePCVersion,            //PC버전
    CPFooterButtonTypeCustomer,             //고객센터
    CPFooterButtonTypeAllService            //전체서비스
};

typedef NS_ENUM(NSUInteger, CPFooterLinkType){
    CPFooterLinkTypeCompanyInfo = 0,        //사업자정보확인
    CPFooterLinkTypeTerms,                  //이용약관
    CPFooterLinkTypePersonalInfo            //개인정보취급방침
};

@interface CPFooterView() <TTTAttributedLabelDelegate,
                        CPPopupViewControllerDelegate>
{
    UIView *footerView;
    NSMutableDictionary *footerInfo;
}

@end

@implementation CPFooterView

@synthesize width = _width;
@synthesize height = _height;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame hasNotice:(BOOL)hasNotice
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        footerInfo = [NSMutableDictionary dictionary];
        footerInfo = [[[CPCommonInfo sharedInfo] footer] mutableCopy];
        
        if (footerInfo.count > 0) {
            
            footerView = [[UIView alloc] initWithFrame:CGRectZero];
            [self addSubview: footerView];
            
            CGFloat loginButtonY = 0;
            
            if (hasNotice) {
                //공지
                UIButton *noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [noticeButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 40)];
                [noticeButton setBackgroundColor:[UIColor whiteColor]];
                [noticeButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
                [noticeButton addTarget:self action:@selector(touchNoticeButton:) forControlEvents:UIControlEventTouchUpInside];
                [footerView addSubview:noticeButton];
                
                UIImageView *noticeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noticeButton.frame)-17, (CGRectGetHeight(noticeButton.frame)-12)/2, 7, 12)];
                [noticeImageView setImage:[UIImage imageNamed:@"ic_notice_arrow.png"]];
                [noticeButton addSubview:noticeImageView];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, CGRectGetHeight(noticeButton.frame))];
                [titleLabel setText:@"공지"];
                [titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
                [titleLabel setBackgroundColor:[UIColor clearColor]];
                [titleLabel setTextColor:UIColorFromRGB(0x333333)];
                [titleLabel setTextAlignment:NSTextAlignmentCenter];
                [noticeButton addSubview:titleLabel];
                
                UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, kScreenBoundsWidth-40-17, CGRectGetHeight(noticeButton.frame))];
                [noticeLabel setText:footerInfo[@"notice"][@"title"]];
                [noticeLabel setFont:[UIFont systemFontOfSize:12]];
                [noticeLabel setBackgroundColor:[UIColor clearColor]];
                [noticeLabel setTextAlignment:NSTextAlignmentLeft];
                [noticeLabel setTextColor:UIColorFromRGB(0x666666)];
                [noticeButton addSubview:noticeLabel];
                
                loginButtonY = CGRectGetMaxY(noticeButton.frame);
            }
            
            //버튼
            UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [loginButton setTag:CPFooterButtonTypeLogin];
            [loginButton setFrame:CGRectMake(0, loginButtonY, (int)kScreenBoundsWidth/4, 40)];
            [loginButton setTitle:([Modules checkLoginFromCookie] ? @"로그아웃" : @"로그인") forState:UIControlStateNormal];
            [loginButton setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateNormal];
            [loginButton setBackgroundImage:[UIImage imageNamed:@"bg_555555.png"] forState:UIControlStateNormal];
            [loginButton setBackgroundImage:[UIImage imageNamed:@"bg_2a2a2a.png"] forState:UIControlStateHighlighted];
            [loginButton addTarget:self action:@selector(touchFooterButton:) forControlEvents:UIControlEventTouchUpInside];
            [loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [footerView addSubview:loginButton];
            
            UIView *loginLine = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/4-1, 0, 1, CGRectGetHeight(loginButton.frame))];
            [loginLine setBackgroundColor:UIColorFromRGB(0x666666)];
            [loginButton addSubview:loginLine];
            
            UIButton *pcVersionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [pcVersionButton setTag:CPFooterButtonTypePCVersion];
            [pcVersionButton setFrame:CGRectMake(CGRectGetMaxX(loginButton.frame), CGRectGetMinY(loginButton.frame), (int)kScreenBoundsWidth/4, 40)];
            [pcVersionButton setTitle:@"PC버전" forState:UIControlStateNormal];
            [pcVersionButton setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateNormal];
            [pcVersionButton setBackgroundImage:[UIImage imageNamed:@"bg_555555.png"] forState:UIControlStateNormal];
            [pcVersionButton setBackgroundImage:[UIImage imageNamed:@"bg_2a2a2a.png"] forState:UIControlStateHighlighted];
            [pcVersionButton addTarget:self action:@selector(touchFooterButton:) forControlEvents:UIControlEventTouchUpInside];
            [pcVersionButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [footerView addSubview:pcVersionButton];
            
            UIView *pcVersionLine = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/4-1, 0, 1, CGRectGetHeight(pcVersionButton.frame))];
            [pcVersionLine setBackgroundColor:UIColorFromRGB(0x666666)];
            [pcVersionButton addSubview:pcVersionLine];
            
            UIButton *customerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [customerButton setTag:CPFooterButtonTypeCustomer];
            [customerButton setFrame:CGRectMake(CGRectGetMaxX(pcVersionButton.frame), CGRectGetMinY(loginButton.frame), (int)kScreenBoundsWidth/4, 40)];
            [customerButton setTitle:@"고객센터" forState:UIControlStateNormal];
            [customerButton setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateNormal];
            [customerButton setBackgroundImage:[UIImage imageNamed:@"bg_555555.png"] forState:UIControlStateNormal];
            [customerButton setBackgroundImage:[UIImage imageNamed:@"bg_2a2a2a.png"] forState:UIControlStateHighlighted];
            [customerButton addTarget:self action:@selector(touchFooterButton:) forControlEvents:UIControlEventTouchUpInside];
            [customerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [footerView addSubview:customerButton];
            
            UIView *customerLine = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/4-1, 0, 1, CGRectGetHeight(customerButton.frame))];
            [customerLine setBackgroundColor:UIColorFromRGB(0x666666)];
            [customerButton addSubview:customerLine];
            
            UIButton *allServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [allServiceButton setTag:CPFooterButtonTypeAllService];
            [allServiceButton setFrame:CGRectMake(CGRectGetMaxX(customerButton.frame), CGRectGetMinY(loginButton.frame), (int)kScreenBoundsWidth/4+2, 40)];
            [allServiceButton setTitle:@"전체서비스" forState:UIControlStateNormal];
            [allServiceButton setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateNormal];
            [allServiceButton setBackgroundImage:[UIImage imageNamed:@"bg_555555.png"] forState:UIControlStateNormal];
            [allServiceButton setBackgroundImage:[UIImage imageNamed:@"bg_2a2a2a.png"] forState:UIControlStateHighlighted];
            [allServiceButton addTarget:self action:@selector(touchFooterButton:) forControlEvents:UIControlEventTouchUpInside];
            [allServiceButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [footerView addSubview:allServiceButton];
            
            
            //하단 정보영역
            UIView *infoView = [[UIView alloc] initWithFrame:CGRectZero];
            [infoView setBackgroundColor:UIColorFromRGB(0x888888)];
            [footerView addSubview:infoView];
            
            NSString *svcTelStr = @"";
            
            BOOL isDoubleLabel = !(IS_IPAD || IS_IPHONE_6);
            
            if (IS_IPAD) {
                svcTelStr = [NSString stringWithFormat:@"%@\n %@ %@", footerInfo[@"info"][@"text1"], footerInfo[@"info"][@"tel"], footerInfo[@"info"][@"email"]];
            }
            else if (IS_IPHONE_6PLUS) {
                svcTelStr = footerInfo[@"info"][@"text1"];
            }
            else if (IS_IPHONE_6) {
                svcTelStr = [NSString stringWithFormat:@"%@%@ %@", footerInfo[@"info"][@"text1"], footerInfo[@"info"][@"tel"], footerInfo[@"info"][@"email"]];
            }
            else {
                svcTelStr = [NSString stringWithFormat:@"%@%@", footerInfo[@"info"][@"text1"], footerInfo[@"info"][@"tel"]];
            }
            
            TTTAttributedLabel *svcTelLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
            [svcTelLabel setDelegate:self];
            [svcTelLabel setFont:[UIFont systemFontOfSize:10.8f]];
            [svcTelLabel setBackgroundColor:[UIColor clearColor]];
            [svcTelLabel setTextColor:UIColorFromRGB(0xdddddd)];
            [svcTelLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [svcTelLabel setNumberOfLines:0];
            [svcTelLabel setTextAlignment:NSTextAlignmentCenter];
            [svcTelLabel setVerticalAlignment:TTTAttributedLabelVerticalAlignmentTop];
            [svcTelLabel setText:svcTelStr];
            if (!IS_IPHONE_6) {
                [svcTelLabel addLinkToPhoneNumber:footerInfo[@"info"][@"tel"] withRange:[svcTelLabel.text rangeOfString:footerInfo[@"info"][@"tel"]]];
            }
            if (IS_IPAD || IS_IPHONE_6PLUS) {
                [svcTelLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", footerInfo[@"info"][@"email"]]] withRange:[svcTelLabel.text rangeOfString:footerInfo[@"info"][@"email"]] noUnderLine:YES];
            }
            [svcTelLabel sizeToFit];
            [infoView addSubview:svcTelLabel];
            
            CGSize size = [svcTelLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(kScreenBoundsWidth-40, 10000) lineBreakMode:svcTelLabel.lineBreakMode];
            [svcTelLabel setFrame:CGRectMake(20, 20, kScreenBoundsWidth-40, size.height)];
            
            if (isDoubleLabel) {
                
                TTTAttributedLabel *doubleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
                [doubleLabel setDelegate:self];
                [doubleLabel setFont:[UIFont systemFontOfSize:10.8f]];
                [doubleLabel setBackgroundColor:[UIColor clearColor]];
                [doubleLabel setTextColor:UIColorFromRGB(0xdddddd)];
                [doubleLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [doubleLabel setNumberOfLines:0];
                [doubleLabel setTextAlignment:NSTextAlignmentCenter];
                
                if (IS_IPHONE_6PLUS) {
                    [doubleLabel setText:[NSString stringWithFormat:@"%@ %@", footerInfo[@"info"][@"tel"], footerInfo[@"info"][@"email"]]];
                    [doubleLabel addLinkToPhoneNumber:footerInfo[@"info"][@"tel"] withRange:[doubleLabel.text rangeOfString:footerInfo[@"info"][@"tel"]]];
                    [doubleLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", footerInfo[@"info"][@"email"]]] withRange:[doubleLabel.text rangeOfString:footerInfo[@"info"][@"email"]] noUnderLine:YES];
                }
                else {
                    [doubleLabel setText:footerInfo[@"info"][@"email"]];
                    [doubleLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", footerInfo[@"info"][@"email"]]] withRange:[doubleLabel.text rangeOfString:footerInfo[@"info"][@"email"]] noUnderLine:YES];
                }
                
                [doubleLabel sizeToFit];
                size = [doubleLabel.text sizeWithFont:[UIFont systemFontOfSize:10.8f] constrainedToSize:CGSizeMake(10000, 13) lineBreakMode:doubleLabel.lineBreakMode];
                [doubleLabel setFrame:CGRectMake((kScreenBoundsWidth-size.width)/2, CGRectGetMaxY(svcTelLabel.frame)-14, size.width, 13)];
                [infoView addSubview:doubleLabel];
            }
            
            NSArray *linkItems = footerInfo[@"linkItems"];
            UIView *footerButtonAreaView = [[UIView alloc] initWithFrame:CGRectZero];
            [infoView addSubview:footerButtonAreaView];
            
            CGFloat buttonX = 0;
            
            for (NSDictionary *dic in linkItems) {
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setTag:[linkItems indexOfObject:dic]];
                [button setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
                [button setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setBackgroundImage:[UIImage imageNamed:@"bg_676767.png"] forState:UIControlStateHighlighted];
                [button.titleLabel setFont:[UIFont systemFontOfSize:10.8f]];
                [button addTarget:self action:@selector(touchFooterInfoButton:) forControlEvents:UIControlEventTouchUpInside];
                [footerButtonAreaView addSubview:button];
                
                if ([linkItems indexOfObject:dic] == 2 && [@"개인정보취급방침" isEqualToString:[dic objectForKey:@"title"]]) {
                    [button setTitle:[NSString stringWithFormat:@"%@ >", [dic objectForKey:@"title"]] forState:UIControlStateNormal];
                    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10.8f]];
                }
                
                size = [button.titleLabel.text sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(10000, 10.8f) lineBreakMode:button.titleLabel.lineBreakMode];
                [button setFrame:CGRectMake(buttonX+15, 0, size.width, 15)];
                
                if ([linkItems indexOfObject:dic] != linkItems.count-1) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame)+7, 0, 1, CGRectGetHeight(button.frame))];
                    [label setText:@"|"];
                    [label setTextColor:UIColorFromRGB(0xdddddd)];
                    [label setBackgroundColor:[UIColor clearColor]];
                    [label setFont:[UIFont systemFontOfSize:10.8f]];
                    [footerButtonAreaView addSubview:label];
                }
                
                buttonX += size.width+15;
            }
            
            [footerButtonAreaView setFrame:CGRectMake((kScreenBoundsWidth-buttonX-5)/2, isDoubleLabel?CGRectGetMaxY(svcTelLabel.frame)+13:CGRectGetMaxY(svcTelLabel.frame), buttonX-5, 15)];
            
            NSString *copyright = [footerInfo[@"info"][@"copyright"] stringByReplacingOccurrencesOfString:@"&copy;" withString:@"©"];
            
            UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [copyrightLabel setFont:[UIFont systemFontOfSize:11]];
            [copyrightLabel setTextColor:UIColorFromRGB(0xdddddd)];
            [copyrightLabel setBackgroundColor:[UIColor clearColor]];
            [copyrightLabel setTextAlignment:NSTextAlignmentCenter];
            [copyrightLabel setNumberOfLines:0];
            [copyrightLabel setText:[NSString stringWithFormat:@"%@\r\r%@", footerInfo[@"info"][@"text2"], copyright]];
            [infoView addSubview:copyrightLabel];
            
            size = [copyrightLabel.text sizeWithFont:copyrightLabel.font constrainedToSize:CGSizeMake(kScreenBoundsWidth-40, 10000) lineBreakMode:copyrightLabel.lineBreakMode];
            [copyrightLabel setFrame:CGRectMake(20, CGRectGetMaxY(footerButtonAreaView.frame)+10, kScreenBoundsWidth-40, size.height)];
            
            [infoView setFrame:CGRectMake(0, CGRectGetMaxY(loginButton.frame), kScreenBoundsWidth, CGRectGetMaxY(copyrightLabel.frame)+60)];
            [footerView setFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetMaxY(infoView.frame))];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLoginStatus) name:@"reloadLoginStatus" object:nil];
        }
        
        self.width = CGRectGetWidth(footerView.frame);
        self.height = CGRectGetHeight(footerView.frame);
    }
    return self;
}

- (void)onCustomerCenterCall
{
    if ([[DEVICE_MODEL lowercaseString] indexOf:@"phone"] < 0)
    {
        return [Modules alert:NSLocalizedString(@"AlertTitleCall", nil) message:NSLocalizedString(@"NoConnectCall", nil)];
    }
    
    [UIAlertView showWithTitle:NSLocalizedString(@"AlertTitle", nil)
                       message:NSLocalizedString(@"AlertMsgConnectCallCenter", nil)
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
             otherButtonTitles:@[ NSLocalizedString(@"AlertTitleCall", nil) ]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (alertView.cancelButtonIndex != buttonIndex)
                          {
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", footerInfo[@"info"][@"tel"]]]];
                          }
                      }];
}

#pragma mark - Public

- (void)reloadLoginStatus
{
    for (UIButton *subview in [footerView subviews]) {
        if (subview.tag == CPFooterButtonTypeLogin) {
            [subview setTitle:([Modules checkLoginFromCookie] ? @"로그아웃" : @"로그인") forState:UIControlStateNormal];
            break;
        }
    }
}

#pragma mark - Selectors

//footer 공지 버튼
- (void)touchNoticeButton:(id)sender
{
    NSString *footerNoticeUrl = footerInfo[@"notice"][@"url"];
    [self openFooterButtonWithUrl:footerNoticeUrl animated:YES];
}

//footer 버튼
- (void)touchFooterButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *buttonUrl;
    BOOL animated = NO;
    
    if (button.tag == CPFooterButtonTypeLogin) {
        if ([Modules checkLoginFromCookie]) {
            buttonUrl = [[CPCommonInfo sharedInfo] urlInfo][@"logout"];
            animated = YES;
        }
        else {
            [self touchLoginButton];
            return;
        }
    }
    else if (button.tag == CPFooterButtonTypeCustomer) {
        buttonUrl = [[CPCommonInfo sharedInfo] urlInfo][@"cvcenter"];
        animated = YES;
    }
    else if (button.tag == CPFooterButtonTypePCVersion) {
        buttonUrl = [[CPCommonInfo sharedInfo] urlInfo][@"pc"];
        animated = NO;
    }
    else if (button.tag == CPFooterButtonTypeAllService) {
        buttonUrl = [[CPCommonInfo sharedInfo] urlInfo][@"category"];
        animated = YES;
    }
    
    [self openFooterButtonWithUrl:[buttonUrl trim] animated:animated];
}

- (void)openFooterButtonWithUrl:(NSString *)url animated:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
    
    if (homeViewController && [homeViewController respondsToSelector:@selector(openWebViewControllerWithUrl:animated:)]) {
        [homeViewController openWebViewControllerWithUrl:url animated:animated];
    }
}

//footerInfo 버튼
- (void)touchFooterInfoButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSArray *linkItems = footerInfo[@"linkItems"];
    NSString *footerInfoUrl;
    
    //현재 json정보를 이용해서는 순서대로 정보가 넘어온다는 가정하에 코딩할수밖에 없음
    footerInfoUrl = linkItems[button.tag][@"url"];
    BOOL isAnimation = button.tag == 0;
    
    [self openFooterButtonWithUrl:footerInfoUrl animated:isAnimation];
}

- (void)touchLoginButton
{
    [self openLoginViewController];
}

- (void)openLoginViewController
{
    NSString *loginUrl = [[CPCommonInfo sharedInfo] urlInfo][@"login"];
    NSString *loginUrlString = [Modules urlWithQueryString:loginUrl];
    
    CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
    [popViewController setTitle:@"로그인"];
    [popViewController setIsLoginType:YES];
    [popViewController setRequestUrl:loginUrlString];
    [popViewController setDelegate:self];
    [popViewController initLayout];
    
    if (self.parentViewController) {
        [self.parentViewController presentViewController:popViewController animated:YES completion:nil];
    }
    else {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([homeViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [homeViewController presentViewController:popViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - CPPopupViewControllerDelegate

- (void)popupViewControllerDidSuccessLogin
{
    //로그인하면 popupViewControllerAfterSuccessLogin 도 호출되기때문에 아무것도 하지 않는다.
}

- (void)popupViewControllerAfterSuccessLogin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLoginStatus" object:nil];
    
    if ([self.delegate respondsToSelector:@selector(reloadAfterLogin)]) {
        [self.delegate reloadAfterLogin];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *phoneNumUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]];
    
    if([[UIApplication sharedApplication] canOpenURL:phoneNumUrl])
    {
        [[UIApplication sharedApplication] openURL:phoneNumUrl];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", footerInfo[@"info"][@"email"]]]];
}

@end
