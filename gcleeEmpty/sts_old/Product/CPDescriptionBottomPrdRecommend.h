#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomPrdRecommendDelegate;

@interface CPDescriptionBottomPrdRecommend : UIView

@property (nonatomic, weak) id <CPDescriptionBottomPrdRecommendDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item title:(NSString *)aTitle;

@end

@protocol CPDescriptionBottomPrdRecommendDelegate <NSObject>
@optional
- (void)didTouchSellerPrd:(NSString *)prdNo;

@end
