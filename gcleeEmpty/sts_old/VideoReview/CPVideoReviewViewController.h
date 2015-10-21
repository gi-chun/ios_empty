//
//  CPVideoReviewViewController.h
//  11st
//
//  Created by spearhead on 2015. 1. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPVideoCaptureManager;

@protocol CPVideoReviewViewControllerDelegate;

@interface CPVideoReviewViewController : UIViewController

@property (nonatomic, weak) id<CPVideoReviewViewControllerDelegate> delegate;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) CPVideoCaptureManager *captureManager;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, strong) NSURL *temporaryDirectoryPath;
@property (nonatomic, strong) NSMutableArray *recordURLList;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSArray *assets;

@property (nonatomic, assign) NSTimeInterval totalDuration;

@end

@protocol CPVideoReviewViewControllerDelegate <NSObject>
@optional

- (void)didTouchConfirmButton;

@end