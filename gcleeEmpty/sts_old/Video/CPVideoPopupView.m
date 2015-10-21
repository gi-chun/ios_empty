//
//  CPVideoPopupView.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPVideoPopupView.h"
#import "CPCommonInfo.h"
#import "CPVideoModule.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+Blocks.h"

@interface CPVideoPopupView () <UIGestureRecognizerDelegate,
                                CPVideoModuleDelegate>
{
    CPVideoModule *videoModule;
    
    UIView *productView;
    UIImageView *linkProductView;
    NSString *itemDetailUrl;
}

@end

@implementation CPVideoPopupView

- (id)initWithFrame:(CGRect)frame productInfo:(NSDictionary *)productInfo urlInfo:(NSDictionary *)urlInfo videoInfo:(CPVideoInfo *)videoInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSString *detailUrl = [urlInfo objectForKey:@"product"];
        NSString *prdNo = [productInfo objectForKey:@"prdNo"];
            
        if (prdNo && [[prdNo trim] length] > 0) {
            itemDetailUrl = [detailUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:prdNo];
        }
        
        [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.8f)];
        
        UIButton *backCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backCloseBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [backCloseBtn addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backCloseBtn];
        
		CGFloat closeBtnSize = 39.f;
		CGFloat contentWidth = 300.f;
		CGFloat videoModuleHeight = 226.f;
		CGFloat productViewHeight = 94.f;
		
		if (IS_IPAD) {
			contentWidth = contentWidth * 2.f;
			videoModuleHeight = videoModuleHeight * 2.f;
		} else {
			contentWidth = self.frame.size.width-20.f;
			videoModuleHeight = [Modules floor:226.f*[Modules getDisplayRatio]];
		}
    
		UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
		containerView.frame = CGRectMake(0.f,
										 0.f,
										 contentWidth+20.f,
										 closeBtnSize+videoModuleHeight+productViewHeight+20.f);
		[containerView setCenter:CGPointMake(self.center.x, self.center.y)];
		[self addSubview:containerView];
		
        // 닫기버튼
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(containerView.frame.size.width-closeBtnSize, 10, closeBtnSize, closeBtnSize)];
        [closeButton setImage:[UIImage imageNamed:@"list_img_prd_closed.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:closeButton];
		
        videoModule = [[CPVideoModule alloc] initWithFrame:CGRectMake((containerView.frame.size.width/2) - (contentWidth/2),
																	  CGRectGetMaxY(closeButton.frame),
																	  contentWidth,
																	  videoModuleHeight)];
        [videoModule setDelegate:self];
        [containerView addSubview:videoModule];
        
        // 상품정보
        productView = [[UIView alloc] initWithFrame:CGRectMake((containerView.frame.size.width/2) - (contentWidth/2),
															   CGRectGetMaxY(videoModule.frame),
															   contentWidth,
															   productViewHeight)];
        [productView setBackgroundColor:UIColorFromRGBA(0xfafafa, 1)];
        [productView.layer setBorderColor:UIColorFromRGBA(0xfafafa, 1).CGColor];
        [productView.layer setBorderWidth:1];
        [containerView addSubview:productView];
        
        //상품 섬네일 처리
        NSString *thumbnailUrl = @"";
        NSString *imgBase =  urlInfo[@"imgUrlPrefix"];
        NSString *imgUrl = productInfo[@"imgUrl"];
        
        if (imgUrl.length > 0) {
            NSString *strUrl = [imgBase stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:imgUrl];
            strUrl = [strUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 300]];
            strUrl = [strUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 300]];
            
            if (strUrl) {
                thumbnailUrl = strUrl;
            }
            else {
                thumbnailUrl = imgUrl;
            }
        }
        
        CPThumbnailView *thumbnailView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(10, 10, 74, 74)];
        
        if ([thumbnailUrl length] > 0) {
            [thumbnailView.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:[UIImage imageNamed:@"detail_img_product_nodata"]];

        }
        else {
            [thumbnailView.imageView setImage:[UIImage imageNamed:@"detail_img_product_nodata"]];
        }
        
        [productView addSubview:thumbnailView];
        
        UIView *thumbnailTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thumbnailView.frame.size.width, 1)];
        [thumbnailTopLine setBackgroundColor:UIColorFromRGBA(0xe3e3e3, 1.f)];
        [thumbnailView addSubview:thumbnailTopLine];
        
        UIView *thumbnailLeftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, thumbnailView.frame.size.height)];
        [thumbnailLeftLine setBackgroundColor:UIColorFromRGBA(0xe3e3e3, 1.f)];
        [thumbnailView addSubview:thumbnailLeftLine];
        
        UIView *thumbnailRightLine = [[UIView alloc] initWithFrame:CGRectMake(thumbnailView.frame.size.width-1, 0, 1, thumbnailView.frame.size.height)];
        [thumbnailRightLine setBackgroundColor:UIColorFromRGBA(0xe3e3e3, 1.f)];
        [thumbnailView addSubview:thumbnailRightLine];
        
        UIView *thumbnailBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, thumbnailView.frame.size.height-1, thumbnailView.frame.size.width, 1)];
        [thumbnailBottomLine setBackgroundColor:UIColorFromRGBA(0xe3e3e3, 1.f)];
        [thumbnailView addSubview:thumbnailBottomLine];
        
        // 상품명
        CGFloat maxWidth = productView.frame.size.width-18-18-74-32-10;
        CGFloat maxHeight = 37;
        NSString *productName = productInfo[@"prdNm"];
        
        UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(thumbnailView.frame)+6, 15, maxWidth, 0)];
        [productNameLabel setBackgroundColor:[UIColor clearColor]];
        [productNameLabel setText:productName];
        [productNameLabel setTextColor:RGBA(0x3e, 0x3e, 0x3e, 1)];
        [productNameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        [productNameLabel setNumberOfLines:2];
        [productNameLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [productNameLabel sizeToFitWithVersion];
        
        CGRect labelFrame = productNameLabel.frame;
        labelFrame.size.width = maxWidth;
        labelFrame.size.height = (labelFrame.size.height >= maxHeight ? maxHeight : labelFrame.size.height);
        productNameLabel.frame = labelFrame;
        
        [productView addSubview:productNameLabel];
        
        //실제가격
        if (productInfo[@"selPrc"] && [[productInfo[@"selPrc"] trim] length] > 0) {
            NSString *priceString = [NSString stringWithFormat:@"%@원", [NSNumberFormatter localizedStringFromNumber:@([productInfo[@"selPrc"] integerValue]) numberStyle:NSNumberFormatterDecimalStyle]];
            CGSize priceLabelSize = [priceString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(productNameLabel.frame.origin.x, 56.f, priceLabelSize.width, 10)];
            [priceLabel setBackgroundColor:[UIColor clearColor]];
            [priceLabel setText:priceString];
            [priceLabel setTextColor:RGBA(0xa5, 0xa5, 0xa5, 1)];
            [priceLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
            [productView addSubview:priceLabel];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(priceLabel.frame), 1)];
            [lineView setCenter:CGPointMake(CGRectGetWidth(priceLabel.frame)/2, CGRectGetHeight(priceLabel.frame)/2)];
            [lineView setBackgroundColor:RGBA(0xa5, 0xa5, 0xa5, 1)];
            [priceLabel addSubview:lineView];
        }
        
        // 할인가
        NSString *discountString = [NSNumberFormatter localizedStringFromNumber:@([productInfo[@"finalDscPrc"] integerValue]) numberStyle:NSNumberFormatterDecimalStyle];
        CGSize discountLabelSize = [discountString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        
        UILabel *discountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(thumbnailView.frame)+6, 68.f, discountLabelSize.width, 12)];
        [discountLabel setBackgroundColor:[UIColor clearColor]];
        [discountLabel setText:discountString];
        [discountLabel setTextColor:RGBA(0xcc, 0x1a, 0x0e, 1)];
        [discountLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [productView addSubview:discountLabel];
        
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(discountLabel.frame), 70.f, 8, 10)];
        [unitLabel setBackgroundColor:[UIColor clearColor]];
        [unitLabel setText:@"원"];
        [unitLabel setTextColor:RGBA(0xcc, 0x1a, 0x0e, 1)];
        [unitLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
        [productView addSubview:unitLabel];
        
        if (productInfo[@"selQty"] && [productInfo[@"selQty"] integerValue] > 0) {
            // 구매수량
            UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(productView.frame)-(8+100), 70, 100, 10)];
            [quantityLabel setBackgroundColor:[UIColor clearColor]];
            [quantityLabel setText:[NSString stringWithFormat:@"%@개 구매", productInfo[@"selQty"]]];
            [quantityLabel setTextColor:RGBA(0x6b, 0x71, 0x8e, 1)];
            [quantityLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
            [quantityLabel setTextAlignment:NSTextAlignmentRight];
            [productView addSubview:quantityLabel];
            
            [quantityLabel sizeToFitWithVersion];
            
            CGRect countLabelFrame = CGRectMake(productView.frame.size.width - quantityLabel.frame.size.width-12-32-10,
                                                70,
                                                quantityLabel.frame.size.width,
                                                10);
            [quantityLabel setFrame:countLabelFrame];
        }
        
        linkProductView = [[UIImageView alloc] initWithFrame:CGRectMake(productView.frame.size.width-42, 9, 32, 82)];
        linkProductView.image = [UIImage imageNamed:@"list_link_product_detail"];
        [productView addSubview:linkProductView];
        
        UIButton *btnProduct = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnProduct setFrame:productView.frame];
        [containerView addSubview:btnProduct];
        
        if (productInfo[@"soldout"] && [productInfo[@"soldout"] isEqualToString:@"N"]) {
            [btnProduct addTarget:self action:@selector(onDownProductView:) forControlEvents:UIControlEventTouchDown];
            [btnProduct addTarget:self action:@selector(onClickProductView:) forControlEvents:UIControlEventTouchUpInside];
            [btnProduct addTarget:self action:@selector(onReleaseProductView:) forControlEvents:UIControlEventTouchUpOutside];
            [btnProduct addTarget:self action:@selector(onReleaseProductView:) forControlEvents:UIControlEventTouchCancel];
        }
        
        // Soldout
        if (productInfo[@"soldout"] && [productInfo[@"soldout"] isEqualToString:@"Y"]) {
            UIImageView *soldoutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, productView.frame.size.width, productView.frame.size.height)];
            [soldoutImageView setImage:[UIImage imageNamed:@"video_list_img_prd_soldout"]];
            [productView addSubview:soldoutImageView];
        }
    }
    return self;
}

- (void)dealloc
{
    if (itemDetailUrl) itemDetailUrl = nil;
    
    if (videoModule) {
        videoModule = nil;
    }
}

- (void)setMovieWithVideoInfo:(CPVideoInfo *)videoInfo
{
    //썸네일
    NSString *movieImgUrl = videoInfo.movieImgUrl;
    if (movieImgUrl && [[movieImgUrl trim] length] > 0) {
        NSString *imgUrlPrefix = [[CPCommonInfo sharedInfo] urlInfo][@"imgUrlPrefix"];
       
        movieImgUrl= [imgUrlPrefix stringByReplacingOccurrencesOfString:@"{{imgUrl}}" withString:movieImgUrl];
        movieImgUrl = [movieImgUrl stringByReplacingOccurrencesOfString:@"{{img_width}}" withString:[NSString stringWithFormat:@"%d", 300]];
        movieImgUrl = [movieImgUrl stringByReplacingOccurrencesOfString:@"{{img_height}}" withString:[NSString stringWithFormat:@"%d", 300]];
        
        [videoModule setThumbnailUrl:movieImgUrl];
    }
    
    //동영상 주소
    NSString *videoUrl = videoInfo.movieUrl;
    if (videoUrl && [[videoUrl trim] length] > 0) {
        [videoModule setVideoUrl:videoUrl];
    }
    
    //재생시간
    NSString *duration = [NSString stringWithFormat:@"%ld", (long)videoInfo.movieRunningTime];
    [videoModule setDuration:duration];
    
    //뷰 카운트
    NSString *viewCount = [NSString stringWithFormat:@"%ld", (long)videoInfo.moviePlayCount];
    [videoModule setViewCount:viewCount];
    
    //뷰 카운터 업데이트 URL
    NSString *updateVideoCountUrl = videoInfo.movieUpdatePlayCountUrl;
    if (updateVideoCountUrl && [[updateVideoCountUrl trim] length] > 0) {
        [videoModule setViewCountUrl:updateVideoCountUrl];
    }
}

- (void)playWithVideoInfo:(CPVideoInfo *)videoInfo
{
    [self playWithVideoInfo:videoInfo autoPlay:YES];
}

- (void)playWithVideoInfo:(CPVideoInfo *)videoInfo autoPlay:(BOOL)autoPlay
{
    [videoModule playWithAutoPlay:autoPlay useMuteSound:NO];
}

- (void)pauseUnFocusCell
{
    [videoModule pauseUnFocusCell];
}

#pragma mark - button Methods
- (void)onDownProductView:(id)sender
{
    [productView.layer setBorderColor:UIColorFromRGBA(0x000000, 1.f).CGColor];
}

- (void)onClickProductView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTouchProductButton:)]) {
        [self.delegate didTouchProductButton:itemDetailUrl];
    }
    
    [self onReleaseProductView:sender];
    [self touchCloseButton];
}

- (void)onReleaseProductView:(id)sender
{
    [productView.layer setBorderColor:UIColorFromRGBA(0xfafafa, 1.f).CGColor];
}

#pragma mark - Selectors
- (void)touchCloseButton
{   
    [self pauseUnFocusCell];
    [self removeFromSuperview];
}

#pragma mark - CPVideoModuleDelegate

- (void)videoModuleonClickFullScreenButton:(CPMoviePlayerViewController *)player
{
    if ([self.delegate respondsToSelector:@selector(didTouchFullScreenButton:)]) {
        [self.delegate didTouchFullScreenButton:player];
    }
}

@end