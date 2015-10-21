//
//  CPBrandView.m
//  11st
//
//  Created by saintsd on 2015. 6. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPBrandView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"

#import "CPRESTClient.h"
#import "HttpRequest.h"
#import "PullToRefreshView.h"
#import "CPSchemeManager.h"

#import "CPMainTabCollectionData.h"
#import "CPMainTabCollectionViewFlowlayout.h"
#import "CPMainTabCollectionCell.h"
#import "CPCommonInfo.h"
#import "CPFooterView.h"
#import "AccessLog.h"

#import "CPHomeViewController.h"

#define HEADER_HEIGHT       64

@interface CPBrandView () <	CPErrorViewDelegate,
							HttpRequestDelegate,
							PullToRefreshViewDelegate,
							CPFooterViewDelegate,
							CPMainTabCollectionCellDelegate,
							UICollectionViewDataSource,
							UICollectionViewDelegate  >
{
	UICollectionView *_collectionView;
	CPFooterView *_footerView;
	CPMainTabCollectionViewFlowlayout *_collectionLayout;
	CPLoadingView *_loadingView;
	CPErrorView *_errorView;
	UIButton *_topScrollButton;
	
	CPMainTabCollectionData *_collectionData;
	NSDictionary *_item;
	NSMutableDictionary *_topBrandAreaItem;
	
	//IOS6, IOS7 bug를 위해 임시 저장
	UICollectionReusableView *saveHeaderView;
	UICollectionReusableView *saveFooterView;
	
	UIView *_headerMenuView;
}
@end

@implementation CPBrandView

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
		
		_collectionData = [[CPMainTabCollectionData alloc] init];
		_collectionLayout = [[CPMainTabCollectionViewFlowlayout alloc] init];
		_footerView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:YES];
		
		_topBrandAreaItem = [NSMutableDictionary dictionary];
		
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
		_item = [info copy];
		
		//마트는 1.5초후 통신하도록 한다.
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:2.5];
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
    [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - HttpRequest
- (void)requestItems:(NSNumber *)ignoreCache
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestItems:) object:@YES];
    
	if (!_item || !_item[@"url"]) {
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
		
		if (_topBrandAreaItem) {
			[_topBrandAreaItem removeAllObjects];
		}
		
		[_collectionData removeAllObjects];

		if (dataArray) {
			[_collectionData setData:dataArray];
			
			for (NSInteger i=0; i<[dataArray count]; i++) {
				NSString *groupName = dataArray[i][@"groupName"];
				
				if ([@"topBrandArea" isEqualToString:groupName]) {
					_topBrandAreaItem = [dataArray[i] mutableCopy];
					break;
				}
			}
		}

        //GNB 키워드광고를 셋팅한다.
        if ([ignoreCache boolValue]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CPHomeViewController *homeViewController = app.homeViewController;
            if (homeViewController && [homeViewController respondsToSelector:@selector(setGnbSearchKeyword)]) {
                [homeViewController setGnbSearchKeyword];
            }
        }
        
		[self showContents];
		
		if (_collectionView) {
			[_collectionView performBatchUpdates:^{
				
			} completion:^(BOOL finished) {
				[_collectionView reloadData];
			}];
		}
		
		[self stopLoadingAnimation];
	};
	
	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
        [self reloadDataWithError:[ignoreCache boolValue]];
        return;
	};
	
	NSString *url = [[Modules urlWithQueryString:_item[@"url"]] stringByAppendingFormat:@"&requestTime=%@",
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
	
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, 64.f)];
	[_collectionLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, _footerView.height+20.f)];
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
										 collectionViewLayout:_collectionLayout];
	[_collectionView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
	[_collectionView setDelegate:self];
	[_collectionView setDataSource:self];
	[_collectionView setClipsToBounds:YES];
	[_collectionView registerClass:[CPMainTabCollectionCell class] forCellWithReuseIdentifier:@"noData"];
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
	[self addSubview:_collectionView];
	
	NSArray *allGroupName = [NSArray arrayWithArray:[_collectionData getAllGroupName]];
	for (NSString *str in allGroupName) {
		[_collectionView registerClass:[CPMainTabCollectionCell class] forCellWithReuseIdentifier:str];
	}
	
	PullToRefreshView *pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:_collectionView];
	[pullToRefreshView setDelegate:self];
	[_collectionView addSubview:pullToRefreshView];
	
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
	if (_collectionView) {
		for (UIView *subview in [_collectionView subviews]) {
			[subview removeFromSuperview];
		}
		
		[_collectionView removeFromSuperview];
		_collectionView.dataSource = nil;
		_collectionView.delegate = nil;
	}
	
	if (_topScrollButton) {
		if (!_topScrollButton.hidden)	[_topScrollButton removeFromSuperview];
		_topScrollButton = nil;
	}
}

#pragma mark - UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_topScrollButton setHidden:0 < scrollView.contentOffset.y ? NO : YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	//검색결과가 없을 때 UI를 그리기 위한 코드
	BOOL isNoData = _collectionData.items.count == 0 ? YES : NO;
	
	return (isNoData ? 1 : _collectionData.items.count);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [_collectionData getSizeForItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *reusableview = nil;
	
	if ([kind isEqual:UICollectionElementKindSectionHeader]) {
		
		UICollectionReusableView *headerView;
		
		@try {
			headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
			saveHeaderView = headerView;
		}
		@catch (NSException *exception) {
			headerView = saveHeaderView;
		}
		@finally {}
		
		_headerMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 54)];
		[headerView addSubview:_headerMenuView];
		
		//메뉴
		NSArray *tapItems = _topBrandAreaItem[@"topBrandArea"];
		for (NSDictionary *dic in tapItems) {
			NSInteger itemWidth = kScreenBoundsWidth / tapItems.count;
			NSInteger itemHeight = (int)CGRectGetHeight(_headerMenuView.frame);
			NSInteger itemX = [tapItems indexOfObject:dic] * itemWidth;
			NSInteger itemY = 0;
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setTag:[tapItems indexOfObject:dic]];
			[button setFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)];
			[button setTitle:dic[@"text"] forState:UIControlStateNormal];
			[button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
			[button setContentEdgeInsets:UIEdgeInsetsMake(26, 0, 0, 0)];
			[button setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[button setBackgroundColor:UIColorFromRGB(0xf1f1f1)];
			[button.titleLabel setFont:[UIFont systemFontOfSize:12]];
			[button addTarget:self action:@selector(onTouchMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
			[_headerMenuView addSubview:button];
			
			NSString *imageName = @"";
			
			if ([tapItems indexOfObject:dic] == 0)		imageName = @"ic_brand1.png";
			else if ([tapItems indexOfObject:dic] == 1) imageName = @"ic_brand2.png";
			else if ([tapItems indexOfObject:dic] == 3) imageName = @"ic_brand3.png";
			else										imageName = @"ic_brand4.png";
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(button.frame)-24)/2, 6, 24, 24)];
			[imageView setImage:[UIImage imageNamed:imageName]];
			[button addSubview:imageView];
		}
		
		reusableview = headerView;
	}
	else if ([kind isEqual:UICollectionElementKindSectionFooter]) {
		
		UICollectionReusableView *footerView;
		
		@try {
			footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
			saveFooterView = footerView;
		}
		@catch (NSException *exception) {
			footerView = saveFooterView;
		}
		@finally {}
		
		//footerView
		[_footerView setFrame:CGRectMake(0, 20, _footerView.width, _footerView.height)];
		[_footerView setDelegate:self];
		[footerView addSubview:_footerView];
		
		[_collectionLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, 20+CGRectGetHeight(_footerView.frame))];
		reusableview = footerView;
	}
	
	return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *groupName = @"noData";
	
	if (_collectionData.items.count > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		dic = _collectionData.items[indexPath.row];
		groupName = dic[@"groupName"];
	}
	
	[[CPCommonInfo sharedInfo] setGroupName:groupName];
	CPMainTabCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:groupName forIndexPath:indexPath];
	[cell setDelegate:self];
	[cell setData:_collectionData indexPath:indexPath];
	
	return cell;
}

//메뉴 클릭
- (void)onTouchMenuClicked:(id)sender
{
	NSInteger tag = [sender tag];

	NSArray *tapItems = _topBrandAreaItem[@"topBrandArea"];
	NSString *linkUrl = tapItems[tag][@"linkUrl"];
	
	if (linkUrl && [[linkUrl trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:linkUrl];
		}
	}
    
    if (tag == 0)       [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0101"];
    else if (tag == 1)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0102"];
    else if (tag == 2)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0103"];
    else if (tag == 3)  [[AccessLog sharedInstance] sendAccessLogWithCode:@"MAP0104"];
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
	if (_item) {
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
	[_collectionView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - CPCollectionViewCommonCell Delegate
- (void)didTouchButtonWithUrl:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:url];
		}
	}
}

- (NSString *)getViewWiselogCode:(NSString *)type
{
    NSString *code = @"";
    
    if ([type isEqualToString:@"commonMoreView"])	code = @"MAP07";
    
    return code;
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

