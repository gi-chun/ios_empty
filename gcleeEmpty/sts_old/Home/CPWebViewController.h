//
//  CPWebViewController.h
//  11st
//
//  Created by spearhead on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPWebView;

typedef enum {
    CPWebviewControllerFullScreenModeNone,
    CPWebviewControllerFullScreenModeOn,
    CPWebviewControllerFullScreenModeOff
} CPWebviewControllerFullScreenMode;

@interface CPWebViewController : UIViewController

@property (nonatomic, strong) CPWebView *webView;

- (id)initWithUrl:(NSString *)url;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore isProduct:(BOOL)product;
- (id)initWithRequest:(NSURLRequest *)request;

@end
