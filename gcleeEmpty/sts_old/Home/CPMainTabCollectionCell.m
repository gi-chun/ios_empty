//
//  CPMainTabCollectionCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMainTabCollectionCell.h"
#import "CPThumbnailView.h"
#import "CPBestView.h"
#import "CPShockingDealView.h"
#import "CPFooterButtonView.h"
#import "CPCommonInfo.h"
#import "UIImageView+WebCache.h"
#import "CPString+Formatter.h"
#import "CPHomeViewController.h"
#import "AccessLog.h"
#import "TTTAttributedLabel.h"
#import "CPBlurImageView.h"
#import "CPTalkCountsView.h"
#import "CPTalkTagView.h"
#import "CPTalkAutoBannerView.h"
#import "CPEventActiveView.h"
#import "CPEventServiceView.h"
#import "CPEventWinnerView.h"
#import "CPCurationItemView.h"
#import "CPMartBillBannerListView.h"
#import "CPMartServiceAreaView.h"
#import "CPTouchActionView.h"
#import "CPMartServiceAreaListView.h"
#import "CPHomeDirectServiceAreaView.h"
#import "CPHomeShadowTitleView.h"
#import "CPHomeTalkStyleListView.h"
#import "CPHomePopularKeywordView.h"
#import "CPCornerBannerView.h"
#import "CPSimpleBestProductView.h"
#import "CPMartProductView.h"
#import "CPMainTabSizeManager.h"
#import "CPSchemeManager.h"
#import "NZLabel.h"

#define SHADOW_HEIGHT	1

@interface CPMainTabCollectionCell () <	CPFooterButtonViewDelegate,
										CPTalkTagViewDelegate,
										CPEventServiceViewDelegate,
										CPEventActiveViewDelegate,
										CPEventWinnerViewDelegate,
										CPTalkAutoBannerViewDelegate,
										CPTouchActionViewDelegate,
										CPHomePopularKeywordViewDelegate >
{
	
}

@end

@implementation CPMainTabCollectionCell

- (NSInteger)getCellType
{
	NSString *cellTypeStr = [[CPCommonInfo sharedInfo] groupName];
	NSInteger cellType = 0;
 
	if ([cellTypeStr isEqualToString:@"commonProduct"]) {
		cellType = CPCellTypeCommonProduct;
	}
	else if ([cellTypeStr isEqualToString:@"bestProductCategory"]) {
		cellType = CPCellTypeBestProductCategory;
	}
	else if ([cellTypeStr isEqualToString:@"bannerProduct"]) {
		cellType = CPCellTypeBannerProduct;
	}
	else if ([cellTypeStr isEqualToString:@"lineBanner"]) {
		cellType = CPCellTypeLineBanner;
	}
	else if ([cellTypeStr isEqualToString:@"autoBannerArea"]) {
		cellType = CPCellTypeAutoBannerArea;
	}
	else if ([cellTypeStr isEqualToString:@"shockingDealAppLink"]) {
		cellType = CPCellTypeShockingDealAppLink;
	}
	else if ([cellTypeStr isEqualToString:@"talkBanner"]) {
		cellType = CPCellTypeTalkBanner;
	}
	else if ([cellTypeStr isEqualToString:@"specialBestArea"] || [cellTypeStr isEqualToString:@"specialTalkArea"]) {
		cellType = CPCellTypeSpecialBestArea;
	}
	else if ([cellTypeStr isEqualToString:@"middleServiceArea"]) {
		cellType = CPCellTypeMiddleServiceArea;
	}
    else if ([cellTypeStr isEqualToString:@"bottomTalkArea"]) {
        cellType = CPCellTypeBottomTalkArea;
    }
	else if ([cellTypeStr isEqualToString:@"commonMoreView"]) {
		cellType = CPCellTypeCommonMoreLink;
	}
	else if ([cellTypeStr isEqualToString:@"subEventTwoTab"]) {
		cellType = CPCellTypeSubEventTwoTab;
	}
	else if ([cellTypeStr isEqualToString:@"eventPlanBanner"]) {
		cellType = CPCellTypeEventPlanBanner;
	}
	else if ([cellTypeStr isEqualToString:@"eventZoneGroupBanner"]) {
		cellType = CPCellTypeEventZoneGroupBanner;
	}
	else if ([cellTypeStr isEqualToString:@"eventWinner"]) {
		cellType = CPCellTypeEventWinner;
	}
	else if ([cellTypeStr isEqualToString:@"subStyleTwoTab"]) {
		cellType = CPCellTypeSubStyleTwoTab;
	}
	else if ([cellTypeStr isEqualToString:@"genderRadioArea"]) {
		cellType = CPCellTypeGenderRadioArea;
	}
	else if ([cellTypeStr isEqualToString:@"curationRightGroup"] || [cellTypeStr isEqualToString:@"curationLeftGroup"]) {
		cellType = CPCellTypeCurationGroup;
	}
	else if ([cellTypeStr isEqualToString:@"martBillBannerList"]) {
		cellType = CPCellTypeMartBillBannerList;
	}
	else if ([cellTypeStr isEqualToString:@"martLineBanner"]) {
		cellType = CPCellTypeMartLineBanner;
	}
	else if ([cellTypeStr isEqualToString:@"martProduct"]) {
		cellType = CPCellTypeMartProduct;
	}
	else if ([cellTypeStr isEqualToString:@"serviceAreaList"]) {
		cellType = CPCellTypeServiceAreaList;
	}
	else if ([cellTypeStr isEqualToString:@"bottomMartArea"]) {
		cellType = CPCellTypeBottomMartArea;
	}
	else if ([cellTypeStr isEqualToString:@"martServiceAreaList"]) {
		cellType = CPCellTypeMartServiceAreaList;
	}
	else if ([cellTypeStr isEqualToString:@"homeDirectServiceArea"]) {
		cellType = CPCellTypeHomeDirectServiceArea;
	}
	else if ([cellTypeStr isEqualToString:@"textLine"]) {
		cellType = CPCellTypeTextLine;
	}
	else if ([cellTypeStr isEqualToString:@"randomBannerArea"]) {
		cellType = CPCellTypeRandomBannerArea;
	}
	else if ([cellTypeStr isEqualToString:@"homeTalkAndStyleGroup"]) {
		cellType = CPCellTypeHomeTalkAndStyleGroup;
	}
	else if ([cellTypeStr isEqualToString:@"homePopularKeywordGroup"]) {
		cellType = CPCellTypeHomePopularKeywordGroup;
	}
	else if ([cellTypeStr isEqualToString:@"cornerBanner"]) {
		cellType = CPCellTypeCornerBanner;
	}
	else if ([cellTypeStr isEqualToString:@"simpleBestProduct"]) {
		cellType = CPCellTypeSimpleBestProduct;
	}
	else if ([cellTypeStr isEqualToString:@"noData"]) {
		cellType = CPCellTypeNoData;
	}
	
	return cellType;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.contentFrame = frame;
		
		switch ([self getCellType]) {
			case CPCellTypeCommonProduct:
				[self initCommonProduct];
				break;
			case CPCellTypeBestProductCategory:
				[self initBestProductCategory];
				break;
			case CPCellTypeBannerProduct:
				[self initBannerProduct];
				break;
			case CPCellTypeLineBanner:
				[self initLineBanner];
				break;
			case CPCellTypeAutoBannerArea:
				[self initAutoBannerArea];
				break;
			case CPCellTypeShockingDealAppLink:
				[self initShockingDealAppLink];
				break;
			case CPCellTypeTalkBanner:
				[self initTalkBanner];
				break;
			case CPCellTypeSpecialBestArea:
				[self initSpecialBestArea];
				break;
			case CPCellTypeMiddleServiceArea:
				[self initMiddleServiceArea];
				break;
            case CPCellTypeBottomTalkArea:
                [self initBottomTalkArea];
                break;
			case CPCellTypeCommonMoreLink:
				[self initCommonMoreLink];
				break;
			case CPCellTypeSubEventTwoTab:
				[self initSubEventTwoTab];
				break;
			case CPCellTypeEventPlanBanner:
				[self initEventPlanBanner];
				break;
			case CPCellTypeEventZoneGroupBanner:
				[self initEventZoneGroupBanner];
				break;
			case CPCellTypeEventWinner:
				[self initEventWinner];
				break;
			case CPCellTypeSubStyleTwoTab:
				[self initSubStyleTwoTab];
				break;
			case CPCellTypeGenderRadioArea:
				[self initGenderRadioArea];
				break;
			case CPCellTypeCurationGroup:
				[self initCurationGroup];
				break;
			case CPCellTypeMartBillBannerList:
				[self initMartBillBannerList];
				break;
			case CPCellTypeMartLineBanner:
				[self initMartLineBanner];
				break;
			case CPCellTypeMartProduct:
				[self initMartProduct];
				break;
			case CPCellTypeServiceAreaList:
				[self initServiceAreaList];
				break;
			case CPCellTypeBottomMartArea:
				[self initBottomMartArea];
				break;
			case CPCellTypeMartServiceAreaList:
				[self initMartServiceAreaList];
				break;
			case CPCellTypeHomeDirectServiceArea:
				[self initHomeDirectServiceArea];
				break;
			case CPCellTypeTextLine:
				[self initTextLine];
				break;
			case CPCellTypeRandomBannerArea:
				[self initRandomBannerArea];
				break;
			case CPCellTypeHomeTalkAndStyleGroup:
				[self initHomeTalkAndStyleGroup];
				break;
			case CPCellTypeHomePopularKeywordGroup:
				[self initHomePopularKeywordGroup];
				break;
			case CPCellTypeCornerBanner:
				[self initCornerBanner];
				break;
			case CPCellTypeSimpleBestProduct:
				[self initSimpleBestProduct];
				break;
			case CPCellTypeNoData:
				[self initNoData];
				break;
				
			default:
				break;
		}
	}
	return self;
}

#pragma mark - InitView

- (void)initCommonProduct
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	
	self.commonProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth+75+SHADOW_HEIGHT)];
	[self.commonProductCellContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[self.contentView addSubview:self.commonProductCellContentView];
	
	self.commonProductThumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.commonProductCellContentView.frame), CGRectGetWidth(self.commonProductCellContentView.frame))];
	[self.commonProductCellContentView addSubview:self.commonProductThumbnailView];
	
	self.commonProductRankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
	[self.commonProductRankingLabel setBackgroundColor:UIColorFromRGBA(0x979fe4, 0.8f)];
	[self.commonProductRankingLabel setFont:[UIFont systemFontOfSize:15]];
	[self.commonProductRankingLabel setTextColor:UIColorFromRGB(0xffffff)];
	[self.commonProductRankingLabel setTextAlignment:NSTextAlignmentCenter];
	[self.commonProductCellContentView addSubview:self.commonProductRankingLabel];
	
	
	self.commonProductProductNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.commonProductThumbnailView.frame)+5, CGRectGetWidth(self.commonProductCellContentView.frame)-20, 35)];
	[self.commonProductProductNameLabel setBackgroundColor:[UIColor clearColor]];
	[self.commonProductProductNameLabel setFont:[UIFont systemFontOfSize:14]];
	[self.commonProductProductNameLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.commonProductProductNameLabel setNumberOfLines:2];
    [self.commonProductProductNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[self.commonProductCellContentView addSubview:self.commonProductProductNameLabel];
	
	
	self.commonProductPriceLabel = [[UILabel alloc] init];
	[self.commonProductPriceLabel setBackgroundColor:[UIColor clearColor]];
	[self.commonProductPriceLabel setTextColor:UIColorFromRGB(0xa5a5af)];
	[self.commonProductPriceLabel setFont:[UIFont systemFontOfSize:10]];
	[self.commonProductCellContentView addSubview:self.commonProductPriceLabel];
	
	self.commonProductLineView = [[UIView alloc] init];
	[self.commonProductLineView setBackgroundColor:UIColorFromRGB(0xa5a5af)];
	[self.commonProductPriceLabel addSubview:self.commonProductLineView];
	
	
	self.commonProductDiscountLabel = [[UILabel alloc] init];
	[self.commonProductDiscountLabel setBackgroundColor:[UIColor clearColor]];
	[self.commonProductDiscountLabel setTextColor:UIColorFromRGB(0x000000)];
	[self.commonProductDiscountLabel setFont:[UIFont boldSystemFontOfSize:16]];
	[self.commonProductCellContentView addSubview:self.commonProductDiscountLabel];
	
	self.commonProductUnitLabel = [[UILabel alloc] init];
	[self.commonProductUnitLabel setBackgroundColor:[UIColor clearColor]];
	[self.commonProductUnitLabel setText:@"원"];
	[self.commonProductUnitLabel setTextColor:UIColorFromRGB(0x000000)];
	[self.commonProductUnitLabel setFont:[UIFont boldSystemFontOfSize:11]];
	[self.commonProductUnitLabel setTextAlignment:NSTextAlignmentLeft];
	[self.commonProductCellContentView addSubview:self.commonProductUnitLabel];
	
	self.commonProductFreeShipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.commonProductCellContentView.frame)-51, CGRectGetMaxY(self.commonProductCellContentView.frame)-25, 44, 17)];
	[self.commonProductFreeShipLabel setBackgroundColor:[UIColor clearColor]];
	[self.commonProductFreeShipLabel setText:@"무료배송"];
	[self.commonProductFreeShipLabel setTextColor:UIColorFromRGB(0x4e66c4)];
	[self.commonProductFreeShipLabel setFont:[UIFont systemFontOfSize:10]];
	[self.commonProductFreeShipLabel setHidden:YES];
	[self.commonProductFreeShipLabel setTextAlignment:NSTextAlignmentCenter];
	[self.commonProductFreeShipLabel.layer setBorderColor:UIColorFromRGB(0x506bd1).CGColor];
	[self.commonProductFreeShipLabel.layer setBorderWidth:1];
	[self.commonProductCellContentView addSubview:self.commonProductFreeShipLabel];
	
	self.commonProductBlankButton = [[CPTouchActionView alloc] initWithFrame:self.commonProductCellContentView.frame];
	[self.commonProductCellContentView addSubview:self.commonProductBlankButton];
	
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.commonProductCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.commonProductCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.commonProductCellContentView addSubview:self.commonShadowLine];
}

- (void)initBestProductCategory
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	
	self.bestProductCategoryCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth+75+SHADOW_HEIGHT)];
	[self.bestProductCategoryCellContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[self.contentView addSubview:self.bestProductCategoryCellContentView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectZero];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.bestProductCategoryCellContentView addSubview:self.commonShadowLine];
}

- (void)initBannerProduct
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = productWidth/1.78+(121+SHADOW_HEIGHT);
	
	self.bannerProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, productWidth, productHeight)];
	[self.bannerProductCellContentView setBackgroundColor:UIColorFromRGB(0xf1f2f3)];
	[self.contentView addSubview:self.bannerProductCellContentView];
	
	//이미지
	self.bannerProductThumbnailView = [[CPThumbnailView alloc] init];
	[self.bannerProductCellContentView addSubview:self.bannerProductThumbnailView];
	
	self.bannerProductProductInfoView = [[UIView alloc] init];
	[self.bannerProductProductInfoView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[self.bannerProductCellContentView addSubview:self.bannerProductProductInfoView];
	
	//상품명
	self.bannerProductProductNameLabel = [[UILabel alloc] init];
	[self.bannerProductProductNameLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductProductNameLabel setFont:[UIFont systemFontOfSize:16]];
	[self.bannerProductProductNameLabel setTextColor:UIColorFromRGB(0x333333)];
	[self.bannerProductProductNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[self.bannerProductProductInfoView addSubview:self.bannerProductProductNameLabel];
	
	//할인률
	self.bannerProductDiscountRate = [[TTTAttributedLabel alloc] init];
	[self.bannerProductDiscountRate setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductDiscountRate setTextColor:UIColorFromRGB(0xff0000)];
	[self.bannerProductProductInfoView addSubview:self.bannerProductDiscountRate];
	
	//실제가격
	self.bannerProductPriceLabel = [[UILabel alloc] init];
	[self.bannerProductPriceLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductPriceLabel setTextColor:UIColorFromRGB(0xa5a5af)];
	[self.bannerProductPriceLabel setFont:[UIFont systemFontOfSize:12]];
	[self.bannerProductProductInfoView addSubview:self.bannerProductPriceLabel];
	
	self.bannerProductPriceUnitLabel = [[UILabel alloc] init];
	[self.bannerProductPriceUnitLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductPriceUnitLabel setTextColor:UIColorFromRGB(0xa5a5af)];
	[self.bannerProductPriceUnitLabel setFont:[UIFont systemFontOfSize:10]];
	[self.bannerProductPriceUnitLabel setTextAlignment:NSTextAlignmentLeft];
	[self.bannerProductProductInfoView addSubview:self.bannerProductPriceUnitLabel];
	
	//라인
	self.bannerProductLineView = [[UIView alloc] init];
	[self.bannerProductLineView setBackgroundColor:UIColorFromRGB(0xa5a5af)];
	[self.bannerProductPriceLabel addSubview:self.bannerProductLineView];
	
	//할인가
	self.bannerProductDiscountLabel = [[UILabel alloc] init];
	[self.bannerProductDiscountLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductDiscountLabel setTextColor:UIColorFromRGB(0x000000)];
	[self.bannerProductDiscountLabel setFont:[UIFont boldSystemFontOfSize:18]];
	[self.bannerProductProductInfoView addSubview:self.bannerProductDiscountLabel];
	
	self.bannerProductUnitLabel = [[UILabel alloc] init];
	[self.bannerProductUnitLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductUnitLabel setText:@"원"];
	[self.bannerProductUnitLabel setTextColor:UIColorFromRGB(0x000000)];
	[self.bannerProductUnitLabel setFont:[UIFont boldSystemFontOfSize:11]];
	[self.bannerProductUnitLabel setTextAlignment:NSTextAlignmentLeft];
	[self.bannerProductProductInfoView addSubview:self.bannerProductUnitLabel];
	
	self.bannerProductStampView = [[UIView alloc] init];
	[self.bannerProductStampView setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductProductInfoView addSubview:self.bannerProductStampView];
	
	self.bannerProductTMembershipImageView = [[UIImageView alloc] init];
	[self.bannerProductStampView addSubview:self.bannerProductTMembershipImageView];
	
	self.bannerProductMileageImageView = [[UIImageView alloc] init];
	[self.bannerProductStampView addSubview:self.bannerProductMileageImageView];
	
	self.bannerProductFreeShipImageView = [[UIImageView alloc] init];
	[self.bannerProductStampView addSubview:self.bannerProductFreeShipImageView];
	
	//구매개수
	self.bannerProductPurchaseCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.bannerProductPurchaseCountButton setBackgroundColor:[UIColor whiteColor]];
	[self.bannerProductPurchaseCountButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
	[self.bannerProductPurchaseCountButton setUserInteractionEnabled:NO];
	[self.bannerProductCellContentView addSubview:self.bannerProductPurchaseCountButton];
	
	self.bannerProductPurchaseTitleView = [[UIView alloc] init];
	[self.bannerProductPurchaseCountButton addSubview:self.bannerProductPurchaseTitleView];
	
	self.bannerProductPurchaseCountLabel = [[UILabel alloc] init];
	[self.bannerProductPurchaseCountLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductPurchaseCountLabel setTextColor:UIColorFromRGB(0x666666)];
	[self.bannerProductPurchaseCountLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[self.bannerProductPurchaseTitleView addSubview:self.bannerProductPurchaseCountLabel];
	
	self.bannerProductPurchaseUnitLabel = [[UILabel alloc] init];
	[self.bannerProductPurchaseUnitLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductPurchaseUnitLabel setTextColor:UIColorFromRGB(0x666666)];
	[self.bannerProductPurchaseUnitLabel setFont:[UIFont systemFontOfSize:13]];
	[self.bannerProductPurchaseTitleView addSubview:self.bannerProductPurchaseUnitLabel];
	
	//연관상품
	self.bannerProductRelativeProductButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.bannerProductRelativeProductButton setBackgroundColor:[UIColor whiteColor]];
	[self.bannerProductRelativeProductButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
	[self.bannerProductCellContentView addSubview:self.bannerProductRelativeProductButton];
	
	self.bannerProductRelativeProductLabel = [[UILabel alloc] init];
	[self.bannerProductRelativeProductLabel setBackgroundColor:[UIColor clearColor]];
	[self.bannerProductRelativeProductLabel setTextColor:UIColorFromRGB(0x666666)];
	[self.bannerProductRelativeProductLabel setFont:[UIFont systemFontOfSize:13]];
	[self.bannerProductRelativeProductLabel setTextAlignment:NSTextAlignmentCenter];
	[self.bannerProductRelativeProductButton addSubview:self.bannerProductRelativeProductLabel];
	
	self.bannerProductRelativeProductImage = [[UIImageView alloc] init];
	[self.bannerProductRelativeProductButton addSubview:self.bannerProductRelativeProductImage];
	
	self.bannerProductBlankButton = [[CPTouchActionView alloc] init];
	[self.contentView addSubview:self.bannerProductBlankButton];
	
	self.bannerProductVideoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.bannerProductVideoPlayButton setHidden:YES];
	[self.contentView addSubview:self.bannerProductVideoPlayButton];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bannerProductCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.bannerProductCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.bannerProductCellContentView addSubview:self.commonShadowLine];
}

- (void)initLineBanner
{
	self.lineBannerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 60+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.lineBannerContentView ];
	
	//backgroundImage
	self.lineBannerImageView = [[CPBlurImageView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-300)/2-10, 0, 300, 60)];
	[self.lineBannerImageView setUserInteractionEnabled:YES];
	[self.lineBannerContentView addSubview:self.lineBannerImageView];
	
	self.lineBannerButton = [[CPTouchActionView alloc] init];
	[self.lineBannerButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.lineBannerContentView.frame), CGRectGetHeight(self.lineBannerContentView.frame))];
	[self.lineBannerContentView addSubview:self.lineBannerButton];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.lineBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.lineBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.lineBannerContentView addSubview:self.commonShadowLine];
}

- (void)initAutoBannerArea
{
	self.autoBannerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 60+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.autoBannerContentView];
	
	self.autoBannerItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 60)];
	[self.autoBannerContentView addSubview:self.autoBannerItemView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.autoBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.autoBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.autoBannerContentView addSubview:self.commonShadowLine];
}

- (void)initShockingDealAppLink
{
	self.shockingDealAppLinkCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34+SHADOW_HEIGHT)];
	self.shockingDealAppLinkCellContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.shockingDealAppLinkCellContentView ];
	
	self.shockingDealAppLinkMoreButton = [[CPTouchActionView alloc] init];
	[self.shockingDealAppLinkMoreButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34)];
	[self.shockingDealAppLinkCellContentView addSubview:self.shockingDealAppLinkMoreButton];
	
	self.shockingDealAppLinkMoreTitleLabel = [[UILabel alloc] init];
	[self.shockingDealAppLinkMoreTitleLabel setText:@"쇼킹딜 APP에서 상품 더 보기"];
	[self.shockingDealAppLinkMoreTitleLabel setTextColor:UIColorFromRGB(0x2d348c)];
	[self.shockingDealAppLinkMoreTitleLabel setBackgroundColor:[UIColor clearColor]];
	[self.shockingDealAppLinkMoreTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[self.shockingDealAppLinkMoreButton addSubview:self.shockingDealAppLinkMoreTitleLabel];
	
	self.shockingDealAppLinkMoreImageView = [[UIImageView alloc] init];
	[self.shockingDealAppLinkMoreImageView setImage:[UIImage imageNamed:@"bt_arrow_go.png"]];
	[self.shockingDealAppLinkMoreButton addSubview:self.shockingDealAppLinkMoreImageView];
	
	CGSize moreTitleSize = [self.shockingDealAppLinkMoreTitleLabel.text sizeWithFont:self.shockingDealAppLinkMoreTitleLabel.font constrainedToSize:CGSizeMake(10000, 34) lineBreakMode:self.shockingDealAppLinkMoreTitleLabel.lineBreakMode];
	NSInteger size = moreTitleSize.width + 12;
	
	[self.shockingDealAppLinkMoreTitleLabel setFrame:CGRectMake((CGRectGetWidth(self.shockingDealAppLinkMoreButton.frame)-size)/2, 0, moreTitleSize.width, 34)];
	[self.shockingDealAppLinkMoreImageView setFrame:CGRectMake(CGRectGetMaxX(self.shockingDealAppLinkMoreTitleLabel.frame)+5, (CGRectGetHeight(self.shockingDealAppLinkMoreButton.frame)-11)/2, 7, 11)];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.shockingDealAppLinkCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.shockingDealAppLinkCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.shockingDealAppLinkCellContentView addSubview:self.commonShadowLine];
}

- (void)initTalkBanner
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	
	self.talkCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, productWidth, 0)];
	self.talkCellContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.talkCellContentView];
	
	//header
	self.talkHeaderView = [[UIView alloc] initWithFrame:self.talkCellContentView.bounds];
	[self.talkCellContentView addSubview:self.talkHeaderView];
	
	//이미지
	self.talkThumbnailView = [[UIView alloc] initWithFrame:self.talkCellContentView.bounds];
	[self.talkCellContentView addSubview:self.talkThumbnailView];
	
	//footer
	self.talkFooterView = [[UIView alloc] initWithFrame:self.talkCellContentView.bounds];
	[self.talkCellContentView addSubview:self.talkFooterView];
	
	self.talkTouchButton = [[CPTouchActionView alloc] init];
	[self.talkCellContentView addSubview:self.talkTouchButton];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectZero];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.talkCellContentView addSubview:self.commonShadowLine];
}

- (void)initSpecialBestArea
{
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
}

- (void)initMiddleServiceArea
{
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
}

- (void)initBottomTalkArea
{
    self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.specialBestAreaCellContentView];
}

- (void)initCommonMoreLink
{
	self.alCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.alCellContentView ];
	
	self.alMoreButton = [[CPTouchActionView alloc] init];
	[self.alMoreButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34)];
	[self.alCellContentView setBackgroundColor:[UIColor whiteColor]];
	[self.alCellContentView addSubview:self.alMoreButton];
	
	self.alMoreTitleLabel = [[UILabel alloc] init];
	[self.alMoreTitleLabel setTextColor:UIColorFromRGB(0x2d348c)];
	[self.alMoreTitleLabel setBackgroundColor:[UIColor clearColor]];
	[self.alMoreTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[self.alMoreButton addSubview:self.alMoreTitleLabel];
	
	self.alMoreImageView = [[UIImageView alloc] init];
	[self.alMoreImageView setImage:[UIImage imageNamed:@"bt_arrow_go.png"]];
	[self.alMoreButton addSubview:self.alMoreImageView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.alCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.alCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.alCellContentView addSubview:self.commonShadowLine];
}

- (void)initSubEventTwoTab
{
	self.esetCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20.f, 36+SHADOW_HEIGHT)];
	self.esetCellContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.esetCellContentView];
	
	self.esetButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20.f, 36.f)];
	[self.esetCellContentView addSubview:self.esetButtonView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.esetCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.esetCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.esetCellContentView addSubview:self.commonShadowLine];
}

- (void)initEventPlanBanner
{
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = [Modules getRatioHeight:CGSizeMake(720, 360) screebWidth:productWidth];
	
	self.epbCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, productWidth, productHeight+SHADOW_HEIGHT)];
	self.epbCellContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.epbCellContentView];
	
	self.epbThumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, productWidth, productHeight)];
	[self.epbCellContentView addSubview:self.epbThumbnailView];
	
	
	self.epbTouchButton = [[CPTouchActionView alloc] init];
	self.epbTouchButton.frame = CGRectMake(0, 0,
										   self.epbCellContentView.frame.size.width,
										   CGRectGetMaxY(self.epbCellContentView.frame));
	[self.epbCellContentView addSubview:self.epbTouchButton];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.epbCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.epbCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.epbCellContentView addSubview:self.commonShadowLine];
}

- (void)initEventZoneGroupBanner
{
	self.eventZoneGroupBannerCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20.f, 123+SHADOW_HEIGHT)];
	self.eventZoneGroupBannerCellContentView.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:self.eventZoneGroupBannerCellContentView];
	
	self.eventZoneThreeBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20.f, 71)];
	self.eventZoneThreeBannerView.backgroundColor = [UIColor whiteColor];
	[self.eventZoneGroupBannerCellContentView addSubview:self.eventZoneThreeBannerView];
	
	self.eventZoneTwoBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.eventZoneThreeBannerView.frame)+1,
																		   kScreenBoundsWidth-20.f, 50.f)];
	self.eventZoneTwoBannerView.backgroundColor = [UIColor whiteColor];
	[self.eventZoneGroupBannerCellContentView addSubview:self.eventZoneTwoBannerView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.eventZoneGroupBannerCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.eventZoneGroupBannerCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.eventZoneGroupBannerCellContentView addSubview:self.commonShadowLine];
}

- (void)initEventWinner
{
	self.eventWinnerCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 0)];
	self.eventWinnerCellContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.eventWinnerCellContentView];
	
	self.eventWinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 0)];
	[self.eventWinnerCellContentView addSubview:self.eventWinnerView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectZero];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.eventWinnerCellContentView addSubview:self.commonShadowLine];
}

- (void)initSubStyleTwoTab
{
	self.subStyleTwoTabCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 36+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.subStyleTwoTabCellContentView];
	
	self.subStyleTwoTabButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 36)];
	[self.subStyleTwoTabCellContentView addSubview:self.subStyleTwoTabButtonView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.subStyleTwoTabCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.subStyleTwoTabCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.subStyleTwoTabCellContentView addSubview:self.commonShadowLine];
}

- (void)initGenderRadioArea
{
	self.genderRadioAreaContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 22)];
	[self.contentView addSubview:self.genderRadioAreaContentView];
}

- (void)initCurationGroup
{
	self.curationGroupContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, [CPCurationItemView viewHeight:kScreenBoundsWidth-20])];
	[self.contentView addSubview:self.curationGroupContentView];
}

- (void)initMartBillBannerList
{
	self.martBillBannerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, [Modules getRatioHeight:CGSizeMake(720, 330) screebWidth:kScreenBoundsWidth-20]+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.martBillBannerContentView];
	
	self.martBillBannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.martBillBannerContentView.frame.size.width, self.martBillBannerContentView.frame.size.height-SHADOW_HEIGHT)];
	[self.martBillBannerContentView addSubview:self.martBillBannerView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.martBillBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.martBillBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.martBillBannerContentView addSubview:self.commonShadowLine];
}

- (void)initMartLineBanner
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"martLineBanner" item:nil];
	
	self.martLineBannerContentView = [[UIView alloc] initWithFrame:frame];
	self.martLineBannerContentView.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:self.martLineBannerContentView];
	
	self.martLineBannerView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y,
																	   frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.martLineBannerContentView addSubview:self.martLineBannerView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.martLineBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.martLineBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.martLineBannerContentView addSubview:self.commonShadowLine];
}

- (void)initMartProduct
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"martProduct" item:nil];
	
	self.martProductContentView = [[UIView alloc] initWithFrame:frame];
	self.martProductContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.martProductContentView];
	
	self.martProductView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.martProductContentView addSubview:self.martProductView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.martProductContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.martProductContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.martProductContentView addSubview:self.commonShadowLine];
}

- (void)initServiceAreaList
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"serviceAreaList" item:nil];
	
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:frame];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
	
	self.specialBestAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.specialBestAreaCellContentView addSubview:self.specialBestAreaView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.specialBestAreaCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.specialBestAreaCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.specialBestAreaCellContentView addSubview:self.commonShadowLine];
}

- (void)initBottomMartArea
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"bottomMartArea" item:nil];
	
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:frame];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
	
	self.specialBestAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.specialBestAreaCellContentView addSubview:self.specialBestAreaView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.specialBestAreaCellContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.specialBestAreaCellContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.specialBestAreaCellContentView addSubview:self.commonShadowLine];
}

- (void)initMartServiceAreaList
{
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
	
	self.specialBestAreaView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.specialBestAreaCellContentView addSubview:self.specialBestAreaView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectZero];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.specialBestAreaCellContentView addSubview:self.commonShadowLine];
}

- (void)initHomeDirectServiceArea
{
	self.homeDirectServiceAreaContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.homeDirectServiceAreaContentView];
	
	self.homeDirectServiceAreaView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.homeDirectServiceAreaContentView addSubview:self.homeDirectServiceAreaView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectZero];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.homeDirectServiceAreaContentView addSubview:self.commonShadowLine];
}

- (void)initTextLine
{
	self.specialBestAreaCellContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.specialBestAreaCellContentView];
	
	self.specialBestAreaView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.specialBestAreaCellContentView addSubview:self.specialBestAreaView];
}

- (void)initRandomBannerArea
{
	self.lineBannerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 60+SHADOW_HEIGHT)];
	[self.contentView addSubview:self.lineBannerContentView ];
	
	//backgroundImage
	self.lineBannerImageView = [[CPBlurImageView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-300)/2-10, 0, 300, 60)];
	[self.lineBannerImageView setUserInteractionEnabled:YES];
	[self.lineBannerContentView addSubview:self.lineBannerImageView];
	
	self.lineBannerButton = [[CPTouchActionView alloc] init];
	[self.lineBannerButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.lineBannerContentView.frame), CGRectGetHeight(self.lineBannerContentView.frame))];
	[self.lineBannerContentView addSubview:self.lineBannerButton];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.lineBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.lineBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.lineBannerContentView addSubview:self.commonShadowLine];
}

- (void)initHomeTalkAndStyleGroup
{
	self.homeTalkAndStyleGroupContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.homeTalkAndStyleGroupContentView];
}

- (void)initHomePopularKeywordGroup
{
	self.homePopularKeywordGroupContentView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:self.homePopularKeywordGroupContentView];
}

- (void)initCornerBanner
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"cornerBanner" item:nil];
	self.cornerBannerContentView = [[UIView alloc] initWithFrame:frame];
	self.cornerBannerContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.cornerBannerContentView];
	
	self.cornerBannerView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.cornerBannerContentView addSubview:self.cornerBannerView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.cornerBannerContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.cornerBannerContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.cornerBannerContentView addSubview:self.commonShadowLine];
}

- (void)initSimpleBestProduct
{
	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"simpleBestProduct" item:nil];
	self.simpleBestProductContentView = [[UIView alloc] initWithFrame:frame];
	self.simpleBestProductContentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:self.simpleBestProductContentView];
	
	self.simpleBestProductView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-SHADOW_HEIGHT)];
	[self.simpleBestProductContentView addSubview:self.simpleBestProductView];
	
	//쉐도우 라인
	self.commonShadowLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.simpleBestProductContentView.frame.size.height-SHADOW_HEIGHT,
																	 self.simpleBestProductContentView.frame.size.width, SHADOW_HEIGHT)];
	self.commonShadowLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.simpleBestProductContentView addSubview:self.commonShadowLine];
}

- (void)initNoData
{
	self.noDataCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 215)];
	[self.noDataCellContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
	[self.noDataCellContentView setCenter:CGPointMake(CGRectGetWidth(self.contentFrame)/2, CGRectGetHeight(self.contentFrame)/2)];
	[self.contentView addSubview:self.noDataCellContentView];
	
	self.noDataImgView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.noDataCellContentView.frame)-41)/2, 69, 41, 41)];
	[self.noDataImgView setImage:[UIImage imageNamed:@"best_list_noresult.png"]];
	[self.noDataCellContentView addSubview:self.noDataImgView];
	
	self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[self.noDataLabel setTextColor:UIColorFromRGB(0x333333)];
	[self.noDataLabel setFont:[UIFont systemFontOfSize:14]];
	[self.noDataLabel setBackgroundColor:[UIColor clearColor]];
	[self.noDataLabel setTextAlignment:NSTextAlignmentCenter];
	[self.noDataCellContentView addSubview:self.noDataLabel];
}
#pragma mark - setData

- (void)setCallerView:(id)callerView
{
	self.callerView = callerView;
}

- (void)setData:(CPMainTabCollectionData *)data indexPath:(NSIndexPath *)indexPath
{
	if (!data || [data.items count] == 0) {
		[self setNoData];
		return;
	}
	
	self.collectionData = data;
	
	self.dicData = [[NSDictionary alloc] initWithDictionary:data.items[indexPath.row]];
	
	if ([self.dicData count] == 0) {
		[self setNoData];
		return;
	}
	
	NSString *groupName = self.dicData[@"groupName"];
	
	if ([groupName isEqualToString:@"commonProduct"]) {
		[self setCommonProduct:indexPath];
	}
	else if ([groupName isEqualToString:@"bestProductCategory"]) {
		[self setBestProductCategory:indexPath];
	}
	else if ([groupName isEqualToString:@"bannerProduct"]) {
		[self setBannerProduct:indexPath];
	}
	else if ([groupName isEqualToString:@"lineBanner"]) {
		[self setLineBanner:indexPath];
	}
	else if ([groupName isEqualToString:@"autoBannerArea"]) {
		[self setAutoBannerArea:indexPath];
	}
	else if ([groupName isEqualToString:@"shockingDealAppLink"]) {
		[self setShockingDealAppLink:indexPath];
	}
	else if ([groupName isEqualToString:@"talkBanner"]) {
		[self setTalkBannerItems:indexPath];
	}
	else if ([groupName isEqualToString:@"specialBestArea"] || [groupName isEqualToString:@"specialTalkArea"]) {
		[self setSpecialBestArea:indexPath];
	}
	else if ([groupName isEqualToString:@"middleServiceArea"]) {
		[self setMiddleServiceArea:indexPath];
	}
    else if ([groupName isEqualToString:@"bottomTalkArea"]) {
        [self setBottomTalkArea:indexPath];
    }
	else if ([groupName isEqualToString:@"commonMoreView"]) {
		[self setCommonMoreLink:indexPath];
	}
	else if ([groupName isEqualToString:@"subEventTwoTab"]) {
		[self setSubEventTwoTab:indexPath];
	}
	else if ([groupName isEqualToString:@"eventPlanBanner"]) {
		[self setEventPlanBanner:indexPath];
	}
	else if ([groupName isEqualToString:@"eventZoneGroupBanner"]) {
		[self setEventZoneGroupBanner:indexPath];
	}
	else if ([groupName isEqualToString:@"eventWinner"]) {
		[self setEventWinner:indexPath];
	}
	else if ([groupName isEqualToString:@"subStyleTwoTab"]) {
		[self setSubStyleTwoTab:indexPath];
	}
	else if ([groupName isEqualToString:@"genderRadioArea"]) {
		[self setGenderRadioArea:indexPath];
	}
	else if ([groupName isEqualToString:@"curationRightGroup"] || [groupName isEqualToString:@"curationLeftGroup"])
	{
		[self setCurationGroup:indexPath];
	}
	else if ([groupName isEqualToString:@"martBillBannerList"]) {
		[self setMartBillBannerList:indexPath];
	}
	else if ([groupName isEqualToString:@"martLineBanner"]) {
		[self setMartLineBanner:indexPath];
	}
	else if ([groupName isEqualToString:@"martProduct"]) {
		[self setMartProduct:indexPath];
	}
	else if ([groupName isEqualToString:@"serviceAreaList"]) {
		[self setServiceAreaList:indexPath];
	}
	else if ([groupName isEqualToString:@"bottomMartArea"]) {
		[self setBottomMartArea:indexPath];
	}
	else if ([groupName isEqualToString:@"martServiceAreaList"]) {
		[self setMartServiceAreaList:indexPath];
	}
	else if ([groupName isEqualToString:@"homeDirectServiceArea"]) {
		[self setHomeDirectServiceArea:indexPath];
	}
	else if ([groupName isEqualToString:@"textLine"]) {
		[self setTextLine:indexPath];
	}
	else if ([groupName isEqualToString:@"randomBannerArea"]) {
		[self setRandomBannerArea:indexPath];
	}
	else if ([groupName isEqualToString:@"homeTalkAndStyleGroup"]) {
		[self setHomeTalkAndStyleGroup:indexPath];
	}
	else if ([groupName isEqualToString:@"homePopularKeywordGroup"]) {
		[self setHomePopularKeywordGroup:indexPath];
	}
	else if ([groupName isEqualToString:@"cornerBanner"]) {
		[self setCornerBanner:indexPath];
	}
	else if ([groupName isEqualToString:@"simpleBestProduct"]) {
		[self setSimpleBestProduct:indexPath];
	}
	else if ([groupName isEqualToString:@"noData"]) {
		[self setNoData];
	}
}

#pragma mark - SettingView

//draw
- (void)setCommonProduct:(NSIndexPath *)indexPath
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	
	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger lineNum = indexPath.row % (NSInteger)columnCount;
	CGRect frame = self.frame;
	frame.origin.x = 10 + (lineNum * cellWidth) + (10 * lineNum);
	self.frame = frame;
	
	
	NSDictionary *commonProductItems = self.dicData[@"commonProduct"];
	
	NSString *imgUrl = commonProductItems[@"prdImgUrl"];
	NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
	
	if ([imgUrl length] > 0) {
		NSRange strRange = [imgUrl rangeOfString:@"http"];
		if (strRange.location == NSNotFound) {
			imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
		}
		strRange = [imgUrl rangeOfString:@"{{img_width}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)cellWidth]];
		}
		strRange = [imgUrl rangeOfString:@"{{img_height}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)cellWidth]];
		}
		
		[self.commonProductThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	else {
		[self.commonProductThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	
	
	if (commonProductItems[@"RANK"]) {
		[self.commonProductRankingLabel setText:[commonProductItems[@"RANK"] stringValue]];
	}
	
	
	if (commonProductItems[@"prdNm"]) {
        NSString *str = commonProductItems[@"prdNm"];
        NSInteger index = 0;
        
        for (int i = 0; i < [str length]; i++) {
            CGSize size = [[str substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.commonProductProductNameLabel.frame)) lineBreakMode:self.commonProductProductNameLabel.lineBreakMode];
            
            if (size.width > CGRectGetWidth(self.commonProductProductNameLabel.frame)) {
                break;
            }
            index = i;
        }
        
        [self.commonProductProductNameLabel setText:[str substringWithRange:NSMakeRange(0, index)]];
	}
	
	if (commonProductItems[@"selPrc"] && ![commonProductItems[@"selPrc"] isEqualToString:commonProductItems[@"finalDscPrc"]]) {
		NSString *priceString = [NSString stringWithFormat:@"%@원", [commonProductItems[@"selPrc"] formatThousandComma]];
		CGSize priceLabelSize = [priceString sizeWithFont:[UIFont systemFontOfSize:10]];
		
		[self.commonProductPriceLabel setFrame:CGRectMake(10, self.commonProductCellContentView.frame.size.height-34, priceLabelSize.width, 11)];
		[self.commonProductPriceLabel setText:priceString];
		
		[self.commonProductLineView setFrame:CGRectMake(10, 0, CGRectGetWidth(self.commonProductPriceLabel.frame), 1)];
		[self.commonProductLineView setCenter:CGPointMake(CGRectGetWidth(self.commonProductPriceLabel.frame)/2, CGRectGetHeight(self.commonProductPriceLabel.frame)/2)];
	}
	else {
		[self.commonProductPriceLabel setText:@""];
		[self.commonProductLineView setFrame:CGRectMake(0, 0, 0, 0)];
	}
	
	if (commonProductItems[@"finalDscPrc"]) {
		NSString *discountString = [commonProductItems[@"finalDscPrc"] formatThousandComma];
		CGSize discountLabelSize = [discountString sizeWithFont:[UIFont boldSystemFontOfSize:16]];
		
		[self.commonProductDiscountLabel setFrame:CGRectMake(10, self.commonProductCellContentView.frame.size.height-24, discountLabelSize.width, 17)];
		[self.commonProductDiscountLabel setText:discountString];
		
		[self.commonProductUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.commonProductDiscountLabel.frame), self.commonProductDiscountLabel.frame.origin.y+4, 11, 11)];
	}
	
	if (commonProductItems[@"icons"]) {
		NSArray *freeShip = commonProductItems[@"icons"];
		[self.commonProductFreeShipLabel setHidden:YES];
		
		for (NSString *str in freeShip) {
			if ([str isEqualToString:@"freeDlv"]) {
				[self.commonProductFreeShipLabel setHidden:NO];
				break;
			}
		}
	}
	
	//Action 설정
	NSDictionary *bestItem = self.dicData[@"commonProduct"];
	NSString *linkUrl = bestItem[@"linkUrl"];
	
	self.commonProductBlankButton.actionType = CPButtonActionTypeOpenSubview;
	self.commonProductBlankButton.actionItem = linkUrl;
	self.commonProductBlankButton.wiseLogCode = @"MAL0400";
	
	
	[self.commonProductBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"%@,%@",
														  self.commonProductProductNameLabel.text,
														  self.commonProductPriceLabel.text]
													Hint:@""];
}

- (void)setBestProductCategory:(NSIndexPath *)indexPath
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];

	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger lineNum = indexPath.row % (NSInteger)columnCount;
	CGRect frame = self.frame;
	frame.origin.x = 10 + (lineNum * cellWidth) + (10 * lineNum);
	self.frame = frame;
	
	NSArray *categoryBestItems = self.dicData[@"items"];
	
	for (UIView *subView in [self.bestProductCategoryCellContentView subviews]) {
		[subView removeFromSuperview];
	}
	
	UIButton *bpcCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[bpcCategoryButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bestProductCategoryCellContentView.frame), 30)];
	[bpcCategoryButton setTitle:@"카테고리 베스트" forState:UIControlStateNormal];
	[bpcCategoryButton setTitleColor:UIColorFromRGB(0x979fe4) forState:UIControlStateNormal];
	[bpcCategoryButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
	[bpcCategoryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[bpcCategoryButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	[self.bestProductCategoryCellContentView addSubview:bpcCategoryButton];
	
	CGFloat topHeight = 30;
	CGFloat buttonHeight = (CGRectGetHeight(self.bestProductCategoryCellContentView.frame)-(30+SHADOW_HEIGHT))/categoryBestItems.count;
	
	for (int i = 0; i < categoryBestItems.count; i++) {
		NSDictionary *categoryItem = categoryBestItems[i];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight + (buttonHeight * i), CGRectGetWidth(self.bestProductCategoryCellContentView.frame), 1)];
		[lineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
		[self.bestProductCategoryCellContentView addSubview:lineView];
		
		UIView *cateView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame), buttonHeight)];
		[self.bestProductCategoryCellContentView addSubview:cateView];
		
		UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame)-10, buttonHeight)];
		[categoryLabel setText:categoryItem[@"title"]];
		[categoryLabel setTextColor:UIColorFromRGB(0x333333)];
		[categoryLabel setFont:[UIFont systemFontOfSize:14]];
		[self.bestProductCategoryCellContentView addSubview:categoryLabel];
		
		CPTouchActionView *categoryButton = [[CPTouchActionView alloc] init];
		[categoryButton setFrame:CGRectMake(0, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame), buttonHeight)];
		[categoryButton setDelegate:self];
		[categoryButton setActionType:CPButtonActionTypeSendDelegateMessageCategoryBest];
		[categoryButton setActionItem:categoryItem[@"linkUrl"]];
		[self.bestProductCategoryCellContentView addSubview:categoryButton];

		UIImage *arrow = [UIImage imageNamed:@"besttab_ca_arrow.png"];
		UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrow];
		[arrowImageView setFrame:CGRectMake(CGRectGetWidth(self.bestProductCategoryCellContentView.frame) - arrow.size.width - 16, 11.5f + topHeight + (buttonHeight * i), arrow.size.width, arrow.size.height)];
		[self.bestProductCategoryCellContentView addSubview:arrowImageView];
	}
	
	self.commonShadowLine.frame = CGRectMake(0, self.bestProductCategoryCellContentView.frame.size.height-SHADOW_HEIGHT,
											 self.bestProductCategoryCellContentView.frame.size.width, SHADOW_HEIGHT);
	[self.bestProductCategoryCellContentView addSubview:self.commonShadowLine];
}

- (void)setBannerProduct:(NSIndexPath *)indexPath
{
	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger groupNameIndex = [self.dicData[@"groupNameIndex"] integerValue];
	[self setOddItemOffsetX:groupNameIndex indexPath:indexPath];
	
	NSDictionary *bannerProductItems = self.dicData[@"bannerProduct"];
	
	NSInteger productWidth = [Modules getBestLayoutItemWidth:kScreenBoundsWidth-20.f columnCount:(IS_IPAD ? 2 : 1)];
	NSInteger productHeight = productWidth/1.78+121;
	
	//이미지
	NSString *imgUrl = bannerProductItems[@"lnkBnnrImgUrl"];
	NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
	
	if ([imgUrl length] > 0) {
		NSRange strRange = [imgUrl rangeOfString:@"http"];
		if (strRange.location == NSNotFound) {
			imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
		}
		strRange = [imgUrl rangeOfString:@"{{img_width}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(productWidth*2)]];
		}
		strRange = [imgUrl rangeOfString:@"{{img_height}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)((productHeight-121)*2)]];
		}
		
		[self.bannerProductThumbnailView setFrame:CGRectMake(0, 0, productWidth, productHeight-121)];
		[self.bannerProductThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	else {
		[self.bannerProductThumbnailView setFrame:CGRectMake(0, 0, productWidth, productHeight-121)];
		[self.bannerProductThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	
	[self.bannerProductProductInfoView setFrame:CGRectMake(0, CGRectGetMaxY(self.bannerProductThumbnailView.frame)+1, productWidth, 83)];
	
	//상품명
	if (bannerProductItems[@"extraText"]) {
		
		NSString *str = bannerProductItems[@"extraText"];
		NSInteger index = 0;
		
		[self.bannerProductProductNameLabel setFrame:CGRectMake(15, 10, productWidth-20, 20)];
		
		for (int i = 0; i < [str length]; i++) {
			CGSize size = [[str substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.bannerProductProductNameLabel.frame)) lineBreakMode:self.bannerProductProductNameLabel.lineBreakMode];
			
			if (size.width > CGRectGetWidth(self.bannerProductProductNameLabel.frame)) {
				break;
			}
			index = i;
		}
		
		if ([str length] > 0) {
			[self.bannerProductProductNameLabel setText:[str substringWithRange:NSMakeRange(0, index+1)]];
		}
	}
	
	
	//할인률
	if (bannerProductItems[@"discountRate"]) {
		if ([bannerProductItems[@"discountRate"] isAllDigits]) {
			NSString *text = [NSString stringWithFormat:@"%@%@", bannerProductItems[@"discountRate"], @"%"];
			
			[self.bannerProductDiscountRate setFrame:CGRectMake(15, CGRectGetHeight(self.bannerProductProductInfoView.frame)-44, 55, 32)];
			[self.bannerProductDiscountRate setFont:[UIFont boldSystemFontOfSize:31]];
			[self.bannerProductDiscountRate setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
				NSRange colorRange = [text rangeOfString:@"%"];
				if (colorRange.location != NSNotFound)
				{
					[mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:18] range:colorRange];
				}
				return mutableAttributedString;
			}];
		}
		//특별가
		else {
			[self.bannerProductDiscountRate setFrame:CGRectMake(15, CGRectGetHeight(self.bannerProductProductInfoView.frame)-32, 55, 20)];
			[self.bannerProductDiscountRate setFont:[UIFont boldSystemFontOfSize:19]];
			[self.bannerProductDiscountRate setText:[NSString stringWithFormat:@"%@", bannerProductItems[@"discountRate"]]];
		}
	}
	
	
	//실제가격
	if (bannerProductItems[@"selPrc"] && ![bannerProductItems[@"selPrc"] isEqualToString:bannerProductItems[@"finalDscPrc"]]) {
		NSString *priceString = [bannerProductItems[@"selPrc"] formatThousandComma];
		CGSize priceLabelSize = [priceString sizeWithFont:[UIFont systemFontOfSize:12]];
		
		[self.bannerProductPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductDiscountRate.frame)+3, CGRectGetMaxY(self.bannerProductProductNameLabel.frame)+10, priceLabelSize.width, 13)];
		[self.bannerProductPriceLabel setText:priceString];
		
		[self.bannerProductPriceUnitLabel setText:@"원"];
		[self.bannerProductPriceUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductPriceLabel.frame), CGRectGetMaxY(self.bannerProductProductNameLabel.frame)+12, 9, 10)];
		
		[self.bannerProductLineView setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductDiscountRate.frame)+3, 0, CGRectGetWidth(self.bannerProductPriceLabel.frame)+CGRectGetWidth(self.bannerProductPriceUnitLabel.frame), 1)];
		[self.bannerProductLineView setCenter:CGPointMake((CGRectGetWidth(self.bannerProductPriceLabel.frame)+CGRectGetWidth(self.bannerProductPriceUnitLabel.frame))/2, CGRectGetHeight(self.bannerProductPriceLabel.frame)/2)];
	}
	else {
		[self.bannerProductPriceLabel setText:@""];
		[self.bannerProductPriceUnitLabel setText:@""];
		[self.bannerProductLineView setFrame:CGRectMake(0, 0, 0, 0)];
	}
	
	
	//할인가
	if (bannerProductItems[@"finalDscPrc"]) {
		NSString *discountString = [bannerProductItems[@"finalDscPrc"] formatThousandComma];
		CGSize discountLabelSize = [discountString sizeWithFont:[UIFont boldSystemFontOfSize:18]];
		
		[self.bannerProductDiscountLabel setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductDiscountRate.frame)+3, CGRectGetMaxY(self.bannerProductProductNameLabel.frame)+22, discountLabelSize.width, 19)];
		[self.bannerProductDiscountLabel setText:discountString];
		
		[self.bannerProductUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductDiscountLabel.frame), CGRectGetMaxY(self.bannerProductProductNameLabel.frame)+28, 12, 12)];
	}
	
	
	//T멤버십, 마일리지, 무료배송
	if ([bannerProductItems[@"icons"] count] > 0) {
		
		NSArray *array = bannerProductItems[@"icons"];
//		NSInteger arrayCount = [array count];
//		
//		//3.5인치의 경우 max는 4개
//		if ((IS_IPHONE_4 || IS_IPHONE_5) && arrayCount > 4) {
//			arrayCount = 4;
//		}
		
		[self.bannerProductStampView setFrame:CGRectMake(productWidth-6-([bannerProductItems[@"icons"] count]*36), CGRectGetHeight(self.bannerProductProductInfoView.frame)-45, [bannerProductItems[@"icons"] count]*36, 36)];
		
		for (UIView *subView in [self.bannerProductStampView subviews]) {
			[subView removeFromSuperview];
		}
		
		for (NSString *str in array) {
			
			if ((IS_IPHONE_4 || IS_IPHONE_5) && [array indexOfObject:str] >= 4) {
				break;
			}
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
			[self.bannerProductStampView addSubview:imageView];
			
			UIImage *image = [[UIImage alloc] init];
			
			if ([str isEqualToString:@"tMember"]) {
				image = [UIImage imageNamed:@"ic_t.png"];
			}
			else if ([str isEqualToString:@"mileage"]) {
				image = [UIImage imageNamed:@"ic_m.png"];
			}
			else if ([str isEqualToString:@"freeDlv"]) {
				image = [UIImage imageNamed:@"ic_free.png"];
			}
			else if ([str isEqualToString:@"myWay"]) {
				image = [UIImage imageNamed:@"ic_me.png"];
			}
			else if ([str isEqualToString:@"discountCard"]) {
				image = [UIImage imageNamed:@"ic_card.png"];
			}
			
			[imageView setFrame:CGRectMake([array indexOfObject:str]*36, 0, 36, 36)];
			[imageView setImage:image];
		}
	}
	else {
		for (UIView *subView in [self.bannerProductStampView subviews]) {
			[subView removeFromSuperview];
		}
	}
	
	//구매개수
    NSInteger selQty = [bannerProductItems[@"selQty"] integerValue];
    NSString *purchaseCount = @"";
    NSString *purchaseUnit = @"";
    
    if (selQty > 0) {
        purchaseCount = [Modules numberFormat:selQty];
        purchaseUnit = @"개 구매";
        
        [self.bannerProductPurchaseCountLabel setFont:[UIFont boldSystemFontOfSize:14]];
    }
    else {
        purchaseCount = @"추천상품";
        purchaseUnit = @"";
        
        [self.bannerProductPurchaseCountLabel setFont:[UIFont systemFontOfSize:14]];
    }
    
    [self.bannerProductPurchaseCountLabel setText:purchaseCount];
    [self.bannerProductPurchaseUnitLabel setText:purchaseUnit];
    
    CGSize countSize = [self.bannerProductPurchaseCountLabel.text sizeWithFont:self.bannerProductPurchaseCountLabel.font constrainedToSize:CGSizeMake(10000, 15) lineBreakMode:self.bannerProductPurchaseCountLabel.lineBreakMode];
    CGSize unitSize = [self.bannerProductPurchaseUnitLabel.text sizeWithFont:self.bannerProductPurchaseUnitLabel.font constrainedToSize:CGSizeMake(10000, 15) lineBreakMode:self.bannerProductPurchaseUnitLabel.lineBreakMode];
    
    CGFloat size = countSize.width + unitSize.width;
    
    [self.bannerProductPurchaseCountButton setFrame:CGRectMake(0, CGRectGetMaxY(self.bannerProductProductInfoView.frame)+1, CGRectGetWidth(self.bannerProductProductInfoView.frame)/2, 36)];
    [self.bannerProductPurchaseTitleView setFrame:CGRectMake((CGRectGetWidth(self.bannerProductPurchaseCountButton.frame)-size)/2, (CGRectGetHeight(self.bannerProductPurchaseCountButton.frame)-15)/2, size, 15)];
    [self.bannerProductPurchaseCountLabel setFrame:CGRectMake(0, 0, countSize.width, 15)];
    [self.bannerProductPurchaseUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductPurchaseCountLabel.frame), 0, unitSize.width, 15)];
	
	//연관상품
	[self.bannerProductRelativeProductButton setTag:indexPath.row];
	[self.bannerProductRelativeProductButton setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductPurchaseCountButton.frame)+1, CGRectGetMaxY(self.bannerProductProductInfoView.frame)+1, CGRectGetWidth(self.bannerProductProductInfoView.frame)/2-1, 36)];
	[self.bannerProductRelativeProductButton addTarget:self action:@selector(touchRelativeProduct:) forControlEvents:UIControlEventTouchUpInside];
	[self.bannerProductRelativeProductButton setAccessibilityLabel:@"연관상품 보기" Hint:@""];
	
	[self.bannerProductRelativeProductLabel setText:@"연관상품"];
	[self.bannerProductRelativeProductImage setImage:[UIImage imageNamed:@"bt_plus_s.png"]];
	
	CGSize relativeProductLabelSize = [self.bannerProductRelativeProductLabel.text sizeWithFont:self.bannerProductRelativeProductLabel.font constrainedToSize:CGSizeMake(10000, 20) lineBreakMode:self.bannerProductRelativeProductLabel.lineBreakMode];
	
	size = relativeProductLabelSize.width + 20;
	
	[self.bannerProductRelativeProductLabel setFrame:CGRectMake((CGRectGetWidth(self.bannerProductRelativeProductButton.frame)-size)/2, (CGRectGetHeight(self.bannerProductRelativeProductButton.frame)-20)/2, relativeProductLabelSize.width, 20)];
	[self.bannerProductRelativeProductImage setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductRelativeProductLabel.frame), (CGRectGetHeight(self.bannerProductRelativeProductButton.frame)-20)/2, 20, 20)];
	
	[self.bannerProductBlankButton setFrame:CGRectMake(0, 0, productWidth, productHeight-36)];
	[self.bannerProductBlankButton setActionType:CPButtonActionTypeOpenSubview];
	[self.bannerProductBlankButton setActionItem:self.dicData[@"bannerProduct"][@"linkUrl"]];
	[self.bannerProductBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"%@,%@원",
														  self.bannerProductProductNameLabel.text,
														  self.bannerProductDiscountLabel.text]
													Hint:@""];
	//WiseLog
    NSString *wiseLogCode = self.dicData[@"wiseLogCode"];
    if (wiseLogCode && [wiseLogCode length] > 0) {
        self.bannerProductBlankButton.wiseLogCode = wiseLogCode;
    }
    
	
	if ([bannerProductItems[@"movieYn"] isEqualToString:@"Y"]) {
		[self.bannerProductVideoPlayButton setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductThumbnailView.frame)-50, CGRectGetMaxY(self.bannerProductThumbnailView.frame)-50, 40, 40)];
		[self.bannerProductVideoPlayButton setImage:[UIImage imageNamed:@"bt_small_play.png"] forState:UIControlStateNormal];
		[self.bannerProductVideoPlayButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
		[self.bannerProductVideoPlayButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
		[self.bannerProductVideoPlayButton setHidden:NO];
		[self.bannerProductVideoPlayButton setTag:indexPath.row];
		[self.bannerProductVideoPlayButton addTarget:self action:@selector(touchVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
		[self.bannerProductVideoPlayButton setAccessibilityLabel:@"동영상 재생" Hint:@""];
	}
	else {
		[self.bannerProductVideoPlayButton setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductThumbnailView.frame)-50, CGRectGetMaxY(self.bannerProductThumbnailView.frame)-50, 40, 40)];
		[self.bannerProductVideoPlayButton setHidden:YES];
	}
	
	[self.contentView addSubview:self.bannerProductVideoPlayButton];
	
}

- (void)setLineBanner:(NSIndexPath *)indexPath
{
	CGFloat screenWidth = kScreenBoundsWidth-20;
	CGFloat columnCount = IS_IPAD ? 4 : 2;
	CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
	
	NSDictionary *lineBannerItems = self.dicData[@"lineBanner"];
	
	//backgroundColor
	NSString *colorValue = lineBannerItems[@"extraText"];
	if (colorValue.length >= 7) {
		unsigned colorInt = 0;
		[[NSScanner scannerWithString:[colorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
		[self.lineBannerContentView setBackgroundColor:UIColorFromRGB(colorInt)];
	}
	else {
		[self.lineBannerContentView setBackgroundColor:UIColorFromRGBA(0x000000, 0.5f)];
	}
	
	//backgroundImage
	NSString *imgUrl = lineBannerItems[@"lnkBnnrImgUrl"];
	NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
	
	if ([imgUrl length] > 0) {
		NSRange strRange = [imgUrl rangeOfString:@"http"];
		if (strRange.location == NSNotFound) {
			imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
		}
		strRange = [imgUrl rangeOfString:@"{{img_width}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)cellWidth]];
		}
		strRange = [imgUrl rangeOfString:@"{{img_height}}"];
		if (strRange.location != NSNotFound) {
			imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)cellWidth]];
		}
		
		[self.lineBannerImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	else {
		[self.lineBannerImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	
	NSString *wiseLogCode = @"";
	if (self.delegate && [self.delegate respondsToSelector:@selector(getViewWiselogCode:)]) {
		wiseLogCode = [self.delegate getViewWiselogCode:@"lineBanner"];
	}

	[self.lineBannerButton setActionType:CPButtonActionTypeOpenSubview];
	[self.lineBannerButton setActionItem:self.dicData[@"lineBanner"][@"dispObjLnkUrl"]];
	[self.lineBannerButton setWiseLogCode:wiseLogCode];
	
	if (lineBannerItems[@"dispObjNm"]) {
		[self.lineBannerButton setAccessibilityLabel:lineBannerItems[@"dispObjNm"] Hint:@""];
	}

	if (lineBannerItems[@"text"]) {
		[self.lineBannerButton setAccessibilityLabel:lineBannerItems[@"text"] Hint:@""];
	}
}

- (void)setAutoBannerArea:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.autoBannerItemView.subviews) {
		[subview removeFromSuperview];
	}

	NSArray *items = self.dicData[@"autoBannerArea"];
	
	CPTalkAutoBannerView *areaView = [[CPTalkAutoBannerView alloc] initWithFrame:self.autoBannerItemView.bounds items:items];
	areaView.delegate = self;
	[self.autoBannerItemView addSubview:areaView];
}

- (void)setShockingDealAppLink:(NSIndexPath *)indexPath
{
	NSString *shockingDealAppURL = self.dicData[@"urlScheme"];
	NSString *shockingDealAppstoreURL = self.dicData[@"storeURL"];

	NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
						  shockingDealAppURL, @"deeplink",
						  shockingDealAppstoreURL, @"appstore", nil];
	
	self.shockingDealAppLinkMoreButton.actionType = CPButtonActionTypeSendOtherAppDeepLink;
	self.shockingDealAppLinkMoreButton.actionItem = item;
	[self.shockingDealAppLinkMoreButton setAccessibilityLabel:@"쇼킹딜앱에서 상품 더 보기" Hint:@""];
}

- (void)setTalkBannerItems:(NSIndexPath *)indexPath
{
	//header subview 제거
	for (UIView *subView in [self.talkHeaderView subviews]) {
		[subView removeFromSuperview];
	}
	
	//thumbnail subview 제거
	for (UIView *subView in [self.talkThumbnailView subviews]) {
		[subView removeFromSuperview];
	}
	
	//footer subview 제거
	for (UIView *subView in [self.talkFooterView subviews]) {
		[subView removeFromSuperview];
	}
	
	CGFloat widthMargin = (self.talkHeaderView.frame.size.width == 300 ? 10 : 16);
	
	//Header
	NSString *title = self.dicData[@"talkBanner"][@"title"];
	NSString *dispObjNm = self.dicData[@"talkBanner"][@"dispObjNm"];
	
	NZLabel *titleLabel = [[NZLabel alloc] initWithFrame:CGRectMake(widthMargin, 11, self.talkHeaderView.frame.size.width-(widthMargin*2), 0.f)];
	[titleLabel setNumberOfLines:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7") && !IS_IPAD ? 2 : 1)];
	[titleLabel setTextColor:UIColorFromRGB(0x333333)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setAdjustsFontSizeToFitWidth:NO];
	[self.talkHeaderView addSubview:titleLabel];
	
	[titleLabel setText:[NSString stringWithFormat:@"%@ %@", title, dispObjNm]];
	[titleLabel setFontColor:UIColorFromRGB(0x5F7FE4) string:title];
	[titleLabel setFont:[UIFont systemFontOfSize:16]];
	[titleLabel setNumberOfLines:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7") && !IS_IPAD ? 2 : 1)];
	[titleLabel sizeToFitWithVersionHoldWidth];
	
	NSString *dispObjBgnDy = self.dicData[@"talkBanner"][@"dispObjBgnDy"];
	NSString *clickCnt = (self.dicData[@"talkBanner"][@"clickCnt"] ? self.dicData[@"talkBanner"][@"clickCnt"] : @"0");
	
	NZLabel *subDescLabel = [[NZLabel alloc] initWithFrame:CGRectMake(widthMargin, CGRectGetMaxY(titleLabel.frame)+3.f, 0.f, 0.f)];
	[subDescLabel setBackgroundColor:[UIColor clearColor]];
	[subDescLabel setTextColor:UIColorFromRGB(0x999999)];
	[subDescLabel setFont:[UIFont systemFontOfSize:13]];
	[self.talkHeaderView addSubview:subDescLabel];
	
	[subDescLabel setText:[NSString stringWithFormat:@"%@ | %@", dispObjBgnDy, @"조회 :"]];
	[subDescLabel setFontColor:UIColorFromRGB(0xECECEC) string:@"|"];
	[subDescLabel sizeToFitWithVersion];
	
	UILabel *clickCntLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(subDescLabel.frame)+3, subDescLabel.frame.origin.y,
																	   0, subDescLabel.frame.size.height)];
	[clickCntLabel setBackgroundColor:[UIColor clearColor]];
	[clickCntLabel setTextColor:UIColorFromRGB(0x999999)];
	[clickCntLabel setFont:[UIFont boldSystemFontOfSize:13]];
	[clickCntLabel setText:clickCnt];
	[clickCntLabel sizeToFitWithVersionHoldHeight];
	[self.talkHeaderView addSubview:clickCntLabel];
	
	NSInteger brdCnt = [self.dicData[@"talkBanner"][@"brdCnt"] intValue];
	NSInteger likeCnt = [self.dicData[@"talkBanner"][@"likeCnt"] intValue];
	
	CPTalkCountsView *countsView = [[CPTalkCountsView alloc] initWithReplyCount:brdCnt loveCount:likeCnt];
	countsView.frame = CGRectMake(CGRectGetMaxX(self.talkHeaderView.frame)-countsView.frame.size.width-widthMargin,
								  subDescLabel.frame.origin.y+3.f,
								  countsView.frame.size.width,
								  countsView.frame.size.height);
	[self.talkHeaderView addSubview:countsView];
	
	self.talkHeaderView.frame = CGRectMake(0, 0, self.talkHeaderView.frame.size.width, CGRectGetMaxY(subDescLabel.frame)+10.f);
	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.talkHeaderView.frame)-1, self.talkHeaderView.frame.size.width, 1)];
	lineView.backgroundColor = UIColorFromRGB(0xF0F2F3);
	[self.talkHeaderView addSubview:lineView];
	
	//thumbnail
	NSString *imageUrl = self.dicData[@"talkBanner"][@"lnkBnnrImgUrl"];
	NSString *lnkBnnrTxt = [self.dicData[@"talkBanner"][@"lnkBnnrTxt"] trim];
	
	if (imageUrl && [imageUrl length] > 0) {
		CGFloat thumbnailHeight = [Modules getRatioHeight:CGSizeMake(676, 400) screebWidth:self.talkThumbnailView.frame.size.width];
		self.talkThumbnailView.frame = CGRectMake(self.talkThumbnailView.frame.origin.x,
												  CGRectGetMaxY(self.talkHeaderView.frame),
												  self.talkThumbnailView.frame.size.width,
												  thumbnailHeight);
		
		self.talkThumbnailView.backgroundColor = [UIColor clearColor];
		
		CPThumbnailView *thumbnailView = [[CPThumbnailView alloc] initWithFrame:self.talkThumbnailView.bounds];
		[self.talkThumbnailView addSubview:thumbnailView];
		
		[thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	else {
		if (IS_IPAD) {
			CGFloat thumbnailHeight = [Modules getRatioHeight:CGSizeMake(676, 400) screebWidth:self.talkThumbnailView.frame.size.width];
			self.talkThumbnailView.frame = CGRectMake(self.talkThumbnailView.frame.origin.x,
													  CGRectGetMaxY(self.talkHeaderView.frame),
													  self.talkThumbnailView.frame.size.width,
													  thumbnailHeight);
			self.talkThumbnailView.backgroundColor = UIColorFromRGB(0xfcfae6);
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20,
																		   self.talkThumbnailView.frame.size.width-60.f,
																		   self.talkThumbnailView.frame.size.height-40.f)];
			textLabel.numberOfLines = 5;
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.textColor = UIColorFromRGB(0x757575);
			textLabel.font = [UIFont boldSystemFontOfSize:19];
			textLabel.textAlignment = NSTextAlignmentLeft;
			textLabel.text = lnkBnnrTxt;
			[textLabel sizeToFitWithVersionHoldWidth];
			[self.talkThumbnailView addSubview:textLabel];
			
			textLabel.frame = CGRectMake(textLabel.frame.origin.x,
										 (self.talkThumbnailView.frame.size.height/2)-(textLabel.frame.size.height/2),
										 textLabel.frame.size.width,
										 textLabel.frame.size.height);
		}
		else {
			self.talkThumbnailView.frame = CGRectMake(self.talkThumbnailView.frame.origin.x,
													  CGRectGetMaxY(self.talkHeaderView.frame),
													  self.talkThumbnailView.frame.size.width,
													  0.f);
			self.talkThumbnailView.backgroundColor = UIColorFromRGB(0xfcfae6);
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, self.talkThumbnailView.frame.size.width-60.f, 0)];
			textLabel.numberOfLines = 5;
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.textColor = UIColorFromRGB(0x757575);
			textLabel.font = [UIFont boldSystemFontOfSize:19];
			textLabel.textAlignment = NSTextAlignmentLeft;
			textLabel.text = lnkBnnrTxt;
			[textLabel sizeToFitWithVersionHoldWidth];
			[self.talkThumbnailView addSubview:textLabel];
			
			self.talkThumbnailView.frame = CGRectMake(self.talkThumbnailView.frame.origin.x,
													  CGRectGetMaxY(self.talkHeaderView.frame),
													  self.talkThumbnailView.frame.size.width,
													  40.f + textLabel.frame.size.height);
		}
	}
	
	//footer
	NSArray *tagItems = self.dicData[@"talkBanner"][@"tagList"];
	if ((!tagItems || [tagItems count] == 0) && !IS_IPAD) {
		self.talkFooterView.frame = CGRectMake(self.talkFooterView.frame.origin.x,
											   CGRectGetMaxY(self.talkThumbnailView.frame),
											   self.talkFooterView.frame.size.width,
											   SHADOW_HEIGHT);
		
		UIView *footLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.talkFooterView.frame.size.width, 1)];
		footLineView.backgroundColor = UIColorFromRGB(0xF0F2F3);
		[self.talkFooterView addSubview:footLineView];
	}
	else {
		self.talkFooterView.frame = CGRectMake(self.talkFooterView.frame.origin.x,
											   CGRectGetMaxY(self.talkThumbnailView.frame),
											   self.talkFooterView.frame.size.width,
											   35.f);
		
		UIView *footLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.talkFooterView.frame.size.width, 1)];
		footLineView.backgroundColor = UIColorFromRGB(0xF0F2F3);
		[self.talkFooterView addSubview:footLineView];
		
		if ([tagItems count] == 0 && IS_IPAD) {
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0,
																	   self.talkFooterView.frame.size.width-30.f,
																	   self.talkFooterView.frame.size.height)];
			label.backgroundColor = [UIColor clearColor];
			label.textColor = UIColorFromRGBA(0x757575, 0.5);
			label.font = [UIFont systemFontOfSize:14];
			label.text = @"태그가 없습니다.";
			[self.talkFooterView addSubview:label];
		}
		else {
			CPTalkTagView *tagView = [[CPTalkTagView alloc] initWithItems:tagItems];
			tagView.delegate = self;
			tagView.frame = CGRectMake(10.f,
									   (self.talkFooterView.frame.size.height/2)-(tagView.frame.size.height/2),
									   tagView.frame.size.width,
									   tagView.frame.size.height);
			[self.talkFooterView addSubview:tagView];
		}
	}
	
	// touchButton
	self.talkTouchButton.frame = CGRectMake(0, 0,
											self.talkCellContentView.frame.size.width,
											CGRectGetMaxY(self.talkThumbnailView.frame));
	self.talkTouchButton.actionType = CPButtonActionTypeOpenSubview;
	self.talkTouchButton.actionItem = [self.dicData[@"talkBanner"][@"dispObjLnkUrl"] trim];
	self.talkTouchButton.wiseLogCode = @"MAF0200";
	[self.talkTouchButton setAccessibilityLabel:dispObjNm Hint:@""];
	
	//최종 높이 계산. (사실은 컨텐츠 뷰 높이를 해도 괜찮을 듯..)
	self.talkCellContentView.frame = CGRectMake(self.talkCellContentView.frame.origin.x,
												self.talkCellContentView.frame.origin.y,
												self.talkCellContentView.frame.size.width,
												CGRectGetMaxY(self.talkFooterView.frame)+SHADOW_HEIGHT);
	
	self.commonShadowLine.frame = CGRectMake(0, CGRectGetMaxY(self.talkCellContentView.frame)-SHADOW_HEIGHT,
											 CGRectGetWidth(self.talkCellContentView.frame), SHADOW_HEIGHT);
}

- (void)setSpecialBestArea:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaCellContentView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSInteger columnCount = [self.dicData[@"columnCount"] integerValue];
	NSArray *items = self.dicData[@"items"];
	
	CGSize viewSize = [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount];
	self.specialBestAreaCellContentView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
	
	CPFooterButtonView *areaView = [[CPFooterButtonView alloc] initWithFrame:self.specialBestAreaCellContentView.bounds];
	[areaView setType:CPFooterButtonUITypeNormal widthCount:columnCount];
	[areaView initData:items];
	[areaView setDelegate:self];
	[self.specialBestAreaCellContentView addSubview:areaView];
}

- (void)setMiddleServiceArea:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaCellContentView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSString *groupName = self.dicData[@"groupName"];
	NSInteger columnCount = [self.dicData[@"columnCount"] integerValue];
	NSArray *items = self.dicData[groupName];
	
	CGSize viewSize = [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount];
	self.specialBestAreaCellContentView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
	
	CPFooterButtonView *areaView = [[CPFooterButtonView alloc] initWithFrame:self.specialBestAreaCellContentView.bounds];
	[areaView setType:CPFooterButtonUITypeNormal widthCount:columnCount];
	[areaView initData:items];
	[areaView setDelegate:self];
	[self.specialBestAreaCellContentView addSubview:areaView];
}

- (void)setBottomTalkArea:(NSIndexPath *)indexPath
{
    for (UIView *subView in [self.specialBestAreaCellContentView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSString *groupName = self.dicData[@"groupName"];
    NSArray *items = self.dicData[groupName];

    CGFloat columnCount = (IS_IPAD ? 4 : 2);
    CGFloat columnWidth = (kScreenBoundsWidth-20) / columnCount;
    CGFloat lineHeight = [Modules getRatioHeight:CGSizeMake(170, 74) screebWidth:columnWidth];
    CGSize viewSize = CGSizeMake(kScreenBoundsWidth-20, lineHeight * (IS_IPAD ? 2 : 4));

    self.specialBestAreaCellContentView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);

    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    
    for (NSInteger i=0; i<[items count]; i++) {
        NSString *imageName = [NSString stringWithFormat:@"sp_talk_view_img_%02ld.png", (long)i+1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, columnWidth, lineHeight)];
        imageView.image = [UIImage imageNamed:imageName];
        [self.specialBestAreaCellContentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UIColorFromRGB(0xffffff);
        label.font = [UIFont boldSystemFontOfSize:17];
        label.text = items[i][@"text"];
        [label sizeToFitWithVersion];
        [imageView addSubview:label];
        
        label.frame = CGRectMake((imageView.frame.size.width/2)-(label.frame.size.width/2),
                                 (imageView.frame.size.height/2)-(label.frame.size.height/2),
                                 label.frame.size.width, label.frame.size.height);

        UILabel *shadowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shadowLabel.backgroundColor = [UIColor clearColor];
        shadowLabel.textColor = UIColorFromRGBA(0x000000, 0.2);
        shadowLabel.font = [UIFont boldSystemFontOfSize:17];
        shadowLabel.text = items[i][@"text"];
        [shadowLabel sizeToFitWithVersion];
        [imageView addSubview:shadowLabel];
        
        [imageView sendSubviewToBack:shadowLabel];
        
        shadowLabel.frame = CGRectMake(label.frame.origin.x+1,
                                       label.frame.origin.y+1,
                                       shadowLabel.frame.size.width, shadowLabel.frame.size.height);

        CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:imageView.frame];
        actionView.actionType = CPButtonActionTypeOpenSubview;
        actionView.actionItem = items[i][@"linkUrl"];
        [actionView setAccessibilityLabel:label.text Hint:@""];
        [self.specialBestAreaCellContentView addSubview:actionView];
        
        offsetX += columnWidth;
        
        if (offsetX + columnWidth > self.specialBestAreaCellContentView.frame.size.width) {
            offsetX = 0;
            offsetY += lineHeight;
        }
    }
}

- (void)setCommonMoreLink:(NSIndexPath *)indexPath
{
	NSString *moreTitle = self.dicData[@"commonMoreView"][@"text"];
	
	[self.alMoreTitleLabel setText:moreTitle];
	CGSize moreTitleSize = [self.alMoreTitleLabel.text sizeWithFont:self.alMoreTitleLabel.font constrainedToSize:CGSizeMake(10000, 34) lineBreakMode:self.alMoreTitleLabel.lineBreakMode];
	NSInteger size = moreTitleSize.width + 12;
	
	[self.alMoreTitleLabel setFrame:CGRectMake((CGRectGetWidth(self.alMoreButton.frame)-size)/2, 0, moreTitleSize.width, 34)];
	[self.alMoreImageView setFrame:CGRectMake(CGRectGetMaxX(self.alMoreTitleLabel.frame)+5, (CGRectGetHeight(self.alMoreButton.frame)-11)/2, 7, 11)];
	
	
	NSString *moreWiseLogCode = @"";
	if (self.delegate && [self.delegate respondsToSelector:@selector(getViewWiselogCode:)]) {
		moreWiseLogCode = [self.delegate getViewWiselogCode:@"commonMoreView"];
	}
	
	self.alMoreButton.actionType = CPButtonActionTypeOpenSubview;
	self.alMoreButton.actionItem = [self.dicData[@"commonMoreView"][@"linkUrl"] trim];
	self.alMoreButton.wiseLogCode = moreWiseLogCode;
	[self.alMoreButton setAccessibilityLabel:moreTitle Hint:@""];
}

- (void)setSubEventTwoTab:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.esetButtonView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSArray *items = self.dicData[@"items"];
	
	CGFloat itemWidth = self.esetButtonView.frame.size.width/2;
	CGFloat itemHeight = self.esetButtonView.frame.size.height;
	
	[self.esetButtonView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
	
	for (NSInteger i=0; i<[items count]; i++) {
		
		NSString *btnTitle = items[i][@"title"];
		BOOL isSelected = [@"Y" isEqualToString:items[i][@"selected"]];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(i * itemWidth, 0, (NSInteger)itemWidth, itemHeight)];
		[btn setTitle:btnTitle forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0x888888) forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
		[btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf4f4f4) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateNormal];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4abecd) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateHighlighted];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4abecd) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateSelected];
		
		[btn setTag:i];
		[btn setSelected:isSelected];
		
		[btn addTarget:self action:@selector(onTouchSubEventTwoTab:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.esetButtonView addSubview:btn];
	}
}

- (void)setEventPlanBanner:(NSIndexPath *)indexPath
{
	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger groupNameIndex = [self.dicData[@"groupNameIndex"] integerValue];
	[self setOddItemOffsetX:groupNameIndex indexPath:indexPath];

	NSString *imageUrl = self.dicData[@"eventPlanBanner"][@"lnkBnnrImgUrl"];
	[self.epbThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	
	NSString *wiseLogCode = @"";
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(getViewWiselogCode:)]) {
		wiseLogCode = [self.delegate getViewWiselogCode:@"eventPlanBanner"];
	}
	
	self.epbTouchButton.actionType = CPButtonActionTypeOpenSubview;
	self.epbTouchButton.actionItem = [self.dicData[@"eventPlanBanner"][@"linkUrl"] trim];
	self.epbTouchButton.wiseLogCode = wiseLogCode;
	
	[self.epbTouchButton setAccessibilityLabel:self.dicData[@"eventPlanBanner"][@"text"] Hint:@""];
}

- (void)setEventZoneGroupBanner:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.eventZoneThreeBannerView subviews]) {
		[subView removeFromSuperview];
	}
	
	for (UIView *subView in [self.eventZoneTwoBannerView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSArray *serviceItems = self.dicData[@"eventZoneGroupBanner"][0][@"eventZoneThreeBanner"];
	CPEventServiceView *serviceView = [[CPEventServiceView alloc] initWithFrame:self.eventZoneThreeBannerView.bounds items:serviceItems];
	serviceView.delegate = self;
	[self.eventZoneThreeBannerView addSubview:serviceView];
	
	NSArray *activeItems = self.dicData[@"eventZoneGroupBanner"][1][@"eventZoneTwoBanner"];
	CPEventActiveView *activeView = [[CPEventActiveView alloc] initWithFrame:self.eventZoneTwoBannerView.bounds items:activeItems];
	activeView.delegate = self;
	[self.eventZoneTwoBannerView addSubview:activeView];
}

- (void)setEventWinner:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.eventWinnerView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSArray *items = self.dicData[@"eventWinner"];
	
	CGFloat height = [CPEventWinnerView getViewHeight:items];
	
	self.eventWinnerCellContentView.frame = CGRectMake(self.eventWinnerCellContentView.frame.origin.x,
													   self.eventWinnerCellContentView.frame.origin.y,
													   self.eventWinnerCellContentView.frame.size.width,
													   height+SHADOW_HEIGHT);
	
	self.eventWinnerView.frame = CGRectMake(self.eventWinnerView.frame.origin.x,
											self.eventWinnerView.frame.origin.y,
											self.eventWinnerView.frame.size.width,
											height);
	
	CPEventWinnerView *eventWinnerView = [[CPEventWinnerView alloc] initWithFrame:self.eventWinnerView.bounds items:items];
	eventWinnerView.delegate = self;
	[self.eventWinnerView addSubview:eventWinnerView];
	
	self.commonShadowLine.frame = CGRectMake(0,
											 self.eventWinnerCellContentView.frame.size.height-1,
											 self.eventWinnerCellContentView.frame.size.width,
											 1);
}

- (void)setSubStyleTwoTab:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.subStyleTwoTabButtonView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSArray *items = self.dicData[@"items"];
	
	CGFloat itemWidth = self.subStyleTwoTabButtonView.frame.size.width/2;
	CGFloat itemHeight = self.subStyleTwoTabButtonView.frame.size.height;
	
	[self.subStyleTwoTabButtonView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
	
	for (NSInteger i=0; i<[items count]; i++) {
		
		NSString *btnTitle = items[i][@"title"];
		BOOL isSelected = [@"Y" isEqualToString:items[i][@"selected"]];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(i * itemWidth, 0, (NSInteger)itemWidth, itemHeight)];
		[btn setTitle:btnTitle forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0x888888) forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
		[btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf4f4f4) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateNormal];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x00befa) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateHighlighted];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x00befa) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateSelected];
		[btn setTag:i];
		[btn setSelected:isSelected];
		
		[btn addTarget:self action:@selector(onTouchSubStyleTwoTab:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.subStyleTwoTabButtonView addSubview:btn];
	}
}

- (void)setGenderRadioArea:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.genderRadioAreaContentView.subviews) {
		[subview removeFromSuperview];
	}
	
	NSArray *items = self.dicData[@"genderRadioArea"];
	
	CGFloat itemWidth = self.genderRadioAreaContentView.frame.size.width/2;
	CGFloat itemHeight = self.genderRadioAreaContentView.frame.size.height;

	for (NSInteger i=0; i<[items count]; i++) {
		
		BOOL isSelected = [@"Y" isEqualToString:items[i][@"selected"]];
		NSString *genderText = items[i][@"text"];
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, itemHeight)];
		[self.genderRadioAreaContentView addSubview:view];
		
		UIImage *imgIcon = [UIImage imageNamed:(isSelected ? @"st_tab_radio_bt_on.png" : @"st_tab_radio_bt_off.png")];
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, itemHeight, itemHeight)];
		iconView.image = imgIcon;
		[view addSubview:iconView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame)+8, 0, 0, itemHeight)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = (isSelected ? UIColorFromRGB(0x43acfd) : UIColorFromRGB(0x4d4d4d));
		label.font = [UIFont systemFontOfSize:15];
		label.textAlignment = NSTextAlignmentLeft;
		label.text = genderText;
		[label sizeToFitWithVersionHoldHeight];
		[view addSubview:label];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
		[btn setTag:i];
		[btn setImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
										width:itemWidth
									   height:itemHeight]
			 forState:UIControlStateHighlighted];
		[btn addTarget:self action:@selector(onTouchGenderRadioButton:) forControlEvents:UIControlEventTouchUpInside];
		[view addSubview:btn];
		
		[btn setAccessibilityLabel:genderText Hint:@""];
	}
}

- (void)setCurationGroup:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.curationGroupContentView.subviews) {
		[subview removeFromSuperview];
	}

	NSString *groupNme = self.dicData[@"groupName"];
	NSArray *items = self.dicData[groupNme];
	
	BOOL isMale = NO;
	if (self.delegate && [self.delegate respondsToSelector:@selector(getStyleTabGenderIsMale)]) {
		isMale = [self.delegate getStyleTabGenderIsMale];
	}
	
	CPCurationItemView *itemView = [[CPCurationItemView alloc] initWithFrame:self.curationGroupContentView.bounds
																	   items:items
																	  isLeft:([@"curationLeftGroup" isEqualToString:groupNme])
																	  isMale:isMale];
	[self.curationGroupContentView addSubview:itemView];
}

- (void)setMartBillBannerList:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.martBillBannerView.subviews) {
		[subview removeFromSuperview];
	}
	
	NSString *groupNme = self.dicData[@"groupName"];
	NSArray *items = self.dicData[groupNme];

	CPMartBillBannerListView *billBannerView = [[CPMartBillBannerListView alloc] initWithFrame:self.martBillBannerView.bounds items:items];
	[self.martBillBannerView addSubview:billBannerView];
}

- (void)setMartLineBanner:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.martLineBannerView.subviews) {
		[subview removeFromSuperview];
	}
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.martLineBannerView.frame.size.width, self.martLineBannerView.frame.size.height-10)];
	bgView.backgroundColor = UIColorFromRGB(0xffc0ca);
	[self.martLineBannerView addSubview:bgView];
	
	UIImage *image = [UIImage imageNamed:@"img_mart_banner1.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.martLineBannerView.frame.size.width/2)-(image.size.width/2), 0,
																		   image.size.width, image.size.height)];
	imageView.image = image;
	[self.martLineBannerView addSubview:imageView];
}

- (void)setMartProduct:(NSIndexPath *)indexPath
{
	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger groupNameIndex = [self.dicData[@"groupNameIndex"] integerValue];
	[self setOddItemOffsetX:groupNameIndex indexPath:indexPath];

	for (UIView *subview in self.martProductView.subviews) {
		[subview removeFromSuperview];
	}
	
	CPMartProductView *productView = [[CPMartProductView alloc] initWithFrame:self.martProductView.bounds item:self.dicData[@"martProduct"]];
	[self.martProductView addSubview:productView];
}

- (void)setServiceAreaList:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaView subviews]) {
		[subView removeFromSuperview];
	}

	NSArray *items = self.dicData[@"serviceAreaList"];
	NSMutableArray *mutableItems = [NSMutableArray array];
	
	for (NSInteger i=0; i<[items count]; i++) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		NSString *linkUrl = items[i][@"dispObjLnkUrl"];
		NSString *imageUrl = items[i][@"lnkBnnrImgUrl"];
		
		[dict setObject:linkUrl forKey:@"linkUrl"];
		[dict setObject:imageUrl forKey:@"imageUrl"];
		[dict setObject:@"image" forKey:@"type"];
		
		[mutableItems addObject:dict];
	}

	CPMartServiceAreaView* areaView = [[CPMartServiceAreaView alloc] initWithFrame:self.specialBestAreaView.bounds items:mutableItems];
	[self.specialBestAreaView addSubview:areaView];
}

- (void)setBottomMartArea:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaView subviews]) {
		[subView removeFromSuperview];
	}
	
	NSArray *items = self.dicData[@"bottomMartArea"];
	NSMutableArray *mutableItems = [NSMutableArray array];
	
	for (NSInteger i=0; i<[items count]; i++) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		NSString *linkUrl = items[i][@"linkUrl"];
		NSString *text = items[i][@"text"];
		
		[dict setObject:linkUrl forKey:@"linkUrl"];
		[dict setObject:text forKey:@"title"];
		[dict setObject:@"text" forKey:@"type"];
		
		[mutableItems addObject:dict];
	}
	
	CPMartServiceAreaView* areaView = [[CPMartServiceAreaView alloc] initWithFrame:self.specialBestAreaView.bounds items:mutableItems];
	[self.specialBestAreaView addSubview:areaView];
}

- (void)setMartServiceAreaList:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaView subviews]) {
		[subView removeFromSuperview];
	}
	
	//데이터 가공
	NSArray *array = self.dicData[@"martServiceAreaList"];
	NSMutableArray *items = [NSMutableArray array];
	for (NSInteger i=0; i<[array count]; i++) {
		NSMutableDictionary *dict = [array[i] mutableCopy];
		
		if ([@"전체보기" isEqualToString:[dict[@"dispObjNm"] trim]])	[dict setValue:@"totalPage" forKey:@"type"];
		else														[dict setValue:@"webImage" forKey:@"type"];
		
		[dict setValue:@"1" forKey:@"weight"];
		[items addObject:dict];
	}
	
	//첫번째 데이터 삽입
	NSMutableDictionary *firstDict = [NSMutableDictionary dictionary];
	[firstDict setValue:@"localImage" forKey:@"type"];
	[firstDict setValue:@"2" forKey:@"weight"];
	[firstDict setValue:@"인기브랜드" forKey:@"dispObjNm"];
	[firstDict setValue:@"" forKey:@"dispObjLnkUrl"];
	[items insertObject:firstDict atIndex:0];
	
	CGSize size = [CPMartServiceAreaListView viewSizeWithData:items columnCount:(IS_IPAD ? 6 : 4)];
	self.specialBestAreaCellContentView.frame = CGRectMake(0, 0, size.width, size.height);
	self.specialBestAreaView.frame = CGRectMake(0, 0, size.width, size.height);

	CPMartServiceAreaListView *serviceView = [[CPMartServiceAreaListView alloc] initWithFrame:self.specialBestAreaView.bounds
																						items:items
																				  columnCount:(IS_IPAD ? 6 : 4)];
	[self.specialBestAreaView addSubview:serviceView];
											  
	//쉐도우 라인
	self.commonShadowLine.frame = CGRectMake(0,
											 self.specialBestAreaCellContentView.frame.size.height-SHADOW_HEIGHT,
											 self.specialBestAreaCellContentView.frame.size.width,
											 SHADOW_HEIGHT);
}

- (void)setHomeDirectServiceArea:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.homeDirectServiceAreaView subviews]) {
		[subView removeFromSuperview];
	}

	CGRect frame = [CPMainTabSizeManager getFrameWithGroupName:@"homeDirectServiceArea" item:self.dicData];
	self.homeDirectServiceAreaContentView.frame = frame;
	self.homeDirectServiceAreaView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-SHADOW_HEIGHT);
	self.homeDirectServiceAreaContentView.backgroundColor = [UIColor whiteColor];
	
	CPHomeDirectServiceAreaView* serviceView = [[CPHomeDirectServiceAreaView alloc] initWithFrame:self.homeDirectServiceAreaView.bounds
																							items:self.dicData[@"homeDirectServiceArea"]
																					  columnCount:(IS_IPAD ? 6 : 3)
																							 font:[UIFont boldSystemFontOfSize:15]
																						textColor:UIColorFromRGB(0x333333)];
	[self.homeDirectServiceAreaView addSubview:serviceView];
	
	//쉐도우 라인
	self.commonShadowLine.frame = CGRectMake(0,
											 self.homeDirectServiceAreaContentView.frame.size.height-SHADOW_HEIGHT,
											 self.homeDirectServiceAreaContentView.frame.size.width,
											 SHADOW_HEIGHT);
}

- (void)setTextLine:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.specialBestAreaView subviews]) {
		[subView removeFromSuperview];
	}

	self.specialBestAreaCellContentView.frame = [CPMainTabSizeManager getFrameWithGroupName:@"textLine" item:nil];
	self.specialBestAreaView.frame = self.specialBestAreaCellContentView.bounds;

	NSString *titleText = self.dicData[@"textLine"][@"titleText"];
	NSString *subTitleText = self.dicData[@"textLine"][@"subTitleText"];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = UIColorFromRGB(0x111111);
	titleLabel.font = [UIFont boldSystemFontOfSize:18];
	titleLabel.textAlignment = NSTextAlignmentLeft;
	titleLabel.text = titleText;
	[titleLabel sizeToFitWithVersion];
	titleLabel.frame = CGRectMake((self.specialBestAreaView.frame.size.width/2)-(titleLabel.frame.size.width/2),
								  (self.specialBestAreaView.frame.size.height/2)-(titleLabel.frame.size.height/2)+5.f,
								  titleLabel.frame.size.width, titleLabel.frame.size.height);
	[self.specialBestAreaView addSubview:titleLabel];
	
	if (subTitleText && [subTitleText length] > 0) {
		
		UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		subTitleLabel.backgroundColor = [UIColor clearColor];
		subTitleLabel.textColor = UIColorFromRGB(0x8c6239);
		subTitleLabel.font = [UIFont systemFontOfSize:13];
		subTitleLabel.textAlignment = NSTextAlignmentLeft;
		subTitleLabel.text = subTitleText;
		[subTitleLabel sizeToFitWithVersion];
		[self.specialBestAreaView addSubview:subTitleLabel];

		CGFloat titleLabelOffsetX = (self.specialBestAreaView.frame.size.width/2)-((titleLabel.frame.size.width+10+subTitleLabel.frame.size.width)/2);
		titleLabel.frame = CGRectMake(titleLabelOffsetX,
									  (self.specialBestAreaView.frame.size.height/2)-(titleLabel.frame.size.height/2)+5.f,
									  titleLabel.frame.size.width, titleLabel.frame.size.height);
		
		subTitleLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame)+10,
										 titleLabel.frame.origin.y+5.f,
										 subTitleLabel.frame.size.width, subTitleLabel.frame.size.height);
	}
}

- (void)setRandomBannerArea:(NSIndexPath *)indexPath
{
	NSArray *randomItems = self.dicData[@"randomBannerArea"];
	NSInteger randNum = rand() % randomItems.count;

	NSDictionary *lineBannerItems = randomItems[randNum][@"lineBanner"];
	
	//backgroundColor
	NSString *colorValue = lineBannerItems[@"extraText"];
	if (colorValue.length >= 7) {
		unsigned colorInt = 0;
		[[NSScanner scannerWithString:[colorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
		[self.lineBannerContentView setBackgroundColor:UIColorFromRGB(colorInt)];
	}
	else {
		[self.lineBannerContentView setBackgroundColor:[UIColor whiteColor]];
	}

	//backgroundImage
	NSString *imgUrl = lineBannerItems[@"lnkBnnrImgUrl"];
	
	if ([imgUrl length] > 0) {
		[self.lineBannerImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
	}
	else {
		[self.lineBannerImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
	}

	[self.lineBannerButton setActionType:CPButtonActionTypeOpenSubview];
	[self.lineBannerButton setActionItem:lineBannerItems[@"dispObjLnkUrl"]];
}

- (void)setHomeTalkAndStyleGroup:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.homeTalkAndStyleGroupContentView subviews]) {
		[subView removeFromSuperview];
	}

	self.homeTalkAndStyleGroupContentView.frame = [CPMainTabSizeManager getFrameWithGroupName:@"homeTalkAndStyleGroup" item:self.dicData];

	CGFloat offsetY = 0.f;
	
	NSDictionary *halfTextLine = self.dicData[@"halfTextLine"];
	if (halfTextLine)
	{
		CGSize headerSize = [CPHomeShadowTitleView viewSizeWithData:self.homeTalkAndStyleGroupContentView.frame.size.width];
		
		CPHomeShadowTitleView *titleView = [[CPHomeShadowTitleView alloc] initWithFrame:CGRectMake(0, offsetY, headerSize.width, headerSize.height)
																				   item:halfTextLine
																				   font:[UIFont boldSystemFontOfSize:18]
																			  textColor:UIColorFromRGB(0x111111)
																			shadowColor:UIColorFromRGB(0xffffff)];
		[self.homeTalkAndStyleGroupContentView addSubview:titleView];
		
		offsetY += headerSize.height;
	}
	
	NSArray *homeTalkStyleList = self.dicData[@"homeTalkStyleList"];
	if (homeTalkStyleList) {
		CGSize listSize = [CPHomeTalkStyleListView viewSizeWithData:self.homeTalkAndStyleGroupContentView.frame.size.width];
		
		CPHomeTalkStyleListView *listView = [[CPHomeTalkStyleListView alloc] initWithFrame:CGRectMake(0, offsetY, listSize.width, listSize.height)
																					 items:homeTalkStyleList];
		[self.homeTalkAndStyleGroupContentView addSubview:listView];
		
		offsetY += listSize.height;
	}
	
	NSArray *homeDirectTabArea = self.dicData[@"homeDirectTabArea"];
	if (homeDirectTabArea) {
		
		offsetY += 10;
		CGSize areaSize = [CPHomeDirectServiceAreaView viewSizeWithData:homeDirectTabArea
																  width:self.homeTalkAndStyleGroupContentView.frame.size.width
															columnCount:[homeDirectTabArea count]];
		
		CPHomeDirectServiceAreaView* serviceView = [[CPHomeDirectServiceAreaView alloc] initWithFrame:CGRectMake(0, offsetY, areaSize.width, areaSize.height)
																								items:homeDirectTabArea
																						  columnCount:[homeDirectTabArea count]
																								 font:[UIFont boldSystemFontOfSize:15]
																							textColor:UIColorFromRGB(0x333333)];
		[self.homeTalkAndStyleGroupContentView addSubview:serviceView];
        
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, serviceView.frame.size.height-1,
                                                                     serviceView.frame.size.width, 1)];
        underLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
        [serviceView addSubview:underLine];
	}
}

- (void)setHomePopularKeywordGroup:(NSIndexPath *)indexPath
{
	for (UIView *subView in [self.homePopularKeywordGroupContentView subviews]) {
		[subView removeFromSuperview];
	}
	
	self.homePopularKeywordGroupContentView.frame = [CPMainTabSizeManager getFrameWithGroupName:@"homePopularKeywordGroup" item:self.dicData];
	
	CGFloat offsetY = 0.f;
	
	NSArray *popularKeywordArea = self.dicData[@"popularKeywordArea"];
	NSArray *homeDirectBottomArea = self.dicData[@"homeDirectBottomArea"];

	if (popularKeywordArea) {

		NSString *popularKeywordOpenYn = self.dicData[@"openYn"];
		CGSize keywordSize = [CPHomePopularKeywordView viewSizeWithData:self.homePopularKeywordGroupContentView.frame.size.width
																  items:popularKeywordArea
																 isOpen:([popularKeywordOpenYn isEqualToString:@"Y"])];
		
		CPHomePopularKeywordView *keywordView = [[CPHomePopularKeywordView alloc] initWithFrame:CGRectMake(0, offsetY, keywordSize.width, keywordSize.height)
																						  items:popularKeywordArea
																						 isOpen:([@"Y" isEqualToString:popularKeywordOpenYn])];
		keywordView.delegate = self;
		[self.homePopularKeywordGroupContentView addSubview:keywordView];
		
		offsetY += keywordSize.height;
	}
	
	if (homeDirectBottomArea) {
		offsetY += 10;
		CGSize serviceSize = [CPHomeDirectServiceAreaView viewSizeWithData:homeDirectBottomArea width:self.homePopularKeywordGroupContentView.frame.size.width
															   columnCount:4];
		
		CPHomeDirectServiceAreaView *areaView = [[CPHomeDirectServiceAreaView alloc] initWithFrame:CGRectMake(0, offsetY, serviceSize.width, serviceSize.height)
																							 items:homeDirectBottomArea
																					   columnCount:4
																							  font:[UIFont systemFontOfSize:13]
																						 textColor:UIColorFromRGB(0x666666)];
		[self.homePopularKeywordGroupContentView addSubview:areaView];
        
		//라인
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, areaView.frame.size.height-1, areaView.frame.size.width, 1)];
        line.backgroundColor = UIColorFromRGB(0xd1d1d6);
		[areaView addSubview:line];
	}
}

- (void)setCornerBanner:(NSIndexPath *)indexPath
{
	//배너개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
	NSInteger groupNameIndex = [self.dicData[@"groupNameIndex"] integerValue];
	[self setOddItemOffsetX:groupNameIndex indexPath:indexPath];

	for (UIView *subview in self.cornerBannerView.subviews) {
		[subview removeFromSuperview];
	}
	
	CPCornerBannerView *bannerView = [[CPCornerBannerView alloc] initWithFrame:self.cornerBannerView.bounds item:self.dicData[@"cornerBanner"]];
	[self.cornerBannerView addSubview:bannerView];
}

- (void)setSimpleBestProduct:(NSIndexPath *)indexPath
{
	for (UIView *subview in self.simpleBestProductView.subviews) {
		[subview removeFromSuperview];
	}
	
	CPSimpleBestProductView *bannerView = [[CPSimpleBestProductView alloc] initWithFrame:self.simpleBestProductView.bounds
																					item:self.dicData[@"simpleBestProduct"]];
	[self.simpleBestProductView addSubview:bannerView];
}

- (void)setNoData
{
	NSDictionary *commonProductItems = self.dicData[@"noData"];
	
	NSString *title = @"검색결과가 없습니다.";
	for (NSDictionary *dic in commonProductItems) {
		if ([dic objectForKey:@"text"]) {
			title = [dic objectForKey:@"text"];
			break;
		}
	}
	
	[self.noDataLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.noDataImgView.frame)+15, CGRectGetWidth(self.noDataCellContentView.frame), 15)];
	[self.noDataLabel setText:title];
}

- (void)setOddItemOffsetX:(NSInteger)groupNameIndex indexPath:(NSIndexPath *)indexPath
{
	CGRect frame = self.frame;
	if (groupNameIndex%2 == indexPath.row%2) {
		frame.origin.x = 10;
		self.frame = frame;
	}
}

#pragma mark - Selectors

//동영상 재생
- (void)touchVideoPlayer:(id)sender
{
	NSDictionary *productDic = self.dicData;
	NSString *linkUrl = [productDic objectForKey:@"bannerProduct"][@"movieAppLink"];
	
	if (linkUrl && [[linkUrl trim] length] > 0) {
		[[CPSchemeManager sharedManager] openUrlScheme:linkUrl sender:nil changeAnimated:NO];
	}
}

//연관상품
- (void)touchRelativeProduct:(id)sender
{
	NSDictionary *productDic = self.dicData;
	NSString *linkUrl = [productDic objectForKey:@"bannerProduct"][@"relationPrd"][@"relationAppLink"];
	
	[[CPSchemeManager sharedManager] openUrlScheme:linkUrl sender:nil changeAnimated:NO];
}

//이벤트 / 기획전 이동
- (void)onTouchSubEventTwoTab:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSArray *items = self.dicData[@"items"];
	if (items && [items count] > 0) {
		NSString *linkUrl = [items[tag][@"key"] trim];
		
		if (linkUrl && [[linkUrl trim] length] > 0) {
			
			AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			CPHomeViewController *homeViewController = app.homeViewController;
			
			if ([homeViewController respondsToSelector:@selector(goToPageAction:)]) {
				[homeViewController goToPageAction:linkUrl];
			}
			
			if ([linkUrl isEqualToString:@"EVENT"]) [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0100"];
			else									[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAM0100"];
		}
	}
}

//트랜드 / 신상 이동
- (void)onTouchSubStyleTwoTab:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSArray *items = self.dicData[@"items"];
	if (items && [items count] > 0) {
		NSString *linkUrl = [items[tag][@"key"] trim];
		
		if (linkUrl && [[linkUrl trim] length] > 0) {
			
			AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			CPHomeViewController *homeViewController = app.homeViewController;
			
			if ([homeViewController respondsToSelector:@selector(goToPageAction:)]) {
				[homeViewController goToPageAction:linkUrl];
			}
		}
	}
}

//스타일 > 신상탭 남/여 선택
- (void)onTouchGenderRadioButton:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSArray *items = self.dicData[@"genderRadioArea"];
	
	NSString *linkUrl = items[tag][@"linkUrl"];
	linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{gender}}" withString:items[tag][@"gender"]];
	linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"app://gopage/CURATION/" withString:@""];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchButtonWithRequestUrl:)]) {
		[self.delegate didTouchButtonWithRequestUrl:linkUrl];
	}
	
	BOOL isMale = ([items[tag][@"gender"] isEqualToString:@"male"]);
	if (self.delegate && [self.delegate respondsToSelector:@selector(isStyleTabGenderMale:)]) {
		[self.delegate isStyleTabGenderMale:isMale];
	}
	
	[[AccessLog sharedInstance] sendAccessLogWithCode:(isMale ? @"MAH0600" : @"MAH0500")];
}

#pragma mark - CPTalkTagViewDelegate
- (void)touchTalkTagViewItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

#pragma mark - CPEventServiceViewDelegate
- (void)touchEventServiceViewItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

#pragma mark - CPEventWinnerViewDelegate
- (void)touchEventWinnerViewItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

#pragma mark - CPEventActiveViewDelegate
- (void)reloadAfterLogin
{
	if (self.delegate &&  [self.delegate respondsToSelector:@selector(reloadAfterLogin)]) {
		[self.delegate performSelector:@selector(reloadAfterLogin)];
	}
}

- (void)touchEventActiveViewItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

#pragma mark - CPTouchActionViewDelegate
- (void)touchActionView:(CPTouchActionView *)view sendCategoryBest:(NSString *)url;
{
	if ([self.delegate respondsToSelector:@selector(touchCategoryBestWithUrl:)]) {
		[self.delegate touchCategoryBestWithUrl:url];
	}
}

#pragma mark - CPHomePopularKeywordViewDelegate
- (void)homePopularKeywordView:(CPHomePopularKeywordView *)view openYn:(BOOL)isOpen
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(popularKeywordViewOpenYn:)]) {
		[self.delegate popularKeywordViewOpenYn:isOpen];
	}
}

#pragma mark - CPFooterButtonViewDelegate
- (void)touchFooterItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}

@end
