//
//  CPTrendView.m
//  11st
//
//  Created by saintsd on 2015. 6. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"
#import "CPRESTClient.h"
#import "HttpRequest.h"
#import "PullToRefreshView.h"
#import "CPCommonInfo.h"
#import "CPFooterView.h"
#import "CPFooterButtonView.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPSchemeManager.h"

#import "CPTrendTwoTabCell.h"
#import "CPTrendLineBannerCell.h"
#import "CPTrendAutoBannerCell.h"
#import "CPTrendServiceAreaCell.h"
#import "CPTrendCommonMoreCell.h"
#import "CPTrendBannerCell.h"

#define SHADOW_HEIGHT		1

@interface CPTrendView () <	CPErrorViewDelegate,
							HttpRequestDelegate,
							PullToRefreshViewDelegate,
							CPFooterViewDelegate,
							UITableViewDelegate,
							UITableViewDataSource,
							CPTrendTwoTabCellDelegate,
							CPTrendLineBannerCellDelegate,
                            CPTrendAutoBannerCellDelegate,
							CPTrendServiceAreaCellDelegate,
							CPTrendCommonMoreCellDelegate,
							CPTrendBannerCellDelegate >
{
	CPFooterView *_footerView;
	CPLoadingView *_loadingView;
	CPErrorView *_errorView;
	UITableView *_tableView;
	UIButton *_topScrollButton;

	NSDictionary *_dict;
	NSArray *_items;
}

@end

@implementation CPTrendView

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
		
		//LoadingView
		_loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
																	   CGRectGetHeight(self.frame)/2-40,
																	   80,
																	   80)];
		[self addSubview:_loadingView];
		[self stopLoadingAnimation];
	}
	return self;
}

- (void)setInfo:(NSDictionary *)info
{
	if (info) {
		_dict = [info copy];
		
		//스타일은 1.5초후 통신하도록 한다.
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
	}
	else {
		[self showErrorView];
	}
}

- (void)reloadData
{
    [self performSelectorInBackground:@selector(requestItems:) withObject:@NO];
}

- (void)reloadDataWithIgnoreCache:(NSNumber *)delay
{
    [self performSelector:@selector(requestItems:) withObject:@YES afterDelay:[delay floatValue]];
}

- (void)reloadDataWithErrorRequest
{
    if (_errorView && _loadingView.hidden) {
        [self requestItems:@YES];
    }
}

//footer login 후 데이터 갱신
- (void)reloadAfterLogin
{
	[self reloadData];
}

- (void)goToTopScroll
{
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - HttpRequest
- (void)requestItems:(NSNumber *)ignoreCache
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestItems:) object:@YES];
    
	if (!_dict || !_dict[@"url"]) {
		[self showErrorView];
		return;
	}
	
	[self startLoadingAnimation];
	
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		
		if (!requestData || 200 != [requestData[@"resultCode"] integerValue] || [requestData count] == 0)
		{
            [self reloadDataWithError:[ignoreCache boolValue]];
            return;
		}
		
		NSArray *dataArray = requestData[@"data"];
		if (dataArray) _items = [[NSArray alloc] initWithArray:dataArray];
		
        //GNB 키워드광고를 셋팅한다.
        if ([ignoreCache boolValue]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CPHomeViewController *homeViewController = app.homeViewController;
            if (homeViewController && [homeViewController respondsToSelector:@selector(setGnbSearchKeyword)]) {
                [homeViewController setGnbSearchKeyword];
            }
        }
        
		[self showContents];
		[self stopLoadingAnimation];
	};
	
	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
        [self reloadDataWithError:[ignoreCache boolValue]];
        return;
	};
	
	NSString *url = [[Modules urlWithQueryString:_dict[@"url"]] stringByAppendingFormat:@"&requestTime=%@",
					 [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if (url) {
		params[@"apiUrl"] = url;
        
        if (![ignoreCache boolValue]) {
            [[CPRESTClient sharedClient] requestCacheWithParam:params
                                                       success:requestSuccess
                                                       failure:requestFailure];
        }
        else {
            [[CPRESTClient sharedClient] requestIgnoreCacheWithParam:params
                                                             success:requestSuccess
                                                             failure:requestFailure];
        }
	}
}

- (void)reloadDataWithError:(BOOL)ignoreCache
{
    if (!ignoreCache) {
        [self stopLoadingAnimation];
        [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
        return;
    }
    else {
        [self showErrorView];
        [self stopLoadingAnimation];
    }
}

#pragma showContents
- (void)showContents
{
	[self removeErrorView];
	[self removeContents];
	
	_tableView = [[UITableView alloc] initWithFrame:self.frame];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.scrollsToTop = NO;
	_tableView.separatorColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.backgroundColor = [UIColor clearColor];
	[self addSubview:_tableView];
	
	//10픽셀짜리 임시 헤더 등록
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 10.f)];
	[_tableView setTableHeaderView:headerView];
	
	PullToRefreshView *pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:_tableView];
	[pullToRefreshView setDelegate:self];
	[_tableView addSubview:pullToRefreshView];
	
	CPFooterView *fView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:YES];
	[fView setFrame:CGRectMake(0, 10, fView.width, fView.height)];
	[fView setDelegate:self];
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fView.frame.size.width, CGRectGetMaxY(fView.frame))];
	[footerView addSubview:fView];
	[_tableView setTableFooterView:footerView];
	
	//topScrollButton
	CGFloat buttonWidth = kScreenBoundsWidth / 7;
	CGFloat buttonHeight = kToolBarHeight;
	
	_topScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_topScrollButton setFrame:CGRectMake(kScreenBoundsWidth-buttonWidth, CGRectGetHeight(self.frame)-buttonHeight, buttonWidth, buttonHeight)];
	[_topScrollButton setImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateNormal];
	[_topScrollButton addTarget:self action:@selector(onTouchTopScroll) forControlEvents:UIControlEventTouchUpInside];
	[_topScrollButton setAccessibilityLabel:@"위로" Hint:@"화면을 위로 이동합니다"];
	[_topScrollButton setHidden:YES];
	[self addSubview:_topScrollButton];
}

- (void)removeContents
{
	if (_tableView) {
		[_tableView removeFromSuperview];
		_tableView.dataSource = nil;
		_tableView.delegate = nil;
		_tableView = nil;
	}
	
	if (_topScrollButton) {
		if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
		_topScrollButton = nil;
	}
}

#pragma mark - TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *groupName = _items[indexPath.row][@"groupName"];
	
	UITableViewCell *cell = nil;
	
	if ([@"subStyleTwoTab" isEqualToString:groupName]) {
		cell = [self getTwoTabCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else if ([@"lineBanner" isEqualToString:groupName]) {
		cell = [self getLineBannerCell:tableView cellForRowAtIndexPath:indexPath];
	}
    else if ([@"autoBannerArea" isEqualToString:groupName]) {
        cell = [self getAutoBannerCell:tableView cellForRowAtIndexPath:indexPath];
    }
	else if ([@"trendBanner" isEqualToString:groupName]) {
		cell = [self getTrendBannerCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else if ([@"commonMoreView" isEqualToString:groupName]) {
		cell = [self getCommonMoreCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else if ([@"middleServiceArea" isEqualToString:groupName]) {
		cell = [self getServiceAreaCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else {
		NSString *ideneifier = @"defaultCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
		}
		
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return cell;
}

- (UITableViewCell *)getTwoTabCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"twoTabCell";
	
	NSArray *items = _items[indexPath.row][@"items"];
	
	CPTrendTwoTabCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	if (!cell) cell = [[CPTrendTwoTabCell alloc] initWithReuseIdentifier:ideneifier];
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	cell.items = items;
	
	return cell;
}

- (UITableViewCell *)getLineBannerCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"lineBannerCell";
	
	NSDictionary *item = _items[indexPath.row][@"lineBanner"];
	
	CPTrendLineBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	if (!cell) cell = [[CPTrendLineBannerCell alloc] initWithReuseIdentifier:ideneifier];
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	cell.item = item;

	return cell;
}

- (UITableViewCell *)getAutoBannerCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ideneifier = @"autoBannerCell";
    
    NSArray *items = _items[indexPath.row][@"autoBannerArea"];
    
    CPTrendAutoBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
    if (!cell) cell = [[CPTrendAutoBannerCell alloc] initWithReuseIdentifier:ideneifier];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.items = items;
    
    return cell;
}

- (UITableViewCell *)getServiceAreaCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"serviceAreaCell";
	
	NSInteger columnCount = [_items[indexPath.row][@"columnCount"] integerValue];
	NSArray *items = _items[indexPath.row][@"middleServiceArea"];
	
	CPTrendServiceAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	if (!cell) cell = [[CPTrendServiceAreaCell alloc] initWithReuseIdentifier:ideneifier];
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	cell.columnCount = columnCount;
	cell.items = items;
	
	return cell;
}

- (UITableViewCell *)getCommonMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"commonMoreCell";
	
	NSDictionary *item = _items[indexPath.row][@"commonMoreView"];
	
	CPTrendCommonMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	if (!cell) cell = [[CPTrendCommonMoreCell alloc] initWithReuseIdentifier:ideneifier];
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	cell.item = item;
	
	return cell;
}

- (UITableViewCell *)getTrendBannerCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"trendBannerCell";
	
	NSDictionary *item = _items[indexPath.row][@"trendBanner"];
	
	CPTrendBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	if (!cell) cell = [[CPTrendBannerCell alloc] initWithReuseIdentifier:ideneifier];
	
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	cell.delegate = self;
	cell.indexPath = indexPath;
	cell.item = item;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 100.f;
	
	NSString *groupName = _items[indexPath.row][@"groupName"];
	if ([@"subStyleTwoTab" isEqualToString:groupName]) {
		height = 46+SHADOW_HEIGHT;
	}
	else if ([@"lineBanner" isEqualToString:groupName]) {
		height = 70+SHADOW_HEIGHT;
	}
    else if ([@"autoBannerArea" isEqualToString:groupName]) {
        height = 70+SHADOW_HEIGHT;
    }
	else if ([@"trendBanner" isEqualToString:groupName]) {
		
		NSString *lnkBnnrImgUrl = _items[indexPath.row][@"trendBanner"][@"lnkBnnrImgUrl"];
		CGFloat thumbnailHeight = [self getHeightThumbnailImageWithUrl:lnkBnnrImgUrl];

		//Header, Thumbnail default, line
		if (thumbnailHeight == 0)	height = 64 + [Modules getRatioHeight:CGSizeMake(300, 200) screebWidth:kScreenBoundsWidth-20] + 11;
		else						height = 64 + thumbnailHeight + 1;
	}
	else if ([@"middleServiceArea" isEqualToString:groupName]) {
		NSInteger columnCount = [_items[indexPath.row][@"columnCount"] integerValue];
		NSArray *items = _items[indexPath.row][@"middleServiceArea"];
		
		height = [CPFooterButtonView viewSizeWithData:items UIType:CPFooterButtonUITypeNormal columnCount:columnCount].height+10.f;
	}
	else if ([@"commonMoreView" isEqualToString:groupName]) {
		height = 44+SHADOW_HEIGHT;
	}
	else {
		height = 0.f;
	}
	
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_topScrollButton setHidden:0 < scrollView.contentOffset.y ? NO : YES];
}

#pragma mark - Error View
- (void)showErrorView
{
	[self removeErrorView];
	[self removeContents];
	
	_errorView = [[CPErrorView alloc] initWithFrame:self.frame];
	[_errorView setDelegate:self];
	[self addSubview:_errorView];
}

- (void)removeErrorView
{
	if (_errorView) {
		[_errorView removeFromSuperview];
		_errorView.delegate = nil;
		_errorView = nil;
	}
}

- (void)didTouchRetryButton
{
	if (_dict) {
		[self removeErrorView];
        [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
															message:NSLocalizedString(@"NetworkTemporaryErrMsg", nil)
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
												  otherButtonTitles:nil, nil];
		
		[alertView show];
	}
}

#pragma mark - PullToRefreshViewDelegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
}

#pragma mark - top button
- (void)onTouchTopScroll
{
	[self onTouchTopScroll:YES];
}

- (void)onTouchTopScroll:(BOOL)animation
{
	[_tableView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - CPTrendTowTabCellDelegate
- (void)trendTwoTabCell:(CPTrendTwoTabCell *)cell moveLinkUrl:(NSString *)url
{
	
}

#pragma mark - CPTrendBannerCellDelegate
- (CGFloat)getHeightThumbnailImageWithUrl:(NSString *)imageUrl
{
	CGFloat height = 0.f;
	
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CPHomeViewController *homeViewController = app.homeViewController;

	for (NSInteger i=0; i<[homeViewController.trendImageHeightArray count]; i++) {
		NSString *tempUrl = homeViewController.trendImageHeightArray[i][@"imageUrl"];
		
		if ([tempUrl isEqualToString:imageUrl]) {
			height = [homeViewController.trendImageHeightArray[i][@"height"] floatValue];
			break;
		}
	}
	
	return height;
}

- (void)setTrendBannerCellImageHeightWithInfo:(NSDictionary *)info
{
	NSString *imageUrl = info[@"imageUrl"];
	NSString *imageHeight = info[@"imageHeight"];
	NSIndexPath *indexPath = info[@"indexPath"];
	
	CGFloat tempH = [self getHeightThumbnailImageWithUrl:imageUrl];
	
	if (tempH == 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;

		[homeViewController.trendImageHeightArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:imageUrl, @"imageUrl", imageHeight, @"height", nil]];
		
		[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						  withRowAnimation:UITableViewRowAnimationNone];
	}
}

#pragma mark - CPLoadingView
- (void)startLoadingAnimation
{
    if (_loadingView.hidden == YES) {
        [_loadingView setHidden:NO];
        [_loadingView startAnimation];
        
        [self bringSubviewToFront:_loadingView];
    }
}

- (void)stopLoadingAnimation
{
    if (_loadingView.hidden == NO) {
        [_loadingView stopAnimation];
        [_loadingView setHidden:YES];
    }
}

@end
