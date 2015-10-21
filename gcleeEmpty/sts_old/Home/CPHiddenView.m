//
//  CPHiddenView.m
//  11st
//
//  Created by saintsd on 2015. 6. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "HttpRequest.h"
#import "CPHiddenView.h"
#import "CPLoadingView.h"
#import "CPErrorView.h"
#import "CPRESTClient.h"
#import "CPFooterView.h"
#import "CPFooterView.h"
#import "CPFooterButtonView.h"
#import "PullToRefreshView.h"
#import "SDWebImageManager.h"
#import "AccessLog.h"
#import "CPSchemeManager.h"
#import "CPCommonInfo.h"
#import "CPHomeViewController.h"

@interface CPHiddenView () <CPErrorViewDelegate,
							UITableViewDataSource,
							UITableViewDelegate,
							CPFooterViewDelegate,
							PullToRefreshViewDelegate,
							CPHiddenViewCellDelegate>
{
	//로딩뷰
	CPLoadingView *_loadingView;
	
	//히든탭 정보
	NSDictionary *_hiddenDic;
	
	//컨텐츠 뷰
	UITableView *_tableView;
	UIButton *_topScrollButton;
	
	//에러뷰
	CPErrorView *_errorView;
	
	//보여줄 이미지
	UIImage *_imageItem;
	CGSize _imageSize;
	
	//히든탭 linkUrl
	NSString *_linkUrl;
}

@end

@implementation CPHiddenView

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
		_hiddenDic = [info copy];
		
		//히든은 0.5초후 통신하도록 한다.
		[self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];

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

- (void)goToTopScroll
{
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - HttpRequest

- (void)requestItems:(NSNumber *)ignoreCache
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestItems:) object:@YES];
    
	if (!_hiddenDic || !_hiddenDic[@"url"]) {
		[self showErrorView];
		return;
	}
	
	[self startLoadingAnimation];
	
	void (^requestSuccess)(NSDictionary *);
	requestSuccess = ^(NSDictionary *requestData) {
		
        //GNB 키워드광고를 셋팅한다.
        if ([ignoreCache boolValue]) {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CPHomeViewController *homeViewController = app.homeViewController;
            if (homeViewController && [homeViewController respondsToSelector:@selector(setGnbSearchKeyword)]) {
                [homeViewController setGnbSearchKeyword];
            }
        }
        
		if (200 == [requestData[@"resultCode"] integerValue] && requestData[@"data"])
		{
			_linkUrl = [[NSString alloc] initWithString:requestData[@"data"][0][@"hiddenBanner"][@"dispObjLnkUrl"]];
			[self requestDownloadImage:requestData[@"data"][0][@"hiddenBanner"][@"lnkBnnrImgUrl"]];
		}
		else
		{
            [self reloadDataWithError:[ignoreCache boolValue]];
            return;
		}
	};
	
	void (^requestFailure)(NSError *);
	requestFailure = ^(NSError *failureData) {
        [self reloadDataWithError:[ignoreCache boolValue]];
        return;
	};
	
	NSString *url = [[Modules urlWithQueryString:_hiddenDic[@"url"]] stringByAppendingFormat:@"&requestTime=%@",
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

- (void)requestDownloadImage:(NSString *)imageUrl
{
	if (!imageUrl || [[imageUrl trim] length] <= 0) {
		[self showErrorView];
		[self stopLoadingAnimation];
		return;
	}
	
	[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl]
		options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
			
		} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
			
			if (finished && image) {
				_imageItem = image;

				//이미지 비율 계산
				CGSize imageSize = image.size;
				CGFloat viewWidth = self.frame.size.width;
				CGFloat ratio = imageSize.width / viewWidth;
				CGFloat height = imageSize.height / ratio;
				
				_imageSize.width = viewWidth;
				_imageSize.height = height;
				
				[self showContents];
				[self stopLoadingAnimation];
			}
			else {
				[self showErrorView];
				[self stopLoadingAnimation];
			}
		}];
}

#pragma mark - Table View
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

	PullToRefreshView *pullToRefreshView = [[PullToRefreshView alloc] initWithScrollView:_tableView];
	[pullToRefreshView setDelegate:self];
	[_tableView addSubview:pullToRefreshView];

	CPFooterView *fView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:YES];
	[fView setFrame:CGRectMake(0, 20, fView.width, fView.height)];
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

#pragma TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"hiddenTabCell";
	
	CPHiddenViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	
	if (!cell) {
		cell = [[CPHiddenViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
	}
	
	cell.frame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.delegate = self;

	if (_imageItem)
	{
		cell.image = _imageItem;
		cell.imageSize = _imageSize;
	}
	
	cell.linkUrl = _linkUrl;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return _imageSize.height;
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
	if (_hiddenDic) {
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

#pragma mark - top button
- (void)onTouchTopScroll
{
	[self onTouchTopScroll:YES];
}

- (void)onTouchTopScroll:(BOOL)animation
{
	[_tableView setContentOffset:CGPointZero animated:animation];
}

#pragma mark - PullToRefreshViewDelegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self performSelectorInBackground:@selector(requestItems:) withObject:@YES];
}

//footer login 후 데이터 갱신
- (void)reloadAfterLogin
{
	[self reloadData];
}

#pragma mark - CPHiddenViewCell Delegate Method
- (void)CPHiddenViewCell:(CPHiddenViewCell *)cell moveUrl:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[self.delegate didTouchButtonWithUrl:url];
		}
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


#pragma CPHiddenViewCell
@interface CPHiddenViewCell ()
{
	UIImageView *_imageView;
	UIView *_selectedView;
}

@end

@implementation CPHiddenViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:_imageView];
	
	_selectedView = [[UIView alloc] initWithFrame:CGRectZero];
	_selectedView.backgroundColor = UIColorFromRGBA(0x000000, 0.3f);
	[self.contentView addSubview:_selectedView];
	
	[_selectedView setHidden:YES];
}

- (void)layoutSubviews {
	
	[self.contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.imageSize.height)];
	
	[_imageView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.imageSize.height)];
	if (self.image) [_imageView setImage:self.image];
	
	_selectedView.frame = _imageView.frame;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	[self setTouchView:YES];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	[self setTouchView:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	[self setTouchView:NO];
	
	if (self.linkUrl && [[self.linkUrl trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(CPHiddenViewCell:moveUrl:)]) {
			[self.delegate CPHiddenViewCell:self moveUrl:self.linkUrl];
		}
		
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAG0100"];
	}
}

- (void)setTouchView:(BOOL)isTouch
{
	if (isTouch)	_selectedView.hidden = NO;
	else			_selectedView.hidden = YES;
}

@end




