//
//  CPVideoCaptureManager.m
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPVideoCaptureManager.h"
#import "CPVideoRecorder.h"
#import "CPVideoPredefined.h"

@interface CPVideoCaptureManager () <CPVideoRecorderDelegate>

@end

@implementation CPVideoCaptureManager

- (id)init
{
    self = [super init];
    if (self != nil) {
        __weak CPVideoCaptureManager *weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureDevice *device = [notification object];
            
            BOOL sessionHasDeviceWithMatchingMediaType = NO;
            NSString *deviceMediaType = nil;
            if ([device hasMediaType:AVMediaTypeAudio])
                deviceMediaType = AVMediaTypeAudio;
            else if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
            
            if (deviceMediaType != nil) {
                for (AVCaptureDeviceInput *input in [[weakSelf session] inputs])
                {
                    if ([[input device] hasMediaType:deviceMediaType]) {
                        sessionHasDeviceWithMatchingMediaType = YES;
                        break;
                    }
                }
                
                if (!sessionHasDeviceWithMatchingMediaType) {
                    NSError *error;
                    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    if ([[weakSelf session] canAddInput:input])
                        [[weakSelf session] addInput:input];
                }
            }
            
            if ([[weakSelf delegate] respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
                [[weakSelf delegate] captureManagerDeviceConfigurationChanged:self];
            }
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            AVCaptureDevice *device = [notification object];
            
            if ([device hasMediaType:AVMediaTypeAudio]) {
                [[weakSelf session] removeInput:[weakSelf audioInput]];
                [weakSelf setAudioInput:nil];
            }
            else if ([device hasMediaType:AVMediaTypeVideo]) {
                [[weakSelf session] removeInput:[weakSelf videoInput]];
                [weakSelf setVideoInput:nil];
            }
            
            if ([[weakSelf delegate] respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
                [[weakSelf delegate] captureManagerDeviceConfigurationChanged:self];
            }
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
        
        self.observerRegistered = YES;
    }
    
    return self;
}

#pragma mark - Session

- (BOOL)setupSession
{
    return [self setupSessionWithPreset:AVCaptureSessionPresetHigh];
}

- (BOOL)setupSessionWithPreset:(NSString *)sessionPreset {
    //	UInt32 doSetProperty = 1;
    //	AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    //	[[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    BOOL success = NO;
    
    // Set torch and flash mode to auto
//    if ([[self backFacingCamera] hasTorch]) {
//        if ([[self backFacingCamera] lockForConfiguration:nil]) {
//            if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOff]) {
//                [[self backFacingCamera] setTorchMode:AVCaptureTorchModeOff];
//            }
//            [[self backFacingCamera] unlockForConfiguration];
//        }
//    }
    
#if defined(__IPHONE_7_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)
//    if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//            AVCaptureDevice *backFacingCamera = [self backFacingCamera];
//            if (backFacingCamera != nil &&
//                [backFacingCamera respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
//                [backFacingCamera respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
//                SAFE_ARC_NSERROR error;
//                [backFacingCamera lockForConfiguration:&error];
//                if (error == nil) {
//                    [backFacingCamera setActiveVideoMinFrameDuration:CMTimeMake(1, 24)];
//                    [backFacingCamera setActiveVideoMaxFrameDuration:CMTimeMake(1, 24)];
//                    
//                    if ([backFacingCamera isSmoothAutoFocusSupported]) {
//                        backFacingCamera.smoothAutoFocusEnabled = YES;
//                        NSLog(@"backFacingCamera.smoothAutoFocusEnabled : %@", backFacingCamera.smoothAutoFocusEnabled ? @"YES" : @"NO");
//                    }
//                }
//                [backFacingCamera unlockForConfiguration];
//            }
//            
//            AVCaptureDevice *frontFacingCamera = [self frontFacingCamera];
//            if (frontFacingCamera != nil &&
//                [frontFacingCamera respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
//                [frontFacingCamera respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
//                SAFE_ARC_NSERROR error;
//                [frontFacingCamera lockForConfiguration:&error];
//                if (error == nil) {
//                    [frontFacingCamera setActiveVideoMinFrameDuration:CMTimeMake(1, 24)];
//                    [frontFacingCamera setActiveVideoMaxFrameDuration:CMTimeMake(1, 24)];
//                    
//                    if ([frontFacingCamera isSmoothAutoFocusSupported]) {
//                        frontFacingCamera.smoothAutoFocusEnabled = YES;
//                        NSLog(@"frontFacingCamera.smoothAutoFocusEnabled : %@", frontFacingCamera.smoothAutoFocusEnabled ? @"YES" : @"NO");
//                    }
//                }
//                [frontFacingCamera unlockForConfiguration];
//            }
//        }
//    }
//    else {
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//            AVCaptureDevice *backFacingCamera = [self backFacingCamera];
//            if (backFacingCamera != nil) {
//                SAFE_ARC_NSERROR error;
//                [backFacingCamera lockForConfiguration:&error];
//                if (error == nil && [backFacingCamera isSmoothAutoFocusSupported]) {
//                    backFacingCamera.smoothAutoFocusEnabled = YES;
//                    NSLog(@"backFacingCamera.smoothAutoFocusEnabled : %@", backFacingCamera.smoothAutoFocusEnabled ? @"YES" : @"NO");
//                }
//                [backFacingCamera unlockForConfiguration];
//            }
//            
//            AVCaptureDevice *frontFacingCamera = [self frontFacingCamera];
//            if (frontFacingCamera != nil) {
//                SAFE_ARC_NSERROR error;
//                [frontFacingCamera lockForConfiguration:&error];
//                if (error == nil && [frontFacingCamera isSmoothAutoFocusSupported]) {
//                    frontFacingCamera.smoothAutoFocusEnabled = YES;
//                    NSLog(@"frontFacingCamera.smoothAutoFocusEnabled : %@", frontFacingCamera.smoothAutoFocusEnabled ? @"YES" : @"NO");
//                }
//                [frontFacingCamera unlockForConfiguration];
//            }
//        }
//    }
#endif
    
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    
    // Create session (use default AVCaptureSessionPresetHigh)
    
    // ####### AVAudioSessionCategoryRecord startRunning : 평균 1.4
    // ####### AVAudioSessionCategoryPlayAndRecord startRunning : 평균 1.0
    // ####### iOS 7.0 이상에서는 AVAudioSession에 대한 설정을 AVCaptureSession 생성 전에 맞게 해야 딜레이가 발생하지 않음 (내부 메커니즘으로 인한 사운드 변경으로 딜레이 걸리는 것 예상 - usesApplicationAudioSession NO 설정 필)
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        UInt32 doSetProperty = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
    //	newCaptureSession.automaticallyConfiguresApplicationAudioSession = NO;
#if defined(__IPHONE_7_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)
    if ([newCaptureSession respondsToSelector:@selector(usesApplicationAudioSession)]) {
        newCaptureSession.usesApplicationAudioSession = NO;
    }
#endif
    
    if ([newCaptureSession canSetSessionPreset:sessionPreset]) {
        [newCaptureSession setSessionPreset:sessionPreset];
    }
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddInput:newAudioInput]) {
        [newCaptureSession addInput:newAudioInput];
    }
    
    NSLog(@"devices : %@", [AVCaptureDevice devices]);
    
    [self setVideoInput:newVideoInput];
    [self setAudioInput:newAudioInput];
    [self setSession:newCaptureSession];
    
    // Set up the movie file output
    NSURL *outputFileURL = [self tempFileURL];
    CPVideoRecorder *newRecorder = [[CPVideoRecorder alloc] initWithSession:self.session outputFileURL:outputFileURL];
    [newRecorder setDelegate:self];
    
    // Send an error to the delegate if video recording is unavailable
    if (![newRecorder recordsVideo] && [newRecorder recordsAudio]) {
        NSString *localizedDescription = NSLocalizedString(@"Video recording unavailable", @"Video recording unavailable description");
        NSString *localizedFailureReason = NSLocalizedString(@"Movies recorded on this device will only contain audio. They will be accessible through iTunes file sharing.", @"Video recording unavailable failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *noVideoError = [NSError errorWithDomain:@"OutplayVideo" code:0 userInfo:errorDict];
        if ([self.delegate respondsToSelector:@selector(captureManager:didFailWithError:)]) {
            [self.delegate captureManager:self didFailWithError:noVideoError];
        }
    }
    
    self.videoConnection = [newRecorder videoConnection];
    self.audioConnection = [newRecorder audioConnection];
    
    [self setRecorder:newRecorder];
    
    success = YES;
    
    return success;
}

#pragma mark - Recording

- (void)startRecordingWithFileURL:(NSURL *)fileURL
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until OutplayVideo returns
        // to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library
        // when OutplayVideo is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error:
        // after the recorded file has been saved.
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }
    
    [self.recorder setOutputFileURL:fileURL];
    
    [self removeFile:[self.recorder outputFileURL]];
    [self.recorder startRecordingWithOrientation:AVCaptureVideoOrientationPortrait];
}

- (void)stopRecording
{
    [self.recorder stopRecording];
}

#pragma mark - Camera Control

- (NSUInteger)cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger)micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

- (BOOL)hasTorch
{
    AVCaptureDevice *device = [[self videoInput] device];
    return [device hasTorch] && [device isTorchAvailable];
}

- (AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    return device.torchMode;
}

- (AVCaptureDevicePosition)devicePosition
{
    AVCaptureDevicePosition position = [[[self videoInput] device] position];
    return position;
}

- (BOOL)toggleCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[self.videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        }
        else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        }
        else {
            //            goto bail;
            return success;
        }
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];
            success = YES;
        } else if (error) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:self.recorder.movieFileOutput.connections];
    
    if ([self devicePosition] == AVCaptureDevicePositionFront) {
        videoConnection.videoMirrored = YES;
    }
    else {
        videoConnection.videoMirrored = NO;
    }
    
    //bail:
    return success;
}

- (BOOL)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [[self videoInput] device];
    if ([device hasTorch] && [device isTorchAvailable] && [device isTorchModeSupported:AVCaptureTorchModeOff] && [device isTorchModeSupported:AVCaptureTorchModeOn] && [device isTorchModeSupported:AVCaptureTorchModeAuto]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        } else {
            return NO;
        }
    }
    
    return YES;
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self videoInput] device];
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
}

#pragma mark - Private Methods

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *)frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *)backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (BOOL)isAvailableFlash
{
    return [[self backFacingCamera] hasFlash];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

- (NSURL *)tempFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}

- (void)removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            if ([self.delegate respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [self.delegate captureManager:self didFailWithError:error];
            }
        }
    }
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

#pragma mark - Observer

- (void)addObservers
{
    if (self.observerRegistered) {
        return;
    }
    
    __weak CPVideoCaptureManager *weakSelf = self;
    void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
        AVCaptureDevice *device = [notification object];
        
        BOOL sessionHasDeviceWithMatchingMediaType = NO;
        NSString *deviceMediaType = nil;
        if ([device hasMediaType:AVMediaTypeAudio])
            deviceMediaType = AVMediaTypeAudio;
        else if ([device hasMediaType:AVMediaTypeVideo])
            deviceMediaType = AVMediaTypeVideo;
        
        if (deviceMediaType != nil) {
            for (AVCaptureDeviceInput *input in [[weakSelf session] inputs])
            {
                if ([[input device] hasMediaType:deviceMediaType]) {
                    sessionHasDeviceWithMatchingMediaType = YES;
                    break;
                }
            }
            
            if (!sessionHasDeviceWithMatchingMediaType) {
                NSError *error;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if ([[weakSelf session] canAddInput:input])
                    [[weakSelf session] addInput:input];
            }
        }
        
        if ([[weakSelf delegate] respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
            [[weakSelf delegate] captureManagerDeviceConfigurationChanged:self];
        }
    };
    void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
        AVCaptureDevice *device = [notification object];
        
        if ([device hasMediaType:AVMediaTypeAudio]) {
            [[weakSelf session] removeInput:[weakSelf audioInput]];
            [weakSelf setAudioInput:nil];
        }
        else if ([device hasMediaType:AVMediaTypeVideo]) {
            [[weakSelf session] removeInput:[weakSelf videoInput]];
            [weakSelf setVideoInput:nil];
        }
        
        if ([[weakSelf delegate] respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
            [[weakSelf delegate] captureManagerDeviceConfigurationChanged:self];
        }
    };
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
    [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
    
    self.observerRegistered = YES;
}

- (void)removeObservers
{
    // BUG...
    // 참조 : http://stackoverflow.com/questions/7791002/avcam-memory-low-warning
    // 애플에서 만든 버그...
    
    if (self.observerRegistered == NO) {
        return;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
    //	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.observerRegistered = NO;
}

#pragma mark - CPVideoRecorderDelegate

-(void)recorderRecordingDidBegin:(CPVideoRecorder *)recorder
{
    if ([self.delegate respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
        [self.delegate captureManagerRecordingBegan:self];
    }
}

-(void)recorder:(CPVideoRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    NSLog(@"recordingDidFinishToOutputFileURL : %@", [outputFileURL absoluteString]);
    
    if (self.delegate == nil) {
        // NOTE : ios 7.1 beta2 : 레코딩 중에 카메라를 종료하는데 recordingDidFinishToOutputFileURL 가 호출됨. 이때 무시.
        return;
    }
    
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
    }
    
    if ([self.delegate respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
        [self.delegate captureManagerRecordingFinished:self];
    }
}

@end
