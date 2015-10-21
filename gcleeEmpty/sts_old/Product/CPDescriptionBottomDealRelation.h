#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomDealRelationDelegate;

@interface CPDescriptionBottomDealRelation : UIView

@property (nonatomic, weak) id <CPDescriptionBottomDealRelationDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item iconImageUrl:(NSString *)aIconImageUrl title:(NSString *)aTitle;

@end

@protocol CPDescriptionBottomDealRelationDelegate <NSObject>
@optional
- (void)didTouchSellerPrd:(NSString *)prdNo;

@end
