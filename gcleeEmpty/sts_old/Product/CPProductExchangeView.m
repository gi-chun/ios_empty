#import "CPProductExchangeView.h"
#import "CPFooterView.h"

@interface CPProductExchangeView () <UIWebViewDelegate,
                                    UIScrollViewDelegate,
                                    CPFooterViewDelegate>
{
	UIWebView *exchangeWebview;
    CPFooterView *cpFooterView;
}

@end

@implementation CPProductExchangeView

- (void)releaseItem
{
    if (exchangeWebview) [exchangeWebview stopLoading], exchangeWebview = nil;
    if (cpFooterView) cpFooterView.delegate = nil, cpFooterView = nil;
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self initLayout];
	}
	return self;
}

- (void)initLayout
{
	exchangeWebview = [[UIWebView alloc] initWithFrame:self.bounds];
	exchangeWebview.delegate = self;
	exchangeWebview.scrollView.delegate = self;
	exchangeWebview.clipsToBounds = YES;
	exchangeWebview.scalesPageToFit = NO;
	exchangeWebview.scrollView.scrollsToTop = NO;
	[self addSubview:exchangeWebview];
}

- (void)openUrl:(NSString *)url
{
	[exchangeWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)stopLoading
{
	[exchangeWebview stopLoading];
}

- (void)setScrollTop
{
	[exchangeWebview.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScrollEnabled:(BOOL)isEnable
{
	[exchangeWebview.scrollView setScrollEnabled:isEnable];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow
{
	[exchangeWebview.scrollView setShowsHorizontalScrollIndicator:isShow];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)isShow
{
	[exchangeWebview.scrollView setShowsVerticalScrollIndicator:isShow];
}


#pragma mark - UIWebViewDelegate Method

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:YES]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
    
    if (!cpFooterView) {
        
        //Footer
        cpFooterView = [[CPFooterView alloc] initWithFrame:CGRectZero hasNotice:NO];
        [cpFooterView setFrame:CGRectMake(0, 0, cpFooterView.width, cpFooterView.height)];
        [cpFooterView setDelegate:self];
        
        [webView.scrollView setContentSize:CGSizeMake(webView.scrollView.contentSize.width, webView.scrollView.contentSize.height+cpFooterView.height)];
        
        if(![cpFooterView superview])
        {
            [cpFooterView setFrame:CGRectMake(0, webView.scrollView.contentSize.height-cpFooterView.height, kScreenBoundsWidth, cpFooterView.height)];
            [webView.scrollView addSubview:cpFooterView];
            [webView.scrollView bringSubviewToFront:cpFooterView];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate productExchangeView:self isLoading:[NSNumber numberWithBool:NO]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate productExchangeView:self scrollViewDidScroll:scrollView];
}

@end
