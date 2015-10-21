//
//  CPCommonLayerPopupView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCommonLayerPopupView.h"
#import "KakaoLinkCenter.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface CPCommonLayerPopupView() <UIWebViewDelegate>
{
    NSString *title;
    NSString *linkUrl;
    
    UIImageView *containerView;
    UIWebView *aWebview;
}

@end


@implementation CPCommonLayerPopupView

- (void)releaseItem
{
    if (title) title = nil;
    if (linkUrl) linkUrl = nil;
    if (containerView) containerView = nil;
    if (aWebview) [aWebview stopLoading], aWebview = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)aTitle linkUrl:(NSString *)aLinkUrl
{
    if (self = [super initWithFrame:frame]) {
        
        title = [aTitle copy];
        
        if (aLinkUrl) {
            linkUrl = [aLinkUrl copy];
            
            [self initLayout];
        }
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"layer_pd_popup_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsHeight)];
    [contentView setUserInteractionEnabled:YES];
    [self addSubview:contentView];
    
    containerView = [[UIImageView alloc] initWithFrame:CGRectMake(13.5f, 0, CGRectGetWidth(self.frame)-27, 260)];
    [containerView setCenter:CGPointMake(kScreenBoundsWidth/2, kScreenBoundsHeight/2)];
    [containerView setImage:backgroundImage];
    [containerView setUserInteractionEnabled:YES];
    [contentView addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, kScreenBoundsWidth-42, 42)];
    [titleLabel setText:title];
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
    
    aWebview = [[UIWebView alloc] initWithFrame:CGRectMake(2.5f, CGRectGetMaxY(lineView.frame), containerView.frame.size.width-5.f, 0)];
    aWebview.delegate = self;
    aWebview.clipsToBounds = NO;
    aWebview.scalesPageToFit = YES;
    aWebview.scrollView.scrollsToTop = NO;
    [containerView addSubview:aWebview];
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    [self removeFromSuperview];
}

#pragma mark - webview

- (void)openUrl:(NSString *)url
{
    [aWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)stopLoading
{
    [aWebview stopLoading];
}

- (void)setScrollTop
{
    [aWebview.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [aWebview.scrollView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [aWebview.scrollView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [aWebview.scrollView setShowsVerticalScrollIndicator:isShow];
}


#pragma mark - UIWebViewDelegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:YES]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ", (int)(containerView.frame.size.width-5.f)]];
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    BOOL isScroll = (kScreenBoundsHeight-120) < (webView.frame.size.height+53);
    CGFloat viewHeight = isScroll ? (kScreenBoundsHeight-120) : (webView.frame.size.height+53);
    
    if (isScroll) frame.size.height = viewHeight-48;
    aWebview.frame = frame;
    [containerView setFrame:CGRectMake(13.5f, (kScreenBoundsHeight-120-viewHeight)/2, CGRectGetWidth(self.frame)-27, viewHeight)];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
    [self touchCloseButton];
}

@end
