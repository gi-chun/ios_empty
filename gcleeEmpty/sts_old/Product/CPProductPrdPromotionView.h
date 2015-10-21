//
//  CPProductPrdPromotionView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductPrdPromotionViewDelegate;

@interface CPProductPrdPromotionView : UIView

@property (nonatomic, weak) id<CPProductPrdPromotionViewDelegate> delegate;
//사용자가 선택한 덤 index
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
//덤정보 세팅
- (void)setPromotionView;

@end

@protocol CPProductPrdPromotionViewDelegate <NSObject>
@optional
- (void)didTouchSeriesDetailButton:(NSString *)url;
- (void)drawLayerPrdPromotionList:(id)sender;

@end