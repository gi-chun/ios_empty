//
//  CPDescriptionBottomView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPDescriptionBottomTownShopBranch.h"
#import "CPDescriptionBottomTitleView.h"

@protocol CPDescriptionBottomViewDelegate;

@interface CPDescriptionBottomView : UIView

@property (nonatomic, weak) id <CPDescriptionBottomViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
- (CGFloat)getMaxY;
- (void)startAutoScroll;
- (void)stopAutoScroll;

@end

@protocol CPDescriptionBottomViewDelegate <NSObject>
@optional
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view isLoading:(NSNumber *)loading;
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)descriptionBottomView:(CPDescriptionBottomView *)view addContentHeight:(CGFloat)height;
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
- (void)didTouchCategoryArea:(NSString *)url;
- (void)didTouchMapButton:(NSString *)linkUrl;
- (void)didTouchBrandShop:(NSString *)linkUrl;
- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;

@end