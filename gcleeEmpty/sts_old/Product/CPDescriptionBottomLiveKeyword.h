#import <UIKit/UIKit.h>

@protocol CPDescriptionBottomLiveKeywordDelegate;

@interface CPDescriptionBottomLiveKeyword : UIView

@property (nonatomic, weak) id <CPDescriptionBottomLiveKeywordDelegate> delegate;
@property (retain) NSTimer *timer;

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item updateTime:(NSString *)aUpdateTime;
- (void)startAutoScroll;
- (void)stopAutoScroll;

@end

@protocol CPDescriptionBottomLiveKeywordDelegate <NSObject>
@optional
- (void)didTouchExpandButton:(CPDescriptionBottomViewType)viewType height:(CGFloat)height;
- (void)didTouchSearchKeyword:(NSString *)keyword;

@end
