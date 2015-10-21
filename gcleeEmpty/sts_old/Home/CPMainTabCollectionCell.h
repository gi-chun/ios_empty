//
//  CPMainTabCollectionCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPMainTabCollectionData.h"
#import "TTTAttributedLabel.h"
#import "CPBlurImageView.h"

typedef NS_ENUM(NSUInteger, CPCellType){
	CPCellTypeCommonProduct = 0,
	CPCellTypeBestProductCategory,
	CPCellTypeBannerProduct,
	CPCellTypeLineBanner,
	CPCellTypeAutoBannerArea,
	CPCellTypeShockingDealAppLink,
	CPCellTypeTalkBanner,
	CPCellTypeSpecialBestArea,
	CPCellTypeMiddleServiceArea,
    CPCellTypeBottomTalkArea,
	CPCellTypeCommonMoreLink,
	CPCellTypeSubEventTwoTab,
	CPCellTypeEventPlanBanner,
	CPCellTypeEventZoneGroupBanner,
	CPCellTypeEventWinner,
	CPCellTypeSubStyleTwoTab,
	CPCellTypeGenderRadioArea,
	CPCellTypeCurationGroup,
	CPCellTypeMartBillBannerList,
	CPCellTypeMartLineBanner,
	CPCellTypeMartProduct,
	CPCellTypeServiceAreaList,
	CPCellTypeBottomMartArea,
	CPCellTypeMartServiceAreaList,
	CPCellTypeHomeDirectServiceArea,
	CPCellTypeTextLine,
	CPCellTypeRandomBannerArea,
	CPCellTypeHomeTalkAndStyleGroup,
	CPCellTypeHomePopularKeywordGroup,
	CPCellTypeCornerBanner,
	CPCellTypeSimpleBestProduct,
	CPCellTypeNoData
};

@class CPThumbnailView;
@class CPTouchActionView;

@protocol CPMainTabCollectionCellDelegate;

@interface CPMainTabCollectionCell : UICollectionViewCell

@property (nonatomic, weak) id<CPMainTabCollectionCellDelegate> delegate;
@property (nonatomic, strong) CPMainTabCollectionData *collectionData;
@property (nonatomic, strong) NSDictionary *dicData;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) id callerView;

@property (nonatomic, strong) UIView *commonShadowLine;

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
@property (nonatomic, strong) CPTouchActionView *commonProductBlankButton;

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
@property (nonatomic, strong) CPTouchActionView *bannerProductBlankButton;
@property (nonatomic, strong) UIButton *bannerProductVideoPlayButton;

//LineBanner
@property (nonatomic, strong) UIView *lineBannerContentView;
@property (nonatomic, strong) CPBlurImageView *lineBannerImageView;
@property (nonatomic, strong) CPTouchActionView *lineBannerButton;

//martLineBanner
@property (nonatomic, strong) UIView *martLineBannerContentView;
@property (nonatomic, strong) UIView *martLineBannerView;

//AutoBannerArea
@property (nonatomic, strong) UIView *autoBannerContentView;
@property (nonatomic, strong) UIView *autoBannerItemView;

//commonMoreLink
@property (nonatomic, strong) UIView *alCellContentView;
@property (nonatomic, strong) CPTouchActionView *alMoreButton;
@property (nonatomic, strong) UILabel *alMoreTitleLabel;
@property (nonatomic, strong) UIImageView *alMoreImageView;

//ShockingDealAppLink
@property (nonatomic, strong) UIView *shockingDealAppLinkCellContentView;
@property (nonatomic, strong) CPTouchActionView *shockingDealAppLinkMoreButton;
@property (nonatomic, strong) UILabel *shockingDealAppLinkMoreTitleLabel;
@property (nonatomic, strong) UIImageView *shockingDealAppLinkMoreImageView;

//talkBanner
@property (nonatomic, strong) UIView *talkCellContentView;
@property (nonatomic, strong) UIView *talkHeaderView;
@property (nonatomic, strong) UIView *talkFooterView;
@property (nonatomic, strong) UIView *talkThumbnailView;
@property (nonatomic, strong) CPTouchActionView *talkTouchButton;

//specialBestArea & serviceArea
@property (nonatomic, strong) UIView *specialBestAreaCellContentView;
@property (nonatomic, strong) UIView *specialBestAreaView;

//eventSubEventTwoTab
@property (nonatomic, strong) UIView *esetCellContentView;
@property (nonatomic, strong) UIView *esetButtonView;

//eventPlanBanner
@property (nonatomic, strong) UIView *epbCellContentView;
@property (nonatomic, strong) CPThumbnailView *epbThumbnailView;
@property (nonatomic, strong) CPTouchActionView *epbTouchButton;

//EventZoneGroupBanner
@property (nonatomic, strong) UIView *eventZoneGroupBannerCellContentView;
@property (nonatomic, strong) UIView *eventZoneThreeBannerView;
@property (nonatomic, strong) UIView *eventZoneTwoBannerView;

//EventWinner
@property (nonatomic, strong) UIView *eventWinnerCellContentView;
@property (nonatomic, strong) UIView *eventWinnerView;

//subStyleTwoTab
@property (nonatomic, strong) UIView *subStyleTwoTabCellContentView;
@property (nonatomic, strong) UIView *subStyleTwoTabButtonView;

//GenderRadioArea
@property (nonatomic, strong) UIView *genderRadioAreaContentView;

//CurationGroup
@property (nonatomic, strong) UIView *curationGroupContentView;

//MartBillBannerList
@property (nonatomic, strong) UIView *martBillBannerContentView;
@property (nonatomic, strong) UIView *martBillBannerView;

//MarkProduct
@property (nonatomic, strong) UIView *martProductContentView;
@property (nonatomic, strong) UIView *martProductView;

//HomeDirectServiceArea
@property (nonatomic, strong) UIView *homeDirectServiceAreaContentView;
@property (nonatomic, strong) UIView *homeDirectServiceAreaView;

//homeTalkAndStyleGroup
@property (nonatomic, strong) UIView *homeTalkAndStyleGroupContentView;

//homePopularKeywordGroup
@property (nonatomic, strong) UIView *homePopularKeywordGroupContentView;

//cornerBanner
@property (nonatomic, strong) UIView *cornerBannerContentView;
@property (nonatomic, strong) UIView *cornerBannerView;

//simpleBestProduct
@property (nonatomic, strong) UIView *simpleBestProductContentView;
@property (nonatomic, strong) UIView *simpleBestProductView;

//NoData
@property (nonatomic, strong) UIView *noDataCellContentView;
@property (nonatomic, strong) UIImageView *noDataImgView;
@property (nonatomic, strong) UILabel *noDataLabel;

- (void)setCallerView:(id)callerView;
- (void)setData:(CPMainTabCollectionData *)data indexPath:(NSIndexPath *)indexPath;

@end

@protocol CPMainTabCollectionCellDelegate <NSObject>
@optional
- (void)touchCategoryBestWithUrl:(NSString *)url;
- (void)didTouchButtonWithUrl:(NSString *)url;
- (void)didTouchButtonWithRequestUrl:(NSString *)url;
- (NSString *)getViewWiselogCode:(NSString *)type;
- (void)isStyleTabGenderMale:(BOOL)isMale;
- (BOOL)getStyleTabGenderIsMale;
- (void)popularKeywordViewOpenYn:(BOOL)isOpen;
@end

