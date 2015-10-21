#import "CPDeveloperViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RegexKitLite.h"
#import "CPHomeViewController.h"
#import "CPWebViewController.h"
#import "CPWebView.h"

@interface CPDeveloperViewController ()	<UIActionSheetDelegate,
										 UIAlertViewDelegate,
										 UITextFieldDelegate,
										 UITextViewDelegate>
{
	NSString *_myDomain;
}

@end

@implementation CPDeveloperViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	[self createDeveloperView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	UITextField *infoView = (UITextField *)[self.view viewWithTag:98];
	if (infoView) [infoView setText:[self devInfo]];
}

- (void)createDeveloperView
{
	int devY = 0;
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)	devY = 20;
	else															devY = 0;
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, devY)];
		blackView.backgroundColor = [UIColor blackColor];
		[self.view addSubview:blackView];
	}
	
	UIView *devView = [[UIView alloc] initWithFrame:CGRectMake(0, devY, self.view.frame.size.width, self.view.frame.size.height-devY)];
	
	UIToolbar *devMenu = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
	UITextView *infoView = [[UITextView alloc] initWithFrame:CGRectMake(0, devMenu.frame.size.height, devView.frame.size.width, devView.frame.size.height - devMenu.frame.size.height)];
	NSMutableArray *barButtons = [NSMutableArray array];
	UIBarButtonItem *domainBtn, *urlBtn, *cookieBtn, *closeBtn, *tZoneBtn;
	
	domainBtn = [[UIBarButtonItem alloc] initWithTitle:@"Domain" style:UIBarButtonItemStyleDone target:self action:@selector(selectDomain:)];
	urlBtn = [[UIBarButtonItem alloc] initWithTitle:@"URL" style:UIBarButtonItemStyleDone target:self action:@selector(urlDialog:)];
	cookieBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cookie" style:UIBarButtonItemStyleDone target:self action:@selector(cookieDialog:)];
	tZoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"T존" style:UIBarButtonItemStyleDone target:self action:@selector(moveTzoneUrl:)];
	closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
	
	[devView setTag:999];
	[devMenu setTag:99];
	[infoView setTag:98];
	[domainBtn setTag:1];
	[urlBtn setTag:2];
	[closeBtn setTag:9];
	
	[barButtons addObject:domainBtn];
	[barButtons addObject:urlBtn];
	[barButtons addObject:cookieBtn];
	[barButtons addObject:tZoneBtn];
	[barButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	[barButtons addObject:closeBtn];
	
	[devMenu setBarStyle:UIBarStyleBlackTranslucent];
	[devMenu setItems:barButtons animated:YES];
	[devMenu setAutoresizesSubviews:YES];
	[devMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
	
	[infoView setText:@""];
	[infoView setEditable:NO];
	[infoView setMultipleTouchEnabled:YES];
	[infoView setMaximumZoomScale:3.0f];
	[infoView setAutoresizesSubviews:YES];
	[infoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[devView addSubview:devMenu];
	[devView addSubview:infoView];
	
	[self.view addSubview:devView];
}

- (void)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if ([self.delegate respondsToSelector:@selector(developerViewControllerClose)]) {
		[self.delegate developerViewControllerClose];
	}
}

#pragma -mark Domain fun.
- (void)selectDomain:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"도메인 선택"
															 delegate:self
													cancelButtonTitle:@"직접입력"
											   destructiveButtonTitle:@"취소"
													otherButtonTitles:@"통합(test-m)", @"개발(dev-m)", @"개발(devo_m)", @"스테이지(stage)", @"검증(verify)", @"상용", nil];
	
	[actionSheet setTag:1];
	[actionSheet showInView:[self view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSArray *domains = [[NSArray alloc] initWithObjects:@"test-m.11st.co.kr", @"dev-m.11st.co.kr", @"devo-m.11st.co.kr", @"stage-m.11st.co.kr", @"verify-m.11st.co.kr", @"m.11st.co.kr", nil];
	
	if (actionSheet.tag == 1)
	{
		if (buttonIndex == 0) return;
		
		if (buttonIndex > 0 && buttonIndex <= [domains count])
		{
			[self changeDomain:(_myDomain = [domains objectAtIndex:buttonIndex - 1])];
		}
		else
		{
			[self domainDialog:actionSheet];
		}
	}
}

- (void)changeDomain:(id)sender
{
	UITextField *inputField = (UITextField *)[self.view viewWithTag:234];
	
	if (inputField)	_myDomain = inputField.text;
	
	if (!_myDomain)
	{
		UIAlertView *pAlertView = [[UIAlertView alloc] initWithTitle:@""
															 message:@"변경할 도메인이 없습니다"
															delegate:nil
												   cancelButtonTitle:@"확인"
													otherButtonTitles:nil, nil];
		[pAlertView show];
		return;
	}
	
	UIAlertView *devAlert = [[UIAlertView alloc] initWithTitle:@"개발자모드"
													   message:[NSString stringWithFormat:@"%@\n도메인이 변경되었습니다.\n다시 실행해 주세요.", _myDomain]
													  delegate:self
											 cancelButtonTitle:@"확인"
											 otherButtonTitles:nil];
	
	[self removeDomainData];
	
	[[NSUserDefaults standardUserDefaults] setObject:_myDomain forKey:@"domainName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[devAlert setDelegate:self];
	[devAlert setTag:1];
	[devAlert show];
}

- (void)domainDialog:(id)sender {
	UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake(10, 20 + 55, 300, 100)];
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
	UIToolbar *dialogMenu = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, dialog.frame.size.width, 45)];
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, dialog.frame.size.width - 20, dialog.frame.size.height - 20 - dialogMenu.frame.origin.y - dialogMenu.frame.size.height)];
	UIBarButtonItem *moveBtn, *cancelBtn;
	NSMutableArray *barButtons = [NSMutableArray array];
	
	moveBtn = [[UIBarButtonItem alloc] initWithTitle:@"수정" style:UIBarButtonItemStyleDone target:self action:@selector(changeDomain:)];
	cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:dialog action:@selector(removeFromSuperview)];
	
	[moveBtn setTag:1];
	[cancelBtn setTag:0];
	
	[barButtons addObject:cancelBtn];
	[barButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	[barButtons addObject:moveBtn];
	
	[dialog setBackgroundColor:[UIColor lightGrayColor]];
	[dialog setAutoresizesSubviews:YES];
	[dialog setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
	
	[dialogMenu setFrame:CGRectMake(textField.frame.origin.x, textField.frame.origin.y + textField.frame.size.height + 5, dialogMenu.frame.size.width - textField.frame.origin.x * 2, dialogMenu.frame.size.height)];
	[dialogMenu setItems:barButtons];
	[dialogMenu setBarStyle:UIBarStyleBlackOpaque];
	[dialogMenu setAutoresizesSubviews:YES];
	[dialogMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	
	[textField setTag:234];
	[textField setDelegate:self];
	[textField setText:(_myDomain = [[NSString alloc] initWithString:BASE_DOMAIN])];
	[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setEnablesReturnKeyAutomatically:YES];
	[textField setAutoresizesSubviews:YES];
	[textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[textField setLeftView:leftView];
	[textField setLeftViewMode:UITextFieldViewModeAlways];
	[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[textField setReturnKeyType:UIReturnKeyDone];
	[textField setPlaceholder:@"도메인을 입력해주세요."];
	
    [[textField layer] setMasksToBounds:YES];
	[[textField layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[textField layer] setBorderWidth:0.5];
	[[textField layer] setCornerRadius:4];
	
    [[dialogMenu layer] setMasksToBounds:YES];
	[[dialogMenu layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[dialogMenu layer] setBorderWidth:0.5];
	[[dialogMenu layer] setCornerRadius:4];
	
    [[dialog layer] setMasksToBounds:YES];
	[[dialog layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
	[[dialog layer] setBorderWidth:0.5];
	[[dialog layer] setCornerRadius:4];
	
	[dialog addSubview:textField];
	[dialog addSubview:dialogMenu];
	
	UIView *devView = [self.view viewWithTag:999];
	
	[devView addSubview:dialog];
}

#pragma -mark URL fun.
- (void)urlDialog:(id)sender
{
	UIView *devView = [self.view viewWithTag:999];
	
	UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake(0, 0, devView.frame.size.width, devView.frame.size.height)];
	UIToolbar *dialogMenu = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, dialog.frame.size.width, 45)];
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, dialog.frame.size.width - 20, dialog.frame.size.height - 20 - dialogMenu.frame.origin.y - dialogMenu.frame.size.height)];
	UIBarButtonItem *webviewBtn, *cancelBtn;
	NSMutableArray *barButtons = [NSMutableArray array];
	
	webviewBtn = [[UIBarButtonItem alloc] initWithTitle:@"웹뷰이동" style:UIBarButtonItemStyleDone target:self action:@selector(moveToUrl:)];
	cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:dialog action:@selector(removeFromSuperview)];
	
	[webviewBtn setTag:1];
	[cancelBtn setTag:0];
	
	[barButtons addObject:cancelBtn];
	[barButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	[barButtons addObject:webviewBtn];
	
	[dialog setBackgroundColor:[UIColor lightGrayColor]];
	[dialog setAutoresizesSubviews:YES];
	[dialog setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[dialogMenu setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y + textView.frame.size.height + 5, dialogMenu.frame.size.width - textView.frame.origin.x * 2, dialogMenu.frame.size.height)];
	[dialogMenu setItems:barButtons];
	[dialogMenu setBarStyle:UIBarStyleBlackOpaque];
	[dialogMenu setAutoresizesSubviews:YES];
	[dialogMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];

	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
	NSString *webUrl = (homeViewController.currentWebView ? [homeViewController.currentWebView url] : @"");
	
	[textView setTag:123];
	[textView setDelegate:self];
	[textView setText:webUrl];
	[textView setFont:[UIFont systemFontOfSize:13]];
	[textView setBackgroundColor:[UIColor whiteColor]];
	[textView setEditable:YES];
	[textView setEnablesReturnKeyAutomatically:YES];
	[textView setAutoresizesSubviews:YES];
	[textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
    [[textView layer] setMasksToBounds:YES];
	[[textView layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[textView layer] setBorderWidth:0.5];
	[[textView layer] setCornerRadius:4];
	
    [[dialogMenu layer] setMasksToBounds:YES];
	[[dialogMenu layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[dialogMenu layer] setBorderWidth:0.5];
	[[dialogMenu layer] setCornerRadius:4];
	
	[dialog addSubview:textView];
	[dialog addSubview:dialogMenu];
	
	[devView addSubview:dialog];
}

- (void)moveToUrl:(id)sender {
	
	UITextField *inputField = (UITextField *)[self.view viewWithTag:123];
	
	if (!inputField || [inputField.text length] == 0)
	{
		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"URL 없음"
														 message:@"이동할 URL을 입력해주세요."
														delegate:nil
											   cancelButtonTitle:@"확인"
											   otherButtonTitles:nil, nil];
		[pAlert show];
		return;
	}
	
	//웹뷰 이동시켜라!!
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
    [homeViewController openWebViewControllerWithUrl:inputField.text animated:YES];
//
//	[homeViewController.currentWebView open:inputField.text];
    
//    CPWebViewController *viewController = [[CPWebViewController alloc] initWithUrl:inputField.text];
//    [self.navigationController pushViewController:viewController animated:YES];

	//창 닫기
	[self close:nil];
}

#pragma -mark Cookie fun..
- (void)cookieDialog:(id)sender
{
	UIView *devView = [self.view viewWithTag:999];
	UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake(0, 0, devView.frame.size.width, devView.frame.size.height)];
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
	UIToolbar *dialogMenu = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, dialog.frame.size.width, 45)];
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, dialog.frame.size.width - 20, 30)];
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(textField.frame.origin.x, textField.frame.origin.y + textField.frame.size.height + 5, dialog.frame.size.width - 20, dialog.frame.size.height - textField.frame.origin.y * 2 - textField.frame.size.height - dialogMenu.frame.origin.y - dialogMenu.frame.size.height - 5)];
	UIBarButtonItem *moveBtn, *cancelBtn;
	NSMutableArray *barButtons = [NSMutableArray array];
	
	moveBtn = [[UIBarButtonItem alloc] initWithTitle:@"저장" style:UIBarButtonItemStyleDone target:self action:@selector(saveCookie:)];
	cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:dialog action:@selector(removeFromSuperview)];
	
	[moveBtn setTag:1];
	[cancelBtn setTag:0];
	
	[barButtons addObject:cancelBtn];
	[barButtons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	[barButtons addObject:moveBtn];
	
	[dialog setTag:777];
	[dialog setBackgroundColor:[UIColor lightGrayColor]];
	[dialog setAutoresizesSubviews:YES];
	[dialog setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[dialogMenu setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y + textView.frame.size.height + 5, dialogMenu.frame.size.width - textView.frame.origin.x * 2, dialogMenu.frame.size.height)];
	[dialogMenu setItems:barButtons];
	[dialogMenu setBarStyle:UIBarStyleBlackOpaque];
	[dialogMenu setAutoresizesSubviews:YES];
	[dialogMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	
	[textField setTag:456];
	[textField setDelegate:self];
	[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[textField setBackgroundColor:[UIColor whiteColor]];
	[textField setEnablesReturnKeyAutomatically:YES];
	[textField setAutoresizesSubviews:YES];
	[textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[textField setLeftView:leftView];
	[textField setLeftViewMode:UITextFieldViewModeAlways];
	[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[textField setReturnKeyType:UIReturnKeyDone];
	
	[textView setTag:345];
	[textView setDelegate:self];
	[textView setFont:[UIFont systemFontOfSize:13]];
	[textView setBackgroundColor:[UIColor whiteColor]];
	[textView setEditable:YES];
	[textView setEnablesReturnKeyAutomatically:YES];
	[textView setAutoresizesSubviews:YES];
	[textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
    [[textField layer] setMasksToBounds:YES];
	[[textField layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[textField layer] setBorderWidth:0.5];
	[[textField layer] setCornerRadius:4];
	
    [[textView layer] setMasksToBounds:YES];
	[[textView layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[textView layer] setBorderWidth:0.5];
	[[textView layer] setCornerRadius:4];
	
    [[dialogMenu layer] setMasksToBounds:YES];
	[[dialogMenu layer] setBorderColor:[[UIColor blackColor] CGColor]];
	[[dialogMenu layer] setBorderWidth:0.5];
	[[dialogMenu layer] setCornerRadius:4];
	
	[dialog addSubview:textField];
	[dialog addSubview:textView];
	[dialog addSubview:dialogMenu];
	
	[devView addSubview:dialog];
}

- (void)moveTzoneUrl:(id)sender
{
	//웹뷰 이동시켜라!!
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;

	if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
		[homeViewController didTouchButtonWithUrl:@"http://m.11st.co.kr/TZONE"];
	}
	
	//창 닫기
	[self close:nil];
}

- (void)saveCookie:(id)sender
{
	UITextField *nameField = (UITextField *)[self.view viewWithTag:456];
	if (!nameField || [nameField.text length] == 0)
	{
		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"쿠키저장"
														 message:@"쿠키 이름을 입력해주세요."
														delegate:nil
											   cancelButtonTitle:@"확인"
											   otherButtonTitles:nil, nil];
		[pAlert show];
		return;
	}
	
	UITextView *valueView = (UITextView *)[self.view viewWithTag:345];
	if (!valueView || [valueView.text length] == 0)
	{
		UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:@"쿠키저장"
														 message:@"쿠키 값을 입력해주세요."
														delegate:nil
											   cancelButtonTitle:@"확인"
											   otherButtonTitles:nil, nil];
		[pAlert show];
		return;
	}
	
	UIView *dialog = [self.view viewWithTag:777];
	
	[self setCookieWithName:nameField.text value:valueView.text domain:BASE_DOMAIN];
	[dialog removeFromSuperview];
	
	
	UITextField *infoView = (UITextField *)[self.view viewWithTag:98];
	if (infoView) [infoView setText:[self devInfo]];
}

- (void)setCookieWithName:(NSString *)cookieName value:(NSString *)cookieValue domain:(NSString *)cookieDomain
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:cookieDomain, NSHTTPCookieDomain, cookieName, NSHTTPCookieName, cookieValue, NSHTTPCookieValue, @"/", NSHTTPCookiePath, nil];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [cookieStorage setCookie:[NSHTTPCookie cookieWithProperties:properties]];
}

#pragma -mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1)
	{
		exit(0);
	}
}

#pragma -mark UITextFieldDelegate
- (void)closeKeyboard
{
	UITextField *textField01 = (UITextField *)[self.view viewWithTag:123];
	UITextField *textField02 = (UITextField *)[self.view viewWithTag:234];
	UITextField *textField03 = (UITextField *)[self.view viewWithTag:345];
	
	if (textField01)		[textField01 resignFirstResponder];
	else if(textField02)	[textField02 resignFirstResponder];
	else if(textField03)	[textField03 resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isMatchedByRegex:@"^[\r\n]+$"]) {
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}

#pragma -mark getInfo
- (NSString *)devInfo {
	NSString *info = @"";
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
	
	NSString *webviewUrl = (homeViewController.currentWebView ? [homeViewController.currentWebView url] : @"");
	NSString *uuid = DEVICE_ID;
	NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushKey"];
	pushToken = (pushToken != nil ? pushToken : @"미등록");
	
	info = [NSString stringWithFormat:@"[CURRENT DOMAIN]\n%@\n[URL]\n%@\n\n[PUSH TOKEN]\n%@\n\n[DEVICE ID]\n%@\n\n[Cookie]\n", [self getCookieName:@"TZONE"],
			webviewUrl, pushToken, uuid];
	
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSHTTPCookie *cookie;
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	
	for (cookie in [cookieStorage cookies]) info = [info stringByAppendingFormat:@"%@ = %@\n", [cookie name], URLDecode([cookie value])];

	//공유키 확인
	NSString *shareStr = [Modules groupObjectForKey:@"shareString"];
	if (![Modules isNullString:shareStr]) {
		info = [info stringByAppendingString:@"\n[공유된 문장]\n"];
		info = [info stringByAppendingFormat:@"%@\n", shareStr];
	}

	return info;
}

- (NSString *)getCookieName:(NSString *)name
{
	NSString *domain = @"";
	
	for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		//        NSLog(@"cookie:%@ \n\n%@ \n\n%@ \n\n%@ ", cookie.name, cookie.value, cookie.expiresDate, cookie.domain);
		if ([cookie.name isEqualToString:name]) {
			//            NSLog(@"cookie name:%@\n value:%@", cookie.name, cookie.value);
			domain = cookie.value;
			break;
		}
	}
    
    if (nilCheck(domain)) {
        domain = BASE_DOMAIN;
    }
	
	return domain;
}


#pragma -mark remove changed Domain Data
- (void)removeDomainData
{
	//TO DO. 도메인 변경시 삭제할 데이터가 있다면 여기에서..
}

@end
