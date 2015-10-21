#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomBrandShopDelegate;

@interface CPDescriptionBottomBrandShop : UIView

@property (nonatomic, weak) id <CPDescriptionBottomBrandShopDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item;

@end

@protocol CPDescriptionBottomBrandShopDelegate <NSObject>
@optional
- (void)didTouchBrandShop:(NSString *)linkUrl;

@end
