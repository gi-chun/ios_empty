//
//  CPMartBillBannerListView.m
//  11st
//
//  Created by saintsd on 2015. 6. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMartBillBannerListView.h"
#import "CPMartBillBannerItem.h"
#import "SwipeView.h"
#import "NSTimer+Blocks.h"
#import "AccessLog.h"


@interface CPMartBillBannerListView () < SwipeViewDataSource, SwipeViewDelegate >
{
	NSArray	*_items;
	NSTimer *_timer;
	NSInteger _currentIndex;
	
	SwipeView *_swipeView;
	UIButton *_leftBtn;
	UIButton *_rightBtn;
	
	UILabel *_countLabel;
	UILabel *_totalCountLabel;
}

@end

@implementation CPMartBillBannerListView

- (void)dealloc
{
	[self releaseSwipeView];

	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}

	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeFromSuperview
{
	[self releaseSwipeView];
	
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}

	[super removeFromSuperview];
}

- (void)releaseSwipeView
{
	if (_swipeView) {
		_swipeView.dataSource = nil;
		_swipeView.delegate = nil;
		_swipeView = nil;
	}
}

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	_swipeView = [[SwipeView alloc] initWithFrame:self.bounds];
	_swipeView.dataSource = self;
	_swipeView.delegate = self;
	_swipeView.wrapEnabled = YES;
	_swipeView.pagingEnabled = YES;
	_swipeView.itemsPerPage = 1;
	_swipeView.alignment = SwipeViewAlignmentCenter;
	[self addSubview:_swipeView];

	if (_items.count > 1) {
		
		UIImage *leftImage = [UIImage imageNamed:@"bt_home_arrow_left.png"];
		
		_leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_leftBtn.frame = CGRectMake(0, 0, leftImage.size.width+10, self.frame.size.height);
		[_leftBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
													   width:leftImage.size.width+10.f
													  height:self.frame.size.height]
							forState:UIControlStateHighlighted];
        [_leftBtn addTarget:self action:@selector(onClickLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_leftBtn];

		UIImageView *leftArrowView = [[UIImageView alloc] initWithImage:leftImage];
		[leftArrowView setCenter:CGPointMake(_leftBtn.frame.size.width/2, _leftBtn.frame.size.height/2)];
        [_leftBtn setAccessibilityLabel:@"이전 광고 보기" Hint:@""];
		[_leftBtn addSubview:leftArrowView];
		
		
		UIImage *rightImage = [UIImage imageNamed:@"bt_home_arrow_right.png"];
		
		_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightBtn.frame = CGRectMake(self.frame.size.width-10-rightImage.size.width, 0,
									 rightImage.size.width+10, self.frame.size.height);
		[_rightBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
														width:rightImage.size.width+10
													   height:self.frame.size.height]
							 forState:UIControlStateHighlighted];
		
		[_rightBtn addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setAccessibilityLabel:@"다음 광고 보기" Hint:@""];
		[self addSubview:_rightBtn];
		
		UIImageView *rightArrowView = [[UIImageView alloc] initWithImage:rightImage];
		[rightArrowView setCenter:CGPointMake(_rightBtn.frame.size.width/2, _rightBtn.frame.size.height/2)];
		[_rightBtn addSubview:rightArrowView];
		
		_totalCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_totalCountLabel.backgroundColor = [UIColor clearColor];
		_totalCountLabel.textColor = UIColorFromRGB(0x333333);
		_totalCountLabel.font = [UIFont boldSystemFontOfSize:13];
		_totalCountLabel.text = @"/ 00";
		[_totalCountLabel sizeToFitWithVersion];
		[self addSubview:_totalCountLabel];
		
		_totalCountLabel.frame = CGRectMake(self.frame.size.width-10-_totalCountLabel.frame.size.width,
											self.frame.size.height-5-_totalCountLabel.frame.size.height,
											_totalCountLabel.frame.size.width,
											_totalCountLabel.frame.size.height);
		
		_countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_countLabel.backgroundColor = [UIColor clearColor];
		_countLabel.textColor = UIColorFromRGB(0x333333);
		_countLabel.font = [UIFont boldSystemFontOfSize:15];
		_countLabel.text = @"00";
		_countLabel.textAlignment = NSTextAlignmentRight;
		[_countLabel sizeToFitWithVersion];
		[self addSubview:_countLabel];
		
		_totalCountLabel.frame = CGRectMake(self.frame.size.width-10-_totalCountLabel.frame.size.width,
											self.frame.size.height-5-_totalCountLabel.frame.size.height,
											_totalCountLabel.frame.size.width,
											_totalCountLabel.frame.size.height);
		
		_countLabel.frame = CGRectMake(_totalCountLabel.frame.origin.x-2-_countLabel.frame.size.width,
									   self.frame.size.height-5-_countLabel.frame.size.height,
									   _countLabel.frame.size.width,
									   _countLabel.frame.size.height);
	}
	
    _currentIndex = rand() % [_items count];
    [_swipeView scrollToPage:_currentIndex duration:0];
	[self startAutoScroll];
	[self setCountLabel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAutoScroll) name:@"startHomeTabTimer" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAutoScroll) name:@"stopHomeTabTimer" object:nil];
}

#pragma countLabel
- (void)setCountLabel
{
	if (_items.count > 0) {
		_countLabel.text = [NSString stringWithFormat:@"%ld", (long)_currentIndex+1];
		_totalCountLabel.text = [NSString stringWithFormat:@"/ %2ld", (long)_items.count];
	}
}

#pragma mark - timer
- (void)startAutoScroll
{
	if (_items.count > 1 && _timer == nil)
	{
		_timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
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
	[self scrollNext];
}

- (void)scrollPrev
{
	NSUInteger prevPage = _currentIndex - 1;
	[_swipeView scrollToPage:prevPage duration:0.3];
}

- (void)scrollNext
{
	NSUInteger nextPage = _currentIndex + 1;
	[_swipeView scrollToPage:nextPage duration:0.3];
}


- (void)onClickLeftBtn:(id)sender
{
    [self scrollPrev];
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0301"];
}

- (void)onClickRightBtn:(id)sender
{
    [self scrollNext];
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0302"];
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
	return _items.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
	if (view == nil)	view = [[CPMartBillBannerItem alloc] initWithFrame:self.bounds];
	
    NSString *wiseLogCode = @"";
    
    if (index == 0)         wiseLogCode = @"MAP0303";
    else if (index == 1)    wiseLogCode = @"MAP0304";
    else if (index == 2)    wiseLogCode = @"MAP0305";
    else if (index == 3)    wiseLogCode = @"MAP0306";
    else if (index == 4)    wiseLogCode = @"MAP0307";
    
	[view setFrame:self.bounds];
	[(CPMartBillBannerItem *)view setItem:_items[index][@"martBillBanner"]];
    [(CPMartBillBannerItem *)view setWiseLogCode:wiseLogCode];
	
	return view;
}

#pragma mark - SwipeViewDelegate

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
	return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
	_currentIndex = swipeView.currentItemIndex;
	[self setCountLabel];
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
	NSLog(@"didSelectItem : %ld", (long)index);
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
	NSLog(@"swipeViewWillBeginDragging");
	
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
	@try {
		[self stopAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
}

- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate
{
	NSLog(@"swipeViewDidEndDragging");
	
	[self startAutoScroll];
}


@end
