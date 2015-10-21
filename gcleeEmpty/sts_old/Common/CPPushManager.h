#import <Foundation/Foundation.h>

#define PUSH_MANAGER	[CPPushManager sharedSingleton]

@interface CPPushManager : NSObject
{
	
}

+ (CPPushManager *)sharedSingleton;

- (void)saveDeviceInfo;
- (void)savePushKey;
- (void)showPushMessage:(NSDictionary *)info;
@end
