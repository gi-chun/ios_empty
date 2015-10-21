//
//  CPProductDeliveryView.h
//  11st
//
//  Created by spearhead on 2015. 6. 26..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductDeliveryViewDelegate;

@interface CPProductDeliveryView : UIView

@property (nonatomic, weak) id<CPProductDeliveryViewDelegate> delegate;

//사용자가 선택한 주소의 index
@property (nonatomic, assign) NSInteger selectedIndex;
//사용자가 선택한 배송점의 index
@property (nonatomic, assign) NSInteger selectedShopIndex;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct productNumber:(NSString *)aProductNumber dlvCstPayChecked:(BOOL)aIsDlvCstPayChecked visitDlvChecked:(BOOL)aIsVisitDlvChecked;
//배송지정보 세팅
- (void)setDeliveryAddressView;
//배송점정보 세팅
- (void)setShopAddressView;
//상품수령시 결제(착불) 노출여부
- (BOOL)isDlvCstPayChecked;
//방문수령체크여부
- (BOOL)isVisitDlvChecked;
- (CGFloat)getListButtonY;
- (CGFloat)getShopListButtonY;
- (void)reloadView:(NSString *)url;
- (void)checkDlvCstPayYn;

@end

@protocol CPProductDeliveryViewDelegate <NSObject>
@optional
- (void)didTouchExpandButton:(CPProductViewType)viewType height:(CGFloat)height;
- (void)didTouchVisitDlvLink:(NSString *)linkUrl;
- (void)didTouchAddDeliveryAddress:(NSString *)linkUrl;
- (void)didTouchDlvCstPayCheckButton:(BOOL)isCheck;
- (void)didTouchVisitDlvCheckButton:(BOOL)isCheck;
- (void)drawLayerDeliveryList:(id)sender listInfo:(NSDictionary *)listInfo;
- (void)drawLayerShopList:(id)sender listInfo:(NSArray *)listInfo;
- (void)didTouchTextIconButton:(NSString *)linkUrl helpTitle:(NSString *)helpTitle;
- (void)removeDeliveryListView;
- (void)productReload;

@end