//
//  CPCoverImageViewController.m
//  11st
//
//  Created by spearhead on 2015. 1. 23..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPCoverImageViewController.h"
#import "CPVideoCompositionItem.h"
#import "CPVideoUtility.h"
#import "CPVideoPredefined.h"
#import "CPLoadingView.h"

@interface CPCoverImageViewController () <CPVideoCompositionItemDelegate>
{
    UIImageView *coverImageView;
    UISlider *coverImageSlider;
    
//    CPLoadingView *loadingView;
    
    NSInteger percent;;
    UIView *loadingView;
}
@end

@implementation CPCoverImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //merge complete 상태를 호출받기 위해
    [[CPVideoCompositionItem currentCompositionItem] setDelegate:self];
    
    [self.view setBackgroundColor:UIColorFromRGB(0x2f3035)];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0, 52, 52)];
    [closeButton setImage:[UIImage imageNamed:@"video_close.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 52, kScreenBoundsWidth, kScreenBoundsWidth)];
    [coverImageView setBackgroundColor:UIColorFromRGB(0x000000)];
    [coverImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:coverImageView];
    
    self.assets = [[CPVideoCompositionItem currentCompositionItem] getAssetsFromClips];
    
    self.imageGenerator = [[CPVideoUtility sharedVideoUtility]
                           assetImageGeneratorWithRecordURLList:[CPVideoCompositionItem currentCompositionItem].clips
                           renderSize:CGSizeMake(CPVideoLandscapeHeight, CPVideoLandscapeHeight)
                           maxClipDuration:[CPVideoCompositionItem currentCompositionItem].clipMaxDuration];
    
    self.imageGenerator.maximumSize = CGSizeMake(coverImageView.frame.size.width * [UIScreen mainScreen].scale, coverImageView.frame.size.height * [UIScreen mainScreen].scale);
    
    CMTime toleranceTime = kCMTimeZero;//CMTimeMake(1, 30);
    self.imageGenerator.requestedTimeToleranceBefore = toleranceTime;//kCMTimeZero;
    self.imageGenerator.requestedTimeToleranceAfter = toleranceTime;//kCMTimeZero;
    self.imageGenerator.appliesPreferredTrackTransform = YES;

    CMTime actualTime;
    
    @try {
        CGImageRef coverImageRef = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:nil];
        coverImageView.image = [UIImage imageWithCGImage:coverImageRef];
        CGImageRelease(coverImageRef);
    }
    @catch (NSException *exception) {
        coverImageView.image = nil;
    }
    
    CMTimeShow(actualTime);
    
    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(coverImageView.frame), kScreenBoundsWidth, 45)];
    [sliderView setBackgroundColor:UIColorFromRGB(0x212225)];
    [sliderView setUserInteractionEnabled:YES];
    [self.view addSubview:sliderView];
    
    coverImageSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 10, kScreenBoundsWidth-60, 25)];
    [coverImageSlider setBackgroundColor:[UIColor clearColor]];
    [coverImageSlider addTarget:self action:@selector(changeCoverImage:) forControlEvents:UIControlEventValueChanged];
    [coverImageSlider setValue:0.0f];
    [coverImageSlider setThumbImage:[UIImage imageNamed:@"video_timeline_movingbtn.png"] forState:UIControlStateNormal];
    [coverImageSlider setThumbImage:[UIImage imageNamed:@"video_timeline_movingbtn.png"] forState:UIControlStateHighlighted];
    [sliderView addSubview:coverImageSlider];
    
    // 마지막 프레임을 얻어올 때 AVAssetImageGenerator에서 오류를 내기 때문에 (없는 시간 프레임)
    // total duration에서 마지막 프레임(frame duration)을 빼준다.
    if ([self.imageGenerator respondsToSelector:@selector(asset)]) {
        self.totalDuration = CMTimeGetSeconds(self.imageGenerator.asset.duration);
        coverImageSlider.maximumValue = self.totalDuration - (1.f / self.imageGenerator.asset.duration.timescale);
    }
    else {
        AVVideoComposition *videoComposition = self.imageGenerator.videoComposition;
        self.totalDuration = CMTimeGetSeconds([[videoComposition.instructions objectAtIndex:0] timeRange].duration);
        coverImageSlider.maximumValue = self.totalDuration - CMTimeGetSeconds(videoComposition.frameDuration);
    }
    
    UIView *bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sliderView.frame), kScreenBoundsWidth, CGRectGetHeight(self.view.frame)-CGRectGetMaxY(sliderView.frame))];
    [bottomMenuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bottomMenuView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(kScreenBoundsWidth/2-(18+55), CGRectGetHeight(bottomMenuView.frame)/2-35, 55, 70)];
    [backButton setImage:[UIImage imageNamed:@"video_cancel.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"video_cancel_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(touchBackButton) forControlEvents:UIControlEventTouchUpInside];
    [bottomMenuView addSubview:backButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setFrame:CGRectMake(kScreenBoundsWidth/2+18, CGRectGetHeight(bottomMenuView.frame)/2-35, 55, 70)];
    [confirmButton setImage:[UIImage imageNamed:@"video_complete.png"] forState:UIControlStateNormal];
    [confirmButton setImage:[UIImage imageNamed:@"video_complete_press.png"] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(touchConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    [bottomMenuView addSubview:confirmButton];
    
    UILabel *tooltipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2-76, CGRectGetMinY(backButton.frame)-(14+20), 152, 20)];
    [tooltipLabel setText:@"대표이미지 선택"];
    [tooltipLabel setFont:[UIFont systemFontOfSize:16]];
    [tooltipLabel setTextColor:UIColorFromRGB(0x71737a)];
    [tooltipLabel setTextAlignment:NSTextAlignmentCenter];
    [bottomMenuView addSubview:tooltipLabel];
    
//    //LoadingView
//    loadingView = [[CPLoadingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-40,
//                                                                  CGRectGetHeight(self.view.frame)/2-40,
//                                                                  80,
//                                                                  80)];
    
    //LoadingView
    [self initLoadingView];
}

- (void)initLoadingView
{
    UIImage *topBgImg = [UIImage imageNamed:@"photo_upload_bg.png"];
    UIImage *progressImgBg = [UIImage imageNamed:@"photo_progress_bar_bg.png"], *progressImg = [UIImage imageNamed:@"photo_progress_bar.png"];
    
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270.0f, 132.0f)];
    UIView *popupBackView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImageView *topBgImageView = [[UIImageView alloc] initWithFrame:popupView.bounds];
    UIImageView *progressBarBg = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImageView *progressBar = [[UIImageView alloc] initWithFrame:CGRectZero];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0f, 220.0f, 0)];
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    topBgImg = [topBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
    progressImgBg = [progressImgBg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9.0f, 0, 9.0f)];
    progressImg = [progressImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0f, 0, 5.0f)];
    
    loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [topBgImageView setImage:topBgImg];
    
    [label setTag:800];
    [label setNumberOfLines:0];
    [label setTextColor:UIColorFromRGB(0x555555)];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:NSLocalizedString(@"EncodingMessage", nil)];
    [label sizeToFit];
    [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, 220.0f, label.frame.size.height)];
    [label setCenter:CGPointMake(popupView.center.x, label.center.y)];
    
    [progressBar setTag:801];
    [progressBar setImage:progressImg];
    [progressBar setFrame:CGRectMake(0, 0, 50, 10.0f)];
    
    [progressBarBg setTag:802];
    [progressBarBg setImage:progressImgBg];
    [progressBarBg setFrame:CGRectMake(25.0f, label.frame.origin.y + label.frame.size.height + 10.0f, 220.0f, 10.0f)];
    [progressBarBg addSubview:progressBar];
    
    [progressLabel setTag:803];
    [progressLabel setText:@"0%"];
    [progressLabel setTextColor:UIColorFromRGB(0x555555)];
    [progressLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [progressLabel setTextAlignment:NSTextAlignmentRight];
    [progressLabel setBackgroundColor:[UIColor clearColor]];
    [progressLabel sizeToFit];
    [progressLabel setFrame:CGRectMake(progressBarBg.frame.origin.x, progressBarBg.frame.origin.y + progressBarBg.frame.size.height, progressBarBg.frame.size.width, progressLabel.frame.size.height)];
    
    [popupView setHidden:NO];
    [popupView setTag:902];
    [popupView.layer setCornerRadius:3.0f];
    [popupView setBackgroundColor:[UIColor whiteColor]];
    [popupView setCenter:loadingView.center];
    [popupView addSubview:topBgImageView];
    [popupView addSubview:label];
    [popupView addSubview:progressBarBg];
    [popupView addSubview:progressLabel];
    
    [popupBackView setAlpha:0.7f];
    [popupBackView setBackgroundColor:[UIColor blackColor]];
    [popupBackView setFrame:loadingView.frame];
    
    [loadingView addSubview:popupBackView];
    [loadingView addSubview:popupView];
    
    [self.view addSubview:loadingView];
    
    [loadingView setHidden:YES];
}

- (void)setProgress
{
    NSInteger percentage = percent++;
    
    UILabel *progressLabel = (UILabel *)[loadingView viewWithTag:803];
    UIImageView *progressBar = (UIImageView *)[loadingView viewWithTag:801];
    UIImageView *progressBarBg = (UIImageView *)[loadingView viewWithTag:802];
    
    [progressBar setFrame:CGRectMake(progressBar.frame.origin.x, progressBar.frame.origin.y, (progressBarBg.frame.size.width / 10) * percentage, progressBar.frame.size.height)];
    [progressLabel setText:[[NSString stringWithFormat:@"%li", (long)percentage*10] stringByAppendingString:@"%"]];
    
    if (percentage >= 10) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
        
        [loadingView removeFromSuperview];
        
        [CPVideoCompositionItem currentCompositionItem].coverImage = coverImageView.image;
        
        [self dismissViewControllerAnimated:NO completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(didTouchConfirmButton)]) {
            [self.delegate didTouchConfirmButton];
        }
    }
    else {
        [self performSelector:@selector(setProgress) withObject:nil afterDelay:1.0f];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            
            [self dismissViewControllerAnimated:NO completion:nil];
            
            if ([self.delegate respondsToSelector:@selector(didTouchCloseButton)]) {
                [self.delegate didTouchCloseButton];
            }
        }
    }
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
                                                        message:NSLocalizedString(@"VideoReviewEditCancel", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    
    [alertView setTag:100];
    [alertView show];
}

- (void)touchBackButton
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(didTouchBackButton)]) {
        [self.delegate didTouchBackButton];
    }
}

- (void)touchConfirmButton
{
    percent = 0;
    
    [loadingView setHidden:NO];
    
    [self performSelector:@selector(setProgress) withObject:nil];
    
    // 이 때부터 파일 encoding 작업을 시작한다.
    [[CPVideoCompositionItem currentCompositionItem] startEncoding];
    
//    if (!isMergeCompleted) {
////        [self startLoadingAnimation];
//    }
//    else {
//        [CPVideoCompositionItem currentCompositionItem].coverImage = coverImageView.image;
//        
//        [self dismissViewControllerAnimated:NO completion:nil];
//        
//        if ([self.delegate respondsToSelector:@selector(didTouchConfirmButton)]) {
//            [self.delegate didTouchConfirmButton];
//        }
//    }
}

- (void)changeCoverImage:(id)sender
{
    CMTime atTime = kCMTimeZero;
    
    if ([self.imageGenerator respondsToSelector:@selector(asset)]) {
        atTime = CMTimeMakeWithSeconds(coverImageSlider.value, self.imageGenerator.asset.duration.timescale);
    }
    else {
        atTime = CMTimeMakeWithSeconds(coverImageSlider.value, 600);
    }
    
    [self.imageGenerator cancelAllCGImageGeneration];
    
    @try {
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObjects:[NSValue valueWithCMTime:atTime], nil]
                                                  completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
         {
             if (result == AVAssetImageGeneratorSucceeded) {
//                 NSLog(@"AVAssetImageGeneratorSucceeded");
                 
                 UIImage *captureImage = [UIImage imageWithCGImage:image];
                 
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     coverImageView.image = captureImage;
                 });
             }
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception);
    }
}

#pragma mark - CPVideoCompositionItemDelegate

- (void)mergeCompleted
{
    percent = 9;
    [self performSelector:@selector(setProgress) withObject:nil afterDelay:1.0f];
//    [self stopLoadingAnimation];
}

- (void)mergeFailed
{
    UILabel *loadLabel = (UILabel *)[loadingView viewWithTag:800];
    [loadLabel setText:NSLocalizedString(@"EncodingFail", nil)];
            
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setProgress) object:nil];
    
    [loadingView removeFromSuperview];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림"
//                                                    message:@"인코딩이 실패하였습니다.\n다시 시도해 주세요."
//                                                   delegate:self
//                                          cancelButtonTitle:NSLocalizedString(@"Confirm", nil)
//                                          otherButtonTitles:nil];
//    [alert show];
}

//#pragma mark - CPLoadingView
//
//- (void)startLoadingAnimation
//{
//    [self.view addSubview:loadingView];
//    [loadingView startAnimation];
//}
//
//- (void)stopLoadingAnimation
//{
//    [loadingView stopAnimation];
//    [loadingView removeFromSuperview];
//}

@end
