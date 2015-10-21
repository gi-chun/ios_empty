//
//  CPHomePopularKeywordView.m
//  11st
//
//  Created by saintsd on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomePopularKeywordView.h"
#import "CPTouchActionView.h"

#define ITEM_HEIGHT		44
@interface CPHomePopularKeywordView ()
{
	BOOL _isOpen;
	NSArray *_items;
	
	NSInteger _randomCount;
	NSTimer *_timer;
}

@end

@implementation CPHomePopularKeywordView

+ (CGSize)viewSizeWithData:(CGFloat)width items:(NSArray *)items isOpen:(BOOL)isOpen
{
	CGFloat height = 0.f;
	
	if (isOpen) {
		
		CGFloat totalCount = 0;
		for (NSInteger i=0; i<[items count]; i++) {
			
			NSString *groupName = items[i][@"groupName"];
			
			if ([@"openLayerHeader" isEqualToString:groupName]) {
				totalCount += 1;
			}
			else if ([@"openLayerBottom" isEqualToString:groupName]) {
				totalCount += 1;
			}
			else if ([@"popularKeywordList" isEqualToString:groupName]) {
				NSArray *popularKeywordList = items[i][groupName];
				
				totalCount += popularKeywordList.count;
			}
		}
		
		height = totalCount * ITEM_HEIGHT;
	}
	else {
		height = ITEM_HEIGHT;
	}
	
	return CGSizeMake(width, height);
}

- (void)removeFromSuperview {
	
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
	
	[super removeFromSuperview];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items isOpen:(BOOL)isOpen
{
	if (self = [super initWithFrame:frame]) {
	
		_isOpen = isOpen;
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	if (_isOpen) {
		[self initOpenView];
	}
	else {
		_randomCount = [self getRandomCount];
		
		[self initCloseView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAutoScroll) name:@"startHomeTabTimer" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAutoScroll) name:@"stopHomeTabTimer" object:nil];
		
		[self startAutoScroll];
	}
}

#pragma mark - close
- (NSInteger)getRandomCount
{
	NSInteger randNum = 0;
	for (NSInteger i=0; i<[_items count]; i++) {
		
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"popularKeywordList" isEqualToString:groupName]) {
			NSArray *popularKeywordList = _items[i][groupName];
			
			randNum = rand() % [popularKeywordList count];
			break;
		}
	}
	
	return randNum;
}

- (NSInteger)getNextCount
{
	NSInteger listCount = 0;
	for (NSInteger i=0; i<[_items count]; i++) {
		
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"popularKeywordList" isEqualToString:groupName]) {
			NSArray *popularKeywordList = _items[i][groupName];
			
			listCount = [popularKeywordList count];
			break;
		}
	}
	
	NSInteger nextIndex = ++_randomCount;
	if (nextIndex >= listCount) nextIndex = 0;
	
	return nextIndex;
}


- (void)initCloseView
{
	NSArray *popularKeywordList = nil;
	
	//데이터 추출
	for (NSInteger i=0; i<[_items count]; i++) {
		NSString *groupName = _items[i][@"groupName"];
		if ([@"popularKeywordList" isEqualToString:groupName]) {
			popularKeywordList = _items[i][groupName];
		}
	}
	
	NSString *keyword = popularKeywordList[_randomCount][@"popularKeyword"][@"keyword"];
	NSString *rankOrder = popularKeywordList[_randomCount][@"popularKeyword"][@"rankOrder"];
	NSString *linkUrl = popularKeywordList[_randomCount][@"popularKeyword"][@"linkUrl"];
	
	NSString *replaceStr = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	replaceStr = [replaceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:replaceStr];

	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, ITEM_HEIGHT)];
	view.backgroundColor = [UIColor whiteColor];
	[self addSubview:view];
	
	UIImage *realTimeBG = [UIImage imageNamed:@"bg_detail_real.png"];
	realTimeBG = [realTimeBG resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
	
	UIImageView *realTimeView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 56, 24)];
	realTimeView.image = realTimeBG;
	[view addSubview:realTimeView];
	
	UILabel *realLabel = [[UILabel alloc] initWithFrame:realTimeView.bounds];
	realLabel.backgroundColor = [UIColor clearColor];
	realLabel.textColor = UIColorFromRGB(0xffffff);
	realLabel.font = [UIFont boldSystemFontOfSize:13];
	realLabel.numberOfLines = 1;
	realLabel.textAlignment = NSTextAlignmentCenter;
	realLabel.text = @"실시간";
	[realTimeView addSubview:realLabel];

	//순위
	UILabel *nLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, 41, view.frame.size.height)];
	nLabel.backgroundColor = [UIColor clearColor];
	nLabel.textColor = UIColorFromRGB(0xf62e3d);
	nLabel.font = [UIFont boldSystemFontOfSize:15];
	nLabel.numberOfLines = 1;
	nLabel.textAlignment = NSTextAlignmentCenter;
	nLabel.text = [NSString stringWithFormat:@"%ld", (long)_randomCount+1];
	[view addSubview:nLabel];

	//열기버튼
	UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[openButton setFrame:CGRectMake(view.frame.size.width-44, 0, 44, 44)];
	[openButton setImage:[UIImage imageNamed:@"bt_home_arrow_real.png"] forState:UIControlStateNormal];
	[openButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
													 width:openButton.frame.size.width
													height:openButton.frame.size.height]
						  forState:UIControlStateHighlighted];
	[openButton addTarget:self action:@selector(onTouchOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    [openButton setAccessibilityLabel:@"열기" Hint:@""];
	[view addSubview:openButton];
	
	//상승 점수
	if ([rankOrder isEqual:[NSNull null]] || [rankOrder length] == 0) {
		//new
		UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(openButton.frame.origin.x-5-37, 0, 37, view.frame.size.height)];
		newLabel.backgroundColor = [UIColor clearColor];
		newLabel.textColor = UIColorFromRGB(0xf62e3d);
		newLabel.font = [UIFont systemFontOfSize:15];
		newLabel.numberOfLines = 1;
		newLabel.textAlignment = NSTextAlignmentRight;
		newLabel.text = @"new";
		[view addSubview:newLabel];
	}
	else {
		NSInteger iconType = 0;		//0 : 상승없음, 1 : +, 2 : -
		if (-1 != [rankOrder indexOf:@"-"]) {
			iconType = 2;
			rankOrder = [rankOrder stringByReplacingOccurrencesOfString:@"-" withString:@""];
		}
		else
		{
			if ([rankOrder isEqualToString:@"0"]) {
				iconType = 0;
				rankOrder = @"";
			}
			else {
				iconType = 1;
			}
		}

		if (iconType != 0) {
			UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(openButton.frame.origin.x-5-37-10, 0, 37, view.frame.size.height)];
			numLabel.backgroundColor = [UIColor clearColor];
			numLabel.textColor = UIColorFromRGB(0x999999);
			numLabel.font = [UIFont systemFontOfSize:14];
			numLabel.numberOfLines = 1;
			numLabel.textAlignment = NSTextAlignmentRight;
			numLabel.text = rankOrder;
			[view addSubview:numLabel];
		}

		UIImage *icon = nil;
		if (iconType == 1)		icon = [UIImage imageNamed:@"ic_home_rank_up.png"];
		else if (iconType == 2) icon = [UIImage imageNamed:@"ic_home_rank_down.png"];
		else					icon = [UIImage imageNamed:@"ic_home_rank_nor.png"];
		
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(openButton.frame.origin.x-2-icon.size.width,
																			  (view.frame.size.height/2)-(icon.size.height/2),
																			  icon.size.width, icon.size.height)];
		iconView.image = icon;
		[view addSubview:iconView];
	}

	//키워드 텍스트 영역
	CGFloat keywordWidth = (openButton.frame.origin.x-5-37-10)-CGRectGetMaxX(nLabel.frame);
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nLabel.frame), 0, keywordWidth, view.frame.size.height)];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = UIColorFromRGB(0x333333);
	textLabel.font = [UIFont systemFontOfSize:14];
	textLabel.numberOfLines = 1;
	textLabel.textAlignment = NSTextAlignmentLeft;
	textLabel.text = keyword;
	[view addSubview:textLabel];
	
	//키워드 터치
	NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:keyword, @"keyword", linkUrl, @"reff", nil];
	
	CPTouchActionView *touchView = [[CPTouchActionView alloc] initWithFrame:CGRectMake(0, 0, openButton.frame.origin.x, view.frame.size.height)];
	touchView.actionType = CPButtonActionTypeGoSearchKeyword;
	touchView.actionItem = actionDict;
    [touchView setAccessibilityLabel:keyword Hint:@""];
	[view addSubview:touchView];
	
	//라인
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-1, view.frame.size.width, 1)];
	line.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[view addSubview:line];
}

- (void)onTouchOpenButton:(id)sender
{
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(homePopularKeywordView:openYn:)])
	{
		[self.delegate homePopularKeywordView:self openYn:YES];
	}
}

#pragma mark - timer
- (void)startAutoScroll
{
	if (_items.count > 1 && _timer == nil)
	{
		_timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
	}
}

- (void)stopAutoScroll
{
	if (_timer && _timer.isValid)
	{
		[_timer invalidate];
		_timer = nil;
	}
}

- (void)autoScroll
{
	for (UIView *subview in self.subviews) {
		[subview removeFromSuperview];
	}

	_randomCount = [self getNextCount];
	[self initCloseView];
}

#pragma mark - open
- (void)initOpenView
{
	NSDictionary *openLayerHeader = nil;
	NSDictionary *openLayerBottom = nil;
	NSArray *popularKeywordList = nil;

	//데이터 추출
	for (NSInteger i=0; i<[_items count]; i++) {
		
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"openLayerHeader" isEqualToString:groupName]) {
			openLayerHeader = _items[i][groupName];
		}
		else if ([@"openLayerBottom" isEqualToString:groupName]) {
			openLayerBottom = _items[i][groupName];
		}
		else if ([@"popularKeywordList" isEqualToString:groupName]) {
			popularKeywordList = _items[i][groupName];
		}
	}

	CGFloat offsetY = 0.f;
	if (openLayerHeader) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, ITEM_HEIGHT)];
		[headerView setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:headerView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = UIColorFromRGB(0xf62e3d);
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.numberOfLines = 1;
		titleLabel.textAlignment = NSTextAlignmentLeft;
		titleLabel.text = openLayerHeader[@"title"];
		[titleLabel sizeToFitWithVersion];
		[headerView addSubview:titleLabel];
		
		titleLabel.frame = CGRectMake(15, (headerView.frame.size.height/2)-(titleLabel.frame.size.height/2),
									  titleLabel.frame.size.width, titleLabel.frame.size.height);
		
        if (!IS_IPAD) {
            //닫기버튼
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton setFrame:CGRectMake(headerView.frame.size.width-44, 0, 44, 44)];
            [closeButton setImage:[UIImage imageNamed:@"bt_home_arrow_real2.png"] forState:UIControlStateNormal];
            [closeButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
                                                              width:closeButton.frame.size.width
                                                             height:closeButton.frame.size.height]
                                   forState:UIControlStateHighlighted];
            [closeButton addTarget:self action:@selector(onTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setAccessibilityLabel:@"닫기" Hint:@""];
            [headerView addSubview:closeButton];
        }
        
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
		line.backgroundColor = UIColorFromRGB(0xebebeb);
		[headerView addSubview:line];
		
		offsetY += headerView.frame.size.height;
	}
	
	if (popularKeywordList) {
		
		for (NSInteger i=0; i<[popularKeywordList count]; i++) {

			NSString *keyword = popularKeywordList[i][@"popularKeyword"][@"keyword"];
			NSString *rankOrder = popularKeywordList[i][@"popularKeyword"][@"rankOrder"];
			NSString *linkUrl = popularKeywordList[i][@"popularKeyword"][@"linkUrl"];
			
			NSString *replaceStr = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			replaceStr = [replaceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			linkUrl = [linkUrl stringByReplacingOccurrencesOfString:@"{{keyword}}" withString:replaceStr];
			
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, ITEM_HEIGHT)];
			view.backgroundColor = [UIColor whiteColor];
			[self addSubview:view];

			UILabel *nLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 41, view.frame.size.height)];
			nLabel.backgroundColor = [UIColor clearColor];
			nLabel.textColor = UIColorFromRGB(0x111111);
			nLabel.font = [UIFont boldSystemFontOfSize:15];
			nLabel.numberOfLines = 1;
			nLabel.textAlignment = NSTextAlignmentCenter;
			nLabel.text = [NSString stringWithFormat:@"%ld", (long)i+1];
			[view addSubview:nLabel];
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 0, 0, view.frame.size.height)];
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.textColor = UIColorFromRGB(0x666666);
			textLabel.font = [UIFont systemFontOfSize:16];
			textLabel.numberOfLines = 1;
			textLabel.textAlignment = NSTextAlignmentLeft;
			textLabel.text = keyword;
			[textLabel sizeToFitWithVersionHoldHeight];
			[view addSubview:textLabel];

			if ([rankOrder isEqual:[NSNull null]] || [rankOrder length] == 0) {
				//new
				UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, view.frame.size.height)];
				newLabel.backgroundColor = [UIColor clearColor];
				newLabel.textColor = UIColorFromRGB(0xf62e3d);
				newLabel.font = [UIFont systemFontOfSize:15];
				newLabel.numberOfLines = 1;
				newLabel.textAlignment = NSTextAlignmentLeft;
				newLabel.text = @"new";
				[newLabel sizeToFitWithVersionHoldHeight];
				[view addSubview:newLabel];
				
				newLabel.frame = CGRectMake(view.frame.size.width-10-newLabel.frame.size.width, 0,
											newLabel.frame.size.width, newLabel.frame.size.height);
			}
			else {
				NSInteger iconType = 0;		//0 : 상승없음, 1 : +, 2 : -
				if (-1 != [rankOrder indexOf:@"-"]) {
					iconType = 2;
					rankOrder = [rankOrder stringByReplacingOccurrencesOfString:@"-" withString:@""];
				}
				else
				{
					if ([rankOrder isEqualToString:@"0"]) {
						iconType = 0;
						rankOrder = @"";
					}
					else {
						iconType = 1;
					}
				}
				
				UIImage *icon = nil;
				if (iconType == 1)		icon = [UIImage imageNamed:@"ic_home_rank_up.png"];
				else if (iconType == 2) icon = [UIImage imageNamed:@"ic_home_rank_down.png"];
				else					icon = [UIImage imageNamed:@"ic_home_rank_nor.png"];
				
				UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width-10-icon.size.width,
																					  (view.frame.size.height/2)-(icon.size.height/2),
																					  icon.size.width, icon.size.height)];
				iconView.image = icon;
				[view addSubview:iconView];
				
				if (iconType != 0) {
					UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, view.frame.size.height)];
					numLabel.backgroundColor = [UIColor clearColor];
					numLabel.textColor = UIColorFromRGB(0x999999);
					numLabel.font = [UIFont systemFontOfSize:14];
					numLabel.numberOfLines = 1;
					numLabel.textAlignment = NSTextAlignmentLeft;
					numLabel.text = rankOrder;
					[numLabel sizeToFitWithVersionHoldHeight];
					[view addSubview:numLabel];
					
					numLabel.frame = CGRectMake(iconView.frame.origin.x-4-numLabel.frame.size.width, 0,
												numLabel.frame.size.width, numLabel.frame.size.height);
				}
			}
			
			UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-1, view.frame.size.width, 1)];
			line.backgroundColor = UIColorFromRGB(0xebebeb);
			[view addSubview:line];
			
			NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:keyword, @"keyword", linkUrl, @"reff", nil];
			
			CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:view.bounds];
			actionView.actionType = CPButtonActionTypeGoSearchKeyword;
			actionView.actionItem = actionDict;
            [actionView setAccessibilityLabel:keyword Hint:@""];
			[view addSubview:actionView];
			
			offsetY += view.frame.size.height;
		}
	}
	
	if (openLayerBottom)
	{
		NSString * updateTimeStr = openLayerBottom[@"title"];
		
		UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, ITEM_HEIGHT)];
		bottomView.backgroundColor = UIColorFromRGB(0xf9f9f9);
		[self addSubview:bottomView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = UIColorFromRGB(0x8c6239);
		titleLabel.font = [UIFont boldSystemFontOfSize:14];
		titleLabel.numberOfLines = 1;
		titleLabel.textAlignment = NSTextAlignmentLeft;
		titleLabel.text = updateTimeStr;
		[titleLabel sizeToFitWithVersion];
		[bottomView addSubview:titleLabel];
		
		titleLabel.frame = CGRectMake(15, (bottomView.frame.size.height/2)-(titleLabel.frame.size.height/2),
									  titleLabel.frame.size.width, titleLabel.frame.size.height);
		
		
		if (!IS_IPAD) {
			UIImageView *closeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(bottomView.frame.size.width-24,
																					  (bottomView.frame.size.height/2)-(7),
																					  14, 14)];
			closeImgView.image = [UIImage imageNamed:@"ic_home_rank_close.png"];
			[bottomView addSubview:closeImgView];
			
			UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			closeLabel.backgroundColor = [UIColor clearColor];
			closeLabel.textColor = UIColorFromRGB(0x666666);
			closeLabel.font = [UIFont systemFontOfSize:13];
			closeLabel.text = @"닫기";
			[closeLabel sizeToFitWithVersion];
			[bottomView addSubview:closeLabel];
			
			closeLabel.frame = CGRectMake(closeImgView.frame.origin.x-5-closeLabel.frame.size.width,
										  (bottomView.frame.size.height/2)-(closeLabel.frame.size.height/2),
										  closeLabel.frame.size.width, closeLabel.frame.size.height);
			
			UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			closeBtn.frame = CGRectMake(closeLabel.frame.origin.x-3, closeLabel.frame.origin.y-6,
										closeLabel.frame.size.width+5+closeImgView.frame.size.width+6,
										closeLabel.frame.size.height+12);
			[closeBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
														   width:closeBtn.frame.size.width
														  height:closeBtn.frame.size.height]
								forState:UIControlStateHighlighted];
			[closeBtn addTarget:self action:@selector(onTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            [closeBtn setAccessibilityLabel:@"닫기" Hint:@""];
			[bottomView addSubview:closeBtn];
		}
		
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, bottomView.frame.size.height-1, bottomView.frame.size.width, 1)];
		line.backgroundColor = UIColorFromRGB(0xd1d1d6);
		[bottomView addSubview:line];
	}
}

- (void)onTouchCloseButton:(id)sender
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(homePopularKeywordView:openYn:)])
	{
		[self.delegate homePopularKeywordView:self openYn:NO];
	}
}

@end
