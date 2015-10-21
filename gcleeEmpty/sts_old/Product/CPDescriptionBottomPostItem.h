#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomPostItemDelegate;

@interface CPDescriptionBottomPostItem : UIView

@property (nonatomic, weak) id <CPDescriptionBottomPostItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item lastItem:(BOOL)lastItem;

@end

@protocol CPDescriptionBottomPostItemDelegate <NSObject>
@optional

@end
