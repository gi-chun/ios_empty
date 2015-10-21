//
//  CPShockingDealView.m
//  11st
//
//  Created by hjcho86 on 2015. 5. 6..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPShockingDealView.h"
#import "CPMainTabCollectionViewFlowlayout.h"
#import "CPLoadingView.h"
#import "AccessLog.h"
#import "PullToRefreshView.h"
#import "HttpRequest.h"
#import "SBJSON.h"
#import "CPRESTClient.h"
#import "CPFooterButtonView.h"
#import "CPFooterView.h"
#import "CPErrorView.h"
#import "CPMainTabCollectionData.h"
#import "CPMainTabCollectionCell.h"
#import "CPCommonInfo.h"
#import "CPSchemeManager.h"
#import "CPHomeViewController.h"

#define HEADER_HEIGHT       64
#define FOOTER_HEIGHT       88

#define MENU_BUTTON_TAG     99

typedef NS_ENUM(NSUInteger, CPMenuImageType){
	CPMenuImageTypeNormal = 0,  //normal
	CPMenuImageTypePressed,     //pressed,highlighted
};

typedef NS_ENUM(NSUInteger, CPMenuImage){
	CPMenuImageRecommend = 0,   //추천
	CPMenuImageFashion,         //패션
	CPMenuImageMart,            //마트
	CPMenuImageLiving,          //리빙
	CPMenuImageDisital,         //디지털
	CPMenuImageLocal            //지역
};

@interface CPShockingDealView() <	HttpRequestDelegate,
									CPFooterViewDelegate,
									CPErrorViewDelegate,
									PullToRefreshViewDelegate,
									CPMainTabCollectionCellDelegate,
									UICollectionViewDataSource,
									UICollectionViewDelegate >
{
	CPMainTabCollectionViewFlowlayout *_collectionLayout;
	UICollectionView *_collectionView;
	CPMainTabCollectionData *_collectionData;
	
	//JSON API 정보
	NSMutableDictionary *tabInfo;
	NSMutableDictionary *specialInfo;
	NSMutableDictionary *noData;
	
	CPLoadingView *_loadingView;
	CPErrorView *_errorView;
	
	//Footer
	CPFooterView *_footerView;
	
	//쇼킹딜텝 정보
	NSDictionary *_dict;
	
	//top이동 버튼
	UIButton *_topScrollButton;
	
	CPErrorView *errorView;
	PullToRefreshView *pull;
	
	//IOS6, IOS7 bug를 위해 임시 저장
	UICollectionReusableView *saveHeaderView;
	UICollectionReusableView *saveFooterView;
	
	UIView *_headerMenuView;
}

@end

@implementation CPShockingDealView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
		[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
		
		//Init dictionary
		tabInfo = [NSMutableDictionary dictionary];
		specialInfo = [NSMutableDictionary dictionary];
		noData = [NSMutableDictionary dictionary];
		
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

- (void)dealloc {
	[self removeContents];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setInfo:(NSDictionary *)info
{
	if (info) {
		_dict = [info copy];
		
		//쇼킹딜은 0.5초후 통신하도록 한다.
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
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
		
		NSArray *dataArray = requestData[@"data"];

		[specialInfo removeAllObjects];
		[noData removeAllObjects];
		[tabInfo removeAllObjects];
		[_collectionData removeAllObjects];
		
		if (dataArray)	[_collectionData setData:dataArray];
		
		NSPredicate *specialInfoPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"specialBestArea"];
		if ([dataArray filteredArrayUsingPredicate:specialInfoPredicate].count > 0) {
			specialInfo = [[dataArray filteredArrayUsingPredicate:specialInfoPredicate][0] mutableCopy];
		}
		
		NSPredicate *tabPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"shockingDealTopTab"];
		if ([dataArray filteredArrayUsingPredicate:tabPredicate].count > 0) {
			tabInfo = [[dataArray filteredArrayUsingPredicate:tabPredicate][0] mutableCopy];
		}
		
		NSPredicate *noDataPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"noData"];
		if ([dataArray filteredArrayUsingPredicate:noDataPredicate].count > 0) {
			noData = [[dataArray filteredArrayUsingPredicate:noDataPredicate][0] mutableCopy];
		}

        //GNB 키워드광고를 셋팅한다.
        if (ignoreCache) {
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
	[self removeErrorView];
	[self removeContents];
	
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT)];
	[_collectionLayout setFooterReferenceSize:CGSizeMake(kScreenBoundsWidth, _footerView.height+20.f)];
	
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return CGSizeMake(collectionView.frame.size.width, HEADER_HEIGHT);
	}
	
	return CGSizeMake(0, 0);
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
	if (section == 0) {
		return CGSizeMake(kScreenBoundsWidth, 20+_footerView.height);
	}
	
	return CGSizeMake(0, 0);
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

		if (_headerMenuView) {
			[_headerMenuView removeFromSuperview];
			_headerMenuView = nil;
		}
		
		_headerMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 54)];
		[headerView addSubview:_headerMenuView];

		//메뉴
		NSArray *tapItems = tabInfo[@"items"];
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
			[button addTarget:self action:@selector(onTouchMenuHighlighted:) forControlEvents:UIControlEventTouchDown];
			[button addTarget:self action:@selector(onTouchMenuDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
			[button addTarget:self action:@selector(onTouchMenuDragOutside:) forControlEvents:UIControlEventTouchCancel];
			[button addTarget:self action:@selector(onTouchMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
			[_headerMenuView addSubview:button];

			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(button.frame)-24)/2, 6, 24, 24)];
			[imageView setTag:button.tag+MENU_BUTTON_TAG];
			[imageView setImage:[self getMenuImage:CPMenuImageTypeNormal index:[tapItems indexOfObject:dic]]];
			[button addSubview:imageView];

			if ([dic objectForKey:@"selected"] && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
				[button setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateNormal];
				[button setBackgroundColor:[UIColor whiteColor]];
				[imageView setImage:[self getMenuImage:CPMenuImageTypePressed index:[tapItems indexOfObject:dic]]];
			}
		}
        
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, _headerMenuView.frame.size.height-1,
                                                                     _headerMenuView.frame.size.width, 1)];
        underLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
        [_headerMenuView addSubview:underLine];
		
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
		
		reusableview = footerView;
	}
	
	return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *groupName = @"noData";
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	if (_collectionData.items.count > 0) {
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
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:url];
		}
	}
}

- (void)didTouchButtonWithRequestUrl:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		[self requestItemWithUrl:url ignoreCache:YES];
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

//메뉴 highlighted
- (void)onTouchMenuHighlighted:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSArray *tapItems = tabInfo[@"items"];
	
	if ([tapItems[button.tag] objectForKey:@"selected"] && [[tapItems[button.tag] objectForKey:@"selected"] isEqualToString:@"Y"]) {
		return;
	}
	
	for (UIImageView *imgView in [button subviews]) {
		if (imgView.tag == button.tag+MENU_BUTTON_TAG) {
			[imgView setImage:[self getMenuImage:CPMenuImageTypePressed index:button.tag]];
			[button setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateNormal];
			break;
		}
	}
}

//메뉴 dragOutside
- (void)onTouchMenuDragOutside:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSArray *tapItems = tabInfo[@"items"];
	
	for (UIImageView *imgView in [button subviews]) {
		if (imgView.tag == button.tag+MENU_BUTTON_TAG) {
			if ([tapItems[button.tag] objectForKey:@"selected"] && [[tapItems[button.tag] objectForKey:@"selected"] isEqualToString:@"Y"]) {
				[imgView setImage:[self getMenuImage:CPMenuImageTypePressed index:button.tag]];
				[button setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateNormal];
			}
			else {
				[imgView setImage:[self getMenuImage:CPMenuImageTypeNormal index:button.tag]];
				[button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
			}
			break;
		}
	}
}

//메뉴 클릭
- (void)onTouchMenuClicked:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSArray *tapItems = tabInfo[@"items"];
	
	for (UIButton *btn in [_headerMenuView subviews]) {
		for (UIImageView *imgView in [btn subviews]) {
			if (imgView.tag == btn.tag+MENU_BUTTON_TAG) {
				
				if ([tapItems[btn.tag] objectForKey:@"selected"] && [[tapItems[btn.tag] objectForKey:@"selected"] isEqualToString:@"Y"]) {
					[imgView setImage:[self getMenuImage:CPMenuImageTypePressed index:btn.tag]];
					[btn setTitleColor:UIColorFromRGB(0xf62e3d) forState:UIControlStateNormal];
				}
				else {
					[imgView setImage:[self getMenuImage:CPMenuImageTypeNormal index:btn.tag]];
					[btn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
				}
			}
		}
	}
	
	NSArray *tabItems = tabInfo[@"items"];
	NSString *linkUrl = tabItems[button.tag][@"linkUrl"];
	
	if (linkUrl && [[linkUrl trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:linkUrl];
		}
	}
}

//메뉴 이미지
//type : 0 = normal, 1 = Highlighted, pressed
- (UIImage *)getMenuImage:(NSInteger)type index:(NSInteger)index
{
	UIImage *image;
	
	switch (index) {
		case CPMenuImageRecommend:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_star_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
		case CPMenuImageFashion:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_fashion_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
		case CPMenuImageMart:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_mart_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
		case CPMenuImageLiving:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_living_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
		case CPMenuImageDisital:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_digital_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
		case CPMenuImageLocal:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_local_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
			
		default:
			image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_s_star_%@.png", (type == CPMenuImageTypeNormal ? @"nor" : @"press")]];
			break;
	}
	
	return image;
}

#pragma mark - CPFooterButtonViewDelegate

- (void)touchFooterItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:url];
		}
	}
}

@end