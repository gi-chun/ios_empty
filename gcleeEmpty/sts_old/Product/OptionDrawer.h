//
//  OptionDrawer.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OptionItemView.h"
#import "OptionItemCell.h"

typedef NS_ENUM(NSUInteger, openOptionType)
{
    openOptionTypePurchase,
    openOptionTypeGift,
    openOptionTypeDownload,
    openOptionTypeBasket,
    openOptionTypeShockingdeal
};

@class MyPriceModel;
@class OptionDrawer;

@protocol OptionDrawerDelegate;

@interface OptionDrawer : UIView <UIGestureRecognizerDelegate,
                                UITableViewDataSource,
                                UITableViewDelegate,
                                UITextFieldDelegate,
                                OptionItemViewDelegate,
                                UIAlertViewDelegate>

@property (nonatomic, weak) id<OptionDrawerDelegate> delegate;
@property (nonatomic, strong) UIView *bottomView, *drawerBar;

@property (nonatomic, assign) CGRect startViewFrame, startBottomViewFrame, superviewFrame;
@property (nonatomic, assign) CGFloat openMinimumHeight, openOffset;

@property (nonatomic, strong) NSDictionary *optionDictionary, *priceInfoDictionary, *deliveryInfoDictionary, *urlDictionary, *martDictionary, *martPromotionDictionary;
@property (nonatomic, strong) NSDictionary *itemDetailInfo;
@property (nonatomic, strong) NSDictionary *productInfo;
@property (nonatomic, strong) NSString *trTypeCd;
@property (nonatomic, strong) NSArray *periodInfo;
@property (nonatomic, strong) NSMutableArray *myCoupons;

@property (nonatomic, readonly) BOOL isDrawerOpen;
@property (nonatomic, readonly) BOOL isGift;
@property (nonatomic, assign) BOOL isDlvCstPayChecked;
@property (nonatomic, assign) BOOL isVisitDlvChecked;
@property (nonatomic, assign) BOOL isPrdPromotionAlert;

+ (CGFloat)ArrowButtonHeight;
- (void)setOptionType:(openOptionType)openType;
- (void)validateOpenDrawer:(BOOL)animated;
- (void)openDrawer:(BOOL)animated;
- (void)closeDrawer;
- (void)closeDrawerNoAnimation;
- (void)onClickCartList:(id)sender;
- (void)localizedCouponDiscountPrice;
- (void)addOptionByName:(NSString *)optionName;

@end


@protocol OptionDrawerDelegate <NSObject>
@optional
- (void)requestItemPurchase:(OptionDrawer *)optionDrawer requestUrl:(NSString *)url;
- (void)requestItemWishList:(OptionDrawer *)optionDrawer requestUrl:(NSString *)url;
- (void)requestLogin:(OptionDrawer *)optionDrawer;
- (void)showModalView:(UIView *)tView title:(NSString *)title;
- (void)didTouchMyCoupon:(NSString *)url;
- (BOOL)isVisitDlvChecked;

@end
