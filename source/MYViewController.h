//
//  MYViewController.h
//  MYBlurIntroductionView-Example
//
//  Created by Matthew York on 10/16/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYBlurIntroductionView.h"

@protocol MYViewControllerDelegate;

@interface MYViewController : UIViewController <MYIntroductionDelegate>

@property (nonatomic, weak) id<MYViewControllerDelegate> delegate;

@end

@protocol MYViewControllerDelegate <NSObject>
@optional
- (void)didFinishIntro;
@end

