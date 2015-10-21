//
//  CPProductViewController.h
//  11st
//
//  Created by spearhead on 2015. 6. 23..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AfterLoginActionStatus)
{
    AfterLoginActionStatusNone,
    AfterLoginActionStatusCart,
    AfterLoginActionStatusLike,
    AfterLoginActionStatusPurchase,
    AfterLoginActionStatusAddWishList,
    AfterLoginActionStatusQnaWrite,
    AfterLoginActionStatusMyCoupon
};

@interface CPProductViewController : UIViewController

- (id)initWithProductNumber:(NSString *)aProductNumber;
- (id)initWithProductNumber:(NSString *)aProductNumber isPop:(BOOL)isPop;
- (id)initWithProductNumber:(NSString *)aProductNumber isPop:(BOOL)isPop parameters:(NSDictionary *)parameters;
- (NSString *)productNumber;

@end
