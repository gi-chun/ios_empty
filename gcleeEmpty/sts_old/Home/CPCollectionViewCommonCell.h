//
//  CPCollectionViewCommonCell.h
//  11st
//
//  Created by spearhead on 2015. 5. 18..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPCollectionData.h"
#import "TTTAttributedLabel.h"
#import "CPBlurImageView.h"
#import "iCarousel.h"

#define POPULAR_SEARCH_TEXT_TAG 1000

@class CPTouchActionView;

typedef NS_ENUM(NSUInteger, CPHotProductButtonType){
    CPHotProductButtonTypeFirst = 0,
    CPHotProductButtonTypeSecond,
    CPHotProductButtonTypeThird
};

typedef NS_ENUM(NSUInteger, CPCellType){
    CPCellTypeCommonProduct = 0,
    CPCellTypeBestProductCategory,
    CPCellTypeBannerProduct,
    CPCellTypeLineBanner,
    CPCellTypeShockingDealAppLink,
    CPCellTypeDetailCtgr,
    CPCellTypeCtgrHotClick,
    CPCellTypeCtgrBest,
    CPCellTypeCtgrDealBest,
    CPCellTypeSearchProduct,
    CPCellTypeSearchProductGrid,
    CPCellTypeSearchProductBanner,
    CPCellTypeShockingDealProduct,
    CPCellTypeSearchCaption,
    CPCellTypeRelatedSearchText,
    CPCellTypeRecommendSearchText,
    CPCellTypeSearchFilter,
    CPCellTypeSearchTopTab,
    CPCellTypeSorting,
    CPCellTypeCategoryNavi,
    CPCellTypeSearchMore,
    CPCellTypeModelSearchProduct,
    CPCellTypeNoSearchData,
    CPCellTypeSearchHotProduct,
    CPCellTypeTworldDirect,
    CPCellTypeNoData
};

@class CPThumbnailView;

@protocol CPCollectionViewCommonCellDelegate;

@interface CPCollectionViewCommonCell : UICollectionViewCell <iCarouselDelegate,
                                                            iCarouselDataSource,
                                                            TTTAttributedLabelDelegate>

@property (nonatomic, weak) id<CPCollectionViewCommonCellDelegate> delegate;
@property (nonatomic, strong) CPCollectionData *collectionData;
@property (nonatomic, strong) NSDictionary *dicData;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) id callerView;

@property (nonatomic, strong) UIView *shadowView;

//CommonProduct
@property (nonatomic, strong) UIView *commonProductCellContentView;
@property (nonatomic, strong) CPThumbnailView *commonProductThumbnailView;
@property (nonatomic, strong) UILabel *commonProductRankingLabel;
@property (nonatomic, strong) UILabel *commonProductProductNameLabel;
@property (nonatomic, strong) UILabel *commonProductPriceLabel;
@property (nonatomic, strong) UIView *commonProductLineView;
@property (nonatomic, strong) UILabel *commonProductDiscountLabel;
@property (nonatomic, strong) UILabel *commonProductUnitLabel;
@property (nonatomic, strong) UILabel *commonProductFreeShipLabel;
@property (nonatomic, strong) UIButton *commonProductBlankButton;

//BestProductCategory
@property (nonatomic, strong) UIView *bestProductCategoryCellContentView;

//BannerProduct
@property (nonatomic, strong) UIView *bannerProductCellContentView;
@property (nonatomic, strong) CPThumbnailView *bannerProductThumbnailView;
@property (nonatomic, strong) UIView *bannerProductProductInfoView;
@property (nonatomic, strong) UILabel *bannerProductProductNameLabel;
@property (nonatomic, strong) TTTAttributedLabel*bannerProductDiscountRate;
@property (nonatomic, strong) UILabel *bannerProductPriceLabel;
@property (nonatomic, strong) UILabel *bannerProductPriceUnitLabel;
@property (nonatomic, strong) UIView *bannerProductLineView;
@property (nonatomic, strong) UILabel *bannerProductDiscountLabel;
@property (nonatomic, strong) UILabel *bannerProductUnitLabel;
@property (nonatomic, strong) UIView *bannerProductStampView;
@property (nonatomic, strong) UIImageView *bannerProductTMembershipImageView;
@property (nonatomic, strong) UIImageView *bannerProductMileageImageView;
@property (nonatomic, strong) UIImageView *bannerProductFreeShipImageView;
@property (nonatomic, strong) UIButton *bannerProductPurchaseCountButton;
@property (nonatomic, strong) UIView *bannerProductPurchaseTitleView;
@property (nonatomic, strong) UILabel *bannerProductPurchaseCountLabel;
@property (nonatomic, strong) UILabel *bannerProductPurchaseUnitLabel;
@property (nonatomic, strong) UIButton *bannerProductRelativeProductButton;
@property (nonatomic, strong) UILabel *bannerProductRelativeProductLabel;
@property (nonatomic, strong) UIImageView *bannerProductRelativeProductImage;
@property (nonatomic, strong) UIButton *bannerProductBlankButton;
@property (nonatomic, strong) UIButton *bannerProductVideoPlayButton;

//LineBanner
@property (nonatomic, strong) UIView *lineBannerContentView;
@property (nonatomic, strong) CPBlurImageView *lineBannerImageView;
@property (nonatomic, strong) UIButton *lineBannerButton;

//ShockingDealAppLink
@property (nonatomic, strong) UIView *shockingDealAppLinkCellContentView;
@property (nonatomic, strong) UIButton *shockingDealAppLinkMoreButton;
@property (nonatomic, strong) UILabel *shockingDealAppLinkMoreTitleLabel;
@property (nonatomic, strong) UIImageView *shockingDealAppLinkMoreImageView;

//ctgrHotClick
@property (nonatomic, strong) UIView *ctgrHotClickCellContentView;

//ctgrBest
@property (nonatomic, strong) UIView *ctgrBestCellContentView;

//ctgrDealBest
@property (nonatomic, strong) UIView *ctgrDealBestCellContentView;

//tWorldDirect
@property (nonatomic, strong) UIView *tWorldDirectCellContentView;

//searchProduct
@property (nonatomic, strong) UIView *searchProductCellContentView;
@property (nonatomic, strong) CPThumbnailView *searchProductThumbnailView;
@property (nonatomic, strong) UIImageView *searchProductShockingDealImageView;
@property (nonatomic, strong) UIView *searchProductAdultView;
@property (nonatomic, strong) UIImageView *searchProductAdultImageView;
@property (nonatomic, strong) UIView *searchProductIconView;
@property (nonatomic, strong) UILabel *searchProductLabel;
@property (nonatomic, strong) TTTAttributedLabel *searchProductDiscountLabel;
@property (nonatomic, strong) UILabel *searchProductPriceLabel;
@property (nonatomic, strong) UIView *searchProductPriceLineView;
@property (nonatomic, strong) UIView *searchProductSatisfyView;
@property (nonatomic, strong) UILabel *searchProductReviewCountLabel;
@property (nonatomic, strong) UIButton *searchProductUpdownButton;
@property (nonatomic, strong) UIView *searchProductUnderLineView;
@property (nonatomic, strong) CPTouchActionView *searchProductActionView;
@property (nonatomic, strong) UIView *searchProductSellerView;
@property (nonatomic, strong) UIView *searchProductShadowView;

//searchProductGrid
@property (nonatomic, strong) UIView *searchProductGridCellContentView;
@property (nonatomic, strong) CPThumbnailView *searchProductGridThumbnailView;
@property (nonatomic, strong) UIImageView *searchProductGridShockingDealImageView;
@property (nonatomic, strong) UIView *searchProductGridAdultView;
@property (nonatomic, strong) UIImageView *searchProductGridAdultImageView;
@property (nonatomic, strong) UIView *searchProductGridIconView;
@property (nonatomic, strong) UILabel *searchProductGridLabel;
@property (nonatomic, strong) TTTAttributedLabel *searchProductGridDiscountLabel;
@property (nonatomic, strong) UILabel *searchProductGridPriceLabel;
@property (nonatomic, strong) UIView *searchProductGridPriceLineView;
@property (nonatomic, strong) CPTouchActionView *searchProductGridActionView;

//searchProductBanner
@property (nonatomic, strong) UIView *searchProductBannerCellContentView;
@property (nonatomic, strong) CPThumbnailView *searchProductBannerThumbnailView;
@property (nonatomic, strong) UIImageView *searchProductBannerShockingDealImageView;
@property (nonatomic, strong) UIView *searchProductBannerAdultView;
@property (nonatomic, strong) UIImageView *searchProductBannerAdultImageView;
@property (nonatomic, strong) UIView *searchProductBannerIconView;
@property (nonatomic, strong) UILabel *searchProductBannerLabel;
@property (nonatomic, strong) TTTAttributedLabel *searchProductBannerDiscountLabel;
@property (nonatomic, strong) UILabel *searchProductBannerPriceLabel;
@property (nonatomic, strong) UIView *searchProductBannerPriceLineView;
@property (nonatomic, strong) UIView *searchProductBannerSatisfyView;
@property (nonatomic, strong) UILabel *searchProductBannerReviewCountLabel;
@property (nonatomic, strong) UIButton *searchProductBannerUpdownButton;
@property (nonatomic, strong) UIView *searchProductBannerUnderLineView;
@property (nonatomic, strong) CPTouchActionView *searchProductBannerActionView;
@property (nonatomic, strong) UIView *searchProductBannerSellerView;
@property (nonatomic, strong) UIView *searchProductBannerShadowView;

//shockingDealProduct
@property (nonatomic, strong) UIView *shockingDealProductCellContentView;
@property (nonatomic, strong) iCarousel *shockingDealProductView;
@property (nonatomic, strong) UIView *shockingDealProductPageControlView;
@property (nonatomic, assign) NSInteger shockingDealProductPageIndex;
@property (nonatomic, strong) UIView *shockingDealProductUnderLineView;
@property (nonatomic, strong) UIButton *shockingDealProductRightButton;
@property (nonatomic, strong) UIButton *shockingDealProductLeftButton;

//searchCaption
@property (nonatomic, strong) UIView *searchCaptionCellContentView;
@property (nonatomic, strong) UILabel *searchCaptionTitleLabel;
@property (nonatomic, strong) UILabel *searchCaptionMoreLabel;
@property (nonatomic, strong) UIImageView *searchCaptionIconImageView;
@property (nonatomic, strong) UIButton *searchCaptionPageMoveButton;
@property (nonatomic, strong) UIButton *searchCaptionADButton;

//relatedSearchText
@property (nonatomic, strong) UIView *relatedSearchBackgroundView;
@property (nonatomic, strong) UIView *relatedSearchTextView;
@property (nonatomic, strong) UIImageView *relatedIconImageView;
@property (nonatomic, strong) UIButton *relatedOpenButton;
@property (nonatomic, strong) UILabel *relatedSearchLabel;
@property (nonatomic, strong) UIView *relatedKeywordView;
@property (nonatomic, strong) UIView *relatedSearchLineView;

//recommendSearchText
@property (nonatomic, strong) UIView *recommendSearchTextBackgroundView;
@property (nonatomic, strong) UIView *recommendSearchTextView;
@property (nonatomic, strong) UIImageView *recommendIconImageView;
@property (nonatomic, strong) UILabel *recommendSearchLabel;
@property (nonatomic, strong) UIView *recommendSearchLineView;

//searchFilter
@property (nonatomic, strong) UIView *searchFilterBackgroundView;
@property (nonatomic, strong) UIView *searchFilterView;
@property (nonatomic, strong) UIView *searchFilterLineView;

//searchTopTab
@property (nonatomic, strong) UIView *searchTopTabBackgroundView;
@property (nonatomic, strong) UIView *searchTopTabView;

//sorting
@property (nonatomic, strong) UIView *sortingBackgroundView;
@property (nonatomic, strong) UIView *sortingView;
@property (nonatomic, strong) UILabel *sortingProductTitleLabel;
@property (nonatomic, strong) UILabel *sortingProductCountLabel;
@property (nonatomic, strong) UILabel *sortingProductUnitLabel;
@property (nonatomic, strong) UIButton *sortingSortTypeButton;
@property (nonatomic, strong) UIButton *sortingViewTypeButton;
@property (nonatomic, strong) UIImageView *sortingArrowImageView;
@property (nonatomic, strong) UIView *viewTypeContainerView;
@property (nonatomic, strong) UIView *sortingShadowView;

//categoryNavi
@property (nonatomic, strong) UIView *categoryNaviBackgroundView;
@property (nonatomic, strong) UIView *categoryNaviView;

//searchMore
@property (nonatomic, strong) UIView *searchMoreCellContentView;
@property (nonatomic, strong) UIButton *searchMoreButton;

//modelSearchProduct
@property (nonatomic, strong) UIView *modelSearchProductCellContentView;
@property (nonatomic, strong) CPThumbnailView *modelSearchProductThumbnailView;
@property (nonatomic, strong) UIImageView *modelSearchProductShockingDealImageView;
@property (nonatomic, strong) UIView *modelSearchProductAdultView;
@property (nonatomic, strong) UIImageView *modelSearchProductAdultImageView;
@property (nonatomic, strong) UILabel *modelSearchProductLabel;
@property (nonatomic, strong) TTTAttributedLabel *modelSearchProductDiscountLabel;
@property (nonatomic, strong) UIView *modelSearchProductSatisfyView;
@property (nonatomic, strong) CPTouchActionView *modelSearchProductActionView;
@property (nonatomic, strong) UIImageView *modelSearchProductPriceCompareImageView;

//noSearchData
@property (nonatomic, strong) UIView *noSearchDataCellContentView;
@property (nonatomic, strong) UIImageView *noSearchDataImageView;
@property (nonatomic, strong) UIView *noSearchDataView;

//searchHotProduct
@property (nonatomic, strong) UIView *searchHotProductCellContentView;
@property (nonatomic, strong) CPThumbnailView *searchHotProductFirstImageView;
@property (nonatomic, strong) UIView *searchHotProductFirstAdultView;
@property (nonatomic, strong) UIImageView *searchHotProductFirstAdultImageView;
@property (nonatomic, strong) UIImageView *searchHotProductFirstGradationImageView;
@property (nonatomic, strong) UIView *searchHotProductFirstIconView;
@property (nonatomic, strong) TTTAttributedLabel *searchHotProductFirstPriceLabel;
@property (nonatomic, strong) UIButton *searchHotProductFirstBlankButton;
@property (nonatomic, strong) CPThumbnailView *searchHotProductSecondImageView;
@property (nonatomic, strong) UIView *searchHotProductSecondAdultView;
@property (nonatomic, strong) UIImageView *searchHotProductSecondAdultImageView;
@property (nonatomic, strong) UIImageView *searchHotProductSecondGradationImageView;
@property (nonatomic, strong) TTTAttributedLabel *searchHotProductSecondPriceLabel;
@property (nonatomic, strong) UIButton *searchHotProductSecondBlankButton;
@property (nonatomic, strong) CPThumbnailView *searchHotProductThirdImageView;
@property (nonatomic, strong) UIView *searchHotProductThirdAdultView;
@property (nonatomic, strong) UIImageView *searchHotProductThirdAdultImageView;
@property (nonatomic, strong) UIImageView *searchHotProductThirdGradationImageView;
@property (nonatomic, strong) TTTAttributedLabel *searchHotProductThirdPriceLabel;
@property (nonatomic, strong) UIButton *searchHotProductThirdBlankButton;

//NoData
@property (nonatomic, strong) UIView *noDataCellContentView;
@property (nonatomic, strong) UIImageView *noDataImgView;
@property (nonatomic, strong) UILabel *noDataLabel;

- (void)setCallerView:(id)callerView;
- (void)setData:(CPCollectionData *)data indexPath:(NSIndexPath *)indexPath;

@end

@protocol CPCollectionViewCommonCellDelegate <NSObject>
@optional
- (void)showSearchCaptionAD:(id)sender;
- (void)touchCategoryBest:(id)sender;
- (void)touchSearchProductAjaxCall:(id)sender;
- (void)touchSearchProductBannerAjaxCall:(id)sender;

- (void)didTouchTopTabButton:(NSDictionary *)dic;
- (void)didTouchRelatedOpenButton:(id)sender;
- (void)didTouchRelatedKeywordButton:(id)sender;
- (void)didTouchRecommendKeywordButton:(id)sender;
- (void)didTouchCategoryNaviButton:(id)sender;
- (void)didTouchFilterButton:(NSString *)key;
- (void)didTouchViewTypeButton:(NSString *)url;
- (void)didTouchSortTypeButton:(id)sender;
- (void)didTouchSearchMore:(id)sender;
- (void)didTouchSearchHotProduct:(id)sender;
- (void)didTouchSearchProductSellerButton:(id)sender;
- (void)didTouchSearchProductBannerSellerButton:(id)sender;
- (void)didTouchCtgrHotClickProduct:(id)sender;
- (void)didTouchCtgrBest:(id)sender;
- (void)didTouchCtgrBestProduct:(id)sender;
- (void)didTouchCtgrDealBestProduct:(id)sender;
- (void)didOnTouchBanner:(id)sender;
- (void)didTouchShockingDealProduct:(id)sender;
- (void)didTouchSearchCaptionPageMoveButton:(id)sender;
- (void)didTouchModelSearchProduct:(id)sender;
- (void)didTouchNoSearchData:(NSString *)linkUrl;
- (BOOL)isSearchProductGridCellAlignment:(NSIndexPath *)indexPath;
- (NSString *)getSearchKeywordFromCommonCellSuperView;
@end