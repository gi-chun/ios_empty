#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomPrdInfoLinkDelegate;

@interface CPDescriptionBottomPrdInfoLink : UIView

@property (nonatomic, weak) id <CPDescriptionBottomPrdInfoLinkDelegate> delegate;

- (id)initWithFrame:(CGRect)frame prdSelInfoUrl:(NSString *)aPrdSelInfoUrl prdInfoNoticeUrl:(NSString *)aPrdInfoNoticeUrl;

@end

@protocol CPDescriptionBottomPrdInfoLinkDelegate <NSObject>
@optional
- (void)didTouchPrdSelInfo:(NSString *)url;
- (void)didTouchProInfoNotice:(NSString *)url;

@end
