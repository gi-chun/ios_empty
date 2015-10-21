//
//  DeviceLock.h
//  arcotOTP
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 This class specifies the interface for a device lock provider. A device lock
 provider is used to obtain a unique identifier from the underlying device,
 that may be used for device locking of an account. This means that account
 information stored on one device cannot be copied and used on another device.
  
 */
#define DeviceLock  AIDOTP_DeviceLock

@interface AIDOTP_DeviceLock : NSObject {
	NSString *lockkey;

}

/**
 Returns the unique identifier for the device
 */
@property (nonatomic, retain) NSString *lockkey;

/**
 Returns the unique identifier for the device
  
 @return device identifier
 */
- (NSString *) getKey;

@end
