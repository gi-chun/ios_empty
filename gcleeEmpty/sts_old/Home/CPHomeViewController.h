//
//  CPHomeViewController.h
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPWebView;
@class CPDeveloperInfo;
@class CPNavigationBarView;

@protocol CPHomeViewControllerDelegate;

@interface CPHomeViewController : UIViewController

@property (nonatomic, weak) id<CPHomeViewControllerDelegate> delegate;
//@property (nonatomic, strong) CPNavigationBarView *navigationBarView;
@property (nonatomic, strong) CPWebView *subWebView;
@property (nonatomic, strong) CPWebView *currentWebView;
@property (nonatomic, strong) CPDeveloperInfo *developerInfo;
@property (nonatomic, strong) NSMutableArray *trendImageHeightArray;

- (void)gotoNativeTab:(NSString *)ac;
- (void)handleOpenURL:(NSString *)url;
- (void)openSubWebView:(NSString *)url;
- (void)openSettingViewController;
- (void)openLoginViewController;
- (void)openOTP:(NSString *)option;
- (void)advertisement:(NSString *)option;
- (void)reloadWebViewData;
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
- (void)didTouchButtonWithUrl:(NSString *)productUrl animated:(BOOL)animated;
- (void)goToPageAction:(NSString *)option;
- (void)goSearchKeyword:(NSString *)keyword referrer:(NSString *)referrer;
- (void)goProductDetail:(NSString *)prdNo;
- (void)goPriceCompareDetail:(NSString *)modelNo keyword:(NSString *)keyword;
- (void)showDataFreeView:(NSString *)linkUrl;
- (void)didTouchMartButton;

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;
- (void)openWebViewControllerWithRequest:(NSURLRequest *)request;
- (void)openPopupBrowserView:(NSDictionary *)popupInfo;
- (void)onTouchCloseDataFreeView:(id)sender;
- (void)setGnbSearchKeyword;

@end

@protocol CPHomeViewControllerDelegate <NSObject>
@optional

@end
