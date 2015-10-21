#import "CPPushManager.h"
#import "HttpRequest.h"
#import "SBJSON.h"

#import "CPHomeViewController.h"
#import "CPPopupViewController.h"
#import "SetupOtpController.h"
#import "AppDelegate.h"

@interface CPPushManager () <HttpRequestDelegate, UIAlertViewDelegate>
{
	BOOL isShowPushMessage;
	BOOL isShowPushAlert;
	NSDictionary *pushDict;
}

@end

@implementation CPPushManager

+ (CPPushManager *)sharedSingleton
{
	static dispatch_once_t pred;
	static CPPushManager *instance = nil;
	
	dispatch_once(&pred, ^{
		instance = [[CPPushManager alloc] init];
	});
	
	return instance;
}

#pragma mark - init Methods..
- (id)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (void)dealloc
{
	
}

#pragma mark - show push message Methods..
- (void)showPushMessage:(NSDictionary *)info
{
	//푸쉬메세지 얼럿을 보여주고있을 경우 다른 푸쉬메세지가 도착하면 무시한다.
	if (isShowPushMessage) return;
	
	isShowPushMessage = YES;
	isShowPushAlert = [[info objectForKey:@"alertShow"] boolValue];
	[self pushNotificationValidation:info];
}

- (void)gotoPushWebviewWithUrl:(NSString *)url
{
	AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (NO == app.isFinishedHomeLoad) {
		return [self performSelector:@selector(gotoPushWebviewWithUrl:) withObject:url afterDelay:0.1f];
	}

	//팝업뷰가 있으면 닫기
	if ([self closePopoverView]) {
		return [self performSelector:@selector(gotoPushWebviewWithUrl:) withObject:url afterDelay:0.4f];
	}

	//페이지 이동
	CPHomeViewController *homeViewController = app.homeViewController;
	[homeViewController didTouchButtonWithUrl:url];
}

- (BOOL)closePopoverView
{
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
	
	if (homeViewController.presentedViewController) {
		//전면팝업 닫기
		if ([homeViewController.presentedViewController isKindOfClass:[CPPopupViewController class]]) {
			CPPopupViewController *modalViewController = (CPPopupViewController *)homeViewController.presentedViewController;
			[modalViewController onClickClose:nil];
			return YES;
		}
		
		//OTP 팝업 닫기
		if ([homeViewController.presentedViewController isKindOfClass:[SetupOtpController class]]) {
			SetupOtpController *modalViewController = (SetupOtpController *)homeViewController.presentedViewController;
			[modalViewController otpClose];
			return YES;
		}
	}
	
	return NO;
}

- (void)showFullScreenPopupWithUrl:(NSString *)url
{
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (!app.isFinishedHomeLoad) {
		return [self performSelector:@selector(showFullScreenPopupWithUrl:) withObject:url afterDelay:0.1f];
	}

	CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
	if ([homeViewController respondsToSelector:@selector(advertisement:)]) {
		[homeViewController advertisement:url];
	}
}

#pragma mark - request Http Methods..
- (void)saveDeviceInfo {
	HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	
	[postData setObject:@"01" forKey:@"osTypCd"];
	[postData setObject:@"iOS" forKey:@"osName"];
	[postData setObject:@"update" forKey:@"mode"];
	[postData setObject:@"01" forKey:@"deviceType"];
	[postData setObject:APP_KIND_CD forKey:@"appId"];
	[postData setObject:DEVICE_MODEL forKey:@"modelNm"];
	[postData setObject:SYSTEM_VERSION forKey:@"osVersion"];
	[postData setObject:DEVICE_ID forKey:@"deviceId"];
	[postData setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"appVersion"];
	
	[request setDelegate:self];
	[request setTimeout:5];
	[request setRequestParameterType:RequestActionSaveDeviceInfo];
	[request setEncoding:DEFAULT_ENCODING];
	[request sendPost:SAVE_PUSHKEY_URL body:postData];
}

- (void)checkAutoLoginDeviceWithType:(RequestAction)reqParamType
{
	HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	
	[postData setObject:@"iOS" forKey:@"osName"];
	[postData setObject:@"update" forKey:@"mode"];
	[postData setObject:@"01" forKey:@"osTypCd"];
	[postData setObject:@"true" forKey:@"isForce"];
	[postData setObject:APP_KIND_CD forKey:@"appId"];
	[postData setObject:SYSTEM_VERSION forKey:@"osVersion"];
	[postData setObject:DEVICE_ID forKey:@"deviceId"];
	[postData setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"appVersion"];
	
	[request setDelegate:self];
	[request setTimeout:10];
	[request setRequestParameterType:reqParamType];
	[request setEncoding:DEFAULT_ENCODING];
	[request sendPost:ALARM_AUTO_LOGIN_URL body:postData];
}

- (void)checkInAppPopup:(RequestAction)reqParamType
{
	HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
	
	[request setDelegate:self];
	[request setRequestParameterType:reqParamType];
	[request setTimeout:10.0f];
	[request sendGet:IN_APP_POPUP_URL data:nil];
}

- (void)savePushKey
{
	HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	NSString *pushKey = [userDefaults objectForKey:@"pushKey"];
	NSString *pushKeyEncoded = pushKey ? [pushKey stringByAddingPercentEscapesUsingEncoding:DEFAULT_ENCODING] : @"";
	
	[postData setObject:@"01" forKey:@"osTypCd"];
	[postData setObject:@"iOS" forKey:@"osName"];
	[postData setObject:@"update" forKey:@"mode"];
	[postData setObject:@"01" forKey:@"deviceType"];
	[postData setObject:APP_KIND_CD forKey:@"appId"];
	[postData setObject:DEVICE_MODEL forKey:@"modelNm"];
	[postData setObject:pushKeyEncoded forKey:@"pushKey"];
	[postData setObject:SYSTEM_VERSION forKey:@"osVersion"];
	[postData setObject:DEVICE_ID forKey:@"deviceId"];
	[postData setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"appVersion"];
	
	[request setDelegate:self];
	[request setTimeout:5];
	[request setRequestParameterType:RequestActionSavePushKey];
	[request setEncoding:DEFAULT_ENCODING];
	[request sendPost:SAVE_PUSHKEY_URL body:postData];
}

- (void)pushNotificationValidation:(NSDictionary *)pushInfo
{
	HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
	
	[postData setObject:@"01" forKey:@"osTypCd"];
	[postData setObject:@"iOS" forKey:@"osName"];
	[postData setObject:APP_KIND_CD forKey:@"appId"];
	[postData setObject:SYSTEM_VERSION forKey:@"osVersion"];
	[postData setObject:[pushInfo objectForKey:@"msgType"] forKey:@"msgType"];
	[postData setObject:[pushInfo objectForKey:@"msgID"] forKey:@"msgId"];
	[postData setObject:[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""] forKey:@"appVersion"];
	[postData setObject:DEVICE_ID forKey:@"deviceId"];
	
	[request setTimeout:10];
	[request setDelegate:self];
	[request setRequestParameterType:RequestActionPushNotificationValidation];
	[request setEncoding:DEFAULT_ENCODING];
	[request sendPost:PUSH_VALIDATION_URL body:postData];
}

#pragma mark - response HttpMethods..
- (void)request:(HttpRequest *)request didSuccessWithReceiveData:(NSString *)data
{
	switch ((NSInteger)request.requestParameterType)
	{
		case RequestActionSaveDeviceInfo:
			//디바이스 정보 저장
			[self successRequestActionSaveDeviceInfo];
			break;
		case RequestActionCheckAutoLoginDevice:
			//autoLogin 체크 (아무것도 하지 않음.)
			break;
		case RequestActionInAppPopup:
			//전면팝업 여부 확인
			[self successRequestActionInAppPopup:data];
			break;
		case RequestActionSavePushKey:
			//푸쉬키 등록
			[self successRequestActionSavePushKey:data];
			break;
		case RequestActionPushNotificationValidation:
			//푸쉬메세지를 통해 이동할 URL을 가져온다.
			[self successRequestActionPushNotificationValidation:data];
			break;
		default: break;
	}
	
}

- (void)request:(HttpRequest *)request didFailWithError:(NSError *)error
{
	switch ((NSInteger)request.requestParameterType)
	{
		case RequestActionSaveDeviceInfo:
			//디바이스 정보 저장 (실패해도 동일한 함수 호출)
			[self successRequestActionSaveDeviceInfo];
			break;
		case RequestActionPushNotificationValidation:
			//푸쉬메세지로 정보를 가져오는 것에 실패했다면 푸쉬를 받을 수 있는 상태로 변경해준다.
			isShowPushMessage = NO;
			break;
		default: break;
	}
}

- (void)successRequestActionSaveDeviceInfo
{
	if ([SYSTEM_VERSION intValue] >= 8) {
		//8.0이상
		UIUserNotificationSettings *notiType = nil;
		notiType = [UIUserNotificationSettings settingsForTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound
													 categories:nil];
	
		UIUserNotificationSettings *userSetting = notiType;
		[[UIApplication sharedApplication] registerUserNotificationSettings:userSetting];
	}
	else {
		//8.0이하
		UIRemoteNotificationType notiType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
		
		[[UIApplication sharedApplication] unregisterForRemoteNotifications];
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notiType];
	}
	
	//자동로그인을 체크한다.
	[self checkAutoLoginDeviceWithType:RequestActionCheckAutoLoginDevice];
	
	//앱 실행 전면팝업이 있는지 확인한다. (로컬알림이나 푸쉬알림으로 실행할 경우에는 띄워주지않는다.)
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if(!app.isLaunchedNotification) {
		[self checkInAppPopup:RequestActionInAppPopup];
	}
}

- (void)successRequestActionInAppPopup:(NSString *)data
{
	if (data == nil || [[data trim] length] == 0) return;
	
	NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																									(CFStringRef)data, NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
																									kCFStringEncodingUTF8));
	
	NSString *popupString = [NSString stringWithFormat:@"popup/%@", escapedString];

	//비로 팝업을 보여준다.
	[self showFullScreenPopupWithUrl:popupString];
}

- (void)successRequestActionSavePushKey:(NSString *)data
{
	//아무것도 하지않음.
}

- (void)successRequestActionPushNotificationValidation:(NSString *)data
{
	SBJSON *json = [[SBJSON alloc] init];
	
	NSDictionary *jsonData = data ? [json objectWithString:data] : nil;
	
	if (jsonData && [[jsonData objectForKey:@"errCode"] intValue] == 0) {
		
		if (isShowPushAlert) {
			//포그라운드에서 푸쉬를 받아 실행하는 경우 알럿을 보여준다.
			pushDict = [[NSDictionary alloc] initWithDictionary:jsonData];
			
			NSString *message = [jsonData objectForKey:@"message"];
			
			if ([message length] > 90) message = [message substringWithRange:NSMakeRange(0, 90)];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[jsonData objectForKey:@"title"]
																message:message
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
													  otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
			
			[alertView setTag:200];
			[alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
		}
		else {
			//백그라운드에서 푸쉬를 받아 실행하는 경우 알럿을 보여주지 않는다.
			NSString *detailUrl = [jsonData objectForKey:@"detailUrl"];
			
			[self gotoPushWebviewWithUrl:detailUrl];
			isShowPushMessage = NO;
		}
	}
	else {
		isShowPushMessage = NO;
	}
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 200)
	{
		if (buttonIndex == 0)
		{
			if (pushDict) {

				AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				if ([app getIsPushMarketingType]) {
					[app resetRefusedPushAgree];
				}
				
				NSString *detailUrl = [pushDict objectForKey:@"detailUrl"];
				
				[self gotoPushWebviewWithUrl:detailUrl];
				isShowPushMessage = NO;
				pushDict = nil;
			}
		}
        else {
            isShowPushMessage = NO;
            pushDict = nil;
        }
	}
}

@end
