//
//  CPHomeHeaderBillBannerListView.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeHeaderBillBannerListView.h"
#import "SwipeView.h"
#import "NSTimer+Blocks.h"
#import "CPHomeBillBannerListItem.h"
#import "AccessLog.h"

@interface CPHomeHeaderBillBannerListView () < SwipeViewDataSource, SwipeViewDelegate >
{
	NSArray *_items;
	NSTimer *_timer;
	NSInteger _currentIndex;
	
	SwipeView *_swipeView;
	UIButton *_leftBtn;
	UIButton *_rightBtn;
	
	UILabel *_countLabel;
	UILabel *_totalCountLabel;
	UIButton *_allButton;
}

@end

@implementation CPHomeHeaderBillBannerListView

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
		[_leftBtn addTarget:self action:@selector(scrollPrev) forControlEvents:UIControlEventTouchUpInside];
        [_leftBtn setAccessibilityLabel:@"이전 광고 보기" Hint:@""];
		[self addSubview:_leftBtn];
		
		UIImageView *leftArrowView = [[UIImageView alloc] initWithImage:leftImage];
		[leftArrowView setCenter:CGPointMake(_leftBtn.frame.size.width/2, _leftBtn.frame.size.height/2)];
		[_leftBtn addSubview:leftArrowView];
		
		
		UIImage *rightImage = [UIImage imageNamed:@"bt_home_arrow_right.png"];
		
		_rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightBtn.frame = CGRectMake(self.frame.size.width-10-rightImage.size.width, 0,
									 rightImage.size.width+10, self.frame.size.height);
		[_rightBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
														width:rightImage.size.width+10
													   height:self.frame.size.height]
							 forState:UIControlStateHighlighted];
		
		[_rightBtn addTarget:self action:@selector(scrollNext) forControlEvents:UIControlEventTouchUpInside];
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
		
		_totalCountLabel.frame = CGRectMake(self.frame.size.width-10-_totalCountLabel.frame.size.width-65,
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
		
		_totalCountLabel.frame = CGRectMake(self.frame.size.width-10-_totalCountLabel.frame.size.width-65,
											self.frame.size.height-5-_totalCountLabel.frame.size.height,
											_totalCountLabel.frame.size.width,
											_totalCountLabel.frame.size.height);
		
		_countLabel.frame = CGRectMake(_totalCountLabel.frame.origin.x-2-_countLabel.frame.size.width,
									   self.frame.size.height-5-_countLabel.frame.size.height,
									   _countLabel.frame.size.width,
									   _countLabel.frame.size.height);
		
		_allButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_allButton.frame = CGRectMake(self.frame.size.width-60, self.frame.size.height-28, 60, 28);
		[_allButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.7)
														 width:60
														height:28]
							  forState:UIControlStateNormal];
		[_allButton setImage:[UIImage imageNamed:@"ic_home_all.png"] forState:UIControlStateNormal];
		[_allButton setTitle:@"전체" forState:UIControlStateNormal];
		[_allButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
		[_allButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
		[_allButton setTitleEdgeInsets:UIEdgeInsetsMake(2, -22, 0, 0)];
		[_allButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
		[_allButton addTarget:self action:@selector(onTouchAllButton:) forControlEvents:UIControlEventTouchUpInside];
        [_allButton setAccessibilityLabel:@"빌보드광고 전체보기" Hint:@""];
		[self addSubview:_allButton];
	}
	
	_currentIndex = rand() % [_items count];
    [_swipeView scrollToPage:_currentIndex duration:0];
	[self startAutoScroll];
	[self setCountLabel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAutoScroll) name:@"startHomeTabTimer" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAutoScroll) name:@"stopHomeTabTimer" object:nil];
}

- (void)onTouchAllButton:(id)sender
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderBillBannerOnTouchButton)]) {
		[self.delegate homeHeaderBillBannerOnTouchButton];
	}
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAJ0102"];
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
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAJ0104"];
}

- (void)scrollNext
{
	NSUInteger nextPage = _currentIndex + 1;
	[_swipeView scrollToPage:nextPage duration:0.3];
    
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAJ0104"];
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
	return _items.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
	if (view == nil)	view = [[CPHomeBillBannerListItem alloc] initWithFrame:self.bounds];

    NSString *wiseLogCode = @"";
    if (index == 0)             wiseLogCode = @"MAJ0101";
    else if (index == 1)        wiseLogCode = @"MAJ0117";
    else if (index == 2)        wiseLogCode = @"MAJ0106";
    else if (index == 3)        wiseLogCode = @"MAJ0107";
    else if (index == 4)        wiseLogCode = @"MAJ0108";
    else if (index == 5)        wiseLogCode = @"MAJ0109";
    else if (index == 6)        wiseLogCode = @"MAJ0110";
    else if (index == 7)        wiseLogCode = @"MAJ0111";
    else if (index == 8)        wiseLogCode = @"MAJ0112";
    else if (index == 9)        wiseLogCode = @"MAJ0113";
    else if (index == 10)       wiseLogCode = @"MAJ0114";
    else if (index == 11)       wiseLogCode = @"MAJ0115";
    else                        wiseLogCode = @"MAJ0116";
    
	[view setFrame:self.bounds];
	[(CPHomeBillBannerListItem *)view setItem:_items[index]];
    [(CPHomeBillBannerListItem *)view setWiseLogCode:wiseLogCode];
	
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
}

- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate
{
	NSLog(@"swipeViewDidEndDragging");
	
	@try {
		[self startAutoScroll];
	}
	@catch (NSException *exception) {
		
	}
}
@end
