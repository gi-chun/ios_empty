#import <UIKit/UIKit.h>
#import "CPWebView.h"

@protocol CPProductOptionDelegate;

@interface CPProductOption : UIView

@property (nonatomic, weak)		id<CPProductOptionDelegate> delegate;
@property (nonatomic, strong)	CPWebView *executeWebView;
@property (nonatomic, strong)	NSDictionary *productOptionRawData;
@property (nonatomic, assign)	BOOL isPopupBrowser;

- (id)initWithToolbarView:(UIView *)toolbarView parentView:(UIView *)parentView;
- (void)setGuideView:(UIImageView *)guideView;
- (void)closeDrawer;
@end


@protocol CPProductOptionDelegate <NSObject>
@optional
- (void)productOptionOnClickPurchasesItem;
@end