#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomReviewItemDelegate;

@interface CPDescriptionBottomReviewItem : UIView

@property (nonatomic, weak) id <CPDescriptionBottomReviewItemDelegate> delegate;
- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item url:(NSString *)url prdNo:(NSString *)prdNo lastItem:(BOOL)lastItem isInTab:(BOOL)isInTab;

@end

@protocol CPDescriptionBottomReviewItemDelegate <NSObject>
@optional
- (void)CPDescriptionBottomReviewItem:(CPDescriptionBottomReviewItem *)item moveUrl:(NSString *)url;
- (void)didTouchReviewCell:(NSString *)url;

@end
