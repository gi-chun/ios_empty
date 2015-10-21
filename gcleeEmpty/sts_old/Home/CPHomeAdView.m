//
//  CPHomeAdView.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeAdView.h"
#import "CPRESTClient.h"
#import "HttpRequest.h"
#import "CPTouchActionView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"

@interface CPHomeAdView () <HttpRequestDelegate>
{
	NSDictionary *_item;
}

@end

@implementation CPHomeAdView

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item
{
	if (self = [super initWithFrame:frame]) {
		if (item) _item = [[NSDictionary alloc] initWithDictionary:item];
		
		[self removeContents];
		
		if (_item) {
			NSString *url = _item[@"dispObjLnkUrl"];
			[self requestItem:url];
		}
	}
	return self;
}

- (void)requestItem:(NSString *)url
{
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		
		[self showContents:requestData];
	};
	
	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
	};
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if (url) {
		params[@"apiUrl"] = url;
		[[CPRESTClient sharedClient] requestCacheWithParam:params
                                                   success:requestSuccess
                                                   failure:requestFailure];
	}
}

- (void)showContents:(NSDictionary *)item
{
	NSString *bgColor = item[@"BGCOLOR"];
	if (bgColor && bgColor.length >= 7) {
		unsigned colorInt = 0;
		[[NSScanner scannerWithString:[bgColor substringWithRange:NSMakeRange(1, 6)]] scanHexInt:&colorInt];
		[self setBackgroundColor:UIColorFromRGB(colorInt)];
	}
	else {
		[self setBackgroundColor:[UIColor clearColor]];
	}
	
	NSString *imageUrl = item[@"IMG1"];
	if (imageUrl && [imageUrl length] > 0) {
		CPThumbnailView *bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-160, 0, 320, 48)];
		[bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
		[self addSubview:bannerImageView];
	}
	
	NSString *linkUrl = item[@"LURL1"];
    NSString *ALT = item[@"ALT"];
	if (linkUrl && [linkUrl length] > 0) {
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:self.bounds];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = linkUrl;

        if (ALT && [ALT length] > 0) [actionView setAccessibilityLabel:ALT Hint:@""];
        
		[self addSubview:actionView];
	}
    
    
	
}

- (void)removeContents
{
	for (UIView *subview in self.subviews) {
		[subview removeFromSuperview];
	}
 }

@end
