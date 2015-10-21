//
//  Store.h
//  arcotOTP
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

/**
 
 This interface is used for managing persistence of ArcotOTP account information on to the physical device.
 If there is no storage set in the OTP class, OTP class uses the defualt database implementation of this interface. 
 The default database implementation of this interface already integrated with the library. Please make sure to 
 include the dist/include/ArcotOTP.db file in the projects resource group.
 
  @auhor Arcot Systems Inc
 
 */
#define Store AIDOTP_Store

@interface AIDOTP_Store : NSObject {

}

/**
 Load all accounts
 */
- (NSMutableArray *) loadAll;

/**
 Load the account corresponding to the given key
 */
- (Account *)load:(NSString *) key;

/**
 Store the given account
 */
- (void) save:(Account *)data;

/**
 Deletes the account corresponding to the given key
 */
- (void)remove:(NSString *) key;

@end
