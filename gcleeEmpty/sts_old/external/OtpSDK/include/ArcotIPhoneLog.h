//
//  ArcotIPhoneLog.h
//  ArcotOTPFrameWork
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>
#define ArcotIPhoneLog  AID_OTPiPhoneLog

#define kLogERROR					0
#define kLogWARNING					1
#define kLogDEBUG					2
#define LOGFILE_NAME				@"arcototplog.txt"
#define LOGMODE_KEY					@"logMode"

@interface AID_OTPiPhoneLog : NSObject {
	
}

+ (void)createLogFileIfNeeded;
+ (NSString *)getLogFilePath;
+ (void)writeLogWithSeverity:(NSInteger)sevLevel message:(NSString *)log; 
+ (void) enableLogging;
+ (void) disableLogging;
+ (NSMutableString *) getDeviceInformation;
+ (void) writeDeviceInformation;

@end
