//
//  CPPayment.h
//  11st
//
//  Created by spearhead on 2014. 9. 4..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPPaymentDelegate;

@interface CPPayment : NSObject

@property (nonatomic, weak) id<CPPaymentDelegate> delegate;

+ (CPPayment *)getInstance;

- (void)openPayment:(NSString *)url;
- (BOOL)isPaymentUrl:(NSString *)url;

@end

@protocol CPPaymentDelegate <NSObject>
@optional

- (void)paymentRequest:(NSURLRequest *)request;
- (void)paymentExecuteScript:(NSString *)script;

@end

