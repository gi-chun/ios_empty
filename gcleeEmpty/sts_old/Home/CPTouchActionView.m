//
//  CPTouchActionView.m
//  11st
//
//  Created by saintsd on 2015. 6. 17..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTouchActionView.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPCommonInfo.h"
#import "CPSchemeManager.h"
#import "AccessLog.h"

@implementation CPTouchActionView

- (void)setTouchEffect:(BOOL)isTouch
{
	if (isTouch)	self.backgroundColor = UIColorFromRGBA(0x000000, 0.3);
	else			self.backgroundColor = [UIColor clearColor];
}

- (void)onTouchAction
{
	if (self.actionType == CPButtonActionTypeOpenSubview) {
		NSString *url = (NSString *)self.actionItem;
		
		if (url && [[url trim] length] > 0) {
			AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			CPHomeViewController *homeViewController = app.homeViewController;
			
            if ([homeViewController respondsToSelector:@selector(openWebViewControllerWithUrl:animated:)]) {
                //Exception URL은 풀스크린으로 보여줌
                BOOL isException = [CPCommonInfo isExceptionalUrl:url];
                [homeViewController openWebViewControllerWithUrl:[url trim] animated:!isException];
            }
		}
	}
	else if (self.actionType == CPButtonActionTypeSendDelegateMessageCategoryBest) {
		NSString *url = (NSString *)self.actionItem;
		
		if (self.delegate && [self.delegate respondsToSelector:@selector(touchActionView:sendCategoryBest:)]) {
			[self.delegate touchActionView:self sendCategoryBest:[url trim]];
		}
	}
	else if (self.actionType == CPButtonActionTypeSendOtherAppDeepLink) {
		NSDictionary *item = (NSDictionary *)self.actionItem;
		
		NSString *shockingDealAppURL = item[@"deeplink"];
		NSString *shockingDealAppstoreURL = item[@"appstore"];

		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:shockingDealAppURL]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppURL]];
		}
		else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:shockingDealAppstoreURL]];
		}
	}
	else if (self.actionType == CPButtonActionTypeOpenPupup) {
		
		NSDictionary *item = (NSDictionary *)self.actionItem;
		
		NSString *linkUrl = item[@"openPopupUrl"];
		NSString *popupTitle = (item[@"popupTitle"] ? item[@"popupTitle"] : @"신상보기");
		
		NSMutableDictionary *param = [NSMutableDictionary dictionary];
		[param setObject:@"insetzero" forKey:@"controls"];
		[param setObject:@"1" forKey:@"showTitle"];
		[param setObject:popupTitle forKey:@"title"];
		[param setObject:linkUrl forKey:@"url"];
		
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;

		if ([homeViewController respondsToSelector:@selector(openPopupBrowserView:)]) {
			[homeViewController openPopupBrowserView:param];
		}
	}
	else if (self.actionType == CPButtonActionTypeAppScheme) {
		NSString *url = (NSString *)self.actionItem;
		
		[[CPSchemeManager sharedManager] openUrlScheme:url sender:nil changeAnimated:NO];
	}
	else if (self.actionType == CPButtonActionTypeGoSearchKeyword) {
		NSDictionary *item = (NSDictionary *)self.actionItem;
		
		NSString *keyword = item[@"keyword"];
		NSString *reff = item[@"reff"];
		
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(goSearchKeyword:referrer:)]) {
			[homeViewController goSearchKeyword:keyword referrer:reff];
		}
	}
    else if (self.actionType == CPButtonActionTypeGoModelSearchProduct) {
        NSDictionary *item = (NSDictionary *)self.actionItem;
        
        NSString *keyword = item[@"keyword"];
        NSString *modelNo = item[@"modelNo"];

        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        
        if (homeViewController && [homeViewController respondsToSelector:@selector(goPriceCompareDetail:keyword:)]) {
            if (modelNo && [modelNo length] > 0) {
                [homeViewController goPriceCompareDetail:modelNo keyword:keyword];
            }
        }
    }
    
	
    if (!nilCheck(self.wiseLogCode)) {
		//AccessLog - 상품
		[[AccessLog sharedInstance] sendAccessLogWithCode:self.wiseLogCode];
	}
    
    if (self.adClickItems && [self.adClickItems count] > 0) {
        //광고클릭 집계
        for (NSInteger i=0; i<[self.adClickItems count]; i++) {
            NSString *url = [self.adClickItems[i] trim];
            if (!nilCheck(url)) {
                [[AccessLog sharedInstance] sendAccessLogWithFullUrl:url];
            }
        }
    }
}

#pragma touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setTouchEffect:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setTouchEffect:NO];
	[self onTouchAction];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setTouchEffect:NO];
}

@end


