//
//  CPVideoRecorder.h
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPVideoRecorderDelegate;

@interface CPVideoRecorder : NSObject

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,strong) NSURL *outputFileURL;
@property (nonatomic,readonly) BOOL recordsVideo;
@property (nonatomic,readonly) BOOL recordsAudio;
@property (nonatomic,readonly,getter=isRecording) BOOL recording;
@property (nonatomic,weak) id <CPVideoRecorderDelegate> delegate;

- (id)initWithSession:(AVCaptureSession *)session outputFileURL:(NSURL *)outputFileURL;
- (void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
- (void)stopRecording;
- (AVCaptureConnection *)videoConnection;
- (AVCaptureConnection *)audioConnection;

@end

@protocol CPVideoRecorderDelegate
@required
- (void)recorderRecordingDidBegin:(CPVideoRecorder *)recorder;
- (void)recorder:(CPVideoRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
@end
