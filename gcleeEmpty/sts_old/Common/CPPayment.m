//
//  CPPayment.m
//  11st
//
//  Created by spearhead on 2014. 9. 4..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPPayment.h"
#import "Common.h"
#import "CPCommonInfo.h"
#import "Modules.h"
#import "RegexKitLite.h"
#import "HttpRequest.h"

#define NOT_INSTALLED_MSG	@"결제관련 앱(모듈)이 설치되어 있지 않습니다."

static CPPayment *instance;

@interface CPPayment() <UIAlertViewDelegate>
{
}

@end

@implementation CPPayment

+ (CPPayment *)getInstance
{
    if (instance == nil) instance = [[CPPayment alloc] init];
    
    return instance;
}

- (BOOL)isPaymentUrl:(NSString *)url
{
    NSDictionary *paymentInfo = [[CPCommonInfo sharedInfo] paymentInfo];
    if (paymentInfo) {
        
        NSDictionary *ISP_info = paymentInfo[@"ISP"];
        NSDictionary *PAYPIN_info = paymentInfo[@"PayPin"];
        NSString *prefix;
        
        //ISP 확인
        if (ISP_info) {
            NSString *scheme = ISP_info[@"scheme"];
            if ([url hasPrefix:scheme]) {
                return YES;
            }
            
            NSDictionary *success = ISP_info[@"success"];
            if ((prefix = success[@"url"])) {
                if ([url hasPrefix:prefix]) {
                    return YES;
                }
            }

            NSDictionary *fail = ISP_info[@"fail"];
            if ((prefix = fail[@"url"])) {
                if ([url hasPrefix:prefix]) {
                    return YES;
                }
            }
        }
        
        //페이핀 확인
        if (PAYPIN_info) {
            NSString *scheme = PAYPIN_info[@"scheme"];
            if ([url hasPrefix:scheme]) {
                return YES;
            }
            
            NSDictionary *success = PAYPIN_info[@"success"];
            if ((prefix = success[@"url"])) {
                if ([url hasPrefix:prefix]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)openPayment:(NSString *)url
{
    NSDictionary *paymentInfo = [[CPCommonInfo sharedInfo] paymentInfo];
    if (paymentInfo) {
        
        NSDictionary *ISP_info = paymentInfo[@"ISP"];
        NSDictionary *PAYPIN_info = paymentInfo[@"PayPin"];
        
        //ISP 확인
        if (ISP_info) {
            NSString *scheme = ISP_info[@"scheme"];
            if ([url hasPrefix:scheme]) {
                [self openUrl:url payment:ISP_info isISP:YES];
                return;
            }
            
            NSDictionary *success = ISP_info[@"success"];
            if (success && [url hasPrefix:success[@"url"]]) {
                [self performSelector:@selector(redirect:item:) withObject:url withObject:success];
                return;
            }
            
            NSDictionary *fail = ISP_info[@"fail"];
            if (fail && [url hasPrefix:fail[@"url"]]) {
                [self performSelector:@selector(redirect:item:) withObject:url withObject:fail];
                return;
            }
        }
        
        //PAYPIN 확인
        if (PAYPIN_info) {
            NSString *scheme = PAYPIN_info[@"scheme"];
            if ([url hasPrefix:scheme]) {
                [self openUrl:url payment:PAYPIN_info isISP:YES];
                return;
            }
            
            NSDictionary *success = PAYPIN_info[@"success"];
            if (success && [url hasPrefix:success[@"url"]]) {
                [self performSelector:@selector(redirect:item:) withObject:url withObject:success];
                return;
            }
        }
    }
}

- (void)openUrl:(NSString *)url payment:(NSDictionary *)payment isISP:(BOOL)isIsp
{
    NSDictionary *temp;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        NSString *message = payment ? (temp = [payment objectForKey:@"store"]) ? [self message:[temp objectForKey:@"message"]] : nil : nil;
        UIAlertView *alert = nil;
        
        if (message) {
            alert = [[UIAlertView alloc] initWithTitle:@"주문 결제" message:message delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"설치", nil];
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"주문 결제" message:NOT_INSTALLED_MSG delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
        }
        
        if (alert) {
            [alert setDelegate:self];
            [alert setTag:(isIsp ? 9999 : 0)];
            [alert show];
        }
    }
}

- (void)openStore:(BOOL)isISP
{
    NSDictionary *paymentInfo = [[CPCommonInfo sharedInfo] paymentInfo];
    if (paymentInfo) {
     
        NSString *openUrl = @"";
        if (isISP) {
            NSDictionary *ISP_info = paymentInfo[@"ISP"];
            
            if (ISP_info && ISP_info[@"store"]) {
                openUrl = ISP_info[@"store"][@"url"];
            }
        }
        else {
            NSDictionary *PAYPIN_info = paymentInfo[@"PayPin"];
            
            if (PAYPIN_info && PAYPIN_info[@"store"]) {
                PAYPIN_info = PAYPIN_info[@"store"][@"url"];
            }
        }
        
        if (openUrl && [openUrl length] > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
        }
    }
}

- (void)redirect:(NSString *)url item:(NSDictionary *)item
{
	NSString *redirectUrl = [item objectForKey:@"redirect"], *cookieDomain;
    
    //쿠키값을 보고 호스트를 붙여준다.
    if (redirectUrl && ![redirectUrl isEqualToString:@""]) {
        NSString *cookieHost = [Modules getCookieName:@"BUY_SITE"];
        cookieHost = [cookieHost stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (cookieHost && [cookieHost length] > 0)  redirectUrl = [cookieHost stringByAppendingString:redirectUrl];
        else                                        redirectUrl = [@"https://buy.m.11st.co.kr/MW" stringByAppendingString:redirectUrl];
    }
    
    NSLog(@"redirectUrl : %@", redirectUrl);
    
	NSString *message = [self message:[item objectForKey:@"message"]];
	NSString *parameters = [url hasPrefix:@"http"] ? [NSString stringWithFormat:@"APP_REFERER=%@&%@", [[url componentsSeparatedByRegex:@"?"] objectAtIndex:0], [url substringFromIndex:[url indexOf:@"?"] + 1]] : [url substringFromIndex:[url indexOf:@"://"] + 3];
	
	if (message) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"주문 결제" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles:nil];
		
		[alert show];
	}
    
	if (redirectUrl && ![redirectUrl isEqualToString:@""]) {
		NSString *redirectUrlWithParam = [([redirectUrl stringByAppendingFormat:@"%@%@", ([redirectUrl indexOf:@"?"] > 0 ? @"&" : @"?"), parameters]) stringByReplacingOccurrencesOfString:@"${DOMAIN}" withString:BASE_DOMAIN];
		NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@", redirectUrlWithParam, ([redirectUrlWithParam indexOf:@"?"] > 0 ? @"&" : @"?"), URL_QUERY_VARS];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
		NSMutableString *Cookie = [[NSMutableString alloc] init];
		NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
		if ((cookieDomain = [requestUrl stringByMatching:@"(https?://[^/]+)/.+" capture:1])) {
			for (NSHTTPCookie *each in [cookieStorage cookiesForURL:[NSURL URLWithString:cookieDomain]]) {
				[Cookie appendString:[NSString stringWithFormat:@"%@=%@; ", [each name], [each value]]];
			}
			
			[request setValue:Cookie forHTTPHeaderField:@"Cookie"];
		}
        
        if ([self.delegate respondsToSelector:@selector(paymentRequest:)]) {
            [self.delegate paymentRequest:request];
        }
        
	} else if ([@"elevenst://ISP=FAIL" isEqualToString:url]) {
        [self failISPMobile];
	}
}

- (void)failISPMobile
{
    NSDictionary *paymentInfo = [[CPCommonInfo sharedInfo] paymentInfo];
    if (paymentInfo) {
        
        NSDictionary *ISP_info = paymentInfo[@"ISP"];
        if (ISP_info) {
            NSDictionary *fail = ISP_info[@"fail"];
            NSString *failScript = [fail objectForKey:@"script"];

            if (failScript) {
                if ([self.delegate respondsToSelector:@selector(paymentExecuteScript:)]) {
                    [self.delegate paymentExecuteScript:failScript];
                }
            }
        }
    }
}


- (NSString *)message:(NSString *)message
{
	if (message && ![[message trim] isEqualToString:@""]) {
        return [message stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
	
	return nil;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //isp : 9999
    if (alertView.tag == 9999) {
        [self failISPMobile];
    }
	
	if (buttonIndex == 1) {
        [self openStore:(alertView.tag == 9999 ? YES : NO)];
    }
}

@end