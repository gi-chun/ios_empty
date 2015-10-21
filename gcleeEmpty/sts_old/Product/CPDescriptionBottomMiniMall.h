#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomMiniMallDelegate;

@interface CPDescriptionBottomMiniMall : UIView

@property (nonatomic, weak) id <CPDescriptionBottomMiniMallDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
               item:(NSDictionary *)item
            linkUrl:(NSString *)aLinkUrl
      resistLinkUrl:(NSString *)aResistLinkUrl
        helpLinkUrl:(NSString *)aHelpLinkUrl
       indiSellerYn:(NSString *)aIndiSellerYn;

@end

@protocol CPDescriptionBottomMiniMallDelegate <NSObject>
@optional
- (void)didTouchInfoButton:(NSString *)url;
- (void)didTouchSellerInfo:(NSString *)url;
- (void)didTouchShowPrdAll:(NSString *)url;
- (void)didTouchSellerPrd:(NSString *)prdNo;
- (void)didTouchMoreButton:(NSString *)moreUrl type:(CPSellerPrdListType)type;

@end
