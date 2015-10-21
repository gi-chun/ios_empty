//
//  CPAddressBookManager.m
//  11st
//
//  Created by spearhead on 2014. 12. 1..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPAddressBookManager.h"
#import "CPAddressBookInfo.h"
#import <AddressBook/AddressBook.h>

@interface CPAddressBookManager ()
{
    ABAddressBookRef addressBook;
}

@end

@implementation CPAddressBookManager

+ (CPAddressBookManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static CPAddressBookManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CPAddressBookManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    
    return self;
}

- (BOOL)isAllowed
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)allowPermission:(CPAddressBookManagerRequestType)requestType showMessage:(BOOL)showMessage
{
    //    CFErrorRef error = nil;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                //                    if (requestAddressBook) {
                //                        [self requestInternationalMobileNumberList:addressBook];
                //                    }
                if (requestType == CPAddressBookManagerRequestFetchAddressBook) {
                    [self fetchAddressBook];
                }
//                else if (requestType == CPAddressBookManagerRequestAutoInsertFriends) {
//                    [self autoInsertFriends];
//                }
                
            }
            else {
                //설정 > 개인 정보 보호 > 연락처 정보를 활성화 해주세요.
                if (showMessage) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림"
                                                                    message:@"설정 > 개인 정보 보호 > 연락처 정보를 활성화 해주세요."
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                                          otherButtonTitles:nil];
                    [alert setDelegate:self];
                    [alert show];
                }
                else {
                    NSLog(@"친구 등록 실패: 권한이 없음");
                }
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        if (requestType == CPAddressBookManagerRequestFetchAddressBook) {
            [self fetchAddressBook];
        }
//        else if (requestType == CPAddressBookManagerRequestAutoInsertFriends) {
//            [self autoInsertFriends];
//        }
    }
    else {
        // 설정 > 개인 정보 보호 > 연락처 정보를 활성화 해주세요.
//        if (showMessage) {
//            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:SERVICE_GUIDE_STRING
//                                                             andMessage:UNSTABLE_NETWORK_CHECK_SETTING_STRING];
//            [alertView addButtonWithTitle:CONFIRM_STRING
//                                     type:SIAlertViewButtonTypeDestructive
//                                  handler:^(SIAlertView *alert) {
//                                      if (self.delegate && [self.delegate respondsToSelector:@selector(allowPermissionFailed)]) {
//                                          [self.delegate allowPermissionFailed];
//                                      }
//                                  }];
//            [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
//            [alertView setTransitionStyle:SIAlertViewTransitionStyleBounce];
//            [alertView show];
//        }
//        else {
//            NSLog(@"친구 등록 실패: 권한이 없음");
//        }
    }
    
}

#pragma mark - Data Fecth Methods

- (NSMutableArray *)allOfAddressBookList
{
    NSMutableArray *addressBookList = [[NSMutableArray alloc] init];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex countOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i = 0; i < countOfPeople; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref,kABPersonLastNameProperty);
        
        if (firstName == nil) {
            firstName = @"";
        }
        
        if (lastName == nil) {
            lastName = @"";
        }
        
        NSString *fullName = nil;
        if ([lastName isEqualToString:@""]) {
            fullName = [NSString stringWithFormat:@"%@", firstName];
        }
        else {
            fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
        }
        
        // 사진 썸네일 추출
        UIImage *thumbnail = nil;
        if (ABPersonHasImageData(ref)) {
            NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
            thumbnail = [[UIImage alloc] initWithData:contactImageData];
        }
        
        NSString *phoneNumber = nil;
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            CFStringRef tempRef = (CFStringRef)ABMultiValueCopyValueAtIndex(phones, j);
            NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, j);
            
            if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                if (tempRef != nil) {
                    phoneNumber = [NSString stringWithFormat:@"%@", (__bridge NSString *)tempRef];
                    //                    NSLog(@"Mobile: %@-%d", phoneNumber, i);
                }
            }
            else if ([label isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                if (tempRef != nil) {
                    phoneNumber = [NSString stringWithFormat:@"%@", (__bridge NSString *)tempRef];
                    //                    NSLog(@"iPhone: %@-%d", phoneNumber, i);
                }
            }
            
            CFRelease(tempRef);
            
            //            if (phoneNumber != nil) {
            //                break;
            //            }
        }
        
        if (phoneNumber != nil && ![phoneNumber isEqualToString:@""] && [self isValidMobilePhoneNumber:phoneNumber]) {
            CPAddressBookInfo *data = [[CPAddressBookInfo alloc] init];
            [data setName:fullName];
            [data setThumbnail:thumbnail];
            [data setPhoneNumber:phoneNumber];
            
            [addressBookList addObject:data];
        }
    }
    
    CFRelease(allPeople);
    
    return addressBookList;
}

- (BOOL)isValidMobilePhoneNumber:(NSString *)number
{
    NSString *pattern = @"(010|011|016|017|018|019)-([0-9]{3,4})-([0-9]{4})";
    
    NSRange range = [number rangeOfString:pattern options:NSRegularExpressionSearch];
    
    if (range.length > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSMutableArray *)internationalMobileNumberList
{
    NSMutableArray *mobileNumberList = [NSMutableArray array];
//    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
//    
//    @try {
//        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
//        CFIndex countOfPeople = ABAddressBookGetPersonCount(addressBook);
//        
//        for (int i = 0; i < countOfPeople; i++) {
//            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
//            ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
//            
//            for (CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
//                CFStringRef tempRef = (CFStringRef)ABMultiValueCopyValueAtIndex(phones, j);
//                
//                NSString *mobileNumber = nil;
//                if (tempRef != nil) {
//                    mobileNumber = [NSString stringWithFormat:@"%@", (__bridge NSString *)tempRef];
//                }
//                
//                if (mobileNumber != nil && ![mobileNumber isEqualToString:@""]) {
//                    
//                    NSError *aError = nil;
//                    NBPhoneNumber *aPhoneNumber = [phoneUtil parse:mobileNumber
//                                                     defaultRegion:[CMUtil countryCode]
//                                                             error:&aError];
//                    
//                    
//                    
//                    NBEPhoneNumberType type = [phoneUtil getNumberType:aPhoneNumber];
//                    BOOL isValidType = (type == NBEPhoneNumberTypeMOBILE);
//                    
//                    if ([phoneUtil isValidNumber:aPhoneNumber] && isValidType) {
//                        
//                        //                    NSString *nationalMobileNumber = [phoneUtil format:aPhoneNumber
//                        //                                                           numberFormat:NBEPhoneNumberFormatNATIONAL
//                        //                                                                  error:nil];
//                        //
//                        //                    nationalMobileNumber = [nationalMobileNumber stringByReplacingOccurrencesOfString:@"-"
//                        //                                                                                           withString:@""];
//                        //                    NSLog(@"phoneNumber: %@", nationalMobileNumber);
//                        //                    NSString *formattedMobileNumber = [NSString stringWithFormat:@"%ld%@", aPhoneNumber.countryCode, nationalMobileNumber];
//                        NSString *formattedMobileNumber = [phoneUtil format:aPhoneNumber
//                                                               numberFormat:NBEPhoneNumberFormatE164
//                                                                      error:nil];
//                        
//                        [mobileNumberList addObject:[formattedMobileNumber stringByReplacingOccurrencesOfString:@"+"
//                                                                                                     withString:@""]];
//                    }
//                }
//                
//                CFRelease(tempRef);
//            }
//        }
//        
//        CFRelease(allPeople);
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",[exception description]);
//    }
    
    return mobileNumberList;
}

- (void)fetchAddressBook
{
    __block NSArray *data = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        data = [self allOfAddressBookList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([data count] > 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchAddressBookSuccess:)]) {
                    [self.delegate fetchAddressBookSuccess:data];
                }
            }
            else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(fetchAddressBookFailed:)]) {
                    [self.delegate fetchAddressBookFailed:nil];
                }
            }
        });
    });
    
}

- (void)dealloc
{
    CFRelease(addressBook);
}

@end
