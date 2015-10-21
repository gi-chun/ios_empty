#import <UIKit/UIKit.h>

@protocol CPProductExchangeViewDelegate;

@interface CPProductExchangeView : UIView
@property (nonatomic, weak) id <CPProductExchangeViewDelegate> delegate;

- (void)releaseItem;
- (void)openUrl:(NSString *)url;
- (void)stopLoading;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;

@end

@protocol CPProductExchangeViewDelegate <NSObject>
@optional
- (void)productExchangeView:(CPProductExchangeView *)view isLoading:(NSNumber *)loading;
- (void)productExchangeView:(CPProductExchangeView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;
@end
