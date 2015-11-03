//
//  CPIndicatorView.h
//

#import <UIKit/UIKit.h>

@interface CPIndicatorView : UIView

@property (nonatomic, assign) BOOL hidesWhenStopped;

- (void)startAnimating;
- (void)stopAnimating;

@end