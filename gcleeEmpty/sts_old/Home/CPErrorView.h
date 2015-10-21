//
//  CPErrorView.h
//  11st
//
//  Created by spearhead on 2014. 10. 29..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPErrorViewDelegate;

@interface CPErrorView : UIView

@property (nonatomic, weak) id<CPErrorViewDelegate> delegate;

@end

@protocol CPErrorViewDelegate <NSObject>
@optional
- (void)didTouchRetryButton;

@end