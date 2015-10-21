#import "CPPopupViewController.h"
#import "RegexKitLite.h"
#import "CPSchemeManager.h"

@interface CPPopupViewController () <UIWebViewDelegate>
{
	CGFloat _statusBarHeight;
	
	UIWebView *_webView;
	UIActivityIndicatorView *_indicator;
}

@end

@implementation CPPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initLayout
{
	if ([SYSTEM_VERSION intValue] >= 7) {
		_statusBarHeight = 20.f;
		
		UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _statusBarHeight)];
		blackView.backgroundColor = [UIColor blackColor];
		blackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.view addSubview:blackView];
	}
	
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[_indicator stopAnimating];
	[_indicator setHidden:YES];
	[self.view addSubview:_indicator];
	
	if (self.isLoginType) {
		//로그인 타입일 경우
        CGFloat topBarViewHeight = 44.0f;
		UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
																	  _statusBarHeight,
																	  self.view.frame.size.width,
																	  topBarViewHeight)];
        topBarView.backgroundColor = NAVIGATION_BAR_COLOR;
		[self.view addSubview:topBarView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:topBarView.bounds];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setText:self.title];
		[topBarView addSubview:titleLabel];
		
		UIImage *buttonImage = [UIImage imageNamed:@"btn_close.png"];
		
		UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnClose setFrame:CGRectMake(topBarView.frame.size.width-buttonImage.size.width-5.f,
									  (topBarView.frame.size.height / 2) - (buttonImage.size.height / 2),
									  buttonImage.size.width,
									  buttonImage.size.height)];
		[btnClose setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
		[btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btnClose.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
		[btnClose addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
        [btnClose setAccessibilityLabel:@"닫기" Hint:@"화면을 닫습니다"];
		[topBarView addSubview:btnClose];
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
															   CGRectGetMaxY(topBarView.frame),
															   self.view.frame.size.width,
															   self.view.frame.size.height-topBarView.frame.size.height-_statusBarHeight)];
		_webView.delegate = self;
		_webView.scalesPageToFit = YES;
		_webView.clipsToBounds = YES;
		[self.view addSubview:_webView];
	}
	else {
		//전면팝업일 경우
		UIImage *bottomImage = [UIImage imageNamed:@"adFullScreen_bottom_bg.png"];
		
		UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
																	  self.view.frame.size.height-bottomImage.size.height,
																	  self.view.frame.size.width,
																	  bottomImage.size.height)];
		[self.view addSubview:bottomView];
		
		UIImageView *bottomBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
																				  0,
																				  bottomView.frame.size.width,
																				  bottomView.frame.size.height)];
		[bottomBgView setImage:bottomImage];
		[bottomView addSubview:bottomBgView];
		
		UIImage *buttonImageNor = [UIImage imageNamed:@"adFullScreen_close_normal.png"];
		UIImage *buttonImageHil = [UIImage imageNamed:@"adFullScreen_close_selected.png"];
		
		UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnClose setFrame:CGRectMake((bottomBgView.frame.size.width/2)-(buttonImageNor.size.width/2),
									  (bottomBgView.frame.size.height/2)-(buttonImageNor.size.height/2),
									  buttonImageNor.size.width,
									  buttonImageNor.size.height)];
		[btnClose setImage:buttonImageNor forState:UIControlStateNormal];
		[btnClose setImage:buttonImageHil forState:UIControlStateHighlighted];
		[btnClose addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
        [btnClose setAccessibilityLabel:@"닫기" Hint:@"화면을 닫습니다"];
		[bottomView addSubview:btnClose];
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,
															   _statusBarHeight,
															   self.view.frame.size.width,
															   self.view.frame.size.height-bottomView.frame.size.height-_statusBarHeight)];
		_webView.delegate = self;
		_webView.scalesPageToFit = YES;
		_webView.clipsToBounds = YES;
		[self.view addSubview:_webView];
	}
	
	[self openUrl:self.requestUrl];
}

- (void)openUrl:(NSString *)url
{
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)showLodingIndicator
{
	[self.view bringSubviewToFront:_indicator];
	[_indicator setCenter:CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height/2))];
	[_indicator setHidden:NO];
	[_indicator startAnimating];
}

- (void)hideLodingIndicator
{
	[_indicator setHidden:YES];
	[_indicator stopAnimating];
}

#pragma mark - button Pressed Methods

- (void)onClickClose:(id)sender
{
	[_webView stopLoading];
	[self hideLodingIndicator];
	
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.isAdult) {
        if ([self.delegate respondsToSelector:@selector(popupviewControllerDidAdultClosed)]) {
            [self.delegate popupviewControllerDidAdultClosed];
        }
    }
    else {
        if ([Modules checkLoginFromCookie] && [self.delegate respondsToSelector:@selector(popupViewControllerAfterSuccessLogin)]) {
            [self.delegate popupViewControllerAfterSuccessLogin];
            
            // 로그인 성공 노티
            [[NSNotificationCenter defaultCenter] postNotificationName:SettingControllerDidLoginNotification object:self];
        }
    }
}

#pragma mark - UIWebviewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"request.url : %@", request.URL.absoluteString);

	if (self.isLoginType) {
		if ([request.URL.absoluteString isMatchedByRegex:[@"^" stringByAppendingString:URL_PATTERN]])
		{
			NSString *command = [request.URL.absoluteString stringByMatching:URL_PATTERN capture:1];
			NSString *option = [request.URL.absoluteString stringByMatching:URL_PATTERN capture:2];
			
			if ([command isEqualToString:@"redirect"]) {
				[self openUrl:[Modules urlWithQueryString:option]];
			}
			else if ([command isEqualToString:@"user"] && [option isEqualToString:@"appLogin"]) {
				[self onClickClose:nil];
				
				// 푸시 승인 후 로그인 처리를 위해 ...
				if ([self.delegate respondsToSelector:@selector(popupViewControllerDidSuccessLogin)]) {
					[self.delegate popupViewControllerDidSuccessLogin];
				}

//                // 로그인 성공 노티
//                [[NSNotificationCenter defaultCenter] postNotificationName:SettingControllerDidLoginNotification object:self];
			}
			else if ([command isEqualToString:@"otp"])
			{
                [[CPSchemeManager sharedManager] openUrlScheme:request.URL.absoluteString sender:nil changeAnimated:NO];
			}
            else if ([command isEqualToString:@"move"])
            {
                [self onClickClose:nil];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(popupviewControllerMoveHome:)]) {
                    [self.delegate popupviewControllerMoveHome:option];
                }
            }
            else if ([command isEqualToString:@"openBrowser"]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(popupviewControllerOpenBrowser:)]) {
                    [self.delegate popupviewControllerOpenBrowser:option];
                }
            }
            else if ([command isEqualToString:@"login"]) {
                [_webView stopLoading];
                [self hideLodingIndicator];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(popupviewControllerDidAdultSuccessLogin:)]) {
                    [self.delegate popupviewControllerDidAdultSuccessLogin:YES];
                }
            }
			
			return NO;
		}
	}
	else {
		if (navigationType == UIWebViewNavigationTypeLinkClicked) {
			NSString *urlRequest = request.URL.absoluteString;

			[self onClickClose:nil];
			
			if ([self.delegate respondsToSelector:@selector(popupViewControllerCloseAndMoveUrl:)]) {
				[self.delegate popupViewControllerCloseAndMoveUrl:urlRequest];
			}
		}
	}

	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self showLodingIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self hideLodingIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self hideLodingIndicator];
}

@end

