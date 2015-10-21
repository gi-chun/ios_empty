//
//  CPWebView.h
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPWebViewDelegate;

@interface CPWebView : UIView

@property (nonatomic, weak) id<CPWebViewDelegate> delegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic, strong) UIButton *baroMartButton;
@property (nonatomic, strong) UIButton *zoomViewerButton;
@property (nonatomic) BOOL isProductDidLoad;
@property (nonatomic) BOOL isExistsSubWebView;
@property (nonatomic) BOOL isScrolling;
@property (nonatomic) NSInteger maxSubWebViewIndx;
@property (nonatomic) NSInteger currentSubWebViewIndx;
@property (nonatomic, strong) NSMutableArray *subWebViewArray;

- (id)initWithFrame:(CGRect)frame isSub:(BOOL)isSub;
- (void)destroyWebView;
- (void)didReceiveMemoryWarning;

- (void)updateFrame;
- (void)setForwardButton:(BOOL)enable;
- (void)open:(NSString *)url;
- (NSString *)execute:(NSString *)script;
- (void)loadRequest:(NSURLRequest *)request;

//- (BOOL)toggleButtonHiddenStatus;
- (void)setHiddenToolBarView:(BOOL)isHidden;
- (void)setHiddenBaroMartButton:(BOOL)isHidden;

- (NSString *)url;
- (void)reload;
- (void)stop;
- (void)goTopWithAnimated:(BOOL)animated;
- (void)goBack;
- (void)goFoward;

//scheme controls
- (void)actionTop;
- (void)actionBackWord;
- (void)actionForward;
- (void)actionReload;

//ProductOption
- (void)makeProductOption;
- (void)closeProductOption;
- (void)destoryProductOption;

- (void)setViewId:(NSInteger)viewId;

- (void)setHiddenPopover:(BOOL)hidden;

@end

@protocol CPWebViewDelegate <NSObject>
@optional

//WebView
- (BOOL)webView:(CPWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request;
- (BOOL)webView:(CPWebView *)webView shouldStartLoadForProduct:(NSURLRequest *)request;
- (void)webViewDidFinishLoad:(CPWebView *)aWebView;
- (void)webView:(CPWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(CPWebView *)webView openUrlScheme:(NSString *)urlScheme;
- (void)webViewGoBack;

//Button in WebView
- (void)didTouchZoomViewerButton;

//ToolBar
- (void)didTouchToolBarButton:(UIButton *)button;

//PopOverView
- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//SnapshotPopOverView
- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//Navigation Bar
- (void)initNavigation:(CPNavigationType)navigationType;

@end