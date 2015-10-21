//
//  CPCoverImageViewController.h
//  11st
//
//  Created by spearhead on 2015. 1. 23..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPCoverImageViewControllerDelegate;

@interface CPCoverImageViewController : UIViewController

@property (nonatomic, weak) id<CPCoverImageViewControllerDelegate> delegate;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSArray *assets;

@property (nonatomic, assign) NSTimeInterval totalDuration;

@end

@protocol CPCoverImageViewControllerDelegate <NSObject>
@optional

- (void)didTouchCloseButton;
- (void)didTouchBackButton;
- (void)didTouchConfirmButton;

@end
