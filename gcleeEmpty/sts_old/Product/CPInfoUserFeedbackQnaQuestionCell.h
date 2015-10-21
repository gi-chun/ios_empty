#import <UIKit/UIKit.h>

@protocol CPInfoUserFeedbackQnaQuestionCellDelegate;

@interface CPInfoUserFeedbackQnaQuestionCell : UITableViewCell

@property (nonatomic, weak) id <CPInfoUserFeedbackQnaQuestionCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property BOOL existAnswer;

@end


@protocol CPInfoUserFeedbackQnaQuestionCellDelegate <NSObject>
@optional
- (void)CPInfoUserFeedbackQnaQuestionCell:(NSDictionary *)dict onClickModifyButton:(NSIndexPath *)indexPath;
- (void)CPInfoUserFeedbackQnaQuestionCell:(NSDictionary *)dict onClickDeleteButton:(NSIndexPath *)indexPath;
@end