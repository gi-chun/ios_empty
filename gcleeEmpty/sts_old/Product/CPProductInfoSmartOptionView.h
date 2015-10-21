//
//  CPProductInfoSmartOptionView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPProductInfoSmartOptionView;
@class ProductSmartOptionModel;

@protocol CPProductInfoSmartOptionViewDelegate <NSObject>

@optional
- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view didClickedOptionDetailButton:(ProductSmartOptionModel *)option;
- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view didClickedOptionSelectButton:(ProductSmartOptionModel *)option;

- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveMorePage:(NSString *)typeStr;
- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveUrl:(NSString *)url;
- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveProductDetailController:(NSString *)prdNo;
- (void)productInfoSmartOptionView:(CPProductInfoSmartOptionView *)view moveProductDetailControllerWithDict:(NSDictionary *)prdDict;

@end

@interface CPProductInfoSmartOptionView : UIView

@property (nonatomic, strong) NSArray *optionItems;
@property (nonatomic, weak) id<CPProductInfoSmartOptionViewDelegate> delegate;

- (void)releaseItem;
- (instancetype)initWithFrame:(CGRect)frame withProductDetailInfo:(NSDictionary *)productDetailInfo;

- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;

@end