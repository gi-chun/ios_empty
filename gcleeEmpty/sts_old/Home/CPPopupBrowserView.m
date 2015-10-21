//
//  CPPopupBrowserView.m
//  11st
//
//  Created by spearhead on 2014. 9. 12..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPPopupBrowserView.h"
#import "CPProductOption.h"
#import "RegexKitLite.h"

@interface CPPopupBrowserView() <UIWebViewDelegate,
                                CPProductOptionDelegate>
{
    NSDictionary *popupInfo;
    UIWebView *popupWebView;
	CPProductOption *productView;
	
	UIView *toolbarView;
	
    UIButton *backButton;
    UIButton *forwardButton;
	UIButton *toggleButton;
	UIButton *onToggleButton;
	UIButton *topButton;
}

@end

@implementation CPPopupBrowserView

- (id)initWithFrame:(CGRect)frame popupInfo:(NSDictionary *)aPopupInfo executeWebView:(CPWebView *)webview
{
    self = [super initWithFrame:frame];
    if (self) {
        
        popupInfo = aPopupInfo;
		self.executeWebView = webview;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 40)];
        [titleView setBackgroundColor:UIColorFromRGB(0xededee)];
        [self addSubview:titleView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, CGRectGetWidth(frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xd3d3d6)];
        [self addSubview:lineView];
        
        NSString *title;
        if (popupInfo[@"title"] && [[popupInfo[@"title"] trim] length] > 0) {
			title = popupInfo[@"title"];
		}
		else {
			title = popupInfo[@"url"];
		}
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(frame)-60, 40)];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:title];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleView addSubview:titleLabel];

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(CGRectGetWidth(frame)-40, 0, 40, 40)];
        [closeButton setImage:[UIImage imageNamed:@"popupBrowser_smclose_nor.png"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"popupBrowser_smclose_press.png"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setAccessibilityLabel:@"닫기" Hint:@"화면을 닫습니다"];
        [titleView addSubview:closeButton];
        
        popupWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
																   CGRectGetMaxY(titleView.frame),
																   CGRectGetWidth(frame),
																   CGRectGetHeight(frame)-titleView.frame.size.height-kToolBarHeight)];
        [popupWebView setBackgroundColor:UIColorFromRGB(0xffffff)];
        [popupWebView setDelegate:self];
		[popupWebView setScalesPageToFit:YES];
        [popupWebView.scrollView setScrollsToTop:YES];
        [self addSubview:popupWebView];
        
        NSURL *encodingUrl = [NSURL URLWithString:[popupInfo[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [popupWebView loadRequest:[NSURLRequest requestWithURL:encodingUrl]];
		
        NSString *control = popupInfo[@"controls"];
		NSArray *controls = [control componentsSeparatedByString:@"|"];
		
		BOOL isHistory = NO;
		BOOL isTop = NO;
//		BOOL isClose = NO;
//		BOOL isOption = NO;
		BOOL isInsetzero = NO;
		
		//insetzero는 패션카탈로그일 경우에만 나타난다. (아이폰만 있음, 안드로이드는 나타나지 않음.)
		for (NSString *control in controls) {
			if ([@"history" isEqualToString:control])	isHistory = YES;
			if ([@"top" isEqualToString:control])		isTop = YES;
//			if ([@"close" isEqualToString:control])		isClose = YES;
//			if ([@"option" isEqualToString:control])	isOption = YES;
			if ([@"insetzero" isEqualToString:control])	isInsetzero = YES;
		}
        
		if (!isInsetzero) {
			toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(popupWebView.frame), kScreenBoundsWidth, kToolBarHeight)];
			toolbarView.backgroundColor = [UIColor whiteColor];
			[self addSubview:toolbarView];
			
			UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 0.5f)];
			[lineView setBackgroundColor:UIColorFromRGB(0x666666)];
			[toolbarView addSubview:lineView];
			
			CGFloat buttonWidth = kScreenBoundsWidth / 5;
			CGFloat buttonHeight = kToolBarHeight;
			
			CGFloat buttonX = 0.f;
			
			if (isHistory) {
				//백버튼
				backButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[backButton setImage:[UIImage imageNamed:@"icon_tabbar_02back_nor.png"] forState:UIControlStateNormal];
				[backButton setImage:[UIImage imageNamed:@"icon_tabbar_02back_highlighted.png"] forState:UIControlStateHighlighted];
				[backButton setImage:[UIImage imageNamed:@"icon_tabbar_02back_disable.png"] forState:UIControlStateDisabled];
				[backButton setFrame:CGRectMake(buttonX, 0, buttonWidth, buttonHeight)];
				[backButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
                [backButton setAccessibilityLabel:@"뒤로" Hint:@"뒤로 이동합니다"];
				[toolbarView addSubview:backButton];
                
				buttonX = buttonX + buttonWidth;
				
				//포워드 버튼
				forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[forwardButton setImage:[UIImage imageNamed:@"icon_tabbar_03fw_nor.png"] forState:UIControlStateNormal];
				[forwardButton setImage:[UIImage imageNamed:@"icon_tabbar_03fw_highlighted.png"] forState:UIControlStateHighlighted];
				[forwardButton setImage:[UIImage imageNamed:@"icon_tabbar_03fw_disable.png"] forState:UIControlStateDisabled];
				[forwardButton setFrame:CGRectMake(buttonX, 0, buttonWidth, buttonHeight)];
				[forwardButton addTarget:self action:@selector(touchForwardButton) forControlEvents:UIControlEventTouchUpInside];
                [forwardButton setAccessibilityLabel:@"앞으로" Hint:@"앞으로 이동합니다"];
				[toolbarView addSubview:forwardButton];
                
				buttonX = buttonX + buttonWidth;
			}
			
			//리프레쉬 버튼
			UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[refreshButton setImage:[UIImage imageNamed:@"icon_tabbar_05refresh_nor.png"] forState:UIControlStateNormal];
			[refreshButton setImage:[UIImage imageNamed:@"icon_tabbar_05refresh_highlighted.png"] forState:UIControlStateHighlighted];
			[refreshButton setFrame:CGRectMake(buttonX, 0, buttonWidth, buttonHeight)];
			[refreshButton addTarget:self action:@selector(touchRefreshButton) forControlEvents:UIControlEventTouchUpInside];
            [refreshButton setAccessibilityLabel:@"새로고침" Hint:@"화면을 새로고침합니다"];
			[toolbarView addSubview:refreshButton];
			
			//토글버튼
			toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[toggleButton setImage:[UIImage imageNamed:@"icon_tabbar_07full_nor.png"] forState:UIControlStateNormal];
			[toggleButton setFrame:CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, buttonHeight)];
			[toggleButton addTarget:self action:@selector(onClickToggleButtonShow:) forControlEvents:UIControlEventTouchUpInside];
            [toggleButton setAccessibilityLabel:@"토글" Hint:@"툴바를 내립니다"];
			[toolbarView addSubview:toggleButton];
			
			onToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[onToggleButton setImage:[UIImage imageNamed:@"icon_tabbar_07fullclose_nor.png"] forState:UIControlStateNormal];
			[onToggleButton setFrame:CGRectMake(self.frame.size.width - buttonWidth, toolbarView.frame.origin.y, buttonWidth, buttonHeight)];
			[onToggleButton addTarget:self action:@selector(onClickToggleButtonHide:) forControlEvents:UIControlEventTouchUpInside];
            [onToggleButton setAccessibilityLabel:@"토글" Hint:@"툴바를 올립니다"];
			[self addSubview:onToggleButton];
			[onToggleButton setHidden:YES];
			
			if (isTop)
			{
				//탑버튼
				topButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[topButton setImage:[UIImage imageNamed:@"icon_tabbar_top_nor.png"] forState:UIControlStateNormal];
				[topButton setImage:[UIImage imageNamed:@"icon_tabbar_top_selected.png"] forState:UIControlStateHighlighted];
				[topButton setFrame:CGRectMake(self.frame.size.width-buttonWidth, CGRectGetMaxY(popupWebView.frame)-10.f-36.f, buttonWidth, 36)];
				[topButton addTarget:self action:@selector(touchTopButton) forControlEvents:UIControlEventTouchUpInside];
                [topButton setAccessibilityLabel:@"탑" Hint:@"화면을 위로 이동합니다"];
				[self addSubview:topButton];
			}
			
            //웹뷰에 붙어있는 서랍옵션은 제거
//			if (isOption) {
//				[self makeProductOption];
//			}
		}
		
		if (isInsetzero) {
			popupWebView.frame = CGRectMake(0,
											CGRectGetMaxY(titleView.frame),
											CGRectGetWidth(frame),
											CGRectGetHeight(frame)-titleView.frame.size.height);
			
			[popupWebView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0.f, 0)];
		} else {
			[popupWebView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 20.f, 0)];
		}
    }
    return self;
}

#pragma mark - Public Methods

- (void)removePopupBrowserView
{
    CGRect frame = self.frame;
//    frame.origin.x += kScreenBoundsWidth;
    frame.origin.y += kScreenBoundsHeight;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self setFrame:frame];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    [self removePopupBrowserView];
}

- (void)touchTopButton
{
    [popupWebView.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)touchRefreshButton
{
    [popupWebView reload];
}

- (void)touchBackButton
{
    //히스토리가 없을 경우 뷰를 닫는다.
    if ([popupWebView canGoBack]) {
        [popupWebView goBack];
    }
    else {
        [self removePopupBrowserView];
    }
}

- (void)touchForwardButton
{
    [popupWebView goForward];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // 5.2.0까지 스킴적용 안됨 (app://popupBrowser/close) 해당 스킴 적용 시 배달의민족 app 호출 됨
	if ([request.URL.absoluteString isMatchedByRegex:[@"^" stringByAppendingString:URL_PATTERN]]) {
		NSString *command = [request.URL.absoluteString stringByMatching:URL_PATTERN capture:1];
		
		if ([@"popupBrowser" isEqualToString:command]) {
            
            if ([self.delegate respondsToSelector:@selector(popupBrowserViewOpenUrlScheme:)]) {
                [self.delegate popupBrowserViewOpenUrlScheme:request.URL.absoluteString];
            }
			
			return NO;
		}
        else if ([@"moviepopup" isEqualToString:command]) {
            
            if ([self.delegate respondsToSelector:@selector(popupBrowserViewOpenUrlScheme:)]) {
                [self.delegate popupBrowserViewOpenUrlScheme:request.URL.absoluteString];
            }
            
            return NO;
        }
	}
	
    return YES;
//	return [APP_ROOTCTRL urlWithProperties:request.URL.absoluteString] != nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//	
//	[self.view bringSubviewToFront:indicatorView];
//	
//	[indicatorView startAnimating];
}

//2013.12.16일 기획변경 : 히스토리가 없더라도 백버튼은 항상 활성화 시킨다. (히스토리가 없을 경우에 뷰를 닫는다.)
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [forwardButton setEnabled:[webView canGoForward]];
//	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//	[indicatorView stopAnimating];
//	[option setHidden:NO];
	
//	[self setBackForwardEnabled:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//	[indicatorView stopAnimating];
}

- (void)onClickToggleButtonShow:(id)sender
{
	//툴바 숨김 / 탑버튼 내림 / 토글On버튼 등장
	CGRect webViewFrame = CGRectMake(popupWebView.frame.origin.x,
									 popupWebView.frame.origin.y,
									 popupWebView.frame.size.width,
									 popupWebView.frame.size.height + kToolBarHeight);
	
	CGRect toolbarFrame = CGRectMake(toolbarView.frame.origin.x,
									 CGRectGetMaxY(webViewFrame),
									 toolbarView.frame.size.width,
									 toolbarView.frame.size.height);
	
	CGRect topButtonFrame = CGRectMake(topButton.frame.origin.x,
									   onToggleButton.frame.origin.y - topButton.frame.size.height-10.f,
									   topButton.frame.size.width,
									   topButton.frame.size.height);
	
	CGRect productFrame = CGRectMake(productView.frame.origin.x,
									 productView.frame.origin.y + kToolBarHeight,
									 productView.frame.size.width,
									 productView.frame.size.height);
	
	[UIView animateWithDuration:0.5f animations:^{
		[popupWebView setFrame:webViewFrame];
		[toolbarView setFrame:toolbarFrame];
		[topButton setFrame:topButtonFrame];
		[productView setFrame:productFrame];
		[productView setAlpha:0.f];
		
	} completion:^(BOOL finished) {
		[onToggleButton setHidden:NO];
	}];
}

- (void)onClickToggleButtonHide:(id)sender
{
	//토글 On 버튼 숨김 / 탑버튼 올림 / 툴바 올림
	[onToggleButton setHidden:YES];
	
	//툴바 숨김 / 탑버튼 내림 / 토글On버튼 등장
	CGRect webViewFrame = CGRectMake(popupWebView.frame.origin.x,
									 popupWebView.frame.origin.y,
									 popupWebView.frame.size.width,
									 popupWebView.frame.size.height - kToolBarHeight);
	
	CGRect toolbarFrame = CGRectMake(toolbarView.frame.origin.x,
									 CGRectGetMaxY(webViewFrame),
									 toolbarView.frame.size.width,
									 toolbarView.frame.size.height);
	
	CGRect topButtonFrame = CGRectMake(topButton.frame.origin.x,
                                       onToggleButton.frame.origin.y - topButton.frame.size.height-10.f-(productView ? 40.f : 0.f),
									   topButton.frame.size.width,
									   topButton.frame.size.height);
	
	CGRect productFrame = CGRectMake(productView.frame.origin.x,
									 productView.frame.origin.y - kToolBarHeight,
									 productView.frame.size.width,
									 productView.frame.size.height);

	[UIView animateWithDuration:0.5f animations:^{
		[popupWebView setFrame:webViewFrame];
		[toolbarView setFrame:toolbarFrame];
		[topButton setFrame:topButtonFrame];
		[productView setFrame:productFrame];
		[productView setAlpha:1.f];
	} completion:^(BOOL finished) {
		
	}];
}

#pragma mark - productOption Methods

- (void)makeProductOption
{
	//툴바가 없으면 화면에 그릴 수 없다.
	if (!toolbarView) return;
	
	productView = [[CPProductOption alloc] initWithToolbarView:toolbarView parentView:self];
	[productView setExecuteWebView:self.executeWebView];
	[productView setIsPopupBrowser:YES];
	[productView setDelegate:self];
	[self addSubview:productView];
	productView.alpha = 0.f;
	
	//툴바를 항상 앞으로 놓는다.
	[self bringSubviewToFront:toolbarView];
	
    //탑버튼을 위로 올린다.
    CGRect topButtonFrame = CGRectMake(topButton.frame.origin.x, CGRectGetMaxY(popupWebView.frame)-10.f-36.f-40.f, topButton.frame.size.width, 36);
    
	//에니메이션
	[UIView animateWithDuration:0.5f animations:^{
		productView.alpha = 1.f;
        topButton.frame = topButtonFrame;
	} completion:^(BOOL finished) {
        
	}];
}

- (void)closeProductOption
{
	if (productView) {
		[productView closeDrawer];
	}
}

- (void)destoryProductOption
{
	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:[CPProductOption class]]) {
			[view removeFromSuperview];
		}
	}
}

- (void)productOptionOnClickPurchasesItem
{
	//상품구매하기 / 장바구니 버튼이 눌리면 창을 닫아준다.
	[self removePopupBrowserView];
}

@end
