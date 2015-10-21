                                               //
//  CPCollectionViewCommonm
//  11st
//
//  Created by spearhead on 2015. 5. 18..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCollectionViewCommonCell.h"
#import "CPThumbnailView.h"
#import "CPBestView.h"
#import "CPShockingDealView.h"
#import "CPCommonInfo.h"
#import "CPString+Formatter.h"
#import "CPHomeViewController.h"
#import "CPBlurImageView.h"
#import "CPProductListViewController.h"
#import "CPTouchActionView.h"

#import "AccessLog.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+WebCache.h"

#define DETAIL_CTGR_TABLEVIEW_TAG   500
#define CELL_LINESPACING            10
#define RELATED_SEARCH_BUTTON_TAG   700

@implementation CPCollectionViewCommonCell

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
    else if ([cellTypeStr isEqualToString:@"shockingDealAppLink"]) {
        cellType = CPCellTypeShockingDealAppLink;
    }
    else if ([cellTypeStr isEqualToString:@"ctgrHotClick"]) {
        cellType = CPCellTypeCtgrHotClick;
    }
    else if ([cellTypeStr isEqualToString:@"ctgrBest"]) {
        cellType = CPCellTypeCtgrBest;
    }
    else if ([cellTypeStr isEqualToString:@"ctgrDealBest"]) {
        cellType = CPCellTypeCtgrDealBest;
    }
    else if ([cellTypeStr isEqualToString:@"searchProduct"]) {
        cellType = CPCellTypeSearchProduct;
    }
    else if ([cellTypeStr isEqualToString:@"searchProductGrid"]) {
        cellType = CPCellTypeSearchProductGrid;
    }
    else if ([cellTypeStr isEqualToString:@"searchProductBanner"]) {
        cellType = CPCellTypeSearchProductBanner;
    }
    else if ([cellTypeStr isEqualToString:@"shockingDealProduct"]) {
        cellType = CPCellTypeShockingDealProduct;
    }
    else if ([cellTypeStr isEqualToString:@"searchCaption"]) {
        cellType = CPCellTypeSearchCaption;
    }
    else if ([cellTypeStr isEqualToString:@"relatedSearchText"]) {
        cellType = CPCellTypeRelatedSearchText;
    }
    else if ([cellTypeStr isEqualToString:@"recommendSearchText"]) {
        cellType = CPCellTypeRecommendSearchText;
    }
    else if ([cellTypeStr isEqualToString:@"searchFilter"]) {
        cellType = CPCellTypeSearchFilter;
    }
    else if ([cellTypeStr isEqualToString:@"searchTopTab"]) {
        cellType = CPCellTypeSearchTopTab;
    }
    else if ([cellTypeStr isEqualToString:@"sorting"]) {
        cellType = CPCellTypeSorting;
    }
    else if ([cellTypeStr isEqualToString:@"categoryNavi"]) {
        cellType = CPCellTypeCategoryNavi;
    }
    else if ([cellTypeStr isEqualToString:@"searchMore"]) {
        cellType = CPCellTypeSearchMore;
    }
    else if ([cellTypeStr isEqualToString:@"modelSearchProduct"]) {
        cellType = CPCellTypeModelSearchProduct;
    }
    else if ([cellTypeStr isEqualToString:@"noSearchData"]) {
        cellType = CPCellTypeNoSearchData;
    }
    else if ([cellTypeStr isEqualToString:@"searchHotProduct"]) {
        cellType = CPCellTypeSearchHotProduct;
    }
    else if ([cellTypeStr isEqualToString:@"tworldDirect"]) {
        cellType = CPCellTypeTworldDirect;
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
        
        //공통 shadowView : Radius 사용시 속도문제가 있음
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 6, frame.size.width, frame.size.height-CELL_LINESPACING)];
        [self.shadowView setBackgroundColor:UIColorFromRGB(0xd1d1d6)];
        [self.shadowView setAlpha:0.5];
        [self.contentView addSubview:self.shadowView];
        
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
            case CPCellTypeShockingDealAppLink:
                [self initShockingDealAppLink];
                break;
            case CPCellTypeCtgrHotClick:
                [self initCtgrHotClick];
                break;
            case CPCellTypeCtgrBest:
                [self initCtgrBest];
                break;
            case CPCellTypeCtgrDealBest:
                [self initCtgrDealBest];
                break;
            case CPCellTypeSearchProduct:
                [self.shadowView setFrame:CGRectMake(0, 6, frame.size.width, 140)];
                [self initSearchProduct];
                break;
            case CPCellTypeSearchProductGrid:
                [self initSearchProductGrid];
                break;
            case CPCellTypeSearchProductBanner:
            {
                NSInteger productHeight = 416;
                if (IS_IPAD) {
                    productHeight = 485;
                }
                else if (IS_IPHONE_6) {
                    productHeight = 470;
                }
                else if (IS_IPHONE_6PLUS) {
                    productHeight = 510;
                }
                
                [self.shadowView setFrame:CGRectMake(0, 6, frame.size.width, productHeight)];
                [self initSearchProductBanner];
                break;
            }
            case CPCellTypeShockingDealProduct:
                [self.shadowView setFrame:CGRectMake(0, 5, frame.size.width, 165)];
                [self initShockingDealProduct];
                break;
            case CPCellTypeSearchCaption:
                [self.shadowView setFrame:CGRectZero];
                [self initSearchCaption];
                break;
            case CPCellTypeRelatedSearchText:
                [self initRelatedSearchText];
                break;
            case CPCellTypeRecommendSearchText:
                [self initRecommendSearchText];
                break;
            case CPCellTypeSearchFilter:
                [self initSearchFilter];
                break;
            case CPCellTypeSearchTopTab:
                [self initSearchTopTab];
                break;
            case CPCellTypeSorting:
                [self.shadowView setFrame:CGRectZero];
                [self initSorting];
                break;
            case CPCellTypeCategoryNavi:
                [self initCategoryNavi];
                break;
            case CPCellTypeSearchMore:
                [self initSearchMore];
                break;
            case CPCellTypeModelSearchProduct:
                [self initModelSearchProduct];
                break;
            case CPCellTypeNoSearchData:
                [self.shadowView setFrame:CGRectZero];
                [self initNoSearchData];
                break;
            case CPCellTypeSearchHotProduct:
                [self initSearchHotProduct];
                break;
            case CPCellTypeTworldDirect:
                [self initTworldDirect];
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
    self.commonProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth]+75)];
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
    
    self.commonProductBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commonProductBlankButton setFrame:self.commonProductCellContentView.frame];
    [self.commonProductBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.commonProductBlankButton setAlpha:0.3];
    [self.commonProductBlankButton addTarget:self action:@selector(touchCommonProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.commonProductBlankButton];
}

- (void)initBestProductCategory
{
    self.bestProductCategoryCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth]+75)];
    [self.bestProductCategoryCellContentView setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
    [self.contentView addSubview:self.bestProductCategoryCellContentView];
}

- (void)initBannerProduct
{
    NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+8)*2 : kScreenBoundsWidth - 20;
    NSInteger productHeight = productWidth/1.78+121;
    
    self.bannerProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, productWidth, productHeight)];
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

    self.bannerProductBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bannerProductBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.bannerProductBlankButton setAlpha:0.3];
    [self.contentView addSubview:self.bannerProductBlankButton];
    
    self.bannerProductVideoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bannerProductVideoPlayButton setHidden:YES];
    [self.contentView addSubview:self.bannerProductVideoPlayButton];
}

- (void)initLineBanner
{
    self.lineBannerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 60)];
    [self.contentView addSubview:self.lineBannerContentView ];
    
    //backgroundImage
    self.lineBannerImageView = [[CPBlurImageView alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-300)/2-10, 0, 300, 60)];
    [self.lineBannerImageView setUserInteractionEnabled:YES];
    [self.lineBannerContentView addSubview:self.lineBannerImageView];
    
    self.lineBannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lineBannerButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.lineBannerContentView.frame), CGRectGetHeight(self.lineBannerContentView.frame))];
    [self.lineBannerButton setBackgroundColor:[UIColor clearColor]];
    [self.lineBannerButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.lineBannerButton setAlpha:0.3];
    [self.lineBannerContentView addSubview:self.lineBannerButton];
}

- (void)initShockingDealAppLink
{
    self.shockingDealAppLinkCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 34)];
    [self.contentView addSubview:self.shockingDealAppLinkCellContentView ];
    
    self.shockingDealAppLinkMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shockingDealAppLinkMoreButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 34)];
    [self.shockingDealAppLinkMoreButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [self.shockingDealAppLinkMoreButton setBackgroundColor:[UIColor whiteColor]];
    [self.shockingDealAppLinkMoreButton addTarget:self action:@selector(onTouchMoreView) forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)initCtgrHotClick
{
    self.ctgrHotClickCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 198+[Modules getCategoryItemHeight])];
    [self.ctgrHotClickCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.ctgrHotClickCellContentView];
}

- (void)initCtgrBest
{
    self.ctgrBestCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 198+[Modules getCategoryItemHeight])];
    [self.ctgrBestCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.ctgrBestCellContentView ];
}

- (void)initCtgrDealBest
{
    self.ctgrDealBestCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 198+[Modules getCategoryItemHeight])];
    [self.ctgrDealBestCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.ctgrDealBestCellContentView ];
}

- (void)initSearchProduct
{
    self.searchProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 140)];
    [self.searchProductCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchProductCellContentView ];
    
    //이미지
    self.searchProductThumbnailView = [[CPThumbnailView alloc] init];
    [self.searchProductCellContentView addSubview:self.searchProductThumbnailView];
    
    //쇼킹딜 이미지
    self.searchProductShockingDealImageView = [[UIImageView alloc] init];
    [self.searchProductThumbnailView addSubview:self.searchProductShockingDealImageView];
    
    //성인이미지뷰
    self.searchProductAdultView = [[UIView alloc] init];
    [self.searchProductAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchProductThumbnailView addSubview:self.searchProductAdultView];
    [self.searchProductAdultView setHidden:YES];
    
    self.searchProductAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    [self.searchProductAdultView addSubview:self.searchProductAdultImageView];
    
    //iconView
    self.searchProductIconView = [[UIView alloc] init];
    [self.searchProductCellContentView addSubview:self.searchProductIconView];
    
    //상품명
    self.searchProductLabel = [[UILabel alloc] init];
    [self.searchProductLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductLabel setFont:[UIFont systemFontOfSize:16]];
    [self.searchProductLabel setTextColor:UIColorFromRGB(0x2d2d2d)];
    [self.searchProductLabel setTextAlignment:NSTextAlignmentLeft];
    [self.searchProductLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductLabel setNumberOfLines:2];
    [self.searchProductCellContentView addSubview:self.searchProductLabel];
    
    //할인가
    self.searchProductDiscountLabel = [[TTTAttributedLabel alloc] init];
    [self.searchProductDiscountLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductDiscountLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.searchProductDiscountLabel setTextColor:UIColorFromRGB(0x292929)];
    [self.searchProductDiscountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.searchProductDiscountLabel setAdjustsFontSizeToFitWidth:YES];
    [self.searchProductCellContentView addSubview:self.searchProductDiscountLabel];
    
    //원가
    self.searchProductPriceLabel = [[UILabel alloc] init];
    [self.searchProductPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductPriceLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchProductPriceLabel setTextColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.searchProductPriceLabel setAdjustsFontSizeToFitWidth:YES];
    [self.searchProductCellContentView addSubview:self.searchProductPriceLabel];
    
    //라인
    self.searchProductPriceLineView = [[UIView alloc] init];
    [self.searchProductPriceLineView setBackgroundColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductPriceLabel addSubview:self.searchProductPriceLineView];
    
    //SatisfyView
    self.searchProductSatisfyView = [[UIView alloc] init];
    [self.searchProductCellContentView addSubview:self.searchProductSatisfyView];
    
    //reviewCount
    self.searchProductReviewCountLabel = [[UILabel alloc] init];
    [self.searchProductReviewCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductReviewCountLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchProductReviewCountLabel setTextColor:UIColorFromRGB(0x5f5f5f)];
    [self.searchProductReviewCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductCellContentView addSubview:self.searchProductReviewCountLabel];
    
    //productLink Button
    self.searchProductActionView = [[CPTouchActionView alloc] init];
    self.searchProductActionView.frame = self.searchProductCellContentView.frame;
    [self.contentView addSubview:self.searchProductActionView];
    
    //ajax call Button
    self.searchProductUpdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchProductUpdownButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
    [self.contentView addSubview:self.searchProductUpdownButton];
    
    //sellerView
    self.searchProductSellerView = [[UIView alloc] init];
    [self.searchProductCellContentView addSubview:self.searchProductSellerView];
    
    self.searchProductShadowView = [[UIView alloc] init];
    [self.searchProductCellContentView addSubview:self.searchProductShadowView];
}

- (void)initSearchProductGrid
{
    CGFloat height = [Modules getBestLayoutItemWidth]*1.85;
    if (IS_IPAD) {
        height = [Modules getBestLayoutItemWidth]*1.70;
    }
    else if (IS_IPHONE_6) {
        height = [Modules getBestLayoutItemWidth]*1.70;
    }
    else if (IS_IPHONE_6PLUS) {
        height = [Modules getBestLayoutItemWidth]*1.65;
    }
    
    self.searchProductGridCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, [Modules getBestLayoutItemWidth], height)];
    [self.searchProductGridCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchProductGridCellContentView ];
    
    //이미지
    self.searchProductGridThumbnailView = [[CPThumbnailView alloc] init];
    [self.searchProductGridCellContentView addSubview:self.searchProductGridThumbnailView];
    
    //쇼킹딜 이미지
    self.searchProductGridShockingDealImageView = [[UIImageView alloc] init];
    [self.searchProductGridThumbnailView addSubview:self.searchProductGridShockingDealImageView];
    
    //성인이미지뷰
    self.searchProductGridAdultView = [[UIView alloc] init];
    [self.searchProductGridAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchProductGridThumbnailView addSubview:self.searchProductGridAdultView];
    [self.searchProductGridAdultView setHidden:YES];
    
    self.searchProductGridAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_02.png"]];
    [self.searchProductGridAdultView addSubview:self.searchProductGridAdultImageView];
    
    //iconView
    self.searchProductGridIconView = [[UIView alloc] init];
    [self.searchProductGridCellContentView addSubview:self.searchProductGridIconView];
    
    //상품명
    self.searchProductGridLabel = [[UILabel alloc] init];
    [self.searchProductGridLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductGridLabel setFont:[UIFont systemFontOfSize:16]];
    [self.searchProductGridLabel setTextColor:UIColorFromRGB(0x2d2d2d)];
    [self.searchProductGridLabel setTextAlignment:NSTextAlignmentLeft];
    [self.searchProductGridLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductGridLabel setNumberOfLines:2];
    [self.searchProductGridCellContentView addSubview:self.searchProductGridLabel];
    
    //할인가
    self.searchProductGridDiscountLabel = [[TTTAttributedLabel alloc] init];
    [self.searchProductGridDiscountLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductGridDiscountLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.searchProductGridDiscountLabel setTextColor:UIColorFromRGB(0x292929)];
    [self.searchProductGridCellContentView addSubview:self.searchProductGridDiscountLabel];
    
    //원가
    self.searchProductGridPriceLabel = [[UILabel alloc] init];
    [self.searchProductGridPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductGridPriceLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchProductGridPriceLabel setTextColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductGridPriceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductGridCellContentView addSubview:self.searchProductGridPriceLabel];
    
    //라인
    self.searchProductGridPriceLineView = [[UIView alloc] init];
    [self.searchProductGridPriceLineView setBackgroundColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductGridPriceLabel addSubview:self.searchProductGridPriceLineView];
    
    //productLink Button
    self.searchProductGridActionView = [[CPTouchActionView alloc] init];
    self.searchProductGridActionView.frame = self.searchProductGridCellContentView.frame;
    [self.contentView addSubview:self.searchProductGridActionView];
}

- (void)initSearchProductBanner
{
    NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+8)*2 : kScreenBoundsWidth - 20;;//IS_IPAD ? ([Modules getBestLayoutItemWidth]+20)*2 : kScreenBoundsWidth - 20;
//    NSInteger productHeight = (IS_IPAD || IS_IPHONE_6 || IS_IPHONE_6PLUS) ? 520 : 416;
    NSInteger productHeight = 416;
    if (IS_IPAD) {
        productHeight = 485;
    }
    else if (IS_IPHONE_6) {
        productHeight = 470;
    }
    else if (IS_IPHONE_6PLUS) {
        productHeight = 510;
    }
    
    self.searchProductBannerCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, productWidth, productHeight)];
    [self.searchProductBannerCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchProductBannerCellContentView];
    
    //이미지
    self.searchProductBannerThumbnailView = [[CPThumbnailView alloc] init];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerThumbnailView];
    
    //쇼킹딜 이미지
    self.searchProductBannerShockingDealImageView = [[UIImageView alloc] init];
    [self.searchProductBannerThumbnailView addSubview:self.searchProductBannerShockingDealImageView];
    
    //성인이미지뷰
    self.searchProductBannerAdultView = [[UIView alloc] init];
    [self.searchProductBannerAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchProductBannerThumbnailView addSubview:self.searchProductBannerAdultView];
    
    self.searchProductBannerAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_03.png"]];
    [self.searchProductBannerAdultView addSubview:self.searchProductBannerAdultImageView];
    
    //iconView
    self.searchProductBannerIconView = [[UIView alloc] init];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerIconView];
    
    //상품명
    self.searchProductBannerLabel = [[UILabel alloc] init];
    [self.searchProductBannerLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductBannerLabel setFont:[UIFont systemFontOfSize:16]];
    [self.searchProductBannerLabel setTextColor:UIColorFromRGB(0x2d2d2d)];
    [self.searchProductBannerLabel setTextAlignment:NSTextAlignmentLeft];
    [self.searchProductBannerLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerLabel];
    
    //할인가
    self.searchProductBannerDiscountLabel = [[TTTAttributedLabel alloc] init];
    [self.searchProductBannerDiscountLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductBannerDiscountLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.searchProductBannerDiscountLabel setTextColor:UIColorFromRGB(0x292929)];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerDiscountLabel];
    
    //원가
    self.searchProductBannerPriceLabel = [[UILabel alloc] init];
    [self.searchProductBannerPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductBannerPriceLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchProductBannerPriceLabel setTextColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductBannerPriceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerPriceLabel];
    
    //라인
    self.searchProductBannerPriceLineView = [[UIView alloc] init];
    [self.searchProductBannerPriceLineView setBackgroundColor:UIColorFromRGB(0x8c8b8b)];
    [self.searchProductBannerPriceLabel addSubview:self.searchProductBannerPriceLineView];
    
    //SatisfyView
    self.searchProductBannerSatisfyView = [[UIView alloc] init];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerSatisfyView];
    
    //reviewCount
    self.searchProductBannerReviewCountLabel = [[UILabel alloc] init];
    [self.searchProductBannerReviewCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchProductBannerReviewCountLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchProductBannerReviewCountLabel setTextColor:UIColorFromRGB(0x5f5f5f)];
    [self.searchProductBannerReviewCountLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerReviewCountLabel];
    
    //ActionView
    self.searchProductBannerActionView = [[CPTouchActionView alloc] init];
    self.searchProductBannerActionView.frame = self.searchProductBannerCellContentView.frame;
    [self.contentView addSubview:self.searchProductBannerActionView];
    
    if (!IS_IPAD) {
        //ajax call Button
        self.searchProductBannerUpdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.searchProductBannerUpdownButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
        [self.contentView addSubview:self.searchProductBannerUpdownButton];
        
        //sellerView
        self.searchProductBannerSellerView = [[UIView alloc] init];
        [self.searchProductBannerCellContentView addSubview:self.searchProductBannerSellerView];
    }
    
    self.searchProductBannerShadowView = [[UIView alloc] init];
    [self.searchProductBannerCellContentView addSubview:self.searchProductBannerShadowView];
}

- (void)initShockingDealProduct
{
    self.shockingDealProductPageIndex = 0;
    
    self.shockingDealProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth, 165)];
    [self.shockingDealProductCellContentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.shockingDealProductCellContentView];
    
    //iCarousel
    self.shockingDealProductView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 140)];
    [self.shockingDealProductView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.shockingDealProductView setType:iCarouselTypeLinear];
    [self.shockingDealProductView setDataSource:self];
    [self.shockingDealProductView setDelegate:self];
    [self.shockingDealProductView setPagingEnabled:YES];
    [self.shockingDealProductView setClipsToBounds:YES];
    [self.shockingDealProductCellContentView addSubview:self.shockingDealProductView];
    
    //pageControl
    self.shockingDealProductPageControlView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shockingDealProductView.frame), kScreenBoundsWidth-20, 24)];
    [self.shockingDealProductPageControlView setBackgroundColor:[UIColor whiteColor]];
    [self.shockingDealProductCellContentView addSubview:self.shockingDealProductPageControlView];
    
    //right Button
    self.shockingDealProductRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shockingDealProductRightButton setFrame:CGRectMake(kScreenBoundsWidth-43, (CGRectGetHeight(self.shockingDealProductCellContentView.frame)-37)/2, 33, 47)];
    [self.shockingDealProductRightButton setImage:[UIImage imageNamed:@"bt_s_swipe_right.png"] forState:UIControlStateNormal];
    [self.shockingDealProductRightButton setHidden:YES];
    [self.shockingDealProductRightButton addTarget:self action:@selector(touchShockingDealProductRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.shockingDealProductRightButton];
    
    //left Button
    self.shockingDealProductLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shockingDealProductLeftButton setFrame:CGRectMake(-10, (CGRectGetHeight(self.shockingDealProductCellContentView.frame)-37)/2, 33, 47)];
    [self.shockingDealProductLeftButton setImage:[UIImage imageNamed:@"bt_s_swipe_left.png"] forState:UIControlStateNormal];
    [self.shockingDealProductLeftButton setHidden:YES];
    [self.shockingDealProductLeftButton addTarget:self action:@selector(touchShockingDealProductLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.shockingDealProductLeftButton];
}

- (void)initSearchCaption
{
    self.searchCaptionCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 29)];
    [self.searchCaptionCellContentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.searchCaptionCellContentView];
    
    //title
    self.searchCaptionTitleLabel = [[UILabel alloc] init];
    [self.searchCaptionTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchCaptionTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.searchCaptionTitleLabel setTextColor:UIColorFromRGB(0x333333)];
    [self.searchCaptionTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.searchCaptionTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchCaptionCellContentView addSubview:self.searchCaptionTitleLabel];
    
    NSString *adTitle = @"AD";
    CGSize adTitleSize = [adTitle sizeWithFont:[UIFont systemFontOfSize:11]];
    
    //AD Button
    self.searchCaptionADButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchCaptionADButton setFrame:CGRectMake(CGRectGetMaxX(self.searchCaptionCellContentView.frame)-adTitleSize.width, CGRectGetMaxY(self.searchCaptionCellContentView.frame)-16, adTitleSize.width, 12)];
    [self.searchCaptionADButton setTitle:@"AD" forState:UIControlStateNormal];
    [self.searchCaptionADButton setTitleColor:UIColorFromRGB(0x757b9c) forState:UIControlStateNormal];
    [self.searchCaptionADButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [self.searchCaptionCellContentView addSubview:self.searchCaptionADButton];
    
    
    //더보기
    self.searchCaptionMoreLabel = [[UILabel alloc] init];
    [self.searchCaptionMoreLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchCaptionMoreLabel setFont:[UIFont systemFontOfSize:13]];
    [self.searchCaptionMoreLabel setTextColor:UIColorFromRGB(0x4d4d4d)];
    [self.searchCaptionMoreLabel setTextAlignment:NSTextAlignmentRight];
    [self.searchCaptionMoreLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.searchCaptionCellContentView addSubview:self.searchCaptionMoreLabel];
    
    //Page Move
    self.searchCaptionIconImageView = [[UIImageView alloc] init];
    [self.searchCaptionIconImageView setImage:[UIImage imageNamed:@"bt_detail_arrow_view3.png"]];
    [self.searchCaptionCellContentView addSubview:self.searchCaptionIconImageView];
    
    self.searchCaptionPageMoveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchCaptionPageMoveButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 24)];
    [self.searchCaptionPageMoveButton addTarget:self action:@selector(touchSearchCaptionPageMoveButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchCaptionCellContentView addSubview:self.searchCaptionPageMoveButton];
    
    [self.searchCaptionMoreLabel setHidden:YES];
    [self.searchCaptionADButton setHidden:YES];
    [self.searchCaptionIconImageView setHidden:YES];
    [self.searchCaptionPageMoveButton setHidden:YES];
}

- (void)initRelatedSearchText
{
    self.relatedSearchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 36)];
    [self.relatedSearchBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.relatedSearchBackgroundView];
    
    self.relatedSearchTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 36)];
    [self.relatedSearchTextView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
    [self.contentView addSubview:self.relatedSearchTextView ];
    
    //icon
    self.relatedIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8.5f, 29, 19)];
    [self.relatedIconImageView setImage:[UIImage imageNamed:@"tag_s_01.png"]];
    [self.relatedSearchTextView addSubview:self.relatedIconImageView];

    //keyword
//    self.relatedKeywordView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.relatedIconImageView.frame)+8,
//                                                                      0,
//                                                                      CGRectGetWidth(self.relatedSearchTextView.frame)-(CGRectGetMaxX(self.relatedIconImageView.frame)+8+45),
//                                                                       CGRectGetHeight(self.relatedSearchTextView.frame))];
    self.relatedKeywordView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.relatedSearchTextView addSubview:self.relatedKeywordView];
    
    //arrow button
    self.relatedOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(self.relatedSearchTextView.frame)-35, 0, 35, 36)];
    [self.relatedOpenButton setBackgroundColor:[UIColor clearColor]];
    [self.relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_down_01.png"] forState:UIControlStateNormal];
    [self.relatedOpenButton addTarget:self action:@selector(touchRelatedOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.relatedSearchTextView addSubview:self.relatedOpenButton];
    
    //line
//    self.relatedSearchLineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(self.relatedSearchTextView.frame)-1, CGRectGetWidth(self.relatedSearchTextView.frame), 1)];
//    [self.relatedSearchLineView setBackgroundColor:UIColorFromRGB(0xe7e8ea)];
//    [self.relatedSearchTextView addSubview:self.relatedSearchLineView];
}

- (void)initRecommendSearchText
{
    self.recommendSearchTextBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 36)];
    [self.recommendSearchTextBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.recommendSearchTextBackgroundView];
    
    self.recommendSearchTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 36)];
    [self.recommendSearchTextView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
    [self.contentView addSubview:self.recommendSearchTextView];
    
    //icon
    self.recommendIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8.5f, 29, 19)];
    [self.recommendIconImageView setImage:[UIImage imageNamed:@"tag_s_02.png"]];
    [self.recommendSearchTextView addSubview:self.recommendIconImageView];
    
    //line
    self.recommendSearchLineView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, CGRectGetWidth(self.recommendSearchTextView.frame), 1)];
    [self.recommendSearchLineView setBackgroundColor:UIColorFromRGB(0xe7e8ea)];
    [self.recommendSearchTextView addSubview:self.recommendSearchLineView];
}

- (void)initSearchFilter
{
    self.searchFilterBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 39)];
    [self.searchFilterBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchFilterBackgroundView];
    
    self.searchFilterView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 39)];
    [self.searchFilterView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
    [self.contentView addSubview:self.searchFilterView ];
    
    //line
    self.searchFilterLineView = [[UIView alloc] initWithFrame:CGRectMake(-10, CGRectGetHeight(self.searchFilterView.frame)-1, CGRectGetWidth(self.searchFilterView.frame), 1)];
    [self.searchFilterLineView setBackgroundColor:UIColorFromRGB(0x9c9eab)];
    [self.searchFilterView addSubview:self.searchFilterLineView];
}

- (void)initSearchTopTab
{
    self.searchTopTabBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 41)];
    [self.searchTopTabBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchTopTabBackgroundView];
    
    self.searchTopTabView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 41)];
    [self.searchTopTabView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
    
    [self.contentView addSubview:self.searchTopTabView ];
}

- (void)initSorting
{
    self.sortingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 45)];
    [self.sortingBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.sortingBackgroundView];
    
    self.sortingView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 45)];
    [self.sortingView setBackgroundColor:UIColorFromRGB(0xf9f9f9)];
    [self.contentView addSubview:self.sortingView ];
    
    //상품수
    self.sortingProductTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 23, CGRectGetHeight(self.sortingView.frame)-6)];
    [self.sortingProductTitleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sortingProductTitleLabel setTextColor:UIColorFromRGB(0x707173)];
    [self.sortingProductTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.sortingView addSubview:self.sortingProductTitleLabel];
    
    self.sortingProductCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.sortingProductCountLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.sortingProductCountLabel setTextColor:UIColorFromRGB(0x392b7b)];
    [self.sortingProductCountLabel setBackgroundColor:[UIColor clearColor]];
    [self.sortingProductCountLabel setTextAlignment:NSTextAlignmentLeft];
    [self.sortingView addSubview:self.sortingProductCountLabel];
    
    self.sortingProductUnitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.sortingProductUnitLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sortingProductUnitLabel setTextColor:UIColorFromRGB(0x392b7b)];
    [self.sortingProductUnitLabel setText:@"개"];
    [self.sortingProductUnitLabel setBackgroundColor:[UIColor clearColor]];
    [self.sortingProductUnitLabel setTextAlignment:NSTextAlignmentLeft];
    [self.sortingView addSubview:self.sortingProductUnitLabel];
    
    //view type button
    self.sortingViewTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.sortingViewTypeButton setFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-41, 6, 31, 31)];
    [self.sortingViewTypeButton setFrame:CGRectZero];
    [self.sortingViewTypeButton setBackgroundImage:[UIImage imageNamed:@"layer_s_filterbg_nor.png"] forState:UIControlStateNormal];
    [self.sortingViewTypeButton addTarget:self action:@selector(touchViewTypeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.sortingView addSubview:self.sortingViewTypeButton];
    
    //sort type button
    UIImage *backgroundImage = [[UIImage imageNamed:@"layer_s_filterbg_nor.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *backgroundPressImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    self.sortingSortTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.sortingSortTypeButton setFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-(41+6+112), 6, 112, 31)];
    [self.sortingSortTypeButton setFrame:CGRectZero];
    [self.sortingSortTypeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.sortingSortTypeButton setTitleColor:UIColorFromRGB(0x242529) forState:UIControlStateNormal];
    [self.sortingSortTypeButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self.sortingSortTypeButton setBackgroundImage:backgroundPressImage forState:UIControlStateSelected];
    [self.sortingSortTypeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [self.sortingSortTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.sortingSortTypeButton addTarget:self action:@selector(touchSortTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sortingView addSubview:self.sortingSortTypeButton];
    
//    self.sortingArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.sortingSortTypeButton.frame)-19, 12.5f, 11, 6)];
    self.sortingArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.sortingArrowImageView setImage:[UIImage imageNamed:@"bt_s_arrow_down_02.png"]];
    [self.sortingSortTypeButton addSubview:self.sortingArrowImageView];
    
    self.sortingShadowView = [[UIView alloc] initWithFrame:CGRectMake(-10, 45, kScreenBoundsWidth, 1)];
    [self.sortingShadowView setBackgroundColor:UIColorFromRGB(0xd1d1d6)];
    [self.sortingShadowView setAlpha:0.5];
    [self.contentView addSubview:self.sortingShadowView];
    
    
//    self.viewTypeContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-141, 0, 31, 100)];
//    [self.viewTypeContainerView setBackgroundColor:[UIColor greenColor]];
//    [self.sortingView addSubview:self.viewTypeContainerView];
//    [self.sortingView insertSubview:viewTypeContainerView aboveSubview:self.contentView];
//    [self.contentView bringSubviewToFront:self.viewTypeContainerView];
}

- (void)initCategoryNavi
{
    self.categoryNaviBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 31)];
    [self.categoryNaviBackgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentView addSubview:self.categoryNaviBackgroundView];
    
    self.categoryNaviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 31)];
    [self.categoryNaviView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentView addSubview:self.categoryNaviView ];
}

- (void)initSearchMore
{
    self.searchMoreCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 45)];
    [self.searchMoreCellContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentView addSubview:self.searchMoreCellContentView];
    
    // title
    self.searchMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchMoreButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchMoreCellContentView.frame), CGRectGetHeight(self.searchMoreCellContentView.frame))];
    [self.searchMoreButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [self.searchMoreButton setTitleColor:UIColorFromRGB(0x301a93) forState:UIControlStateNormal];
    [self.searchMoreButton addTarget:self action:@selector(touchSearchMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchMoreCellContentView addSubview:self.searchMoreButton];
}

- (void)initModelSearchProduct
{
    self.modelSearchProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 140)];
    [self.modelSearchProductCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.modelSearchProductCellContentView ];
    
    //이미지
    self.modelSearchProductThumbnailView = [[CPThumbnailView alloc] init];
    [self.modelSearchProductCellContentView addSubview:self.modelSearchProductThumbnailView];
    
    //쇼킹딜 이미지
    self.modelSearchProductShockingDealImageView = [[UIImageView alloc] init];
    [self.modelSearchProductThumbnailView addSubview:self.modelSearchProductShockingDealImageView];
    
    //성인이미지뷰
    self.modelSearchProductAdultView = [[UIView alloc] init];
    [self.modelSearchProductAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.modelSearchProductThumbnailView addSubview:self.modelSearchProductAdultView];
    
    self.modelSearchProductAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    [self.modelSearchProductAdultView addSubview:self.modelSearchProductAdultImageView];
    
    //상품명
    self.modelSearchProductLabel = [[UILabel alloc] init];
    [self.modelSearchProductLabel setBackgroundColor:[UIColor clearColor]];
    [self.modelSearchProductLabel setFont:[UIFont systemFontOfSize:16]];
    [self.modelSearchProductLabel setTextColor:UIColorFromRGB(0x2d2d2d)];
    [self.modelSearchProductLabel setTextAlignment:NSTextAlignmentLeft];
    [self.modelSearchProductLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.modelSearchProductLabel setNumberOfLines:2];
    [self.modelSearchProductCellContentView addSubview:self.modelSearchProductLabel];
    
    //할인가
    self.modelSearchProductDiscountLabel = [[TTTAttributedLabel alloc] init];
    [self.modelSearchProductDiscountLabel setBackgroundColor:[UIColor clearColor]];
    [self.modelSearchProductDiscountLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.modelSearchProductDiscountLabel setTextColor:UIColorFromRGB(0x292929)];
    [self.modelSearchProductCellContentView addSubview:self.modelSearchProductDiscountLabel];
    
    //SatisfyView
    self.modelSearchProductSatisfyView = [[UIView alloc] init];
    [self.modelSearchProductCellContentView addSubview:self.modelSearchProductSatisfyView];
    
    //priceCompareImageView
    UIImage *compareImage = [[UIImage imageNamed:@"bt_s_pricelist.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    
    self.modelSearchProductPriceCompareImageView = [[UIImageView alloc] init];
    [self.modelSearchProductPriceCompareImageView setImage:compareImage];
    [self.modelSearchProductCellContentView addSubview:self.modelSearchProductPriceCompareImageView];
    
    //blankButton
    self.modelSearchProductActionView = [[CPTouchActionView alloc] init];
    self.modelSearchProductActionView.frame = self.modelSearchProductCellContentView.frame;
    [self.contentView addSubview:self.modelSearchProductActionView];
}

- (void)initNoSearchData
{
    self.noSearchDataCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 295)];
    [self.noSearchDataCellContentView setBackgroundColor:[UIColor clearColor]];
    [self.noSearchDataCellContentView setCenter:CGPointMake(CGRectGetWidth(self.contentFrame)/2, CGRectGetHeight(self.contentFrame)/2)];
    [self.contentView addSubview:self.noSearchDataCellContentView];
    
    self.noSearchDataImageView = [[UIImageView alloc] init];
    [self.noSearchDataCellContentView addSubview:self.noSearchDataImageView];
    
    self.noSearchDataView = [[UIView alloc] init];
    [self.noSearchDataView setBackgroundColor:[UIColor clearColor]];
    [self.noSearchDataCellContentView addSubview:self.noSearchDataView];
}

- (void)initSearchHotProduct
{
    self.searchHotProductCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, (kScreenBoundsWidth-20)/1.621+(kScreenBoundsWidth-20)/15)];
    [self.searchHotProductCellContentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.searchHotProductCellContentView];
    
    //첫번째 이미지
    self.searchHotProductFirstImageView = [[CPThumbnailView alloc] init];
    [self.searchHotProductCellContentView addSubview:self.searchHotProductFirstImageView];
    
    //성인이미지뷰
    self.searchHotProductFirstAdultView = [[UIView alloc] init];
    [self.searchHotProductFirstAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchHotProductFirstImageView addSubview:self.searchHotProductFirstAdultView];
    
    self.searchHotProductFirstAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_03.png"]];
    [self.searchHotProductFirstAdultView addSubview:self.searchHotProductFirstAdultImageView];
    
    self.searchHotProductFirstGradationImageView = [[UIImageView alloc] init];
    [self.searchHotProductFirstImageView addSubview:self.searchHotProductFirstGradationImageView];
    
    self.searchHotProductFirstIconView = [[UIView alloc] init];
    [self.searchHotProductFirstImageView addSubview:self.searchHotProductFirstIconView];
    
    self.searchHotProductFirstPriceLabel = [[TTTAttributedLabel alloc] init];
    [self.searchHotProductFirstPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchHotProductFirstPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.searchHotProductFirstPriceLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.searchHotProductFirstPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.searchHotProductFirstImageView addSubview:self.searchHotProductFirstPriceLabel];
    
    self.searchHotProductFirstBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchHotProductFirstBlankButton setTag:CPHotProductButtonTypeFirst];
    [self.searchHotProductFirstBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.searchHotProductFirstBlankButton setAlpha:0.3];
    [self.searchHotProductFirstBlankButton addTarget:self action:@selector(touchSearchHotProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchHotProductFirstImageView addSubview:self.searchHotProductFirstBlankButton];
    
    [self.searchHotProductFirstBlankButton setBackgroundColor:UIColorFromRGB(0xff0000)];
    
    //두번째 이미지
    self.searchHotProductSecondImageView = [[CPThumbnailView alloc] init];
    [self.searchHotProductCellContentView addSubview:self.searchHotProductSecondImageView];
    
    //성인이미지뷰
    self.searchHotProductSecondAdultView = [[UIView alloc] init];
    [self.searchHotProductSecondAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchHotProductSecondImageView addSubview:self.searchHotProductSecondAdultView];
    
    self.searchHotProductSecondAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    [self.searchHotProductSecondAdultView addSubview:self.searchHotProductSecondAdultImageView];
    
    self.searchHotProductSecondGradationImageView = [[UIImageView alloc] init];
    [self.searchHotProductSecondImageView addSubview:self.searchHotProductSecondGradationImageView];
    
    self.searchHotProductSecondPriceLabel = [[TTTAttributedLabel alloc] init];
    [self.searchHotProductSecondPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchHotProductSecondPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.searchHotProductSecondPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.searchHotProductSecondPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.searchHotProductSecondImageView addSubview:self.searchHotProductSecondPriceLabel];
    
    self.searchHotProductSecondBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchHotProductSecondBlankButton setTag:CPHotProductButtonTypeSecond];
    [self.searchHotProductSecondBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.searchHotProductSecondBlankButton setAlpha:0.3];
    [self.searchHotProductSecondBlankButton addTarget:self action:@selector(touchSearchHotProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchHotProductSecondImageView addSubview:self.searchHotProductSecondBlankButton];
    
    //세번째 이미지
    self.searchHotProductThirdImageView = [[CPThumbnailView alloc] init];
    [self.searchHotProductCellContentView addSubview:self.searchHotProductThirdImageView];
    
    //성인이미지뷰
    self.searchHotProductThirdAdultView = [[UIView alloc] init];
    [self.searchHotProductThirdAdultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
    [self.searchHotProductThirdImageView addSubview:self.searchHotProductThirdAdultView];
    
    self.searchHotProductThirdAdultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
    [self.searchHotProductThirdAdultView addSubview:self.searchHotProductThirdAdultImageView];
    
    self.searchHotProductThirdGradationImageView = [[UIImageView alloc] init];
    [self.searchHotProductThirdImageView addSubview:self.searchHotProductThirdGradationImageView];
    
    self.searchHotProductThirdPriceLabel = [[TTTAttributedLabel alloc] init];
    [self.searchHotProductThirdPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.searchHotProductThirdPriceLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.searchHotProductThirdPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.searchHotProductThirdPriceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.searchHotProductThirdImageView addSubview:self.searchHotProductThirdPriceLabel];
    
    self.searchHotProductThirdBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchHotProductThirdBlankButton setTag:CPHotProductButtonTypeThird];
    [self.searchHotProductThirdBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [self.searchHotProductThirdBlankButton setAlpha:0.3];
    [self.searchHotProductThirdBlankButton addTarget:self action:@selector(touchSearchHotProduct:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchHotProductThirdImageView addSubview:self.searchHotProductThirdBlankButton];
}

- (void)initTworldDirect
{
    self.tWorldDirectCellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, 34+140)];
    [self.contentView addSubview:self.tWorldDirectCellContentView];
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

- (void)setData:(CPCollectionData *)data indexPath:(NSIndexPath *)indexPath
{
    if ([data.items count] == 0) {
        [self setNoData];
        return;
    }
    
    self.collectionData = data;
    self.dicData = [[NSDictionary alloc] initWithDictionary:data.items[indexPath.row]];
    
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
    else if ([groupName isEqualToString:@"shockingDealAppLink"]) {
        [self setShockingDealAppLink:indexPath];
    }
    else if ([groupName isEqualToString:@"ctgrHotClick"]) {
        [self setCtgrHotClick:indexPath];
    }
    else if ([groupName isEqualToString:@"ctgrBest"]) {
        [self setCtgrBest:indexPath];
    }
    else if ([groupName isEqualToString:@"ctgrDealBest"]) {
        [self setCtgrDealBest:indexPath];
    }
    else if ([groupName isEqualToString:@"searchProduct"]) {
        [self setSearchProduct:indexPath];
    }
    else if ([groupName isEqualToString:@"searchProductGrid"]) {
        [self setSearchProductGrid:indexPath];
    }
    else if ([groupName isEqualToString:@"searchProductBanner"]) {
        [self setSearchProductBanner:indexPath];
    }
    else if ([groupName isEqualToString:@"shockingDealProduct"]) {
        [self setShockingDealProduct:indexPath];
    }
    else if ([groupName isEqualToString:@"relatedSearchText"]) {
        [self setRelatedSearchText:indexPath];
    }
    else if ([groupName isEqualToString:@"recommendSearchText"]) {
        [self setRecommendSearchText];
    }
    else if ([groupName isEqualToString:@"searchFilter"]) {
        [self setSearchFilter];
    }
    else if ([groupName isEqualToString:@"searchTopTab"]) {
        [self setSearchTopTab];
    }
    else if ([groupName isEqualToString:@"sorting"]) {
        [self setSorting];
    }
    else if ([groupName isEqualToString:@"categoryNavi"]) {
        [self setCategoryNavi];
    }
    else if ([groupName isEqualToString:@"searchCaption"]) {
        [self setSearchCaption:indexPath];
    }
    else if ([groupName isEqualToString:@"searchMore"]) {
        [self setSearchMore:indexPath];
    }
    else if ([groupName isEqualToString:@"modelSearchProduct"]) {
        [self setModelSearchProduct:indexPath];
    }
    else if ([groupName isEqualToString:@"noSearchData"]) {
        [self setNoSearchData];
    }
    else if ([groupName isEqualToString:@"searchHotProduct"]) {
        [self setSearchHotProduct];
    }
    else if ([groupName isEqualToString:@"tworldDirect"]) {
        [self setTworldDirect:indexPath];
    }
    else if ([groupName isEqualToString:@"noData"]) {
        [self setNoData];
    }
}

#pragma mark - SettingView

//draw
- (void)setCommonProduct:(NSIndexPath *)indexPath
{
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
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
        }
        strRange = [imgUrl rangeOfString:@"{{img_height}}"];
        if (strRange.location != NSNotFound) {
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
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
        
        [self.commonProductPriceLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.commonProductProductNameLabel.frame)+2, priceLabelSize.width, 11)];
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
        
        [self.commonProductDiscountLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.commonProductProductNameLabel.frame)+12, discountLabelSize.width, 17)];
        [self.commonProductDiscountLabel setText:discountString];
        
        [self.commonProductUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.commonProductDiscountLabel.frame), CGRectGetMaxY(self.commonProductProductNameLabel.frame)+16, 11, 11)];
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
    
}

- (void)setBestProductCategory:(NSIndexPath *)indexPath
{
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
    CGFloat buttonHeight = (CGRectGetHeight(self.bestProductCategoryCellContentView.frame)-30)/categoryBestItems.count;
    
    for (int i = 0; i < categoryBestItems.count; i++) {
        NSDictionary *categoryItem = categoryBestItems[i];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight + (buttonHeight * i), CGRectGetWidth(self.bestProductCategoryCellContentView.frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xd0cdcd)];
        [self.bestProductCategoryCellContentView addSubview:lineView];
        
        UIView *cateView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame), buttonHeight)];
        [self.bestProductCategoryCellContentView addSubview:cateView];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame)-10, buttonHeight)];
        [categoryLabel setText:categoryItem[@"title"]];
        [categoryLabel setTextColor:UIColorFromRGB(0x333333)];
        [categoryLabel setFont:[UIFont systemFontOfSize:14]];
        [self.bestProductCategoryCellContentView addSubview:categoryLabel];
        
        UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [categoryButton setFrame:CGRectMake(0, topHeight + (buttonHeight * i) + 1, CGRectGetWidth(self.bestProductCategoryCellContentView.frame), buttonHeight)];
        [categoryButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [categoryButton setAlpha:0.3];
        [categoryButton setTitle:categoryItem[@"linkUrl"] forState:UIControlStateNormal];
        [categoryButton.titleLabel setFont:[UIFont systemFontOfSize:0]];
        [categoryButton addTarget:self action:@selector(touchCategoryBest:) forControlEvents:UIControlEventTouchUpInside];
        [self.bestProductCategoryCellContentView addSubview:categoryButton];
        
        UIImage *arrow = [UIImage imageNamed:@"besttab_ca_arrow.png"];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrow];
        [arrowImageView setFrame:CGRectMake(CGRectGetWidth(self.bestProductCategoryCellContentView.frame) - arrow.size.width - 16, 11.5f + topHeight + (buttonHeight * i), arrow.size.width, arrow.size.height)];
        [self.bestProductCategoryCellContentView addSubview:arrowImageView];
    }
}

- (void)setBannerProduct:(NSIndexPath *)indexPath
{
    //BannerProduct개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
    NSInteger groupNameIndex = [self.dicData[@"groupNameIndex"] integerValue];
                 
    CGRect frame = self.frame;
    if (groupNameIndex%2 == indexPath.row%2) {
        frame.origin.x = 10;
        self.frame = frame;
    }
    
    NSDictionary *bannerProductItems = self.dicData[@"bannerProduct"];
    
    NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+8)*2 : kScreenBoundsWidth - 20;
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
        
        [self.bannerProductProductNameLabel setText:[str substringWithRange:NSMakeRange(0, index+1)]];
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
//        NSInteger arrayCount = [array count];
        
        //3.5인치의 경우 max는 4개
//        if ((IS_IPHONE_4 || IS_IPHONE_5) && arrayCount > 4) {
//            arrayCount = 4;
//        }
        
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
    
    
    //구매개수
    NSString *purchaseCount = [bannerProductItems[@"selQty"] formatThousandComma];
    NSString *purchaseUnit = @"개 구매";
    
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
    
    
    [self.bannerProductRelativeProductLabel setText:@"연관상품"];
    [self.bannerProductRelativeProductImage setImage:[UIImage imageNamed:@"bt_plus_s.png"]];
    
    CGSize relativeProductLabelSize = [self.bannerProductRelativeProductLabel.text sizeWithFont:self.bannerProductRelativeProductLabel.font constrainedToSize:CGSizeMake(10000, 20) lineBreakMode:self.bannerProductRelativeProductLabel.lineBreakMode];
    
    size = relativeProductLabelSize.width + 20;
    
    [self.bannerProductRelativeProductLabel setFrame:CGRectMake((CGRectGetWidth(self.bannerProductRelativeProductButton.frame)-size)/2, (CGRectGetHeight(self.bannerProductRelativeProductButton.frame)-20)/2, relativeProductLabelSize.width, 20)];
    [self.bannerProductRelativeProductImage setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductRelativeProductLabel.frame), (CGRectGetHeight(self.bannerProductRelativeProductButton.frame)-20)/2, 20, 20)];
    
    [self.bannerProductBlankButton setFrame:CGRectMake(0, 5, productWidth, productHeight-36)];
    [self.bannerProductBlankButton setTag:indexPath.row];
    [self.bannerProductBlankButton addTarget:self action:@selector(touchBannerProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([bannerProductItems[@"movieYn"] isEqualToString:@"Y"]) {
        [self.bannerProductVideoPlayButton setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductThumbnailView.frame)-50, CGRectGetMaxY(self.bannerProductThumbnailView.frame)-50, 40, 40)];
        [self.bannerProductVideoPlayButton setImage:[UIImage imageNamed:@"bt_small_play.png"] forState:UIControlStateNormal];
        [self.bannerProductVideoPlayButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
        [self.bannerProductVideoPlayButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [self.bannerProductVideoPlayButton setHidden:NO];
        [self.bannerProductVideoPlayButton setTag:indexPath.row];
        [self.bannerProductVideoPlayButton addTarget:self action:@selector(touchVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.bannerProductVideoPlayButton setFrame:CGRectMake(CGRectGetMaxX(self.bannerProductThumbnailView.frame)-50, CGRectGetMaxY(self.bannerProductThumbnailView.frame)-50, 40, 40)];
        [self.bannerProductVideoPlayButton setHidden:YES];
    }
    
    [self.contentView addSubview:self.bannerProductVideoPlayButton];
}

- (void)setLineBanner:(NSIndexPath *)indexPath
{
    NSDictionary *lineBannerItems = self.dicData[@"lineBanner"];
    
    //backgroundColor
    NSString *colorValue = lineBannerItems[@"extraText"];
    if (colorValue.length >= 7) {
        unsigned colorInt = 0;
        [[NSScanner scannerWithString:[colorValue substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
        [self.lineBannerContentView setBackgroundColor:UIColorFromRGB(colorInt)];
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
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
        }
        strRange = [imgUrl rangeOfString:@"{{img_height}}"];
        if (strRange.location != NSNotFound) {
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
        }
        
        [self.lineBannerImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
    }
    else {
        [self.lineBannerImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
    }
    
    [self.lineBannerButton setTag:indexPath.row];
    [self.lineBannerButton addTarget:self action:@selector(onTouchBanner:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setShockingDealAppLink:(NSIndexPath *)indexPath
{
    
}

- (void)setCtgrHotClick:(NSIndexPath *)indexPath
{
    NSArray *ctgrHotClickItems = self.dicData[@"items"];
    NSInteger itemCount = ctgrHotClickItems.count;
    if (itemCount < 3) {
        return;
    }
    [self.ctgrHotClickCellContentView setFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, itemCount > 3 ? 350+[Modules getCategoryItemHeight]*2 : 198+[Modules getCategoryItemHeight])];
    
    for (UIView *subView in [self.ctgrHotClickCellContentView subviews]) {
        [subView removeFromSuperview];
    }
    
    UILabel *chcTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 150, 15)];
    [chcTitleLabel setText:@"HOT클릭"];
    [chcTitleLabel setBackgroundColor:[UIColor clearColor]];
    [chcTitleLabel setTextColor:UIColorFromRGB(0x111111)];
    [chcTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [chcTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.ctgrHotClickCellContentView addSubview:chcTitleLabel];
    
    if ([self.dicData[@"adInfo"] length] != 0) {
        UIButton *chcADButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chcADButton setFrame:CGRectMake(CGRectGetWidth(self.ctgrHotClickCellContentView.frame)-40, 0, 40, 40)];
        [chcADButton setTitle:@"AD" forState:UIControlStateNormal];
        [chcADButton setTitleColor:UIColorFromRGB(0x757b9c) forState:UIControlStateNormal];
        [chcADButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [chcADButton addTarget:self action:@selector(touchCtgrHotClickAD:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctgrHotClickCellContentView addSubview:chcADButton];
    }
    
    UIView *chcProductContentView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(chcTitleLabel.frame)+13, CGRectGetWidth(self.ctgrHotClickCellContentView.frame)-30, (itemCount > 3 ? 308+[Modules getCategoryItemHeight]*2 : 156+[Modules getCategoryItemHeight]))];
    [chcProductContentView setBackgroundColor:[UIColor whiteColor]];
    [self.ctgrHotClickCellContentView addSubview:chcProductContentView];
    
    for (NSDictionary *dic in ctgrHotClickItems) {
        
//        CGFloat imgViewWidth = 84;
        CGFloat imgViewWidth = (CGRectGetWidth(chcProductContentView.frame)-30)/3;
        CGFloat imgViewHeight = 154+[Modules getCategoryItemHeight];
        CGFloat imgViewX = 0;
        CGFloat imgViewY = [ctgrHotClickItems indexOfObject:dic] < 3 ? 0 : imgViewHeight;
        
        switch ([ctgrHotClickItems indexOfObject:dic]%3) {
            case 1:
                imgViewX = (CGRectGetWidth(chcProductContentView.frame)-imgViewWidth)/2;
                break;
            case 2:
                imgViewX = CGRectGetWidth(chcProductContentView.frame)-imgViewWidth;
                break;
            default:
                imgViewX = 0;
                break;
        }
        
        UIView *chcCellView = [[UIView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, imgViewWidth, imgViewHeight)];
        [chcCellView setBackgroundColor:[UIColor whiteColor]];
        [chcProductContentView addSubview:chcCellView];
        
        UIImageView *chcProductImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
        NSString *imgUrl = dic[@"img1"];
        NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
        
        if ([dic[@"adultProduct"] isEqualToString:@"Y"]) {
//            [chcProductImageView setImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
            
            UIView *adultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
            [adultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
            [chcProductImageView addSubview:adultView];
            
            UIImage *adultImage = [UIImage imageNamed:IS_IPAD?@"ic_li_adult_03.png":@"ic_li_adult_01.png"];
            CGFloat iconSize = IS_IPAD?132:60;
            
            UIImageView *adultImageView = [[UIImageView alloc] initWithImage:adultImage];
            [adultImageView setFrame:CGRectMake((CGRectGetWidth(adultView.frame)-iconSize)/2, (CGRectGetHeight(adultView.frame)-iconSize)/2, iconSize, iconSize)];
            [adultView addSubview:adultImageView];
        }
        else {
            if ([imgUrl length] > 0) {
                NSRange strRange = [imgUrl rangeOfString:@"http"];
                if (strRange.location == NSNotFound) {
                    imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
                }
                strRange = [imgUrl rangeOfString:@"{{img_width}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                strRange = [imgUrl rangeOfString:@"{{img_height}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                
                [chcProductImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            else {
                [chcProductImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
            }
        }
        
        [chcCellView addSubview:chcProductImageView];
        
        
        UILabel *chcProductNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, CGRectGetMaxY(chcProductImageView.frame)+7, imgViewWidth-22, 36)];
        [chcProductNameLabel setText:[dic objectForKey:@"prdNm"]];
        [chcProductNameLabel setBackgroundColor:[UIColor clearColor]];
        [chcProductNameLabel setTextColor:UIColorFromRGB(0x333333)];
        [chcProductNameLabel setFont:[UIFont systemFontOfSize:14]];
        [chcProductNameLabel setTextAlignment:NSTextAlignmentLeft];
        [chcProductNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [chcProductNameLabel setNumberOfLines:2];
        [chcCellView addSubview:chcProductNameLabel];
        
        
        TTTAttributedLabel *chcPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(chcProductNameLabel.frame)+3, imgViewWidth, 16)];
        [chcPriceLabel setBackgroundColor:[UIColor clearColor]];
        [chcPriceLabel setTextColor:UIColorFromRGB(0x111111)];
        [chcPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [chcPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [chcCellView addSubview:chcPriceLabel];
        
        NSString *text = [NSString stringWithFormat:@"%@원", [dic[@"finalPrc"] formatThousandComma]];
        [chcPriceLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        
        UIButton *chcBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chcBlankButton setTag:[ctgrHotClickItems indexOfObject:dic]];
        [chcBlankButton setFrame:CGRectMake(0, 0, imgViewWidth, imgViewHeight)];
        [chcBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [chcBlankButton setAlpha:0.3];
        [chcBlankButton addTarget:self action:@selector(touchCtgrHotClickProduct:) forControlEvents:UIControlEventTouchUpInside];
        [chcBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", dic[@"prdNm"], dic[@"finalPrc"]]];
        [chcCellView addSubview:chcBlankButton];
        
        
    }
}

- (void)setCtgrBest:(NSIndexPath *)indexPath
{
    NSArray *ctgrBestItems = self.dicData[@"items"];
    NSInteger itemCount = ctgrBestItems.count;
    if (itemCount < 3) {
        return;
    }
    
    for (UIView *subView in [self.ctgrBestCellContentView subviews]) {
        [subView removeFromSuperview];
    }
    
    UILabel *cbTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 150, 15)];
    [cbTitleLabel setText:@"베스트"];
    [cbTitleLabel setBackgroundColor:[UIColor clearColor]];
    [cbTitleLabel setTextColor:UIColorFromRGB(0x111111)];
    [cbTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [cbTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.ctgrBestCellContentView addSubview:cbTitleLabel];
    
    NSString *linkUrl = self.dicData[@"moreUrl"];
    if (linkUrl && [[linkUrl trim] length] > 0) {
        UIButton *cbADButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cbADButton setFrame:CGRectMake(CGRectGetWidth(self.ctgrBestCellContentView.frame)-55, 10, 45, 20)];
        [cbADButton setImage:[UIImage imageNamed:@"bt_c_arrow_view_02.png"] forState:UIControlStateNormal];
        [cbADButton setTitle:@"더보기" forState:UIControlStateNormal];
        [cbADButton setTitleColor:UIColorFromRGB(0x301a93) forState:UIControlStateNormal];
        [cbADButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [cbADButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        [cbADButton setImageEdgeInsets:UIEdgeInsetsMake(0, 38, 0, 0)];
        [cbADButton addTarget:self action:@selector(touchCtgrBest:) forControlEvents:UIControlEventTouchUpInside];
        [self.ctgrBestCellContentView addSubview:cbADButton];
    }
    
    UIView *cbProductContentView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(cbTitleLabel.frame)+14, CGRectGetWidth(self.ctgrBestCellContentView.frame)-30, 154+[Modules getCategoryItemHeight])];
    [cbProductContentView setBackgroundColor:[UIColor whiteColor]];
    [self.ctgrBestCellContentView addSubview:cbProductContentView];
    
    for (NSDictionary *dic in ctgrBestItems) {
        
        CGFloat imgViewWidth = (CGRectGetWidth(cbProductContentView.frame)-30)/3;
        CGFloat imgViewHeight = 154+[Modules getCategoryItemHeight];
        CGFloat imgViewX = 0;
        CGFloat imgViewY = 0;
        
        switch ([ctgrBestItems indexOfObject:dic]%3) {
            case 1:
                imgViewX = (CGRectGetWidth(cbProductContentView.frame)-imgViewWidth)/2;
                break;
            case 2:
                imgViewX = CGRectGetWidth(cbProductContentView.frame)-imgViewWidth;
                break;
            default:
                imgViewX = 0;
                break;
        }
        
        UIView *cbCellView = [[UIView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, imgViewWidth, imgViewHeight)];
        [cbCellView setBackgroundColor:[UIColor whiteColor]];
        [cbProductContentView addSubview:cbCellView];
        
        
        UIImageView *cbProductImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
        NSString *imgUrl = dic[@"img1"];
        NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
        
        if ([dic[@"adultProduct"] isEqualToString:@"Y"]) {
//            [cbProductImageView setImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
            
            UIView *adultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
            [adultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
            [cbProductImageView addSubview:adultView];
            
            UIImageView *adultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
            [adultImageView setFrame:CGRectMake((CGRectGetWidth(adultView.frame)-60)/2, (CGRectGetHeight(adultView.frame)-60)/2, 60, 60)];
            [adultView addSubview:adultImageView];
        }
        else {
            if ([imgUrl length] > 0) {
                NSRange strRange = [imgUrl rangeOfString:@"http"];
                if (strRange.location == NSNotFound) {
                    imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
                }
                strRange = [imgUrl rangeOfString:@"{{img_width}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                strRange = [imgUrl rangeOfString:@"{{img_height}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                
                [cbProductImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            else {
                [cbProductImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
            }
        }
        
        [cbCellView addSubview:cbProductImageView];
        
        
        UILabel *cbProductNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, CGRectGetMaxY(cbProductImageView.frame)+6, imgViewWidth-22, 36)];
        [cbProductNameLabel setText:[dic objectForKey:@"prdNm"]];
        [cbProductNameLabel setBackgroundColor:[UIColor clearColor]];
        [cbProductNameLabel setTextColor:UIColorFromRGB(0x333333)];
        [cbProductNameLabel setFont:[UIFont systemFontOfSize:14]];
        [cbProductNameLabel setTextAlignment:NSTextAlignmentLeft];
        [cbProductNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [cbProductNameLabel setNumberOfLines:2];
        [cbCellView addSubview:cbProductNameLabel];
        
        
        TTTAttributedLabel *cbPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cbProductNameLabel.frame)+3, imgViewWidth, 16)];
        [cbPriceLabel setBackgroundColor:[UIColor clearColor]];
        [cbPriceLabel setTextColor:UIColorFromRGB(0x111111)];
        [cbPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [cbPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [cbCellView addSubview:cbPriceLabel];
        
        NSString *text = [NSString stringWithFormat:@"%@원", [dic[@"finalPrc"] formatThousandComma]];
        [cbPriceLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        
        UIButton *cbBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cbBlankButton setTag:[ctgrBestItems indexOfObject:dic]];
        [cbBlankButton setFrame:CGRectMake(0, 0, imgViewWidth, imgViewHeight)];
        [cbBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [cbBlankButton setAlpha:0.3];
        [cbBlankButton addTarget:self action:@selector(touchCtgrBestProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cbBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", dic[@"prdNm"], dic[@"finalPrc"]]];
        [cbCellView addSubview:cbBlankButton];
    }
}

- (void)setCtgrDealBest:(NSIndexPath *)indexPath
{
    NSArray *ctgrDealBestItems = self.dicData[@"items"];
    NSInteger itemCount = ctgrDealBestItems.count;
    if (itemCount < 3) {
        return;
    }
    
    for (UIView *subView in [self.ctgrDealBestCellContentView subviews]) {
        [subView removeFromSuperview];
    }
    
    UILabel *cdbTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 150, 15)];
    [cdbTitleLabel setText:@"쇼킹딜베스트"];
    [cdbTitleLabel setBackgroundColor:[UIColor clearColor]];
    [cdbTitleLabel setTextColor:UIColorFromRGB(0x111111)];
    [cdbTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [cdbTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.ctgrDealBestCellContentView addSubview:cdbTitleLabel];
    
    
    UIView *cdbProductContentView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(cdbTitleLabel.frame)+14, CGRectGetWidth(self.ctgrDealBestCellContentView.frame)-30, 154+[Modules getCategoryItemHeight])];
    [cdbProductContentView setBackgroundColor:[UIColor whiteColor]];
    [self.ctgrDealBestCellContentView addSubview:cdbProductContentView];
    
    for (NSDictionary *dic in ctgrDealBestItems) {
        
        CGFloat imgViewWidth = (CGRectGetWidth(cdbProductContentView.frame)-30)/3;
        CGFloat imgViewHeight = 154+[Modules getCategoryItemHeight];
        CGFloat imgViewX = 0;
        CGFloat imgViewY = 0;
        
        switch ([ctgrDealBestItems indexOfObject:dic]%3) {
            case 1:
                imgViewX = (CGRectGetWidth(cdbProductContentView.frame)-imgViewWidth)/2;
                break;
            case 2:
                imgViewX = CGRectGetWidth(cdbProductContentView.frame)-imgViewWidth;
                break;
            default:
                imgViewX = 0;
                break;
        }
        
        UIView *cdbCellView = [[UIView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, imgViewWidth, imgViewHeight)];
        [cdbCellView setBackgroundColor:[UIColor whiteColor]];
        [cdbProductContentView addSubview:cdbCellView];
        
        UIImageView *cdbProductImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
        NSString *imgUrl = dic[@"img1"];
        NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
        
        if ([dic[@"adultProduct"] isEqualToString:@"Y"]) {
//            [cdbProductImageView setImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
            
            UIView *adultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgViewWidth, imgViewWidth)];
            [adultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
            [cdbProductImageView addSubview:adultView];
            
            UIImageView *adultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
            [adultImageView setFrame:CGRectMake((CGRectGetWidth(adultView.frame)-60)/2, (CGRectGetHeight(adultView.frame)-60)/2, 60, 60)];
            [adultView addSubview:adultImageView];
        }
        else {
            if ([imgUrl length] > 0) {
                NSRange strRange = [imgUrl rangeOfString:@"http"];
                if (strRange.location == NSNotFound) {
                    imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
                }
                strRange = [imgUrl rangeOfString:@"{{img_width}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                strRange = [imgUrl rangeOfString:@"{{img_height}}"];
                if (strRange.location != NSNotFound) {
                    imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%f", imgViewWidth*2]];
                }
                
                [cdbProductImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
            }
            else {
                [cdbProductImageView setImage:[UIImage imageNamed:@"thum_default.png"]];
            }
        }
        
        [cdbCellView addSubview:cdbProductImageView];
        
        
        UILabel *cdbProductNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, CGRectGetMaxY(cdbProductImageView.frame)+6, imgViewWidth-22, 36)];
        [cdbProductNameLabel setText:[dic objectForKey:@"prdNm"]];
        [cdbProductNameLabel setBackgroundColor:[UIColor clearColor]];
        [cdbProductNameLabel setTextColor:UIColorFromRGB(0x333333)];
        [cdbProductNameLabel setFont:[UIFont systemFontOfSize:14]];
        [cdbProductNameLabel setTextAlignment:NSTextAlignmentLeft];
        [cdbProductNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [cdbProductNameLabel setNumberOfLines:2];
        [cdbCellView addSubview:cdbProductNameLabel];
        
        
        TTTAttributedLabel *cdbPriceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cdbProductNameLabel.frame)+3, imgViewWidth, 16)];
        [cdbPriceLabel setBackgroundColor:[UIColor clearColor]];
        [cdbPriceLabel setTextColor:UIColorFromRGB(0x111111)];
        [cdbPriceLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [cdbPriceLabel setTextAlignment:NSTextAlignmentCenter];
        [cdbCellView addSubview:cdbPriceLabel];
        
        NSString *text = [NSString stringWithFormat:@"%@원", [dic[@"finalPrc"] formatThousandComma]];
        [cdbPriceLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        
        UIButton *cdbBlankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cdbBlankButton setTag:[ctgrDealBestItems indexOfObject:dic]];
        [cdbBlankButton setFrame:CGRectMake(0, 0, imgViewWidth, imgViewHeight)];
        [cdbBlankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [cdbBlankButton setAlpha:0.3];
        [cdbBlankButton addTarget:self action:@selector(touchCtgrDealBestProduct:) forControlEvents:UIControlEventTouchUpInside];
        [cdbBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", dic[@"prdNm"], dic[@"finalPrc"]]];
        [cdbCellView addSubview:cdbBlankButton];
    }
}

- (void)setSearchProduct:(NSIndexPath *)indexPath
{
    for (UIView *subView in [self.searchProductIconView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [self.searchProductSatisfyView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [self.searchProductSellerView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *searchProductItems = self.dicData;
    
    [self.commonProductBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", searchProductItems[@"prdNm"], searchProductItems[@"finalPrc"]]];
    
    BOOL isExpanded = [[self.collectionData.items[indexPath.row] objectForKey:@"isExpanded"] isEqualToString:@"Y"];
    [self.searchProductCellContentView setFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, isExpanded ? 174 : 140)];
    
    
    //이미지
    NSString *imgUrl = searchProductItems[@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([searchProductItems[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
        
        [self.searchProductAdultView setHidden:NO];
        [self.searchProductAdultView setFrame:CGRectMake(0, 0, 120, 120)];
        [self.searchProductAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchProductAdultView.frame)-60)/2, (CGRectGetHeight(self.searchProductAdultView.frame)-60)/2, 60, 60)];
    }
    else {
        [self.searchProductAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            
            [self.searchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
            [self.searchProductThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
            [self.searchProductThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    if ([searchProductItems[@"dealPrdYN"] isEqualToString:@"Y"]) {
        [self.searchProductShockingDealImageView setFrame:CGRectMake(5, 5, 37, 15)];
        [self.searchProductShockingDealImageView setImage:[UIImage imageNamed:@"ic_li_shockingdeal_s.png"]];
    }
    else {
        [self.searchProductShockingDealImageView setImage:nil];
    }
    
    //iconView
    if ([searchProductItems[@"icons"] count] > 0) {
        
        NSArray *array = searchProductItems[@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [iconLabel setBackgroundColor:[UIColor clearColor]];
            [iconLabel setTextAlignment:NSTextAlignmentCenter];
            [iconLabel.layer setBorderWidth:1];
            [self.searchProductIconView addSubview:iconLabel];
            
            CGFloat width = 50;
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"100refund"]) {
                //TODO
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"tMember"]) {
                [iconLabel setText:@"T멤버십"];
                [iconLabel setTextColor:UIColorFromRGB(0xff411c)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffaa9e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"mileage"]) {
                [iconLabel setText:@"마일리지"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"myWay"]) {
                width = 78;
                [iconLabel setBackgroundColor:UIColorFromRGB(0xff3b0e)];
                [iconLabel setText:[NSString stringWithFormat:@"내맘대로 %@",[dic objectForKey:@"rate"]]];
                [iconLabel setTextColor:UIColorFromRGB(0xffffff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xff3b0e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"discountCard"]) {
                [iconLabel setText:@"카드할인"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            
            [iconLabel setFrame:CGRectMake(viewWidth, 0, width, 19)];
            viewWidth += width+1;
        }
        
        [self.searchProductIconView setFrame:CGRectMake(CGRectGetMaxX(self.searchProductThumbnailView.frame)+10, 12, viewWidth, 19)];
    }
    else {
        CGRect frame = self.searchProductIconView.frame;
        frame.size.height = 0;
        [self.searchProductIconView setFrame:frame];
    }
    
    //상품명
    if (searchProductItems[@"prdNm"]) {
        NSString *str = searchProductItems[@"prdNm"];
        BOOL isExistIcon = [searchProductItems[@"icons"] count] > 0;
        
        [self.searchProductLabel setText:str];
        [self.searchProductLabel setFrame:CGRectMake(CGRectGetMaxX(self.searchProductThumbnailView.frame)+10, isExistIcon?CGRectGetMaxY(self.searchProductIconView.frame)+5  :18, kScreenBoundsWidth-170, 40)];
    }
    
    //할인가
    if (searchProductItems[@"finalPrc"]) {
        NSString *text = [NSString stringWithFormat:@"%@원", [searchProductItems[@"finalPrc"] formatThousandComma]];
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductDiscountLabel.frame)) lineBreakMode:self.searchProductDiscountLabel.lineBreakMode];
        if (size.width > 90) {
            size.width = 90;
        }
        
        [self.searchProductDiscountLabel setFrame:CGRectMake(CGRectGetMaxX(self.searchProductThumbnailView.frame)+10, CGRectGetMaxY(self.searchProductLabel.frame)+6, size.width, 20)];
        [self.searchProductDiscountLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }
    
    //실제가격
    if (searchProductItems[@"selPrc"] && ![searchProductItems[@"selPrc"] isEqualToString:searchProductItems[@"finalPrc"]]) {
        NSString *priceString = [NSString stringWithFormat:@"%@원", [searchProductItems[@"selPrc"] formatThousandComma]];
        CGSize priceLabelSize = [priceString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductPriceLabel.frame)) lineBreakMode:self.searchProductPriceLabel.lineBreakMode];
        if (priceLabelSize.width > 68) {
            priceLabelSize.width = 68;
        }
        
        [self.searchProductPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.searchProductDiscountLabel.frame), CGRectGetMinY(self.searchProductDiscountLabel.frame)+4, priceLabelSize.width, 14)];
        [self.searchProductPriceLabel setText:priceString];
        
        [self.searchProductPriceLineView setFrame:CGRectMake(CGRectGetMaxX(self.searchProductDiscountLabel.frame), 0, CGRectGetWidth(self.searchProductPriceLabel.frame), 1)];
        [self.searchProductPriceLineView setCenter:CGPointMake(CGRectGetWidth(self.searchProductPriceLabel.frame)/2, CGRectGetHeight(self.searchProductPriceLabel.frame)/2)];
    }
    else {
        [self.searchProductPriceLabel setText:@""];
        [self.searchProductPriceLineView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    NSInteger satisfyCount = [searchProductItems[@"buySatisfyGrd"] integerValue];
    NSInteger reviewCount = [searchProductItems[@"reviewCount"] integerValue];
    
    //만족도 70%이상 && 리뷰 수 1개이상
    if (satisfyCount >= 70 && reviewCount > 0) {
        [self.searchProductSatisfyView setHidden:NO];
        
        //SatisfyView
        [self.searchProductSatisfyView setFrame:CGRectMake(CGRectGetMaxX(self.searchProductThumbnailView.frame)+10, 112, 120, 14)];
        
        UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
        NSInteger buySatisfyGrd = [searchProductItems[@"buySatisfyGrd"] integerValue];
        CGFloat viewWidth = 0;
        
        for (int i = 0; i < 5; i++) {
            
            if (i*20 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_off.png"];
            }
            else if (i*20+10 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_half.png"];
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 2, 10, 9)];
            [imgView setImage:image];
            [self.searchProductSatisfyView addSubview:imgView];
            
            viewWidth += 11;
        }
        
        //reviewCount
        if (searchProductItems[@"reviewCount"] && [searchProductItems[@"reviewCount"] integerValue] >= 0) {
            
            NSString *satisfyString = [NSString stringWithFormat:@"(%@)", [searchProductItems[@"reviewCount"] formatThousandComma]];
            CGSize satisfyLabelSize = [satisfyString sizeWithFont:[UIFont systemFontOfSize:13]];
            
            UILabel *satisfyLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth+3, 0, satisfyLabelSize.width, 13)];
            [satisfyLabel setText:satisfyString];
            [satisfyLabel setBackgroundColor:[UIColor clearColor]];
            [satisfyLabel setTextColor:UIColorFromRGB(0x5f5f5f)];
            [satisfyLabel setFont:[UIFont systemFontOfSize:13]];
            [satisfyLabel setTextAlignment:NSTextAlignmentLeft];
            [self.searchProductSatisfyView addSubview:satisfyLabel];
        }
    }
    else {
        [self.searchProductSatisfyView setHidden:YES];
    }
    
    //ajax call Button
    [self.searchProductUpdownButton setTag:indexPath.row];
    [self.searchProductUpdownButton setFrame:CGRectMake(CGRectGetWidth(self.searchProductCellContentView.frame)-32, 118, 32, 27)];
    [self.searchProductUpdownButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_li_arrow_%@.png", isExpanded?@"up":@"down"]] forState:UIControlStateNormal];
    [self.searchProductUpdownButton addTarget:self action:@selector(touchSearchProductAjaxCall:) forControlEvents:UIControlEventTouchUpInside];
    
    //productLink Button
    [self.searchProductActionView setActionType:CPButtonActionTypeOpenSubview];
    [self.searchProductActionView setActionItem:searchProductItems[@"prdDtlUrl"]];
    [self.searchProductActionView setWiseLogCode:searchProductItems[@"clickCd"]];
    [self.searchProductActionView setAdClickItems:searchProductItems[@"adClickTrcUrl"]];
    [self.searchProductActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", searchProductItems[@"prdNm"], searchProductItems[@"finalPrc"]] Hint:@""];
    
    //sellerView
    if (isExpanded) {
        [self.searchProductSellerView setFrame:CGRectMake(0, 140, kScreenBoundsWidth-20, 34)];
        
        UIView *searchProductUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 1)];
        [searchProductUnderLineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
        [self.searchProductSellerView addSubview:searchProductUnderLineView];
        
        //seller
        NSString *sellerNm = searchProductItems[@"nckNm"];
        CGSize sellerNmSize = [sellerNm sizeWithFont:[UIFont systemFontOfSize:14]];
        
        UILabel *sellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 15)];
        [sellerLabel setText:sellerNm];
        [sellerLabel setBackgroundColor:[UIColor clearColor]];
        [sellerLabel setTextColor:UIColorFromRGB(0x666666)];
        [sellerLabel setFont:[UIFont systemFontOfSize:14]];
        [sellerLabel setTextAlignment:NSTextAlignmentLeft];
        [self.searchProductSellerView addSubview:sellerLabel];
        
        //star
        UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
        NSInteger psmGrd = [searchProductItems[@"psmGrd"] integerValue];
        CGFloat viewWidth = sellerNmSize.width < 80 ? sellerNmSize.width+13 : CGRectGetMaxX(sellerLabel.frame)+3;
        
        for (int i = 1; i <= 5; i++) {
            
            if (psmGrd < i) {
                image = [UIImage imageNamed:@"ic_li_star_off.png"];
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 12, 10, 9)];
            [imgView setImage:image];
            [self.searchProductSellerView addSubview:imgView];
            
            viewWidth += 11;
        }
        
        UIButton *sellerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sellerButton setTag:indexPath.row];
        [sellerButton setFrame:CGRectMake(CGRectGetMinX(sellerLabel.frame), CGRectGetMinY(sellerLabel.frame), viewWidth-10, 15)];
        [sellerButton setBackgroundColor:[UIColor clearColor]];
        [sellerButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [sellerButton setAlpha:0.3];
        [sellerButton addTarget:self action:@selector(touchSearchProductSellerButton:) forControlEvents:UIControlEventTouchUpInside];
        [sellerButton setAccessibilityLabel:@"판매자 정보"];
        [self.searchProductSellerView addSubview:sellerButton];
        
        //crdtSellerYN
        //csSellerYN
        NSInteger viewCount = 0;
        
        if ([searchProductItems[@"crdtSellerYN"] isEqualToString:@"Y"]) {
            viewCount++;
        }
        if ([searchProductItems[@"csSellerYN"] isEqualToString:@"Y"]) {
            viewCount++;
        }
        
        if (viewCount > 0) {
            if (viewCount == 1) {
                
                UILabel *firstLabel = [[UILabel alloc] init];
                [firstLabel setBackgroundColor:[UIColor clearColor]];
                [firstLabel setTextColor:UIColorFromRGB(0x666666)];
                [firstLabel setFont:[UIFont systemFontOfSize:12]];
                [firstLabel setTextAlignment:NSTextAlignmentLeft];
                [self.searchProductSellerView addSubview:firstLabel];
                
//                UIImage *image = [[UIImage alloc] init];
                UIImageView *imgView = [[UIImageView alloc] init];
                [self.searchProductSellerView addSubview:imgView];
                
                if ([searchProductItems[@"crdtSellerYN"] isEqualToString:@"Y"]) {
                    NSString *crdtSellerStr = @"판매우수";
                    CGSize crdtSellerSize = [crdtSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                    [firstLabel setText:crdtSellerStr];
                    [firstLabel setFrame:CGRectMake(kScreenBoundsWidth-crdtSellerSize.width-30, 11, crdtSellerSize.width, 13)];
                    
                    image = [UIImage imageNamed:@"ic_li_crown.png"];
                    [imgView setImage:image];
                    [imgView setFrame:CGRectMake(CGRectGetMinX(firstLabel.frame)-22, 10, 18, 14)];
                }
                else if ([searchProductItems[@"csSellerYN"] isEqualToString:@"Y"]) {
                    NSString *csSellerStr = @"고객만족";
                    CGSize csSellerSize = [csSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                    [firstLabel setText:csSellerStr];
                    [firstLabel setFrame:CGRectMake(kScreenBoundsWidth-csSellerSize.width-30, 11, csSellerSize.width, 13)];
                    
                    image = [UIImage imageNamed:@"ic_li_diamond.png"];
                    [imgView setImage:image];
                    [imgView setFrame:CGRectMake(CGRectGetMinX(firstLabel.frame)-22, 10, 18, 14)];
                }
            }
            else if (viewCount == 2) {
                
                NSString *csSellerStr = @"고객만족";
                CGSize csSellerSize = [csSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                
                UILabel *csSellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-csSellerSize.width-30, 11, csSellerSize.width, 13)];
                [csSellerLabel setBackgroundColor:[UIColor clearColor]];
                [csSellerLabel setText:csSellerStr];
                [csSellerLabel setTextColor:UIColorFromRGB(0x666666)];
                [csSellerLabel setFont:[UIFont systemFontOfSize:12]];
                [csSellerLabel setTextAlignment:NSTextAlignmentLeft];
                [self.searchProductSellerView addSubview:csSellerLabel];
                
                UIImageView *csSellerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_diamond.png"]];
                [csSellerImgView setFrame:CGRectMake(CGRectGetMinX(csSellerLabel.frame)-22, 10, 18, 14)];
                [self.searchProductSellerView addSubview:csSellerImgView];
                
                NSString *crdtSellerStr = @"판매우수";
                CGSize crdtSellerSize = [crdtSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                
                UILabel *crdtSellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(csSellerImgView.frame)-csSellerSize.width-6, 11, crdtSellerSize.width, 13)];
                [crdtSellerLabel setBackgroundColor:[UIColor clearColor]];
                [crdtSellerLabel setText:crdtSellerStr];
                [crdtSellerLabel setTextColor:UIColorFromRGB(0x666666)];
                [crdtSellerLabel setFont:[UIFont systemFontOfSize:12]];
                [crdtSellerLabel setTextAlignment:NSTextAlignmentLeft];
                [self.searchProductSellerView addSubview:crdtSellerLabel];
                
                UIImageView *crdtSellerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_crown.png"]];
                [crdtSellerImgView setFrame:CGRectMake(CGRectGetMinX(crdtSellerLabel.frame)-22, 10, 18, 14)];
                [self.searchProductSellerView addSubview:crdtSellerImgView];
            }
        }
        
        [self.searchProductShadowView setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
        [self.searchProductShadowView setFrame:CGRectMake(0, CGRectGetMaxY(self.searchProductSellerView.frame), kScreenBoundsWidth-20, 1)];
    }
    else {
        [self.searchProductShadowView setFrame:CGRectZero];
    }
}

- (void)setSearchProductGrid:(NSIndexPath *)indexPath
{
    //SearchProductGrid 개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
    CGRect frame = self.frame;
    if ((frame.origin.x+5 >= (kScreenBoundsWidth-[Modules getBestLayoutItemWidth])/2) && (frame.origin.x-5 <= (kScreenBoundsWidth-[Modules getBestLayoutItemWidth])/2)) {
        frame.origin.x = 10;
        self.frame = frame;
    }
    
    //IPAD에서 마지막 셀이 두개일 경우 정렬 필요
    if (IS_IPAD && (frame.origin.x == kScreenBoundsWidth-10-[Modules getBestLayoutItemWidth]) && [self isSearchProductGridCellAlignment:indexPath]) {
        CGFloat cellsSpace = (kScreenBoundsWidth-20-[Modules getBestLayoutItemWidth]*4)/3;
        frame.origin.x = 10+[Modules getBestLayoutItemWidth]+cellsSpace;
        self.frame = frame;
    }
    
    for (UIView *subView in [self.searchProductGridIconView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *searchProductGridItems = self.dicData;
    
    //이미지
    NSString *imgUrl = searchProductGridItems[@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([searchProductGridItems[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchProductGridThumbnailView setFrame:CGRectMake(0, 0, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth])];
        
        [self.searchProductGridAdultView setHidden:NO];
        [self.searchProductGridAdultView setFrame:CGRectMake(0, 0, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth])];
        [self.searchProductGridAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchProductGridAdultView.frame)-72)/2, (CGRectGetHeight(self.searchProductGridAdultView.frame)-72)/2, 72, 72)];
    }
    else {
        [self.searchProductGridAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)[Modules getBestLayoutItemWidth]*2]];
            }
            
            [self.searchProductGridThumbnailView setFrame:CGRectMake(0, 0, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth])];
            [self.searchProductGridThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchProductGridThumbnailView setFrame:CGRectMake(0, 0, [Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth])];
            [self.searchProductGridThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    if ([searchProductGridItems[@"dealPrdYN"] isEqualToString:@"Y"]) {
        [self.searchProductGridShockingDealImageView setFrame:CGRectMake(5, 5, 43, 18)];
        [self.searchProductGridShockingDealImageView setImage:[UIImage imageNamed:@"ic_li_shockingdeal_m.png"]];
    }
    else {
        [self.searchProductGridShockingDealImageView setImage:nil];
    }
    
    //iconView
    if ([searchProductGridItems[@"icons"] count] > 0) {
        
        NSArray *array = searchProductGridItems[@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            //그리드뷰에선 아이콘 MAX 2개.
            if ([array indexOfObject:dic] > 1) {
                break;
            }
            
            UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [iconLabel setBackgroundColor:[UIColor clearColor]];
            [iconLabel setTextAlignment:NSTextAlignmentCenter];
            [iconLabel.layer setBorderWidth:1];
            [self.searchProductGridIconView addSubview:iconLabel];
            
            CGFloat width = 50;
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"100refund"]) {
                //TODO
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"tMember"]) {
                [iconLabel setText:@"T멤버십"];
                [iconLabel setTextColor:UIColorFromRGB(0xff411c)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffaa9e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"mileage"]) {
                [iconLabel setText:@"마일리지"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"myWay"]) {
                width = 78;
                [iconLabel setBackgroundColor:UIColorFromRGB(0xff3b0e)];
                [iconLabel setText:[NSString stringWithFormat:@"내맘대로 %@",[dic objectForKey:@"rate"]]];
                [iconLabel setTextColor:UIColorFromRGB(0xffffff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xff3b0e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"discountCard"]) {
                [iconLabel setText:@"카드할인"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            
            [iconLabel setFrame:CGRectMake(viewWidth, 0, width, 19)];
            viewWidth += width+1;
        }
        
        [self.searchProductGridIconView setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductGridThumbnailView.frame)+10, [Modules getBestLayoutItemWidth]-20, 19)];
    }
    else {
        CGRect frame = self.searchProductGridIconView.frame;
        frame.size.height = 0;
        [self.searchProductGridIconView setFrame:frame];
    }
    
    //상품명
    if ([searchProductGridItems[@"prdNm"] isKindOfClass:[NSString class]] && searchProductGridItems[@"prdNm"]) {
        NSString *str = searchProductGridItems[@"prdNm"];
        [self.searchProductGridLabel setText:str];
        [self.searchProductGridLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductGridThumbnailView.frame)+33, [Modules getBestLayoutItemWidth]-20, 40)];
    }
    else {
        [self.searchProductGridLabel setText:@""];
        [self.searchProductGridLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductGridThumbnailView.frame)+33, [Modules getBestLayoutItemWidth]-20, 40)];
    }
    
    //할인가
    if (searchProductGridItems[@"finalPrc"]) {
        NSString *text = [NSString stringWithFormat:@"%@원", [searchProductGridItems[@"finalPrc"] formatThousandComma]];
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductGridDiscountLabel.frame)) lineBreakMode:self.searchProductGridDiscountLabel.lineBreakMode];
        
        [self.searchProductGridDiscountLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductGridLabel.frame)+3, size.width, 20)];
        [self.searchProductGridDiscountLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }
    
    //실제가격
    if (searchProductGridItems[@"selPrc"] && ![searchProductGridItems[@"selPrc"] isEqualToString:searchProductGridItems[@"finalPrc"]]) {
        NSString *priceString = [NSString stringWithFormat:@"%@원", [searchProductGridItems[@"selPrc"] formatThousandComma]];
        CGSize priceLabelSize = [priceString sizeWithFont:[UIFont systemFontOfSize:13]];
        
        [self.searchProductGridPriceLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductGridDiscountLabel.frame)+2, priceLabelSize.width, 14)];
        [self.searchProductGridPriceLabel setText:priceString];
        
        [self.searchProductGridPriceLineView setFrame:CGRectMake(10, 0, CGRectGetWidth(self.searchProductGridPriceLabel.frame), 1)];
        [self.searchProductGridPriceLineView setCenter:CGPointMake(CGRectGetWidth(self.searchProductGridPriceLabel.frame)/2, CGRectGetHeight(self.searchProductGridPriceLabel.frame)/2)];
    }
    else {
        [self.searchProductGridPriceLabel setText:@""];
        [self.searchProductGridPriceLineView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    //productLink Button
    self.searchProductGridActionView.actionType = CPButtonActionTypeOpenSubview;
    self.searchProductGridActionView.actionItem = searchProductGridItems[@"prdDtlUrl"];
    self.searchProductGridActionView.wiseLogCode = searchProductGridItems[@"clickCd"];
    self.searchProductGridActionView.adClickItems = searchProductGridItems[@"adClickTrcUrl"];
    [self.searchProductGridActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", searchProductGridItems[@"prdNm"], searchProductGridItems[@"finalPrc"]]];
}

- (void)setSearchProductBanner:(NSIndexPath *)indexPath
{
    //SearchProductBanner 개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
    CGRect frame = self.frame;
    if ((frame.origin.x+5 >= (kScreenBoundsWidth-([Modules getBestLayoutItemWidth]+8)*2)/2) && (frame.origin.x-5 <= (kScreenBoundsWidth-([Modules getBestLayoutItemWidth]+8)*2)/2)) {
        frame.origin.x = 10;
        self.frame = frame;
    }
    
    for (UIView *subView in [self.searchProductBannerIconView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [self.searchProductBannerSatisfyView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [self.searchProductBannerSellerView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *searchProductBannerItems = self.dicData;
    BOOL isExpanded = [[self.collectionData.items[indexPath.row] objectForKey:@"isExpanded"] isEqualToString:@"Y"];
    
    NSInteger productWidth = IS_IPAD ? ([Modules getBestLayoutItemWidth]+8)*2 : kScreenBoundsWidth - 20;
    NSInteger productHeight = isExpanded ? 450 : 416;
    if (IS_IPAD) {
        productHeight = 485;
    }
    else if (IS_IPHONE_6) {
        productHeight = isExpanded ? 504 : 470;
    }
    else if (IS_IPHONE_6PLUS) {
        productHeight = isExpanded ? 544 : 510;
    }
    
    [self.searchProductBannerCellContentView setFrame:CGRectMake(0, 5, productWidth, productHeight)];
    
    //이미지
    NSString *imgUrl = searchProductBannerItems[@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([searchProductBannerItems[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchProductBannerThumbnailView setFrame:CGRectMake(0, 0, productWidth, productWidth)];
        
        [self.searchProductBannerAdultView setHidden:NO];
        [self.searchProductBannerAdultView setFrame:CGRectMake(0, 0, productWidth, productWidth)];
        [self.searchProductBannerAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchProductBannerAdultView.frame)-132)/2, (CGRectGetHeight(self.searchProductBannerAdultView.frame)-132)/2, 132, 132)];
    }
    else {
        [self.searchProductBannerAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)productWidth*2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)productWidth*2]];
            }
            
            [self.searchProductBannerThumbnailView setFrame:CGRectMake(0, 0, productWidth, productWidth)];
            [self.searchProductBannerThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchProductBannerThumbnailView setFrame:CGRectMake(0, 0, productWidth, productWidth)];
            [self.searchProductBannerThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    if ([searchProductBannerItems[@"dealPrdYN"] isEqualToString:@"Y"]) {
        [self.searchProductBannerShockingDealImageView setFrame:CGRectMake(5, 5, 52, 21)];
        [self.searchProductBannerShockingDealImageView setImage:[UIImage imageNamed:@"ic_li_shockingdeal_l.png"]];
    }
    else {
        [self.searchProductBannerShockingDealImageView setImage:nil];
    }
    
    BOOL isShowIcon = [searchProductBannerItems[@"icons"] count] > 0;
    
    //iconView
    if (isShowIcon) {
        
        NSArray *array = searchProductBannerItems[@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [iconLabel setBackgroundColor:[UIColor clearColor]];
            [iconLabel setTextAlignment:NSTextAlignmentCenter];
            [iconLabel.layer setBorderWidth:1];
            [self.searchProductBannerIconView addSubview:iconLabel];
            
            CGFloat width = 50;
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"100refund"]) {
                //TODO
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"tMember"]) {
                [iconLabel setText:@"T멤버십"];
                [iconLabel setTextColor:UIColorFromRGB(0xff411c)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffaa9e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"mileage"]) {
                [iconLabel setText:@"마일리지"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"myWay"]) {
                width = 78;
                [iconLabel setBackgroundColor:UIColorFromRGB(0xff3b0e)];
                [iconLabel setText:[NSString stringWithFormat:@"내맘대로 %@",[dic objectForKey:@"rate"]]];
                [iconLabel setTextColor:UIColorFromRGB(0xffffff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xff3b0e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"discountCard"]) {
                [iconLabel setText:@"카드할인"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            
            [iconLabel setFrame:CGRectMake(viewWidth, 0, width, 19)];
            viewWidth += width+1;
        }
        
        [self.searchProductBannerIconView setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductBannerThumbnailView.frame)+10, viewWidth, 19)];
    }
    else {
        CGRect frame = self.searchProductBannerIconView.frame;
        frame.size.height = 0;
        [self.searchProductBannerIconView setFrame:frame];
    }
    
    //상품명
    if (searchProductBannerItems[@"prdNm"]) {
        NSString *str = searchProductBannerItems[@"prdNm"];
        NSInteger index = 0;
        
        for (int i = 0; i < [str length]; i++) {
            CGSize size = [[str substringWithRange:NSMakeRange(0, i)] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductBannerLabel.frame)) lineBreakMode:self.searchProductBannerLabel.lineBreakMode];
            
            if (size.width > 280) {
                break;
            }
            index = i;
        }
        
        [self.searchProductBannerLabel setText:[str substringWithRange:NSMakeRange(0, index)]];
        [self.searchProductBannerLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductBannerThumbnailView.frame)+(isShowIcon?36:15), 280, 18)];
    }
    
    //할인가
    if (searchProductBannerItems[@"finalPrc"]) {
        NSString *text = [NSString stringWithFormat:@"%@원", [searchProductBannerItems[@"finalPrc"] formatThousandComma]];
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductBannerDiscountLabel.frame)) lineBreakMode:self.searchProductBannerDiscountLabel.lineBreakMode];
        
        [self.searchProductBannerDiscountLabel setFrame:CGRectMake(10, CGRectGetMaxY(self.searchProductBannerLabel.frame)+6, size.width, 20)];
        [self.searchProductBannerDiscountLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }
    
    //실제가격
    if (searchProductBannerItems[@"selPrc"] && ![searchProductBannerItems[@"selPrc"] isEqualToString:searchProductBannerItems[@"finalPrc"]]) {
        NSString *priceString = [NSString stringWithFormat:@"%@원", [searchProductBannerItems[@"selPrc"] formatThousandComma]];
        CGSize priceLabelSize = [priceString sizeWithFont:[UIFont systemFontOfSize:13]];
        
        [self.searchProductBannerPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.searchProductBannerDiscountLabel.frame)+3, CGRectGetMinY(self.searchProductBannerDiscountLabel.frame)+4, priceLabelSize.width, 14)];
        [self.searchProductBannerPriceLabel setText:priceString];
        
        [self.searchProductBannerPriceLineView setFrame:CGRectMake(CGRectGetMaxX(self.searchProductBannerDiscountLabel.frame)+3, 0, CGRectGetWidth(self.searchProductBannerPriceLabel.frame), 1)];
        [self.searchProductBannerPriceLineView setCenter:CGPointMake(CGRectGetWidth(self.searchProductBannerPriceLabel.frame)/2, CGRectGetHeight(self.searchProductBannerPriceLabel.frame)/2)];
    }
    else {
        [self.searchProductBannerPriceLabel setText:@""];
        [self.searchProductBannerPriceLineView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    NSInteger satisfyCount = [searchProductBannerItems[@"buySatisfyGrd"] integerValue];
    NSInteger reviewCount = [searchProductBannerItems[@"reviewCount"] integerValue];
    BOOL isShowSatisfy = satisfyCount >= 70 && reviewCount > 0;
    
    //만족도 70%이상 && 리뷰 수 1개이상
    if (isShowSatisfy) {
        [self.searchProductBannerSatisfyView setHidden:NO];
        
        NSInteger satisfyHeight = 416;
        if (IS_IPAD) {
            satisfyHeight = 485;
        }
        else if (IS_IPHONE_6) {
            satisfyHeight = 470;
        }
        else if (IS_IPHONE_6PLUS) {
            satisfyHeight = 510;
        }
        
        
        //SatisfyView
        [self.searchProductBannerSatisfyView setFrame:CGRectMake(10, satisfyHeight-25, 120, 14)];
        
        UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
        NSInteger buySatisfyGrd = [searchProductBannerItems[@"buySatisfyGrd"] integerValue];
        CGFloat viewWidth = 0;
        
        for (int i = 0; i < 5; i++) {
            
            if (i*20 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_off.png"];
            }
            else if (i*20+10 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_half.png"];
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 2, 10, 9)];
            [imgView setImage:image];
            [self.searchProductBannerSatisfyView addSubview:imgView];
            
            viewWidth += 11;
        }
        
        //reviewCount
        if (searchProductBannerItems[@"reviewCount"] && [searchProductBannerItems[@"reviewCount"] integerValue] >= 0) {
            
            NSString *satisfyString = [NSString stringWithFormat:@"(%@)", [searchProductBannerItems[@"reviewCount"] formatThousandComma]];
            CGSize satisfyLabelSize = [satisfyString sizeWithFont:[UIFont systemFontOfSize:13]];
            
            UILabel *satisfyLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth+3, 0, satisfyLabelSize.width, 13)];
            [satisfyLabel setText:satisfyString];
            [satisfyLabel setBackgroundColor:[UIColor clearColor]];
            [satisfyLabel setTextColor:UIColorFromRGB(0x5f5f5f)];
            [satisfyLabel setFont:[UIFont systemFontOfSize:13]];
            [satisfyLabel setTextAlignment:NSTextAlignmentLeft];
            [self.searchProductBannerSatisfyView addSubview:satisfyLabel];
        }
    }
    else {
        [self.searchProductBannerSatisfyView setHidden:YES];
    }
    
    //ActionView
    [self.searchProductBannerActionView setActionType:CPButtonActionTypeOpenSubview];
    [self.searchProductBannerActionView setActionItem:searchProductBannerItems[@"prdDtlUrl"]];
    [self.searchProductBannerActionView setWiseLogCode:searchProductBannerItems[@"clickCd"]];
    [self.searchProductBannerActionView setAdClickItems:searchProductBannerItems[@"adClickTrcUrl"]];
    [self.searchProductBannerActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", searchProductBannerItems[@"prdNm"], searchProductBannerItems[@"finalPrc"]]];
    
    if (!IS_IPAD) {
        NSInteger callButtonHeight = 416;
        if (IS_IPHONE_6) {
            callButtonHeight = 470;
        }
        else if (IS_IPHONE_6PLUS) {
            callButtonHeight = 510;
        }
        
        //ajax call Button
        [self.searchProductBannerUpdownButton setTag:indexPath.row];
        [self.searchProductBannerUpdownButton setFrame:CGRectMake(CGRectGetWidth(self.searchProductBannerCellContentView.frame)-32, callButtonHeight-23, 32, 27)];
        [self.searchProductBannerUpdownButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_li_arrow_%@.png", isExpanded?@"up":@"down"]] forState:UIControlStateNormal];
        [self.searchProductBannerUpdownButton addTarget:self action:@selector(touchSearchProductBannerAjaxCall:) forControlEvents:UIControlEventTouchUpInside];
        
        //sellerView
        if (isExpanded) {
            NSInteger sellerY = callButtonHeight;
            [self.searchProductBannerSellerView setFrame:CGRectMake(0, sellerY, kScreenBoundsWidth-20, 34)];
            
            UIView *searchProductBannerUnderLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 1)];
            [searchProductBannerUnderLineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
            [self.searchProductBannerSellerView addSubview:searchProductBannerUnderLineView];
            
            //seller
            NSString *sellerNm = searchProductBannerItems[@"nckNm"];
            CGSize sellerNmSize = [sellerNm sizeWithFont:[UIFont systemFontOfSize:14]];
            
            UILabel *sellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 15)];
            [sellerLabel setText:searchProductBannerItems[@"nckNm"]];
            [sellerLabel setBackgroundColor:[UIColor clearColor]];
            [sellerLabel setTextColor:UIColorFromRGB(0x666666)];
            [sellerLabel setFont:[UIFont systemFontOfSize:14]];
            [sellerLabel setTextAlignment:NSTextAlignmentLeft];
            [self.searchProductBannerSellerView addSubview:sellerLabel];
            
            //star
            UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
            NSInteger psmGrd = [searchProductBannerItems[@"psmGrd"] integerValue];
            CGFloat viewWidth = sellerNmSize.width < 80 ? sellerNmSize.width+13 : CGRectGetMaxX(sellerLabel.frame)+3;
            
            for (int i = 1; i <= 5; i++) {
                
                if (psmGrd < i) {
                    image = [UIImage imageNamed:@"ic_li_star_off.png"];
                }
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 12, 10, 9)];
                [imgView setImage:image];
                [self.searchProductBannerSellerView addSubview:imgView];
                
                viewWidth += 11;
            }
            
            UIButton *sellerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [sellerButton setTag:indexPath.row];
            [sellerButton setFrame:CGRectMake(CGRectGetMinX(sellerLabel.frame), CGRectGetMinY(sellerLabel.frame), viewWidth-10, 15)];
            [sellerButton setBackgroundColor:[UIColor clearColor]];
            [sellerButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
            [sellerButton setAlpha:0.3];
            [sellerButton addTarget:self action:@selector(touchSearchProductBannerSellerButton:) forControlEvents:UIControlEventTouchUpInside];
            [sellerButton setAccessibilityLabel:@"판매자 정보"];
            [self.searchProductBannerSellerView addSubview:sellerButton];
            
            //crdtSellerYN
            //csSellerYN
            NSInteger viewCount = 0;
            
            if ([searchProductBannerItems[@"crdtSellerYN"] isEqualToString:@"Y"]) {
                viewCount++;
            }
            if ([searchProductBannerItems[@"csSellerYN"] isEqualToString:@"Y"]) {
                viewCount++;
            }
            
            if (viewCount > 0) {
                if (viewCount == 1) {
                    
                    UILabel *firstLabel = [[UILabel alloc] init];
                    [firstLabel setBackgroundColor:[UIColor clearColor]];
                    [firstLabel setTextColor:UIColorFromRGB(0x666666)];
                    [firstLabel setFont:[UIFont systemFontOfSize:12]];
                    [firstLabel setTextAlignment:NSTextAlignmentLeft];
                    [self.searchProductBannerSellerView addSubview:firstLabel];
                    
//                    UIImage *image = [[UIImage alloc] init];
                    UIImageView *imgView = [[UIImageView alloc] init];
                    [self.searchProductBannerSellerView addSubview:imgView];
                    
                    if ([searchProductBannerItems[@"crdtSellerYN"] isEqualToString:@"Y"]) {
                        NSString *crdtSellerStr = @"판매우수";
                        CGSize crdtSellerSize = [crdtSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                        [firstLabel setText:crdtSellerStr];
                        [firstLabel setFrame:CGRectMake(productWidth-crdtSellerSize.width-10, 11, crdtSellerSize.width, 13)];
                        
                        image = [UIImage imageNamed:@"ic_li_crown.png"];
                        [imgView setImage:image];
                        [imgView setFrame:CGRectMake(CGRectGetMinX(firstLabel.frame)-22, 10, 18, 14)];
                    }
                    else if ([searchProductBannerItems[@"csSellerYN"] isEqualToString:@"Y"]) {
                        NSString *csSellerStr = @"고객만족";
                        CGSize csSellerSize = [csSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                        [firstLabel setText:csSellerStr];
                        [firstLabel setFrame:CGRectMake(productWidth-csSellerSize.width-10, 11, csSellerSize.width, 13)];
                        
                        image = [UIImage imageNamed:@"ic_li_diamond.png"];
                        [imgView setImage:image];
                        [imgView setFrame:CGRectMake(CGRectGetMinX(firstLabel.frame)-22, 10, 18, 14)];
                    }
                }
                else if (viewCount == 2) {
                    
                    NSString *crdtSellerStr = @"판매우수";
                    CGSize crdtSellerSize = [crdtSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                    
                    UILabel *crdtSellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(productWidth-crdtSellerSize.width-10, 11, crdtSellerSize.width, 13)];
                    [crdtSellerLabel setBackgroundColor:[UIColor clearColor]];
                    [crdtSellerLabel setText:crdtSellerStr];
                    [crdtSellerLabel setTextColor:UIColorFromRGB(0x666666)];
                    [crdtSellerLabel setFont:[UIFont systemFontOfSize:12]];
                    [crdtSellerLabel setTextAlignment:NSTextAlignmentLeft];
                    [self.searchProductBannerSellerView addSubview:crdtSellerLabel];
                    
                    UIImageView *crdtSellerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_crown.png"]];
                    [crdtSellerImgView setFrame:CGRectMake(CGRectGetMinX(crdtSellerLabel.frame)-22, 10, 18, 14)];
                    [self.searchProductBannerSellerView addSubview:crdtSellerImgView];
                    
                    NSString *csSellerStr = @"고객만족";
                    CGSize csSellerSize = [csSellerStr sizeWithFont:[UIFont systemFontOfSize:12]];
                    
                    UILabel *csSellerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(crdtSellerImgView.frame)-csSellerSize.width-6, 11, csSellerSize.width, 13)];
                    [csSellerLabel setBackgroundColor:[UIColor clearColor]];
                    [csSellerLabel setText:csSellerStr];
                    [csSellerLabel setTextColor:UIColorFromRGB(0x666666)];
                    [csSellerLabel setFont:[UIFont systemFontOfSize:12]];
                    [csSellerLabel setTextAlignment:NSTextAlignmentLeft];
                    [self.searchProductBannerSellerView addSubview:csSellerLabel];
                    
                    UIImageView *csSellerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_diamond.png"]];
                    [csSellerImgView setFrame:CGRectMake(CGRectGetMinX(csSellerLabel.frame)-22, 10, 18, 14)];
                    [self.searchProductBannerSellerView addSubview:csSellerImgView];
                }
            }
            
            [self.searchProductBannerShadowView setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            [self.searchProductBannerShadowView setFrame:CGRectMake(0, CGRectGetMaxY(self.searchProductBannerSellerView.frame), kScreenBoundsWidth-20, 1)];
        }
        else {
            [self.searchProductBannerShadowView setFrame:CGRectZero];
        }
    }
}

- (void)setShockingDealProduct:(NSIndexPath *)indexPath
{
    [self.shockingDealProductRightButton setHidden:[self.dicData[@"items"] count]>1 ? NO : YES];
    [self controlPageSet];
}

- (void)controlPageSet
{
    for (UIView *subView in [self.shockingDealProductPageControlView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *searchCaptionItems = self.dicData[@"items"];
    NSInteger itemCount = [searchCaptionItems count];
    
    UIView *controlView = [[UIView alloc] init];
    [self.shockingDealProductPageControlView addSubview:controlView];
    [self.shockingDealProductView reloadData];
    
    int itemWidth = 0;
    
    for (int i = 0; i < itemCount; i++) {
        
        BOOL isSelected = self.shockingDealProductPageIndex==i;
        
        UIImageView *dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemWidth+2, 0, 10, 10)];
        [dotImageView setImage:[UIImage imageNamed:isSelected?@"ic_s_paging_press.png":@"ic_s_paging_nor.png"]];
        [controlView addSubview:dotImageView];
        
        itemWidth += 16;
    }
    
    [controlView setFrame:CGRectMake((kScreenBoundsWidth-20-itemWidth)/2, (CGRectGetHeight(self.shockingDealProductPageControlView.frame)-10)/2, itemWidth, 10)];
}

- (void)setSearchCaption:(NSIndexPath *)indexPath
{
    NSDictionary *searchCaptionItems = self.dicData;
    
    NSString *adTitle = [searchCaptionItems objectForKey:@"title"];
    CGSize adTitleSize = [adTitle sizeWithFont:[UIFont systemFontOfSize:14]];
    
    [self.searchCaptionTitleLabel setText:adTitle];
    [self.searchCaptionTitleLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.searchCaptionCellContentView.frame)-19, adTitleSize.width, 15)];
    
    [self.searchCaptionMoreLabel setHidden:YES];
    [self.searchCaptionADButton setHidden:YES];
    [self.searchCaptionIconImageView setHidden:YES];
    [self.searchCaptionPageMoveButton setHidden:YES];
    
    if ([searchCaptionItems objectForKey:@"adText"]) {
        [self.searchCaptionADButton setHidden:NO];
        
        [self.searchCaptionADButton setTag:indexPath.row];
        [self.searchCaptionADButton addTarget:self action:@selector(touchSearchCaption:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.searchCaptionADButton setHidden:YES];
    }
    
    if ([searchCaptionItems objectForKey:@"moreUrl"]) {
        [self.searchCaptionMoreLabel setHidden:NO];
        [self.searchCaptionIconImageView setHidden:NO];
        [self.searchCaptionPageMoveButton setHidden:NO];
        
        NSString *moreText = @"더보기";
        CGSize moreTextSize = [moreText sizeWithFont:[UIFont systemFontOfSize:13]];
        
        [self.searchCaptionIconImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchCaptionCellContentView.frame)-10, 13, 6, 11)];
        [self.searchCaptionMoreLabel setFrame:CGRectMake(CGRectGetMaxX(self.searchCaptionCellContentView.frame)-15-moreTextSize.width, 4, moreTextSize.width, CGRectGetHeight(self.searchCaptionCellContentView.frame))];
        [self.searchCaptionMoreLabel setText:moreText];
    }
    else {
        [self.searchCaptionIconImageView setHidden:YES];
        [self.searchCaptionPageMoveButton setHidden:YES];
    }
}

- (void)setRelatedSearchText:(NSIndexPath *)indexPath
{
    NSArray *relatedSearchTextItems = self.collectionData.relatedSearchText[0][@"items"];
    NSDictionary *relatedSearchTextDic = self.collectionData.relatedSearchText[0];
//    NSArray *relatedSearchTextItems = self.dicData[@"items"];
    
    NSInteger itemCount = ceilf([[NSNumber numberWithUnsignedInteger:relatedSearchTextItems.count] floatValue] / 2);
    
    for (UIView *subView in self.relatedKeywordView.subviews) {
        [subView removeFromSuperview];
    }
    
    if ([relatedSearchTextDic[@"isExpanded"] isEqualToString:@"Y"]) {
        
        [self.relatedSearchTextView setFrame:CGRectMake(-10, 0, kScreenBoundsWidth, itemCount*36)];
        [self.relatedKeywordView setFrame:CGRectMake(CGRectGetMaxX(self.relatedIconImageView.frame)+8,
                                                                           0,
                                                                           CGRectGetWidth(self.relatedSearchTextView.frame)-(CGRectGetMaxX(self.relatedIconImageView.frame)+8+45),
                                                                           itemCount*36)];
        [self.relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(self.relatedSearchTextView.frame)-35, CGRectGetHeight(self.relatedSearchTextView.frame)-36, 35, 36)];
        [self.relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_up.png"] forState:UIControlStateNormal];
        
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        CGFloat buttonWidth = CGRectGetWidth(self.relatedKeywordView.frame)/2;
        
        for (NSInteger i = 0; i < relatedSearchTextItems.count; i++) {
            NSString *keyword = relatedSearchTextItems[i][@"text"];
            
            UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [keywordButton setBackgroundColor:[UIColor clearColor]];
            [keywordButton setFrame:CGRectMake(buttonX, buttonY, buttonWidth-5, 36)];
            [keywordButton setTitle:keyword forState:UIControlStateNormal];
            [keywordButton setTitleColor:UIColorFromRGB(0x255b84) forState:UIControlStateNormal];
            [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [keywordButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [keywordButton addTarget:self action:@selector(touchRelatedKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
            [keywordButton setTag:i+RELATED_SEARCH_BUTTON_TAG];
            [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [self.relatedKeywordView addSubview:keywordButton];
            
            buttonX += buttonWidth;
            NSLog(@"%@", NSStringFromCGRect(keywordButton.frame));
            if ((i + 1) % 2 == 0) {
                buttonY += 36;
                buttonX = 0;
            }
        }
    }
    else {
        [self.relatedSearchTextView setFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 36)];
        [self.relatedKeywordView setFrame:CGRectMake(CGRectGetMaxX(self.relatedIconImageView.frame)+8,
                                                                           0,
                                                                           CGRectGetWidth(self.relatedSearchTextView.frame)-(CGRectGetMaxX(self.relatedIconImageView.frame)+8+45),
                                                                           CGRectGetHeight(self.relatedSearchTextView.frame))];
        [self.relatedOpenButton setFrame:CGRectMake(CGRectGetWidth(self.relatedSearchTextView.frame)-35, 0, 35, 36)];
        [self.relatedOpenButton setImage:[UIImage imageNamed:@"bt_s_arrow_down_01.png"] forState:UIControlStateNormal];
        
        CGFloat buttonX = 0;
        NSInteger lastIndex = 0;
        
        for (NSInteger i = 0; i < relatedSearchTextItems.count; i++) {
            NSMutableString *keyword = [[NSMutableString alloc] init];
            [keyword appendString:relatedSearchTextItems[i][@"text"]];
            [keyword appendString:@","];
            
            CGSize labelSize = [keyword sizeWithFont:[UIFont systemFontOfSize:14]];
            
            CGFloat buttonWidth = labelSize.width+5;
            
            UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [keywordButton setBackgroundColor:[UIColor clearColor]];
            [keywordButton setFrame:CGRectMake(buttonX, 0, buttonWidth, CGRectGetHeight(self.relatedKeywordView.frame))];
            [keywordButton setTitleColor:UIColorFromRGB(0x255b84) forState:UIControlStateNormal];
            [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [keywordButton addTarget:self action:@selector(touchRelatedKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
            [keywordButton setTag:i+RELATED_SEARCH_BUTTON_TAG];
            [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [keywordButton setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width+13, 0, 0)];
            
            buttonX += buttonWidth;
            
//            NSLog(@"%@, %@", NSStringFromCGRect(keywordButton.frame), NSStringFromCGRect(self.relatedKeywordView.frame));
//            NSLog(@"%f, %f", CGRectGetMaxX(keywordButton.frame), CGRectGetMinX(self.relatedOpenButton.frame));
            if (CGRectGetMaxX(keywordButton.frame)+25 >= CGRectGetMinX(self.relatedOpenButton.frame)) {
                [self.relatedOpenButton setHidden:NO];
                break;
            }
            else {
                [keywordButton setTitle:keyword forState:UIControlStateNormal];
                [self.relatedKeywordView addSubview:keywordButton];
                [self.relatedOpenButton setHidden:YES];
                lastIndex = i+RELATED_SEARCH_BUTTON_TAG;
            }
        }
        
        NSString *keyword = relatedSearchTextItems[lastIndex-RELATED_SEARCH_BUTTON_TAG][@"text"];
        UIButton *lastKeywordButton = (UIButton *)[self.relatedKeywordView viewWithTag:lastIndex];
        [lastKeywordButton setTitle:keyword forState:UIControlStateNormal];
    }
    
    [self.relatedSearchLineView setFrame:CGRectMake(0, CGRectGetHeight(self.relatedSearchTextView.frame)-1, CGRectGetWidth(self.relatedSearchTextView.frame), 1)];
}

- (void)setRecommendSearchText
{
    NSArray *recommendSearchTextItems = self.dicData[@"items"];
    
    CGFloat buttonX = CGRectGetMaxX(self.recommendIconImageView.frame)+8;
    
    for (NSInteger i = 0; i < recommendSearchTextItems.count; i++) {
        NSString *keyword = recommendSearchTextItems[i][@"text"];
        
        CGSize labelSize = [keyword sizeWithFont:[UIFont systemFontOfSize:14]];
        
        CGFloat buttonWidth = labelSize.width+5;
        
        UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [keywordButton setBackgroundColor:[UIColor clearColor]];
        [keywordButton setFrame:CGRectMake(buttonX, 0, CGRectGetWidth(self.recommendSearchTextView.frame), CGRectGetHeight(self.recommendSearchTextView.frame))];
        [keywordButton setTitle:keyword forState:UIControlStateNormal];
        [keywordButton setTitleColor:UIColorFromRGB(0x7375ca) forState:UIControlStateNormal];
        [keywordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [keywordButton addTarget:self action:@selector(touchRecommendKeywordButton:) forControlEvents:UIControlEventTouchUpInside];
        [keywordButton setTag:i];
        [keywordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.recommendSearchTextView addSubview:keywordButton];
        
        buttonX += buttonWidth;
    }
}

- (void)setSearchFilter
{
    NSArray *filterItems = self.dicData[@"items"];
    
    for (UIView *subView in self.searchFilterView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat filterButtonWidth = kScreenBoundsWidth/filterItems.count;
    
    for (int i = 0; i < filterItems.count; i++) {
        NSDictionary *menu = filterItems[i];
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton setFrame:CGRectMake(filterButtonWidth*i, 0, filterButtonWidth-1, CGRectGetHeight(self.searchFilterView.frame)-1)];
        [filterButton setBackgroundColor:[UIColor clearColor]];
        [filterButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [filterButton setTitleColor:UIColorFromRGB(0x5c5fd5) forState:UIControlStateHighlighted];
        [filterButton setTitleColor:UIColorFromRGB(0x5c5fd5) forState:UIControlStateSelected];
        [filterButton setTitle:menu[@"text"] forState:UIControlStateNormal];
        [filterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [filterButton setTag:i];
        [filterButton setSelected:([menu[@"selected"] isEqualToString:@"Y"] ? YES : NO)];
        [filterButton addTarget:self action:@selector(touchFilterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.searchFilterView addSubview:filterButton];
        
        if (i < filterItems.count - 1) {
            UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(filterButton.frame), 12, 1, 15)];
            [verticalLineView setBackgroundColor:UIColorFromRGB(0xc4c4c5)];
            [self.searchFilterView addSubview:verticalLineView];
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchFilterView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0xd6d7dc)];
    [self.searchFilterView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchFilterView.frame)-1, CGRectGetWidth(self.searchFilterView.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGB(0x9c9eab)];
    [self.searchFilterView addSubview:lineView];
}

- (void)setSearchTopTab
{
    NSArray *tabItems = self.dicData[@"items"];
//    NSArray *tabItems = @[@{@"text":@"전체상품", @"selected":@"Y"}, @{@"text":@"가격비교", @"selected":@"N"}];//self.dicData[@"items"];
    
    for (UIView *subView in self.searchTopTabView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat tabButtonWidth = (kScreenBoundsWidth-20)/tabItems.count;
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, kScreenBoundsWidth-20, 34)];
    [backgroundImageView setImage:[UIImage imageNamed:@"tab_s_filter_bg.png"]];
    [self.searchTopTabView addSubview:backgroundImageView];
    
    for (int i = 0; i < tabItems.count; i++) {
        NSDictionary *menu = tabItems[i];
        
        UIImage *backgroundImageSelected;
        if (i == 0) {
            backgroundImageSelected = [UIImage imageNamed:@"tab_s_filter_left.png"];
        }
        else {
            backgroundImageSelected = [UIImage imageNamed:@"tab_s_filter_right.png"];
        }
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton setFrame:CGRectMake(10+tabButtonWidth*i, 7, tabButtonWidth, 34)];
        [filterButton setBackgroundColor:[UIColor clearColor]];
        [filterButton setBackgroundImage:nil forState:UIControlStateNormal];
        [filterButton setBackgroundImage:backgroundImageSelected forState:UIControlStateSelected];
        [filterButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [filterButton setTitleColor:UIColorFromRGB(0x71759d) forState:UIControlStateNormal];
        [filterButton setTitle:menu[@"text"] forState:UIControlStateNormal];
        [filterButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [filterButton setTag:i];
        [filterButton setSelected:([menu[@"selected"] isEqualToString:@"Y"] ? YES : NO)];
        [self.searchTopTabView addSubview:filterButton];
        
//        if (![menu[@"selected"] isEqualToString:@"Y"]) {
            [filterButton addTarget:self action:@selector(touchTopTabButton:) forControlEvents:UIControlEventTouchUpInside];
//        }
        
//        if (i == 1) {
//            CGSize titleSize = [menu[@"text"] sizeWithFont:[UIFont systemFontOfSize:16]];
//            [filterButton setImage:[UIImage imageNamed:@"ic_s_new.png"] forState:UIControlStateNormal];
//            [filterButton setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width*2.6, 0, 0)];
//            [filterButton setContentEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//        }
    }
}

- (void)setSorting
{
    if (self.dicData[@"productCount"]) {
        NSInteger productCount = [self.dicData[@"productCount"] integerValue];
//        NSString *productCountString = [self.dicData[@"productCount"] stringValue];
        
        NSString *productCountString = [NSNumberFormatter localizedStringFromNumber:@(productCount) numberStyle:NSNumberFormatterDecimalStyle];
        
        CGSize labelSize = [productCountString sizeWithFont:[UIFont systemFontOfSize:16]];
        
        [self.sortingProductTitleLabel setText:self.dicData[@"title"]];
        
        [self.sortingProductCountLabel setText:productCountString];
        [self.sortingProductCountLabel setFrame:CGRectMake(CGRectGetMaxX(self.sortingProductTitleLabel.frame), 2, labelSize.width, CGRectGetHeight(self.sortingView.frame)-6)];
        [self.sortingProductUnitLabel setFrame:CGRectMake(CGRectGetMaxX(self.sortingProductCountLabel.frame), 2, 10, CGRectGetHeight(self.sortingView.frame)-6)];
    }
    
    NSArray *viewItems = self.dicData[@"viewItems"];
    
    if (self.dicData[@"viewItems"] && viewItems.count > 0) {
        
        //프레임을 잡아줌
        [self.sortingViewTypeButton setFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-41, 7, 31, 31)];
        
        for (NSDictionary *viewInfo in viewItems) {
            if ([viewInfo[@"selected"] isEqualToString:@"Y"]) {
                //이미지 url로 바꾸자
//                [self.sortingViewTypeButton setImage:[UIImage imageNamed:@"ic_s_filter_01.png"] forState:UIControlStateNormal];
//                
//                NSString *iconUrl = viewInfo[@"img_ios"];
//                iconUrl = [iconUrl stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
                
                //네이티브에서 처리
                UIImage *image = [[UIImage alloc] init];
                switch ([viewItems indexOfObject:viewInfo]) {
                    case 0:
                        image = [UIImage imageNamed:@"ic_s_filter_01.png"];
                        break;
                    case 1:
                        image = [UIImage imageNamed:@"ic_s_filter_02.png"];
                        break;
                    case 2:
                        image = [UIImage imageNamed:@"ic_s_filter_03.png"];
                        break;
                    default:
                        break;
                }
                
                // icon
                UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.5f, 6, 20, 17)];
                [iconImageView setBackgroundColor:[UIColor clearColor]];
                [iconImageView setUserInteractionEnabled:NO];
                [iconImageView setImage:image];
                [self.sortingViewTypeButton addSubview:iconImageView];
                
//                if ([iconUrl length] > 0) {
//                    [iconImageView.imageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
//                }
            }
        }
    }
    
    NSArray *sortItems = self.dicData[@"sortItems"];
    
    if (self.dicData[@"sortItems"] && sortItems.count > 0) {
        
        //프레임을 잡아줌
        if (viewItems.count > 0) {
            [self.sortingSortTypeButton setFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-(41+6+112), 7, 112, 31)];
        }
        else {
            [self.sortingSortTypeButton setFrame:CGRectMake(CGRectGetWidth(self.sortingView.frame)-(10+112), 7, 112, 31)];
        }
        [self.sortingArrowImageView setFrame:CGRectMake(CGRectGetWidth(self.sortingSortTypeButton.frame)-19, 12.5f, 11, 6)];
        
        for (NSDictionary *sortInfo in sortItems) {
            if ([sortInfo[@"selected"] isEqualToString:@"Y"]) {
                //이미지 url로 바꾸자
                [self.sortingSortTypeButton setTitle:sortInfo[@"text"] forState:UIControlStateNormal];
            }
        }
    }
    
}

- (void)setCategoryNavi
{
    NSArray *categorNaviItems = self.dicData[@"items"];
    
    CGFloat cellWidtgh = CGRectGetWidth(self.frame);
    NSInteger viewSizeWidth = 5;
    NSInteger lineCount = 1;
    
    for (NSDictionary *dic in categorNaviItems) {
        
        CGSize buttonLabelSize = [[dic objectForKey:@"dispCtgrNm"] sizeWithFont:[UIFont systemFontOfSize:14]];
        
        //버튼
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(viewSizeWidth, 4+(lineCount-1)*31, buttonLabelSize.width+20, 23)];
        [button setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xededf2)] forState:UIControlStateHighlighted];
        [button setTitle:[dic objectForKey:@"dispCtgrNm"] forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button addTarget:self action:@selector(touchCategoryNaviButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:[categorNaviItems indexOfObject:dic]];
        [self.categoryNaviView addSubview:button];
        
        viewSizeWidth += button.frame.size.width;
        if (viewSizeWidth >= cellWidtgh) {
            viewSizeWidth = 5;
            lineCount++;
            
            [button setFrame:CGRectMake(viewSizeWidth, 4+(lineCount-1)*31, buttonLabelSize.width+20, 23)];
            viewSizeWidth += button.frame.size.width;
        }
        
        //마지막
        if ([dic isEqualToDictionary:[categorNaviItems lastObject]]) {
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            break;
        }
        
        //arrow
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewSizeWidth, 11+(lineCount-1)*31, 6, 10)];
        [arrowImageView setImage:[UIImage imageNamed:@"ic_s_arrow_right.png"]];
        [self.categoryNaviView addSubview:arrowImageView];
        
        viewSizeWidth += arrowImageView.frame.size.width;
        if (viewSizeWidth >= cellWidtgh) {
            viewSizeWidth = 15;
            lineCount++;
            
            [arrowImageView setFrame:CGRectMake(viewSizeWidth, 11+(lineCount-1)*31, 6, 10)];
            viewSizeWidth += arrowImageView.frame.size.width;
        }
    }
    
    [self.categoryNaviBackgroundView setFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 30+(lineCount-1)*31)];
    [self.categoryNaviView setFrame:CGRectMake(-10, 0, kScreenBoundsWidth, 30+(lineCount-1)*31)];
}

- (void)setSearchMore:(NSIndexPath *)indexPath
{
    NSString *text = self.dicData[@"text"];
    CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:15]];
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView setUserInteractionEnabled:NO];
    [self.searchMoreButton addSubview:contentView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, CGRectGetHeight(self.searchMoreButton.frame))];
    [textLabel setText:text];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextColor:UIColorFromRGB(0x301a93)];
    [textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [contentView addSubview:textLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textLabel.frame)+5, (CGRectGetHeight(self.searchMoreButton.frame)-8)/2, 13, 8)];
    [imageView setImage:[UIImage imageNamed:@"bt_s_arrow_down_03.png"]];
    [contentView addSubview:imageView];
    
    [contentView setFrame:CGRectMake((CGRectGetWidth(self.searchMoreButton.frame)-CGRectGetMaxX(imageView.frame))/2, 0, CGRectGetMaxX(imageView.frame), CGRectGetHeight(self.searchMoreButton.frame))];
}

- (void)setModelSearchProduct:(NSIndexPath *)indexPath
{
    for (UIView *subView in [self.modelSearchProductSatisfyView subviews]) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in [self.modelSearchProductPriceCompareImageView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *modelSearchProductItems = self.dicData;
    
    //이미지
    NSString *imgUrl = modelSearchProductItems[@"imgUrl"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([modelSearchProductItems[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.modelSearchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
        
        [self.modelSearchProductAdultView setHidden:NO];
        [self.modelSearchProductAdultView setFrame:CGRectMake(0, 0, 120, 120)];
        [self.modelSearchProductAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.modelSearchProductAdultView.frame)-60)/2, (CGRectGetHeight(self.modelSearchProductAdultView.frame)-60)/2, 60, 60)];
    }
    else {
        [self.modelSearchProductAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            
            [self.modelSearchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
            [self.modelSearchProductThumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.modelSearchProductThumbnailView setFrame:CGRectMake(10, 10, 120, 120)];
            [self.modelSearchProductThumbnailView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    if ([modelSearchProductItems[@"dealPrdYN"] isEqualToString:@"Y"]) {
        [self.modelSearchProductShockingDealImageView setFrame:CGRectMake(5, 5, 37, 15)];
        [self.modelSearchProductShockingDealImageView setImage:[UIImage imageNamed:@"ic_li_shockingdeal_s.png"]];
    }
    else {
        [self.modelSearchProductShockingDealImageView setImage:nil];
    }
    
    //상품명
    if (modelSearchProductItems[@"modelNm"]) {
        NSString *str = modelSearchProductItems[@"modelNm"];

        [self.modelSearchProductLabel setText:str];
        [self.modelSearchProductLabel setFrame:CGRectMake(CGRectGetMaxX(self.modelSearchProductThumbnailView.frame)+10, 18, 150, 40)];
    }
    
    //할인가
    if (modelSearchProductItems[@"minPrice"]) {
        NSString *text = [NSString stringWithFormat:@"%@원~", [modelSearchProductItems[@"minPrice"] formatThousandComma]];
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(self.searchProductDiscountLabel.frame)) lineBreakMode:self.searchProductDiscountLabel.lineBreakMode];
        
        [self.modelSearchProductDiscountLabel setFrame:CGRectMake(CGRectGetMaxX(self.modelSearchProductThumbnailView.frame)+10, CGRectGetMaxY(self.modelSearchProductLabel.frame)+6, size.width, 20)];
        [self.modelSearchProductDiscountLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원~"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }
    
    NSString *compareStr = @"가격비교";
    CGSize compareSize = [compareStr sizeWithFont:[UIFont systemFontOfSize:12]];
    
    UILabel *compareLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, compareSize.width, 24)];
    [compareLabel setBackgroundColor:[UIColor clearColor]];
    [compareLabel setText:compareStr];
    [compareLabel setFont:[UIFont systemFontOfSize:12]];
    [compareLabel setTextColor:UIColorFromRGB(0x5d5d73)];
    [compareLabel setTextAlignment:NSTextAlignmentCenter];
    [self.modelSearchProductPriceCompareImageView addSubview:compareLabel];
    
    NSString * compareCountStr = modelSearchProductItems[@"prdCount"];
    NSInteger compareCount = [modelSearchProductItems[@"prdCount"] integerValue];
    if (compareCount > 999) {
        compareCountStr = @"999+";
    }
    
    CGSize compareCountSize = [compareCountStr sizeWithFont:[UIFont systemFontOfSize:13]];
    
    UILabel *compareCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(compareLabel.frame)+3, 0, compareCountSize.width, 24)];
    [compareCountLabel setBackgroundColor:[UIColor clearColor]];
    [compareCountLabel setText:compareCountStr];
    [compareCountLabel setFont:[UIFont systemFontOfSize:13]];
    [compareCountLabel setTextColor:UIColorFromRGB(0x3f3f5f)];
    [compareCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.modelSearchProductPriceCompareImageView addSubview:compareCountLabel];
    
    UIImageView *compareArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(compareCountLabel.frame)+4, 7, 6, 10)];
    [compareArrowView setImage:[UIImage imageNamed:@"bt_s_arrow_right_02.png"]];
    [self.modelSearchProductPriceCompareImageView addSubview:compareArrowView];
    
    CGFloat priceCompareViewWidth = CGRectGetMaxX(compareArrowView.frame)+4;
    
    [self.modelSearchProductPriceCompareImageView setFrame:CGRectMake(CGRectGetWidth(self.modelSearchProductCellContentView.frame)-priceCompareViewWidth-10, CGRectGetMaxY(self.modelSearchProductCellContentView.frame)-39, priceCompareViewWidth, 24)];
    
    
    
    NSInteger satisfyCount = [modelSearchProductItems[@"satisfyStar"] integerValue];
    NSInteger reviewCount = [modelSearchProductItems[@"buyerCommentSum"] integerValue];
    
    //만족도 70%이상 && 리뷰 수 1개이상
    if (satisfyCount >= 70 && reviewCount > 0) {
        [self.modelSearchProductSatisfyView setHidden:NO];
        
    
        //SatisfyView
        UIImage *image = [UIImage imageNamed:@"ic_li_star_on.png"];
        NSInteger buySatisfyGrd = [modelSearchProductItems[@"satisfyStar"] integerValue];
        CGFloat viewWidth = 0;
        
        for (int i = 0; i < 5; i++) {
            
            if (i*20 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_off.png"];
            }
            else if (i*20+10 == buySatisfyGrd) {
                image = [UIImage imageNamed:@"ic_li_star_half.png"];
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 2, 10, 9)];
            [imgView setImage:image];
            [self.modelSearchProductSatisfyView addSubview:imgView];
            
            viewWidth += 11;
        }
        
        //reviewCount
        if (modelSearchProductItems[@"buyerCommentSum"] && [modelSearchProductItems[@"buyerCommentSum"] integerValue] >= 0) {
            
            NSString *satisfyString = [NSString stringWithFormat:@"(%@)", [modelSearchProductItems[@"buyerCommentSum"] formatThousandComma]];
            CGSize satisfyLabelSize = [satisfyString sizeWithFont:[UIFont systemFontOfSize:13]];
            CGFloat space = CGRectGetMinX(self.self.modelSearchProductPriceCompareImageView.frame) - (CGRectGetMaxX(self.modelSearchProductThumbnailView.frame)+10) - (viewWidth+2);
            
            UILabel *satisfyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, satisfyLabelSize.width, 13)];
            [satisfyLabel setText:satisfyString];
            [satisfyLabel setBackgroundColor:[UIColor clearColor]];
            [satisfyLabel setTextColor:UIColorFromRGB(0x5f5f5f)];
            [satisfyLabel setFont:[UIFont systemFontOfSize:13]];
            [satisfyLabel setTextAlignment:NSTextAlignmentLeft];
            [self.modelSearchProductSatisfyView addSubview:satisfyLabel];
            
            //별점과 가겨비교 버튼 사이의 간격에 따라 라벨이 밑으로 내려감
            if (space > satisfyLabelSize.width) {
                [satisfyLabel setFrame:CGRectMake(viewWidth+2, 0, satisfyLabelSize.width, 13)];
            }
        }
        
        [self.modelSearchProductSatisfyView setFrame:CGRectMake(CGRectGetMaxX(self.modelSearchProductThumbnailView.frame)+10, 105, viewWidth, 27)];
    }
    else {
        [self.modelSearchProductSatisfyView setHidden:YES];
    }

    NSString *modelNo = self.dicData[@"modelNo"];
    NSString *keyword = @"";
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSearchKeywordFromCommonCellSuperView)]) {
        keyword = [self.delegate getSearchKeywordFromCommonCellSuperView];
    }
    
    NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
    [actionDict setValue:keyword forKey:@"keyword"];
    [actionDict setValue:modelNo forKey:@"modelNo"];
    
    self.modelSearchProductActionView.actionType = CPButtonActionTypeGoModelSearchProduct;
    self.modelSearchProductActionView.actionItem = actionDict;
    [self.modelSearchProductActionView setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", modelSearchProductItems[@"prdNm"], modelSearchProductItems[@"finalPrc"]]];
}

- (void)setNoSearchData
{
    for (UIView *subView in [self.noSearchDataView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *noSearchDataItem = self.dicData;
    
    [self.noSearchDataCellContentView setFrame:CGRectMake(0, 5, kScreenBoundsWidth-20, [noSearchDataItem objectForKey:@"recommendKeyword"] ? 295 : 235)];
    [self.noSearchDataImageView setFrame:CGRectMake((CGRectGetWidth(self.noSearchDataCellContentView.frame)-35)/2, 30, 35, 35)];
    [self.noSearchDataImageView setImage:[UIImage imageNamed:@"ic_s_notice.png"]];
    
    
    [self.noSearchDataView setFrame:CGRectMake(0, CGRectGetMaxY(self.noSearchDataImageView.frame)+15, kScreenBoundsWidth-20, 195)];
    
    UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.noSearchDataView.frame), 19)];
    [noResultLabel setBackgroundColor:[UIColor clearColor]];
    [noResultLabel setFont:[UIFont systemFontOfSize:18]];
    [noResultLabel setText:@"검색 결과가 없습니다."];
    [noResultLabel setTextColor:UIColorFromRGB(0x5d5d73)];
    [noResultLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noSearchDataView addSubview:noResultLabel];
    
    CGFloat viewMaxY = CGRectGetMaxY(noResultLabel.frame);
    
    if ([noSearchDataItem objectForKey:@"recommendKeyword"]) {
        
        NSString *questionText = [NSString stringWithFormat:@"찾고 계신 검색어가 '%@'입니까?", [noSearchDataItem objectForKey:@"recommendKeyword"]];
        
        TTTAttributedLabel *questionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, viewMaxY+15, CGRectGetWidth(self.noSearchDataView.frame), 15)];
        [questionLabel setBackgroundColor:[UIColor clearColor]];
        [questionLabel setTextColor:UIColorFromRGB(0x868ba8)];
        [questionLabel setFont:[UIFont systemFontOfSize:14]];
        [questionLabel setTextAlignment:NSTextAlignmentCenter];
        [questionLabel setText:questionText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [questionText rangeOfString:[noSearchDataItem objectForKey:@"recommendKeyword"]];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont boldSystemFontOfSize:14] range:colorRange];
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[UIColorFromRGB(0xf62d3d) CGColor] range:colorRange];
            }
            return mutableAttributedString;
        }];
        [self.noSearchDataView addSubview:questionLabel];
        
        viewMaxY += CGRectGetHeight(questionLabel.frame)+15;
        
        NSString *linkText = [NSString stringWithFormat:@"%@ 검색결과 더보기", [noSearchDataItem objectForKey:@"recommendKeyword"]];
        CGSize linkTextSize = [linkText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
        
        TTTAttributedLabel *linkLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.noSearchDataView.frame)-linkTextSize.width)/2, viewMaxY+15, linkTextSize.width, 16)];
        [linkLabel setDelegate:self];
        [linkLabel setBackgroundColor:[UIColor clearColor]];
        [linkLabel setTextColor:UIColorFromRGB(0x5c5fd5)];
        [linkLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [linkLabel setTextAlignment:NSTextAlignmentCenter];
        [linkLabel setText:linkText];
        [linkLabel addLinkToURL:[noSearchDataItem objectForKey:@"recommendKeyword"] withRange:[linkLabel.text rangeOfString:linkText]];
        [self.noSearchDataView addSubview:linkLabel];
        
        viewMaxY += CGRectGetHeight(linkLabel.frame)+15;
    }
    
    UILabel *noDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewMaxY+23, CGRectGetWidth(self.noSearchDataView.frame), 66)];
    [noDescLabel setBackgroundColor:[UIColor clearColor]];
    [noDescLabel setFont:[UIFont systemFontOfSize:13]];
    [noDescLabel setText:@"단어의 철자의 정확한지 확인해 주세요.\n검색어의 단어 수를 줄이거나,\n다른 검색어로 검색해 보세요.\n보다 일반적인 검색어로 다시 검색해 보세요."];
    [noDescLabel setTextColor:UIColorFromRGB(0x868ba8)];
    [noDescLabel setTextAlignment:NSTextAlignmentCenter];
    [noDescLabel setNumberOfLines:0];
    [self.noSearchDataView addSubview:noDescLabel];
}

- (void)setSearchHotProduct
{
    for (UIView *subView in [self.searchHotProductFirstIconView subviews]) {
        [subView removeFromSuperview];
    }
    
    NSDictionary *noSearchHotProduct = self.dicData;
    [self.searchHotProductFirstBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", noSearchHotProduct[@"items"][0][@"prdNm"], noSearchHotProduct[@"items"][0][@"finalPrc"]]];
    [self.searchHotProductSecondBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", noSearchHotProduct[@"items"][1][@"prdNm"], noSearchHotProduct[@"items"][1][@"finalPrc"]]];
    [self.searchHotProductThirdBlankButton setAccessibilityLabel:[NSString stringWithFormat:@"상품명:%@ 할인가:%@원", noSearchHotProduct[@"items"][2][@"prdNm"], noSearchHotProduct[@"items"][2][@"finalPrc"]]];
    
    NSString *imgUrl = noSearchHotProduct[@"items"][0][@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([noSearchHotProduct[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchHotProductFirstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
        
        [self.searchHotProductFirstAdultView setHidden:NO];
        [self.searchHotProductFirstAdultView setFrame:CGRectMake(0, 0, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
        [self.searchHotProductFirstAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchHotProductFirstAdultView.frame)-132)/2, (CGRectGetHeight(self.searchHotProductFirstAdultView.frame)-132)/2, 132, 132)];
    }
    else {
        [self.searchHotProductFirstAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)]];
            }
            
            [self.searchHotProductFirstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
            [self.searchHotProductFirstImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchHotProductFirstImageView setFrame:CGRectMake((kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/1.621, (kScreenBoundsWidth-20)/1.621)];
            [self.searchHotProductFirstImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    [self.searchHotProductFirstGradationImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductFirstImageView.frame), CGRectGetHeight(self.searchHotProductFirstImageView.frame))];
    [self.searchHotProductFirstGradationImageView setImage:[UIImage imageNamed:@"bg_li_hot_b.png"]];
    
    //iconView
    if ([noSearchHotProduct[@"items"][0][@"icons"] count] > 0) {
        
        NSArray *array = noSearchHotProduct[@"items"][0][@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                
                UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
                [iconLabel setBackgroundColor:[UIColor whiteColor]];
                [iconLabel setTextAlignment:NSTextAlignmentCenter];
                [iconLabel.layer setBorderWidth:1];
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
                [iconLabel setFrame:CGRectMake(viewWidth, 0, 50, 19)];
                [self.searchHotProductFirstIconView addSubview:iconLabel];
                
                viewWidth = 50;
                break;
            }
        }
        
        [self.searchHotProductFirstIconView setFrame:CGRectMake(10, CGRectGetHeight(self.searchHotProductFirstIconView.frame)-56, viewWidth, 19)];
    }
    
    NSString *firstText = [NSString stringWithFormat:@"%@원", [noSearchHotProduct[@"items"][0][@"finalPrc"] formatThousandComma]];
    CGSize firstTextSize = [firstText sizeWithFont:[UIFont boldSystemFontOfSize:18]];
    
    [self.searchHotProductFirstPriceLabel setFrame:CGRectMake(10, CGRectGetHeight(self.searchHotProductFirstImageView.frame)-32, firstTextSize.width, 20)];
    [self.searchHotProductFirstPriceLabel setText:firstText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [firstText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:13] range:colorRange];
        }
        return mutableAttributedString;
    }];
    
    [self.searchHotProductFirstBlankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductFirstImageView.frame), CGRectGetHeight(self.searchHotProductFirstImageView.frame))];
    
    
    imgUrl = noSearchHotProduct[@"items"][1][@"img1"];
    imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([noSearchHotProduct[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchHotProductSecondImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        
        [self.searchHotProductSecondAdultView setHidden:NO];
        [self.searchHotProductSecondAdultView setFrame:CGRectMake(0, 0, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        [self.searchHotProductSecondAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchHotProductSecondAdultView.frame)-60)/2, (CGRectGetHeight(self.searchHotProductSecondAdultView.frame)-60)/2, 60, 60)];
    }
    else {
        [self.searchHotProductSecondAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            
            [self.searchHotProductSecondImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [self.searchHotProductSecondImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchHotProductSecondImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/30, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [self.searchHotProductSecondImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    [self.searchHotProductSecondGradationImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductSecondImageView.frame), CGRectGetHeight(self.searchHotProductSecondImageView.frame))];
    [self.searchHotProductSecondGradationImageView setImage:[UIImage imageNamed:@"bg_li_hot_s.png"]];
    
    NSString *secondText = [NSString stringWithFormat:@"%@원", [noSearchHotProduct[@"items"][1][@"finalPrc"] formatThousandComma]];
    CGSize secondTextSize = [secondText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
    
    [self.searchHotProductSecondPriceLabel setFrame:CGRectMake(10, CGRectGetHeight(self.searchHotProductSecondImageView.frame)-24, secondTextSize.width, 20)];
    [self.searchHotProductSecondPriceLabel setText:secondText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [secondText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:11] range:colorRange];
        }
        return mutableAttributedString;
    }];
    
    [self.searchHotProductSecondBlankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductFirstImageView.frame), CGRectGetHeight(self.searchHotProductFirstImageView.frame))];
    
    
    imgUrl = noSearchHotProduct[@"items"][2][@"img1"];
    imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([noSearchHotProduct[@"adultProduct"] isEqualToString:@"Y"]) {
        [self.searchHotProductThirdImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(self.searchHotProductSecondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        
        [self.searchHotProductThirdAdultView setHidden:NO];
        [self.searchHotProductThirdAdultView setFrame:CGRectMake(0, 0, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
        [self.searchHotProductThirdAdultImageView setFrame:CGRectMake((CGRectGetWidth(self.searchHotProductThirdAdultView.frame)-60)/2, (CGRectGetHeight(self.searchHotProductThirdAdultView.frame)-60)/2, 60, 60)];
    }
    else {
        [self.searchHotProductThirdAdultView setHidden:YES];
        
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", (int)(kScreenBoundsWidth-20)/2]];
            }
            
            [self.searchHotProductThirdImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(self.searchHotProductSecondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [self.searchHotProductThirdImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [self.searchHotProductThirdImageView setFrame:CGRectMake(CGRectGetMaxX(self.searchHotProductFirstImageView.frame)+(kScreenBoundsWidth-20)/60, CGRectGetMaxY(self.searchHotProductSecondImageView.frame)+(kScreenBoundsWidth-20)/60, (kScreenBoundsWidth-20)/3.33, (kScreenBoundsWidth-20)/3.33)];
            [self.searchHotProductThirdImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    [self.searchHotProductThirdGradationImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductThirdImageView.frame), CGRectGetHeight(self.searchHotProductThirdImageView.frame))];
    [self.searchHotProductThirdGradationImageView setImage:[UIImage imageNamed:@"bg_li_hot_s.png"]];
    
    NSString *thirdText = [NSString stringWithFormat:@"%@원", [noSearchHotProduct[@"items"][2][@"finalPrc"] formatThousandComma]];
    CGSize thirdTextSize = [thirdText sizeWithFont:[UIFont boldSystemFontOfSize:15]];
    
    
    [self.searchHotProductThirdPriceLabel setFrame:CGRectMake(10, CGRectGetHeight(self.searchHotProductThirdImageView.frame)-24, thirdTextSize.width, 20)];
    [self.searchHotProductThirdPriceLabel setText:thirdText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
        NSRange colorRange = [thirdText rangeOfString:@"원"];
        if (colorRange.location != NSNotFound)
        {
            [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:11] range:colorRange];
        }
        return mutableAttributedString;
    }];
    
    [self.searchHotProductThirdBlankButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.searchHotProductFirstImageView.frame), CGRectGetHeight(self.searchHotProductFirstImageView.frame))];
}

- (void)setTworldDirect:(NSIndexPath *)indexPath
{
    for (UIView *subview in self.tWorldDirectCellContentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    //tWorld Line
    UIView *tWorldLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tWorldDirectCellContentView.frame.size.width, 34)];
    tWorldLineView.backgroundColor = UIColorFromRGB(0x282D2E);
    [self.tWorldDirectCellContentView addSubview:tWorldLineView];
    
    UIImage *tWorldLineImage = [UIImage imageNamed:@"T_world_direct_title_img.png"];
    UIImageView *tWorldLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake((tWorldLineView.frame.size.width/2)-(tWorldLineImage.size.width/2),
                                                                                     (tWorldLineView.frame.size.height/2)-(tWorldLineImage.size.height/2),
                                                                                     tWorldLineImage.size.width,
                                                                                     tWorldLineImage.size.height)];
    tWorldLineImageView.image = tWorldLineImage;
    [tWorldLineView addSubview:tWorldLineImageView];
    
    
    NSDictionary *item = self.dicData[@"tworldDirect"];
    
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tWorldLineView.frame),
                                                                    self.tWorldDirectCellContentView.frame.size.width,
                                                                    self.tWorldDirectCellContentView.frame.size.height-CGRectGetMaxY(tWorldLineView.frame))];
    contentsView.backgroundColor = UIColorFromRGB(0xffffff);
    [self.tWorldDirectCellContentView addSubview:contentsView];
    
    //Banner Image
    CPThumbnailView *bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
    [bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:item[@"imageUrl"]] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
    [contentsView addSubview:bannerImageView];

    //telecomIcon
    UILabel *telecomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    telecomLabel.backgroundColor = [UIColor clearColor];
    telecomLabel.textColor = UIColorFromRGB(0xff5f2e);
    telecomLabel.font = [UIFont boldSystemFontOfSize:12];
    telecomLabel.text = item[@"iconName"];
    [telecomLabel sizeToFitWithFloor];
    
    UIView *telecomIconView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bannerImageView.frame)+10, 12,
                                                                       telecomLabel.frame.size.width+6, 19)];
    telecomIconView.layer.borderWidth = 1;
    telecomIconView.layer.borderColor = UIColorFromRGB(0xfeaa9f).CGColor;
    [contentsView addSubview:telecomIconView];
    
    [telecomIconView addSubview:telecomLabel];
    telecomLabel.frame = CGRectMake((telecomIconView.frame.size.width/2)-(telecomLabel.frame.size.width/2),
                                    (telecomIconView.frame.size.height/2)-(telecomLabel.frame.size.height/2),
                                    telecomLabel.frame.size.width, telecomLabel.frame.size.height);
    
    //product Name
    UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bannerImageView.frame)+10, CGRectGetMaxY(telecomIconView.frame)+6,
                                                                          contentsView.frame.size.width-(CGRectGetMaxX(bannerImageView.frame)+20),
                                                                          0)];
    productNameLabel.backgroundColor = [UIColor clearColor];
    productNameLabel.textColor = UIColorFromRGB(0x2d2d2d);
    productNameLabel.font = [UIFont systemFontOfSize:16];
    productNameLabel.numberOfLines = 2;
    productNameLabel.textAlignment = NSTextAlignmentLeft;
    productNameLabel.text = item[@"phoneName"];
    [productNameLabel sizeToFitWithVersionHoldWidth];
    [contentsView addSubview:productNameLabel];
    
    //price
    NSInteger priceNum = [item[@"phonePrice"] integerValue];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bannerImageView.frame)+10,
                                                                    CGRectGetMaxY(productNameLabel.frame)+3,
                                                                    0, 0)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.textColor = UIColorFromRGB(0x333333);
    priceLabel.font = [UIFont boldSystemFontOfSize:17];
    priceLabel.numberOfLines = 1;
    priceLabel.textAlignment = NSTextAlignmentLeft;
    priceLabel.text = [Modules numberFormat:priceNum];
    [priceLabel sizeToFitWithVersion];
    [contentsView addSubview:priceLabel];

    UILabel *priceWonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    priceWonLabel.backgroundColor = [UIColor clearColor];
    priceWonLabel.textColor = UIColorFromRGB(0x333333);
    priceWonLabel.font = [UIFont systemFontOfSize:11];
    priceWonLabel.numberOfLines = 1;
    priceWonLabel.textAlignment = NSTextAlignmentLeft;
    priceWonLabel.text = @"원~/월";
    [priceWonLabel sizeToFitWithVersion];
    [contentsView addSubview:priceWonLabel];

    priceWonLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame), priceLabel.frame.origin.y+5,
                                     priceWonLabel.frame.size.width, priceWonLabel.frame.size.height);
    
    // 특전1
    UILabel *benefitTitle01 = [[UILabel alloc] initWithFrame:CGRectZero];
    benefitTitle01.backgroundColor = [UIColor clearColor];
    benefitTitle01.textColor = UIColorFromRGB(0xff5f2e);
    benefitTitle01.font = [UIFont systemFontOfSize:11];
    benefitTitle01.numberOfLines = 1;
    benefitTitle01.textAlignment = NSTextAlignmentLeft;
    benefitTitle01.text = item[@"benefit"][@"title1"];
    [benefitTitle01 sizeToFitWithVersion];
    [contentsView addSubview:benefitTitle01];
    
    benefitTitle01.frame = CGRectMake(CGRectGetMaxX(bannerImageView.frame)+10, 101, benefitTitle01.frame.size.width, benefitTitle01.frame.size.height);
    
    UILabel *benefitText01 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(benefitTitle01.frame)+1, benefitTitle01.frame.origin.y,
                                                                       contentsView.frame.size.width-(CGRectGetMaxX(benefitTitle01.frame)+11),
                                                                       benefitTitle01.frame.size.height)];
    benefitText01.backgroundColor = [UIColor clearColor];
    benefitText01.textColor = UIColorFromRGB(0x666666);
    benefitText01.font = [UIFont systemFontOfSize:11];
    benefitText01.numberOfLines = 1;
    benefitText01.textAlignment = NSTextAlignmentLeft;
    benefitText01.text = item[@"benefit"][@"content1"];
    [contentsView addSubview:benefitText01];
    
    // 특전2
    UILabel *benefitTitle02 = [[UILabel alloc] initWithFrame:CGRectZero];
    benefitTitle02.backgroundColor = [UIColor clearColor];
    benefitTitle02.textColor = UIColorFromRGB(0xff5f2e);
    benefitTitle02.font = [UIFont systemFontOfSize:11];
    benefitTitle02.numberOfLines = 1;
    benefitTitle02.textAlignment = NSTextAlignmentLeft;
    benefitTitle02.text = item[@"benefit"][@"title2"];
    [benefitTitle02 sizeToFitWithVersion];
    [contentsView addSubview:benefitTitle02];

    benefitTitle02.frame = CGRectMake(benefitTitle01.frame.origin.x, CGRectGetMaxY(benefitTitle01.frame)+1,
                                      benefitTitle02.frame.size.width, benefitTitle02.frame.size.height);
    
    UILabel *benefitText02 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(benefitTitle02.frame)+1, benefitTitle02.frame.origin.y,
                                                                       contentsView.frame.size.width-(CGRectGetMaxX(benefitTitle02.frame)+11),
                                                                       benefitTitle02.frame.size.height)];
    benefitText02.backgroundColor = [UIColor clearColor];
    benefitText02.textColor = UIColorFromRGB(0x666666);
    benefitText02.font = [UIFont systemFontOfSize:11];
    benefitText02.numberOfLines = 1;
    benefitText02.textAlignment = NSTextAlignmentLeft;
    benefitText02.text = item[@"benefit"][@"content2"];
    [contentsView addSubview:benefitText02];

    //underLine
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, contentsView.frame.size.height-1, contentsView.frame.size.width, 1)];
    underLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
    [contentsView addSubview:underLine];

    //touchView
    CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:contentsView.bounds];
    actionView.actionType = CPButtonActionTypeOpenSubview;
    actionView.actionItem = item[@"linkUrl"];
    actionView.wiseLogCode = item[@"clickCd"];
    [contentsView addSubview:actionView];
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

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.dicData[@"items"] count];
}

#pragma mark - iCarouselDelegate

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, 140)];
    
    NSDictionary *dicItems = self.dicData[@"items"][index];
    
    //이미지
    CPThumbnailView *thumbnailImageView = [[CPThumbnailView alloc] init];
    [view addSubview:thumbnailImageView];
    
    //이미지
    NSString *imgUrl = dicItems[@"img1"];
    NSString *imgBase = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
    
    if ([dicItems[@"adultProduct"] isEqualToString:@"Y"]) {
        [thumbnailImageView setFrame:CGRectMake(10, 10, 120, 120)];
        
        UIView *adultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        [adultView setBackgroundColor:UIColorFromRGB(0xf3f3f3)];
        [thumbnailImageView addSubview:adultView];
        
        UIImageView *adultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_li_adult_01.png"]];
        [adultImageView setFrame:CGRectMake((CGRectGetWidth(adultView.frame)-60)/2, (CGRectGetHeight(adultView.frame)-60)/2, 60, 60)];
        [adultView addSubview:adultImageView];
    }
    else {
        if ([imgUrl length] > 0) {
            NSRange strRange = [imgUrl rangeOfString:@"http"];
            if (strRange.location == NSNotFound) {
                imgUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            }
            strRange = [imgUrl rangeOfString:@"{{img_width}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            strRange = [imgUrl rangeOfString:@"{{img_height}}"];
            if (strRange.location != NSNotFound) {
                imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 240]];
            }
            
            [thumbnailImageView setFrame:CGRectMake(10, 10, 120, 120)];
            [thumbnailImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"thum_default.png"]];
        }
        else {
            [thumbnailImageView setFrame:CGRectMake(10, 10, 120, 120)];
            [thumbnailImageView.imageView setImage:[UIImage imageNamed:@"thum_default.png"]];
        }
    }
    
    UIImageView *shockingDealImageView = [[UIImageView alloc] init];
    [thumbnailImageView addSubview:shockingDealImageView];
    
    if ([dicItems[@"dealPrdYN"] isEqualToString:@"Y"]) {
        [shockingDealImageView setFrame:CGRectMake(5, 5, 37, 15)];
        [shockingDealImageView setImage:[UIImage imageNamed:@"ic_li_shockingdeal_s.png"]];
    }
    else {
        [shockingDealImageView setImage:nil];
    }
    
    //iconView
    UIView *iconView = [[UIView alloc] init];
    [view addSubview:iconView];
    
    if ([dicItems[@"icons"] count] > 0) {
        
        NSArray *array = dicItems[@"icons"];
        CGFloat viewWidth = 0;
        
        for (NSDictionary *dic in array) {
            
            //그리드뷰에선 아이콘 MAX 2개.
            if ([array indexOfObject:dic] > 1) {
                break;
            }
            
            UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [iconLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [iconLabel setBackgroundColor:[UIColor clearColor]];
            [iconLabel setTextAlignment:NSTextAlignmentCenter];
            [iconLabel.layer setBorderWidth:1];
            [iconView addSubview:iconLabel];
            
            CGFloat width = 50;
            
            if ([[dic objectForKey:@"type"] isEqualToString:@"freedlv"]) {
                [iconLabel setText:@"무료배송"];
                [iconLabel setTextColor:UIColorFromRGB(0x6989ff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xb6c6ff).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"100refund"]) {
                //TODO
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"tMember"]) {
                [iconLabel setText:@"T멤버십"];
                [iconLabel setTextColor:UIColorFromRGB(0xff411c)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffaa9e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"mileage"]) {
                [iconLabel setText:@"마일리지"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"myWay"]) {
                width = 78;
                [iconLabel setBackgroundColor:UIColorFromRGB(0xff3b0e)];
                [iconLabel setText:[NSString stringWithFormat:@"내맘대로 %@",[dic objectForKey:@"rate"]]];
                [iconLabel setTextColor:UIColorFromRGB(0xffffff)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xff3b0e).CGColor];
            }
            else if ([[dic objectForKey:@"type"] isEqualToString:@"discountCard"]) {
                [iconLabel setText:@"카드할인"];
                [iconLabel setTextColor:UIColorFromRGB(0xff822f)];
                [iconLabel.layer setBorderColor:UIColorFromRGB(0xffb483).CGColor];
            }
            
            [iconLabel setFrame:CGRectMake(viewWidth, 0, width, 19)];
            viewWidth += width+1;
        }
        
        [iconView setFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+10, 12, viewWidth, 19)];
    }
    else {
        CGRect frame = iconView.frame;
        frame.size.height = 0;
        [iconView setFrame:frame];
    }
    
    //상품명
    UILabel *productLabel = [[UILabel alloc] init];
    [productLabel setBackgroundColor:[UIColor clearColor]];
    [productLabel setFont:[UIFont systemFontOfSize:16]];
    [productLabel setTextColor:UIColorFromRGB(0x2d2d2d)];
    [productLabel setTextAlignment:NSTextAlignmentLeft];
    [productLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [productLabel setNumberOfLines:2];
    [view addSubview:productLabel];
    
    if (dicItems[@"prdNm"]) {
        NSString *str = dicItems[@"prdNm"];
        BOOL isExistIcon = [dicItems[@"icons"] count] > 0;
        
        [productLabel setText:str];
        [productLabel setFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+10, isExistIcon?CGRectGetMaxY(iconView.frame)+7:18, kScreenBoundsWidth-170, 40)];
    }
    
    TTTAttributedLabel *discountRateLabel = [[TTTAttributedLabel alloc] init];
    [discountRateLabel setBackgroundColor:[UIColor clearColor]];
    [discountRateLabel setFont:[UIFont boldSystemFontOfSize:24]];
    [discountRateLabel setTextColor:UIColorFromRGB(0xff272f)];
    [view addSubview:discountRateLabel];
    
    NSString *discountRateText = [NSString stringWithFormat:@"%@%%", dicItems[@"discountRate"]];
    CGSize discountRateSize = [discountRateText sizeWithFont:[UIFont boldSystemFontOfSize:24] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(discountRateLabel.frame)) lineBreakMode:discountRateLabel.lineBreakMode];
    
    if (dicItems[@"discountRate"]) {
        
        [discountRateLabel setFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+10, CGRectGetMaxY(view.frame)-46, discountRateSize.width, 26)];
        [discountRateLabel setText:discountRateText afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [discountRateText rangeOfString:@"%"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:15] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }
    else {
        //특별가
        discountRateText = @"특별가";
        discountRateSize = [discountRateText sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(discountRateLabel.frame)) lineBreakMode:discountRateLabel.lineBreakMode];
        
        [discountRateLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [discountRateLabel setText:discountRateText];
        [discountRateLabel setFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+10, CGRectGetMaxY(view.frame)-36, discountRateSize.width, 15)];
    }
    
    //할인가
    TTTAttributedLabel *discountLabel = [[TTTAttributedLabel alloc] init];
    [discountLabel setBackgroundColor:[UIColor clearColor]];
    [discountLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [discountLabel setTextColor:UIColorFromRGB(0x333333)];
    [view addSubview:discountLabel];
    
    //할인가
    if (dicItems[@"finalPrc"]) {
        NSString *text = [NSString stringWithFormat:@"%@원", [dicItems[@"finalPrc"] formatThousandComma]];
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(discountLabel.frame)) lineBreakMode:discountLabel.lineBreakMode];
        
        [discountLabel setFrame:CGRectMake(CGRectGetMaxX(discountRateLabel.frame)+(dicItems[@"discountRate"]?0:7), CGRectGetMaxY(view.frame)-38, size.width, 17)];
        [discountLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [text rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont boldSystemFontOfSize:11] range:colorRange];
            }
            return mutableAttributedString;
        }];
    }

    //원가
    TTTAttributedLabel *priceLabel = [[TTTAttributedLabel alloc] init];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [priceLabel setFont:[UIFont systemFontOfSize:11]];
    [priceLabel setTextColor:UIColorFromRGB(0x8c8b8b)];
    [priceLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:priceLabel];
    
    //라인
    UIView *priceLineView = [[UIView alloc] init];
    [priceLineView setBackgroundColor:UIColorFromRGB(0x8c8b8b)];
    [priceLabel addSubview:priceLineView];
    
    if (dicItems[@"selPrc"] && ![dicItems[@"selPrc"] isEqualToString:dicItems[@"finalPrc"]]) {
        NSString *priceString = [NSString stringWithFormat:@"%@원", [dicItems[@"selPrc"] formatThousandComma]];
        CGSize priceStringSize = [priceString sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(priceLabel.frame)) lineBreakMode:priceLabel.lineBreakMode];
        
        [priceLabel setFrame:CGRectMake(CGRectGetMaxX(discountRateLabel.frame)+(dicItems[@"discountRate"]?0:7), CGRectGetMaxY(view.frame)-50, priceStringSize.width, 12)];
        [priceLabel setText:priceString afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [priceString rangeOfString:@"원"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:10] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        [priceLineView setFrame:CGRectMake(CGRectGetMinX(priceLabel.frame), 0, CGRectGetWidth(priceLabel.frame), 1)];
        [priceLineView setCenter:CGPointMake(CGRectGetWidth(priceLabel.frame)/2, CGRectGetHeight(priceLabel.frame)/2)];
    }
    else {
        [priceLabel setText:@""];
        [priceLineView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    //구매개수
    TTTAttributedLabel *selCntLabel = [[TTTAttributedLabel alloc] init];
    [selCntLabel setBackgroundColor:[UIColor clearColor]];
    [selCntLabel setFont:[UIFont systemFontOfSize:12]];
    [selCntLabel setTextColor:UIColorFromRGB(0xff272f)];
    [view addSubview:selCntLabel];
    
    if (dicItems[@"selCnt"]) {
        NSString *priceString = [NSString stringWithFormat:@"%@개 구매", dicItems[@"selCnt"]];
        CGSize priceStringSize = [priceString sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(10000, CGRectGetHeight(priceLabel.frame)) lineBreakMode:priceLabel.lineBreakMode];
        
        [selCntLabel setFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+56, CGRectGetMaxY(view.frame)-44, priceStringSize.width, 12)];
        [selCntLabel setText:priceString afterInheritingLabelAttributesAndConfiguringWithBlock: ^(NSMutableAttributedString *mutableAttributedString) {
            NSRange colorRange = [priceString rangeOfString:@"개 구매"];
            if (colorRange.location != NSNotFound)
            {
                [mutableAttributedString addAttribute:(NSString *) kCTFontAttributeName value:(id)[UIFont systemFontOfSize:11] range:colorRange];
                [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[UIColorFromRGB(0x666666) CGColor] range:colorRange];
            }
            return mutableAttributedString;
        }];
        
        [selCntLabel setFrame:CGRectMake(CGRectGetMaxX(view.frame)-8-priceStringSize.width, CGRectGetMaxY(view.frame)-9-priceStringSize.height, priceStringSize.width, priceStringSize.height)];
    }
    
    //underLine
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame)-1, kScreenBoundsWidth-20, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
    [view addSubview:underLineView];
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blankButton setFrame:view.frame];
    [blankButton setTag:index];
    [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
    [blankButton setAlpha:0.3];
    [blankButton addTarget:self action:@selector(touchShockingDealProduct:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:blankButton];
    
    return view;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    self.shockingDealProductPageIndex = carousel.currentItemIndex;
    [self controlPageSet];
    
    [self.shockingDealProductRightButton setHidden:carousel.currentItemIndex == [self.dicData[@"items"] count]-1 ? YES : NO];
    [self.shockingDealProductLeftButton setHidden:carousel.currentItemIndex == 0 ? YES : NO];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
}

#pragma mark - Selectors

//베스트탭 상품
- (void)touchCommonProduct:(id)sender
{
    NSDictionary *bestItem = self.dicData[@"commonProduct"];
    NSString *linkUrl = bestItem[@"linkUrl"];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = app.homeViewController;
    
    if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
        [homeViewController didTouchButtonWithUrl:linkUrl];
    }
    
    //AccessLog - 상품
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0400"];
}

//카테고리베스트
- (void)touchCategoryBest:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchCategoryBest:)]) {
        [self.delegate touchCategoryBest:sender];
    }
}

//쇼킹딜탭 상품
- (void)touchBannerProduct:(id)sender
{
    //상품 터치이벤트
    NSDictionary *shockingItem = self.dicData[@"bannerProduct"];
    NSString *linkUrl = shockingItem[@"linkUrl"];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
            [homeViewController didTouchButtonWithUrl:linkUrl];
        }
    }
}

//동영상 재생
- (void)touchVideoPlayer:(id)sender
{
    NSDictionary *productDic = self.dicData;
    NSString *linkUrl = [productDic objectForKey:@"bannerProduct"][@"movieAppLink"];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
            [homeViewController didTouchButtonWithUrl:linkUrl];
        }
    }
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAJ0304"];
}

//연관상품
- (void)touchRelativeProduct:(id)sender
{
    NSDictionary *productDic = self.dicData;
    NSString *linkUrl = [productDic objectForKey:@"bannerProduct"][@"relationPrd"][@"relationAppLink"];
    
    if (linkUrl && [[linkUrl trim] length] > 0) {
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
            [homeViewController didTouchButtonWithUrl:linkUrl];
        }
    }
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAJ0303"];
}

//searchProductSellerButton
- (void)touchSearchProductSellerButton:(id)sender
{
    NSDictionary *searchProductItems = self.dicData;
//    NSString *linkUrl = @"http://m.11st.co.kr/MW/Product/productSellerZone.tmall?sellerHmpgUrl={{sellerUrl}}&selMemNo={{sellerNo}}&prdNo={{prdNo}}";
//    
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{sellerUrl}}" withString:[NSString stringWithFormat:@"%@", [searchProductItems objectForKey:@"sellerHmpgUrl"]]];
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{sellerNo}}" withString:[NSString stringWithFormat:@"%@", [searchProductItems objectForKey:@"sellerMemNo"]]];
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:[NSString stringWithFormat:@"%@", [searchProductItems objectForKey:@"prdNo"]]];
    
    NSString *linkUrl = searchProductItems[@"sellerHmpgUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSearchProductSellerButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchSearchProductSellerButton:linkUrl];
        }
    }
}

//searchProductBannerSellerButton
- (void)touchSearchProductBannerSellerButton:(id)sender
{
    NSDictionary *searchProductBannerItems = self.dicData;
//    NSString *linkUrl = @"http://m.11st.co.kr/MW/Product/productSellerZone.tmall?sellerHmpgUrl={{sellerUrl}}&selMemNo={{sellerNo}}&prdNo={{prdNo}}";
//    
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{sellerUrl}}" withString:[NSString stringWithFormat:@"%@", [searchProductBannerItems objectForKey:@"sellerHmpgUrl"]]];
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{sellerNo}}" withString:[NSString stringWithFormat:@"%@", [searchProductBannerItems objectForKey:@"sellerMemNo"]]];
//    linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:[NSString stringWithFormat:@"%@", [searchProductBannerItems objectForKey:@"prdNo"]]];
    
    NSString *linkUrl = searchProductBannerItems[@"sellerHmpgUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSearchProductBannerSellerButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchSearchProductBannerSellerButton:linkUrl];
        }
    }
}

//touchSearchCaption
- (void)touchSearchCaption:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showSearchCaptionAD:)]) {
        [self.delegate showSearchCaptionAD:sender];
    }
}

//touchCtgrHotClick
- (void)touchCtgrHotClickProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *ctgrHotClickItems = self.dicData[@"items"][button.tag];
    NSString *linkUrl = [ctgrHotClickItems objectForKey:@"prdDtlUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCtgrHotClickProduct:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchCtgrHotClickProduct:linkUrl];
        }
    }
    
    //AccessLog - 핫클릭 상품 클릭 시
    NSString *clickCd = ctgrHotClickItems[@"clickCd"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:clickCd];
    
    //광고 클릭집계
    if (ctgrHotClickItems[@"adClickTrcUrl"]) {
        for (NSString *url in ctgrHotClickItems[@"adClickTrcUrl"]) {
            [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
        }
    }
}

//touchCtgrHotClickAD
- (void)touchCtgrHotClickAD:(id)sender
{
    for (UIButton *adView in self.ctgrHotClickCellContentView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == 99){
            return;
        }
    }
    
    UIImage *image = [[UIImage imageNamed:@"layer_s_popup_02.png"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
    
    UIButton *searchCaptionADView = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchCaptionADView setTag:99];
    [searchCaptionADView setFrame:CGRectMake(-2, 30, kScreenBoundsWidth-14, 62)];
    [searchCaptionADView setBackgroundImage:image forState:UIControlStateNormal];
    [searchCaptionADView addTarget:self action:@selector(touchCloseADView:) forControlEvents:UIControlEventTouchUpInside];
    [self.ctgrHotClickCellContentView addSubview:searchCaptionADView];
    
    NSString *ADtitle = self.dicData[@"adInfo"];
    
    UILabel *ADLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, CGRectGetWidth(searchCaptionADView.frame)-40, 40)];
    [ADLabel setBackgroundColor:[UIColor clearColor]];
    [ADLabel setFont:[UIFont systemFontOfSize:15]];
    [ADLabel setText:ADtitle];
    [ADLabel setTextColor:UIColorFromRGB(0xffffff)];
    [ADLabel setNumberOfLines:2];
    [searchCaptionADView addSubview:ADLabel];
    
    UIImageView *ADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchCaptionADView.frame)-30, 10, 14, 14)];
    [ADImageView setImage:[UIImage imageNamed:@"ic_s_close_02.png"]];
    [searchCaptionADView addSubview:ADImageView];
}

- (void)touchCloseADView:(id)sender
{
    for (UIButton *adView in self.ctgrHotClickCellContentView.subviews){
        if([adView isKindOfClass:[UIButton class]] && adView.tag == 99){
            [adView removeFromSuperview];
        }
    }
}

//touchCtgrBest
- (void)touchCtgrBest:(id)sender
{
    NSString *linkUrl = self.dicData[@"moreUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCtgrBest:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchCtgrBest:linkUrl];
        }
    }
    
    //AccessLog - 랭킹상품 더보기 클릭 시
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NACTGB12"];
}

//touchCtgrBest
- (void)touchCtgrBestProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *ctgrHotClickItems = self.dicData[@"items"][button.tag];
    NSString *linkUrl = [ctgrHotClickItems objectForKey:@"prdDtlUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCtgrBestProduct:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchCtgrBestProduct:linkUrl];
        }
    }
    
    //AccessLog - 랭킹상품 상품 클릭 시
    NSString *clickCd = ctgrHotClickItems[@"clickCd"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:clickCd];
}

//touchCtgrDealBest
- (void)touchCtgrDealBestProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *ctgrHotClickItems = self.dicData[@"items"][button.tag];
    NSString *linkUrl = [ctgrHotClickItems objectForKey:@"prdDtlUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCtgrDealBestProduct:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchCtgrDealBestProduct:linkUrl];
        }
    }
    
    //AccessLog - 쇼킹딜상품 클릭 시
    NSString *clickCd = ctgrHotClickItems[@"clickCd"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:clickCd];
}

//배너 클릭
- (void)onTouchBanner:(id)sender
{
    NSString *linkUrl = self.dicData[@"lineBanner"][@"dispObjLnkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didOnTouchBanner:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didOnTouchBanner:linkUrl];
        }
    }
}

//쇼킹딜 App에서 상품 더보기
- (void)onTouchMoreView
{
    NSString *shockingDealAppURL = self.dicData[@"urlScheme"];
    NSString *shockingDealAppstoreURL = self.dicData[@"storeURL"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:shockingDealAppURL]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppURL]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppstoreURL]];
    }
}

//searchProduct ajax call
- (void)touchSearchProductAjaxCall:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchSearchProductAjaxCall:)]) {
        [self.delegate touchSearchProductAjaxCall:sender];
    }
}

- (void)touchCategoryNaviButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryNaviButton:)]) {
        [self.delegate didTouchCategoryNaviButton:sender];
    }
}

- (void)touchRelatedOpenButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchRelatedOpenButton:)]) {
        [self.delegate didTouchRelatedOpenButton:sender];
    }
}

- (void)touchRelatedKeywordButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchRelatedKeywordButton:)]) {
        [self.delegate didTouchRelatedKeywordButton:sender];
    }
}

- (void)touchRecommendKeywordButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchRecommendKeywordButton:)]) {
        [self.delegate didTouchRecommendKeywordButton:sender];
    }
}

- (void)touchFilterButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSArray *filterItems = self.dicData[@"items"];
    
    NSDictionary *menu = filterItems[button.tag];
    
    if ([self.delegate respondsToSelector:@selector(didTouchFilterButton:)]) {
        [self.delegate didTouchFilterButton:menu[@"key"]];
    }
}

- (void)touchTopTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSArray *searchTopTabItems = self.dicData[@"items"];
    
    NSDictionary *menu = searchTopTabItems[button.tag];
    
    if ([self.delegate respondsToSelector:@selector(didTouchTopTabButton:)]) {
        [self.delegate didTouchTopTabButton:menu];
    }
}

- (void)touchViewTypeButton
{
    NSArray *viewItems = self.dicData[@"viewItems"];
    
    NSString *currentViewType;
    NSString *listUrl;
    NSString *imageUrl;
    NSString *slideUrl;
    NSString *url;
    
    for (NSDictionary *viewInfo in viewItems) {
        if ([viewInfo[@"selected"] isEqualToString:@"Y"]) {
            currentViewType = viewInfo[@"text"];
        }
        
        if ([viewInfo[@"text"] isEqualToString:@"리스트형"]) {
            listUrl = viewInfo[@"url"];
        }
        
        if ([viewInfo[@"text"] isEqualToString:@"이미지형"]) {
            imageUrl = viewInfo[@"url"];
        }
        
        if ([viewInfo[@"text"] isEqualToString:@"슬라이드형"]) {
            slideUrl = viewInfo[@"url"];
        }
    }
    
    if ([currentViewType isEqualToString:@"리스트형"]) {
        url = imageUrl;
    }
    else if ([currentViewType isEqualToString:@"이미지형"]) {
        url = slideUrl;
    }
    else {
        url = listUrl;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchViewTypeButton:)]) {
        [self.delegate didTouchViewTypeButton:url];
    }
}

- (void)touchSortTypeButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchSortTypeButton:)]) {
        [self.delegate didTouchSortTypeButton:sender];
    }
}

//searchProductBanner ajax call
- (void)touchSearchProductBannerAjaxCall:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchSearchProductBannerAjaxCall:)]) {
        [self.delegate touchSearchProductBannerAjaxCall:sender];
    }
}

//rightButton
- (void)touchShockingDealProductRightButton:(id)sender
{
    [self.shockingDealProductView scrollToItemAtIndex:self.shockingDealProductPageIndex+1 animated:YES];
}

//leftButton
- (void)touchShockingDealProductLeftButton:(id)sender
{
    [self.shockingDealProductView scrollToItemAtIndex:self.shockingDealProductPageIndex-1 animated:YES];
}

//touchShockingDealProduct
- (void)touchShockingDealProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *dicItems = self.dicData[@"items"][button.tag];
    NSString *linkUrl = [dicItems objectForKey:@"prdDtlUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchShockingDealProduct:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchShockingDealProduct:linkUrl];
        }
    }
    
    //AccessLog - touchShockingDealProduct
    NSString *clickCd = dicItems[@"clickCd"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:clickCd];
}

- (void)touchSearchCaptionPageMoveButton:(id)sender
{
    NSString *linkUrl = self.dicData[@"moreUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSearchCaptionPageMoveButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchSearchCaptionPageMoveButton:linkUrl];
        }
    }
    
    //AccessLog - 쇼킹딜 더보기
    NSString *clickCd =  self.dicData[@"clickCd"];
    [[AccessLog sharedInstance] sendAccessLogWithCode:clickCd];
}

- (void)touchSearchMore:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchSearchMore:)]) {
        [self.delegate didTouchSearchMore:sender];
    }
}

- (void)touchSearchHotProduct:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSDictionary *searchHotProductItems = self.dicData;
    NSString *prdDtlUrl = searchHotProductItems[@"items"][button.tag][@"prdDtlUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSearchHotProduct:)]) {
        if (prdDtlUrl && [[prdDtlUrl trim] length] > 0) {
            [self.delegate didTouchSearchHotProduct:prdDtlUrl];
        }
    }
    
    //광고 클릭집계
    if (searchHotProductItems[@"items"][button.tag][@"adClickTrcUrl"]) {
        for (NSString *url in searchHotProductItems[@"items"][button.tag][@"adClickTrcUrl"]) {
            [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
        }
    }
}

#pragma mark - Private Methods

- (BOOL)isSearchProductGridCellAlignment:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(isSearchProductGridCellAlignment:)]) {
        return [self.delegate isSearchProductGridCellAlignment:indexPath];
    }
    
    return NO;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = app.homeViewController;
    
    NSDictionary *dic = self.dicData;
    NSString *keyword = [dic objectForKey:@"recommendKeyword"];
    NSString *encKeyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    encKeyword = [encKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] initWithKeyword:encKeyword referrer:nil];
    [homeViewController.navigationController pushViewController:viewConroller animated:YES];
}

@end