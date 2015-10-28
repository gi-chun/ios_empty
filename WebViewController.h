//
//  WebViewController.h
//
//  Created by gclee on 2015. 10. 28..
//  Copyright (c) 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebView;

typedef enum {
    CPWebviewControllerFullScreenModeNone,
    CPWebviewControllerFullScreenModeOn,
    CPWebviewControllerFullScreenModeOff
} CPWebviewControllerFullScreenMode;

@interface WebViewController : UIViewController

@property (nonatomic, strong) WebView *webView;

- (id)initWithUrl:(NSString *)url;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore;
- (id)initWithUrl:(NSString *)url isPop:(BOOL)isPop isIgnore:(BOOL)ignore isProduct:(BOOL)product;
- (id)initWithRequest:(NSURLRequest *)request;

@end
