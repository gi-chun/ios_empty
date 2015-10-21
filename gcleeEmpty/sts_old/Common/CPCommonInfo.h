//
//  CPCommonInfo.h
//  11st
//
//  Created by spearhead on 2014. 9. 11..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPWebViewController;

@interface CPCommonInfo : NSObject

@property (nonatomic, strong) NSMutableDictionary *versionInfo;             // 앱버전 정보
@property (nonatomic, strong) NSMutableDictionary *urlInfo;                 // Static URL(장바구니등)
@property (nonatomic, strong) NSMutableDictionary *dpServiceArea;           // 사이드메뉴(주요서비스)
@property (nonatomic, strong) NSMutableDictionary *categoryArea;            // 사이드메뉴(카테고리)
@property (nonatomic, strong) NSMutableDictionary *mypageArea;              // 사이드메뉴(마이페이지)
@property (nonatomic, strong) NSMutableDictionary *tooltip;                 // 툴팁
@property (nonatomic, strong) NSMutableDictionary *intro;                   // 인트로 설정
@property (nonatomic, strong) NSMutableDictionary *footer;                  // footer 설정
@property (nonatomic, strong) NSMutableDictionary *searchKeyWordInfo;       // ads스킴 검색어 정보
@property (nonatomic, strong) NSMutableDictionary *paymentInfo;             // ISP, Paypin 정보

@property (nonatomic, strong) NSString *lastShowDataFreeDate;               //데이터프리 마지막으로 보여준 날짜
@property (nonatomic, strong) NSString *gnbTextAppScheme;                   //GNB KEYWORD 광고
@property (nonatomic, assign) BOOL checkedVideoDataAlert;                   //동영상 과금

@property (nonatomic, strong) NSArray *mainTabs;                            // 메인탭 메뉴
@property (nonatomic, strong) NSArray *subUrls;                             // 서브 URLs
@property (nonatomic, strong) NSArray *exceptionUrls;                       // 예외 URLs

@property (nonatomic, strong) NSMutableArray *homeMenuItems;                // 홈 탭 메뉴
@property (nonatomic, strong) NSMutableArray *shownAppVersions;             // 앱버전(알림을 본)
@property (nonatomic, strong) NSMutableArray *recentSearchItems;            // 최근 검색어
@property (nonatomic, strong) NSMutableArray *offerBannerItems;             // OfferBanner

@property (nonatomic, strong) NSString *cacheMinutes;                       // 캐쉬 설정
@property (nonatomic, strong) NSString *currentAdKeyword;                   // ads스킴 SearchText
@property (nonatomic, strong) NSString *groupName;                          // groupName 설정

@property (nonatomic, strong) NSDate *offerBannerExpiresDate;               // OfferBanner exprie 날짜

@property (nonatomic, assign) CPNavigationType currentNavigationType;       // 현재 네비게이션 타입

@property (nonatomic, strong) CPWebViewController *currentWebViewController; // 현재 웹뷰 컨트롤러
@property (nonatomic, strong) UIViewController *lastViewController;          // 마지막 뷰 컨트롤러

@property (nonatomic, strong) NSDate *inBackgroundTime;                      //백그라운드로 진입한 마지막 시간을 저장한다.
@property (nonatomic, strong) NSMutableArray *logDataArray;                  //와이즈로그가 전송된 내용을 기록한다.

+ (CPCommonInfo *)sharedInfo;

+ (BOOL)isHomeMenuUrl:(NSString *)url;
+ (BOOL)isExceptionalUrl:(NSString *)url;
+ (BOOL)isShownAppVersion:(NSString *)appVersion;

+ (void)addRecentSearchItems:(NSString *)keyword;
+ (BOOL)isRecentSearchItem:(NSString *)keyword;
+ (void)removeRecentSearchItems:(NSInteger)index;
+ (void)removeAllRecentSearchItems;

@end
