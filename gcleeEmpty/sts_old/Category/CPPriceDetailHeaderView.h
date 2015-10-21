//
//  CPPriceDetailHeaderView.h
//  11st
//
//  Created by 김응학 on 2015. 7. 7..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CPPriceDetailHeaderTypeNone                     = 0,
    CPPriceDetailHeaderTypeRelatedModels,
    CPPriceDetailHeaderTypeSpec,
    CPPriceDetailHeaderTypeCompPrcList,
    CPPriceDetailHeaderTypeReviewList,
    CPPriceDetailHeaderTypeSatisfyScore,
    CPPriceDetailHeaderTypeSaleGraph,
    CPPriceDetailHeaderTypeSameCategoryModels,
    CPPriceDetailHeaderTypeSameBrandModels,
    CPPriceDetailHeaderTypeBestProducts
} CPPriceDetailHeaderType;


@protocol CPPriceDetailHeaderViewDelegate;

@interface CPPriceDetailHeaderView : UIView

@property (nonatomic, weak) id <CPPriceDetailHeaderViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, assign) CPPriceDetailHeaderType type;

@end


@protocol CPPriceDetailHeaderViewDelegate <NSObject>
@optional
- (void)priceDetailHeaderOnTouchOpenYn:(BOOL)isOpen type:(CPPriceDetailHeaderType)type;
- (void)priceDetailHeaderOnTouchFilterPopup:(NSString *)filterTypeStr;
- (void)priceDetailHeaderOnTOuchReviewTabs:(NSInteger)selectIdx;

@end