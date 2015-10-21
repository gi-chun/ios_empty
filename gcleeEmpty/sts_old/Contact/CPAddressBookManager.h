//
//  CPAddressBookManager.h
//  11st
//
//  Created by spearhead on 2014. 12. 1..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CPAddressBookManagerRequestType) {
    CPAddressBookManagerRequestPermission = 0,
    CPAddressBookManagerRequestFetchAddressBook,
    CPAddressBookManagerRequestAutoInsertFriends
};

@protocol CPAddressBookManagerDelegate;

@interface CPAddressBookManager : NSObject

@property (nonatomic, weak) id<CPAddressBookManagerDelegate> delegate;

+ (CPAddressBookManager *)sharedInstance;
- (BOOL)isAllowed;
- (void)allowPermission:(CPAddressBookManagerRequestType)requestType showMessage:(BOOL)showMessage;

@end

@protocol CPAddressBookManagerDelegate <NSObject>
@optional

- (void)fetchAddressBookSuccess:(NSArray *)data;
- (void)fetchAddressBookFailed:(NSError *)error;

@end