//
//  CPCommonInfo.m
//  11st
//
//  Created by spearhead on 2014. 9. 11..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPCommonInfo.h"
#import "RegexKitLite.h"

@implementation CPCommonInfo

+ (CPCommonInfo *)sharedInfo
{
    static dispatch_once_t onceToken;
    static CPCommonInfo *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CPCommonInfo alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *savedValue = nil;
        
        // 앱버전 정보
        savedValue = [defaults objectForKey:@"versionInfo"];
        if (savedValue) {
            [self setVersionInfo:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setVersionInfo:nil];
        }
        
        // Static URL(장바구니등)
        savedValue = [defaults objectForKey:@"urlInfo"];
        if (savedValue) {
            [self setUrlInfo:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setUrlInfo:nil];
        }
        
        // 사이드메뉴(주요서비스)
        savedValue = [defaults objectForKey:@"dpServiceArea"];
        if (savedValue) {
            [self setDpServiceArea:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setDpServiceArea:nil];
        }
        
        // 사이드메뉴(카테고리)
        savedValue = [defaults objectForKey:@"categoryArea"];
        if (savedValue) {
            [self setCategoryArea:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setCategoryArea:nil];
        }
        
        // 사이드메뉴(마이페이지)
        savedValue = [defaults objectForKey:@"mypageArea"];
        if (savedValue) {
            [self setMypageArea:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setMypageArea:nil];
        }
        
        // 홈탭 메뉴들
        savedValue = [defaults objectForKey:@"homeMenuItems"];
        if (savedValue) {
            [self setHomeMenuItems:[NSMutableArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setHomeMenuItems:[NSMutableArray array]];
        }
        
        NSString *lastShowDataFree = [defaults objectForKey:@"lastShowDataFreeDate"];
        if (lastShowDataFree) {
            [self setLastShowDataFreeDate:[NSString stringWithString:lastShowDataFree]];
        }
        
        // 메인탭 메뉴
        savedValue = [defaults objectForKey:@"mainTabs"];
        if (savedValue) {
            [self setMainTabs:[NSArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setMainTabs:[NSArray array]];
        }
        
        // 서브 URLs
        savedValue = [defaults objectForKey:@"subUrls"];
        if (savedValue) {
            [self setSubUrls:[NSArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setSubUrls:[NSArray array]];
        }
        
        // 예외 URLs
        savedValue = [defaults objectForKey:@"exceptionUrls"];
        if (savedValue) {
            [self setExceptionUrls:[NSArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setExceptionUrls:[NSArray array]];
        }
        
        // 앱버전(알림을 본)
        savedValue = [defaults objectForKey:@"shownAppVersions"];
        if (savedValue) {
            [self setShownAppVersions:[NSMutableArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setShownAppVersions:[NSMutableArray array]];
        }
        
        // 최근 검색어
        savedValue = [defaults objectForKey:@"recentSearchItems"];
        if (savedValue) {
            [self setRecentSearchItems:[NSMutableArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setRecentSearchItems:[NSMutableArray array]];
        }
        
        // Offer Banner
        savedValue = [defaults objectForKey:@"offerBannerItems"];
        if (savedValue) {
            [self setOfferBannerItems:[NSMutableArray arrayWithArray:[savedValue mutableCopy]]];
        }
        else {
            [self setOfferBannerItems:[NSMutableArray array]];
        }
        
        // 캐쉬 타임
        savedValue = [defaults objectForKey:@"cacheMinutes"];
        if (savedValue) {
            [self setCacheMinutes:[savedValue description]];
        }
        else {
            [self setCacheMinutes:nil];
        }
        
        // 툴팁 기본값 : 빈 Dictionary
        savedValue = [defaults objectForKey:@"tooltip"];
        if (savedValue) {
            [self setTooltip:[NSMutableDictionary dictionaryWithDictionary:[savedValue mutableCopy]]];
        }
        else {
            [self setTooltip:nil];
        }
        
        savedValue = [defaults objectForKey:@"offerBannerExpiresDate"];
        if (savedValue) {
            [self setOfferBannerExpiresDate:[savedValue copy]];
        }
        else {
            [self setOfferBannerExpiresDate:nil];
        }
        
        _logDataArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Settor

- (void)setVersionInfo:(NSMutableDictionary *)versionInfo
{
    _versionInfo = versionInfo;
    [[NSUserDefaults standardUserDefaults] setObject:[_versionInfo mutableCopy]
                                              forKey:@"versionInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUrlInfo:(NSMutableDictionary *)urlInfo
{
    _urlInfo = urlInfo;
    [[NSUserDefaults standardUserDefaults] setObject:[_urlInfo mutableCopy]
                                              forKey:@"urlInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDpServiceArea:(NSMutableDictionary *)dpServiceArea
{
    _dpServiceArea = dpServiceArea;
    [[NSUserDefaults standardUserDefaults] setObject:[_dpServiceArea mutableCopy]
                                              forKey:@"dpServiceArea"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCategoryArea:(NSMutableDictionary *)categoryArea
{
    _categoryArea = categoryArea;
    [[NSUserDefaults standardUserDefaults] setObject:[_categoryArea mutableCopy]
                                              forKey:@"categoryArea"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setMypageArea:(NSMutableDictionary *)mypageArea
{
    _mypageArea = mypageArea;
    [[NSUserDefaults standardUserDefaults] setObject:[_mypageArea mutableCopy]
                                              forKey:@"mypageArea"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setMainTabs:(NSMutableArray *)mainTabs
{
    _mainTabs = mainTabs;
    [[NSUserDefaults standardUserDefaults] setObject:[_mainTabs mutableCopy]
                                              forKey:@"mainTabs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSubUrls:(NSMutableArray *)subUrls
{
    _subUrls = subUrls;
    [[NSUserDefaults standardUserDefaults] setObject:[_subUrls mutableCopy]
                                              forKey:@"subUrls"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setExceptionUrls:(NSMutableArray *)exceptionUrls
{
    _exceptionUrls = exceptionUrls;
    [[NSUserDefaults standardUserDefaults] setObject:[_exceptionUrls mutableCopy]
                                              forKey:@"exceptionUrls"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setHomeMenuItems:(NSMutableArray *)homeMenuItems
{
    _homeMenuItems = homeMenuItems;
    
    [[NSUserDefaults standardUserDefaults] setObject:[_homeMenuItems mutableCopy]
                                              forKey:@"homeMenuItems"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setShownAppVersions:(NSMutableArray *)shownAppVersions
{
    _shownAppVersions = shownAppVersions;
    
    [[NSUserDefaults standardUserDefaults] setObject:[_shownAppVersions mutableCopy]
                                              forKey:@"shownAppVersions"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRecentSearchItems:(NSMutableArray *)recentSearchItems
{
    _recentSearchItems = recentSearchItems;
    
    [[NSUserDefaults standardUserDefaults] setObject:[_recentSearchItems mutableCopy]
                                              forKey:@"recentSearchItems"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOfferBannerItems:(NSMutableArray *)offerBannerItems
{
    _offerBannerItems = offerBannerItems;
    
    [[NSUserDefaults standardUserDefaults] setObject:[_offerBannerItems mutableCopy]
                                              forKey:@"offerBannerItems"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTooltip:(NSMutableDictionary *)tooltip
{
    if (!tooltip) {
        tooltip = [NSMutableDictionary dictionary];
        for (int i=0; i<10; i++) {
            tooltip[[NSString stringWithFormat:@"%d", i]] = @NO;
        }
    }
    _tooltip = tooltip;
    [[NSUserDefaults standardUserDefaults] setObject:[_tooltip mutableCopy]
                                              forKey:@"tooltip"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIntro:(NSMutableDictionary *)intro
{
    _intro = intro;
    [[NSUserDefaults standardUserDefaults] setObject:[_intro mutableCopy]
                                              forKey:@"intro"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFooter:(NSMutableDictionary *)footer
{
    _footer = footer;
    [[NSUserDefaults standardUserDefaults] setObject:[_footer mutableCopy]
                                              forKey:@"footer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPaymentInfo:(NSMutableDictionary *)paymentInfo
{
    _paymentInfo = paymentInfo;
    [[NSUserDefaults standardUserDefaults] setObject:[_paymentInfo mutableCopy]
                                              forKey:@"paymentInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLastShowDataFreeDate:(NSString *)lastShowDataFreeDate
{
    _lastShowDataFreeDate = lastShowDataFreeDate;
    [[NSUserDefaults standardUserDefaults] setObject:lastShowDataFreeDate
                                              forKey:@"lastShowDataFreeDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setGnbTextAppScheme:(NSString *)gnbTextAppScheme
{
    _gnbTextAppScheme = gnbTextAppScheme;
}

- (void)setGroupName:(NSString *)groupName
{
    _groupName = groupName;
    [[NSUserDefaults standardUserDefaults] setObject:[_groupName mutableCopy]
                                              forKey:@"groupName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setOfferBannerExpiresDate:(NSDate *)offerBannerExpiresDate
{
    _offerBannerExpiresDate = offerBannerExpiresDate;
    
    [[NSUserDefaults standardUserDefaults] setObject:[_offerBannerExpiresDate copy]
                                              forKey:@"offerBannerExpiresDate"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Class Methods

+ (BOOL)isHomeMenuUrl:(NSString *)url
{
    BOOL isHome = NO;
    
    for (NSString *item in [[CPCommonInfo sharedInfo] homeMenuItems]) {
        //        if ([url hasPrefix:item])
        if ([url isEqualToString:item]) {
            return YES;
        }
    }
    
    return isHome;
}

+ (BOOL)isExceptionalUrl:(NSString *)url
{
    BOOL isException = NO;
    
    for (NSDictionary *item in [[CPCommonInfo sharedInfo] exceptionUrls]) {
        if ([@"start" hasPrefix:item[@"compare"]] && [url hasPrefix:item[@"url"]]) {
            return YES;
        }
        
        if ([@"match" hasPrefix:item[@"compare"]] && [url isMatchedByRegex:item[@"url"]]) {
            return YES;
        }
    }
    
    return isException;
}

+ (BOOL)isShownAppVersion:(NSString *)appVersion
{
    BOOL isHome = NO;
    
    for (NSString *item in [[CPCommonInfo sharedInfo] shownAppVersions]) {
        if ([appVersion isEqualToString:item])
            return YES;
    }
    
    return isHome;
}

+ (void)addRecentSearchItems:(NSString *)keyword
{
    NSMutableArray *items = [[[CPCommonInfo sharedInfo] recentSearchItems] mutableCopy];
    
    if (![CPCommonInfo isRecentSearchItem:keyword]) {
        if (items.count > 19) {
            [items removeObjectAtIndex:0];
        }
        
        if (!nilCheck(keyword)) {
            [items addObject:keyword];
        }
        
        [[CPCommonInfo sharedInfo] setRecentSearchItems:items];
    }
}

+ (void)removeRecentSearchItems:(NSInteger)index
{
    NSMutableArray *items = [[[CPCommonInfo sharedInfo] recentSearchItems] mutableCopy];
    
    [items removeObjectAtIndex:index];
    [[CPCommonInfo sharedInfo] setRecentSearchItems:items];
}

+ (void)removeAllRecentSearchItems
{
    NSMutableArray *items = [[[CPCommonInfo sharedInfo] recentSearchItems] mutableCopy];
    
    [items removeAllObjects];
    [[CPCommonInfo sharedInfo] setRecentSearchItems:items];
}

+ (BOOL)isRecentSearchItem:(NSString *)keyword
{
    BOOL isRecent = NO;
    
    for (NSString *item in [[CPCommonInfo sharedInfo] recentSearchItems]) {
        if ([keyword isEqualToString:item])
            return YES;
    }
    
    return isRecent;
}

@end