#import "CPProductInfoUserFeedbackView.h"
#import "CPDescriptionBottomReviewItem.h"
#import "CPDescriptionBottomPostItem.h"
#import "CPFooterView.h"
#import "CPString+Formatter.h"
#import "NSString+URLEncodedString.h"

#import "CPRESTClient.h"
#import "CPLoadingView.h"
#import "AccessLog.h"

typedef NS_ENUM(NSUInteger, UserFeedbackType)
{
	UserFeedbackTypeReview = 0,
	UserFeedbackTypePost
};

typedef NS_ENUM(NSUInteger, UserSortingType)
{
    UserSortingTypeRecommand = 0,
    UserSortingTypeReviewAll
};

@interface CPProductInfoUserFeedbackView () <UITableViewDataSource,
                                            UITableViewDelegate,
                                            CPFooterViewDelegate,
                                            CPDescriptionBottomReviewItemDelegate,
                                            CPDescriptionBottomPostItemDelegate>
{
	NSString *prdNo;
	NSDictionary *items;
	UITableView *feedbackTableView;
	NSMutableArray *tableDataArray;
    NSMutableArray *reviewSortArray;
    NSMutableArray *recommandSortArray;
	
    UserFeedbackType currentViewType;
	NSInteger currentPage;
    NSInteger lastLoadIndex;
	NSInteger reviewTotalCount;
    NSInteger postTotalCount;
    NSString *nextReviewApiUrl;
    NSString *nextPostApiUrl;
    NSString *lastCallReviewUrl;
    NSString *lastCallPostUrl;
    BOOL isNext;
    BOOL existReviewMoreButton;
    BOOL existPostMoreButton;
    //판매자 요청에 의한 리뷰/후기 비노출
    BOOL reviewPostDispYN;
//    NSString *pageNumStr;
    
    CPLoadingView *loadingView;
    CPFooterView *cpFooterView;
    UIButton *recommandButton;
    UIButton *reviewAllButton;
    UserSortingType currentOpenSortType;
    UIView *sortTypeContainerView;
}

@end

@implementation CPProductInfoUserFeedbackView

- (void)releaseItem
{
    if (prdNo) prdNo = nil;
    if (items) items = nil;
    if (feedbackTableView) feedbackTableView.dataSource = nil, feedbackTableView.delegate = nil, feedbackTableView = nil;
    if (tableDataArray) tableDataArray = nil;
    if (reviewSortArray) reviewSortArray = nil;
    if (recommandSortArray) recommandSortArray = nil;
    if (nextReviewApiUrl) nextReviewApiUrl = nil;
    if (nextPostApiUrl) nextPostApiUrl = nil;
    if (lastCallReviewUrl) lastCallReviewUrl = nil;
    if (lastCallPostUrl) lastCallPostUrl = nil;
    if (loadingView) loadingView = nil;
    if (cpFooterView) cpFooterView.delegate = nil, cpFooterView = nil;
    if (recommandButton) recommandButton = nil;
    if (reviewAllButton) reviewAllButton = nil;
    if (sortTypeContainerView) sortTypeContainerView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo
{
    currentViewType = UserFeedbackTypeReview;
    return [self initWithFrame:frame items:aItems prdNo:aPrdNo moveTab:MoveTabTypeReview];
}

- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo moveTab:(MoveTabType)aMoveTab
{
    return [self initWithFrame:frame items:aItems prdNo:aPrdNo moveTab:MoveTabTypeReview loading:YES];
}

- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo moveTab:(MoveTabType)aMoveTab loading:(BOOL)aLoading
{
    if (self = [super initWithFrame:frame])
    {
        if (aPrdNo) {
            prdNo = aPrdNo;
        }
        
        if (aItems) {
            items = aItems;
        }
        
        currentViewType = aMoveTab-1;
        
        [self initLayout:aLoading];
    }
    return self;
}

- (void)initLayout:(BOOL)isLoading
{
    tableDataArray = [NSMutableArray array];
    reviewSortArray = [NSMutableArray array];
    recommandSortArray = [NSMutableArray array];
    
    currentOpenSortType = -1;
	currentPage = 1;
	reviewTotalCount = 1;
    postTotalCount = 1;
    nextReviewApiUrl = @"";
    nextPostApiUrl = @"";
    lastCallReviewUrl = @"";
    lastCallPostUrl = @"";
    isNext = NO;
//    pageNumStr = nil;
    lastLoadIndex = 0;
    existReviewMoreButton = YES;
    existPostMoreButton = YES;
    reviewPostDispYN = [items[@"reviewPostDispYN"] isEqualToString:@"Y"];
	
	feedbackTableView = [[UITableView alloc] initWithFrame:self.bounds];
	feedbackTableView.delegate = self;
	feedbackTableView.dataSource = self;
	feedbackTableView.bounces = YES;
	feedbackTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	if ([feedbackTableView respondsToSelector:@selector(separatorInset)]) {
		[feedbackTableView setSeparatorInset:UIEdgeInsetsZero];
	}
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
                                                                  (CGRectGetHeight(self.frame)-kToolBarHeight)/2-40,
                                                                  80,
                                                                  80)];
    [self addSubview:loadingView];
	
    if (isLoading) [self touchTabView];
	[self addSubview:feedbackTableView];
    
    //Footer
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setFrame:CGRectMake(0, 0, cpFooterView.width, cpFooterView.height)];
    [cpFooterView setDelegate:self];
    [feedbackTableView setTableFooterView:cpFooterView];
}

- (void)parseReviewObject:(NSDictionary *)dict moreYn:(BOOL)isMore
{
    [reviewSortArray removeAllObjects];
    [recommandSortArray removeAllObjects];
    
    reviewSortArray = [dict[@"review"][@"list"][0][@"viewTypeFilter"] mutableCopy];
    recommandSortArray = [dict[@"review"][@"list"][0][@"evlFilter"] mutableCopy];
    NSMutableArray *array = [dict[@"review"][@"list"] mutableCopy];
    
//    if (!array || [array count] == 0)
//    {
//        if (!isMore)
//        {
//            [self showErrorPage];
//        }
//        return;
//    }
    
//    totalPage = [dict[@"review"][@"totalPage"] integerValue];
//    pageNumStr = dict[@"review"][@"pageNumStr"];
    nextReviewApiUrl = dict[@"review"][@"nexApiUrl"];
    
    //첫번째 데이터 제거
    [array removeObjectAtIndex:0];
    
    if (!isMore)
    {
        if (!tableDataArray) {
            tableDataArray = [[NSMutableArray alloc] initWithArray:[array mutableCopy]];
        }
        else {
            [tableDataArray addObjectsFromArray:[array mutableCopy]];
        }
        
        if (array.count < 30) {
            existReviewMoreButton = NO;
        }
        
        [feedbackTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [tableDataArray addObjectsFromArray:[array mutableCopy]];
        [feedbackTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)parsePostObject:(NSDictionary *)dict moreYn:(BOOL)isMore
{
    NSArray *array = dict[@"post"][@"list"];
    
//    if (!array || [array count] == 0)
//    {
//        if (!isMore)
//        {
//            [self showErrorPage];
//        }
//        return;
//    }
    
//    totalPage = [dict[@"post"][@"totalPage"] integerValue];
//    pageNumStr = nil;
    nextPostApiUrl = dict[@"post"][@"nexApiUrl"];
    
    if (!isMore)
    {
        if (!tableDataArray) {
            tableDataArray = [[NSMutableArray alloc] initWithArray:[array mutableCopy]];
        }
        else {
            [tableDataArray addObjectsFromArray:[array mutableCopy]];
        }
        
        if (array.count < 30) {
            existPostMoreButton = NO;
        }
        
        [feedbackTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [tableDataArray addObjectsFromArray:[array mutableCopy]];
        [feedbackTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - API

- (void)getReviewData:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^reviewSuccess)(NSDictionary *);
    reviewSuccess = ^(NSDictionary *reviewData) {
        
        if (reviewData && [reviewData count] > 0) {
            
            if (currentViewType == UserFeedbackTypeReview) {
                isNext = [reviewData[@"review"][@"nextYn"] isEqualToString:@"Y"];
                [self parseReviewObject:reviewData moreYn:isNext];
            }
            else if (currentViewType == UserFeedbackTypePost) {
                isNext = [reviewData[@"post"][@"nextYn"] isEqualToString:@"Y"];
                [self parsePostObject:reviewData moreYn:isNext];
            }
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^reviewFailure)(NSError *);
    reviewFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:reviewSuccess
                                                         failure:reviewFailure];
    }
}

#pragma mark - Selectors

- (void)touchTabView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:currentViewType];//UserFeedbackTypeReview];
    
    [self touchTabView:button];
}

- (void)touchTabView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *apiUrl = @"";
    
    switch (button.tag) {
        case UserFeedbackTypeReview:
            apiUrl = items[@"prdReview"][@"reviewListApiUrl"];
            break;
        case UserFeedbackTypePost:
            apiUrl = items[@"prdPost"][@"postListApiUrl"];
            break;
    }
    
    currentViewType = button.tag;
    [self InfoUserFeedbackTabView:button.tag];
    
    apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:prdNo];
    apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:[NSString stringWithFormat:@"%ld", (long)currentPage]];
    
    [tableDataArray removeAllObjects];
    [self removeSortTypeContainerView];
    
    if (currentViewType == UserFeedbackTypeReview && lastCallReviewUrl && lastCallReviewUrl.length > 0) {
        apiUrl = lastCallReviewUrl;
    }
    
    if (currentViewType == UserFeedbackTypePost && lastCallPostUrl && lastCallPostUrl.length > 0) {
        apiUrl = lastCallPostUrl;
    }
    
    if (currentViewType == UserFeedbackTypeReview) lastCallReviewUrl = apiUrl;
    if (currentViewType == UserFeedbackTypePost) lastCallPostUrl = apiUrl;
    
    [self getReviewData:apiUrl];
    
    //AccessLog
    switch (button.tag) {
        case UserFeedbackTypeReview:
            //AccessLog - 리뷰탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL02"];
            break;
        case UserFeedbackTypePost:
            //AccessLog - 후기탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL07"];
            break;
    }
}

- (void)didTouchSortingButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSMutableArray *array = [NSMutableArray array];
    
    switch (button.tag) {
        case UserSortingTypeRecommand:
            recommandButton = button;
            recommandButton.selected = !recommandButton.selected;
            currentOpenSortType = UserSortingTypeRecommand;
            [array setArray:recommandSortArray];
            break;
        case UserSortingTypeReviewAll:
            reviewAllButton = button;
            reviewAllButton.selected = !reviewAllButton.selected;
            currentOpenSortType = UserSortingTypeReviewAll;
            [array setArray:reviewSortArray];
            break;
    }
    
    if (sortTypeContainerView) {
        [self removeSortTypeContainerView];
        return;
    }
    
    if (array.count > 0 && !sortTypeContainerView) {
        
        UIImage *backImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
        sortTypeContainerView = [[UIView alloc] init];
        [sortTypeContainerView setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y, 100, 30*(array.count+1))];
        [feedbackTableView addSubview:sortTypeContainerView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:backImage];
        [imgView setFrame:CGRectMake(0, 0, CGRectGetWidth(sortTypeContainerView.frame), CGRectGetHeight(sortTypeContainerView.frame))];
        [sortTypeContainerView addSubview:imgView];
        
        NSString *sortTypeStr = @"";
        for (NSDictionary *sortInfo in array) {
            if ([sortInfo[@"selectedYn"] isEqualToString:@"Y"]) {
                sortTypeStr = sortInfo[@"name"];
                break;
            }
        }
        
        UIButton *sortingTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sortingTopButton setFrame:CGRectMake(1, 1, 98, 31)];
        [sortingTopButton setTitle:sortTypeStr forState:UIControlStateNormal];
        [sortingTopButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [sortingTopButton setTitleColor:UIColorFromRGB(0xbdbdc0) forState:UIControlStateNormal];
        [sortingTopButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
        [sortingTopButton setContentEdgeInsets:UIEdgeInsetsMake(-1, 7, 0, 0)];
        [sortingTopButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [sortingTopButton addTarget:self action:@selector(removeSortTypeContainerView) forControlEvents:UIControlEventTouchUpInside];
        [sortTypeContainerView addSubview:sortingTopButton];

        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(sortingTopButton.frame)-19, 12.5f, 11, 6)];
        [arrowImageView setImage:[UIImage imageNamed:@"bt_s_arrow_up_02.png"]];
        [sortingTopButton addSubview:arrowImageView];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sortingTopButton.frame)-3, 98, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
        [sortingTopButton addSubview:lineView];
        
        for (int i = 0; i < array.count; i++) {
            NSDictionary *sortItemInfo = array[i];
            
            UIButton *sortingSortTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [sortingSortTypeButton setFrame:CGRectMake(1, (i+1)*30, 98, 31)];
            [sortingSortTypeButton setTitle:sortItemInfo[@"name"] forState:UIControlStateNormal];
            [sortingSortTypeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [sortingSortTypeButton setBackgroundColor:UIColorFromRGB(0xfbfbfb)];
            [sortingSortTypeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
            [sortingSortTypeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [sortingSortTypeButton addTarget:self action:@selector(touchSortTypeButton:) forControlEvents:UIControlEventTouchUpInside];
            [sortingSortTypeButton setTag:i];
            [sortTypeContainerView addSubview:sortingSortTypeButton];
            
            if ([sortItemInfo[@"selectedYn"] isEqualToString:@"Y"]) {
                UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                //                    [selectedButton setFrame:CGRectMake(1, 1, 110, 29)];
                [selectedButton setFrame:CGRectMake(0, 0, 98, 30)];
                [selectedButton setTitle:sortItemInfo[@"name"] forState:UIControlStateNormal];
                [selectedButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                [selectedButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [selectedButton setBackgroundColor:UIColorFromRGB(0x5d5fd6)];
                [selectedButton setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
                [selectedButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [selectedButton addTarget:self action:@selector(touchSortTypeButton:) forControlEvents:UIControlEventTouchUpInside];
                [selectedButton setTag:i];
                [sortingSortTypeButton addSubview:selectedButton];
            }
            else {
                [sortingSortTypeButton setTitleColor:UIColorFromRGB(0x4d4d4d) forState:UIControlStateNormal];
            }
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sortingSortTypeButton.frame)-2, 98, 1)];
            [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e8)];
            [sortingSortTypeButton addSubview:lineView];
            
            if (array.count-1 == i) {
                [lineView setBackgroundColor:UIColorFromRGB(0x74737c)];
            }
        }
    }
}

- (void)touchSortTypeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *sortItemInfo = currentOpenSortType == UserSortingTypeRecommand ? recommandSortArray[button.tag] :  reviewSortArray[button.tag];
    
    //더보기 버튼 초기화
    existReviewMoreButton = YES;
    existPostMoreButton = YES;
    lastLoadIndex = 0;
    
    //AccessLog
    switch (currentOpenSortType) {
        case UserSortingTypeRecommand:
            //AccessLog - 리뷰 추천 정렬
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL04"];
            break;
        case UserSortingTypeReviewAll:
            //AccessLog - 리뷰 종류 정렬
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL03"];
            break;
    }
    
    if (sortItemInfo) {
        NSString *url = sortItemInfo[@"apiUrl"];
        
        if (!(url && [[url trim] length] > 0)) {
            return;
        }
        
        [tableDataArray removeAllObjects];
        [self getReviewData:url];
        
        if (currentViewType == UserFeedbackTypeReview ) {
            lastCallReviewUrl = url;
        }
        else if (currentViewType == UserFeedbackTypePost) {
            lastCallPostUrl = url;
        }
    }
    
    [self removeSortTypeContainerView];
}

- (void)didTouchReviewCell:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(didTouchReviewCell:)]) {
        [self.delegate didTouchReviewCell:url];
    }
}

- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab
{
    if ([self.delegate respondsToSelector:@selector(didTouchTabMove:moveTab:)]) {
        [self.delegate didTouchTabMove:pageIndex moveTab:moveTab];
    }
}

#pragma mark - Private Methods

- (void)reloadView
{
//    [feedbackTableView reloadData];
    [tableDataArray removeAllObjects];
    [self touchTabView];
}

- (void)InfoUserFeedbackTabView:(NSInteger)selectedIdx
{
    currentViewType = selectedIdx;
    currentPage = 1;
    reviewTotalCount = [items[@"prdReview"][@"totalCount"] integerValue];
    postTotalCount = [items[@"prdPost"][@"totalCount"] integerValue];
    nextReviewApiUrl = @"";
    nextPostApiUrl = @"";
    isNext = NO;
    existReviewMoreButton = YES;
    existPostMoreButton = YES;
    reviewPostDispYN = [items[@"reviewPostDispYN"] isEqualToString:@"Y"];
//    pageNumStr = nil;
    lastLoadIndex = 0;
    
    //데이터 초기화
    [tableDataArray removeAllObjects];
}

- (void)removeSortTypeContainerView
{
    if (sortTypeContainerView) {
        recommandButton.selected = NO;
        reviewAllButton.selected = NO;
        currentOpenSortType = -1;
        [sortTypeContainerView removeFromSuperview];
        sortTypeContainerView = nil;
    }
}

- (UIView *)noDataView:(CGFloat)height
{
    UIView *noDataContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, height)];
    [noDataContentView setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *noItemImg = [UIImage imageNamed:@"ic_pd_review.png"];
    
    UIImageView *noItemView = [[UIImageView alloc] initWithFrame:CGRectMake((noDataContentView.frame.size.width/2)-(noItemImg.size.width/2), 46,
                                                                            noItemImg.size.width, noItemImg.size.height)];
    noItemView.image = noItemImg;
    [noDataContentView addSubview:noItemView];
    
    NSString *noText = [NSString stringWithFormat:@"작성된 상품%@가 없습니다.", currentViewType==UserFeedbackTypeReview?@"리뷰":@"후기"];
    UILabel *noTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noTextLabel.backgroundColor = [UIColor clearColor];
    noTextLabel.font = [UIFont systemFontOfSize:14];
    noTextLabel.textColor = UIColorFromRGB(0xb8b8b8);
    noTextLabel.numberOfLines = 1;
    noTextLabel.textAlignment = NSTextAlignmentLeft;
    noTextLabel.text = noText;
    [noTextLabel sizeToFitWithVersion];
    [noDataContentView addSubview:noTextLabel];
    
    noTextLabel.frame = CGRectMake((noDataContentView.frame.size.width/2)-(noTextLabel.frame.size.width/2),
                                   CGRectGetMaxY(noItemView.frame)+12,
                                   noTextLabel.frame.size.width, noTextLabel.frame.size.height);
    
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(noDataContentView.frame)-1, kScreenBoundsWidth, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [noDataContentView addSubview:underLineView];
    
    return noDataContentView;
}

- (UIView *)noDispView:(CGFloat)height
{
    UIView *noDispContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, height)];
    [noDispContentView setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *noItemImg = [UIImage imageNamed:@"ic_pd_review.png"];
    
    UIImageView *noItemView = [[UIImageView alloc] initWithFrame:CGRectMake((noDispContentView.frame.size.width/2)-(noItemImg.size.width/2), 46,
                                                                            noItemImg.size.width, noItemImg.size.height)];
    noItemView.image = noItemImg;
    [noDispContentView addSubview:noItemView];
    
    NSString *noText = @"판매자 요청에 의해상품리뷰/구매후기노출을\n제한합니다.";
    UILabel *noTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noTextLabel.backgroundColor = [UIColor clearColor];
    noTextLabel.font = [UIFont systemFontOfSize:14];
    noTextLabel.textColor = UIColorFromRGB(0xb8b8b8);
    noTextLabel.numberOfLines = 2;
    noTextLabel.textAlignment = NSTextAlignmentCenter;
    noTextLabel.text = noText;
    [noTextLabel sizeToFitWithVersion];
    [noDispContentView addSubview:noTextLabel];
    
    noTextLabel.frame = CGRectMake((noDispContentView.frame.size.width/2)-(noTextLabel.frame.size.width/2),
                                   CGRectGetMaxY(noItemView.frame)+12,
                                   noTextLabel.frame.size.width, noTextLabel.frame.size.height);
    
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(noDispContentView.frame)-1, kScreenBoundsWidth, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [noDispContentView addSubview:underLineView];
    
    return noDispContentView;
}

- (UIView *)moreButton
{
    UIView *moreContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
    lineView.backgroundColor = UIColorFromRGB(0xededed);
    [moreContentView addSubview:lineView];
    
    UIButton *imageMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageMoreButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
    [imageMoreButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [imageMoreButton addTarget:self action:@selector(touchMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [imageMoreButton setAccessibilityLabel:[NSString stringWithFormat: @"%@ 더보기", currentViewType==UserFeedbackTypeReview?@"리뷰":@"후기"]];
    [moreContentView addSubview:imageMoreButton];
    
    NSString *moreStr = [NSString stringWithFormat: @"%@ 더보기", currentViewType==UserFeedbackTypeReview?@"리뷰":@"후기"];
    CGSize moreStrSize = [moreStr sizeWithFont:[UIFont systemFontOfSize:15]];
    
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-(moreStrSize.width+7+13))/2, 0, moreStrSize.width, 44)];
    [moreLabel setText:moreStr];
    [moreLabel setFont:[UIFont systemFontOfSize:15]];
    [moreLabel setTextColor:UIColorFromRGB(0x283593)];
    [imageMoreButton addSubview:moreLabel];
    
    UIImageView *moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moreLabel.frame)+7, 18.5f, 13, 7)];
    [moreImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down_02.png"]];
    [imageMoreButton addSubview:moreImageView];
    
    return moreContentView;
}

- (void)touchMoreButton:(id)sender
{
    [self validateMorePage:[NSIndexPath indexPathForRow:[tableDataArray count]-1 inSection:0]];
    
    //더보기버튼 없애기
    if (currentViewType==UserFeedbackTypeReview) {
        existReviewMoreButton = NO;
    }
    else {
        existPostMoreButton = NO;
    }
    
    //AccessLog
    switch (currentViewType) {
        case UserFeedbackTypeReview:
            //AccessLog - 상품리뷰 더보기
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL06"];
            break;
        case UserFeedbackTypePost:
            //AccessLog - 후기 더보기
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPL08"];
            break;
    }
}

#pragma mark - request Method
- (void)validateMorePage:(NSIndexPath *)indexPath
{
    if (!tableDataArray || [tableDataArray count] == 0) return;
//    if (totalCount <= indexPath.row) return;
    if (currentViewType == UserFeedbackTypeReview && reviewTotalCount <= indexPath.row) return;
    if (currentViewType == UserFeedbackTypePost && postTotalCount <= indexPath.row) return;
    if (!isNext) return;
    if (lastLoadIndex >= indexPath.row) return;
    
    if ([tableDataArray count]-1 == indexPath.row)
    {
        currentPage++;
        
        lastLoadIndex = indexPath.row;
        NSString *apiUrl = @"";
        
        if (currentViewType == UserFeedbackTypeReview) {
//            apiUrl = items[@"prdReview"][@"reviewListApiUrl"];
            if (nextReviewApiUrl && [[nextReviewApiUrl trim] length] > 0) {
                apiUrl = nextReviewApiUrl;
            }
        }
        else if (currentViewType == UserFeedbackTypePost) {
//            apiUrl = items[@"prdPost"][@"postListApiUrl"];
            if (nextPostApiUrl && [[nextPostApiUrl trim] length] > 0) {
                apiUrl = nextPostApiUrl;
            }
        }
        
        apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:prdNo];
        apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:[NSString stringWithFormat:@"%ld", (long)currentPage]];
        
        [self getReviewData:apiUrl];
    }
}




- (void)setScrollTop
{
    [feedbackTableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [feedbackTableView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [feedbackTableView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [feedbackTableView setShowsVerticalScrollIndicator:isShow];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //판매자에 의한 리뷰/후기 비노출
    if (!reviewPostDispYN) {
        return 1;
    }
    
    if (tableDataArray.count == 0) {
        return 2;
    }
    
    BOOL isExistMoreButton = NO;
    
    //더보기버튼
    if (currentViewType == UserFeedbackTypeReview) {
        isExistMoreButton = existReviewMoreButton;
    }
    else {
        isExistMoreButton = existPostMoreButton;
    }
    
    return tableDataArray.count+1+isExistMoreButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isHeaderCell = indexPath.row == 0;
    
    if (!reviewPostDispYN) {
        return 165.f;
    }
    
    if (isHeaderCell) {
        
        if (currentViewType == UserFeedbackTypeReview) {
            return 98.f;
        }
        else {
            return 57.f;
        }
    }
    else {
        
        //noData
        if (tableDataArray.count < 1) {
            return 165.f;
        }
        
        
        //더보기버튼
        BOOL isExistMoreButton = NO;
        
        if (currentViewType == UserFeedbackTypeReview) {
            isExistMoreButton = existReviewMoreButton;
        }
        else {
            isExistMoreButton = existPostMoreButton;
        }
        
        NSInteger totalRow = tableDataArray.count+1+isExistMoreButton;
        BOOL isLastCell = indexPath.row == totalRow-1;
        
        if (isLastCell && isExistMoreButton) {
            return 44.f;
        }
        else {
            if (currentViewType == UserFeedbackTypeReview) {
                
                //이미지가 없으면서 옵션이 없을 때
                if (!tableDataArray[indexPath.row-1][@"option"] && !tableDataArray[indexPath.row-1][@"imgUrl"]) {
                    return 92.f;
                }
                
                return 105.f;
            }
            else {
                
                //후기
                //상단마진
                CGFloat height = 15.f;
                
                //후기 제목
                NSString *subject = tableDataArray[indexPath.row-1][@"subject"];
                height += GET_STRING_SIZE(subject, [UIFont systemFontOfSize:14], kScreenBoundsWidth-85).height;
                
                //마진
                height += 6.f;
                
                //옵션
                NSString *option = @"가"; //옵션은 무조건 공간이 존재해야해서 강제로 텍스트를 박아놓는다.
                CGFloat optionHeight = GET_STRING_SIZE(option, [UIFont systemFontOfSize:13], kScreenBoundsWidth-85).height;
                height += optionHeight;
                
                //마진
                height += 4.f;
                
                //기타 텍스트 (옵션과 높이가 같기때문에 따로 계산하지 않는다.
                height += optionHeight;
                
                //하단 마진
                height += 15.f;
                
                return height;
            }
        }
    }
    
    return 105.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *headerReviewCellIdentifier = @"headerReviewCell";
    static NSString *headerPostCellIdentifier = @"headerPostCell";
    static NSString *reviewItemCellIdentifier = @"reviewItemCell";
    static NSString *postItemCellIdentifier = @"postItemCell";
    static NSString *noDataCellIdentifier = @"noDataCell";
    static NSString *moreCellIdentifier = @"moreCell";
    static NSString *reviewPostDispYNCellIdentifier = @"reviewPostDispYNCell";
    
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell;
    
    BOOL isHeaderCell = indexPath.row == 0;
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isLastCell = indexPath.row == totalRow-1;
    
    //판매자에 의한 리뷰/후기 비노출
    if (!reviewPostDispYN) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reviewPostDispYNCellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell addSubview:[self noDispView:rowHeight]];
        return cell;
    }
    
    if (tableDataArray.count < 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCellIdentifier];
    }
    else {
        if (isHeaderCell) {
            if (currentViewType == UserFeedbackTypeReview) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerReviewCellIdentifier];
            }
            else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerPostCellIdentifier];
            }
        }
        else {
            if (isLastCell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCellIdentifier];
            }
            else {
                if (currentViewType == UserFeedbackTypeReview) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reviewItemCellIdentifier];
                }
                else {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postItemCellIdentifier];
                }
            }
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (isHeaderCell) {
        
        UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, rowHeight)];
        [cellContentView setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:cellContentView];
        
        UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [reviewButton setFrame:CGRectMake(10, 10, kScreenBoundsWidth/2-10, 36)];
        [reviewButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"tab_pd_review_%@.png", currentViewType==UserFeedbackTypeReview?@"01":@"bg"]] forState:UIControlStateNormal];
        [reviewButton setTag:UserFeedbackTypeReview];
        [reviewButton addTarget:self action:@selector(touchTabView:) forControlEvents:UIControlEventTouchUpInside];
        [cellContentView addSubview:reviewButton];
        
        NSString *reviewTextStr = @"리뷰";
        NSString *reviewCountStr = [NSString stringWithFormat:@"(%@)", [items[@"prdReview"][@"totalCount"] formatThousandComma]];
        if ([items[@"prdReview"][@"totalCount"] integerValue] > 99999) reviewCountStr = @"(99,999+)";
        CGSize reviewTextStrSize = [reviewTextStr sizeWithFont:[UIFont systemFontOfSize:14]];
        CGSize reviewCountStrSize = [reviewCountStr sizeWithFont:[UIFont systemFontOfSize:12]];
        CGFloat reviewX = (CGRectGetWidth(reviewButton.frame)-(reviewTextStrSize.width+reviewCountStrSize.width))/2;
        
        UILabel *reviewTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(reviewX, 0, reviewTextStrSize.width, CGRectGetHeight(reviewButton.frame))];
        [reviewTextLabel setBackgroundColor:[UIColor clearColor]];
        [reviewTextLabel setText:reviewTextStr];
        [reviewTextLabel setTextColor:currentViewType==UserFeedbackTypeReview?UIColorFromRGB(0xffffff):UIColorFromRGB(0x666666)];
        [reviewTextLabel setFont:[UIFont systemFontOfSize:14]];
        [reviewTextLabel setTextAlignment:NSTextAlignmentCenter];
        [reviewButton addSubview:reviewTextLabel];
        
        UILabel *reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(reviewTextLabel.frame), 0, reviewCountStrSize.width, CGRectGetHeight(reviewButton.frame))];
        [reviewCountLabel setBackgroundColor:[UIColor clearColor]];
        [reviewCountLabel setText:reviewCountStr];
        [reviewCountLabel setTextColor:currentViewType==UserFeedbackTypeReview?UIColorFromRGB(0xffffff):UIColorFromRGB(0x666666)];
        [reviewCountLabel setFont:[UIFont systemFontOfSize:12]];
        [reviewCountLabel setTextAlignment:NSTextAlignmentCenter];
        [reviewButton addSubview:reviewCountLabel];
        
        
        UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [postButton setFrame:CGRectMake(CGRectGetMaxX(reviewButton.frame), 10, kScreenBoundsWidth/2-10, 36)];
        [postButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"tab_pd_review_%@.png", currentViewType==UserFeedbackTypeReview?@"bg":@"02"]] forState:UIControlStateNormal];
        [postButton setTag:UserFeedbackTypePost];
        [postButton addTarget:self action:@selector(touchTabView:) forControlEvents:UIControlEventTouchUpInside];
        [cellContentView addSubview:postButton];
        
        NSString *postTextStr = @"후기";
        NSString *postCountStr = [NSString stringWithFormat:@"(%@)", [items[@"prdPost"][@"totalCount"] formatThousandComma]];
        if ([items[@"prdPost"][@"totalCount"] integerValue] > 99999) postCountStr = @"(99,999+)";
        CGSize postTextStrSize = [postTextStr sizeWithFont:[UIFont systemFontOfSize:14]];
        CGSize postCountStrSize = [postCountStr sizeWithFont:[UIFont systemFontOfSize:12]];
        CGFloat postX = (CGRectGetWidth(postButton.frame)-(postTextStrSize.width+postCountStrSize.width))/2;
        
        UILabel *postTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(postX, 0, postTextStrSize.width, CGRectGetHeight(postButton.frame))];
        [postTextLabel setBackgroundColor:[UIColor clearColor]];
        [postTextLabel setText:postTextStr];
        [postTextLabel setTextColor:currentViewType==UserFeedbackTypeReview?UIColorFromRGB(0x666666):UIColorFromRGB(0xffffff)];
        [postTextLabel setFont:[UIFont systemFontOfSize:14]];
        [postTextLabel setTextAlignment:NSTextAlignmentCenter];
        [postButton addSubview:postTextLabel];
        
        UILabel *postCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(postTextLabel.frame), 0, postCountStrSize.width, CGRectGetHeight(postButton.frame))];
        [postCountLabel setBackgroundColor:[UIColor clearColor]];
        [postCountLabel setText:postCountStr];
        [postCountLabel setTextColor:currentViewType==UserFeedbackTypeReview?UIColorFromRGB(0x666666):UIColorFromRGB(0xffffff)];
        [postCountLabel setFont:[UIFont systemFontOfSize:12]];
        [postCountLabel setTextAlignment:NSTextAlignmentCenter];
        [postButton addSubview:postCountLabel];
        
        if (currentViewType == UserFeedbackTypeReview) {
            
            NSString *recommandSortStr = @"";
            for (NSDictionary *sortInfo in recommandSortArray) {
                if ([sortInfo[@"selectedYn"] isEqualToString:@"Y"]) {
                    recommandSortStr = sortInfo[@"name"];
                    break;
                }
            }
            
            //sort type button
            UIImage *backgroundImage = [[UIImage imageNamed:@"layer_s_filterbg_nor.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            UIImage *backgroundPressImage = [[UIImage imageNamed:@"layer_s_filterbg_press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            
            UIButton *recommandSortButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [recommandSortButton setFrame:CGRectMake(kScreenBoundsWidth-110, CGRectGetMaxY(reviewButton.frame)+10, 100, 31)];
            [recommandSortButton setTag:UserSortingTypeRecommand];
            [recommandSortButton setTitle:recommandSortStr forState:UIControlStateNormal];
            [recommandSortButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [recommandSortButton setTitleColor:UIColorFromRGB(0x242529) forState:UIControlStateNormal];
            [recommandSortButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            [recommandSortButton setBackgroundImage:backgroundPressImage forState:UIControlStateSelected];
            [recommandSortButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
            [recommandSortButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [recommandSortButton addTarget:self action:@selector(didTouchSortingButton:) forControlEvents:UIControlEventTouchUpInside];
            [cellContentView addSubview:recommandSortButton];
            
            UIImageView *recommandImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [recommandImageView setFrame:CGRectMake(CGRectGetWidth(recommandSortButton.frame)-19, 12.5f, 11, 6)];
            [recommandImageView setImage:[UIImage imageNamed:@"bt_s_arrow_down_02.png"]];
            [recommandSortButton addSubview:recommandImageView];
            
            
            NSString *reviewAllSortStr = @"";
            for (NSDictionary *sortInfo in reviewSortArray) {
                if ([sortInfo[@"selectedYn"] isEqualToString:@"Y"]) {
                    reviewAllSortStr = sortInfo[@"name"];
                    break;
                }
            }
            
            UIButton *reviewAllSortButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [reviewAllSortButton setFrame:CGRectMake(recommandSortButton.frame.origin.x-110, CGRectGetMaxY(reviewButton.frame)+10, 100, 31)];
            [reviewAllSortButton setTag:UserSortingTypeReviewAll];
            [reviewAllSortButton setTitle:reviewAllSortStr forState:UIControlStateNormal];
            [reviewAllSortButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [reviewAllSortButton setTitleColor:UIColorFromRGB(0x242529) forState:UIControlStateNormal];
            [reviewAllSortButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            [reviewAllSortButton setBackgroundImage:backgroundPressImage forState:UIControlStateSelected];
            [reviewAllSortButton setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
            [reviewAllSortButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [reviewAllSortButton addTarget:self action:@selector(didTouchSortingButton:) forControlEvents:UIControlEventTouchUpInside];
            [cellContentView addSubview:reviewAllSortButton];
            
            UIImageView *reviewAllImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [reviewAllImageView setFrame:CGRectMake(CGRectGetWidth(reviewAllSortButton.frame)-19, 12.5f, 11, 6)];
            [reviewAllImageView setImage:[UIImage imageNamed:@"bt_s_arrow_down_02.png"]];
            [reviewAllSortButton addSubview:reviewAllImageView];
        }
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cellContentView.frame)-1, kScreenBoundsWidth, 1)];
        [underLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
        [cellContentView addSubview:underLineView];
    }
    else {
        
        BOOL isExistMoreButton = NO;
        
        if (currentViewType == UserFeedbackTypeReview) {
            isExistMoreButton = existReviewMoreButton;
        }
        else {
            isExistMoreButton = existPostMoreButton;
        }
        
        if (isLastCell && isExistMoreButton) {
            
            //더보기 버튼
            [cell addSubview:[self moreButton]];
            return cell;
        }
        else {
            
            //noData
            if (tableDataArray.count < 1) {
                [cell addSubview:[self noDataView:rowHeight]];
                return cell;
            }
            
            if (currentViewType == UserFeedbackTypeReview) {
                CPDescriptionBottomReviewItem *item = [[CPDescriptionBottomReviewItem alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                                      kScreenBoundsWidth,
                                                                                                                      rowHeight)
                                                                                                      item:tableDataArray[indexPath.row-1]
                                                                                                       url:items[@"prdReview"][@"reviewApiUrl"]
                                                                                                     prdNo:tableDataArray[indexPath.row-1][@"contNo"]
                                                                                                  lastItem:(indexPath.row == tableDataArray.count)
                                                                                                   isInTab:YES];
                item.delegate = self;
                [cell addSubview:item];
                
                if (!existReviewMoreButton) {
                    [self validateMorePage:indexPath];
                }
            }
            else if (currentViewType == UserFeedbackTypePost) {
                CPDescriptionBottomPostItem *item = [[CPDescriptionBottomPostItem alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                                  self.frame.size.width,
                                                                                                                  0.f)
                                                                                                  item:tableDataArray[indexPath.row-1]
                                                                                              lastItem:(indexPath.row == tableDataArray.count)];
                item.delegate = self;
                [cell addSubview:item];
                
                if (!existPostMoreButton) {
                    [self validateMorePage:indexPath];
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self removeSortTypeContainerView];
    [self.delegate productInfoUserFeedbackView:self scrollViewDidScroll:scrollView];
}

#pragma mark - CPLoadingView

- (void)startLoadingAnimation
{
    [self insertSubview:loadingView aboveSubview:self];
    [loadingView startAnimation];
}

- (void)stopLoadingAnimation
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
