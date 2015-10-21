//
//  CPProductDescriptionView.h
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPDescriptionBottomTownShopBranch.h"
#import "CPDescriptionBottomTitleView.h"

@protocol CPProductDescriptionViewDelegate;

@interface CPProductDescriptionView : UIView

@property (nonatomic, weak) id <CPProductDescriptionViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;
- (void)resumeImageDownloading;
- (void)pauseImageDownloading;
- (void)cancelImageDownloading;
- (void)startAutoScroll;
- (void)stopAutoScroll;
- (void)removeMemory;

@end

@protocol CPProductDescriptionViewDelegate <NSObject>
@optional
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view isLoading:(NSNumber *)loading;
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)productDescriptionView:(CPProductDescriptionView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)didTouchTabMove:(NSInteger)pageIndex;
- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab;
- (void)didTouchSearchKeyword:(NSString *)keyword;
- (void)didTouchPrdSelInfo:(NSString *)url;
- (void)didTouchProInfoNotice:(NSString *)url;
- (void)didTouchInfoButton:(NSString *)url;
- (void)didTouchSellerInfo:(NSString *)url;
- (void)didTouchShowPrdAll:(NSString *)url;
- (void)didTouchSellerPrd:(NSString *)prdNo;
- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type;
- (void)didTouchReviewCell:(NSString *)url;
- (void)didTouchSellerNotice:(NSString *)url;
- (void)didTouchCategoryArea:(NSString *)url;
- (void)didTouchMapButton:(NSString *)linkUrl;
- (void)didTouchBrandShop:(NSString *)linkUrl;
- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;

- (void)productExchangeView:(CPProductDescriptionView *)view isLoading:(NSNumber *)loading;
- (void)productExchangeView:(CPProductDescriptionView *)view scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)smartOptionDidClickedOptionDetailAtUrl:(NSString *)url;
- (void)smartOptionDidClickedOptionSelectButtonAtOptionName:(NSString *)optionName;

//- (void)ProductInfoDescriptView:(ProductInfoDescriptView *)item moveMorePage:(NSString *)typeStr;
//- (void)ProductInfoDescriptView:(ProductInfoDescriptView *)view moveUrl:(NSString *)url;
//- (void)ProductInfoDescriptView:(ProductInfoDescriptView *)view moveProductDetailController:(NSString *)prdNo;
//- (void)ProductInfoDescriptView:(ProductInfoDescriptView *)view moveProductDetailControllerWithDict:(NSDictionary *)prdDict;
@end