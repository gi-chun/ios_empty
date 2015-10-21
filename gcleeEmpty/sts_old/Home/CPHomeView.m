//
//  CPHomeView.m
//  11st
//
//  Created by saintsd on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"

#import "CPRESTClient.h"
#import "HttpRequest.h"
#import "PullToRefreshView.h"
#import "CPSchemeManager.h"

#import "CPMainTabCollectionData.h"
#import "CPMainTabCollectionViewFlowlayout.h"
#import "CPMainTabCollectionCell.h"
#import "CPMainTabSizeManager.h"
#import "CPCommonInfo.h"
#import "CPHomeHeaderView.h"
#import "CPFooterView.h"
#import "CPHomeTotalBillBannerView.h"
#import "CPHomeAdView.h"
#import "CPTouchActionView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "CPCommonInfo.h"

@interface CPHomeView () <	CPErrorViewDelegate,
							HttpRequestDelegate,
							PullToRefreshViewDelegate,
							CPFooterViewDelegate,
							CPMainTabCollectionCellDelegate,
							CPHomeHeaderViewDelegate,
							CPHomeTotalBillBannerViewDelegate,
							UICollectionViewDataSource,
							UICollectionViewDelegate  >
{
	
	UICollectionView *_collectionView;
	CPFooterView *_footerView;
	CPMainTabCollectionViewFlowlayout *_collectionLayout;
	CPLoadingView *_loadingView;
	CPErrorView *_errorView;
	CPHomeAdView *_footerAdView;
	UIButton *_topScrollButton;
	
	CPMainTabCollectionData *_collectionData;
	NSDictionary *_dict;
	NSMutableDictionary *_headerDict;
	NSMutableArray *_billBannerGroupArr;
	NSMutableDictionary *_footerAdDict;
	NSMutableArray *_floatingBannerArr;
	NSMutableDictionary *_datafreeDict;
	
	//IOS6, IOS7 bug를 위해 임시 저장
	UICollectionReusableView *saveHeaderView;
	UICollectionReusableView *saveFooterView;
	
	//floating Banner
	UIView *_floatingView;
	UIButton *_floatingCloseButton;
}

@end

@implementation CPHomeView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
		
		_collectionData = [[CPMainTabCollectionData alloc] init];
		_collectionLayout = [[CPMainTabCollectionViewFlowlayout alloc] init];
		
		_footerView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:YES];
		
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
		[self reloadData];
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
    
	if (!_dict || !_dict[@"url"]) {
		[self showErrorView];
		return;
	}
	
	NSString *url = _dict[@"url"];
	
    [self requestItemWithUrl:url ignoreCache:[ignoreCache boolValue]];
}

- (void)requestItemWithUrl:(NSString *)url ignoreCache:(BOOL)ignoreCache
{
	if (!url && [url length] == 0) return;
	
	url = [[Modules urlWithQueryString:url] stringByAppendingFormat:@"&requestTime=%@",
		   [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
	
	[self startLoadingAnimation];
	
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		
		if (!requestData || 200 != [requestData[@"resultCode"] integerValue] || [requestData count] == 0)
		{
            [self reloadDataWithError:ignoreCache];
			return;
		}
		
		NSArray *dataArray = [self transferDataArray:requestData[@"data"] homeDealFixedYn:requestData[@"homeDealFixedYn"]];
		
		[_collectionData removeAllObjects];
		
		if (_headerDict) {
			[_headerDict removeAllObjects];
			_headerDict = nil;
		}
		
		if (_billBannerGroupArr) {
			[_billBannerGroupArr removeAllObjects];
			_billBannerGroupArr = nil;
		}

		if (_floatingBannerArr) {
			[_floatingBannerArr removeAllObjects];
			_floatingBannerArr = nil;
		}
		
		if (_footerAdDict) {
			[_footerAdDict removeAllObjects];
			_footerAdDict = nil;
		}
		
		if (_datafreeDict) {
			[_datafreeDict removeAllObjects];
			_datafreeDict = nil;
		}
		
		NSArray *layerData = requestData[@"layerData"];
		if (layerData) {
			for (NSInteger i=0; i<[layerData count]; i++) {
				NSString *groupName = layerData[i][@"groupName"];
				
				if ([@"billGroupBannerList" isEqualToString:groupName]) {
					_billBannerGroupArr = [[NSMutableArray alloc] initWithArray:layerData[i][groupName]];
				}
				else if ([@"floatingBannerList" isEqualToString:groupName]) {
					_floatingBannerArr = [[NSMutableArray alloc] initWithArray:layerData[i][groupName]];
				}
				else if ([@"dataFreeBanner" isEqualToString:groupName]) {
					_datafreeDict = [[NSMutableDictionary alloc] initWithDictionary:layerData[i][groupName]];
				}
			}
		}
		
		if (dataArray) {
			[_collectionData setData:dataArray];
			
			//빌보드 배너값을 가져온다.(HEADER VIEW 사용)
			for (NSInteger i=0; i<[dataArray count]; i++) {
				NSString *groupName = dataArray[i][@"groupName"];
				
				if ([@"homeBillBannerGroup" isEqualToString:groupName]) {
					_headerDict = [[NSMutableDictionary alloc] initWithDictionary:dataArray[i] copyItems:YES];
					[_headerDict setValue:(IS_IPAD ? @"Y" : @"N") forKey:@"openYn"];
				}
				else if ([@"adLineBanner" isEqualToString:groupName]) {
					_footerAdDict = [[NSMutableDictionary alloc] initWithDictionary:dataArray[i][groupName]];
				}
			}
		}
        
        //GNB 키워드광고를 셋팅한다.
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = app.homeViewController;
        if (homeViewController && [homeViewController respondsToSelector:@selector(setGnbSearchKeyword)]) {
            [homeViewController setGnbSearchKeyword];
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
        [self reloadDataWithError:ignoreCache];
        return;
	};
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	if (url) {
		params[@"apiUrl"] = url;
        
        if (!ignoreCache) {
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
    if (homeViewController && [homeViewController respondsToSelector:@selector(onTouchCloseDataFreeView:)]) {
        [homeViewController onTouchCloseDataFreeView:nil];
    }
    
	[self removeErrorView];
	[self removeContents];
	[self removeFloatingBanner];
	
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, 10.f)];
	[_collectionLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, 20+_footerView.height)];
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
										 collectionViewLayout:_collectionLayout];
	[_collectionView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
	[_collectionView setDelegate:self];
	[_collectionView setDataSource:self];
	[_collectionView setClipsToBounds:YES];
	[self addSubview:_collectionView];
	
	[_collectionView registerClass:[CPMainTabCollectionCell class] forCellWithReuseIdentifier:@"noData"];
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
	[_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
	
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
	
	[self showFloatingBanner];
	
	if (_datafreeDict && [_datafreeDict count] > 0 && [Modules isSktCustomerWithCurrier])
    {
        NSInteger nlastDate = [[[CPCommonInfo sharedInfo] lastShowDataFreeDate] integerValue];
        NSInteger nToday = [[Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"] integerValue];
        
        if (nlastDate < nToday) {
            [[CPCommonInfo sharedInfo] setLastShowDataFreeDate:[Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
            
            if (homeViewController && [homeViewController respondsToSelector:@selector(showDataFreeView:)])
            {
                NSString *linkUrl = _datafreeDict[@"dispObjLnkUrl"];
                [homeViewController showDataFreeView:linkUrl];
            }
        }
	}
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

- (void)showFloatingBanner
{
	if (!_floatingBannerArr || [_floatingBannerArr count] == 0) return;
	
	NSInteger randNum = rand() % [_floatingBannerArr count];
	NSDictionary *item = _floatingBannerArr[randNum][@"floatingBanner"];
	
	_floatingView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-110, self.frame.size.width, 110)];
	[self addSubview:_floatingView];
	
	NSString *bgColor = item[@"extraText"];
	
	UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, _floatingView.frame.size.width, 100)];
	bgColorView.backgroundColor = UIColorFromRGBA(0x000000, 0.9);
	[_floatingView addSubview:bgColorView];

	if (bgColor && [bgColor length] > 0)
	{
        bgColor = [bgColor lowercaseString];
        
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"rgba(" withString:@""];
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"rgba(" withString:@")"];
        
        NSArray *colorArr = [bgColor componentsSeparatedByString:@","];
        if ([colorArr count] == 4) {
            
            NSInteger colorR = [colorArr[0] integerValue];
            NSInteger colorG = [colorArr[1] integerValue];
            NSInteger colorB = [colorArr[2] integerValue];
            CGFloat colorA = [colorArr[3] floatValue];
            
            [bgColorView setBackgroundColor:RGBA(colorR, colorG, colorB, colorA)];
        }
	}
	
	NSString *imageUrl = item[@"lnkBnnrImgUrl"];
	if (imageUrl && [imageUrl length] > 0) {
		CPThumbnailView *bannerImageView = [[CPThumbnailView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-160, 0, 320, 110)];
		[bannerImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
		[_floatingView addSubview:bannerImageView];
	}
	
	NSString *linkUrl = item[@"dispObjLnkUrl"];
	if (linkUrl && [linkUrl length] > 0) {
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-160, 0, 320, 110)];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = linkUrl;
		[_floatingView addSubview:actionView];
	}
	
	_floatingCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_floatingCloseButton setFrame:CGRectMake(self.frame.size.width-4-28, self.frame.size.height-100-9-28, 28, 28)];
	[_floatingCloseButton setImage:[UIImage imageNamed:@"bt_home_banner_floating_close.png"] forState:UIControlStateNormal];
	[_floatingCloseButton addTarget:self action:@selector(onTouchFloatBannerClose:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_floatingCloseButton];
}

- (void)removeFloatingBanner
{
	if (_floatingView) {
		[_floatingView removeFromSuperview];
		_floatingView = nil;
	}
	
	if (_floatingCloseButton) {
		[_floatingCloseButton removeFromSuperview];
		_floatingCloseButton = nil;
	}
}

- (void)onTouchFloatBannerClose:(id)sender
{
	[self removeFloatingBanner];
}

#pragma mark - UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self bringSubviewToFront:_topScrollButton];
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
		
		for (UIView *subviews in headerView.subviews) {
			[subviews removeFromSuperview];
		}
		
		
		if (_headerDict && [_headerDict count] > 0) {
			CPHomeHeaderView *view = [[CPHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, 0) item:_headerDict];
			[view setDelegate:self];
			[headerView addSubview:view];
			
			[_collectionLayout setHeaderReferenceSize:CGSizeMake(view.frame.size.width, view.frame.size.height)];
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
		
		if (_footerAdView) {
			[_footerAdView removeFromSuperview];
			_footerAdView = nil;
		}
		
		_footerAdView = [[CPHomeAdView alloc] initWithFrame:CGRectMake(0, 20, collectionView.frame.size.width, 48)
													   item:_footerAdDict];
		[footerView addSubview:_footerAdView];
		
		//footerView
		[_footerView setFrame:CGRectMake(0, 68, _footerView.width, _footerView.height)];
		[_footerView setDelegate:self];
		[footerView addSubview:_footerView];
		
		[_collectionLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, 68+CGRectGetHeight(_footerView.frame))];
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
	[_collectionView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - CPCollectionViewCommonCell Delegate
- (void)didTouchButtonWithUrl:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        CPHomeViewController *homeViewController = (CPHomeViewController *)app.homeViewController;
        
        if (homeViewController && [homeViewController respondsToSelector:@selector(openWebViewControllerWithUrl:animated:)]) {
            [homeViewController openWebViewControllerWithUrl:[url trim] animated:YES];
        }
	}
}

- (void)popularKeywordViewOpenYn:(BOOL)isOpen
{
	NSLog(@"popularKeywordViewOpenYn : %@", _collectionData.items);
	NSInteger indexRow = -1;
	
	NSMutableArray *tempArr = [NSMutableArray array];
	for (NSInteger i=0; i<[_collectionData.items count]; i++)
	{
		NSMutableDictionary *dict = _collectionData.items[i];
		
		NSString *groupName = dict[@"groupName"];
		
		if ([@"homePopularKeywordGroup" isEqualToString:groupName]) {
			[dict setValue:(isOpen ? @"Y" : @"N") forKey:@"openYn"];
			[tempArr addObject:dict];
			
			indexRow = i;
		}
		else {
			[tempArr addObject:dict];
		}
	}

	if (indexRow != -1) {
		_collectionData.items = tempArr;
		[_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexRow inSection:0]]];
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

#pragma mark - data 
- (NSArray *)transferDataArray:(NSArray *)array homeDealFixedYn:(NSString *)homeDealFixedYn;
{
	NSMutableArray *tArray = [NSMutableArray array];

	//bannerProduct를 랜덤으로 뿌려주기위해 데이터를 조작한다.
	NSArray *bannerProductListGroup = nil;
	for (NSInteger i=0; i<[array count]; i++) {
		NSString *groupName = array[i][@"groupName"];
		
		if ([@"randomDealBannerProductList" isEqualToString:groupName])
		{
			bannerProductListGroup = array[i][groupName];
		}
	}
	
	if (bannerProductListGroup && [bannerProductListGroup count] > 0) {
		BOOL isFixed = ([homeDealFixedYn isEqualToString:@"Y"]);
		bannerProductListGroup = [self getBannerProductList:bannerProductListGroup isFixed:isFixed];
	}
	
	//talk&style 그룹을 모은다
	NSMutableDictionary *homeTalkAndStyleGroup = [NSMutableDictionary dictionary];
	[homeTalkAndStyleGroup setValue:@"homeTalkAndStyleGroup" forKey:@"groupName"];
	
	//실시간 급상승 그룹을 모은다.
	NSMutableDictionary *homePopularKeywordGroup = [NSMutableDictionary dictionary];
	[homePopularKeywordGroup setValue:@"homePopularKeywordGroup" forKey:@"groupName"];
	[homePopularKeywordGroup setValue:(IS_IPAD ? @"Y" : @"N") forKey:@"openYn"];

	
	NSArray *homeTabletAreaGroup = nil;
	for (NSInteger i=0; i<[array count]; i++) {
		NSString *groupName = array[i][@"groupName"];

		if ([@"homeTabletAreaGroup" isEqualToString:groupName])
		{
			homeTabletAreaGroup = array[i][groupName];
			break;
		}
	}
	
	for (NSInteger i=0; i<[homeTabletAreaGroup count]; i++) {
		NSString *groupName = homeTabletAreaGroup[i][@"groupName"];

		//톡&스타일
		if ([@"textLine" isEqualToString:groupName])
		{
			[homeTalkAndStyleGroup setValue:homeTabletAreaGroup[i][@"textLine"] forKey:@"halfTextLine"];
		}
		else if ([@"homeTalkStyleList" isEqualToString:groupName])
		{
			[homeTalkAndStyleGroup setValue:homeTabletAreaGroup[i][@"homeTalkStyleList"] forKey:@"homeTalkStyleList"];
		}
		else if ([@"homeDirectTabArea" isEqualToString:groupName])
		{
			[homeTalkAndStyleGroup setValue:homeTabletAreaGroup[i][@"homeDirectTabArea"] forKey:@"homeDirectTabArea"];
		}
		//실시간 검색 순위
		else if ([@"popularKeywordArea" isEqualToString:groupName])
		{
			[homePopularKeywordGroup setValue:homeTabletAreaGroup[i][@"popularKeywordArea"] forKey:@"popularKeywordArea"];
		}
		else if ([@"homeDirectBottomArea" isEqualToString:groupName])
		{
			[homePopularKeywordGroup setValue:homeTabletAreaGroup[i][@"homeDirectBottomArea"] forKey:@"homeDirectBottomArea"];
		}
	}
	
	//패드에서 양옆의 아이템 높이를 맞춰야해서 사이즈를 미리가져온다.
	CGSize talkStyleSize = [CPMainTabSizeManager getSizeWithGroupName:@"homeTalkAndStyleGroup" item:homeTalkAndStyleGroup];
	[homePopularKeywordGroup setValue:[NSString stringWithFormat:@"%f", talkStyleSize.height] forKey:@"talkStyleHeight"];
	
	//변경된 데이터를 넣는다.
    NSInteger cornerBannerCount = 0;
	for (NSInteger i=0; i<[array count]; i++) {

		NSString *groupName = array[i][@"groupName"];
		if ([@"randomDealBannerProductList" isEqualToString:groupName]) {
			for (NSInteger i=0; i<[bannerProductListGroup count]; i++) {
				[tArray addObject:bannerProductListGroup[i]];
			}
		}
		else if ([@"homeTabletAreaGroup" isEqualToString:groupName])
		{
			[tArray addObject:homeTalkAndStyleGroup];
			[tArray addObject:homePopularKeywordGroup];
		}
        else if ([@"cornerBanner" isEqualToString:groupName])
        {
            NSMutableDictionary *cornerBannerDict = [NSMutableDictionary dictionary];
            
            [cornerBannerDict setValue:@"cornerBanner" forKey:@"groupName"];
            [cornerBannerDict setValue:[array[i][@"cornerBanner"] mutableCopy] forKey:@"cornerBanner"];
            [cornerBannerDict[@"cornerBanner"] setValue:[NSString stringWithFormat:@"%ld", (long)cornerBannerCount++] forKey:@"index"];

            [tArray addObject:cornerBannerDict];
        }
		else
		{
			[tArray addObject:array[i]];
		}
	}
	
	return tArray;
}

- (NSArray *)getBannerProductList:(NSArray *)bannerGroup isFixed:(BOOL)isFixed
{
	//최대 8개 노출이 되는데 8개보다 적을 경우 모두 보여준다.
	if ([bannerGroup count] <= 8) return bannerGroup;

	NSMutableArray *array = [bannerGroup mutableCopy];
	NSMutableArray *tArray = [NSMutableArray array];
	
	//isFixed가 YES이면 0번째 데이터를 리스트로 보여준다.
	if (isFixed) {
		[tArray addObject:array[0]];
		[array removeObjectAtIndex:0];
	}
	
	NSInteger randNum = 0;
    NSMutableDictionary *tempDict = nil;
	
	randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0301" forKey:@"wiseLogCode"];
	[tArray addObject:tempDict];
	[array removeObjectAtIndex:randNum];
	if ([tArray count] == 8) return tArray;

    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0302" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;

    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0309" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;

    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0310" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;
	
    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0311" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;
	
    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0312" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;
	
    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0313" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;
	
    randNum = rand() % [array count];
    tempDict = [array[randNum] mutableCopy];
    [tempDict setValue:@"MAJ0314" forKey:@"wiseLogCode"];
    [tArray addObject:tempDict];
    [array removeObjectAtIndex:randNum];
    if ([tArray count] == 8) return tArray;
	
	return tArray;
}

#pragma mark - CPHomeHeaderViewDelegate
- (void)resizeHomeHeaderViewFrame:(CGSize)viewSize
{
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(viewSize.width, viewSize.height)];
}

- (void)homeHeaderBillBannerOnTouchButton
{
	CPHomeTotalBillBannerView *view = [[CPHomeTotalBillBannerView alloc] initWithFrame:self.bounds];
	view.delegate = self;
	view.items = _billBannerGroupArr;
	[self addSubview:view];
}

@end
