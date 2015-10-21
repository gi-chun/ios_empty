//
//  CPProductThumbnailView.m
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductThumbnailView.h"
#import "CPRESTClient.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+Blocks.h"
#import "AccessLog.h"

#define THUMBNAIL_PAGECONTROLLER_TAG	100

@interface CPProductThumbnailView() <UIScrollViewDelegate>
{
    NSDictionary *product;
    
    NSArray *items;
    NSString *prefix;
    NSString *vendorIconType;
    NSDictionary *bookInfo;
    
    UIScrollView *thumbNailscrollView;
    UIView *pageControllerView;
    
    UIView *noSellItemView;
    
    NSInteger currentPage;
    NSInteger maxCount;
}

@end

@implementation CPProductThumbnailView

- (void)releaseItem
{
    if (items)  items = nil;
    if (prefix)  prefix = nil;
    if (vendorIconType) vendorIconType = nil;
    if (bookInfo)   bookInfo = nil;
    if (thumbNailscrollView)    thumbNailscrollView.delegate = nil, thumbNailscrollView = nil;
    if (pageControllerView) pageControllerView = nil;
    if (noSellItemView) noSellItemView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
        prefix = product[@"imgUrlPrefix"];
        
        vendorIconType = product[@"prdImg"][@"vendorIconType"];
        
        bookInfo = [product[@"prdImg"][@"bookIcons"] copy];
        
        [self initLayout];
        
        //gif만 이미지 ajax 호출
//        if (product[@"prdImg"][@"headerImgUrl"] && [product[@"prdImg"][@"headerImgUrl"] hasSuffix:@".gif"]) {
        if ([product[@"prdImg"][@"headerImgUrl"] hasSuffix:@".gif"] || (product[@"prdImg"][@"prdAddImg"] && product[@"prdImg"][@"prdAddImg600YN"])) {
            [self getHeaderImage];
        }
    }
    return self;
}

- (void)initLayout
{
    
    CGFloat thumbnailSize = 300;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            thumbnailSize);
    
    thumbNailscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(thumbnailSize/2), 0, thumbnailSize, thumbnailSize)];
    [thumbNailscrollView setPagingEnabled:YES];
    [thumbNailscrollView setBounces:NO];
    [thumbNailscrollView setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [thumbNailscrollView setShowsHorizontalScrollIndicator:NO];
    [thumbNailscrollView setShowsVerticalScrollIndicator:NO];
    [thumbNailscrollView setDelegate:self];
    [self addSubview:thumbNailscrollView];
    
    //이미지 로딩
    [self initThumbnailImage:product[@"prdImg"][@"headerImgUrl"]];
    
    //백화점/마트 아이콘
    if (vendorIconType) {
        UIImage *vendorImage = nil;
        if ([vendorIconType isEqualToString:@"homeplus"]) {
            vendorImage  = [UIImage imageNamed:@"ic_detail_homeplus.png"];
        }
        else if ([vendorIconType isEqualToString:@"gsmart"]) {
            vendorImage  = [UIImage imageNamed:@"ic_detail_gssuper.png"];
        }
        else if ([vendorIconType isEqualToString:@"hyundaiDept"]) {
            vendorImage  = [UIImage imageNamed:@"ic_detail_hyundaistore.png"];
        }
        
        UIImageView *venderIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(thumbNailscrollView.frame)+8, CGRectGetHeight(thumbNailscrollView.frame)-32, 105, 25)];
        [venderIconImageView setBackgroundColor:[UIColor clearColor]];
        [venderIconImageView setImage:vendorImage];
        [self addSubview:venderIconImageView];
    }
    
    //미리보기
    if (bookInfo) {
        UIImage *bgImage = [UIImage imageNamed:@"bt_pd_view.png"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [previewButton setFrame:CGRectMake(CGRectGetMaxX(thumbNailscrollView.frame)-89, CGRectGetHeight(thumbNailscrollView.frame)-41, 85, 36)];
        [previewButton setImage:[UIImage imageNamed:@"ic_pd_view.png"] forState:UIControlStateNormal];
        [previewButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        [previewButton setTitle:bookInfo[@"text"] forState:UIControlStateNormal];
        [previewButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [previewButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [previewButton addTarget:self action:@selector(touchPreviewButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previewButton];
    }
    
    //상품이미지 노출여부
    if ([@"N" isEqualToString:product[@"prdImgViewYn"]]) {
        [self initNoSellItemView];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1)];
    [lineView setBackgroundColor:UIColorFromRGBA(0x000000, 0.12f)];
    [self addSubview:lineView];
}

- (void)initThumbnailImage:(NSString *)headerImgUrl
{
    for (UIView *subView in thumbNailscrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (headerImgUrl) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(thumbNailscrollView.frame),CGRectGetHeight(thumbNailscrollView.frame))];
        [imageView sd_setImageWithURL:[NSURL URLWithString:headerImgUrl]];
        
        [thumbNailscrollView addSubview:imageView];
    }
    else {
        //헤더이미지 맥스값 10
        maxCount = (items.count > 10 ? 10 : items.count);
        
        [thumbNailscrollView setContentSize:CGSizeMake(CGRectGetWidth(thumbNailscrollView.frame) * maxCount, CGRectGetHeight(thumbNailscrollView.frame))];
        
//        NSInteger screenSize = (NSInteger)(thumbNailscrollView.frame.size.width * [[UIScreen mainScreen] scale]);
        
        for (NSInteger i = 0; i< maxCount; i++) {
//            if (!prefix) {
//                return;
//            }
//            
//            NSString *imageUrl = [NSString stringWithString:prefix];
//            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%ld", (long)screenSize]];
//            imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%ld", (long)screenSize]];
//            //        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:items[i]];
//            imageUrl = [imageUrl stringByAppendingString:items[i]];
//            // http://i.011st.com/ex_t/R/300x300/1/80/0/0/src/ak/8/3/2/1/3/2/183832132_B_V18.gif
            
            if (!nilCheck(items[i])) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(thumbNailscrollView.frame)*i, 0, CGRectGetWidth(thumbNailscrollView.frame),CGRectGetHeight(thumbNailscrollView.frame))];
                [imageView sd_setImageWithURL:[NSURL URLWithString:items[i]]];
                
                [thumbNailscrollView addSubview:imageView];
            }
        }
        
        [self initPageController];
    }
}

- (void)initPageController
{
    if (maxCount <= 1) {
        return;
    }
    
    if (pageControllerView) {
        [pageControllerView removeFromSuperview];
    }
    
    currentPage = -1;
    
    UIImage *imgOff = [UIImage imageNamed:@"indicator_pd_off.png"];
    
    CGFloat width = (maxCount * (imgOff.size.width)) + ((maxCount-1) * 3.f);
    
    pageControllerView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(width/2), 10, width, imgOff.size.height)];
    [pageControllerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:pageControllerView];
    
    CGFloat offsetX = 0.f;
    for (NSInteger i = 0; i < maxCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, imgOff.size.width, imgOff.size.height)];
        imageView.tag = THUMBNAIL_PAGECONTROLLER_TAG+i;
        [pageControllerView addSubview:imageView];
        
        offsetX += imgOff.size.width + 2.f;
    }
    
    [self setPageController:0];
}

- (void)initNoSellItemView
{
    noSellItemView = [[UIView alloc] initWithFrame:thumbNailscrollView.frame];
    [noSellItemView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:noSellItemView];
    
    UILabel *statementLabel = [[UILabel alloc] initWithFrame:CGRectMake(-0, 0, CGRectGetWidth(noSellItemView.frame), CGRectGetHeight(noSellItemView.frame))];
    [statementLabel setText:@"현재 판매중인 상품이 아닙니다."];
    [statementLabel setFont:[UIFont systemFontOfSize:20]];
    [statementLabel setTextColor:UIColorFromRGB(0x999999)];
    [statementLabel setTextAlignment:NSTextAlignmentCenter];
    [statementLabel setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [noSellItemView addSubview:statementLabel];
}

- (void)setPageController:(NSInteger)idx
{
    if (currentPage == idx) return;
    
    UIImage *imgOn = [UIImage imageNamed:@"indicator_pd_on.png"];
    UIImage *imgOff = [UIImage imageNamed:@"indicator_pd_off.png"];
    
    for (NSInteger i = 0; i < maxCount; i++) {
        UIImageView *imageView = (UIImageView *)[pageControllerView viewWithTag:THUMBNAIL_PAGECONTROLLER_TAG + i];
        if (imageView) {
            if (idx == i) {
                imageView.image = imgOn;
            }
            else {
                imageView.image = imgOff;
            }
        }
    }
    
    currentPage = idx;
    
    //AccessLog - 이미지 좌우 스와이프
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPA01"];
}

- (void)setHiddenNoSellItemView:(BOOL)isHidden
{
    if (noSellItemView.hidden == isHidden) {
        return;
    }
    
    noSellItemView.hidden = isHidden;
}

- (BOOL)validateMyPriceResult:(NSArray *)priceCells
{
    NSInteger discountResult = 0;
    
//    for (int i=0; i<self.myPriceModel.priceCells.count; i++)
//    {
//        MyPriceLineModel *lineModel = (MyPriceLineModel *)self.myPriceModel.priceCells[i];
//        
//        if (![lineModel.type isEqualToString:@"selPrc"]
//            && ![lineModel.type isEqualToString:@"finalDscPrc"]
//            && ![lineModel.type isEqualToString:@"totalMyPrice"])
//        {
//            discountResult++;
//        }
//    }
    
    return (discountResult == 0 ? NO : YES);
}

#pragma mark - Selectors

- (void)touchPreviewButton
{
    [UIAlertView showWithTitle:STR_APP_TITLE
                       message:@"미리보기는 SKT 데이터프리가 적용되지 않습니다."
             cancelButtonTitle:@"확인"
             otherButtonTitles:@[ @"취소" ]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == alertView.cancelButtonIndex) {
                              if (bookInfo[@"linkUrl"] && [self.delegate respondsToSelector:@selector(didTouchPreviewButton:)]) {
                                  [self.delegate didTouchPreviewButton:bookInfo[@"linkUrl"]];
                              }
                          }
                      }];
    
    //AccessLog - 도서 상품 미리보기 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPA02"];
}

#pragma mark - UIScrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (pageControllerView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1;
        
        [self setPageController:page];
    }
}

#pragma mark - API 

- (void)getHeaderImage
{
    NSString *url = PRODUCT_HEADER_IMAGE_URL;
    if (product[@"prdImg"][@"prdAddImg"] && product[@"prdImg"][@"prdAddImg600YN"]) {
        NSString *prdAddImg600YN = product[@"prdImg"][@"prdAddImg600YN"];
        prdAddImg600YN = [prdAddImg600YN stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *prdAddImg = product[@"prdImg"][@"prdAddImg"];
        prdAddImg = [prdAddImg stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        url = [url stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:product[@"prdImg"][@"imgUrl"]];
        url = [url stringByReplacingOccurrencesOfString:@"{{size}}" withString:product[@"prdImg"][@"imgSize"]];
        url = [url stringByReplacingOccurrencesOfString:@"{{prdAddImg600YN}}" withString:prdAddImg600YN];
        url = [url stringByReplacingOccurrencesOfString:@"{{prdAddImg}}" withString:prdAddImg];
        
        if (url) {
            [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                             success:^(NSDictionary *result) {
                                                                 if (result) {
                                                                     if ([[result[@"status"][@"code"] stringValue] isEqualToString:@"200"]) {
                                                                         items = [result[@"images"] copy];
                                                                         
                                                                         [self initThumbnailImage:nil];
                                                                     }
                                                                 }
                                                                 else {
                                                                     
                                                                 }
                                                             }
                                                             failure:^(NSError *error) {
                                                                 
                                                             }];
        }
    }
}

@end
