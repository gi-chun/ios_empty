#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MoveTabType)
{
    MoveTabTypeNone = 0,
    MoveTabTypeReview,
    MoveTabTypePost
};

@protocol CPDescriptionBottomTitleViewDelegate;

@interface CPDescriptionBottomTitleView : UIView

@property (nonatomic, weak) id <CPDescriptionBottomTitleViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
			  title:(NSString *)titleStr
         totalCount:(NSString *)totalCount
			   type:(MoveTabType)typeIndex
			bgColor:(UIColor *)bgColor
		 titleColor:(UIColor *)titleColor
       topLineColor:(UIColor *)topLineColor
       isBottomLine:(BOOL)isBottomLine;

@end

@protocol CPDescriptionBottomTitleViewDelegate <NSObject>
@optional
- (void)CPDescriptionBottomTitleView:(CPDescriptionBottomTitleView *)item moveMorePage:(NSString *)typeStr;
- (void)didTouchTabMove:(NSInteger)pageIndex moveTab:(MoveTabType)moveTab;

@end
