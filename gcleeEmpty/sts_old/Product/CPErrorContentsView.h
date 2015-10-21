#import <UIKit/UIKit.h>

@protocol CPErrorContentsViewDelegate;

@interface CPErrorContentsView : UIView

@property (nonatomic, weak) id <CPErrorContentsViewDelegate> delegate;
@property (nonatomic, assign) BOOL isRetryButton;
@property (nonatomic, strong) NSString *errorText;
@property (nonatomic, strong) NSString *errorIcon;

@end

@protocol CPErrorContentsViewDelegate <NSObject>
@optional
- (void)CPErrorContentsView:(CPErrorContentsView *)view didClickedRefreshButton:(id)sender;
@end
