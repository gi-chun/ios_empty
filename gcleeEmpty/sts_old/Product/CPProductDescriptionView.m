//
//  CPProductDescriptionView.m
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPProductDescriptionView.h"
#import "CPDescriptionBottomView.h"
#import "CPErrorContentsView.h"
#import "CPThumbnailView.h"

#import "CMDQueryStringSerialization.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "NSString+URLEncodedString.h"
#import "AccessLog.h"

#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPProductViewController.h"

#define ImgViewTag 5500

const NSString *kImageDownloadUrl = @"URL";
const NSString *kImageDownloadStatus = @"STATUS";

static NSString *const kProductInfoSmartOptionDetailScheme = @"app://smart_option/detail_view?";
static NSString *const kProductInfoSmartOptionInsertScheme = @"app://smart_option/insert?";

@interface CPProductDescriptionView() <UIScrollViewDelegate,
                                       CPDescriptionBottomViewDelegate,
                                       CPErrorContentsViewDelegate,
                                       UIWebViewDelegate>
{
    NSDictionary *product;
    NSDictionary *descInfo;
    NSArray *descImages;
    
    //10개이하
    NSMutableArray *imageArr;
    //11이후
    NSMutableArray *imageArrMore;
    
    UIScrollView *imageScrollView;
    UIView *contentsView;
    UIView *imageDescriptionView;
    UIView *encoreDealView;
    CPErrorContentsView *errorContentsView;
    UIButton *imageMoreButton;
    CPDescriptionBottomView *descriptionBottomView;
    
    //smartOption
    UIWebView *smartOptionWebView;
    
    //판매자 공지
    UIView *sellerNoticeView;
    
    NSString *prdNo;
    
    BOOL isLoadReview;
    BOOL isClose;
    BOOL isPauseDownloading;
    BOOL isResizeImageView;
    BOOL isZooming;
    
    NSInteger failedCount;
    
    CGSize firstImageSize;
    CGSize endImageSize;
    NSInteger viewPointIndex;
    
    CGFloat baseWidth;
    CGFloat baseHegiht;
    CGFloat lastViewIndex;
    
    NSString *documentFolder;
    NSString *currentDate;
    
    id <SDWebImageOperation> imageDownloadManager;
}

@end

@implementation CPProductDescriptionView

- (void)removeMemory
{
    [self stopAutoScroll];
    
    for (NSInteger i = 0; i < [imageArr count]; i++) {
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag + i];
        
        if (imageView) {
            imageView.image = nil;
            [imageView removeFromSuperview];
            imageView = nil;
        }
    }
    
    if (product)            product = nil;
    if (descInfo)           descInfo = nil;
    if (descImages)         descImages = nil;
    if (imageArr)           imageArr = nil;
    if (imageArrMore)       imageArrMore = nil;
    
    if (imageScrollView)            [imageScrollView removeFromSuperview], imageScrollView = nil;
    if (contentsView)               [contentsView removeFromSuperview], contentsView = nil;
    if (imageDescriptionView)       [imageDescriptionView removeFromSuperview], imageDescriptionView = nil;
    if (encoreDealView)             [encoreDealView removeFromSuperview], encoreDealView = nil;
    if (errorContentsView)          [errorContentsView removeFromSuperview], errorContentsView = nil;
    if (descriptionBottomView)      [descriptionBottomView removeFromSuperview], descriptionBottomView = nil;
    if (sellerNoticeView)           [sellerNoticeView removeFromSuperview], sellerNoticeView = nil;
}

- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct
{
    if (self = [super initWithFrame:frame]) {
        
        product = [aProduct copy];
        
        if (product[@"prdDescImage"]) {
            descInfo = [product[@"prdDescImage"] copy];
            descImages = [NSArray arrayWithArray:descInfo[@"images"]];
            
            imageArr = [NSMutableArray array];
            imageArrMore = [NSMutableArray array];
            
            for (NSInteger i =0; i < descImages.count; i++) {
                
                NSString *imageUrl = descImages[i];
                if (i < 10) {
                    [imageArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         imageUrl, kImageDownloadUrl,
                                         @"READY", kImageDownloadStatus, nil]];
                }
                else {
                    [imageArrMore addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         imageUrl, kImageDownloadUrl,
                                         @"READY", kImageDownloadStatus, nil]];
                }
            }
            
            documentFolder = [[NSString alloc] initWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                                    NSUserDomainMask, YES)
                                                                lastObject]];
            currentDate = [[NSString alloc] initWithString:[Modules dateStringWithType:9]];
            
            [self initLayout];
        }
    }
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:UIColorFromRGB(0xffffff)];;
    
    viewPointIndex = -1;
    lastViewIndex = -1;
    baseWidth = self.frame.size.width;
    baseHegiht = self.frame.size.height;
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.delegate = self;
    imageScrollView.bounces = YES;
    imageScrollView.pagingEnabled = NO;
    imageScrollView.maximumZoomScale = 2.f;
    imageScrollView.clipsToBounds = YES;
    [self addSubview:imageScrollView];
    
    imageScrollView.contentSize = CGSizeMake(0, imageScrollView.frame.size.height+1);
    
    contentsView = [[UIView alloc] initWithFrame:imageScrollView.bounds];
    [imageScrollView addSubview:contentsView];
    
    [self initEncoreDealView];
    [self initContentsImage];
}

- (void)initContentsImage
{
    //상품상세 이미지 노출여부
    if ([@"N" isEqualToString:product[@"prdDetailImgViewYn"]]) {
        UILabel *statementLabel = [[UILabel alloc] initWithFrame:CGRectMake(-0, CGRectGetMaxY(encoreDealView.frame)+10, CGRectGetWidth(contentsView.frame), CGRectGetHeight(contentsView.frame))];
        [statementLabel setText:@"현재 판매중인 상품이 아닙니다."];
        [statementLabel setFont:[UIFont systemFontOfSize:20]];
        [statementLabel setTextColor:UIColorFromRGB(0x999999)];
        [statementLabel setTextAlignment:NSTextAlignmentCenter];
        [statementLabel setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
        [contentsView addSubview:statementLabel];
        
        [self addBottomView:CGRectGetMaxY(statementLabel.frame)];
    }
    else {
        //smartOptionURL
        if ([descInfo[@"detailViewType"] isEqualToString:@"tagging"]) { //스마트옵션
            
            [self initSellerNotice];
            
            //웹뷰
            smartOptionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(encoreDealView.frame)+10, contentsView.frame.size.width, 0)];
            smartOptionWebView.delegate = self;
            smartOptionWebView.autoresizingMask = UIViewAutoresizingNone;
            smartOptionWebView.scrollView.scrollEnabled = NO;
            smartOptionWebView.scrollView.scrollsToTop = NO;
            
            [contentsView addSubview:smartOptionWebView];
            
            NSString *smartOptionURL = descInfo[@"smartOptionURL"];
            [smartOptionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:smartOptionURL]]];
            
            //bottomView
//            [self addBottomView:offsetY];
            
        }
        else {
            if (!imageArr || [imageArr count] == 0) {
                [self addNoDataImage];
            }
            else {
                [self initImageDescriptionView];
                [self initSellerNotice];
                
                for (NSInteger i = 0; i < [imageArr count]; i++) {
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
                    [imgView setTag:ImgViewTag + i];
                    [imgView setHidden:YES];
                    [contentsView addSubview:imgView];
                }
                
                [self loadContentsImage];
            }
        }
    }
}

- (void)initImageDescriptionView
{
    UIImage *bgImage = [[UIImage imageNamed:@"bg_pd_encoredeal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    imageDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(encoreDealView.frame), CGRectGetWidth(self.frame), 76)];
    [contentsView addSubview:imageDescriptionView];
    
    UIImageView *containerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(imageDescriptionView.frame)-20, 66)];
    [containerView setImage:bgImage];
    [imageDescriptionView addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, CGRectGetWidth(containerView.frame)-26, CGRectGetHeight(containerView.frame))];
    [titleLabel setText:@"아래 이미지는 이미지 크기를 최적화 하여, 데이터 비용에 부담이 가지 않도록 조정한 이미지입니다. \n(자세한 내용은 PC버전 상품상세 버튼을 눌러주세요.)"];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [titleLabel setTextColor:UIColorFromRGB(0x999999)];
    [titleLabel setNumberOfLines:0];
    [containerView addSubview:titleLabel];
}

- (void)initEncoreDealView
{
    UIImage *bgImage = [[UIImage imageNamed:@"bg_pd_encoredeal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    encoreDealView = [[UIView alloc] initWithFrame:CGRectZero];
    [contentsView addSubview:encoreDealView];
    
    if (product[@"dealEncore"]) {
        [encoreDealView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 76)];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(encoreDealView.frame)-20, 66)];
        [bgView setImage:bgImage];
        [encoreDealView addSubview:bgView];
        
        UIView *containerView = [[UIImageView alloc] init];
        [bgView addSubview:containerView];
        
        UIImageView *encoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 52, 52)];
        [encoreImageView setImage:[UIImage imageNamed:@"ic_pd_encoredeal.png"]];
        [containerView addSubview:encoreImageView];
        
        NSString *titleStr = product[@"dealEncore"][@"text"];
        CGSize titleStrSize = [titleStr sizeWithFont:[UIFont systemFontOfSize:13]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(encoreImageView.frame)+10, 16, titleStrSize.width, 17)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:titleStr];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        [titleLabel setTextColor:UIColorFromRGB(0x6b6b6b)];
        [containerView addSubview:titleLabel];
        
        NSString *descStr = product[@"dealEncore"][@"subText"];
        CGSize descStrSize = [descStr sizeWithFont:[UIFont boldSystemFontOfSize:13]];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(encoreImageView.frame)+10, 33, descStrSize.width, 17)];
        [descLabel setBackgroundColor:[UIColor clearColor]];
        [descLabel setText:descStr];
        [descLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [descLabel setTextColor:UIColorFromRGB(0x5765ff)];
        [containerView addSubview:descLabel];
        
        CGFloat containerWidth = CGRectGetWidth(encoreImageView.frame) + 10 + MAX(CGRectGetWidth(titleLabel.frame), CGRectGetWidth(descLabel.frame));
        [containerView setFrame:CGRectMake((CGRectGetWidth(bgView.frame)-containerWidth)/2, 0, containerWidth, 66)];
    }
}

- (void)initSellerNotice
{
    CGFloat originY = CGRectGetMaxY(imageDescriptionView.frame) + 10;
    
    if (!sellerNoticeView && product[@"sellerNotiLinkUrl"]) {
        
        sellerNoticeView = [[UIView alloc] initWithFrame:CGRectMake(10, originY+8, 83, 63)];
        [sellerNoticeView setBackgroundColor:[UIColor clearColor]];
        [imageScrollView addSubview:sellerNoticeView];
        
        UIButton *closeSellerNoticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeSellerNoticeButton setFrame:CGRectMake(CGRectGetWidth(sellerNoticeView.frame)-6-10, 0, 10, 10)];
        [closeSellerNoticeButton setBackgroundImage:[UIImage imageNamed:@"ic_pd_floating_close.png"] forState:UIControlStateNormal];
        [closeSellerNoticeButton addTarget:self action:@selector(touchCloseSellerNotice:) forControlEvents:UIControlEventTouchUpInside];
        [sellerNoticeView addSubview:closeSellerNoticeButton];
        
        UIImageView *noticeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(closeSellerNoticeButton.frame)+3, 83, 50)];
        [noticeView setImage:[UIImage imageNamed:@"bt_pd_floating_notice.png"]];
        [sellerNoticeView addSubview:noticeView];
        
        UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [blankButton setFrame:CGRectMake(0, 10, sellerNoticeView.frame.size.width, sellerNoticeView.frame.size.height-10)];
        [blankButton setBackgroundImage:[UIImage imageNamed:@"bg_000000.png"] forState:UIControlStateHighlighted];
        [blankButton setAlpha:0.3];
        [blankButton addTarget:self action:@selector(touchSellerNotice:) forControlEvents:UIControlEventTouchUpInside];
        [sellerNoticeView addSubview:blankButton];
    }
}

- (void)addImageMoreButton:(CGFloat)offsetY
{
    CGRect frame = contentsView.frame;
    frame.size.height += 44;
    contentsView.frame = frame;
    
    imageMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageMoreButton setFrame:CGRectMake(0, offsetY, baseWidth, 44)];
    [imageMoreButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [imageMoreButton addTarget:self action:@selector(touchMoreImageButton:) forControlEvents:UIControlEventTouchUpInside];
    [imageMoreButton setAccessibilityLabel:@"이미지 더보기"];
    [contentsView addSubview:imageMoreButton];
    
    NSString *moreStr = @"이미지 더보기";
    CGSize moreStrSize = [moreStr sizeWithFont:[UIFont systemFontOfSize:15]];
    
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake((baseWidth-(moreStrSize.width+7+13))/2, 0, moreStrSize.width, 44)];
    [moreLabel setText:moreStr];
    [moreLabel setFont:[UIFont systemFontOfSize:15]];
    [moreLabel setTextColor:UIColorFromRGB(0x283593)];
    [imageMoreButton addSubview:moreLabel];
    
    UIImageView *moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moreLabel.frame)+7, 18.5f, 13, 7)];
    [moreImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down_02.png"]];
    [imageMoreButton addSubview:moreImageView];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    [topLineView setBackgroundColor:UIColorFromRGB(0xdfdfdf)];
    [imageMoreButton addSubview:topLineView];
    
    //AccessLog - 이미지 더보기 노출
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ03"];
}

- (void)addBottomView:(CGFloat)offsetY
{
    NSString *smartOptionURL = descInfo[@"smartOptionURL"];
    if (smartOptionURL && [[smartOptionURL trim] length] > 0) {
        descriptionBottomView = [[CPDescriptionBottomView alloc] initWithFrame:CGRectMake(0, offsetY, baseWidth, 0) product:product];
        [descriptionBottomView setDelegate:self];
        [contentsView addSubview:descriptionBottomView];
        
        //descriptionBottomView 길이만큼 content영역 추가
//        CGRect contentFrame = contentsView.frame;
//        contentFrame.size.height += [descriptionBottomView getMaxY];
//        contentsView.frame = contentFrame;
        
        imageScrollView.contentSize = CGSizeMake(imageScrollView.contentSize.width, contentsView.frame.size.height);
    }
    else {
        if (!descriptionBottomView) {
            descriptionBottomView = [[CPDescriptionBottomView alloc] initWithFrame:CGRectMake(0, offsetY, baseWidth, 0) product:product];
            [descriptionBottomView setDelegate:self];
            [contentsView addSubview:descriptionBottomView];
        }
        else {
            //이미지 더보기 후
            [descriptionBottomView setFrame:CGRectMake(0, offsetY, baseWidth, descriptionBottomView.frame.size.height)];
            
            //descriptionBottomView 길이만큼 content영역 추가
            CGRect contentFrame = contentsView.frame;
            contentFrame.size.height += [descriptionBottomView getMaxY];
            contentsView.frame = contentFrame;
            
            imageScrollView.contentSize = CGSizeMake(imageScrollView.contentSize.width, contentsView.frame.size.height);
        }
    }
}

- (void)addNoDataImage
{
    if (errorContentsView) return;
    
    errorContentsView = [[CPErrorContentsView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(encoreDealView.frame)+10,
                                                                             contentsView.frame.size.width,
                                                                             contentsView.frame.size.height)];
    errorContentsView.isRetryButton = NO;
    errorContentsView.errorIcon = @"ic_noimage.png";
    errorContentsView.errorText = @"저장된 이미지가 없습니다.\n원본 보기를 이용해주세요.";
    [contentsView addSubview:errorContentsView];
    
    if (!isLoadReview)
    {
        [self addBottomView:CGRectGetMaxY(errorContentsView.frame)];
        isLoadReview = YES;
    }
}

#pragma mark - Private Methods

- (void)startAutoScroll
{
    [descriptionBottomView startAutoScroll];
}

- (void)stopAutoScroll
{
    [descriptionBottomView stopAutoScroll];
}

#pragma mark - Selectors

- (void)touchBanner
{
//    NSString *linkUrl = bannerInfo[@"bannerLink"];
    
    //    if ([self.delegate respondsToSelector:@selector(didTouchLineBannerButton:)]) {
    //        if (linkUrl && [[linkUrl trim] length] > 0) {
    //            [self.delegate didTouchLineBannerButton:linkUrl];
    //        }
    //    }
    
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

- (void)didTouchSellerPrd:(NSString *)aPrdNo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSellerPrd:)]) {
        [self.delegate didTouchSellerPrd:aPrdNo];
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

- (void)touchSellerNotice:(id)sender
{
    NSString *url = product[@"sellerNotiLinkUrl"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchSellerNotice:)]) {
        if (url && [[url trim] length] > 0) {
            [self.delegate didTouchSellerNotice:url];
        }
    }
    
    //AccessLog - 판매자공지 보기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ02"];
}

- (void)touchCloseSellerNotice:(id)sender
{
    [sellerNoticeView removeFromSuperview];
}

#pragma mark - image download & setting

- (void)resumeImageDownloading
{
    if (!isPauseDownloading) {
        return;
    }
    
    isPauseDownloading = NO;
    [self loadContentsImage];
}

- (void)pauseImageDownloading
{
    isPauseDownloading = YES;
}

- (void)cancelImageDownloading
{
    isClose = YES;
    
    if (imageDownloadManager) {
        [imageDownloadManager cancel],
        imageDownloadManager = nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self removeImageFolder];
}

- (BOOL)checkDownloadImageArray
{
    if ([imageArr count] == 0) {
        return NO;
    }
    
    NSInteger readyCount = 0;
    for (NSInteger i=0; i<[imageArr count]; i++) {
        NSString *status = imageArr[i][kImageDownloadStatus];
        
        if ([status isEqualToString:@"READY"]) {
            readyCount++;
        }
    }
    
    return (readyCount == 0 ? NO : YES);
}

- (void)loadContentsImage
{
    if (![self checkDownloadImageArray]) {
        //이미지 다운로드 완료
        return;
    }
    
    //일시정지
    if (isPauseDownloading) {
        return;
    }
    
    NSInteger downloadIndex = [self getIndexWithPosition:@"FIRST"];
    if (downloadIndex == -1) {
        downloadIndex = [self getIndexWithPosition:@"END"];
    }
    
    if (downloadIndex == -1) {
        downloadIndex = [self getIndexWithPosition:@"MIDDLE"];
    }
    
    if (downloadIndex != -1) {
        [self downloadContentsImage:downloadIndex];
    }
}

- (void)downloadContentsImage:(NSInteger)downloadIndex
{
    NSString *url = [imageArr[downloadIndex][kImageDownloadUrl] trim];
    
    imageArr[downloadIndex][kImageDownloadStatus] = @"DOWNLOADING";
    
    UIImage *contentImage = [self getImage:url];
    if (contentImage) {
        [self successImageLoad:contentImage url:url index:downloadIndex];
        return;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    imageDownloadManager = [manager downloadImageWithURL:[NSURL URLWithString:[url trim]]
                                                  options:SDWebImageCacheMemoryOnly
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize)
                             {
                                 
                             }
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                             {
                                 imageDownloadManager = nil;
                                 if (isClose) {
                                     return;
                                 }
                                 
                                 if (finished && error == nil) {
                                     [self saveImage:url image:image];
                                     [self successImageLoad:image url:url index:downloadIndex];
                                     failedCount = 0;
                                 }
                                 else {
                                     if (failedCount >= 2) {
                                         if (!isResizeImageView) {
                                             //첫번째 이미지와 마지막 이미지를 다운받지 못했을 때
                                             [self performSelectorOnMainThread:@selector(addNoDataImage) withObject:nil waitUntilDone:NO];
                                         }
                                         else {
                                             //현재 항목을 삭제하고 재시도 한다.
                                             failedCount = 0;
                                             imageArr[downloadIndex][kImageDownloadStatus] = @"READY";
                                             [self loadContentsImage];
                                         }
                                         return;
                                     }
                                     
                                     //재시도
                                     failedCount++;
                                     [self loadContentsImage];
                                 }
                             }];
}

- (void)successImageLoad:(UIImage *)image url:(NSString *)url index:(NSInteger)downloadIndex
{
    imageArr[downloadIndex][kImageDownloadStatus] = @"FINISHED";
    
    if (downloadIndex == 0) {
        //최초 이미지 사이즈를 저장해 놓는다.
        firstImageSize = image.size;
    }
    
    if (imageArr.count > 1 && downloadIndex == imageArr.count-1) {
        //마지막 이미지 사이즈를 저장해 놓는다.
        endImageSize = image.size;
    }
    
    if ([imageArr count] == 1 && !CGSizeEqualToSize(CGSizeZero, firstImageSize)) {
        if (!isResizeImageView)	{
            [self resizeContentsImageView];
        }
    }
    else if ([imageArr count] > 1
             && !CGSizeEqualToSize(CGSizeZero, firstImageSize)
             && !CGSizeEqualToSize(CGSizeZero, endImageSize)) {
        if (!isResizeImageView)	[self resizeContentsImageView];
    }
    
    //다음 파일을 다운로드 받는다.
    [self loadContentsImage];
    
    [self performSelectorOnMainThread:@selector(checkUserViewPoint:)
                           withObject:[NSNumber numberWithFloat:imageScrollView.contentOffset.y]
                        waitUntilDone:NO];
}

-  (NSString *)getImageFolderPath
{
    //상품상세를 통해 동일한 상품을 열수있어 "시간"을 붙여준다.(종료시 이미지 삭제 안되도록)
    NSString *folder = [NSString stringWithString:documentFolder];
    NSString *folderStr = [NSString stringWithFormat:@"productImage_%@_%@", prdNo, currentDate];
    
    return [folder stringByAppendingPathComponent:folderStr];
}

- (void)removeImageFolder
{
    NSInteger viewCount = 0;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
    
    for (UIViewController *controller in homeViewController.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[CPProductViewController class]]) {
            viewCount++;
        }
    }
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (viewCount == 0) {
        //모든 이미지를 삭제한다. (사용자가 상품상세에서 강제종료할 경우 남아있는 이미지 폴더를 모두 지운다.)
        NSArray *documentFolderArr = [fileManager contentsOfDirectoryAtPath:documentFolder error:nil];
        for (NSInteger i = 0; i<[documentFolderArr count]; i++) {
            NSString *folderPath = [documentFolderArr objectAtIndex:i];
            if ([folderPath compareToken:@"productImage"]) {
                NSString *deletePath = [documentFolder stringByAppendingPathComponent:folderPath];
                [fileManager removeItemAtPath:deletePath error:nil];
            }
        }
    }
    else {
        //현재 보고있는 화면의 이미지만 삭제한다.
        NSString *imageFolder = [self getImageFolderPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:imageFolder]) {
            [fileManager removeItemAtPath:imageFolder error:nil];
        }
    }
}

- (void)saveImage:(NSString *)fileUrl image:(UIImage *)image
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^(void) {
        
        NSString *imageFolder = [self getImageFolderPath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:imageFolder]) {
            //폴더가 없을 경우
            [fileManager createDirectoryAtPath:imageFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *fileName = [fileUrl stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
        fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        fileName = [imageFolder stringByAppendingPathComponent:fileName];
        
        NSInteger tokenNum = [fileName indexOfBackwardSearch:@"?"];
        if (tokenNum != -1) {
            fileName = [fileName substringWithRange:NSMakeRange(0, tokenNum)];
        }
        
        NSData* imageData = UIImagePNGRepresentation(image);
        if (imageData) {
            [imageData writeToFile:fileName atomically:YES];
        }
    });
}

- (UIImage *)getImage:(NSString *)fileUrl
{
    NSString *imageFolder = [self getImageFolderPath];
    
    NSString *fileName = [fileUrl stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    fileName = [imageFolder stringByAppendingPathComponent:fileName];
    
    NSInteger tokenNum = [fileName indexOfBackwardSearch:@"?"];
    if (tokenNum != -1) {
        fileName = [fileName substringWithRange:NSMakeRange(0, tokenNum)];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:fileName];
    
    return image;
}

- (NSInteger)getIndexWithPosition:(NSString *)po
{
    if ([@"FIRST" isEqualToString:po]) {
        NSString *status = imageArr[0][kImageDownloadStatus];
        if ([@"READY" isEqualToString:status]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    
    if ([@"END" isEqualToString:po]) {
        
        if (imageArr.count == 1) {
            return -1;
        }
        
        NSString *status = imageArr[([imageArr count]-1)][kImageDownloadStatus];
        if ([@"READY" isEqualToString:status]) {
            return [imageArr count]-1;
        }
        else {
            return -1;
        }
    }
    
    if ([@"MIDDLE" isEqualToString:po]) {
        if (viewPointIndex == -1) {
            viewPointIndex = 0;
        }
        
        //현재 보고있는 화면으로부터 밑으로 다운로드 받는다. (앱사용 패턴 위에서 아래로 보니까.)
        //현재 보고있는 인덱스부터 받으면 화면에 걸친 전이미지가 안보이기때문에 현재인덱스-1부터 다운로드 받는다.
        NSInteger findNum = -1;
        NSInteger startIndex = (viewPointIndex-1 > 0 ? viewPointIndex-1 : 0);
        for (NSInteger i=startIndex; i<[imageArr count]; i++) {
            NSString *status = imageArr[i][kImageDownloadStatus];
            if ([@"READY" isEqualToString:status]) {
                findNum = i;
                break;
            }
        }
        
        //현재 보고있는 화면부터 밑으로 이미지를 모두 다운로드 받았다면 비어있는 이미지를 다운받는다. (아래에서 위로 받는다.)
        if (findNum == -1) {
            NSInteger startIndex = (viewPointIndex > (imageArr.count-1) ? (imageArr.count-1) : viewPointIndex);
            for (NSInteger i=startIndex; i>=0; i--) {
                NSString *status = imageArr[i][kImageDownloadStatus];
                if ([@"READY" isEqualToString:status]) {
                    findNum = i;
                    break;
                }
            }
        }
        
        return findNum;
    }
    
    return -1;
}

- (void)resizeContentsImageView
{
    CGFloat screenWidth = contentsView.frame.size.width;
    CGFloat ratio = firstImageSize.width / screenWidth;
    CGFloat height = firstImageSize.height / ratio;
    
    //이미지정보 위치부터 뿌려준다.
    CGFloat originY = CGRectGetMaxY(imageDescriptionView.frame) + 10;
    
    if ([imageArr count] > 1) {
        for (NSInteger i=0; i<[imageArr count]-1; i++)
        {
            UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag + i];
            if (imageView) {
                imageView.frame = CGRectMake(0, originY, screenWidth, height);
                imageView.hidden = NO;
            }
            
            originY += height;
        }
        
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag+imageArr.count-1];
        if (imageView) {
            imageView.frame = CGRectMake(0, originY, screenWidth, endImageSize.height / ratio);
            imageView.hidden = NO;
        }
        
        originY += (endImageSize.height / ratio);
    }
    else {
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag];
        if (imageView) {
            imageView.frame = CGRectMake(0, originY, screenWidth, height);
            imageView.hidden = NO;
        }
        
        originY += height;
    }
    
    contentsView.frame  = CGRectMake(0, 0, contentsView.frame.size.width, originY);
    if (contentsView.frame.size.height < imageScrollView.frame.size.height) {
        imageScrollView.contentSize = CGSizeMake(0, imageScrollView.frame.size.height+1);
        
        if (!isLoadReview) {
            CGFloat offsetY = CGRectGetMaxY(contentsView.frame);
            
            //더보기 버튼
            if ([imageArr count] == 10 && [imageArrMore count] > 0) {
                [self addImageMoreButton:offsetY];
                offsetY += 44;
            }
            
            [self addBottomView:offsetY];
            isLoadReview = YES;
        }
    } else {
        imageScrollView.contentSize = CGSizeMake(0, contentsView.frame.size.height);
    }
    
    [self performSelector:@selector(checkUserViewPoint:)
               withObject:[NSNumber numberWithFloat:imageScrollView.contentOffset.y]
               afterDelay:0.3f];
    
    isResizeImageView = YES;
}

- (void)checkUserViewPoint:(NSNumber *)numberOffsetY
{
    //이미지가 한장일 경우 오류처리 (이미지가 한장이면서 높이가 화면보다 작을 때가 있다.)
    if ([imageArr count] == 1) {
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag];
        if (!imageView.image) {
            UIImage *snapShot = [self getImage:imageArr[0][kImageDownloadUrl]];
            if (snapShot) {
                [imageView setImage:snapShot];
            }
        }
        return;
    }
    
    if (isZooming) {
        return;
    }
    
    CGFloat offsetY = [numberOffsetY floatValue];
    
    //현재 보고있는 화면의 인덱스 값을 찾는다.
    NSInteger currentViewIdx = -1;
    
    CGFloat ratio = contentsView.frame.size.width / baseWidth;
    offsetY = offsetY/ratio;
    
    CGFloat encoreDealOffset = CGRectGetMaxY(encoreDealView.frame) / ratio;
    if (encoreDealOffset > offsetY) {
        currentViewIdx = 0;
    }
    else {
        //화면 중앙으로 체크하도록 값을 더해준다.
        offsetY = offsetY + (baseHegiht/2);
        
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag];
        CGFloat index = (offsetY-encoreDealOffset)/imageView.frame.size.height;
        
        if (index > [imageArr count]-1) {
            index = [imageArr count]-1;
        }
        currentViewIdx = index;
    }
    
    if (currentViewIdx == -1) {
        currentViewIdx = 0;
    }
    
    if (lastViewIndex == currentViewIdx) {
        //정지된 화면에서는 위화면 / 현재화면 / 아래화면 3가지만 이미지를 확인한다.
        NSInteger viewIndex = currentViewIdx-1;
        for (NSInteger i=viewIndex; i<viewIndex+3; i++) {
            if (i >= 0 && i < imageArr.count-1 ) {
                UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag+i];
                
                if (imageView) {
                    if (!imageView.image) {
                        UIImage *snapShot = [self getImage:imageArr[i][kImageDownloadUrl]];
                        if (snapShot)	[imageView setImage:snapShot];
                    }
                }
            }
        }
        return;
    }
    
    viewPointIndex = currentViewIdx;
    
    for (NSInteger i = 0; i < [imageArr count]; i++) {
        //화면을 아래로 내릴때는 현재 기준으로 위에는 이미지 1장, 보고있는거 1장, 밑에 2장 깔아놓는다. (총 4장)
        //반대로 올릴때는 위에 2장, 보고있는거 1장, 아래 1장 깐다. (총 4장)
        //확대 했을 경우에는 포지션이 꼬여서 위,아래 2장씩 깐다. (총 5장)
        BOOL isImageSetting = NO;
        UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag + i];
        if (lastViewIndex < currentViewIdx) {
            if (imageScrollView.zoomScale >= 1.5) {
                if (i == currentViewIdx-2 || i == currentViewIdx-1 || i == currentViewIdx || i == currentViewIdx+1 || i == currentViewIdx+2) {
                    isImageSetting = YES;
                }
            }
            else {
                if (i == currentViewIdx-1 || i == currentViewIdx || i == currentViewIdx+1 || i == currentViewIdx+2) {
                    isImageSetting = YES;
                }
            }
        }
        else {
            if (imageScrollView.zoomScale >= 1.5) {
                if (i == currentViewIdx-2 || i == currentViewIdx-1 || i == currentViewIdx || i == currentViewIdx+1 || i == currentViewIdx+2) {
                    isImageSetting = YES;
                }
            }
            else {
                if (i == currentViewIdx-2 || i == currentViewIdx-1 || i == currentViewIdx || i == currentViewIdx+1) {
                    isImageSetting = YES;
                }
            }
        }
        
        if (isImageSetting) {
            if (!imageView.image) {
                UIImage *snapShot = [self getImage:imageArr[i][kImageDownloadUrl]];
                if (snapShot)	[imageView setImage:snapShot];
            }
        }
        else {
            if (imageView.image) [imageView setImage:nil];
        }
    }
    
    lastViewIndex = currentViewIdx;
}

- (void)touchMoreImageButton:(id)sender
{
    //더보기버튼 삭제
    CGRect frame = contentsView.frame;
    frame.size.height -= 44;
    contentsView.frame = frame;
    
    for (UIView *subView in [imageMoreButton subviews]) {
        [subView removeFromSuperview];
    }
    
    //나머지 이미지 추가
    [imageArr addObjectsFromArray:imageArrMore];
    for (NSInteger i = 10; i < [imageArr count]; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imgView setTag:ImgViewTag + i];
        [imgView setHidden:YES];
        [contentsView addSubview:imgView];
    }
    
    isResizeImageView = NO;
    isLoadReview = NO;
    [self loadContentsImage];
    
    //AccessLog - 이미지 더보기 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPJ04"];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isResizeImageView) {
        [self performSelectorOnMainThread:@selector(checkUserViewPoint:)
                               withObject:[NSNumber numberWithFloat:scrollView.contentOffset.y]
                            waitUntilDone:NO];
        
        if (scrollView.contentOffset.y+600 >= scrollView.contentSize.height - scrollView.frame.size.height) {
            if (!isLoadReview) {
                UIImageView *imageView = (UIImageView *)[contentsView viewWithTag:ImgViewTag + (imageArr.count-1)];
                
                CGFloat offsetY = CGRectGetMaxY(imageView.frame);
                
                //더보기 버튼
                if ([imageArr count] == 10 && [imageArrMore count] > 0) {
                    [self addImageMoreButton:offsetY];
                    offsetY += 44;
                }
                
                [self addBottomView:offsetY];
                
                isLoadReview = YES;
            }
        }
    }
    
//    if (openMarketingType) {
//        if (scrollView.contentSize.height-50 < (scrollView.contentOffset.y + scrollView.frame.size.height)) {
//            [_alrimiView setHidden:NO];
//        }
//        else {
//            [_alrimiView setHidden:YES];
//        }
//    }
//    else {
//        [_alrimiView setHidden:YES];
//    }
//
    [self.delegate productDescriptionView:self scrollViewDidScroll:scrollView];
    
//    DELEGATE_CALL2(self.delegate,
//                   ProductInfoDescriptView:scrollViewDidScroll:,
//                   self,
//                   scrollView);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return contentsView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    isZooming = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    isZooming = NO;
}

- (void)setScrollTop
{
    [imageScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    if (imageScrollView.zoomScale > 1.f) {
        [imageScrollView setZoomScale:1.f animated:NO];
    }
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [imageScrollView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [imageScrollView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [imageScrollView setShowsVerticalScrollIndicator:isShow];
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestUrlString = request.URL.absoluteString;
    
    // 옵션 자세히 보기
    if ([requestUrlString hasPrefix:kProductInfoSmartOptionDetailScheme])
    {
        NSString *queryString = [requestUrlString substringFromIndex:kProductInfoSmartOptionDetailScheme.length];
        NSDictionary *queryDict = [CMDQueryStringSerialization dictionaryWithQueryString:queryString];
        NSString *detailUrlString = queryDict[@"detailUrl"];
        if (detailUrlString && detailUrlString.length > 0)
        {
//            NSURL *detailUrl = [NSURL URLWithString:detailUrlString];
            
            if ([self.delegate respondsToSelector:@selector(smartOptionDidClickedOptionDetailAtUrl:)]) {
                [self.delegate smartOptionDidClickedOptionDetailAtUrl:detailUrlString];
            }
            
            return NO;
        }
    }
    
    // 옵션 담기
    if ([requestUrlString hasPrefix:kProductInfoSmartOptionInsertScheme])
    {
        NSString *queryString = [requestUrlString substringFromIndex:kProductInfoSmartOptionInsertScheme.length];
        NSDictionary *queryDict = [CMDQueryStringSerialization dictionaryWithQueryString:queryString];
        NSString *optionName = queryDict[@"optionNm"];
        if (optionName && optionName.length > 0)
        {
            if ([self.delegate respondsToSelector:@selector(smartOptionDidClickedOptionSelectButtonAtOptionName:)]) {
                [self.delegate smartOptionDidClickedOptionSelectButtonAtOptionName:optionName];
            }
            
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:YES]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(calculateWebViewSize) withObject:nil afterDelay:0.3];
}

- (void)calculateWebViewSize
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
    
//    CGRect frame = smartOptionWebView.frame;
//    frame.size.height = 1;
//    smartOptionWebView.frame = frame;
//    CGSize fittingSize = [smartOptionWebView sizeThatFits:CGSizeZero];
//    frame.size = fittingSize;
//    smartOptionWebView.frame = frame;
    
    CGRect frame = smartOptionWebView.frame;
    frame.size.height = 1;
    smartOptionWebView.frame = frame;
    
    NSString *output = [smartOptionWebView stringByEvaluatingJavaScriptFromString:@"Math.max( document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight );"];
    CGFloat newHeight = [output floatValue];
    
    [smartOptionWebView setFrame:CGRectMake(smartOptionWebView.frame.origin.x, smartOptionWebView.frame.origin.y, smartOptionWebView.frame.size.width, newHeight)];
    
    CGRect contentFrame = contentsView.frame;
    contentFrame.size.height = CGRectGetMaxY(smartOptionWebView.frame);
    contentsView.frame = contentFrame;
    
    [self addBottomView:CGRectGetMaxY(smartOptionWebView.frame)];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
//    [self touchCloseButton];
}

#pragma mark - CPFooterViewDelegate

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;
{
    if (url && [[url trim] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(openWebViewControllerWithUrl:animated:)]) {
            [self.delegate openWebViewControllerWithUrl:url animated:animated];
        }
    }
}

#pragma mark - CPDescriptionBottomViewDelegate

- (void)descriptionBottomView:(CPDescriptionBottomView *)view addContentHeight:(CGFloat)height
{
    CGRect contentFrame = contentsView.frame;
    contentFrame.size.height = contentFrame.size.height + (height * imageScrollView.zoomScale);
    contentsView.frame = contentFrame;

    imageScrollView.contentSize = CGSizeMake(imageScrollView.contentSize.width, contentsView.frame.size.height);
    [descriptionBottomView setFrame:CGRectMake(descriptionBottomView.frame.origin.x, descriptionBottomView.frame.origin.y, kScreenBoundsWidth, contentFrame.size.height)];
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
