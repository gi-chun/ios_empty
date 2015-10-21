//
//  CPEventActiveView.m
//  11st
//
//  Created by saintsd on 2015. 6. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPEventActiveView.h"
#import "CPRESTClient.h"
#import "UIAlertView+Blocks.h"
#import "Modules.h"
#import "CPCommonInfo.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPPopupViewController.h"
#import "UIImageView+WebCache.h"
#import "AccessLog.h"


@interface CPEventActiveView () <CPPopupViewControllerDelegate>
{
	NSArray *_items;
	BOOL _isAttendYn;
	
	UIImageView *_attendIconView;
	UILabel *_attendTextLabel;
	
	UIButton *_attendButton;
}

@end

@implementation CPEventActiveView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		_isAttendYn = NO;
		
		[self initSubviews];
		[self changeAttendLayout:NO];
		[self requestAttendYn];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = UIColorFromRGB(0xf5f7ff);
	
	CGFloat buttonWidth = self.frame.size.width / [_items count];
	CGFloat buttonHeight = self.frame.size.height;

	for (NSInteger i=0; i<[_items count]; i++) {
		NSString *btnTitle = _items[i][@"text"];
		NSString *itemType = [_items[i][@"type"] lowercaseString];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
		[btn setTag:i];
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3) width:CGRectGetWidth(btn.frame) height:CGRectGetHeight(btn.frame)]
					   forState:UIControlStateHighlighted];
		[btn addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:btn];

		BOOL isAttendType = [@"attend" isEqualToString:itemType];
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        if (!isAttendType) [iconView sd_setImageWithURL:[NSURL URLWithString:_items[i][@"lnkBnnrImgUrl"]]];
		[btn addSubview:iconView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		[label setFont:[UIFont systemFontOfSize:14.f]];
		[label setText:btnTitle];
		[label setTextColor:UIColorFromRGBA(0x333333, 1.f)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextAlignment:NSTextAlignmentLeft];
		[btn addSubview:label];
		[label sizeToFitWithVersion];
		
		if (isAttendType) _attendButton = btn;
		[btn setAccessibilityLabel:btnTitle Hint:@""];
		
		if (isAttendType) label.text = @"";
		
		CGFloat attWidth = iconView.frame.size.width + 9.f + label.frame.size.width;
		CGFloat offsetX = (btn.frame.size.width/2) - (attWidth / 2);
		
		iconView.frame = CGRectMake(offsetX, (btn.frame.size.height/2)-(iconView.frame.size.height/2),
									iconView.frame.size.width, iconView.frame.size.height);
		
		label.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+9.f, (btn.frame.size.height/2)-(label.frame.size.height/2),
								 label.frame.size.width, label.frame.size.height);
		
		if (isAttendType) {
			_attendIconView = iconView;
			_attendTextLabel = label;
		}
	}
	
	UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width/2), (self.frame.size.height/2)-14, 1, 28)];
	middleLine.backgroundColor = UIColorFromRGBA(0xdfe1e8, 1.f);
	[self addSubview:middleLine];
	
	//로그인상황이 변하면 출석체크에 대한 내용을 다시 받아온다.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAttendYn) name:@"reloadLoginStatus" object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeAttendLayout:(BOOL)isAttend
{
    if (_attendIconView) {
        NSString *iconName = (isAttend ? _items[0][@"lnkBnnrImgUrl2"] : _items[0][@"lnkBnnrImgUrl"]);
        
        if (!nilCheck(iconName)) {
            [_attendIconView sd_setImageWithURL:[NSURL URLWithString:iconName]];
        }
    }
    
	if (_attendTextLabel)
	{
		_attendTextLabel.text = (isAttend ? @"출석완료" : @"출석체크");
		[_attendButton setAccessibilityLabel:_attendTextLabel.text Hint:@""];
	}
}

- (void)showAttendMessageAndMoveUrl:(NSInteger)index
{
	[UIAlertView showWithTitle:NSLocalizedString(@"AlertTitle11st", nil)
					   message:NSLocalizedString(@"AlertDidSuccessAttend", nil)
			 cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
			 otherButtonTitles:nil
					  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
						  [self openUrl:_items[index][@"redirectUrl"]];
					  }];
}

- (void)onTouchButton:(id)sender
{
	NSInteger tag = [sender tag];

	NSString *isLoginCheck = _items[tag][@"isLogin"];
	if ([@"Y" isEqualToString:isLoginCheck]) {
		if (![Modules checkLoginFromCookie]) {
			//로그인 창을 띄움.
			[self openLoginViewController];
			return;
		}
	}
	
	NSString *itemType = _items[tag][@"type"];
	BOOL isAttendType = [@"attend" isEqualToString:[itemType lowercaseString]];
	if (isAttendType && _isAttendYn) {
		[self showAttendMessageAndMoveUrl:tag];
		return;
	}
	
	NSString *linkUrl = [_items[tag][@"linkUrl"] trim];
	[self requestApiUrl:linkUrl isAttendType:isAttendType index:tag];
	
	if (tag == 0)		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0200"];
	else if (tag == 1)	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0202"];
}

- (void)requestAttendYn
{
	if (!_items || [_items count] == 0) return;
	
	NSString *requestUrl = @"";
	for (NSInteger i=0; i<[_items count]; i++) {
		NSString *type = _items[i][@"type"];
		
		if ([type isEqualToString:@"attend"]) {
			requestUrl = _items[i][@"attendEvtYn"];
			break;
		}
	}
	
	if ([requestUrl length] == 0) return;
	
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		NSLog(@"successParam : %@", requestData);
		
		if (200 == [requestData[@"resultCode"] integerValue]) {
			if ([@"Y" isEqualToString:requestData[@"attendEvtYn"]]) {
				[self changeAttendLayout:YES];
				_isAttendYn = YES;
			}
			else {
				[self changeAttendLayout:NO];
				_isAttendYn = NO;
			}
		}
		else {
			[self changeAttendLayout:NO];
			_isAttendYn = NO;
		}
	};

	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
		[self changeAttendLayout:NO];
		_isAttendYn = NO;
	};

	if (requestUrl) {
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		params[@"apiUrl"] = requestUrl;

		[[CPRESTClient sharedClient] requestCacheWithParam:params
                                                   success:requestSuccess
                                                   failure:requestFailure];
	}
}

- (void)requestApiUrl:(NSString *)url isAttendType:(BOOL)isAttendType index:(NSInteger)index
{
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		
		NSInteger alertCode = [requestData[@"alertCode"] integerValue];
		BOOL isShowAlertMsg = NO;
		
		if (isAttendType) {
			if (alertCode != 999 && alertCode != 501) {
				//출석체크 정상처리
				isShowAlertMsg = YES;
				
				_isAttendYn = YES;
				[self changeAttendLayout:YES];
				
			}
			else if (alertCode == 501) {
				//이미 출석체크 됨.
				isShowAlertMsg = NO;
				[self showAttendMessageAndMoveUrl:index];
			}
			else {
				//기타 에러
				isShowAlertMsg = YES;
			}
		}
		else {
			isShowAlertMsg = YES;
		}
		
		if (isShowAlertMsg) {
			NSString *alertMsg = [requestData[@"alertMessage"] trim];
			if (alertMsg && alertMsg.length > 0) {
				[UIAlertView showWithTitle:NSLocalizedString(@"AlertTitle11st", nil)
								   message:alertMsg
						 cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
						 otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
							 
						 }];
			}
		}
	};
	
	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
		[UIAlertView showWithTitle:NSLocalizedString(@"AlertTitle11st", nil)
						   message:NSLocalizedString(@"NetworkTemporaryErrMsg", nil)
				 cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
				 otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
					 
				 }];
	};
	
	if (url) {
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		params[@"apiUrl"] = url;
		
		[[CPRESTClient sharedClient] requestCacheWithParam:params
                                                   success:requestSuccess
                                                   failure:requestFailure];
	}
}

- (void)openUrl:(NSString *)url
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(touchEventActiveViewItemButton:)]) {
		[self.delegate touchEventActiveViewItemButton:url];
	}
}

#pragma login
- (void)openLoginViewController
{
	NSString *loginUrl = [[CPCommonInfo sharedInfo] urlInfo][@"login"];
	NSString *loginUrlString = [Modules urlWithQueryString:loginUrl];
	
	CPPopupViewController *popViewController = [[CPPopupViewController alloc] init];
	
	[popViewController setTitle:@"로그인"];
	[popViewController setIsLoginType:YES];
	[popViewController setRequestUrl:loginUrlString];
	[popViewController setDelegate:self];
	[popViewController initLayout];
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
		
	if ([homeViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[homeViewController presentViewController:popViewController animated:YES completion:nil];
	}
}

- (void)popupViewControllerDidSuccessLogin
{
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;
	if ([homeViewController respondsToSelector:@selector(reloadWebViewData)]) {
		[homeViewController reloadWebViewData];
	}
	
	[self performSelector:@selector(didFinishedAfterLogin) withObject:nil afterDelay:0.5f];
}

- (void)didFinishedAfterLogin
{
	if ([self.delegate respondsToSelector:@selector(reloadAfterLogin)]) {
		[self.delegate reloadAfterLogin];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLoginStatus" object:nil];
}

- (void)popupViewControllerAfterSuccessLogin
{
	[self popupViewControllerDidSuccessLogin];
}

@end
