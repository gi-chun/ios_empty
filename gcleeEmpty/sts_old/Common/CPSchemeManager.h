//
//  CPSchemeManager.h
//  11st
//
//  Created by spearhead on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPSchemeManagerDelegate;

@interface CPSchemeManager : NSObject

@property (nonatomic, weak) id<CPSchemeManagerDelegate> delegate;

+ (CPSchemeManager *)sharedManager;

- (BOOL)openUrlScheme:(NSString *)url sender:(id)sender changeAnimated:(BOOL)animated;

@end

@protocol CPSchemeManagerDelegate <NSObject>
@optional

//ads
- (void)openPopupViewController:(NSString *)linkUrl;
- (void)setSearchTextField:(NSString *)keyword;

//photoReview
- (void)openPhotoReviewController:(NSDictionary *)reviewInfo;

//contact
- (void)openContactViewController:(NSDictionary *)contactInfo;
- (void)closeContactViewController;

//popupBrowser
- (void)openPopupBrowserView:(NSDictionary *)popupInfo;
- (void)closePopupBrowserView:(NSDictionary *)popupInfo;

//zoomViewer
- (void)setZoomViewer:(NSArray *)options;

//canOpenApp
- (void)executeCanOpenApplication:(NSString *)option;

- (void)openWebView:(NSString *)url;

//toolbar action
- (void)webViewToolbarAction:(NSString *)option;

//movie popup
- (void)openVideoPopupView:(NSDictionary *)productInfo;

//imageView
- (void)openImageView:(NSDictionary *)imageInfo;

//pasteBoard
- (void)pasteClipBoard:(NSArray *)options;

//executeJavascript
- (void)executeJavascript:(NSString *)command;

//product
- (void)setProductOption:(BOOL)isEnable;

//setting
- (void)setSettingViewController:(NSString *)option animated:(BOOL)animated;

//otp
- (void)setOtp:(NSString *)otpStr;

//shakemotion
- (void)shakemotion:(NSString *)option;

//eventAlarm
- (void)eventAlarmAddAction:(NSDictionary *)jsonData;
- (void)eventAlarmRemoveAction:(NSDictionary *)jsonData;

//goPage
- (void)goToPageAction:(NSString *)option;

//moveToHome
- (void)moveToHomeAction:(NSString *)option;

//doNotInterceptSwipe
- (void)doNotInterceptSwipe:(NSString *)option;

@end