//
//  CPDescriptionBottomView.m
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPDescriptionBottomView.h"
#import "CPDescriptionBottomTownShopBranch.h"
#import "CPDescriptionBottomReviewItem.h"
#import "CPDescriptionBottomPostItem.h"
#import "CPDescriptionBottomPrdInfoLink.h"
#import "CPDescriptionBottomBrandShop.h"
#import "CPDescriptionBottomMiniMall.h"
#import "CPDescriptionBottomCategoryPopular.h"
#import "CPDescriptionBottomDealRelation.h"
#import "CPDescriptionBottomPrdRecommend.h"
#import "CPDescriptionBottomLiveKeyword.h"
#import "CPFooterView.h"

#import "CPRESTClient.h"
#import "AccessLog.h"

@interface CPDescriptionBottomView() <CPDescriptionBottomTitleViewDelegate,
                                    CPDescriptionBottomTownShopBranchDelegate,
                                    CPDescriptionBottomReviewItemDelegate,
                                    CPDescriptionBottomPostItemDelegate,
                                    CPDescriptionBottomPrdInfoLinkDelegate,
                                    CPDescriptionBottomBrandShopDelegate,
                                    CPDescriptionBottomMiniMallDelegate,
                                    CPDescriptionBottomCategoryPopularDelegate,
                                    CPDescriptionBottomDealRelationDelegate,
                                    CPDescriptionBottomPrdRecommendDelegate,
                                    CPDescriptionBottomLiveKeywordDelegate,
                                    CPFooterViewDelegate>
{
    NSDictionary *product;
    
    NSMutableDictionary *townShopBranch;
    NSMutableDictionary *prdReview;
    NSMutableDictionary *prdPost;
    NSMutableDictionary *miniMall;
    NSMutableDictionary *categoryPopular;
    NSMutableDictionary *dealRelation;
    NSMutableDictionary *prdRecommend;
    NSMutableDictionary *liveKeyword;
    
    CGFloat offsetY;
    CGFloat offSetTownShopBranchY;
    CGFloat offSetLiveKeywordY;
    
    UIView *townShopBranchView;
    //지점정보 목록
    UIView *townShopBranchListView;
    
    UIView *reviewItemView;
    UIView *postItemView;
    UIView *prdInfoLinkView;
    UIView *brandShopView;
    UIView *miniMallView;
    UIView *categoryPopularView;
    UIView *dealRelationView;
    UIView *prdRecommendView;
    UIView *liveKeywordView;
    UIView *bottomMarginView;
    
    CPDescriptionBottomTownShopBranch *townShopBranchLayer;
    CPDescriptionBottomLiveKeyword *liveKeywordLayout;
    
    //footerView
    CPFooterView *cpFooterView;
}

@end

@implementation CPDescriptionBottomView

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
        [self initData];
        [self initLayout];
    }
    return self;
}

- (void)initData
{
    townShopBranch = [NSMutableDictionary dictionary];
    prdReview = [NSMutableDictionary dictionary];
    prdPost = [NSMutableDictionary dictionary];
    miniMall = [NSMutableDictionary dictionary];
    liveKeyword = [NSMutableDictionary dictionary];
    categoryPopular = [NSMutableDictionary dictionary];
    dealRelation = [NSMutableDictionary dictionary];
    prdRecommend = [NSMutableDictionary dictionary];
    
    townShopBranch = product[@"townShopBranch"];
    prdReview = product[@"prdReview"];
    prdPost = product[@"prdPost"];
    miniMall = product[@"miniMall"];
    liveKeyword = product[@"liveKeyword"];
    categoryPopular = product[@"categoryPopular"];
    dealRelation = product[@"dealRelation"];
    prdRecommend = product[@"prdRecommend"];
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self drawTownShopBranchLayout];
}

- (void)loadReview
{
    NSDictionary *dict = prdReview;
    NSInteger itemCount = [dict[@"totalCount"] integerValue];
    
    if (itemCount == 0) {
        [self loadPost];
        return;
    }
    
    NSString *url = dict[@"reviewApiUrl"];
    
    [self getReviewData:url];
}

- (void)drawTownShopBranchLayout
{
    NSDictionary *dict  = townShopBranch;
    
    if (dict && dict.count > 0) {
    
        CGFloat townShopBranchItemOffsetY = 0.f;
        
        townShopBranchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.f)];
        [self addSubview:townShopBranchView];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, townShopBranchView.frame.size.width, 1)];
        topLine.backgroundColor = UIColorFromRGB(0xdbdbe1);
        [townShopBranchView addSubview:topLine];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, townShopBranchView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [townShopBranchView addSubview:topMarginView];
        
        townShopBranchItemOffsetY = 10.f;
        
        CGFloat viewHeight = 165.f;
        townShopBranchLayer = [[CPDescriptionBottomTownShopBranch alloc] initWithFrame:CGRectMake(0, townShopBranchItemOffsetY,
                                                                                                              self.frame.size.width,
                                                                                                              viewHeight)
                                                                                  item:dict];
        
        townShopBranchLayer.delegate = self;
        [townShopBranchView addSubview:townShopBranchLayer];
        townShopBranchItemOffsetY += viewHeight;
        
        townShopBranchView.frame = CGRectMake(townShopBranchView.frame.origin.x,
                                          townShopBranchView.frame.origin.y,
                                          townShopBranchView.frame.size.width,
                                          townShopBranchItemOffsetY);
        
        offsetY += townShopBranchView.frame.size.height;
        offSetTownShopBranchY = townShopBranchView.frame.origin.y;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                townShopBranchView.frame.size.height);
    }

    [self loadReview];
}

- (void)drawReviewLayout:(NSArray *)array
{
    if ([product[@"reviewPostDispYN"] isEqualToString:@"Y"]) {
        
        CGFloat reviewItemOffsetY = 0.f;
        
        reviewItemView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0.f)];
        [self addSubview:reviewItemView];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, reviewItemView.frame.size.width, 1)];
        topLine.backgroundColor = UIColorFromRGB(0xdbdbe1);
        [reviewItemView addSubview:topLine];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, reviewItemView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [reviewItemView addSubview:topMarginView];
        
        reviewItemOffsetY = 10.f;
        
        CPDescriptionBottomTitleView *titleView = nil;
        titleView = [[CPDescriptionBottomTitleView alloc] initWithFrame:CGRectMake(0, reviewItemOffsetY, self.frame.size.width, 46.f)
                                                                  title:@"상품리뷰"
                                                             totalCount:prdReview[@"totalCount"]
                                                                   type:MoveTabTypeReview
                                                                bgColor:[UIColor whiteColor]
                                                             titleColor:UIColorFromRGB(0x333333)
                                                           topLineColor:UIColorFromRGB(0xdbdbe1)
                                                           isBottomLine:YES];
        titleView.delegate = self;
        [reviewItemView addSubview:titleView];
        
        reviewItemOffsetY += titleView.frame.size.height;
        
        NSInteger count = ([array count] > 3 ? 3 : [array count]);
        for (NSInteger i=1; i<count; i++)
        {
            CGFloat viewHeight = 105.f;
            if (!array[i][@"option"] && !array[i][@"imgUrl"]) {
                viewHeight = 92.f;
            }
            
            CPDescriptionBottomReviewItem *item = [[CPDescriptionBottomReviewItem alloc] initWithFrame:CGRectMake(0, reviewItemOffsetY,
                                                                                                                  self.frame.size.width,
                                                                                                                  viewHeight)
                                                                                                  item:array[i]
                                                                                                   url:prdReview[@"reviewApiUrl"]
                                                                                                 prdNo:array[i][@"contNo"]
                                                                                              lastItem:(i == count-1)
                                                                                               isInTab:NO];
            
            item.delegate = self;
            [reviewItemView addSubview:item];
            reviewItemOffsetY += viewHeight;
        }
        
        reviewItemView.frame = CGRectMake(reviewItemView.frame.origin.x,
                                          reviewItemView.frame.origin.y,
                                          reviewItemView.frame.size.width,
                                          reviewItemOffsetY);
        
        offsetY += reviewItemView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                reviewItemView.frame.size.height);
        
        //    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
        //        [self.delegate descriptionBottomView:self addContentHeight:reviewItemView.frame.size.height];
        //    }
    }
}

- (void)loadPost
{
    NSDictionary *dict  = prdPost;
    
    NSInteger itemCount = [dict[@"totalCount"] integerValue];
    
    if (itemCount == 0) {
        [self loadPrdInfoLink];
        return;
    }
    
    NSString *url = dict[@"postListApiUrl"];
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:product[@"prdNo"]];
    url = [url stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:@"1"];
    
    [self getPostData:url];
}

- (void)drawPostLayout:(NSArray *)array
{
    if ([product[@"reviewPostDispYN"] isEqualToString:@"Y"]) {
        
        CGFloat postOffsetY = 0.f;
        
        postItemView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:postItemView];
        
    //    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, postItemView.frame.size.width, 1)];
    //    topLine.backgroundColor = UIColorFromRGB(0xd9d9d9);
    //    [postItemView addSubview:topLine];
    //    
    //    postOffsetY += 10.f;
        
        if (!reviewItemView) {
            UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, postItemView.frame.size.width, 1)];
            topLine.backgroundColor = UIColorFromRGB(0xdbdbe1);
            [postItemView addSubview:topLine];
            
            UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, postItemView.frame.size.width, 10)];
            topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
            [postItemView addSubview:topMarginView];
            
            postOffsetY = 10.f;
        }
        
        CPDescriptionBottomTitleView *titleView = nil;
        titleView = [[CPDescriptionBottomTitleView alloc] initWithFrame:CGRectMake(0, postOffsetY, self.frame.size.width, 46.f)
                                                                  title:@"구매후기"
                                                             totalCount:prdPost[@"totalCount"]
                                                                   type:MoveTabTypePost
                                                                bgColor:[UIColor whiteColor]
                                                             titleColor:UIColorFromRGB(0x333333)
                                                           topLineColor:UIColorFromRGB(0xededed)
                                                           isBottomLine:YES];
        
        titleView.delegate = self;
        [postItemView addSubview:titleView];
        
        postOffsetY += titleView.frame.size.height;
        
        NSInteger count = ([array count] > 2 ? 2 : [array count]);
        for (NSInteger i=0; i<count; i++)
        {
            CPDescriptionBottomPostItem *item = [[CPDescriptionBottomPostItem alloc] initWithFrame:CGRectMake(0, postOffsetY,
                                                                                                            self.frame.size.width,
                                                                                                            0.f)
                                                                                            item:array[i]
                                                                                        lastItem:(i == count-1)];
            item.delegate = self;
            [postItemView addSubview:item];
            
            postOffsetY += item.frame.size.height;
        }
        
        postItemView.frame = CGRectMake(postItemView.frame.origin.x,
                                         postItemView.frame.origin.y,
                                         postItemView.frame.size.width,
                                         postOffsetY);
        
        offsetY += postItemView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                postItemView.frame.size.height);
        
    //    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
    //        [self.delegate descriptionBottomView:self addContentHeight:postItemView.frame.size.height];
    //    }
    }
}

- (void)loadPrdInfoLink
{
    NSString *prdSelUrl  = product[@"prdSelInfoLinkUrl"];
    NSString *prdInfoNoticeUrl  = product[@"prdInfoNoticeLinkUrl"];
    
    CGFloat prdInfoOffsetY = 0.f;
    
    prdInfoLinkView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
    [self addSubview:prdInfoLinkView];
    
    UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, prdInfoLinkView.frame.size.width, 10)];
    topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
    [prdInfoLinkView addSubview:topMarginView];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, prdInfoLinkView.frame.size.width, 1)];
    topLineView.backgroundColor = UIColorFromRGB(0xdbdbe1);
    [prdInfoLinkView addSubview:topLineView];

    prdInfoOffsetY += 10.f;
    
    CPDescriptionBottomPrdInfoLink *item = nil;
    item = [[CPDescriptionBottomPrdInfoLink alloc] initWithFrame:CGRectMake(0, prdInfoOffsetY,
                                                                                       self.frame.size.width,
                                                                                       44)
                                                             prdSelInfoUrl:prdSelUrl
                                                          prdInfoNoticeUrl:prdInfoNoticeUrl];
    
    item.delegate = self;
    [prdInfoLinkView addSubview:item];
    
    prdInfoOffsetY += item.frame.size.height;
    
    prdInfoLinkView.frame = CGRectMake(prdInfoLinkView.frame.origin.x,
                                    prdInfoLinkView.frame.origin.y,
                                    prdInfoLinkView.frame.size.width,
                                    prdInfoOffsetY);
    
    offsetY += prdInfoLinkView.frame.size.height;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            prdInfoLinkView.frame.size.height);
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:prdInfoLinkView.frame.size.height];
//    }
    
    [self loadBrandShop];
}

- (void)loadBrandShop
{
    NSDictionary *brandShopDict  = product[@"brandShop"];
    
    if (brandShopDict && brandShopDict.count > 0) {
        
        //AccessLog - 브랜드몰 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ15"];
        
        CGFloat brandShopOffsetY = 0.f;
        
        brandShopView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:brandShopView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, brandShopView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [brandShopView addSubview:topMarginView];
        
        brandShopOffsetY += 10.f;
        
        CPDescriptionBottomBrandShop *item = nil;
        item = [[CPDescriptionBottomBrandShop alloc] initWithFrame:CGRectMake(0, brandShopOffsetY,
                                                                                self.frame.size.width,
                                                                                60)
                                                              item:brandShopDict];
        
        item.delegate = self;
        [brandShopView addSubview:item];
        
        brandShopOffsetY += item.frame.size.height;
        
        brandShopView.frame = CGRectMake(brandShopView.frame.origin.x,
                                           brandShopView.frame.origin.y,
                                           brandShopView.frame.size.width,
                                           brandShopOffsetY);
        
        offsetY += brandShopView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                brandShopView.frame.size.height);
        
//        if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//            [self.delegate descriptionBottomView:self addContentHeight:brandShopView.frame.size.height];
//        }
    }
    
    [self getMiniMallData];
}

- (void)loadMiniMall:(NSDictionary *)dic
{
    NSDictionary *miniMallDict  = dic;
    
    if ([miniMallDict[@"sellerInfo"][@"list"] count] > 0) {
        
        //AccessLog - 판매자 영역 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK01"];
        
        CGFloat miniMallOffsetY = 0.f;
        
        miniMallView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:miniMallView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, miniMallView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [miniMallView addSubview:topMarginView];
        
        miniMallOffsetY += 10.f;
        //로그인 여부
        CGFloat itemHeight = 280;
        
        CPDescriptionBottomMiniMall *item = nil;
        item = [[CPDescriptionBottomMiniMall alloc] initWithFrame:CGRectMake(0, miniMallOffsetY,
                                                                              self.frame.size.width,
                                                                              itemHeight)
                                                            title:miniMall[@"label"]
                                                             item:miniMallDict
                                                          linkUrl:miniMall[@"minimallLinkUrl"]
                                                    resistLinkUrl:miniMall[@"minimallResistLinkUrl"]
                                                      helpLinkUrl:miniMall[@"helpLinkUrl"]
                                                     indiSellerYn:miniMall[@"indiSellerYn"]];
        item.delegate = self;
        [miniMallView addSubview:item];
        
        miniMallOffsetY += item.frame.size.height;
        
        miniMallView.frame = CGRectMake(miniMallView.frame.origin.x,
                                         miniMallView.frame.origin.y,
                                         miniMallView.frame.size.width,
                                         miniMallOffsetY);
        
        offsetY += miniMallView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                miniMallView.frame.size.height);
        
    }
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:miniMallView.frame.size.height];
//    }
}

- (void)loadCategoryPopular:(NSDictionary *)dic
{
    NSDictionary *categoryPopularDict  = dic;
    
    if ([categoryPopularDict[@"categoryPopularPrd"][@"list"] count] > 0) {
        
        //AccessLog - 카테고리 인기상품 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK05"];
    
        CGFloat categoryPopularOffsetY = 0.f;
        
        categoryPopularView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:categoryPopularView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, categoryPopularView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [categoryPopularView addSubview:topMarginView];
        
        categoryPopularOffsetY += 10.f;
        
        
        CPDescriptionBottomTitleView *titleView = nil;
        titleView = [[CPDescriptionBottomTitleView alloc] initWithFrame:CGRectMake(0, categoryPopularOffsetY, self.frame.size.width, 46.f)
                                                                  title:categoryPopular[@"label"]
                                                             totalCount:@""
                                                                   type:MoveTabTypeNone
                                                                bgColor:[UIColor whiteColor]
                                                             titleColor:UIColorFromRGB(0x333333)
                                                           topLineColor:UIColorFromRGB(0xdbdbe1)
                                                           isBottomLine:YES];
        
        titleView.delegate = self;
        [categoryPopularView addSubview:titleView];
        
        categoryPopularOffsetY += titleView.frame.size.height;
        
        
        CPDescriptionBottomCategoryPopular *item = nil;
        item = [[CPDescriptionBottomCategoryPopular alloc] initWithFrame:CGRectMake(0, categoryPopularOffsetY,
                                                                             self.frame.size.width,
                                                                             212)
                                                                    item:categoryPopularDict
                                                              morePrdUrl:categoryPopular[@"morePrdUrl"]];
        
        item.delegate = self;
        [categoryPopularView addSubview:item];
        
        categoryPopularOffsetY += item.frame.size.height;
        
        categoryPopularView.frame = CGRectMake(categoryPopularView.frame.origin.x,
                                        categoryPopularView.frame.origin.y,
                                        categoryPopularView.frame.size.width,
                                        categoryPopularOffsetY);
        
        offsetY += categoryPopularView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                categoryPopularView.frame.size.height);
    }
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:categoryPopularView.frame.size.height];
//    }
}

- (void)loadDealRelation:(NSDictionary *)dic
{
    NSDictionary *dealRelationDict  = dic;
    
    if ([dealRelationDict[@"dealPopularPrd"][@"list"] count] >= 3) {
    
        //AccessLog - 쇼킹딜 상품 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK09"];
        
        CGFloat dealRelationOffsetY = 0.f;
        
        dealRelationView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:dealRelationView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dealRelationView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [dealRelationView addSubview:topMarginView];
        
        dealRelationOffsetY += 10.f;
        
        CPDescriptionBottomDealRelation *item = nil;
        item = [[CPDescriptionBottomDealRelation alloc] initWithFrame:CGRectMake(0, dealRelationOffsetY,
                                                                                    self.frame.size.width,
                                                                                    208)
                                                                    item:dealRelationDict
                                                            iconImageUrl:dealRelation[@"imgUrl"]
                                                                   title:dealRelation[@"label"]];
        
        item.delegate = self;
        [dealRelationView addSubview:item];
        
        dealRelationOffsetY += item.frame.size.height;
        
        dealRelationView.frame = CGRectMake(dealRelationView.frame.origin.x,
                                            dealRelationView.frame.origin.y,
                                            dealRelationView.frame.size.width,
                                            dealRelationOffsetY);
        
        offsetY += dealRelationView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                dealRelationView.frame.size.height);
        
    }
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:dealRelationView.frame.size.height];
//    }
}

- (void)loadPrdRecommend:(NSDictionary *)dic
{
    NSDictionary *prdRecommendDict  = dic;
    
    if ([prdRecommendDict[@"response"][@"resultList"] count] >= 3) {
        
        //AccessLog - 함께 본 상품 노출
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPK11"];
    
        CGFloat prdRecommendOffsetY = 0.f;
        
        prdRecommendView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:prdRecommendView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, prdRecommendView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [prdRecommendView addSubview:topMarginView];
        
        prdRecommendOffsetY += 10.f;
        
        CPDescriptionBottomPrdRecommend *item = nil;
        item = [[CPDescriptionBottomPrdRecommend alloc] initWithFrame:CGRectMake(0, prdRecommendOffsetY,
                                                                                 self.frame.size.width,
                                                                                 208)
                                                                 item:prdRecommendDict
                                                                title:prdRecommend[@"label"]];
        
        item.delegate = self;
        [prdRecommendView addSubview:item];
        
        prdRecommendOffsetY += item.frame.size.height;
        
        prdRecommendView.frame = CGRectMake(prdRecommendView.frame.origin.x,
                                            prdRecommendView.frame.origin.y,
                                            prdRecommendView.frame.size.width,
                                            prdRecommendOffsetY);
        
        offsetY += prdRecommendView.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                prdRecommendView.frame.size.height);
    }
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:prdRecommendView.frame.size.height];
//    }
}

- (void)loadLiveKeyword
{
    NSDictionary *liveKeywordDict  = liveKeyword;
    
    if ([liveKeywordDict[@"keywordList"] count] > 0) {
        CGFloat liveKeywordOffsetY = 0.f;
        
        liveKeywordView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)];
        [self addSubview:liveKeywordView];
        
        UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, liveKeywordView.frame.size.width, 10)];
        topMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
        [liveKeywordView addSubview:topMarginView];
        
        liveKeywordOffsetY += 10.f;
        
        liveKeywordLayout = [[CPDescriptionBottomLiveKeyword alloc] initWithFrame:CGRectMake(0, liveKeywordOffsetY,
                                                                                             self.frame.size.width,
                                                                                             44)
                                                                             item:liveKeywordDict[@"keywordList"]
                                                                       updateTime:liveKeywordDict[@"updateDate"]];
        
        liveKeywordLayout.delegate = self;
        [liveKeywordView addSubview:liveKeywordLayout];
        
        liveKeywordOffsetY += liveKeywordLayout.frame.size.height;
        
        liveKeywordView.frame = CGRectMake(liveKeywordView.frame.origin.x,
                                           liveKeywordView.frame.origin.y,
                                           liveKeywordView.frame.size.width,
                                           liveKeywordOffsetY);
        
        offsetY += liveKeywordView.frame.size.height;
        offSetLiveKeywordY = liveKeywordView.frame.origin.y;
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                liveKeywordView.frame.size.height);
        
//        if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//            [self.delegate descriptionBottomView:self addContentHeight:liveKeywordView.frame.size.height];
//        }
    }
    
    [self loadFooterView];
}

- (void)loadFooterView
{
//    CGFloat footerHeight = 0;
    
    bottomMarginView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, kScreenBoundsWidth, 10)];
    bottomMarginView.backgroundColor = UIColorFromRGB(0xe3e3e8);
    [self addSubview:bottomMarginView];
    
//    footerHeight += 10;
    offsetY += 10;
    
    //Footer
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setFrame:CGRectMake(0, offsetY, cpFooterView.width, cpFooterView.height)];
    [cpFooterView setDelegate:self];
    [self addSubview:cpFooterView];
    
//    footerHeight += cpFooterView.frame.size.height;
    offsetY += cpFooterView.frame.size.height;
    
//    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
//        [self.delegate descriptionBottomView:self addContentHeight:footerHeight];
//    }
    
    if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
        [self.delegate descriptionBottomView:self addContentHeight:offsetY];
    }
}

#pragma mark - API

- (void)getReviewData:(NSString *)url
{
    void (^reviewSuccess)(NSDictionary *);
    reviewSuccess = ^(NSDictionary *reviewData) {
        
        if (reviewData && [reviewData count] > 0) {
            
            [self drawReviewLayout:reviewData[@"review"][@"list"]];
            [self loadPost];
        }
        else {
            [self loadPost];
        }
    };
    
    void (^reviewFailure)(NSError *);
    reviewFailure = ^(NSError *error) {
        [self loadPost];
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:reviewSuccess
                                                         failure:reviewFailure];
    }
    else {
        [self loadPost];
    }
}

- (void)getPostData:(NSString *)url
{
    void (^postSuccess)(NSDictionary *);
    postSuccess = ^(NSDictionary *postData) {
        
        if (postData && [postData count] > 0) {
            
            [self drawPostLayout:postData[@"post"][@"list"]];
            [self loadPrdInfoLink];
        }
        else {
            [self loadPrdInfoLink];
        }
    };
    
    void (^postFailure)(NSError *);
    postFailure = ^(NSError *error) {
        [self loadPrdInfoLink];
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:postSuccess
                                                         failure:postFailure];
    }
    else {
        [self loadPrdInfoLink];
    }
}

- (void)getMiniMallData
{
    void (^miniMallSuccess)(NSDictionary *);
    miniMallSuccess = ^(NSDictionary *miniMallData) {
        
        if (miniMallData && [miniMallData count] > 0) {
            
            [self loadMiniMall:miniMallData];
            [self getCategoryPopularData];
        }
        else {
            [self getCategoryPopularData];
        }
    };
    
    void (^miniMallFailure)(NSError *);
    miniMallFailure = ^(NSError *error) {
        [self getCategoryPopularData];
    };
    
    NSString *url = miniMall[@"miniMallApiUrl"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:miniMallSuccess
                                                         failure:miniMallFailure];
    }
    else {
        [self getCategoryPopularData];
    }
}

- (void)getCategoryPopularData
{
    void (^categoryPopularSuccess)(NSDictionary *);
    categoryPopularSuccess = ^(NSDictionary *categoryPopularData) {
        
        if (categoryPopularData && [categoryPopularData count] > 0) {
            
            [self loadCategoryPopular:categoryPopularData];
            [self getDealRelationData];
        }
        else {
            [self getDealRelationData];
        }
    };
    
    void (^categoryPopularFailure)(NSError *);
    categoryPopularFailure = ^(NSError *error) {
        [self getDealRelationData];
    };
    
    NSString *url = categoryPopular[@"apiUrl"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:categoryPopularSuccess
                                                         failure:categoryPopularFailure];
    }
    else {
        [self getDealRelationData];
    }
}

- (void)getDealRelationData
{
    void (^dealRelationSuccess)(NSDictionary *);
    dealRelationSuccess = ^(NSDictionary *dealRelationData) {
        
        if (dealRelationData && [dealRelationData count] > 0) {
            
            [self loadDealRelation:dealRelationData];
            [self getPrdRecommendData];
        }
        else {
            [self getPrdRecommendData];
        }
    };
    
    void (^dealRelationFailure)(NSError *);
    dealRelationFailure = ^(NSError *error) {
        [self getPrdRecommendData];
    };
    
    NSString *url = dealRelation[@"apiUrl"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:dealRelationSuccess
                                                         failure:dealRelationFailure];
    }
    else {
        [self getPrdRecommendData];
    }
}

- (void)getPrdRecommendData
{
    void (^prdRecommendSuccess)(NSDictionary *);
    prdRecommendSuccess = ^(NSDictionary *prdRecommendData) {
        
        if (prdRecommendData && [prdRecommendData count] > 0) {
            
            [self loadPrdRecommend:prdRecommendData];
            [self loadLiveKeyword];
        }
        else {
            [self loadLiveKeyword];
        }
    };
    
    void (^prdRecommendFailure)(NSError *);
    prdRecommendFailure = ^(NSError *error) {
        [self loadLiveKeyword];
    };
    
    NSString *url = prdRecommend[@"recommendListApiUrl"];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:prdRecommendSuccess
                                                         failure:prdRecommendFailure];
    }
    else {
        [self loadLiveKeyword];
    }
}

#pragma mark - Private Methods

- (CGFloat)getMaxY
{
    return CGRectGetMaxY(cpFooterView.frame);
}

- (void)removeTouchTownShopListView
{
    if (townShopBranchListView) {
        [townShopBranchListView removeFromSuperview];
        townShopBranchListView = nil;
    }
}

- (void)startAutoScroll
{
    [liveKeywordLayout startAutoScroll];
}

- (void)stopAutoScroll
{
    [liveKeywordLayout stopAutoScroll];
}

#pragma mark - Selectors

- (void)didTouchExpandButton:(CPDescriptionBottomViewType)viewType height:(CGFloat)height
{
    if (viewType == CPDescriptionBottomViewTypeTownShop) {
        
        if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
            [self.delegate descriptionBottomView:self addContentHeight:height-(townShopBranchView.frame.size.height-10)];
        }
        
        offSetLiveKeywordY += height-(townShopBranchView.frame.size.height-10);
        
        CGFloat offset = 0;
        
        [townShopBranchView setFrame:CGRectMake(0, offSetTownShopBranchY, kScreenBoundsWidth, 10+height)];
        [townShopBranchLayer setFrame:CGRectMake(0, 10, townShopBranchLayer.frame.size.width, height)];
        offset = offSetTownShopBranchY+townShopBranchView.frame.size.height;
        [reviewItemView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, reviewItemView.frame.size.height)];
        offset += reviewItemView.frame.size.height;
        [postItemView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, postItemView.frame.size.height)];
        offset += postItemView.frame.size.height;
        [prdInfoLinkView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, prdInfoLinkView.frame.size.height)];
        offset += prdInfoLinkView.frame.size.height;
        [brandShopView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, brandShopView.frame.size.height)];
        offset += brandShopView.frame.size.height;
        [miniMallView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, miniMallView.frame.size.height)];
        offset += miniMallView.frame.size.height;
        [categoryPopularView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, categoryPopularView.frame.size.height)];
        offset += categoryPopularView.frame.size.height;
        [dealRelationView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, dealRelationView.frame.size.height)];
        offset += dealRelationView.frame.size.height;
        [prdRecommendView setFrame:CGRectMake(0, offset, kScreenBoundsWidth, prdRecommendView.frame.size.height)];
//        offset += prdRecommendView.frame.size.height;
        
        [liveKeywordView setFrame:CGRectMake(0, offSetLiveKeywordY, kScreenBoundsWidth, liveKeywordView.frame.size.height)];
        [bottomMarginView setFrame:CGRectMake(0, offSetLiveKeywordY+liveKeywordView.frame.size.height, kScreenBoundsWidth, 10)];
        [cpFooterView setFrame:CGRectMake(0, offSetLiveKeywordY+liveKeywordView.frame.size.height+10, cpFooterView.width, cpFooterView.height)];
        
    }
    else if (viewType == CPDescriptionBottomViewTypeLiveKeyword) {
        
        if ([self.delegate respondsToSelector:@selector(descriptionBottomView:addContentHeight:)]) {
            [self.delegate descriptionBottomView:self addContentHeight:height-(liveKeywordView.frame.size.height-10)];
        }
        
        [liveKeywordView setFrame:CGRectMake(0, offSetLiveKeywordY, kScreenBoundsWidth, 10+height)];
        [liveKeywordLayout setFrame:CGRectMake(0, 10, liveKeywordLayout.frame.size.width, height)];
        [bottomMarginView setFrame:CGRectMake(0, offSetLiveKeywordY+liveKeywordView.frame.size.height, kScreenBoundsWidth, 10)];
        [cpFooterView setFrame:CGRectMake(0, offSetLiveKeywordY+liveKeywordView.frame.size.height+10, cpFooterView.width, cpFooterView.height)];
    }
}

- (void)didTouchMapButton:(NSString *)linkUrl
{
    if ([self.delegate respondsToSelector:@selector(didTouchMapButton:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchMapButton:linkUrl];
        }
    }
}

- (void)didTouchTabMove:(NSInteger)pageIndex
{
    if ([self.delegate respondsToSelector:@selector(didTouchTabMove:)]) {
        [self.delegate didTouchTabMove:pageIndex];
    }
}

- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab
{
    if ([self.delegate respondsToSelector:@selector(didTouchTabMove:moveTab:)]) {
        [self.delegate didTouchTabMove:pageIndex moveTab:moveTab];
    }
}

- (void)didTouchSearchKeyword:(NSString *)keyword
{
    if ([self.delegate respondsToSelector:@selector(didTouchSearchKeyword:)]) {
        [self.delegate didTouchSearchKeyword:keyword];
    }
}

- (void)didTouchPrdSelInfo:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchPrdSelInfo:)]) {
        [self.delegate didTouchPrdSelInfo:url];
    }
}

- (void)didTouchProInfoNotice:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchProInfoNotice:)]) {
        [self.delegate didTouchProInfoNotice:url];
    }
}

- (void)didTouchInfoButton:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchInfoButton:)]) {
        [self.delegate didTouchInfoButton:url];
    }
}

- (void)didTouchSellerInfo:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerInfo:)]) {
        [self.delegate didTouchSellerInfo:url];
    }
}

- (void)didTouchShowPrdAll:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchShowPrdAll:)]) {
        [self.delegate didTouchShowPrdAll:url];
    }
}

- (void)didTouchSellerPrd:(NSString *)prdNo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:prdNo];
    }
}

- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type
{
    if ([self.delegate respondsToSelector:@selector(didTouchMoreButton:type:)]) {
        [self.delegate didTouchMoreButton:moreUrl type:type];
    }
}

- (void)didTouchReviewCell:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchReviewCell:)]) {
        [self.delegate didTouchReviewCell:url];
    }
}

- (void)didTouchCategoryArea:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchCategoryArea:)]) {
        [self.delegate didTouchCategoryArea:url];
    }
}

- (void)didTouchBrandShop:(NSString *)linkUrl;
{
    if ([self.delegate respondsToSelector:@selector(didTouchBrandShop:)]) {
        if (linkUrl && [[linkUrl trim] length] > 0) {
            [self.delegate didTouchBrandShop:linkUrl];
        }
    }
}

- (void)touchTownShopListButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == townShopBranchLayer.selectedIndex) {
        [self removeTouchTownShopListView];
        return;
    }
    
    townShopBranchLayer.selectedIndex = button.tag;
    [townShopBranchLayer setTownShopBranchView];
    
    [self removeTouchTownShopListView];
}

- (void)didTouchTownShopList:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    CGFloat listViewY = townShopBranchLayer.frame.origin.y+[townShopBranchLayer getListButtonY];
    NSArray *touchTownShopList = townShopBranch[@"shopLayer"];
    
    if (townShopBranchListView) {
        [self removeTouchTownShopListView];
        return;
    }
    
    if (touchTownShopList && touchTownShopList.count > 0) {
        
        //배송지 목록
        townShopBranchListView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x, listViewY, button.frame.size.width, touchTownShopList.count*32+2)];
        [self addSubview:townShopBranchListView];
        
        CGFloat cellHeight = 1;
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:backImage];
        [bgImageView setFrame:CGRectMake(0, 0, button.frame.size.width, touchTownShopList.count*32+2)];
        [townShopBranchListView addSubview:bgImageView];
        
        for (NSDictionary *dic in touchTownShopList) {
            
            UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [listButton setFrame:CGRectMake(1, cellHeight, button.frame.size.width-2, 32)];
            [listButton setTitle:dic[@"shopBranchNm"] forState:UIControlStateNormal];
            [listButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [listButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [listButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [listButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [listButton addTarget:self action:@selector(touchTownShopListButton:) forControlEvents:UIControlEventTouchUpInside];
            [listButton setTag:[touchTownShopList indexOfObject:dic]];
            [townShopBranchListView addSubview:listButton];
            
            //selected
            if (button.tag == [touchTownShopList indexOfObject:dic]) {
                [listButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [listButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [listButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
            }
            else {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(listButton.frame)-1, button.frame.size.width-2, 1)];
                [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
                [townShopBranchListView addSubview:lineView];
            }
            
            cellHeight += 32;
        }
    }
}

#pragma mark - CPDescriptionBottomTownShopBranch Delegate Method
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view isLoading:(NSNumber *)loading
{
    [self.delegate productTownShopBranchView:view isLoading:loading];
}

- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate productTownShopBranchView:view isLoading:[NSNumber numberWithBool:NO]];
}

@end
