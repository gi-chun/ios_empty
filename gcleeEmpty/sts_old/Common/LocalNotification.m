#import "LocalNotification.h"

#import "CPHomeViewController.h"
#import "CPPopupViewController.h"
#import "SetupOtpController.h"
#import "AccessLog.h"

@implementation LocalNotification

+ (LocalNotification *)sharedSingleton
{
	static dispatch_once_t pred;
	static LocalNotification *instance = nil;
	
	dispatch_once(&pred, ^{
		instance = [[LocalNotification alloc] init];
	});
	
	return instance;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (void)dealloc
{
}

#pragma -mark show Notification List
- (void)showNotificationList
{
	NSLog(@"notification : %@", [[UIApplication sharedApplication] scheduledLocalNotifications].description);
}

#pragma -mark check Notification List
- (BOOL)isHaveEventNotification:(NSString *)eventId message:(NSString *)msg date:(NSString *)dateStr url:(NSString *)url
{
	for (int i=0; i<[[UIApplication sharedApplication] scheduledLocalNotifications].count; i++) {
		UILocalNotification *localNotification = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
		
		NSDictionary *dict = localNotification.userInfo;
		
		NSString *tEventId	= [dict objectForKey:@"eventid"];
		NSString *tMessage	= [dict objectForKey:@"message"];
		NSString *tDateStr	= [dict objectForKey:@"date"];
		NSString *tUrl		= [dict objectForKey:@"eventurl"];
		
		if ([tEventId isEqualToString:eventId] && [tMessage isEqualToString:msg] && [tDateStr isEqualToString:dateStr] && [tUrl isEqualToString:url]) {
			return YES;
		}
	}
	
	return NO;
}

#pragma -mark Add / Remove Notification
- (BOOL)addLocalNotification:(NSString *)eventId message:(NSString *)msg date:(NSString *)dateStr url:(NSString *)url
{
	//등록될 내용과 동일한 정보가 이미 있을 경우 등록된 것으로 판단한다.
	if ([self isHaveEventNotification:eventId message:msg date:dateStr url:url]) {
		return YES;
	}
	
	//년,월,일,시,분,초가 잘못된 내용일 경우 실패를 리턴한다.
	if ([[dateStr trim] length] != 14) {
		return NO;
	}
	
	//date를 NSDate형으로 변환한다.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSDate *dateFromString = [dateFormatter dateFromString:dateStr];
	
	//UTO 시간이므로 9시간을 더해준다.
	dateFromString = [dateFromString dateByAddingTimeInterval:9 * 60 * 60];
	
	//현재시간을 가져온다.
	NSDate *nowDate = [NSDate date];
	nowDate = [nowDate dateByAddingTimeInterval:9 * 60 * 60];

	//현재시간과 이벤트시간을 비교하여 지나간 이벤트인지 확인한다.
	NSInteger second = [Modules getDistanceDateWithStartDate:nowDate EndDate:dateFromString];

	//등록할 시간이 지났거나, 현재시간일 경우 등록하지않는다.
	if (second <= 0) {
		return NO;
	}
	
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
	if (localNotification == nil) return NO;

	//위의 9시간을 더해준 사항은 값을 현재시간과 비교하기위해서고, 실제 입력시에는 받아온 시간 그대로 넣는다.
	localNotification.fireDate		= [dateFormatter dateFromString:dateStr];;
	localNotification.timeZone		= [NSTimeZone systemTimeZone];
	localNotification.alertBody		= msg;
	localNotification.alertAction	= @"이벤트 보기";
	localNotification.soundName		= UILocalNotificationDefaultSoundName;
	localNotification.applicationIconBadgeNumber = 0;

	NSDictionary *notiDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  eventId, @"eventid",
							  msg, @"message",
							  dateStr, @"date",
							  url, @"eventurl",
							  nil];
	localNotification.userInfo = notiDict;

	// Schedule the notification
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	
	return YES;
}

- (BOOL)removeLocalNotification:(NSString *)eventId
{
	for (int i=[[UIApplication sharedApplication] scheduledLocalNotifications].count-1; i>=0; i--) {
		UILocalNotification *localNotification = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
		NSDictionary *dict = localNotification.userInfo;
		
		NSString *tEventId = [dict objectForKey:@"eventid"];
		
		if ([tEventId isEqualToString:eventId]) {
			[[UIApplication sharedApplication] cancelLocalNotification:localNotification];
		}
	}
	
	return YES;
}

//모든 알람을 삭제한다.
- (void)removeAllLocalNotification
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//이미 지나간 시간에 대한 알람을 삭제한다.
- (void)removeOldLocalNotification
{
	NSLog(@"removeOldLocalNotification");
	
	for (int i=[[UIApplication sharedApplication] scheduledLocalNotifications].count-1; i>=0; i--) {
		UILocalNotification *localNotification = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
		NSDictionary *dict = localNotification.userInfo;
		
		NSString *dateStr = [dict objectForKey:@"date"];
		
		//date를 NSDate형으로 변환한다.
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
		[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
		NSDate *dateFromString = [dateFormatter dateFromString:dateStr];
		
		//UTO 시간이므로 9시간을 더해준다.
		dateFromString = [dateFromString dateByAddingTimeInterval:9 * 60 * 60];
		
		//현재시간을 가져온다.
		NSDate *nowDate = [NSDate date];
		nowDate = [nowDate dateByAddingTimeInterval:9 * 60 * 60];
		
		//현재시간과 이벤트시간을 비교하여 지나간 이벤트인지 확인한다.
		NSInteger second = [Modules getDistanceDateWithStartDate:nowDate EndDate:dateFromString];
		
		//등록할 시간이 지났거나, 현재시간일 경우 등록하지않는다.
		if (second <= 0) {
			[[UIApplication sharedApplication] cancelLocalNotification:localNotification];
		}
		
		NSLog(@"second : %ld", (long)second);
	}
}


#pragma -mark go to Event Webview
- (void)gotoEventWebViewWithUrl:(NSString *)url
{
	AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if (NO == app.isFinishedHomeLoad) {
		return [self performSelector:@selector(gotoEventWebViewWithUrl:) withObject:url afterDelay:0.1f];
	}

	//팝업뷰가 있으면 닫기
	if ([self closePopoverView]) {
		return [self performSelector:@selector(gotoEventWebViewWithUrl:) withObject:url afterDelay:0.4f];
	}
	
	if (![app.homeViewController.navigationController.viewControllers.lastObject isKindOfClass:[CPHomeViewController class]]) {
		[app.homeViewController.navigationController popToRootViewControllerAnimated:YES];
		
		return [self performSelector:@selector(gotoEventWebViewWithUrl:) withObject:url afterDelay:0.4f];
	}
	else {
		//페이지 이동
		CPHomeViewController *homeViewController = app.homeViewController;
		[homeViewController openSubWebView:url];
	}
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

- (void)addInsertEventAlarmLogWithEventId:(NSString *)eventId
{
	if ([[eventId trim] length] > 0) {
		[[AccessLog sharedInstance] sendAccessLogWithUrl:@"EVTALARM" key:eventId item:@"INSERT_ALARM"];
	}
}

- (void)addOpenEventPageLogWithEventId:(NSString *)eventId
{
	if ([[eventId trim] length] > 0) {
		[[AccessLog sharedInstance] sendAccessLogWithUrl:@"EVTALARM" key:eventId item:@"OPEN_EVTPAGE"];
	}
}

@end
