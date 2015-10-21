//
//  CPVideoCaptureManager.h
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPVideoRecorder;

@protocol CPVideoCaptureManagerDelegate;

@interface CPVideoCaptureManager : NSObject

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) CPVideoRecorder *recorder;
@property (nonatomic, assign) id deviceConnectedObserver;
@property (nonatomic, assign) id deviceDisconnectedObserver;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, weak) id <CPVideoCaptureManagerDelegate> delegate;
@property (nonatomic, assign) BOOL observerRegistered;

- (BOOL)setupSession;
- (BOOL)setupSessionWithPreset:(NSString *)sessionPreset;
//- (void)startRecording;
- (void)startRecordingWithFileURL:(NSURL *)fileURL;
- (void)stopRecording;
- (BOOL)toggleCamera;
- (BOOL)setTorchMode:(AVCaptureTorchMode)torchMode;
- (AVCaptureTorchMode)torchMode;
- (AVCaptureDevicePosition)devicePosition;
- (NSUInteger)cameraCount;
- (NSUInteger)micCount;
- (BOOL)hasTorch;
//- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
//- (void)autoFocusAtPoint:(CGPoint)point;
- (void)continuousFocusAtPoint:(CGPoint)point;
- (BOOL)isAvailableFlash;

- (void)addObservers;
- (void)removeObservers;

@end

@protocol CPVideoCaptureManagerDelegate <NSObject>
@optional
- (void)captureManager:(CPVideoCaptureManager *)captureManager didFailWithError:(NSError *)error;
- (void)captureManagerRecordingBegan:(CPVideoCaptureManager *)captureManager;
- (void)captureManagerRecordingFinished:(CPVideoCaptureManager *)captureManager;
- (void)captureManagerStillImageCaptured:(CPVideoCaptureManager *)captureManager;
- (void)captureManagerDeviceConfigurationChanged:(CPVideoCaptureManager *)captureManager;
@end