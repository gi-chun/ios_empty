#import <UIKit/UIKit.h>
#import "CPWebView.h"

@protocol CPPopupBrowserViewDelegate;

@interface CPPopupBrowserView : UIView

@property (nonatomic, weak) id<CPPopupBrowserViewDelegate> delegate;
@property (nonatomic, strong) CPWebView *executeWebView;

- (id)initWithFrame:(CGRect)frame popupInfo:(NSDictionary *)aPopupInfo executeWebView:(CPWebView *)webview;
- (void)removePopupBrowserView;

@end

@protocol CPPopupBrowserViewDelegate <NSObject>
@optional

- (void)popupBrowserViewOpenUrlScheme:(NSString *)urlScheme;

@end