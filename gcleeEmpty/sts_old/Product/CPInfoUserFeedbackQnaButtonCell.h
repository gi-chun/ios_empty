#import <UIKit/UIKit.h>

@protocol CPInfoUserFeedbackQnaButtonCellDelegate;

@interface CPInfoUserFeedbackQnaButtonCell : UITableViewCell

@property (nonatomic, weak) id <CPInfoUserFeedbackQnaButtonCellDelegate> delegate;

@end

@protocol CPInfoUserFeedbackQnaButtonCellDelegate <NSObject>
@optional
- (void)CPInfoUserFeedbackQnaButtonCell:(CPInfoUserFeedbackQnaButtonCell *)cell onClickQnaWriteButton:(id)sender;
@end
