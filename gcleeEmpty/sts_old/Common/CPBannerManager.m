//
//  CPBannerManager.m
//  11st
//
//  Created by spearhead on 2015. 6. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPBannerManager.h"
#import "CPCommonInfo.h"
#import "CPThumbnailView.h"
#import "CPRESTClient.h"
#import "RegexKitLite.h"
#import "SBJSON.h"
#import "NSString+SBJSON.h"
#import "UIImageView+WebCache.h"

@interface CPBannerManager()
{
//    NSMutableArray *bannerItems;
    NSMutableDictionary *currentBannerInfo;
    
    NSString *endDate;
    
    UIView *bannerView;
    UIButton *drawerButton;
    
    BOOL isDrawerOpen;
}

@end

@implementation CPBannerManager

+ (CPBannerManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static CPBannerManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CPBannerManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
//        bannerItems = [NSMutableArray array];
        currentBannerInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - API

- (void)getOfferBanner
{
    void (^getBannerSuccess)(NSDictionary *);
    getBannerSuccess = ^(NSDictionary *bannerData) {
        NSLog(@"bannerData:%@", bannerData);
        
        if (bannerData && [bannerData[@"response"] count] > 0) {
            NSArray *bannerItems = [bannerData[@"response"][@"banners"] mutableCopy];
            [[CPCommonInfo sharedInfo] setOfferBannerItems:[NSMutableArray arrayWithArray:bannerItems]];
//            NSLog(@"offerBannerItems1%@", [[CPCommonInfo sharedInfo] offerBannerItems]);
            // endDate 설정
            if (bannerItems.count > 0) {
                endDate = [self getEndDate:bannerItems];
            }
        }
        
        // 만료기간 설정
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDate *expireDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
        [[CPCommonInfo sharedInfo] setOfferBannerExpiresDate:expireDate];
    };
    
    void (^getBannerFailure)(NSError *);
    getBannerFailure = ^(NSError *error) {
        
    };
    
    NSString *apiUrl = [[Modules urlWithQueryString:APP_OFFER_GET_BANNER_URL] stringByAppendingFormat:@"&requestTime=%@", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"apiUrl"] = apiUrl;
    
    [[CPRESTClient sharedClient] requestGetOfferBannerWithParam:params
                                                        success:getBannerSuccess
                                                        failure:getBannerFailure];
}

- (void)updateOfferBanner:(NSString *)actionType
{
    void (^updateBannerSuccess)(NSDictionary *);
    updateBannerSuccess = ^(NSDictionary *bannerData) {
        NSLog(@"updateBannerSuccess:%@", bannerData[@"result"]);
    };
    
    void (^updateBannerFailure)(NSError *);
    updateBannerFailure = ^(NSError *error) {
        NSLog(@"updateBannerFailure");
    };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cpCode"] = currentBannerInfo[@"cpCode"];
    params[@"type"] = actionType;
    
    if (!nilCheck(endDate)) {
        params[@"endDate"] = endDate;
    }
    
    [[CPRESTClient sharedClient] requestUpdateOfferBannerWithParam:params
                                                               url:APP_OFFER_UPDATE_COOKIE_URL
                                                           success:updateBannerSuccess
                                                           failure:updateBannerFailure];
}

#pragma mark - Public Methods

- (void)initBanner
{
    [self getOfferBanner];
}

- (UIView *)makeOfferBannerView
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(viewYn == 'N' && denyYn == 'N')"];
    
    NSMutableArray *bannerItems = [[[CPCommonInfo sharedInfo] offerBannerItems] mutableCopy];
    NSLog(@"bannerItems:%@", bannerItems);
    
    if ([bannerItems filteredArrayUsingPredicate:predicate].count > 0) {
        
        NSArray *filterdArray = [bannerItems filteredArrayUsingPredicate:predicate];
        
        for (NSDictionary *bannerInfo in filterdArray) {
            currentBannerInfo = [bannerInfo mutableCopy];
            
            if ([self isEnableOffer:currentBannerInfo[@"cpCode"]]) { //그만보기 Y 이거나 노출 Y 면 배너 비노출
                bannerView = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-40, kScreenBoundsHeight-(114+90+kNavigationHeight), 286, 114)];
                
                drawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [drawerButton setFrame:CGRectMake(0, 0, 40, 114)];
                [drawerButton setImage:[UIImage imageNamed:@"mdn_btn_close_nor.png"] forState:UIControlStateNormal];
                [drawerButton setImage:[UIImage imageNamed:@"mdn_btn_close_press.png"] forState:UIControlStateHighlighted];
                [drawerButton addTarget:self action:@selector(touchDrawerButton) forControlEvents:UIControlEventTouchUpInside];
                [bannerView addSubview:drawerButton];
                
                UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(drawerButton.frame), 0, 246, CGRectGetHeight(bannerView.frame))];
                [containerView.layer setBorderWidth:2.0f];
                [containerView.layer setBorderColor:UIColorFromRGB(0x2d3642).CGColor];
                [bannerView addSubview:containerView];
                
                //        NSString *imageUrl = @"http://i.011st.com/ds/2015/04/30/568/423e82d8d8e2052ef448fef0f7d410c9.png";
                NSString *imageUrl = currentBannerInfo[@"imgUrl"];
                
                CPThumbnailView *bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(2, 2, CGRectGetWidth(containerView.frame)-(2+22), CGRectGetHeight(containerView.frame)-4)];
                [bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xffffff)]];
                //    [bannerImageView.imageView setContentMode:UIViewContentModeScaleAspectFit];
                [containerView addSubview:bannerImageView];
                
                UIButton *bannerImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [bannerImageButton setFrame:bannerImageView.frame];
                [bannerImageButton setBackgroundColor:[UIColor clearColor]];
                [bannerImageButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x000000)] forState:UIControlStateHighlighted];
                [bannerImageButton addTarget:self action:@selector(touchBannerButton) forControlEvents:UIControlEventTouchUpInside];
                [bannerImageButton setAlpha:0.3];
                [containerView addSubview:bannerImageButton];
                
                UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [closeButton setFrame:CGRectMake(CGRectGetMaxX(bannerImageButton.frame), 2, 22, CGRectGetHeight(containerView.frame)-4)];
                [closeButton setTitle:@"그\n만\n보\n기" forState:UIControlStateNormal];
                [closeButton setTitleColor:UIColorFromRGB(0x858c94) forState:UIControlStateNormal];
                [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
                [closeButton.titleLabel setNumberOfLines:0];
                [closeButton setContentEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
                [closeButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x2d3642)] forState:UIControlStateNormal];
                [closeButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x1d242e)] forState:UIControlStateHighlighted];
                [closeButton addTarget:self action:@selector(touchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
                [containerView addSubview:closeButton];
                
                UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 10, 10)];
                [closeImageView setImage:[UIImage imageNamed:@"mdn_btn_delete.png"]];
                [closeButton addSubview:closeImageView];
                
                //노출 처리
                [self updateOfferBanner:@"VIEW"];
                [bannerItems removeObject:currentBannerInfo];
                [[CPCommonInfo sharedInfo] setOfferBannerItems:bannerItems];
                //                NSLog(@"offerBannerItems2%@", [[CPCommonInfo sharedInfo] offerBannerItems]);
                
                [self initBannerView];
                
                break;
            }
        }
    }
    else {
        bannerView = nil;
    }
    
    isDrawerOpen = NO;
    
    return bannerView;
}

- (void)initBannerView
{
//    NSMutableArray *bannerItems = [[[CPCommonInfo sharedInfo] offerBannerItems] mutableCopy];
//    if (bannerItems.count > 0) {
        //노출 4초후 다시 슬라이딩 아웃
        [self animateBannerView:nil];
        
        [self performSelector:@selector(animateBannerView:) withObject:@"delay" afterDelay:4.0f];
//    }
//    else {
//        [bannerView removeFromSuperview];
//    }
}

- (void)removeBannerView
{
    [bannerView removeFromSuperview];
}

#pragma mark - Private Methods

- (void)animateBannerView:(NSString *)delay
{
    CGRect bannerViewFrame;
    UIImage *drawerButtonImageNormal;
    UIImage *drawerButtonImageHighlighted;
    
    if ([delay isEqualToString:@"delay"] && !isDrawerOpen) {
        return;
    }
    
    if (!isDrawerOpen) {
        bannerViewFrame = CGRectMake(kScreenBoundsWidth-286, kScreenBoundsHeight-(114+90+kNavigationHeight), 286, 114);
        drawerButtonImageNormal = [UIImage imageNamed:@"mdn_btn_close_nor.png"];
        drawerButtonImageHighlighted = [UIImage imageNamed:@"mdn_btn_close_press.png"];
    }
    else {
        bannerViewFrame = CGRectMake(kScreenBoundsWidth-40, kScreenBoundsHeight-(114+90+kNavigationHeight), 286, 114);
        drawerButtonImageNormal = [UIImage imageNamed:@"mdn_btn_open_nor.png"];
        drawerButtonImageHighlighted = [UIImage imageNamed:@"mdn_btn_open_press.png"];
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        [bannerView setFrame:bannerViewFrame];
    } completion:^(BOOL finished) {
        [drawerButton setImage:drawerButtonImageNormal forState:UIControlStateNormal];
        [drawerButton setImage:drawerButtonImageHighlighted forState:UIControlStateHighlighted];
        
        isDrawerOpen = !isDrawerOpen;
    }];
}

- (NSString *)getEndDate:(NSArray *)array
{
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    NSDictionary *sortedInfo = sortedArray.firstObject;
    
    return sortedInfo[@"endDate"];
}

- (BOOL)isEnableOffer:(NSString *)cpCode
{
    BOOL isEnable = YES;
    
    NSString *deny = @"";
    NSString *view = @"";
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        //        NSLog(@"app cookie:%@", [cookie description]);
        
        if ([cookie.name isEqualToString:@"offerBnInfo"]) {
            NSLog(@"offerBnInfo:%@", URLDecode(cookie.value));
            
            NSArray *offerBnInfoCookieArray = [URLDecode(cookie.value) componentsSeparatedByString:@"@"];
            
            for (NSString *cookieValue in offerBnInfoCookieArray) {
                if (!nilCheck(cookieValue)) {
                    NSArray *cookieValueArray = [cookieValue componentsSeparatedByString:@"|"];
                    
                    if ([cookieValueArray.firstObject isEqualToString:cpCode]) {
                        
                        if (cookieValueArray.count >= 4) {
                            deny = cookieValueArray.lastObject;
                            view = cookieValueArray[1];
                        }
                        
                        break;
                    }
                }
            }
            
            break;
        }
    }
    
    if ([deny isEqualToString:@"Y"] || [view isEqualToString:@"Y"]) {
        isEnable = NO;
    }
    
    return isEnable;
}

#pragma mark - Selectors

- (void)touchDrawerButton
{
    [self animateBannerView:nil];
}

- (void)touchCloseButton:(id)sender
{
    if (sender) {
        [self updateOfferBanner:@"DENY"];
    }
    
    [bannerView removeFromSuperview];
}

- (void)touchBannerButton
{
    [self updateOfferBanner:@"CLICK"];
    
//    NSString *url = @"http://ds.11st.co.kr/click/11st/11st_mobile/mobile_category@NM_category_linebanner?ads_id=26099&creative_id=22645&click_id=21174";
    NSString *url = currentBannerInfo[@"link"];
    
    if ([self.delegate respondsToSelector:@selector(didTouchBannerButton:)]) {
        [self.delegate didTouchBannerButton:url];
    }
    
    [self touchCloseButton:nil];
}

@end
