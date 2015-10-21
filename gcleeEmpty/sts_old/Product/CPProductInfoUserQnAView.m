#import "CPProductInfoUserQnAView.h"
#import "CPInfoUserFeedbackQnaAnswerCell.h"
#import "CPInfoUserFeedbackQnaButtonCell.h"
#import "CPInfoUserFeedbackQnaListCell.h"
#import "CPInfoUserFeedbackQnaQuestionCell.h"
#import "CPFooterView.h"
#import "NSString+URLEncodedString.h"
#import "CPRESTClient.h"
#import "CPLoadingView.h"
#import "TTTAttributedLabel.h"
#import "AccessLog.h"

@interface CPProductInfoUserQnAView () <UITableViewDataSource,
                                        UITableViewDelegate,
                                        CPFooterViewDelegate,
                                        CPInfoUserFeedbackQnaButtonCellDelegate,
                                        CPInfoUserFeedbackQnaQuestionCellDelegate,
                                        TTTAttributedLabelDelegate>
{
	NSString *_prdNo;
	NSDictionary *_items;
	UITableView *_tableView;
    UIView *_tabView;
	NSMutableArray *_tableDataArray;
	
    NSInteger _currentViewType;
	NSInteger _currentPage;
    NSInteger _lastLoadIndex;
    NSString *_pageNumStr;
    NSString *_nextApiUrl;
    BOOL _isNextPage;
    BOOL existMoreButton;
    
    CPLoadingView *loadingView;
    CPFooterView *cpFooterView;
    UIButton *tempButton;
}

@end

@implementation CPProductInfoUserQnAView

- (void)releaseItem
{
    if (_prdNo) _prdNo = nil;
    if (_items) _items = nil;
    if (_tableView) _tableView.dataSource = nil, _tableView.delegate = nil, _tableView = nil;
    if (_tableDataArray) _tableDataArray = nil;
    if (_pageNumStr) _pageNumStr = nil;
    if (_nextApiUrl) _nextApiUrl = nil;
    if (loadingView) loadingView = nil;
    if (tempButton) tempButton = nil;
    if (cpFooterView) cpFooterView.delegate = nil, cpFooterView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)items prdNo:(NSString *)prdNo
{
	if (self = [super initWithFrame:frame])
	{
		if (prdNo) {
			_prdNo = prdNo;
		}
		
		if (items) {
			_items = items;
		}
		
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
    _tableDataArray = [NSMutableArray array];
    _currentViewType = -1;
	_currentPage = 1;
	_isNextPage = NO;
    _pageNumStr = nil;
    _nextApiUrl = @"";
    _lastLoadIndex = 0;
    existMoreButton = YES;
	
	_tableView = [[UITableView alloc] initWithFrame:self.bounds];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.bounces = YES;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	if ([_tableView respondsToSelector:@selector(separatorInset)]) {
		[_tableView setSeparatorInset:UIEdgeInsetsZero];
	}
    
    [self addSubview:_tableView];
    
    //GS리테일, 홈플러스일때는 제외
    if ([_items[@"martInfo"][@"martNo"] integerValue] != 3 && [_items[@"martInfo"][@"martNo"] integerValue] != 5 && [_items[@"martInfo"][@"martNo"] integerValue] != 6) {
        //상단 Q&A쓰기 영역
        [self initWriteView];
    }
    
    //LoadingView
    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-40,
                                                                  (CGRectGetHeight(self.frame)-kToolBarHeight)/2-40,
                                                                  80,
                                                                  80)];
    [self addSubview:loadingView];
    
    //Footer
    cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
    [cpFooterView setFrame:CGRectMake(0, 0, cpFooterView.width, cpFooterView.height)];
    [cpFooterView setDelegate:self];
    [_tableView setTableFooterView:cpFooterView];
    
    [self getQnaData:_items[@"prdQna"][@"qnaApiUrl"]];
}

- (void)initWriteView
{
    _tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 59)];
    [_tabView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setTableHeaderView:_tabView];
    
    UIImage *writeImage = [[UIImage imageNamed:@"bt_pd_write_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIButton *writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeButton setFrame:CGRectMake(10, 10, kScreenBoundsWidth-20, 38)];
    [writeButton setBackgroundImage:writeImage forState:UIControlStateNormal];
    [writeButton addTarget:self action:@selector(touchWriteButton:) forControlEvents:UIControlEventTouchUpInside];
    [_tabView addSubview:writeButton];
    
    NSString *qnaStr = @"Q&A쓰기";
    CGSize qnaStrSize = [qnaStr sizeWithFont:[UIFont systemFontOfSize:14]];
    CGFloat qnaImageX = (CGRectGetWidth(writeButton.frame)-(14+5+qnaStrSize.width))/2;
    
    UIImageView *qnaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(qnaImageX, (CGRectGetHeight(writeButton.frame)-14)/2, 14, 14)];
    [qnaImageView setImage:[UIImage imageNamed:@"ic_pd_write.png"]];
    [writeButton addSubview:qnaImageView];
    
    UILabel *qnaLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(qnaImageView.frame)+5, 0, qnaStrSize.width, CGRectGetHeight(writeButton.frame))];
    [qnaLabel setBackgroundColor:[UIColor clearColor]];
    [qnaLabel setText:qnaStr];
    [qnaLabel setTextColor:UIColorFromRGB(0x333333)];
    [qnaLabel setFont:[UIFont systemFontOfSize:14]];
    [writeButton addSubview:qnaLabel];
    
    UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_tabView.frame)-1, kScreenBoundsWidth, 1)];
    [underLineView setBackgroundColor:UIColorFromRGB(0xebebeb)];
    [_tabView addSubview:underLineView];
}

- (UIView *)noDataMartView:(CGFloat)height
{
    UIView *noDataContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, height)];
    [noDataContentView setBackgroundColor:[UIColor whiteColor]];
    
    NSString *noText = @"이 상품에 궁금한 점이 있으세요?\n전화주시면 친절히 상담해 드립니다.";
    UILabel *noTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, kScreenBoundsWidth, 36)];
    noTextLabel.backgroundColor = [UIColor clearColor];
    noTextLabel.font = [UIFont systemFontOfSize:14];
    noTextLabel.textColor = UIColorFromRGB(0x666666);
    noTextLabel.numberOfLines = 2;
    noTextLabel.textAlignment = NSTextAlignmentCenter;
    noTextLabel.text = noText;
    [noDataContentView addSubview:noTextLabel];
    
    
    NSString *martNm = [self getMartNM:_items[@"martInfo"][@"martNo"]];
    UILabel *martNmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(noTextLabel.frame)+20, kScreenBoundsWidth, 14)];
    martNmLabel.backgroundColor = [UIColor clearColor];
    martNmLabel.font = [UIFont systemFontOfSize:13];
    martNmLabel.textColor = UIColorFromRGB(0x999999);
    martNmLabel.textAlignment = NSTextAlignmentCenter;
    martNmLabel.text = martNm;
    [noDataContentView addSubview:martNmLabel];
    
    
    NSString *linkStr = _items[@"martInfo"][@"tel"];
    CGSize labelSize = [linkStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, 15) lineBreakMode:NSLineBreakByWordWrapping];
    
    TTTAttributedLabel *linkLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-labelSize.width)/2, CGRectGetMaxY(martNmLabel.frame)+4, labelSize.width, 15)];
    [linkLabel setDelegate:self];
    [linkLabel setBackgroundColor:[UIColor clearColor]];
    [linkLabel setTextColor:UIColorFromRGB(0x51bcff)];
    [linkLabel setFont:[UIFont systemFontOfSize:14]];
    [linkLabel setTextAlignment:NSTextAlignmentCenter];
    [linkLabel setText:linkStr];
    [linkLabel addLinkToPhoneNumber:linkStr withRange:[linkLabel.text rangeOfString:linkStr]];
    [noDataContentView addSubview:linkLabel];
    
    return noDataContentView;
}

- (NSString *)getMartNM:(NSString *)number
{
    // 마트번호 (롯데마트:1, 명절롯데마트:2, GS리테일:3, crewmate:4, 홈플러스:5, hometesco:6) 이외 값 없음
    NSString *martNm = @"";
    
    switch ([number integerValue]) {
        case 1:
            martNm = @"롯데마트";
            break;
        case 2:
            martNm = @"명절롯데마트";
            break;
        case 3:
            martNm = @"GS리테일";
            break;
        case 4:
            martNm = @"crewmate";
            break;
        case 5:
            martNm = @"홈플러스";
            break;
        case 6:
            martNm = @"hometesco";
            break;
            
        default:
            break;
    }
    
    return martNm;
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
    
    NSString *noText = @"이 상품에 궁금한 점이 있으세요?\n셀러가 친절히 답변해드립니다.";
    UILabel *noTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noTextLabel.backgroundColor = [UIColor clearColor];
    noTextLabel.font = [UIFont systemFontOfSize:14];
    noTextLabel.textColor = UIColorFromRGB(0xb8b8b8);
    noTextLabel.numberOfLines = 2;
    noTextLabel.textAlignment = NSTextAlignmentCenter;
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

- (UIView *)moreButton
{
    UIView *moreContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
    
    UIButton *imageMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageMoreButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, 44)];
    [imageMoreButton setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
    [imageMoreButton addTarget:self action:@selector(touchMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [imageMoreButton setAccessibilityLabel:@"Q&A 더보기"];
    [moreContentView addSubview:imageMoreButton];
    
    NSString *moreStr = @"Q&A 더보기";
    CGSize moreStrSize = [moreStr sizeWithFont:[UIFont systemFontOfSize:15]];
    
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenBoundsWidth-(moreStrSize.width+7+13))/2, 0, moreStrSize.width, 44)];
    [moreLabel setText:moreStr];
    [moreLabel setFont:[UIFont systemFontOfSize:15]];
    [moreLabel setTextColor:UIColorFromRGB(0x283593)];
    [imageMoreButton addSubview:moreLabel];
    
    UIImageView *moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moreLabel.frame)+7, 18.5f, 13, 7)];
    [moreImageView setImage:[UIImage imageNamed:@"ic_pd_arrow_down_02.png"]];
    [imageMoreButton addSubview:moreImageView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenBoundsWidth, 1)];
    lineView.backgroundColor = UIColorFromRGB(0xededed);
    [moreContentView addSubview:lineView];
    
    return moreContentView;
}

- (void)touchMoreButton:(id)sender
{
    [self validateMorePage:[NSIndexPath indexPathForRow:[_tableDataArray count]-1 inSection:0]];
    
    //더보기버튼 없애기
    existMoreButton = NO;
    
    //AccessLog - Q&A 더보기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPM04"];
}

- (void)parseQnaObject:(NSDictionary *)dict moreYn:(BOOL)isMore
{
    NSMutableArray *array = [dict[@"qna"][@"list"] mutableCopy];
    
    if (!array || [array count] == 0)
    {
        if (!isMore)
        {
//            [self showErrorPage];
            
            _isNextPage = NO;
            _tableDataArray = [[NSMutableArray alloc] initWithArray:[array mutableCopy]];
            
//            //Q&A의 경우 첫번째 탭에 대한 데이터 가공이 필요하다.
//            NSMutableDictionary *firstDict = [NSMutableDictionary dictionary];
//            [firstDict setObject:@"button" forKey:@"cellType"];
//            [_tableDataArray insertObject:firstDict atIndex:0];
        }
        
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        return;
    }
    
    _isNextPage = [dict[@"qna"][@"nextYn"] isEqualToString:@"Y"];
    _pageNumStr = dict[@"qna"][@"pageNumStr"];
    _nextApiUrl = dict[@"qna"][@"nexApiUrl"];
    
    //1. Q&A의 경우 첫번째 탑을 보여주기위해 각 셀마다 타입을 추가한다.
    //2. Q&A의 경우 열리고 닫히는 UI가 있기때문에 Open여부를 추가한다.
    for (NSInteger i=0; i<[array count]; i++)
    {
        NSMutableDictionary *item = [array[i] mutableCopy];
        
        if (item)
        {
            [item setValue:@"list" forKey:@"cellType"];
            [item setValue:@"N" forKey:@"openYn"];
            [array replaceObjectAtIndex:i withObject:item];
        }
    }
    
    if (!isMore)
    {
        if (!_tableDataArray) {
            _tableDataArray = [[NSMutableArray alloc] initWithArray:[array mutableCopy]];
        }
        else {
            [_tableDataArray addObjectsFromArray:[array mutableCopy]];
        }
        
        //Q&A의 경우 첫번째 탭에 대한 데이터 가공이 필요하다.
//        NSMutableDictionary *firstDict = [NSMutableDictionary dictionary];
//        [firstDict setObject:@"button" forKey:@"cellType"];
//        [_tableDataArray insertObject:firstDict atIndex:0];
        
        if (array.count < 30) {
            existMoreButton = NO;
        }
        
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [_tableDataArray addObjectsFromArray:[array mutableCopy]];
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - API

- (void)getQnaData:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^QnaSuccess)(NSDictionary *);
    QnaSuccess = ^(NSDictionary *QnaData) {
        
        if (QnaData && [QnaData count] > 0) {
            
            [self parseQnaObject:QnaData moreYn:[QnaData[@"qna"][@"nextYn"] isEqualToString:@"Y"]];
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^QnaFailure)(NSError *);
    QnaFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
    };
    
    //vertical bar때문에 인코딩
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:QnaSuccess
                                                         failure:QnaFailure];
    }
}

- (void)qnaDeleteApi:(NSString *)url
{
    [self startLoadingAnimation];
    
    void (^qnaDeleteSuccess)(NSDictionary *);
    qnaDeleteSuccess = ^(NSDictionary *qnaDeleteData) {
        
        if (qnaDeleteData && [qnaDeleteData count] > 0) {
            
//            [self removeQnaListItem:[NSIndexPath indexPathForRow:_currentViewType inSection:0]];
            DEFAULT_ALERT(STR_APP_TITLE, @"정상적으로 삭제 되었습니다.");
            [self reloadView];
        }
        else {
            DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해주세요.");
        }
        
        [self stopLoadingAnimation];
    };
    
    void (^qnaDeleteFailure)(NSError *);
    qnaDeleteFailure = ^(NSError *error) {
        [self stopLoadingAnimation];
        DEFAULT_ALERT(STR_APP_TITLE, @"일시적인 오류가 발생하였습니다. 잠시 후 다시 시도해주세요.");
    };
    
    if (url) {
        [[CPRESTClient sharedClient] requestProductDetailWithUrl:url
                                                         success:qnaDeleteSuccess
                                                         failure:qnaDeleteFailure];
    }
}

#pragma mark - Private Methods

- (void)reloadView
{
//    [_tableView reloadData];
//    [_tableDataArray removeAllObjects];
    [self InfoUserFeedbackTabView:0];
    [self getQnaData:_items[@"prdQna"][@"qnaApiUrl"]];
}

- (void)InfoUserFeedbackTabView:(NSInteger)selectedIdx
{
    _currentViewType = selectedIdx;
    _currentPage = 1;
    _isNextPage = NO;
    _pageNumStr = nil;
    _nextApiUrl = @"";
    _lastLoadIndex = 0;
    existMoreButton = YES;
    
    //데이터 초기화
    [_tableDataArray removeAllObjects];
}

#pragma mark - Selectors

- (void)touchWriteButton:(id)sender
{
    NSString *url = _items[@"prdQna"][@"qnaWriteLink"];
    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:_prdNo];
    
    if ([self.delegate respondsToSelector:@selector(didTouchWriteButton:)]) {
        [self.delegate didTouchWriteButton:url];
    }
    
    //AccessLog - Q&A쓰기
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPM02"];
}


#pragma mark - request Method
- (void)validateMorePage:(NSIndexPath *)indexPath
{
    if (!_tableDataArray || [_tableDataArray count] == 0) return;
    if (!_isNextPage) return;
    if (_lastLoadIndex >= indexPath.row) return;
    
    if ([_tableDataArray count]-1 == indexPath.row)
    {
        _currentPage++;
        
        _lastLoadIndex = indexPath.row;
        NSString *apiUrl = @"";
        
//        apiUrl = _items[@"prdQna"][@"qnaApiUrl"];
        if (_nextApiUrl && [[_nextApiUrl trim] length] > 0) {
            apiUrl = _nextApiUrl;
        }
        
        apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:_prdNo];
        apiUrl = [apiUrl stringByReplacingOccurrencesOfString:@"{{pageNo}}" withString:[NSString stringWithFormat:@"%ld", (long)_currentPage]];
        
        [self getQnaData:apiUrl];
    }
}

- (void)setScrollTop
{
    [_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
    [_tableView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
    [_tableView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
    [_tableView setShowsVerticalScrollIndicator:isShow];
}

#pragma mark - InfoUserFeedbackQnaQuestionCell Delegate Method
- (void)CPInfoUserFeedbackQnaQuestionCell:(NSDictionary *)dict onClickModifyButton:(NSIndexPath *)indexPath
{
    NSString *url = _tableDataArray[indexPath.row-1][@"qnaModifyLinkUrl"];
    NSString *brdInfoNo = dict[@"brdInfoNo"];

    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:_prdNo];
    url = [url stringByReplacingOccurrencesOfString:@"{{brdInfoNo}}" withString:brdInfoNo];
    
    if ([self.delegate respondsToSelector:@selector(CPProductInfoUserQnAView:openWriteQna:)]) {
        [self.delegate CPProductInfoUserQnAView:self openWriteQna:url];
    }
}

- (void)CPInfoUserFeedbackQnaQuestionCell:(NSDictionary *)dict onClickDeleteButton:(NSIndexPath *)indexPath
{
    NSString *url = _tableDataArray[indexPath.row-1][@"qnaDeleteApiUrl"];
    NSString *brdInfoNo = dict[@"brdInfoNo"];

    url = [url stringByReplacingOccurrencesOfString:@"{{prdNo}}" withString:_prdNo];
    url = [url stringByReplacingOccurrencesOfString:@"{{brdInfoNo}}" withString:brdInfoNo];
    
    _currentViewType = indexPath.row;
    [self qnaDeleteApi:url];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //noDataView
    if (_tableDataArray.count == 0) {
        return 1;
    }
    
    return _tableDataArray.count+existMoreButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (_tableDataArray.count <= 0) {
        //noData
        BOOL isMart = [_items[@"martInfo"][@"isMart"] isEqualToString:@"Y"];
        return isMart?180.f:165.f;
    }
    
    //더보기버튼
    NSInteger totalRow = _tableDataArray.count+existMoreButton;
    BOOL isLastCell = indexPath.row == totalRow-1;
    
    if (isLastCell && existMoreButton) {
        return 44.f;
    }
    
    NSString *cellType = _tableDataArray[indexPath.row][@"cellType"];
        
    if ([cellType isEqualToString:@"button"])
    {
        height = 53.f;
    }
    else if ([cellType isEqualToString:@"list"])
    {
        height = 66.f;
    }
    else if ([cellType isEqualToString:@"question"])
    {
        //최소 높이 : 아이콘 + 상하단 마진
        CGFloat minHeight = 18.f+16.f+16.f;
        
        //상단마진
        height += 16.f;
        
        //텍스트 높이
        CGFloat textWidth = tableView.frame.size.width - 51.f;
        NSString *text = _tableDataArray[indexPath.row][@"text"];
        
        height += [Modules getLabelHeightWithText:text
                                            frame:CGRectMake(0, 0, textWidth, 0)
                                             font:[UIFont systemFontOfSize:13.f]
                                            lines:100
                                    textAlignment:NSTextAlignmentLeft];
        
        NSString *mineYn = _tableDataArray[indexPath.row][@"mineYn"];
        if ([mineYn isEqualToString:@"Y"])
        {
//            //상단마진 + 아이콘 이미지 높이 + 10.f
//            if (height+10.f < 16.f+18.f+10.f)
//            {
//                height = 14.f+31.f+10.f+27.f;
//            }
//            else
//            {
//                height += (10.f + 27.f);
//            }
            
            if (!(_tableDataArray.count > indexPath.row+1 && [_tableDataArray[indexPath.row+1][@"cellType"] isEqualToString:@"answer"])) {
                height += 25.f;
            }
        }
        
        //하단마진
        height += 16.f;
        
        if (height < minHeight) height = minHeight;
    }
    else if ([cellType isEqualToString:@"answer"])
    {
        //최소 높이 : 아이콘 + 상하단 마진
        CGFloat minHeight = 18.f+16.f+20.f;
        
        //상단마진
        height += 16.f;
        
        //텍스트 높이
        CGFloat textWidth = tableView.frame.size.width - 51.f;
        NSString *text = _tableDataArray[indexPath.row][@"text"];
        
        height += [Modules getLabelHeightWithText:text
                                            frame:CGRectMake(0, 0, textWidth, 0)
                                             font:[UIFont systemFontOfSize:13.f]
                                            lines:100
                                    textAlignment:NSTextAlignmentLeft];
        
        //하단마진
        height += 20.f;
        
        if (height < minHeight) height = minHeight;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (_tableDataArray.count < 1) {
        NSString *identifier = @"qnaNoDataTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        BOOL isMart = [_items[@"martInfo"][@"isMart"] isEqualToString:@"Y"];
        [cell addSubview:isMart?[self noDataMartView:180.f]:[self noDataView:165.f]];
        return cell;
    }
    
    
    NSInteger totalRow = _tableDataArray.count+existMoreButton;
    BOOL isLastCell = indexPath.row == totalRow-1;
    
    if (isLastCell && existMoreButton) {
        NSString *identifier = @"moreViewCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //더보기 버튼
        [cell addSubview:[self moreButton]];
        return cell;
    }
    else {
        cell = [self makeQnaTableViewCell:tableView indexPath:indexPath];
        if (!existMoreButton) {
            [self validateMorePage:indexPath];
        }
    }
    
    return cell;
}

- (UITableViewCell *)makeQnaTableViewCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = _tableDataArray[indexPath.row][@"cellType"];
    
    if ([cellType isEqualToString:@"button"])
    {
        //버튼 셀
        NSString *identifier = @"qnaButtonTableViewCell";
        CPInfoUserFeedbackQnaButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            cell = [[CPInfoUserFeedbackQnaButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        cell.delegate = self;
        
        return cell;
    }
    else if ([cellType isEqualToString:@"list"])
    {
        //리스트 셀
        NSString *identifier = @"qnaListTableViewCell";
        CPInfoUserFeedbackQnaListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            cell = [[CPInfoUserFeedbackQnaListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        cell.dict = [_tableDataArray objectAtIndex:indexPath.row];
        
        if (!existMoreButton) {
            [self validateMorePage:indexPath];
        }
            
        return cell;
    }
    else if ([cellType isEqualToString:@"question"])
    {
        //Question 셀
        NSString *identifier = @"qnaQuestionTableViewCell";
        CPInfoUserFeedbackQnaQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            cell = [[CPInfoUserFeedbackQnaQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        BOOL existAnswer = NO;
        if (_tableDataArray.count > indexPath.row+1 && [_tableDataArray[indexPath.row+1][@"cellType"] isEqualToString:@"answer"]) {
            existAnswer = YES;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        cell.dict = [_tableDataArray objectAtIndex:indexPath.row];
        cell.existAnswer = existAnswer;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        return cell;
    }
    else if ([cellType isEqualToString:@"answer"])
    {
        //Answer 셀
        NSString *identifier = @"qnaAnswerTableViewCell";
        CPInfoUserFeedbackQnaAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            cell = [[CPInfoUserFeedbackQnaAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        cell.dict = [_tableDataArray objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //AccessLog - Q&A클릭
    [[AccessLog sharedInstance] sendAccessLogWithCode:@"NAIDPM03"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    if ([_tableDataArray count] <= indexPath.row) return;
    
    NSString *cellType = _tableDataArray[indexPath.row][@"cellType"];
    
    if ([cellType isEqualToString:@"errorPage"]) return;
    
    cellType = _tableDataArray[indexPath.row][@"cellType"];
    
    if ([cellType isEqualToString:@"list"])
    {
        NSString *openYn = _tableDataArray[indexPath.row][@"openYn"];
        
        if ([openYn isEqualToString:@"N"])	[self addQnaChildList:indexPath];
        else								[self removeQnaChildList:indexPath];
    }
}

- (void)addQnaChildList:(NSIndexPath *)indexPath
{
    NSString *secretYn = _tableDataArray[indexPath.row][@"secretYn"];
    NSString *mineYn = _tableDataArray[indexPath.row][@"mineYn"];
    
    if ([secretYn isEqualToString:@"Y"] && [mineYn isEqualToString:@"N"]) return;
    
    BOOL isQuestion = NO;
    BOOL isAnswer = NO;
    
    NSString *questionStr = _tableDataArray[indexPath.row][@"brdInfoCont"];
    NSString *answerStr = _tableDataArray[indexPath.row][@"AnswerCont"];
    
    if (!([questionStr isEqual:[NSNull null]] || [questionStr length] == 0))
    {
        NSString *brdInfoNo = _tableDataArray[indexPath.row][@"brdInfoNo"];
        NSMutableDictionary *questionDict = [NSMutableDictionary dictionary];
        
        [questionDict setValue:@"question" forKey:@"cellType"];
        [questionDict setValue:questionStr forKey:@"text"];
        [questionDict setValue:brdInfoNo forKey:@"brdInfoNo"];
        [questionDict setValue:mineYn forKey:@"mineYn"];
        
        [_tableDataArray insertObject:questionDict atIndex:indexPath.row+1];
        
        isQuestion = YES;
    }
    
    if (!([answerStr isEqual:[NSNull null]] || [answerStr length] == 0))
    {
        NSString *brdInfoNo = _tableDataArray[indexPath.row][@"brdInfoNo"];
        NSMutableDictionary *answerDict = [NSMutableDictionary dictionary];
        
        [answerDict setValue:@"answer" forKey:@"cellType"];
        [answerDict setValue:answerStr forKey:@"text"];
        [answerDict setValue:brdInfoNo forKey:@"brdInfoNo"];
        
        [_tableDataArray insertObject:answerDict atIndex:indexPath.row+2];
        
        isAnswer = YES;
    }
    
    //둘다 없으면 리턴!
    if (!isAnswer && !isQuestion) return;
    
    //상태값을 변경한다.
    [_tableDataArray[indexPath.row] setValue:@"Y" forKey:@"openYn"];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    [_tableView beginUpdates];
    if (isQuestion)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
    if (isAnswer)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
    [_tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
    [_tableView endUpdates];
}

- (void)removeQnaChildList:(NSIndexPath *)indexPath
{
    BOOL isQuestion = NO;
    BOOL isAnswer = NO;
    
    NSString *questionStr = _tableDataArray[indexPath.row][@"brdInfoCont"];
    NSString *answerStr = _tableDataArray[indexPath.row][@"AnswerCont"];
    
    if (!([questionStr isEqual:[NSNull null]] || [questionStr length] == 0))	isQuestion = YES;
    if (!([answerStr isEqual:[NSNull null]] || [answerStr length] == 0))		isAnswer = YES;
    
    //둘다 없으면 리턴!
    if (!isAnswer && !isQuestion) return;
    
    //상태값을 변경한다.
    [_tableDataArray[indexPath.row] setValue:@"N" forKey:@"openYn"];
    
    if (isAnswer)	[_tableDataArray removeObjectAtIndex:indexPath.row+2];
    if (isQuestion)	[_tableDataArray removeObjectAtIndex:indexPath.row+1];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    [_tableView beginUpdates];
    if (isQuestion)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
    if (isAnswer)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
    [_tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
    [_tableView endUpdates];
}

- (void)removeQnaListItem:(NSIndexPath *)indexPath
{
    BOOL isQuestion = NO;
    BOOL isAnswer = NO;
    
    NSString *questionStr = _tableDataArray[indexPath.row-1][@"brdInfoCont"];
    NSString *answerStr = _tableDataArray[indexPath.row-1][@"AnswerCont"];
    
    if (!([questionStr isEqual:[NSNull null]] || [questionStr length] == 0))	isQuestion = YES;
    if (!([answerStr isEqual:[NSNull null]] || [answerStr length] == 0))		isAnswer = YES;
    
    if (isAnswer)	[_tableDataArray removeObjectAtIndex:indexPath.row+1];	//답변
    if (isQuestion)	[_tableDataArray removeObjectAtIndex:indexPath.row]; //퀘스천
    [_tableDataArray removeObjectAtIndex:indexPath.row-1];	//제목
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    [_tableView beginUpdates];
    [indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
    if (isQuestion)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    if (isAnswer)	[indexPathArray addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
    [_tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationMiddle];
    [_tableView endUpdates];
}

#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    [self.delegate productInfoUserQnAView:self scrollViewDidScroll:scrollView];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    // '080-850-2332~3' 같은 경우 ~뒤는 제거
    if ([phoneNumber rangeOfString:@"~"].location != NSNotFound) {
        NSArray *numberArray = [phoneNumber componentsSeparatedByString:@"~"];
        phoneNumber = numberArray[0];
    }
    
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *phoneNumUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]];
    
    if([[UIApplication sharedApplication] canOpenURL:phoneNumUrl])
    {
        [[UIApplication sharedApplication] openURL:phoneNumUrl];
    }
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
