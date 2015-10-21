#import <UIKit/UIKit.h>

@protocol CPDeveloperViewControllerDelegate;

@interface CPDeveloperViewController : UIViewController

@property (nonatomic, weak) id <CPDeveloperViewControllerDelegate> delegate;
@end


@protocol CPDeveloperViewControllerDelegate <NSObject>
@optional
- (void)developerViewControllerClose;
@end