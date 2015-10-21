#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomCategoryPopularDelegate;

@interface CPDescriptionBottomCategoryPopular : UIView

@property (nonatomic, weak) id <CPDescriptionBottomCategoryPopularDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item morePrdUrl:(NSString *)morePrdUrl;

@end

@protocol CPDescriptionBottomCategoryPopularDelegate <NSObject>
@optional
- (void)didTouchSellerPrd:(NSString *)prdNo;
- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type;
- (void)didTouchCategoryArea:(NSString *)url;

@end
