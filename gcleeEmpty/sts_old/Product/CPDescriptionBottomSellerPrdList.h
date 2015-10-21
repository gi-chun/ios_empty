#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomSellerPrdListDelegate;

@interface CPDescriptionBottomSellerPrdList : UIView

@property (nonatomic, weak) id <CPDescriptionBottomSellerPrdListDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSArray *)item moreUrl:(NSString *)aMoreUrl type:(CPSellerPrdListType)type;

@end

@protocol CPDescriptionBottomSellerPrdListDelegate <NSObject>
@optional
- (void)didTouchSellerPrd:(NSString *)prdNo;
- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type;

@end
