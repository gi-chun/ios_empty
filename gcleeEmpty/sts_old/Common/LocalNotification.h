#import <Foundation/Foundation.h>

#define LOCAL_ALARM [LocalNotification sharedSingleton]

@interface LocalNotification : NSObject
{
	
}

+ (LocalNotification *)sharedSingleton;

- (void)showNotificationList;
- (BOOL)addLocalNotification:(NSString *)eventId message:(NSString *)msg date:(NSString *)dateStr url:(NSString *)url;
- (BOOL)removeLocalNotification:(NSString *)eventId;
- (void)removeAllLocalNotification;
- (void)removeOldLocalNotification;

- (void)gotoEventWebViewWithUrl:(NSString *)url;
- (void)addInsertEventAlarmLogWithEventId:(NSString *)eventId;
- (void)addOpenEventPageLogWithEventId:(NSString *)eventId;

@end
