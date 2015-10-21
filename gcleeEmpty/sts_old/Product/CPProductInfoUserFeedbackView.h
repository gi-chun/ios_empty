#import <UIKit/UIKit.h>
#import "CPDescriptionBottomTitleView.h"

@protocol CPProductInfoUserFeedbackViewDelegate;

@interface CPProductInfoUserFeedbackView : UIView

@property (nonatomic, weak) id <CPProductInfoUserFeedbackViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo;
- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo moveTab:(MoveTabType)aMoveTab;
- (id)initWithFrame:(CGRect)frame items:(NSDictionary *)aItems prdNo:(NSString *)aPrdNo moveTab:(MoveTabType)aMoveTab loading:(BOOL)aLoading;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;
- (void)reloadView;
- (void)touchTabView:(id)sender;

@end

@protocol CPProductInfoUserFeedbackViewDelegate <NSObject>
@optional
- (void)productInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)didTouchReviewCell:(NSString *)url;
- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab;
- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated;

//- (void)CPProductInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view isLoading:(NSNumber *)loading;
//- (void)CPProductInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)CPProductInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view openUrl:(NSString *)url;
//- (void)CPProductInfoUserFeedbackView:(CPProductInfoUserFeedbackView *)view openWriteQna:(NSString *)url;
@end
