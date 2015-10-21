//
//  CPVideoReviewViewController.m
//  11st
//
//  Created by spearhead on 2015. 1. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPVideoReviewViewController.h"
#import "CPVideoCaptureManager.h"
#import "CPVideoUtility.h"
#import "CPVideoRecorder.h"
#import "CPVideoCompositionItem.h"
#import "CPVideoPredefined.h"
#import "CPCoverImageViewController.h"
#import <AVFoundation/AVFoundation.h>

#define videoMinimumClipDuration        5.0f

@interface CPVideoReviewViewController () <CPVideoCaptureManagerDelegate,
                                           CPCoverImageViewControllerDelegate>
{
    UIView *topMenuView;
    UIButton *micButton;
    UIButton *flashButton;
    UIButton *cameraRotateButton;
    
    UIView *videoPreviewView;
    UIView *progressContainerView;
    UIProgressView *progressView;
    UILabel *durationLabel;
    
    UIView *shootingView;
    UIButton *cameraButton;
    UIButton *nextButton;
    UIButton *retryButton;
    UIImageView *tooltipImageView;
 
    NSTimeInterval recordingStartTimeInterval;
    BOOL isRecording;
    BOOL isFinishedRecording;
    
    NSTimer *captureTimer;
    CGFloat duration;
}

@end

@implementation CPVideoReviewViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        duration = 0;
        isRecording = NO;
        self.torchMode = AVCaptureTorchModeOff;

        self.temporaryDirectoryPath = [CPVideoUtility createTemporaryDirectory];
        
        self.recordURLList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:UIColorFromRGB(0x2f3035)];
    
    //탑 메뉴
    [self loadTopMenuView];
    
    //하단 메뉴
    [self loadShootingMenuView];
    
    //start video capture 
    [self startCaptureVideo];
}

- (void)loadShootingMenuView
{
//    shootingView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(progressView.frame), kScreenBoundsWidth, kScreenBoundsHeight-CGRectGetMaxY(progressView.frame))];
    shootingView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topMenuView.frame), kScreenBoundsWidth, kScreenBoundsHeight-CGRectGetHeight(topMenuView.frame))];
    [shootingView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:shootingView];
    
    videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kScreenBoundsWidth)];
    [videoPreviewView setBackgroundColor:UIColorFromRGB(0x000000)];
    [shootingView addSubview:videoPreviewView];
    
    progressContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(videoPreviewView.frame), kScreenBoundsWidth, 45)];
    [progressContainerView setBackgroundColor:UIColorFromRGB(0x212225)];
    [shootingView addSubview:progressContainerView];
    
    durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 20, 45)];
    [durationLabel setFont:[UIFont systemFontOfSize:12]];
    [durationLabel setTextColor:UIColorFromRGB(0xffffff)];
    [durationLabel setText:@"0"];
    [durationLabel setTextAlignment:NSTextAlignmentCenter];
    [durationLabel setBackgroundColor:[UIColor clearColor]];
    [progressContainerView addSubview:durationLabel];
    
    UIView *progressBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(30, 21, kScreenBoundsWidth-60, 3)];
    [progressBackgroundView setBackgroundColor:UIColorFromRGB(0x505050)];
    [progressContainerView addSubview:progressBackgroundView];
    
    UIView *minProgressBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(30, 21, CGRectGetWidth(progressBackgroundView.frame)/6, 3)];
    [minProgressBackgroundView setBackgroundColor:UIColorFromRGB(0x6a6a6a)];
    [progressContainerView addSubview:minProgressBackgroundView];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [progressView setFrame:CGRectMake(30, 21, kScreenBoundsWidth-60, 20)];
    [progressView setProgressTintColor:UIColorFromRGB(0xffffff)];
//    [progressView setTrackTintColor:UIColorFromRGB(0x505050)];
//    [progressView setTrackImage:[UIImage imageNamed:@"video_timeline.png"]];
    [progressContainerView addSubview:progressView];
    
    UILabel *maxDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(progressView.frame)+5, 0, 20, 45)];
    [maxDurationLabel setFont:[UIFont systemFontOfSize:12]];
    [maxDurationLabel setTextColor:UIColorFromRGB(0xffffff)];
    [maxDurationLabel setText:@"30"];
    [maxDurationLabel setTextAlignment:NSTextAlignmentCenter];
    [maxDurationLabel setBackgroundColor:[UIColor clearColor]];
    [progressContainerView addSubview:maxDurationLabel];
    
    UIView *bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(progressContainerView.frame), kScreenBoundsWidth, CGRectGetHeight(shootingView.frame)-CGRectGetMaxY(progressContainerView.frame))];
    [bottomMenuView setBackgroundColor:[UIColor clearColor]];
    [shootingView addSubview:bottomMenuView];
    
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(kScreenBoundsWidth/2-32, CGRectGetHeight(bottomMenuView.frame)/2-32, 64, 64)];
    [cameraButton setImage:[UIImage imageNamed:@"video_shooting_default.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"video_shooting_press.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(touchEndCameraButton) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton addTarget:self action:@selector(touchCameraButton) forControlEvents:UIControlEventTouchDown];
    [bottomMenuView addSubview:cameraButton];
    
    retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryButton setFrame:CGRectMake(CGRectGetMinX(cameraButton.frame)-(23+55), CGRectGetHeight(bottomMenuView.frame)/2-35, 55, 70)];
    [retryButton setImage:[UIImage imageNamed:@"video_refresh.png"] forState:UIControlStateNormal];
    [retryButton setImage:[UIImage imageNamed:@"video_refresh_press.png"] forState:UIControlStateHighlighted];
    [retryButton addTarget:self action:@selector(touchRetryButton) forControlEvents:UIControlEventTouchUpInside];
    [retryButton setEnabled:NO];
    [bottomMenuView addSubview:retryButton];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setFrame:CGRectMake(CGRectGetMaxX(cameraButton.frame)+23, CGRectGetHeight(bottomMenuView.frame)/2-35, 55, 70)];
    [nextButton setImage:[UIImage imageNamed:@"video_next.png"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"video_next_press.png"] forState:UIControlStateHighlighted];
//    [nextButton setImage:[UIImage imageNamed:@"video_next_inactive.png"] forState:UIControlStateDisabled];
    [nextButton setEnabled:NO];
    [nextButton addTarget:self action:@selector(touchNextButton) forControlEvents:UIControlEventTouchUpInside];
    [bottomMenuView addSubview:nextButton];
    
    tooltipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenBoundsWidth/2-76, CGRectGetMinY(cameraButton.frame)-(8+37), 152, 37)];
    [tooltipImageView setImage:[UIImage imageNamed:@"video_textballoon.png"]];
    [bottomMenuView addSubview:tooltipImageView];
}

- (void)loadTopMenuView
{
    topMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 52)];
    [topMenuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topMenuView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0, 52, 52)];
    [closeButton setImage:[UIImage imageNamed:@"video_close.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [topMenuView addSubview:closeButton];
    
    micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [micButton setFrame:CGRectMake(kScreenBoundsWidth-52, 0, 52, 52)];
    [micButton setImage:[UIImage imageNamed:@"video_mic_off.png"] forState:UIControlStateNormal];
    [micButton setImage:[UIImage imageNamed:@"video_mic_on.png"] forState:UIControlStateSelected];
    [micButton addTarget:self action:@selector(touchMicButton) forControlEvents:UIControlEventTouchUpInside];
    [micButton setSelected:YES];
    [topMenuView addSubview:micButton];
   
    //볼륨 기본값
    [[CPVideoCompositionItem currentCompositionItem] setVolume:1.0f];
    
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setFrame:CGRectMake(kScreenBoundsWidth-104, 0, 52, 52)];
    [flashButton setImage:[UIImage imageNamed:@"video_flash_off.png"] forState:UIControlStateNormal];
    [flashButton setImage:[UIImage imageNamed:@"video_flash_on.png"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(touchFlashButton) forControlEvents:UIControlEventTouchUpInside];
    [flashButton setSelected:NO];
    [topMenuView addSubview:flashButton];
    
    cameraRotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraRotateButton setFrame:CGRectMake(kScreenBoundsWidth-156, 0, 52, 52)];
    [cameraRotateButton setImage:[UIImage imageNamed:@"video_selfcamera.png"] forState:UIControlStateNormal];
    [cameraRotateButton addTarget:self action:@selector(touchCameraRotateButton) forControlEvents:UIControlEventTouchUpInside];
    [topMenuView addSubview:cameraRotateButton];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    if (self.captureManager != nil && [[self.captureManager session] isRunning] == NO) {
        [self.captureManager addObservers];
        
        [[self.captureManager session] startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if (self.alertView) {
//        [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
//        self.alertView = nil;
//    }
//    
//    self.disappeared = YES;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.torchMode = [self.captureManager torchMode];
        
        if ([[self.captureManager session] isRunning]) {
            [[self.captureManager session] stopRunning];
            [self.captureManager removeObservers];
        }
    });
    
//    [self updateButtonStates];
    
    // stop blinking
    // 화면이 사라지는 경우는 녹화 중일 수 없기 때문에 무조건 블링크가 되어있는 상태.
    // 그래서 꺼줘야 한다.
//    [self.progres?sView stopBlinking];
    
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)removeVideoCaptureManager
{
    NSLog(@"removeVideoCaptureManager");
    
    if ([[self.captureManager session] isRunning]) {
        [self.captureManager.session stopRunning];
        [self.captureManager stopRecording];
    }
    
    [self.captureManager removeObservers];
    self.captureManager = nil;
    
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    self.captureVideoPreviewLayer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    [self.captureManager removeObservers];
    self.captureManager = nil;
    
    self.captureVideoPreviewLayer = nil;
}

#pragma mark - Notifications

- (void)captureSessionDidStartRunningNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)captureSessionDidStopRunningNotification:(NSNotification *)notification
{
    NSLog(@"captureSessionDidStopRunningNotification");
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)captureSessionRuntimeErrorNotification:(NSNotification *)notification
{
    NSLog(@"captureSessionRuntimeErrorNotification");
    
    NSDictionary *userInfo = notification.userInfo;
    NSError *error = (NSError *)[userInfo objectForKey:AVCaptureSessionErrorKey];
    
    NSLog(@"AVCaptureSessionErrorKey : %@", error);
    
    isRecording = NO;
    
    [self clearAll];
    
    [self startCaptureVideo];
}

- (void)captureSessionWasInterruptedNotification:(NSNotification *)notification
{
    NSLog(@"captureSessionWasInterruptedNotification");
}

- (void)captureSessionInterruptionEndedNotification:(NSNotification *)notification {
    NSLog(@"captureSessionInterruptionEndedNotification");
}

- (void)videoRecorderDidEnterBackgroundNotification:(NSNotification *)notification
{
    NSLog(@"videoRecorderDidEnterBackgroundNotification called");
    
    [self removeVideoCaptureManager];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)videoRecorderWillEnterForegroundNotification:(NSNotification *)notification {
    NSLog(@"videoRecorderWillEnterForegroundNotification called");
    
    [self removeVideoCaptureManager];
    [self startCaptureVideo];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (self.captureManager != nil && [[self.captureManager session] isRunning] == NO) {
            [self.captureManager addObservers];
            [[self.captureManager session] startRunning];
        }
    });
}

#pragma mark - AVCapture

- (void)startCaptureVideo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (!self.captureManager) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionDidStartRunningNotification:)
                                                     name:AVCaptureSessionDidStartRunningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionDidStopRunningNotification:)
                                                     name:AVCaptureSessionDidStopRunningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionRuntimeErrorNotification:)
                                                     name:AVCaptureSessionRuntimeErrorNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionWasInterruptedNotification:)
                                                     name:AVCaptureSessionWasInterruptedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionInterruptionEndedNotification:)
                                                     name:AVCaptureSessionInterruptionEndedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoRecorderDidEnterBackgroundNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoRecorderWillEnterForegroundNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        //Capture Manager
        CPVideoCaptureManager *manager = [[CPVideoCaptureManager alloc] init];
        [manager setDelegate:self];
        self.captureManager = manager;
        
        if (![self.captureManager isAvailableFlash]) {
            [flashButton setHidden:YES];
        }
        else {
            [flashButton setHidden:NO];
        }
        
        if ([self.captureManager setupSessionWithPreset:AVCaptureSessionPreset640x480]) {
            //AVCapture
//            AVCaptureSession *session = [[AVCaptureSession alloc] init];
//            session.sessionPreset = AVCaptureSessionPresetHigh;
            
//            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//            
//            NSError *error = nil;
//            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//            
//            if (!input) {
//                NSLog(@"Couldn't create video capture device");
//            }
//            [session addInput:input];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
                CALayer *viewLayer = [videoPreviewView layer];
                
                [newCaptureVideoPreviewLayer setFrame:videoPreviewView.bounds];
                [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
                [viewLayer addSublayer:newCaptureVideoPreviewLayer];
                
                self.captureVideoPreviewLayer = newCaptureVideoPreviewLayer;
                
//                [session startRunning];
            });
        }
    }
}

- (void)clearAll
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self removeVideoCaptureManager];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self removeVideoCaptureManager];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Selectors

- (void)touchCloseButton
{
    if (isRecording) {
        return;
    }
    
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0 && [self.recordURLList count] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertTitle", nil)
                                                            message:NSLocalizedString(@"VideoReviewEditCancel", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
        
        [alertView setTag:100];
        [alertView show];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)touchMicButton
{
    if (isRecording) {
        return;
    }
    
    [micButton setSelected:![micButton isSelected]];
    
    if ([micButton isSelected]) {
        [[CPVideoCompositionItem currentCompositionItem] setVolume:1.0f];
    }
    else {
        [[CPVideoCompositionItem currentCompositionItem] setVolume:0.0f];
    }
}

- (void)touchFlashButton
{
    if (isRecording) {
        return;
    }
    
    AVCaptureTorchMode torchMode = AVCaptureTorchModeOff;
    
    switch ([self.captureManager torchMode]) {
        case AVCaptureTorchModeOff:
            torchMode = AVCaptureTorchModeOn;
            break;
        case AVCaptureTorchModeOn:
            torchMode = AVCaptureTorchModeOff;
            break;
        default:
            break;
    }
    
    [self.captureManager setTorchMode:torchMode];
    self.torchMode = torchMode;
    
    [flashButton setSelected:![flashButton isSelected]];
}

- (void)touchCameraRotateButton
{
    if (isRecording) {
        return;
    }
    
    [self.captureManager toggleCamera];
    
    // Do an initial focus
    [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    
    if ([self.captureManager devicePosition] == AVCaptureDevicePositionBack) {
        [flashButton setHidden:NO];
        [self.captureManager setTorchMode:self.torchMode];
    }
    else if ([self.captureManager devicePosition] == AVCaptureDevicePositionFront) {
        // 무조건 끈다.
        [self.captureManager setTorchMode:AVCaptureTorchModeOff];
        [flashButton setHidden:YES];
    }
    else {
        // unspecified...
        // do nothing...
    }
}

- (void)touchCameraButton
{
    NSLog(@"CACurrentMediaTime: %f, %f", CACurrentMediaTime(), recordingStartTimeInterval);
    if (isRecording) {
        NSTimeInterval delayedTimeInterval = CACurrentMediaTime() - recordingStartTimeInterval;
        
        if (delayedTimeInterval < CPVideoMinimumClipDuration) {
            // 1초보다 적으면 무시하자... 최소 1초는 찍자.
            return;
        }
        
        [self touchEndCameraButton];
        return;
    }
    
    if ([self.captureManager.recorder isRecording]) {
        // 촬영시작을 해야 하는데, captureManager 가 이미 촬영중인 경우, 무시.
        // 촬영정지를 했는데 잠시 isRecording = TRUE 인 경우가 있음 (iPad2 ...)
        return;
    }
    
    isRecording = YES;
    recordingStartTimeInterval = CACurrentMediaTime();
    [tooltipImageView setHidden:YES];
    
    if (![self.captureManager.recorder isRecording]) {
        [self timerStart];
        
        //촬영 시작전에 볼륨 조정
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        
        CGFloat gain = [[CPVideoCompositionItem currentCompositionItem] volume];
        NSLog(@"setInputGain volume:%f", gain);
        NSError* error;
        if (audioSession.isInputGainSettable) {
            BOOL success = [audioSession setInputGain:gain error:&error];
            if (!success){
                NSLog(@"error:%@", [error description]);
            } //error handling
        } else {
            NSLog(@"ios6 - cannot set input gain");
        }
        
        NSLog(@"startRecording");
        NSURL *recordURL = [[self.temporaryDirectoryPath URLByAppendingPathComponent:[CPVideoUtility timestamp]] URLByAppendingPathExtension:@"mov"];
        
        [self.captureManager startRecordingWithFileURL:recordURL];
    }
}

- (void)touchEndCameraButton
{
    NSLog(@"stopRecording");
    
    if (isRecording) {
        NSTimeInterval delayedTimeInterval = CACurrentMediaTime() - recordingStartTimeInterval;
        
        if (delayedTimeInterval < CPVideoMinimumClipDuration) {
            // 최소 1초는 찍고 종료되도록 1초 딜레이 후 촬영 종료.
            double delayInSeconds = 1.f - delayedTimeInterval;
            NSLog(@"delayInSeconds : %f", delayInSeconds);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self touchEndCameraButton];
            });
            return;
        }
    }
    
    isRecording = NO;
    
//    if (![self.captureManager.recorder isRecording] == NO) {
        [self.captureManager stopRecording];
        [self timerStop:captureTimer];
//    }
}

- (void)touchNextButton
{
    if (isRecording) {
        return;
    }
    
    if ([flashButton isSelected]) {
        [self.captureManager setTorchMode:AVCaptureTorchModeOff];
        [flashButton setSelected:NO];
    }
    
    if (![retryButton isEnabled]) {
        double delayInSeconds = 1.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"retry touchNextButton");
            [self touchNextButton];
        });
        
        return;
    }
    
    if (!isFinishedRecording) {
        double delayInSeconds = 1.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"not finished recording");
            [self touchNextButton];
        });
        
        return;
    }
    
//    // 이 때부터 파일 encoding 작업을 시작한다.
//    [[CPVideoCompositionItem currentCompositionItem] startEncoding];
    
    CPCoverImageViewController *viewController = [[CPCoverImageViewController alloc] init];
    [viewController setDelegate:self];
    [self presentViewController:viewController animated:NO completion:nil];
}

- (void)touchRetryButton
{
    if (isRecording) {
        return;
    }
    
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0 && [self.recordURLList count] > 0) {
        
        [[CPVideoCompositionItem currentCompositionItem].clips removeAllObjects];
        [self.recordURLList removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            duration = 0;
            [durationLabel setText:[NSString stringWithFormat:@"%i", (int)duration]];
            [progressView setProgress:duration/30 animated:YES];
            [self timerStop:captureTimer];
            
            [retryButton setEnabled:NO];
            [nextButton setEnabled:NO];
            [micButton setEnabled:YES];
        });
    }
}

#pragma mark - CPVideoCaptureManagerDelegate

- (void)captureManager:(CPVideoCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    NSLog(@"captureManager:didFailWithError:");
    
    isFinishedRecording = YES;
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerRecordingBegan:(CPVideoCaptureManager *)captureManager
{
    NSLog(@"captureManagerRecordingBegan");

    isFinishedRecording = NO;
}

- (void)captureManagerRecordingFinished:(CPVideoCaptureManager *)captureManager
{
    NSLog(@"captureManagerRecordingFinished called:%@", captureManager.recorder.outputFileURL);
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [self.recordURLList addObject:captureManager.recorder.outputFileURL];
        [[CPVideoCompositionItem currentCompositionItem].clips addObject:captureManager.recorder.outputFileURL];

        // SAVE COMPOSITION INFO TO PLIST
//        [CPVideoUtility saveCurrentCompositionItems];

        isFinishedRecording = YES;
        
        if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0 && [self.recordURLList count] > 0) {
            [retryButton setEnabled:YES];
            [micButton setEnabled:NO];
        }
        else {
            [retryButton setEnabled:NO];
            [micButton setEnabled:YES];
        }
    });
}

- (void)captureManagerDeviceConfigurationChanged:(CPVideoCaptureManager *)captureManager
{
    NSLog(@"captureManagerDeviceConfigurationChanged called");
//    [self updateButtonStates];
}

#pragma mark - CPCoverImageViewControllerDelegate

- (void)didTouchCloseButton
{
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0 && [self.recordURLList count] > 0) {
        [[CPVideoCompositionItem currentCompositionItem].clips removeAllObjects];
        [self.recordURLList removeAllObjects];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTouchBackButton
{
//    [self touchRetryButton];
//    [nextButton setEnabled:NO];
}

- (void)didTouchConfirmButton
{
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0 && [self.recordURLList count] > 0) {
        
        [[CPVideoCompositionItem currentCompositionItem].clips removeAllObjects];
        [self.recordURLList removeAllObjects];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(didTouchConfirmButton)]) {
        [self.delegate didTouchConfirmButton];
    }
}

#pragma mark - Timer

-(void)timerStart
{
    captureTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                    target:self
                                                  selector:@selector(timerCount)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)timerCount
{
    duration += 0.1f;
    [durationLabel setText:[NSString stringWithFormat:@"%i", (int)duration]];
    [progressView setProgress:duration/30 animated:YES];
    
    if (duration >= 5) {
        [nextButton setEnabled:YES];
    }
    
    if (duration >= 30) {
        [self touchEndCameraButton];
        
        [self touchNextButton];
        
        [self timerStop:captureTimer];
    }
    
//    NSLog(@"timerCount:%f, %f", duration, duration/30);
}

-(void)timerStop:(NSTimer *)timer
{
    [timer invalidate];
    timer = nil;
}

@end
