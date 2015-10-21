//
//  CPProductWebView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductWebView.h"
#import "CMDQueryStringSerialization.h"
#import "RegexKitLite.h"

static NSString *const kProductOptionDetailViewOptionCloseScheme = @"app://smart_option/close";
static NSString *const kProductOptionDetailViewOptionInsertScheme = @"app://smart_option/insert?";

@interface CPProductWebView() <UIWebViewDelegate>
{
    NSDictionary *popupInfo;
    
    UIWebView *productWebView;
    
    UIView *headerView;
    
    UIButton *backButton;
    UIButton *forwardButton;
    UIButton *refreshButton;
}

@end

@implementation CPProductWebView

- (id)initWithFrame:(CGRect)frame popupInfo:(NSDictionary *)aPopupInfo
{
    if (self = [super initWithFrame:frame]) {
        
        popupInfo = [aPopupInfo copy];
        
        [self initLayout];
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.7f)];
    
    if ([popupInfo[@"key"] isEqualToString:@"coupon"] || [popupInfo[@"key"] isEqualToString:@"smartOption"] ) {
        headerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:headerView];
    }
    else {
        UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 40)];
        [cornerImageView setImage:[UIImage imageNamed:@"layer_wv_top.png"]];
        [self addSubview:cornerImageView];
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(52, 0, CGRectGetWidth(self.frame)-52, 40)];
        [headerView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
        [self addSubview:headerView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, CGRectGetWidth(headerView.frame)-(3+40+10), 40)];
        [titleLabel setText:popupInfo[@"title"]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [titleLabel setTextColor:UIColorFromRGB(0x333333)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:titleLabel];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(CGRectGetWidth(headerView.frame)-40, 0, 40, 40)];
        [closeButton setImage:[UIImage imageNamed:@"ic_wv_close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:closeButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, CGRectGetWidth(self.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xd9d9d9)];
        [self addSubview:lineView];
    }
    
    //웹뷰
    productWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(headerView.frame),
                                                               CGRectGetWidth(self.frame),
                                                               CGRectGetHeight(self.frame)-CGRectGetHeight(headerView.frame))];
    [productWebView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [productWebView setDelegate:self];
    [productWebView setScalesPageToFit:YES];
    [productWebView.scrollView setScrollsToTop:YES];
    [self addSubview:productWebView];
    
    NSURL *encodingUrl = [NSURL URLWithString:[popupInfo[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [productWebView loadRequest:[NSURLRequest requestWithURL:encodingUrl]];
    
    //버튼
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(10, CGRectGetHeight(self.frame)-50, 41, 42)];
    [backButton setImage:[UIImage imageNamed:@"bt_wv_back_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"bt_wv_back_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardButton setFrame:CGRectMake(CGRectGetMaxX(backButton.frame)+13, CGRectGetHeight(self.frame)-50, 41, 42)];
    [forwardButton setImage:[UIImage imageNamed:@"bt_wv_forward_nor.png"] forState:UIControlStateNormal];
    [forwardButton setImage:[UIImage imageNamed:@"bt_wv_forward_press.png"] forState:UIControlStateHighlighted];
    [forwardButton addTarget:self action:@selector(touchFowardButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:forwardButton];
    
    refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setFrame:CGRectMake(CGRectGetWidth(self.frame)-51, CGRectGetHeight(self.frame)-50, 41, 42)];
    [refreshButton setImage:[UIImage imageNamed:@"bt_wv_refresh_nor.png"] forState:UIControlStateNormal];
    [refreshButton setImage:[UIImage imageNamed:@"bt_wv_refresh_press.png"] forState:UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(touchRefreshButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshButton];
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    CGRect frame = self.frame;
    frame.origin.x += kScreenBoundsWidth;
//    frame.origin.y += kScreenBoundsHeight;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self setFrame:frame];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(didTouchWebViewClose)]) {
            [self.delegate didTouchWebViewClose];
        }
    }];
}

- (void)touchBackButton
{
    if ([productWebView canGoBack]) {
        [productWebView goBack];
    }
    else {
        [self touchCloseButton];
    }
}

- (void)touchFowardButton
{
    [productWebView goForward];
}

- (void)touchRefreshButton
{
    [productWebView reload];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request.url : %@", request.URL.absoluteString);
    NSString *url = request.URL.absoluteString;
    
    if ([url hasPrefix:@"app://coupon_popup_close"]) {
        [self touchCloseButton];
        return NO;
    }
    
    //쿠폰
    if ([url hasPrefix:@"app://coupon_popup"]) {
        // deal://coupon_popup?applyJson=%7B%22resultCode%22%3A200%2C%22result%22%3A%5B%7B%22STOCK_NO%22%3A%224550108392%22%2C%22ADD_ISS_CUPN_NO%22%3A1211520838%2C%22ADD_DSC_AMT%22%3A900%7D%5D%7D
        NSDictionary *parseInfo = [CMDQueryStringSerialization dictionaryWithQueryString:url];
        NSString *resultString = nil;
        for (NSString *key in parseInfo.allKeys) {
            if ([key hasPrefix:@"app://coupon_popup"]) {
                resultString = parseInfo[key];
                break;
            }
        }
        
        if (resultString == nil) {
            [self touchCloseButton];
            return NO;
        }
        
        NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            [self touchCloseButton];
            return NO;
        }
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (jsonDict == nil) {
            [self touchCloseButton];
            return NO;
        }
        
        NSArray *coupons = [jsonDict[@"result"] copy];
        
        if ([self.delegate respondsToSelector:@selector(didSelectedOptions:)]) {
            [self.delegate didSelectedOptions:coupons];
            [self touchCloseButton];
        }
        
        return NO;
    }
    
    //장바구니 이동등
    if ([url hasPrefix:@"app://popupBrowser/close"]) {
        [self touchCloseButton];
        
        if ([self.delegate respondsToSelector:@selector(productWebViewOpenUrlScheme:)]) {
            [self.delegate productWebViewOpenUrlScheme:request.URL.absoluteString];
        }
        
        return NO;
    }
    
    // 옵션 담기
    if ([url hasPrefix:kProductOptionDetailViewOptionInsertScheme]) {
        
        NSString *queryString = [url substringFromIndex:kProductOptionDetailViewOptionInsertScheme.length];
        NSDictionary *queryDict = [CMDQueryStringSerialization dictionaryWithQueryString:queryString];
        NSString *optionName = queryDict[@"optionNm"];
        
        if (optionName && optionName.length > 0) {
            if ([self.delegate respondsToSelector:@selector(smartOptionDidClickedOptionSelectButtonAtOptionName:)]) {
                [self.delegate smartOptionDidClickedOptionSelectButtonAtOptionName:optionName];
            }
            return NO;
        }
    }
    
    // 옵션 닫기
    if ([url hasPrefix:kProductOptionDetailViewOptionCloseScheme]) {
        [self touchCloseButton];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [forwardButton setEnabled:[webView canGoForward]];
}

@end
