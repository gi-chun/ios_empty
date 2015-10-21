#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomTownShopBranchDelegate;

@interface CPDescriptionBottomTownShopBranch : UIView

@property (nonatomic, weak) id <CPDescriptionBottomTownShopBranchDelegate> delegate;
//사용자가 선택한 주소의 index
@property (nonatomic, assign) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item;

- (void)openUrl:(NSString *)url;
- (void)stopLoading;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;
- (CGFloat)getListButtonY;

//지점정보 세팅
- (void)setTownShopBranchView;

@end

@protocol CPDescriptionBottomTownShopBranchDelegate <NSObject>
@optional
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view isLoading:(NSNumber *)loading;
- (void)productTownShopBranchView:(CPDescriptionBottomTownShopBranch *)view scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)didTouchExpandButton:(CPDescriptionBottomViewType)viewType height:(CGFloat)height;
- (void)didTouchMapButton:(NSString *)linkUrl;
- (void)didTouchTownShopList:(id)sender;

@end
