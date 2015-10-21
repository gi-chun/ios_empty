//
//  CPProductBadgeView.h
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kBadgeTypeFreeDelivery = @"freeDlv";      // 무료배송
static NSString *const kBadgeTypeTMembership = @"tMember";       // T멤버십
static NSString *const kBadgeTypeMileage = @"mileage";           // 마일리지
static NSString *const kBadgeTypeMySelect = @"myWay";            // 내맘대로
static NSString *const kBadgeTypeCardDiscount = @"discountCard"; // 카드할인

static NSString *const kBadgeTypeFreeDeliveryV2 = @"01"; // 무료배송 API v2

typedef NS_ENUM(NSUInteger, ProductBadgeType)
{
    ProductBadgeTypeRound,
    ProductBadgeTypeRectangle
};

@interface CPProductBadgeView : UIView

- (void)releaseItem;

@property (nonatomic, assign) ProductBadgeType badgeType;
@property (nonatomic, assign) BOOL isProductDetail;
@property (nonatomic, strong) NSArray *badges;
@property (nonatomic, strong) NSString *myDiscountRate;

@end
