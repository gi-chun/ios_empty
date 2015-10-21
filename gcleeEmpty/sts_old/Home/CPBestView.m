//
//  CPCurationView.m
//  11st
//
//  Created by saintsd on 2015. 6. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPBestView.h"
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

#define HEADER_HEIGHT    130
#define FOOTER_HEIGHT    88
#define kCategoryLongButton_width   IS_IPAD ? 290 : 119
#define kCategoryShortButton_width  IS_IPAD ? 160 : 72

typedef NS_ENUM(NSUInteger, CPCategoryButtonType){
	CPCategoryButtonTypeHome = 0,           //홈
	CPCategoryButtonTypeFirstDepth,         //대카테고리 첫번째 버튼
	CPCategoryButtonTypeSecondDepth,        //대카테고리 나머지 버튼
	CPCategoryButtonTypeThirdDepth,         //소카테고리 버튼
	CPCategoryButtonTypeFourthDepth
};

typedef NS_ENUM(NSUInteger, CPCategoryImageType){
	CPCategoryImageTypeMainDropdown = 101,  //대 카테고리 dropdown 이미지 태그
	CPCategoryImageTypeMinorDropdown,       //소 카테고리 dropdown 이미지 태그
	CPCategoryImageTypeFirstArrow,          //1depth arrow 이미지 태그
	CPCategoryImageTypeSecondArrow          //2depth arrow 이미지 태그
};

typedef NS_ENUM(NSUInteger, CPGenderButtonType){
	CPGenderButtonTypeAll = 0,                 //전체
	CPGenderButtonTypeMale,                    //남성
	CPGenderButtonTypeFemale                   //여성
};

@interface CPBestView () <	CPErrorViewDelegate,
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
	NSDictionary *_dict;
	
	//JSON API 정보
	NSMutableDictionary *_tabInfo;
	NSMutableDictionary *_categoryInfo;
	NSMutableDictionary *_noData;
	
	NSMutableArray *_categoryItems;
	
	//모바일 베스트, 11번가 베스트 구분자
	BOOL _isMobileBest;
	BOOL _isMenuOpen;
	
	UIView *_categoryView;
	UIView *_categorySecondView;
	UIView *_menuView;
	UIView *_updateTimeView;
	
	NSInteger _selectedCategoryButtonDepth;
	NSString *_lastRequestUrl;
	
	
	//IOS6, IOS7 bug를 위해 임시 저장
	UICollectionReusableView *_saveHeaderView;
	UICollectionReusableView *_saveFooterView;
}

@end

@implementation CPBestView

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
		
		//Init dictionary
		_tabInfo = [NSMutableDictionary dictionary];
		_categoryInfo = [NSMutableDictionary dictionary];
		_noData = [NSMutableDictionary dictionary];
		_categoryItems = [NSMutableArray array];
		
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
		_isMobileBest = [info[@"key"] isEqualToString:@"RANK"] ? YES : NO;
		_dict = [info copy];
		
		//베스트는 1.0초후 통신하도록 한다.
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
	}
	else {
		[self showErrorView];
	}
}

- (void)reloadData
{
    [self performSelectorInBackground:@selector(requestItems:) withObject:@NO];
	[self removeCategoryMenuView];
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

- (void)requestIgnoreCacheItemWithUrl:(NSString *)url
{
    [self requestItemWithUrl:url ignoreCache:YES];
}

- (void)requestItemWithUrl:(NSString *)url ignoreCache:(BOOL)ignoreCache
{
	if (!url && [url length] == 0) return;
	
    _lastRequestUrl = [[NSString alloc] initWithString:url];
    
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
		
		[_tabInfo removeAllObjects];
		[_categoryInfo removeAllObjects];
		[_noData removeAllObjects];
		[_collectionData removeAllObjects];
		
		if (dataArray) {
			[_collectionData setData:dataArray];
			
			NSPredicate *tabPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"subTwoTab"];
			if ([dataArray filteredArrayUsingPredicate:tabPredicate].count > 0) {
				_tabInfo = [[dataArray filteredArrayUsingPredicate:tabPredicate][0] mutableCopy];
			}
			
			NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"lineCategory"];
			if ([dataArray filteredArrayUsingPredicate:categoryPredicate].count > 0) {
				_categoryInfo = [[dataArray filteredArrayUsingPredicate:categoryPredicate][0] mutableCopy];
			}
			
			NSPredicate *noDataPredicate = [NSPredicate predicateWithFormat:@"(groupName == %@)", @"noData"];
			if ([dataArray filteredArrayUsingPredicate:noDataPredicate].count > 0) {
				_noData = [[dataArray filteredArrayUsingPredicate:noDataPredicate][0] mutableCopy];
			}
			
			int keyCounter = 1;
			[_categoryItems removeAllObjects];
			
			while (YES) {
				NSString *key = [NSString stringWithFormat:@"categoryItem%d", keyCounter];
				
				if ([_categoryInfo objectForKey:key]) {
					_categoryItems[keyCounter-1] = _categoryInfo[key];
					keyCounter++;
				}
				else {
					break;
				}
			}
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
	
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT + (_categoryItems.count >=4 ? 45 : 0))];
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
	
	//menuView
	_menuView = [[UIView alloc] initWithFrame:CGRectZero];
	[_menuView setBackgroundColor:[UIColor clearColor]];
	[_collectionView addSubview:_menuView];

	_isMenuOpen = NO;
	
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
	if (_categorySecondView) {
		for (UIView *subView in [_categorySecondView subviews]) {
			[subView removeFromSuperview];
		}

		[_categorySecondView removeFromSuperview];
		_categorySecondView = nil;
	}
	
	if (_menuView) {
		for (UIView *subView in [_menuView subviews]) {
			[subView removeFromSuperview];
		}
		
		[_menuView removeFromSuperview];
		_menuView = nil;
	}
	
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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//	if (section == 0) {
//		return CGSizeMake(collectionView.frame.size.width, HEADER_HEIGHT+(_categoryItems.count >=4 ? 45 : 0));
//	}
//	
//	return CGSizeMake(0, 0);
//}
//
//-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//	if (section == 0) {
//		return CGSizeMake(kScreenBoundsWidth, 20+_footerView.height);
//	}
//	
//	return CGSizeMake(0, 0);
//}

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
			_saveHeaderView = headerView;
		}
		@catch (NSException *exception) {
			headerView = _saveHeaderView;
		}
		@finally {}
		
		UIView *headerRadiusView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenBoundsWidth-20, 76)];
		[headerView addSubview:headerRadiusView];
		
		if (_tabInfo && _tabInfo.count > 0) {
			NSArray *tabItems = _tabInfo[@"items"];
			NSDictionary *leftTabItem = tabItems[0];
			NSDictionary *rightTabItem = tabItems[1];
			
			UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[leftButton setTag:CPTabButtonTypeMobileBest];
			[leftButton setFrame:CGRectMake(0, 0, (kScreenBoundsWidth-20)/2, 36)];
			[leftButton setBackgroundColor:_isMobileBest?UIColorFromRGB(0x979fe4):UIColorFromRGB(0xf4f4f4)];
			[leftButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[leftButton setTitle:leftTabItem[@"title"] forState:UIControlStateNormal];
			[leftButton setTitleColor:_isMobileBest?UIColorFromRGB(0xffffff):UIColorFromRGB(0x888888) forState:UIControlStateNormal];
			[leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
			[leftButton addTarget:self action:@selector(touchTabButton:) forControlEvents:UIControlEventTouchUpInside];
			[headerRadiusView addSubview:leftButton];
			
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[rightButton setTag:CPTabButtonTypeElevenstBest];
			[rightButton setFrame:CGRectMake(CGRectGetMaxX(leftButton.frame), 0, (kScreenBoundsWidth-20)/2, 36)];
			[rightButton setBackgroundColor:_isMobileBest?UIColorFromRGB(0xf4f4f4):UIColorFromRGB(0x979fe4)];
			[rightButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[rightButton setTitle:rightTabItem[@"title"] forState:UIControlStateNormal];
			[rightButton setTitleColor:_isMobileBest?UIColorFromRGB(0x888888):UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
			[rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
			[rightButton addTarget:self action:@selector(touchTabButton:) forControlEvents:UIControlEventTouchUpInside];
			[headerRadiusView addSubview:rightButton];
		}
		
		if (_categoryInfo && _categoryInfo.count > 0) {
			_categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 36, kScreenBoundsWidth-20, 40)];
			[_categoryView setBackgroundColor:UIColorFromRGB(0xffffff)];
			[headerRadiusView addSubview:_categoryView];
			
			//업데이트 시간
			NSString *updateTime = _categoryInfo[@"updateTime"];
			
			if (!_isMenuOpen) {
				//헤더길이 조절
				[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT + (_categoryItems.count >=4 ? 45 : 0))];
			}
			
			UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _categoryView.frame.size.height-1, _categoryView.frame.size.width, 1)];
			bottomLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
			[_categoryView addSubview:bottomLine];
			
			UIButton *crownButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[crownButton setTag:CPCategoryButtonTypeHome];
			[crownButton setFrame:CGRectMake(0, 0, 47, 39)];
			[crownButton setImage:[UIImage imageNamed:@"best_icon_top_nor.png"] forState:UIControlStateNormal];
			[crownButton setImage:[UIImage imageNamed:@"best_icon_top_pre.png"] forState:UIControlStateSelected];
			[crownButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[crownButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
			[_categoryView addSubview:crownButton];
			
			UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
			[imgView setFrame:CGRectMake(CGRectGetMaxX(crownButton.frame)-15, 0, 15, CGRectGetHeight(crownButton.frame))];
			[crownButton addSubview:imgView];
			
			UIButton *categoryFirstButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[categoryFirstButton setTag:CPCategoryButtonTypeFirstDepth];
			[categoryFirstButton addTarget:self action:@selector(makeCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
			[categoryFirstButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[categoryFirstButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
			[categoryFirstButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 8)];
			[categoryFirstButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
			[categoryFirstButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[_categoryView addSubview:categoryFirstButton];
			
			UIButton *categorySecondButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[categorySecondButton setTag:CPCategoryButtonTypeSecondDepth];
			[categorySecondButton addTarget:self action:@selector(makeCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
			[categorySecondButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[categorySecondButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
			[categorySecondButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 8)];
			[categorySecondButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
			[categorySecondButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[_categoryView addSubview:categorySecondButton];
			
			UIButton *categoryThirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[categoryThirdButton setTag:CPCategoryButtonTypeThirdDepth];
			[categoryThirdButton addTarget:self action:@selector(makeCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
			[categoryThirdButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[categoryThirdButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
			[categoryThirdButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 8)];
			[categoryThirdButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
			[categoryThirdButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
			[_categoryView addSubview:categoryThirdButton];
			
			[categoryFirstButton setHidden:YES];
			[categorySecondButton setHidden:YES];
			[categoryThirdButton setHidden:YES];
			
			UIImageView *dropdownView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
			[dropdownView setTag:CPCategoryImageTypeMainDropdown];
			
			//대카테고리
			if (_categoryItems.count >= 1) {
				NSArray *categoryArray = _categoryItems[0];
				for (NSDictionary *dic in categoryArray) {
					
					if ([dic objectForKey:@"selected"] != nil && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
						[categoryFirstButton setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
						[categoryFirstButton setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
						[categoryFirstButton setHidden:NO];
						
						if (_categoryItems.count == 1) {
							[categoryFirstButton setFrame:CGRectMake(CGRectGetMaxX(crownButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(crownButton.frame), 39)];
							
							[dropdownView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-27, 7, 26, 25)];
							[categoryFirstButton addSubview:dropdownView];
						}
						else {
							[categoryFirstButton setFrame:CGRectMake(CGRectGetMaxX(crownButton.frame), 0, kCategoryShortButton_width, 39)];
							
							UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
							[imgView setTag:CPCategoryImageTypeFirstArrow];
							[imgView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-15, 0, 15, CGRectGetHeight(categoryFirstButton.frame))];
							[categoryFirstButton addSubview:imgView];
						}
						
						break;
					}
				}
			}
			
			//2depth 카테고리
			if (_categoryItems.count >= 2) {
				NSArray *categoryArray = _categoryItems[1];
				for (NSDictionary *dic in categoryArray) {
					
					if ([dic objectForKey:@"selected"] != nil && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
						[categorySecondButton setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
						[categorySecondButton setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
						[categorySecondButton setHidden:NO];
						
						if (_categoryItems.count == 2) {
							[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(crownButton.frame) - CGRectGetWidth(categoryFirstButton.frame), 39)];
							
							[dropdownView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-27, 7, 26, 25)];
							[categorySecondButton addSubview:dropdownView];
						}
						else {
							[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, kCategoryShortButton_width, 39)];
							
							UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
							[imgView setTag:CPCategoryImageTypeSecondArrow];
							[imgView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-15, 0, 15, CGRectGetHeight(categorySecondButton.frame))];
							[categorySecondButton addSubview:imgView];
						}
						
						break;
					}
				}
			}
			
			//3depth 카테고리
			if (_categoryItems.count >= 3) {
				NSArray *categoryArray = _categoryItems[2];
				for (NSDictionary *dic in categoryArray) {
					
					if ([dic objectForKey:@"selected"] != nil && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
						[categoryThirdButton setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
						[categoryThirdButton setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
						[categoryThirdButton setHidden:NO];
						
						[categoryThirdButton setFrame:CGRectMake(CGRectGetMaxX(categorySecondButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(crownButton.frame) - CGRectGetWidth(categoryFirstButton.frame) - CGRectGetWidth(categorySecondButton.frame), 39)];
						
						[dropdownView setFrame:CGRectMake(CGRectGetWidth(categoryThirdButton.frame)-27, 7, 26, 25)];
						[categoryThirdButton addSubview:dropdownView];
						
						break;
					}
				}
			}
			
			//소카테고리
			if (_categoryItems.count >= 4) {
				NSArray *categoryArray = _categoryItems[3];
				for (NSDictionary *dic in categoryArray) {
					
					_categorySecondView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_categoryView.frame)+20, kScreenBoundsWidth-20, 35)];
					[_categorySecondView setBackgroundColor:UIColorFromRGB(0xffffff)];
					[headerView addSubview:_categorySecondView];
					
					UIButton *categoryFourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
					[categoryFourthButton setTag:CPCategoryButtonTypeFourthDepth];
					[categoryFourthButton addTarget:self action:@selector(makeCategoryMenu:) forControlEvents:UIControlEventTouchUpInside];
					[categoryFourthButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
					[categoryFourthButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
					[categoryFourthButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 8)];
					[categoryFourthButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
					[categoryFourthButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
					[_categorySecondView addSubview:categoryFourthButton];
					
					if ([dic objectForKey:@"selected"] != nil && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
						[categoryFourthButton setTitle:[dic objectForKey:@"title"] forState:UIControlStateNormal];
						[categoryFourthButton setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
						[categoryFourthButton setFrame:CGRectMake(0, 0, CGRectGetWidth(_categorySecondView.frame), CGRectGetHeight(_categorySecondView.frame))];
						
						UIImageView *dropdownView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
						[dropdownView setUserInteractionEnabled:YES];
						[dropdownView setTag:CPCategoryImageTypeMinorDropdown];
						
						[dropdownView setFrame:CGRectMake(CGRectGetWidth(categoryFourthButton.frame)-27, 5, 26, 25)];
						[categoryFourthButton addSubview:dropdownView];
						
						break;
					}
				}
			}
			
			for (UIView *subView in [_updateTimeView subviews]) {
				[subView removeFromSuperview];
			}
			
			_updateTimeView = [[UIView alloc] initWithFrame:CGRectZero];
			
			UILabel *updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 26)];
			[updateTimeLabel setBackgroundColor:[UIColor clearColor]];
			[updateTimeLabel setTextColor:UIColorFromRGB(0x8c6239)];
			[updateTimeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
			[updateTimeLabel setShadowColor:[UIColor whiteColor]];
			[updateTimeLabel setShadowOffset:CGSizeMake(0,2)];
			[updateTimeLabel setText:updateTime];
			[updateTimeLabel setTextAlignment:NSTextAlignmentCenter];
			[_updateTimeView addSubview:updateTimeLabel];
		}
		
		
		//성별
		NSArray *genderInfo = _categoryInfo[@"genderItems"];
		BOOL isExistSelected = NO;
		
		for (NSDictionary *dic in genderInfo) {
			if ([[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
				isExistSelected = YES;
				break;
			}
		}
		
		if (genderInfo && genderInfo.count > 0 && isExistSelected) {
			
			for (NSDictionary *dic in genderInfo) {
				
				int x = 0;
				int tagValue = CPGenderButtonTypeAll;
				
				if ([[dic objectForKey:@"searchType"] isEqualToString:@"ALL"]) {
					x = kScreenBoundsWidth-200;
				}
				else if ([[dic objectForKey:@"searchType"] isEqualToString:@"M"]) {
					x = kScreenBoundsWidth-140;
					tagValue = CPGenderButtonTypeMale;
				}
				else if ([[dic objectForKey:@"searchType"] isEqualToString:@"F"]) {
					x = kScreenBoundsWidth-80;
					tagValue = CPGenderButtonTypeFemale;
				}
				
				UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
				[button setTag:tagValue];
				[button setFrame:CGRectMake(x, 0, 60, 26)];
				[button setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
				[button setTitle:[dic objectForKey:@"text"] forState:UIControlStateNormal];
				[button setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
				[button addTarget:self action:@selector(reloadGenderData:) forControlEvents:UIControlEventTouchUpInside];
				[button.titleLabel setFont:[UIFont systemFontOfSize:14]];
				[button.layer setCornerRadius:4];
				[_updateTimeView addSubview:button];
				
				if ([[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
					[button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
					[button setBackgroundColor:UIColorFromRGB(0xb6b6cb)];
					[button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
					
					if ([[dic objectForKey:@"searchType"] isEqualToString:@"ALL"]) {
						UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-81, 4, 1, 18)];
						[lineView setBackgroundColor:UIColorFromRGB(0xbfbfc2)];
						[_updateTimeView addSubview:lineView];
					}
					else if ([[dic objectForKey:@"searchType"] isEqualToString:@"F"]) {
						UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth-141, 4, 1, 18)];
						[lineView setBackgroundColor:UIColorFromRGB(0xbfbfc2)];
						[_updateTimeView addSubview:lineView];
					}
				}
			}
		}
		
		if (_isMenuOpen) {
			[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 26)];
		}
		else {
			[_updateTimeView setFrame:CGRectMake(10, (_categoryItems.count >= 4 ? CGRectGetMaxY(_categorySecondView.frame)+10 : CGRectGetMaxY(_categoryView.frame)+20), kScreenBoundsWidth-20, 26)];
		}
		
		[_collectionLayout setHeaderReferenceSize:CGSizeMake(_collectionView.frame.size.width, CGRectGetMaxY(_updateTimeView.frame)+10)];
		[headerView addSubview:_updateTimeView];
		
		reusableview = headerView;
	}
	else if ([kind isEqual:UICollectionElementKindSectionFooter]) {
		
		UICollectionReusableView *footerView;
		
		@try {
			footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
			_saveFooterView = footerView;
		}
		@catch (NSException *exception) {
			footerView = _saveFooterView;
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

#pragma mark - Selectors
- (void)touchCategoryBest:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSString *url = button.titleLabel.text;
	
	if (url && [[url trim] length] > 0) {
		if (-1 != [url indexOf:@"app://"]) {
			NSRange range = [url rangeOfString:@"http"];
			url = [url substringFromIndex:range.location];
			
			if (!url || url.length == 0) {
                [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
                return;
			}
		}
		
		[self performSelectorInBackground:@selector(requestIgnoreCacheItemWithUrl:) withObject:url];
		[self removeCategoryMenuView];
	}
	
	//AccessLog - 메타카테고리
	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0200"];
}

- (void)touchCategoryBestWithUrl:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		if (-1 != [url indexOf:@"app://"]) {
			NSRange range = [url rangeOfString:@"http"];
			url = [url substringFromIndex:range.location];
			
			if (!url || url.length == 0) {
                [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
				return;
			}
		}
		
		[self performSelectorInBackground:@selector(requestIgnoreCacheItemWithUrl:) withObject:url];
		[self removeCategoryMenuView];
	}
	
	//AccessLog - 메타카테고리
	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0200"];
}

- (void)touchTabButton:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	if ((_isMobileBest && button.tag == CPTabButtonTypeMobileBest) || (!_isMobileBest && button.tag == CPTabButtonTypeElevenstBest)) {
		[self reloadData];
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(didTouchTabButton:)]) {
		[self.delegate didTouchTabButton:sender];
	}
}

- (void)gotoClickedMenu:(id)sender
{
	[self removeCategoryMenuView];
	
	UIButton *button = (UIButton *)sender;
	
	NSArray *categoryItem = _categoryInfo[[NSString stringWithFormat:@"categoryItem%ld", (long)_selectedCategoryButtonDepth]];
	NSString *linkUrl = categoryItem[button.tag][@"linkUrl"];
	
	if (-1 != [linkUrl indexOf:@"app://"]) {
		NSRange range = [linkUrl rangeOfString:@"http"];
		linkUrl = [linkUrl substringFromIndex:range.location];
		
		if (!linkUrl || linkUrl.length == 0) {
            [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
			return;
		}
	}

	[self performSelectorInBackground:@selector(requestIgnoreCacheItemWithUrl:) withObject:linkUrl];
	
	//AccessLog - 메타카테고리
	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0200"];
}

//성별 터치이벤트
- (void)reloadGenderData:(id)sender
{
	[self removeCategoryMenuView];
	
	UIButton *button = (UIButton *)sender;
	NSArray *items = _categoryInfo[@"genderItems"];
	NSString *linkUrl = items[CPGenderButtonTypeAll][@"linkUrl"];
	
	if (button.tag == CPGenderButtonTypeAll) {
		//AccessLog - 성별 전체
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0300"];
	}
	else if (button.tag == CPGenderButtonTypeMale) {
		linkUrl = items[CPGenderButtonTypeMale][@"linkUrl"];
		
		//AccessLog - 성별 남성
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0301"];
	}
	else if (button.tag == CPGenderButtonTypeFemale) {
		linkUrl = items[CPGenderButtonTypeFemale][@"linkUrl"];
		
		//AccessLog - 성별 여성
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0302"];
	}
	
	if (-1 != [linkUrl indexOf:@"app://"]) {
		NSRange range = [linkUrl rangeOfString:@"http"];
		linkUrl = [linkUrl substringFromIndex:range.location];
		
		if (!linkUrl || linkUrl.length == 0) {
            [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
			return;
		}
	}
	
	[self performSelectorInBackground:@selector(requestIgnoreCacheItemWithUrl:) withObject:linkUrl];
}

//Dropdown이미지 로테이션
- (void)rotateDropdownImage:(id)sender degrees:(NSInteger)degrees
{
	//애니메이션
	UIImageView *dropdownView;
	
	for (UIImageView *subview in [sender subviews]) {
		if (subview.tag == CPCategoryImageTypeMainDropdown || subview.tag == CPCategoryImageTypeMinorDropdown) {
			dropdownView = (UIImageView *)subview;
			break;
		}
	}
	
	[self rotateImage:dropdownView duration:0.3 curve:UIViewAnimationCurveEaseIn degrees:degrees];
}

- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
			  curve:(int)curve degrees:(CGFloat)degrees
{
	// Setup the animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationCurve:curve];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// The transform matrix
	CGAffineTransform transform = CGAffineTransformMakeRotation(degrees / 180.0 * M_PI);
	image.transform = transform;
	
	// Commit the changes
	[UIView commitAnimations];
}

//카테고리 아래 메뉴 뷰 구성
- (void)makeCategoryMenu:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	//닫기
	if (_isMenuOpen) {
		
		_isMenuOpen = NO;
		[button setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
		[self rotateDropdownImage:button degrees:360];
		[self removeCategoryMenuView];
		return;
	}
	//열기
	else {
		
		_isMenuOpen = YES;
		for (UIButton *subView in [_categoryView subviews]) {
			if ([subView isKindOfClass:[UIButton class]]) {
				[subView setTitleColor:UIColorFromRGB(0x444444) forState:UIControlStateNormal];
			}
		}
		[button setTitleColor:UIColorFromRGB(0x5d5fd6) forState:UIControlStateNormal];
		
		//카테고리 depth 구분자
		_selectedCategoryButtonDepth = button.tag;
		
		if (2 <= _categoryItems.count) {
			
			UIButton *homeButton;
			UIButton *categoryFirstButton;
			UIButton *categorySecondButton;
			UIButton *categoryThirdButton;
			UIButton *categoryFourthButton;
			UIImageView *dropdownMainView;
			UIImageView *dropdownMinorView;
			UIImageView *arrowFirstView;
			UIImageView *arrowSecondView;
			
			for (UIButton *subview in [_categoryView subviews]) {
				if (subview.tag == CPCategoryButtonTypeHome) {
					homeButton = (UIButton *)subview;
				}
				
				if (subview.tag == CPCategoryButtonTypeFirstDepth) {
					categoryFirstButton = (UIButton *)subview;
					
					for (UIImageView *subview in [categoryFirstButton subviews]) {
						if (subview.tag == CPCategoryImageTypeMainDropdown) {
							dropdownMainView = (UIImageView *)subview;
						}
						else if (subview.tag == CPCategoryImageTypeFirstArrow) {
							arrowFirstView = (UIImageView *)subview;
						}
					}
				}
				
				if (subview.tag == CPCategoryButtonTypeSecondDepth) {
					categorySecondButton = (UIButton *)subview;
					
					for (UIImageView *subview in [categorySecondButton subviews]) {
						if (subview.tag == CPCategoryImageTypeMainDropdown) {
							dropdownMainView = (UIImageView *)subview;
						}
						else if (subview.tag == CPCategoryImageTypeSecondArrow) {
							arrowSecondView = (UIImageView *)subview;
						}
					}
				}
				
				if (subview.tag == CPCategoryButtonTypeThirdDepth) {
					categoryThirdButton = (UIButton *)subview;
					
					for (UIImageView *subview in [categoryThirdButton subviews]) {
						if (subview.tag == CPCategoryImageTypeMainDropdown) {
							dropdownMainView = (UIImageView *)subview;
						}
					}
				}
				
				if (subview.tag == CPCategoryButtonTypeFourthDepth) {
					categoryFourthButton = (UIButton *)subview;
					
					for (UIImageView *subview in [categoryFourthButton subviews]) {
						if (subview.tag == CPCategoryImageTypeMinorDropdown) {
							dropdownMinorView = (UIImageView *)subview;
						}
					}
				}
			}
			
			if (button.tag == CPCategoryButtonTypeFirstDepth) {
				
				[dropdownMainView removeFromSuperview];
				[arrowFirstView removeFromSuperview];
				[arrowSecondView removeFromSuperview];
				
				[categoryFirstButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 39)];
				[categoryFirstButton setFrame:CGRectMake(CGRectGetMaxX(homeButton.frame), 0, kCategoryLongButton_width, 39)];
				
				arrowFirstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
				[arrowFirstView setTag:CPCategoryImageTypeFirstArrow];
				[arrowFirstView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-15, 0, 15, CGRectGetHeight(categoryFirstButton.frame))];
				[categoryFirstButton addSubview:arrowFirstView];
				
				
				dropdownMainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
				[dropdownMainView setTag:CPCategoryImageTypeMainDropdown];
				[dropdownMainView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-42, 7, 26, 25)];
				[categoryFirstButton addSubview:dropdownMainView];
				
				if (_categoryItems.count == 2) {
					
					[categorySecondButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
					[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(homeButton.frame) - CGRectGetWidth(categoryFirstButton.frame), 39)];
				}
				else if (_categoryItems.count >= 3) {
					
					[categorySecondButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
					[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, kCategoryShortButton_width, 39)];
					[categoryThirdButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
					[categoryThirdButton setFrame:CGRectMake(CGRectGetMaxX(categorySecondButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(homeButton.frame) - CGRectGetWidth(categoryFirstButton.frame) - CGRectGetWidth(categorySecondButton.frame), 39)];
					
					arrowSecondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
					[arrowSecondView setTag:CPCategoryImageTypeSecondArrow];
					[arrowSecondView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-15, 0, 15, CGRectGetHeight(categorySecondButton.frame))];
					[categorySecondButton addSubview:arrowSecondView];
				}
			}
			else if (button.tag == CPCategoryButtonTypeSecondDepth) {
				
				[dropdownMainView removeFromSuperview];
				[arrowFirstView removeFromSuperview];
				[arrowSecondView removeFromSuperview];
				
				[categoryFirstButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
				[categoryFirstButton setFrame:CGRectMake(CGRectGetMaxX(homeButton.frame), 0, kCategoryShortButton_width, 39)];
				
				arrowFirstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
				[arrowFirstView setTag:CPCategoryImageTypeFirstArrow];
				[arrowFirstView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-15, 0, 15, CGRectGetHeight(categoryFirstButton.frame))];
				[categoryFirstButton addSubview:arrowFirstView];
				
				if (_categoryItems.count == 2) {
					
					[categorySecondButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
					[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(homeButton.frame) - CGRectGetWidth(categoryFirstButton.frame), 39)];
					
					dropdownMainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
					[dropdownMainView setTag:CPCategoryImageTypeMainDropdown];
					[dropdownMainView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-27, 7, 26, 25)];
					[categorySecondButton addSubview:dropdownMainView];
				}
				else if (_categoryItems.count >= 3) {
					
					[categorySecondButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
					[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, kCategoryLongButton_width, 39)];
					[categoryThirdButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
					[categoryThirdButton setFrame:CGRectMake(CGRectGetMaxX(categorySecondButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(homeButton.frame) - CGRectGetWidth(categoryFirstButton.frame) - CGRectGetWidth(categorySecondButton.frame), 39)];
					
					dropdownMainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
					[dropdownMainView setTag:CPCategoryImageTypeMainDropdown];
					[dropdownMainView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-42, 7, 26, 25)];
					[categorySecondButton addSubview:dropdownMainView];
					
					arrowSecondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
					[arrowSecondView setTag:CPCategoryImageTypeSecondArrow];
					[arrowSecondView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-15, 0, 15, CGRectGetHeight(categorySecondButton.frame))];
					[categorySecondButton addSubview:arrowSecondView];
				}
			}
			else if (button.tag == CPCategoryButtonTypeThirdDepth) {
				
				[dropdownMainView removeFromSuperview];
				[arrowFirstView removeFromSuperview];
				[arrowSecondView removeFromSuperview];
				
				[categoryFirstButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
				[categoryFirstButton setFrame:CGRectMake(CGRectGetMaxX(homeButton.frame), 0, kCategoryShortButton_width, 39)];
				
				arrowFirstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
				[arrowFirstView setTag:CPCategoryImageTypeFirstArrow];
				[arrowFirstView setFrame:CGRectMake(CGRectGetWidth(categoryFirstButton.frame)-15, 0, 15, CGRectGetHeight(categoryFirstButton.frame))];
				[categoryFirstButton addSubview:arrowFirstView];
				
				[categorySecondButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
				[categorySecondButton setFrame:CGRectMake(CGRectGetMaxX(categoryFirstButton.frame), 0, kCategoryShortButton_width, 39)];
				
				arrowSecondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_arrow.png"]];
				[arrowSecondView setTag:CPCategoryImageTypeSecondArrow];
				[arrowSecondView setFrame:CGRectMake(CGRectGetWidth(categorySecondButton.frame)-15, 0, 15, CGRectGetHeight(categorySecondButton.frame))];
				[categorySecondButton addSubview:arrowSecondView];
				
				
				[categoryThirdButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
				[categoryThirdButton setFrame:CGRectMake(CGRectGetMaxX(categorySecondButton.frame), 0, CGRectGetWidth(_categoryView.frame) - CGRectGetWidth(homeButton.frame) - CGRectGetWidth(categoryFirstButton.frame) - CGRectGetWidth(categorySecondButton.frame), 39)];
				
				dropdownMainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"best_depth_dropdown.png"]];
				[dropdownMainView setTag:CPCategoryImageTypeMainDropdown];
				[dropdownMainView setFrame:CGRectMake(CGRectGetWidth(categoryThirdButton.frame)-27, 7, 26, 25)];
				[categoryThirdButton addSubview:dropdownMainView];
			}
		}
		
		//애니메이션
		[self rotateDropdownImage:button degrees:180];
	}
	
	for (UIView *subView in [_menuView subviews]) {
		[subView removeFromSuperview];
	}
	
	_menuView.backgroundColor = UIColorFromRGB(0xffffff);
	
	//대카테고리 메뉴
	if (button.tag == CPCategoryButtonTypeFirstDepth) {
		
		NSArray *categoryFirstItem = _categoryItems[0];
		
		for (NSDictionary *dic in categoryFirstItem) {
			
			int x = ((int)[categoryFirstItem indexOfObject:dic] % 3) * (kScreenBoundsWidth-20)/3;
			int y = ((int)[categoryFirstItem indexOfObject:dic] / 3) * 39;
			
			UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[menuButton setTag:[categoryFirstItem indexOfObject:dic]];
			[menuButton setFrame:CGRectMake(x, y, (kScreenBoundsWidth-20)/3, 39)];
			[menuButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[menuButton addTarget:self action:@selector(gotoClickedMenu:) forControlEvents:UIControlEventTouchUpInside];
			[menuButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
			[_menuView addSubview:menuButton];
			
			NSString *imageName = [NSString stringWithFormat:@"best_icon_top_%02lu_nor", (unsigned long)[categoryFirstItem indexOfObject:dic]];
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
			[imageView setImage:[UIImage imageNamed:imageName]];
			[menuButton addSubview:imageView];
			
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+2, 0, 68, CGRectGetHeight(menuButton.frame))];
			[titleLabel setText:[dic objectForKey:@"title"]];
			[titleLabel setTextColor:UIColorFromRGB(0x444444)];
			[titleLabel setFont:[UIFont systemFontOfSize:14]];
			[titleLabel setBackgroundColor:[UIColor clearColor]];
			[menuButton addSubview:titleLabel];
			
			if ([dic objectForKey:@"selected"] && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
				[titleLabel setTextColor:UIColorFromRGB(0x5d5fd6)];
				[imageView setImage:[UIImage imageNamed:[imageName stringByReplacingOccurrencesOfString:@"nor" withString:@"pre"]]];
			}
		}
		
		if (_categorySecondView) {
			[_menuView setFrame:CGRectMake(10, 91, kScreenBoundsWidth-20, ((categoryFirstItem.count-1)/3+1)*39)];
			[_categorySecondView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 35)];
			[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_categorySecondView.frame)+10, kScreenBoundsWidth-20, 26)];
			[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, CGRectGetMaxY(_updateTimeView.frame)+10)];
		}
		else {
			[_menuView setFrame:CGRectMake(10, 91, kScreenBoundsWidth-20, ((categoryFirstItem.count-1)/3+1)*39)];
			[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 26)];
			[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, CGRectGetMaxY(_updateTimeView.frame)+10)];
		}
	}
	//소카테고리 메뉴
	else if (button.tag == CPCategoryButtonTypeSecondDepth || button.tag == CPCategoryButtonTypeThirdDepth || button.tag == CPCategoryButtonTypeFourthDepth){
		
		NSArray *categoryItem = _categoryItems[button.tag-1];
		
		for (NSDictionary *dic in categoryItem) {
			
			int x = ((int)[categoryItem indexOfObject:dic] % 2) * (kScreenBoundsWidth-20)/2;
			int y = ((int)[categoryItem indexOfObject:dic] / 2) * 39;
			
			UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[menuButton setTag:[categoryItem indexOfObject:dic]];
			[menuButton setFrame:CGRectMake(x, y, (kScreenBoundsWidth-20)/2, 39)];
			[menuButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
			[menuButton addTarget:self action:@selector(gotoClickedMenu:) forControlEvents:UIControlEventTouchUpInside];
			[menuButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
			[_menuView addSubview:menuButton];
			
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, CGRectGetWidth(menuButton.frame)-12, CGRectGetHeight(menuButton.frame))];
			[titleLabel setText:[dic objectForKey:@"title"]];
			[titleLabel setTextColor:UIColorFromRGB(0x444444)];
			[titleLabel setFont:[UIFont systemFontOfSize:14]];
			[titleLabel setBackgroundColor:[UIColor clearColor]];
			[menuButton addSubview:titleLabel];
			
			if ([dic objectForKey:@"selected"] && [[dic objectForKey:@"selected"] isEqualToString:@"Y"]) {
				[titleLabel setTextColor:UIColorFromRGB(0x5d5fd6)];
			}
		}
		
		if (button.tag == CPCategoryButtonTypeFourthDepth) {
			[_menuView setFrame:CGRectMake(10, 91+45, kScreenBoundsWidth-20, ((categoryItem.count-1)/2+1)*39)];
			[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 26)];
			[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, CGRectGetMaxY(_updateTimeView.frame)+10)];
		}
		else {
			if (_categorySecondView) {
				[_menuView setFrame:CGRectMake(10, 91, kScreenBoundsWidth-20, ((categoryItem.count-1)/2+1)*39)];
				[_categorySecondView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 35)];
				[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_categorySecondView.frame)+10, kScreenBoundsWidth-20, 26)];
				[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, CGRectGetMaxY(_updateTimeView.frame)+10)];
			}
			else {
				[_menuView setFrame:CGRectMake(10, 91, kScreenBoundsWidth-20, ((categoryItem.count-1)/2+1)*39)];
				[_updateTimeView setFrame:CGRectMake(10, CGRectGetMaxY(_menuView.frame)+10, kScreenBoundsWidth-20, 26)];
				[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, CGRectGetMaxY(_updateTimeView.frame)+10)];
			}
		}
	}
    
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, _menuView.frame.size.height-1,
                                                                 _menuView.frame.size.width, 1)];
    underLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
    [_menuView addSubview:underLine];
}

// 카테고리 메뉴 romove
- (void)removeCategoryMenuView
{
	for (UIView *subView in [_menuView subviews]) {
		[subView removeFromSuperview];
	}
	
	[_collectionLayout setHeaderReferenceSize:CGSizeMake(kScreenBoundsWidth, HEADER_HEIGHT + (_categoryItems.count >=4 ? 45 : 0))];
	[_menuView setBackgroundColor:[UIColor clearColor]];
	[_menuView setFrame:CGRectZero];
	if (_categorySecondView) {
		[_categorySecondView setFrame:CGRectMake(10, CGRectGetMaxY(_categoryView.frame)+20, kScreenBoundsWidth-20, 35)];
	}
	[_updateTimeView setFrame:CGRectMake(10, (_categoryItems.count >= 4 ? CGRectGetMaxY(_categorySecondView.frame)+10 : CGRectGetMaxY(_categoryView.frame)+20), kScreenBoundsWidth-20, 26)];
}

#pragma mark - PullToRefreshViewDelegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
	if (_lastRequestUrl && [_lastRequestUrl length] > 0) {
		[self performSelectorInBackground:@selector(requestIgnoreCacheItemWithUrl:) withObject:_lastRequestUrl];
	}
	else {
        [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
	}
	
	[self removeCategoryMenuView];
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
		[self requestIgnoreCacheItemWithUrl:url];
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
