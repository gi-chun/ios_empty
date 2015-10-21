//
//  CPVideoRecorder.m
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPVideoRecorder.h"
#import "CPVideoPredefined.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static void *AVCamRecorderConnectionsObserverContext = &AVCamRecorderConnectionsObserverContext;

@interface CPVideoRecorder () <AVCaptureFileOutputRecordingDelegate>

@end

@implementation CPVideoRecorder

- (id) initWithSession:(AVCaptureSession *)aSession outputFileURL:(NSURL *)anOutputFileURL
{
    self = [super init];
    if (self != nil) {
        AVCaptureMovieFileOutput *aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        //		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [aMovieFileOutput addObserver:self forKeyPath:@"connections" options:0 context:AVCamRecorderConnectionsObserverContext];
        //		}
        
        if ([aSession canAddOutput:aMovieFileOutput]) {
            [aSession addOutput:aMovieFileOutput];
        }
        
        [self setMovieFileOutput:aMovieFileOutput];
        
        [self setSession:aSession];
        [self setOutputFileURL:anOutputFileURL];
    }
    
    return self;
}

- (void) dealloc
{
    [[self session] removeOutput:[self movieFileOutput]];
    
    [self.movieFileOutput removeObserver:self forKeyPath:@"connections"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamRecorderConnectionsObserverContext) {
        // Whenever the Movie File Output's connections property changes, a connection has been added
        // or removed, such as when we switch cameras (remove an input, add a new input, which implicitly
        // severs a connection and forms a new one).  Here is where we do all of our one-time connection
        // set up.
        AVCaptureConnection *videoConnection = [object connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection) {
            // Opt in for video stabilization
#if defined(__IPHONE_6_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0)
            if ([videoConnection respondsToSelector:@selector(isVideoStabilizationSupported)]) {
                if ([videoConnection isVideoStabilizationSupported]) {
                    [videoConnection setEnablesVideoStabilizationWhenAvailable:YES];
                }
                else {
                    [videoConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
                }
            }
            else {
                [videoConnection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
            }
#endif
            
//            if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
                if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    if ([videoConnection respondsToSelector:@selector(setVideoMinFrameDuration:)]) {
                        videoConnection.videoMinFrameDuration = CMTimeMake(1, 24);
                    }
                    
                    if ([videoConnection respondsToSelector:@selector(setVideoMaxFrameDuration:)]) {
                        videoConnection.videoMaxFrameDuration = CMTimeMake(1, 24);
                    }
#pragma clang diagnostic pop
                    
                    CMTimeShow(videoConnection.videoMinFrameDuration);
                    CMTimeShow(videoConnection.videoMaxFrameDuration);
                }
//            }
            
        }
    }
}

- (BOOL)recordsVideo
{
    AVCaptureConnection *videoConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    return [videoConnection isActive];
}

- (BOOL)recordsAudio
{
    AVCaptureConnection *audioConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeAudio];
    return [audioConnection isActive];
}

- (AVCaptureConnection *)videoConnection
{
    return [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
}

- (AVCaptureConnection *)audioConnection
{
    return [self.movieFileOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (BOOL)isRecording
{
    return [self.movieFileOutput isRecording];
}

- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
{
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.movieFileOutput connections]];
    
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:videoOrientation];
    }
    
    [self.movieFileOutput startRecordingToOutputFileURL:self.outputFileURL recordingDelegate:self];
}

- (void)stopRecording
{
    [self.movieFileOutput stopRecording];
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

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
//    if ([self.delegate respondsToSelector:@selector(recorderRecordingDidBegin:)]) {
        [self.delegate recorderRecordingDidBegin:self];
//    }
}

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL                 fromConnections:(NSArray *)connections error:(NSError *)error
{
//    if ([self.delegate respondsToSelector:@selector(recorder:recordingDidFinishToOutputFileURL:error:)]) {
        [self.delegate recorder:self recordingDidFinishToOutputFileURL:anOutputFileURL error:error];
//    }
    
    //녹화 결과 확인용으로 앨범에 저장
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:anOutputFileURL]) {
//        [library writeVideoAtPathToSavedPhotosAlbum:anOutputFileURL
//                                    completionBlock:^(NSURL *assetURL, NSError *error) {
//             if (error) {
//                 
//             }
//         }];
//    }
}

@end
