//
//  CPSearchViewController.m
//  11st
//
//  Created by spearhead on 2014. 9. 19..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSearchViewController.h"
#import "CPProductListViewController.h"
#import "CPSearchTabMenuView.h"
#import "CPSearchView.h"
#import "CPCommonInfo.h"
#import "CPLoadingView.h"
#import "ColorLabel.h"
#import "ALToastView.h"
#import "AccessLog.h"
#import "SBJSON.h"
#import "iCarousel.h"
#import "RegexKitLite.h"
#import "CPRESTClient.h"

@interface CPSearchViewController () <UITextFieldDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UIAlertViewDelegate,
                                    CPSearchTabMenuViewDelegate,
                                    CPSearchViewDelegate,
                                    iCarouselDataSource,
                                    iCarouselDelegate>
{
    CGFloat statusBarHeight;

    UITextField *searchTextField;
    
    CPSearchTabMenuView *searchTabMenuView;
    iCarousel *contentsView;
    
    NSArray *tabTitles;
    NSMutableArray *tabContents;
    
    NSMutableArray *recentKeywordArray;
    NSMutableArray *hotKeywordArray;
    NSMutableArray *riseKeywordArray;
    NSMutableArray *autoCompleteLeftKeywordArray;
    NSMutableArray *autoCompleteRightKeywordArray;
    
    NSString *riseUpdateDate;
    NSString *hotUpdateDate;
    
    UITableView *autoCompleteTableView;
    
    UIButton *swipeLeftButton;
    UIButton *swipeRightButton;
    UIButton *closeButton;
    
    CPLoadingView *loadingView;
    
    BOOL isAutoComplete;
}
@end

@implementation CPSearchViewController

- (id)init
{
    self = [super init];
    if (self) {
        recentKeywordArray = [NSMutableArray array];
        hotKeywordArray = [NSMutableArray array];
        riseKeywordArray = [NSMutableArray array];
        autoCompleteLeftKeywordArray = [NSMutableArray array];
        autoCompleteRightKeywordArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([SYSTEM_VERSION intValue] < 7) {
//        [self setWantsFullScreenLayout:YES];
//    }
    
    // iOS7 Layout
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        statusBarHeight = 20;
    }
    
    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f2)];
    
    [self performSelectorInBackground:@selector(getRiseKeywordList) withObject:nil];
//    [self performSelectorInBackground:@selector(getHotKeywordList:) withObject:nil];
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-40,
                                                                  CGRectGetHeight(self.view.frame)/2-40,
                                                                  80,
                                                                  80)];
    [self startLoadingAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)textFieldBecomeFirstResponder
{
    if ([searchTextField canBecomeFirstResponder]) {
        [searchTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma  mark - Init

- (void)initTabArray
{
    tabTitles= @[@{@"key":@"recent", @"title":@"최근검색어"}, @{@"key":@"rise", @"title":@"급상승"}, @{@"key":@"hot", @"title":@"인기"}];
    
    NSInteger riseMenuCount = ceilf([[NSNumber numberWithUnsignedInteger:riseKeywordArray.count] floatValue] / 10);
    
    tabContents = [NSMutableArray array];
    [tabContents addObject:@{@"key":@"recent", @"title":@"최근 검색어"}];
    
    if (riseMenuCount == 0) {
        [tabContents addObject:@{@"key":@"rise", @"title":@"급상승 검색어", @"page":@(0)}];
    }
    else {
        for (int i = 0; i < riseMenuCount; i++) {
            [tabContents addObject:@{@"key":@"rise", @"title":@"급상승 검색어", @"page":@(i)}];
        }
    }
    
    [tabContents addObject:@{@"key":@"hot", @"title":@"인기 검색어"}];
    
    recentKeywordArray = [[CPCommonInfo sharedInfo] recentSearchItems];
}

- (void)loadContentsView
{
    // 메뉴 구성
    [self initTabArray];
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), statusBarHeight)];
    [statusBar setBackgroundColor:UIColorFromRGB(0x000000)];
    [self.view addSubview:statusBar];
    
    UIView *searchAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, CGRectGetWidth(self.view.frame), 52)];
    [searchAreaView setBackgroundColor:UIColorFromRGB(0xee3340)];
    [self.view addSubview:searchAreaView];

    UIImage *searchImage = [UIImage imageNamed:@"gnb_search_bg.png"];
    searchImage = [searchImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchImage.size.height / 2, searchImage.size.width / 2, searchImage.size.height / 2, searchImage.size.width / 2)];
    
    UIImageView *searchBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(searchAreaView.frame)-20, 36)];
    [searchBackgroundImageView setImage:searchImage];
    [searchBackgroundImageView setUserInteractionEnabled:YES];
    [searchAreaView addSubview:searchBackgroundImageView];

    searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, CGRectGetWidth(searchAreaView.frame)-58, 36)];
    [searchTextField setDelegate:self];
    [searchTextField setTextColor:UIColorFromRGB(0x444444)];
    [searchTextField setFont:[UIFont systemFontOfSize:16]];
    [searchTextField setReturnKeyType:UIReturnKeySearch];
    [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [searchTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [searchBackgroundImageView addSubview:searchTextField];
    
    [self performSelector:@selector(textFieldBecomeFirstResponder) withObject:nil afterDelay:0.5f];
    
    if (self.isSearchText) {
        [searchTextField setText:self.defaultText];
        isAutoComplete = YES;
        [NSThread detachNewThreadSelector:@selector(getLoadAutoCompleteData:) toTarget:self withObject:[searchTextField.text trim]];
    }
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(CGRectGetWidth(searchBackgroundImageView.frame)-36, 0, 36, 36)];
    [searchButton setImage:[UIImage imageNamed:@"ic_search_nor.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"ic_search_press.png"] forState:UIControlStateHighlighted];
    [searchButton addTarget:self action:@selector(touchSearchButton) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setAccessibilityLabel:@"검색" Hint:@"검색을 시작합니다"];
    [searchBackgroundImageView addSubview:searchButton];
    
    // Tab Menu
    searchTabMenuView = [[CPSearchTabMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchAreaView.frame), kScreenBoundsWidth, 58) tabTitleItems:tabTitles tabContentsItems:tabContents];
    [searchTabMenuView setDelegate:self];
    [self.view addSubview:searchTabMenuView];
    
    // ContentsView iCarousel
    contentsView = [[iCarousel alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(searchTabMenuView.frame),
                                                               kScreenBoundsWidth,
                                                               kScreenBoundsHeight - (CGRectGetHeight(searchAreaView.frame)+CGRectGetHeight(searchTabMenuView.frame)))];
    [contentsView setBackgroundColor:[UIColor clearColor]];
    [contentsView setType:iCarouselTypeLinear];
    [contentsView setDataSource:self];
    [contentsView setDelegate:self];
    [contentsView setDecelerationRate:0.7f];
    [contentsView setScrollSpeed:0.5f];
    [contentsView setBounceDistance:0.5f];
    [self.view addSubview:contentsView];
    
    // 스와이프 버튼
    swipeLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [swipeLeftButton setFrame:CGRectMake(0, self.view.center.y, 30, 46)];
    [swipeLeftButton setBackgroundColor:[UIColor clearColor]];
    [swipeLeftButton setImage:[UIImage imageNamed:@"search_btn_flicking_left.png"] forState:UIControlStateNormal];
    [swipeLeftButton addTarget:self action:@selector(touchSwipeButton:) forControlEvents:UIControlEventTouchUpInside];
    [swipeLeftButton setHidden:NO];
    [swipeLeftButton setTag:0];
    [swipeLeftButton setAccessibilityLabel:@"왼쪽 스와이프" Hint:@"왼쪽으로 스와이프 합니다"];
    [self.view insertSubview:swipeLeftButton aboveSubview:contentsView];
    
    swipeRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [swipeRightButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)-30, self.view.center.y, 30, 46)];
    [swipeRightButton setBackgroundColor:[UIColor clearColor]];
    [swipeRightButton setImage:[UIImage imageNamed:@"search_btn_flicking_right.png"] forState:UIControlStateNormal];
    [swipeRightButton addTarget:self action:@selector(touchSwipeButton:) forControlEvents:UIControlEventTouchUpInside];
    [swipeRightButton setHidden:NO];
    [swipeRightButton setTag:1];
    [swipeRightButton setAccessibilityLabel:@"오른쪽 스와이프" Hint:@"오른쪽으로 스와이프 합니다"];
    [self.view insertSubview:swipeRightButton aboveSubview:contentsView];

    // 자동완성 테이블뷰
    UIImageView *tableBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [tableBgImageView setImage:[UIImage imageNamed:@"autocomplete_bg.png"]];
    
    autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                          CGRectGetMaxY(searchAreaView.frame),
                                                                          kScreenBoundsWidth,
                                                                          CGRectGetHeight(self.view.frame)-CGRectGetHeight(searchAreaView.frame))
                                                     style:UITableViewStylePlain];
    [autoCompleteTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [autoCompleteTableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [autoCompleteTableView setDataSource:self];
    [autoCompleteTableView setDelegate:self];
    [autoCompleteTableView setScrollsToTop:NO];
    [autoCompleteTableView setShowsVerticalScrollIndicator:NO];
    [autoCompleteTableView setHidden:YES];
    [autoCompleteTableView setBackgroundView:tableBgImageView];
    [self.view addSubview:autoCompleteTableView];
    
    // 닫기 버튼
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)-59, CGRectGetHeight(self.view.frame)-36, 51, 27)];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close.png"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close_press.png"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(touchCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
    [self.view addSubview:closeButton];
    
    //AccessLog - 검색창
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"AGC0100"];
}

#pragma mark - Selectors

- (void)touchKeyword:(id)sender
{
    NSUInteger index = [(UIButton *)sender tag];
    NSString *keyword = nil;
    
    if (isAutoComplete) {
        if (autoCompleteLeftKeywordArray && autoCompleteLeftKeywordArray.count > 0) {
            keyword = index % 2 == 0 ? [autoCompleteLeftKeywordArray objectAtIndex:index / 2] : [autoCompleteRightKeywordArray objectAtIndex:index / 2];
        }
        else {
            keyword = [autoCompleteRightKeywordArray objectAtIndex:index / 2];
        }
        
        //AccessLog - 검색창 자동완성 검색어 선택
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB01"];
    }
    
    if (keyword) {
        [self search:keyword];
    }
}

- (void)touchSearchButton
{
    //AccessLog - 검색창 검색 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB08"];
    
    //검색어가 광고와 같다면 광고 URL을 실행하고, 광고가 아니라면 실제 검색을 실행한다.
    if ([self.defaultText length] > 0 && [self.defaultText isEqualToString:searchTextField.text]) {
        if ([self.defaultUrl length] > 0) {
            if ([self.delegate respondsToSelector:@selector(searchWithAdvertisement:)]) {
                [self.delegate searchWithAdvertisement:self.defaultUrl];
                
                [self closeSearchViewController];
            }
            return;
        }
    }
    
    [self search:[searchTextField.text trim]];
}

- (void)touchCancelButton
{
    [self closeSearchViewController];
    
    //AccessLog - 검색창 취소 버튼
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB06"];
}

- (void)touchSwipeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger index = contentsView.currentItemIndex;
    
    if (button.tag == 0) {
        if (index == 0) {
            index = tabContents.count-1;
        }
        else {
            index = index - 1;
        }
    }
    else {
        if (index == tabContents.count-1) {
            index = 0;
        }
        else {
            index = index + 1;
        }
    }
    
    [contentsView scrollToItemAtIndex:index animated:YES];
    
    //AccessLog - 스와이프 버튼 클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB10"];
}

- (void)search:(NSString *)keyword
{
    if (!keyword || [[keyword trim] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchWithKeyword:)]) {
        [self.delegate searchWithKeyword:keyword];
    }
    
    //최근 검색어 저장
    if ([self isValidateKeyword:keyword]) {
        [CPCommonInfo addRecentSearchItems:keyword];
    }
    
//    [self.navigationController setNavigationBarHidden:NO];
//    CPProductListViewController *viewConroller = [[CPProductListViewController alloc] init];
//    [self.navigationController pushViewController:viewConroller animated:YES];
    
    [self closeSearchViewController];
    
    //AccessLog - 검색
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"UMA0201"];
}

- (void)closeSearchViewController
{
    [searchTextField resignFirstResponder];
    isAutoComplete = NO;
    
//    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)isValidateKeyword:(NSString *)keyword
{
    NSString *regular = @"[^\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318f a- zA-Z0-9]+";
    NSString *inputKeyword = [keyword stringByReplacingOccurrencesOfString:regular withString:@" "];
    inputKeyword = [inputKeyword stringByReplacingOccurrencesOfString:@"\\p{Space}" withString:@""];
    inputKeyword = [inputKeyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    inputKeyword = [inputKeyword lowercaseString];
    
    if ([inputKeyword isMatchedByRegex:@"[ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ]"]) {
        return NO;
    }
    
    if ([inputKeyword isMatchedByRegex:@"[ㅏ ㅐ ㅑ ㅒ ㅓ ㅔ ㅕ ㅖ ㅗ ㅘ ㅙ ㅚ ㅛ ㅜ ㅝ ㅞ ㅟ ㅠ ㅡ ㅢ ㅣ]"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - API

- (void)getRiseKeywordList
{   
    NSString *apiUrl = [APP_SEARCH_URL stringByReplacingOccurrencesOfString:@"{{type}}" withString:@"rise"];
    apiUrl = [[Modules urlWithQueryString:apiUrl] stringByAppendingFormat:@"&requestTime=%@", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
    
    void (^searchSuccess)(NSDictionary *);
    searchSuccess = ^(NSDictionary *result) {
        if (result && [result count] > 0) {
            [riseKeywordArray setArray:result[@"list"]];
            riseUpdateDate = result[@"date"];
        }
        
        [self performSelectorInBackground:@selector(getHotKeywordList:) withObject:nil];
        
        [self stopLoadingAnimation];
    };
    
    void (^searchFailure)(NSError *);
    searchFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    [[CPRESTClient sharedClient] requestSearchWithUrl:apiUrl
                                              success:searchSuccess
                                              failure:searchFailure];
}

- (void)getHotKeywordList:(id)sender
{
    NSString *apiUrl = [APP_SEARCH_URL stringByReplacingOccurrencesOfString:@"{{type}}" withString:@"day"];
    apiUrl = [[Modules urlWithQueryString:apiUrl] stringByAppendingFormat:@"&requestTime=%@", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
    
    void (^searchSuccess)(NSDictionary *);
    searchSuccess = ^(NSDictionary *result) {
        if (result && [result count] > 0) {
            [hotKeywordArray setArray:result[@"list"]];
            hotUpdateDate = result[@"date"];
        }
        
        // Load View
        [self loadContentsView];
        
        [self stopLoadingAnimation];
    };
    
    void (^searchFailure)(NSError *);
    searchFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        
    };
    
    [[CPRESTClient sharedClient] requestSearchWithUrl:apiUrl
                                              success:searchSuccess
                                              failure:searchFailure];
}

- (void)getLoadAutoCompleteData:(NSString *)keyword
{   
    if (nilCheck(keyword)) {
        return;
    }
    
    //인코딩을 두번해야 한글 검색 가능
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (nilCheck(keyword)) {
        return;
    }
    
    NSString *apiUrl = [APP_AUTOCOMPLETE_URL stringByReplacingOccurrencesOfString:@"{{key}}" withString:keyword];
    
    void (^searchSuccess)(NSDictionary *);
    searchSuccess = ^(NSDictionary *result) {
        if (result && [result count] > 0) {
            
            if (isAutoComplete) {
                [autoCompleteLeftKeywordArray removeAllObjects];
                [autoCompleteRightKeywordArray removeAllObjects];
                
                NSArray *outKeywordLeftArray = result[@"AKCResult"][@"outKwd"];
                NSArray *outKeywordRightArray = result[@"AKCResult1"][@"outKwd1"];
                
                if (outKeywordLeftArray && outKeywordLeftArray.count > 0) {
                    for (NSString *keyword in outKeywordLeftArray) {
                        if (keyword && ![keyword isEqual:[NSNull null]]) {
                            [autoCompleteLeftKeywordArray addObject:keyword];
                        }
                    }
                }
                
                if (outKeywordRightArray && outKeywordRightArray.count > 0) {
                    for (NSString *keyword in outKeywordRightArray) {
                        if (keyword && ![keyword isEqual:[NSNull null]]) {
                            [autoCompleteRightKeywordArray addObject:keyword];
                        }
                    }
                }
                
                [autoCompleteTableView setHidden:NO];
                [autoCompleteTableView reloadData];
            }
        }
        
    };
    
    void (^searchFailure)(NSError *);
    searchFailure = ^(NSError *error) {
        //
        
    };
    
    [[CPRESTClient sharedClient] requestSearchWithUrl:apiUrl
                                              success:searchSuccess
                                              failure:searchFailure];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return  tabContents.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, CGRectGetHeight(contentsView.frame))];
    [view setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *tabContentsInfo = tabContents[index];
    if ([tabContentsInfo[@"key"] isEqualToString:@"recent"]) {
        CPSearchView *recentTableView = [[CPSearchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))
                                                           tabContentsItems:recentKeywordArray
                                                                 searchType:CPSearchTypeRecent
                                                                 searchDate:@""
                                                                  pageIndex:0];
        [recentTableView setDelegate:self];
        [view addSubview:recentTableView];
    }
    else if ([tabContentsInfo[@"key"] isEqualToString:@"rise"]) {
        NSInteger pageIndex = [tabContentsInfo[@"page"] integerValue];
        
        NSInteger arrayCount = riseKeywordArray.count;
        NSInteger location = 0;
        NSInteger length = 0;
        
        if (pageIndex  == 0) {
            location = 0;
            
            if (arrayCount > 10) {
                length = 10;
            }
            else {
                length = arrayCount;
            }
        }
        else if (pageIndex  == 1) {
            location = 10;
            
            if (arrayCount > 20) {
                length = 10;
            }
            else {
                length = arrayCount - 10;
            }
        }
        else if (pageIndex  == 2) {
            location = 20;
            length = arrayCount - 20;
        }
        
        NSArray *subArray = [riseKeywordArray subarrayWithRange:NSMakeRange(location, length)];
            
        CPSearchView *riseTableView = [[CPSearchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))
                                                           tabContentsItems:subArray
                                                                 searchType:CPSearchTypeRise
                                                               searchDate:riseUpdateDate
                                                                pageIndex:pageIndex];
        [riseTableView setDelegate:self];
        [view addSubview:riseTableView];
    }
    else if ([tabContentsInfo[@"key"] isEqualToString:@"hot"]) {
        CPSearchView *hotTableView = [[CPSearchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))
                                                           tabContentsItems:hotKeywordArray
                                                                 searchType:CPSearchTypeHot
                                                              searchDate:hotUpdateDate
                                                               pageIndex:0];
        [hotTableView setDelegate:self];
        [view addSubview:hotTableView];
    }
    
    return view;
}

#pragma mark - iCarouselDelegate

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case iCarouselOptionWrap:
            return YES;
            break;
        case iCarouselOptionVisibleItems:
            value = tabContents.count;
            break;
        case iCarouselOptionSpacing:
            break;
        default:
            break;
    }
    
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    [searchTabMenuView tabMenuCurrentItemIndexDidChange:carousel.currentItemIndex];
    
//    NSDictionary *tabInfo = tabContents[carousel.currentItemIndex];
//    if ([tabInfo[@"key"] isEqualToString:@"rise"]) {
//        [UIView animateWithDuration:0.5f animations:^{
//            [swipeLeftButton setHidden:NO];
//            [swipeRightButton setHidden:NO];
//        }];
//    }
//    else {
//        [UIView animateWithDuration:0.5f animations:^{
//            [swipeLeftButton setHidden:YES];
//            [swipeRightButton setHidden:YES];
//        }];
//    }
    
    [searchTextField resignFirstResponder];
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
//    [self.searchTextField resignFirstResponder];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
//    [self.searchTextField resignFirstResponder];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //    NSLog(@"didSelectItemAtIndex:%@", menuItems[index]);
}

#pragma mark - CPSearchTabMenuViewDelegate

- (void)didTouchTabMenuButton:(NSInteger)index
{
    [contentsView scrollToItemAtIndex:index animated:YES];
}

#pragma mark - CPSearchViewDelegate

- (void)didTouchKeyword:(NSString *)keyword
{
    [self search:keyword];
}

- (void)didScrollViewWillBeginDragging
{
    [searchTextField resignFirstResponder];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 0;
    
    if (isAutoComplete) {
        rowsCount = [autoCompleteLeftKeywordArray count] > [autoCompleteRightKeywordArray count] ? [autoCompleteLeftKeywordArray count]: [autoCompleteRightKeywordArray count];
    }
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"autoCompleteCellLeft";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (isAutoComplete) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([autoCompleteLeftKeywordArray count] > indexPath.row) {

            ColorLabel *leftLabel = [[ColorLabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [leftLabel setBackgroundColor:[UIColor clearColor]];
//            [leftLabel setText:[[autoCompleteLeftKeywordArray objectAtIndex:indexPath.row] objectForKey:@"Word"]];
            [leftLabel setText:autoCompleteLeftKeywordArray[indexPath.row]];
            [leftLabel setTextColor:[UIColor blackColor]];
            [leftLabel setFont:[UIFont systemFontOfSize:16.0f]];
            [leftLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [leftLabel setColorWord:[searchTextField.text trim] withColor:[UIColor redColor]];
            [cell.contentView addSubview:leftLabel];
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftButton setTag:indexPath.row * 2];
            [leftButton setFrame:CGRectMake(10, 0, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [leftButton setBackgroundColor:[UIColor clearColor]];
            [leftButton addTarget:self action:@selector(touchKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [leftButton setAccessibilityLabel:@"자동완성 검색어" Hint:@"자동완성 검색어를 선택합니다"];
            [cell.contentView addSubview:leftButton];
        }
        
        if ([autoCompleteRightKeywordArray count] > indexPath.row) {
            ColorLabel *rightLabel = [[ColorLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(autoCompleteTableView.frame)/2+10, 10, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [rightLabel setBackgroundColor:[UIColor clearColor]];
            [rightLabel setTextAlignment:NSTextAlignmentRight];
//            [rightLabel setText:[[autoCompleteRightKeywordArray objectAtIndex:indexPath.row] objectForKey:@"Word"]];
            [rightLabel setText:autoCompleteRightKeywordArray[indexPath.row]];
            [rightLabel setTextColor:[UIColor blackColor]];
            [rightLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [rightLabel setFont:[UIFont systemFontOfSize:16.0f]];
            [rightLabel setTag:indexPath.row * 2 + 1];
            [rightLabel setColorWord:[searchTextField.text trim] withColor:[UIColor redColor]];
            [cell.contentView addSubview:rightLabel];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setTag:indexPath.row * 2 + 1];
            [rightButton setFrame:CGRectMake(CGRectGetWidth(autoCompleteTableView.frame)/2, 0, CGRectGetWidth(autoCompleteTableView.frame)/2-20, 40)];
            [rightButton setBackgroundColor:[UIColor clearColor]];
            [rightButton addTarget:self action:@selector(touchKeyword:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton setAccessibilityLabel:@"자동완성 검색어" Hint:@"자동완성 검색어를 선택합니다"];
            [cell.contentView addSubview:rightButton];
        }
    }
    
    //iOS7 대응 : iOS7이상에서 cell의 background가 투명이 아니기때문에 투명하게 지정함.
    if ([SYSTEM_VERSION intValue] >= 7) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [autoCompleteTableView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 키보드 액세사리뷰
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenBoundsHeight-36, kScreenBoundsWidth, 36)];
    [cancelView setBackgroundColor:[UIColor clearColor]];
    [textField setInputAccessoryView:cancelView];
    
    // 닫기 버튼
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(CGRectGetWidth(cancelView.frame)-59, 0, 51, 27)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close.png"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"search_btn_close_press.png"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(touchCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setAccessibilityLabel:@"닫기" Hint:@"검색창을 닫습니다"];
    [cancelView addSubview:cancelButton];
    
    return YES;
}

- (void)onTextDidChanged:(NSNotification *)notification
{
    isAutoComplete = YES;
    
    if ([searchTextField.text length] == 1) {
        [autoCompleteTableView.backgroundView setHidden:NO];
    }
    
    if ([[searchTextField.text trim] length] > 0) {
        [NSThread detachNewThreadSelector:@selector(getLoadAutoCompleteData:) toTarget:self withObject:[searchTextField.text trim]];
    }
    else {
        isAutoComplete = NO;
        [autoCompleteTableView setHidden:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    if (!isAutoComplete) {
        [textField setFont:[UIFont systemFontOfSize:16]];
        
        isAutoComplete = NO;
        
        return;
    }
    
    isAutoComplete = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[searchTextField.text trim] length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"검색어를 입력해주세요."
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
                                              otherButtonTitles:nil];
        
        [alert setDelegate:self];
        [alert setTag:1];
        [alert show];

        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    //검색어가 광고와 같다면 광고 URL을 실행하고, 광고가 아니라면 실제 검색을 실행한다.
    if ([self.defaultText length] > 0 && [self.defaultText isEqualToString:searchTextField.text]) {
        if ([self.defaultUrl length] > 0) {
            if ([self.delegate respondsToSelector:@selector(searchWithAdvertisement:)]) {
                [self.delegate searchWithAdvertisement:self.defaultUrl];
                
                [self closeSearchViewController];
            }
            return YES;
        }
    }
    
    [self search:[searchTextField.text trim]];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    //AccessLog - 검색창 검색어 삭제
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB07"];
    
    return YES;
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self.view addSubview:loadingView];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end