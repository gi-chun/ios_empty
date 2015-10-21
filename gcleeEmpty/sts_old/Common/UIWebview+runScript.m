//
//  UIWebview+runScript.m
//  11st
//
//  Created by 김응학 on 2015. 7. 20..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "UIWebview+runScript.h"

#pragma mark - UIWebview + JavaScriptAlert
@implementation UIWebView (JavaScriptAlert)

static BOOL status = NO;
static BOOL isEnd = NO;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle11st", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
    
    [alertView show];
}

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle11st", nil)
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    [confirmDiag show];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.) {
        while (isEnd == NO) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        }
    }
    else
    {
        while (isEnd == NO && confirmDiag.superview != nil) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        }
    }
    
    isEnd = NO;
    
    return status;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    status = buttonIndex;
    isEnd = YES;
}

@end
