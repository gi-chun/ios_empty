//
//  CPHomeHeaderView.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeHeaderView.h"
#import "CPHomeHeaderBillBannerListView.h"
#import "CPHomeDynamicServiceListView.h"
#import "AccessLog.h"

@interface CPHomeHeaderView () <	CPHomeHeaderBillBannerListViewDelegate,
									CPHomeDynamicServiceListViewDelegate >
{
	NSDictionary *_item;
	NSArray *_homeBillBannerList;
	NSArray *_dynamicHomeServiceList;
	BOOL _isShockingLogoImage;
	BOOL _isOpen;
	
	CPHomeHeaderBillBannerListView *_billBannerListView;
	CPHomeDynamicServiceListView *_dynamicServiceView;
	UIImageView *_shockingLogoView;
	UIButton *_serviceButton;
	
	UIView *_underLineView;
}

@end

@implementation CPHomeHeaderView

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item
{
	if (self = [super initWithFrame:frame]) {
		if (item) _item = [[NSDictionary alloc] initWithDictionary:item];
		
		[self initData];
		[self initSubviews];
	}
	return self;
}

- (void)initData
{
	_isOpen = ([@"Y" isEqualToString:_item[@"openYn"]]);
	
	NSArray *array = _item[@"homeBillBannerGroup"];
	
	for (NSInteger i=0; i<[array count]; i++) {
		
		NSString *groupName = array[i][@"groupName"];
		
		if ([@"homeBillBannerList" isEqualToString:groupName])
		{
			_homeBillBannerList = [[NSArray alloc] initWithArray:array[i][groupName]];
		}
		else if ([@"dynamicHomeServiceList_10" isEqualToString:groupName] && !IS_IPAD)
		{
			_dynamicHomeServiceList = [[NSArray alloc] initWithArray:array[i][groupName]];
		}
		else if ([@"dynamicHomeServiceList_12" isEqualToString:groupName] && IS_IPAD)
		{
			_dynamicHomeServiceList = [[NSArray alloc] initWithArray:array[i][groupName]];
		}
		else if ([@"homeDealLineBanner" isEqualToString:groupName])
		{
			_isShockingLogoImage = YES;
		}
	}
}

- (void)initSubviews
{
	if (!IS_IPAD)	[self initLayout_P];
	else			[self initLayout_T];
}

- (void)initLayout_P
{
	CGFloat offsetY = 0.f;

	//빌보드
	CGFloat billBannerHeight = [Modules getRatioHeight:CGSizeMake(360, 180) screebWidth:self.frame.size.width];
	_billBannerListView = [[CPHomeHeaderBillBannerListView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, billBannerHeight)
																		  items:_homeBillBannerList];
	[_billBannerListView setDelegate:self];
	[self addSubview:_billBannerListView];
	
	offsetY += _billBannerListView.frame.size.height;
	
	//바로가기
	_dynamicServiceView = [[CPHomeDynamicServiceListView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, 0)
																		items:_dynamicHomeServiceList
																  columnCount:5
																	   isOpen:NO];
	[_dynamicServiceView setDelegate:self];
	[self addSubview:_dynamicServiceView];
	
	offsetY += _dynamicServiceView.frame.size.height + 10;

	//밑줄
	_underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dynamicServiceView.frame), self.frame.size.width, 1)];
	_underLineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self addSubview:_underLineView];

	if (!_isShockingLogoImage) {
		UIImage *buttonImage = [UIImage imageNamed:(!_isOpen ? @"bg_home_quick.png" : @"bg_home_quick_open.png")];
		_serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_serviceButton.frame = CGRectMake(self.frame.size.width-20-40, CGRectGetMaxY(_dynamicServiceView.frame), 40, 24);
		[_serviceButton setImage:buttonImage forState:UIControlStateNormal];
		[_serviceButton addTarget:self action:@selector(onTouchServiceButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_serviceButton];

		offsetY = CGRectGetMaxY(_serviceButton.frame)+10;
	}
	else {
		//쇼킹딜 로고 표시
		UIImage *logoImg = [UIImage imageNamed:@"img_home_shocking.png"];
		
		_shockingLogoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(logoImg.size.width/2), offsetY,
																		  logoImg.size.width, logoImg.size.height)];
		_shockingLogoView.image = logoImg;
		[self addSubview:_shockingLogoView];
		
		offsetY += _shockingLogoView.frame.size.height + 10;
		
		UIImage *buttonImage = [UIImage imageNamed:(!_isOpen ? @"bg_home_quick.png" : @"bg_home_quick_open.png")];
		_serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_serviceButton.frame = CGRectMake(self.frame.size.width-20-40, CGRectGetMaxY(_dynamicServiceView.frame), 40, 24);
		[_serviceButton setImage:buttonImage forState:UIControlStateNormal];
		[_serviceButton addTarget:self action:@selector(onTouchServiceButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_serviceButton];
	}
	
	self.frame = CGRectMake(0, 0, self.frame.size.width, offsetY);
}

- (void)initLayout_T
{
	CGFloat offsetY = 0.f;
	
	//빌보드
	NSInteger billBannerWidth = (NSInteger)(self.frame.size.width * 0.6);
	CGFloat billBannerHeight = [Modules getRatioHeight:CGSizeMake(360, 180) screebWidth:billBannerWidth];
	_billBannerListView = [[CPHomeHeaderBillBannerListView alloc] initWithFrame:CGRectMake(0, offsetY, billBannerWidth, billBannerHeight)
																		  items:_homeBillBannerList];
	[_billBannerListView setDelegate:self];
	[self addSubview:_billBannerListView];
	
	//바로가기
	_dynamicServiceView = [[CPHomeDynamicServiceListView alloc] initWithFrame:CGRectMake(billBannerWidth, offsetY,
																						 self.frame.size.width-billBannerWidth, billBannerHeight)
																		items:_dynamicHomeServiceList
																  columnCount:4
																	   isOpen:YES];
	[_dynamicServiceView setDelegate:self];
	[self addSubview:_dynamicServiceView];
	
	offsetY += billBannerHeight + 10;

	//밑줄
	_underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, _dynamicServiceView.frame.size.height-1, self.frame.size.width, 1)];
	_underLineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self addSubview:_underLineView];

	//쇼킹딜 로고 표시
	if (_isShockingLogoImage) {
		UIImage *logoImg = [UIImage imageNamed:@"img_home_shocking.png"];
		
		_shockingLogoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(logoImg.size.width/2), offsetY,
																		  logoImg.size.width, logoImg.size.height)];
		_shockingLogoView.image = logoImg;
		[self addSubview:_shockingLogoView];
		
		offsetY += _shockingLogoView.frame.size.height + 10;
	}
	
	self.frame = CGRectMake(0, 0, self.frame.size.width, offsetY);
}

- (void)onTouchServiceButton:(id)sender
{
	_isOpen = !_isOpen;
	[_dynamicServiceView setOpenYn:_isOpen];
	
	UIImage *buttonImage = [UIImage imageNamed:(!_isOpen ? @"bg_home_quick.png" : @"bg_home_quick_open.png")];
	[_serviceButton setImage:buttonImage forState:UIControlStateNormal];

	//사이즈 계산
	_underLineView.frame = CGRectMake(0, CGRectGetMaxY(_dynamicServiceView.frame), self.frame.size.width, 1);
	
	CGFloat offset = CGRectGetMaxY(_dynamicServiceView.frame);
	if (_isShockingLogoImage) {
		_serviceButton.frame = CGRectMake(_serviceButton.frame.origin.x, offset,
										  _serviceButton.frame.size.width, _serviceButton.frame.size.height);
		
		offset += 10;
		_shockingLogoView.frame = CGRectMake(_shockingLogoView.frame.origin.x, offset,
											 _shockingLogoView.frame.size.width, _shockingLogoView.frame.size.height);
		
		offset = CGRectGetMaxY(_shockingLogoView.frame)+10;
	}
	else {
		_serviceButton.frame = CGRectMake(_serviceButton.frame.origin.x, offset,
										  _serviceButton.frame.size.width, _serviceButton.frame.size.height);
		
		offset = CGRectGetMaxY(_serviceButton.frame)+10;
	}
	
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, offset);
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(resizeHomeHeaderViewFrame:)]) {
		[self.delegate resizeHomeHeaderViewFrame:CGSizeMake(self.frame.size.width, self.frame.size.height)];
	}
}

#pragma mark - CPHomeHeaderBillBannerViewDelegate
- (void)homeHeaderBillBannerOnTouchButton
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderBillBannerOnTouchButton)]) {
		[self.delegate homeHeaderBillBannerOnTouchButton];
	}
}

@end
