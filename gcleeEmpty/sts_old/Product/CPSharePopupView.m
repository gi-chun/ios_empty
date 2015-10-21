//
//  CPSharePopupView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPSharePopupView.h"
#import "KakaoLinkCenter.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "AccessLog.h"

@interface CPSharePopupView()
{
    NSDictionary *product;
    NSDictionary *shareInfo;
    
    CGFloat itemHeight;
}

@end


@implementation CPSharePopupView

- (void)releaseItem
{
    if (product) product = nil;
    if (shareInfo) shareInfo = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
//        if (product[@"prdLike"]) {
//            shareInfo = [product[@"prdLike"] copy];
//            
//            [self initLayout];
//        }
        
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];
//    [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.8f)];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"layer_pd_popup_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImageView *containerView = [[UIImageView alloc] initWithFrame:CGRectMake(13.5f, 0, CGRectGetWidth(self.frame)-27, 260)];
    [containerView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [containerView setImage:backgroundImage];
    [containerView setUserInteractionEnabled:YES];
    [self addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 150, 42)];
    [titleLabel setText:@"공유하기"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:titleLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(CGRectGetWidth(containerView.frame)-42, 0, 42, 42)];
    [closeButton setImage:[UIImage imageNamed:@"ic_pd_popup_close.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:closeButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(2, 41, CGRectGetWidth(self.frame)-31, 1)];
    [lineView setBackgroundColor:UIColorFromRGBA(0xafb0c2, 0.3f)];
    [containerView addSubview:lineView];
    
    CGFloat buttonWidth = (CGRectGetWidth(containerView.frame)-12)/3;
    
    //카카오톡
    NSString *title = @"카카오톡";
    UIImage *imageNormal = [UIImage imageNamed:@"ic_share_kakaotalk.png"];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(6, CGRectGetMaxY(titleLabel.frame), buttonWidth, 106)];
    [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
    [menuButton setImage:imageNormal forState:UIControlStateNormal];
    [menuButton setTitle:title forState:UIControlStateNormal];
    [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [menuButton addTarget:self action:@selector(touchKakaotalkButton) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:menuButton];
    
    CGSize imageSize = imageNormal.size;
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    CGFloat totalHeight = (imageSize.height + titleSize.height + 6);
    [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
    [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
    
    //카카오스토리
    title = @"카카오스토리";
    imageNormal = [UIImage imageNamed:@"ic_share_kakaostory.png"];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(6+buttonWidth, CGRectGetMaxY(titleLabel.frame), buttonWidth, 106)];
    [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
    [menuButton setImage:imageNormal forState:UIControlStateNormal];
    [menuButton setTitle:title forState:UIControlStateNormal];
    [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [menuButton addTarget:self action:@selector(touchKakaostoryButton) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:menuButton];
    
    imageSize = imageNormal.size;
    titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    totalHeight = (imageSize.height + titleSize.height + 6);
    [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
    [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
    
    //facebook
    title = @"페이스북";
    imageNormal = [UIImage imageNamed:@"ic_share_facebook.png"];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(6+buttonWidth*2, CGRectGetMaxY(titleLabel.frame), buttonWidth, 106)];
    [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
    [menuButton setImage:imageNormal forState:UIControlStateNormal];
    [menuButton setTitle:title forState:UIControlStateNormal];
    [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [menuButton addTarget:self action:@selector(touchFacebookButton) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:menuButton];
    
    imageSize = imageNormal.size;
    titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    totalHeight = (imageSize.height + titleSize.height + 6);
    [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
    [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
    
    //iPad는 SMS제외
    if (IS_IPAD) {
        //URL복사
        title = @"URL복사";
        imageNormal = [UIImage imageNamed:@"ic_share_url.png"];
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(6, CGRectGetMaxY(titleLabel.frame)+106, buttonWidth, 106)];
        [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [menuButton setImage:imageNormal forState:UIControlStateNormal];
        [menuButton setTitle:title forState:UIControlStateNormal];
        [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [menuButton addTarget:self action:@selector(touchURLButton) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:menuButton];
        
        imageSize = imageNormal.size;
        titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
        totalHeight = (imageSize.height + titleSize.height + 6);
        [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
        [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
    }
    else {
        //SMS
        title = @"SMS";
        imageNormal = [UIImage imageNamed:@"ic_share_sms.png"];
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(6, CGRectGetMaxY(titleLabel.frame)+106, buttonWidth, 106)];
        [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [menuButton setImage:imageNormal forState:UIControlStateNormal];
        [menuButton setTitle:title forState:UIControlStateNormal];
        [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [menuButton addTarget:self action:@selector(touchSMSButton) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:menuButton];
        
        imageSize = imageNormal.size;
        titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
        totalHeight = (imageSize.height + titleSize.height + 6);
        [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
        [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
        
        //URL복사
        title = @"URL복사";
        imageNormal = [UIImage imageNamed:@"ic_share_url.png"];
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setFrame:CGRectMake(6+buttonWidth, CGRectGetMaxY(titleLabel.frame)+106, buttonWidth, 106)];
        [menuButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        [menuButton setImage:imageNormal forState:UIControlStateNormal];
        [menuButton setTitle:title forState:UIControlStateNormal];
        [menuButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [menuButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [menuButton addTarget:self action:@selector(touchURLButton) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:menuButton];
        
        imageSize = imageNormal.size;
        titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
        totalHeight = (imageSize.height + titleSize.height + 6);
        [menuButton setImageEdgeInsets:UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0, 0, - titleSize.width)];
        [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height),0)];
    }
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    [self removeFromSuperview];
}

- (void)touchKakaotalkButton
{
    if (![KOAppCall canOpenKakaoTalkAppLink]) {
        DEFAULT_ALERT(@"공유하기", @"카카오톡이 설치되어 있지 않습니다.");
        
        return;
    }
    
    NSString *labelString = [NSString stringWithFormat:@"[11번가]\n\n%@\n%@", self.shareTitle, self.shareUrl];
    
    KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:labelString];
    
    KakaoTalkLinkAction *androidAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                                                      devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                       execparam:@{@"executeurl":self.shareUrl}];
    KakaoTalkLinkAction *iphoneAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                                                     devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                      execparam:@{@"executeurl":self.shareUrl}];
    KakaoTalkLinkObject *buttonObj = [KakaoTalkLinkObject createAppButton:@"앱으로 연결"
                                                                  actions:@[androidAppAction, iphoneAppAction]];
    
    
    NSMutableDictionary *kakaoTalkLinkObjects = [@{@"label":label, @"button":buttonObj} mutableCopy];
    
    [KOAppCall openKakaoTalkAppLink:[kakaoTalkLinkObjects allValues]];
    
    //AccessLog - 카카오톡
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH04"];
}

- (void)touchKakaostoryButton
{
    if (![KakaoLinkCenter canOpenStoryLink]) {
        DEFAULT_ALERT(@"공유하기", @"카카오스토리가 설치되어 있지 않습니다.");
        
        return;
    }
    
    [KakaoLinkCenter openStoryLinkWithPost:[NSString stringWithFormat:@"[11번가]%@ %@", self.shareTitle, self.shareUrl]
                               appBundleID:[[NSBundle mainBundle] bundleIdentifier]
                                appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                   appName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] urlInfo:nil];
    
    //AccessLog - 카카오스토리
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH05"];
}

- (void)touchFacebookButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchFacebookButton)]) {
        [self.delegate didTouchFacebookButton];
    }
    
    //AccessLog - 페이스북
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH07"];
}

- (void)touchURLButton
{
    NSString *productUrl = PRODUCT_DETAIL_WEB_URL;
    productUrl = [productUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:[product[@"prdNo"] stringValue]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:productUrl];
    
    DEFAULT_ALERT(@"공유하기", @"URL이 복사되었습니다.");
    
    //AccessLog - URL복사
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH09"];
}

- (void)touchSMSButton
{
    if ([self.delegate respondsToSelector:@selector(didTouchSMSButton)]) {
        [self.delegate didTouchSMSButton];
    }
    
    //AccessLog - SMS보내기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPH08"];
}

@end
