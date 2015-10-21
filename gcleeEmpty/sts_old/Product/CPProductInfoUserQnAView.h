#import <UIKit/UIKit.h>

@protocol CPProductInfoUserQnAViewDelegate;

@interface CPProductInfoUserQnAView : UIView

@property (nonatomic, weak) id <CPProductInfoUserQnAViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)items prdNo:(NSString *)prdNo;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;
- (void)reloadView;

@end

@protocol CPProductInfoUserQnAViewDelegate <NSObject>
@optional
- (void)productInfoUserQnAView:(CPProductInfoUserQnAView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)didTouchWriteButton:(NSString *)url;
- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;

//- (void)CPProductInfoUserQnAView:(CPProductInfoUserQnAView *)view isLoading:(NSNumber *)loading;
//- (void)CPProductInfoUserQnAView:(CPProductInfoUserQnAView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)CPProductInfoUserQnAView:(CPProductInfoUserQnAView *)view openUrl:(NSString *)url;
- (void)CPProductInfoUserQnAView:(CPProductInfoUserQnAView *)view openWriteQna:(NSString *)url;
@end
