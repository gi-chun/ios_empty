#import <UIKit/UIKit.h>

@protocol CPPopupViewControllerDelegate;

@interface CPPopupViewController : UIViewController

@property (nonatomic, weak) id<CPPopupViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isLoginType;
@property (nonatomic, assign) BOOL isAdult;
@property (nonatomic, strong) NSString *requestUrl;

- (void)initLayout;
- (void)onClickClose:(id)sender;

@end


@protocol CPPopupViewControllerDelegate <NSObject>
@optional
- (void)popupViewControllerDidSuccessLogin;
- (void)popupViewControllerAfterSuccessLogin;
- (void)popupViewControllerCloseAndMoveUrl:(NSString *)url;
- (void)popupviewControllerOpenOtpController:(NSString *)option;
- (void)popupviewControllerMoveHome:(NSString *)option;
- (void)popupviewControllerOpenBrowser:(NSString *)option;

- (void)popupviewControllerDidAdultClosed;
- (void)popupviewControllerDidAdultSuccessLogin:(BOOL)successYn;
@end
