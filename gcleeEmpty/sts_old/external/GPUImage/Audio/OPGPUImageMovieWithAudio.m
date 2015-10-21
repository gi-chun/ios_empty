// Modified by FUTUREWIZ
// Based on https://github.com/pheed/GPUImage
// Added for Video compositions

#import "OPGPUImageMovieWithAudio.h"
#import "OPGPUImageMovieWriter.h"
#import "OPGPUImageFilter.h"
#import "OPGPUImageVideoCamera.h"
#import "OPGPUImageAudioPlayer.h"

@interface OPGPUImageMovieWithAudio () <AVPlayerItemOutputPullDelegate>
{
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;
    OPGPUImageMovieWriter *synchronizedMovieWriter;
    CVOpenGLESTextureCacheRef coreVideoTextureCache;
    AVAssetReader *reader;
	AVPlayerItemVideoOutput *playerItemOutput;
    CADisplayLink *displayLink;
    CMTime previousFrameTime;
    CFAbsoluteTime previousActualFrameTime;
    BOOL keepLooping;
    BOOL pausedRendering; // BY FUTUREWIZ
    BOOL resetPreviousFrameTime; // BY FUTREWIZ
	
	GLuint luminanceTexture, chrominanceTexture;
	
	OPGLProgram *yuvConversionProgram;
    GLint yuvConversionPositionAttribute, yuvConversionTextureCoordinateAttribute;
    GLint yuvConversionLuminanceTextureUniform, yuvConversionChrominanceTextureUniform;
    GLint yuvConversionMatrixUniform;
    GLuint yuvConversionFramebuffer;
    const GLfloat *_preferredConversion;
	
    int imageBufferWidth, imageBufferHeight;
    
    OPGPUImageAudioPlayer *audioPlayer;
    CFAbsoluteTime assetStartTime;
    dispatch_queue_t audio_queue;
}

- (void)processAsset;

@end

@implementation OPGPUImageMovieWithAudio

@synthesize url = _url;
@synthesize asset = _asset;
@synthesize runBenchmark = _runBenchmark;
@synthesize playAtActualSpeed = _playAtActualSpeed;
@synthesize delegate = _delegate;
@synthesize shouldRepeat = _shouldRepeat;
@synthesize compositon = _compositon;
@synthesize videoComposition = _videoComposition;
@synthesize audioMix = _audioMix;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithURL:(NSURL *)url;
{
    if (!(self = [super init])) 
    {
        return nil;
    }

    [self textureCacheSetup];

    self.url = url;
    self.asset = nil;
    self.alwaysCopiesSampleData = YES;

    return self;
}

- (id)initWithAsset:(AVAsset *)asset;
{
    if (!(self = [super init])) 
    {
      return nil;
    }
    
    [self textureCacheSetup];

    self.url = nil;
    self.asset = asset;
    self.alwaysCopiesSampleData = YES;

    return self;
}

- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
{
    if (!(self = [super init]))
    {
        return nil;
    }
	
    [self textureCacheSetup];
	
    self.url = nil;
    self.asset = nil;
    self.playerItem = playerItem;
	
    return self;
}

- (id)initWithComposition:(AVComposition *)compositon
      andVideoComposition:(AVVideoComposition *)videoComposition
              andAudioMix:(AVAudioMix *)audioMix {
    if (!(self = [super init]))
    {
        return nil;
    }
	
    [self textureCacheSetup];
	
    self.compositon = compositon;
    self.videoComposition = videoComposition;
    self.audioMix = audioMix;
	
    return self;
}

- (void)textureCacheSetup;
{
    if ([OPGPUImageContext supportsFastTextureUpload])
    {
        runSynchronouslyOnVideoProcessingQueue(^{
            [OPGPUImageContext useImageProcessingContext];
			
            _preferredConversion = kOPColorConversion709;
            yuvConversionProgram = [[OPGPUImageContext sharedImageProcessingContext] programForVertexShaderString:kOPGPUImageVertexShaderString fragmentShaderString:kOPGPUImageYUVVideoRangeConversionForLAFragmentShaderString];
			
            if (!yuvConversionProgram.initialized)
            {
                [yuvConversionProgram addAttribute:@"position"];
                [yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
				
                if (![yuvConversionProgram link])
                {
                    NSString *progLog = [yuvConversionProgram programLog];
                    NSLog(@"Program link log: %@", progLog);
                    NSString *fragLog = [yuvConversionProgram fragmentShaderLog];
                    NSLog(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [yuvConversionProgram vertexShaderLog];
                    NSLog(@"Vertex shader compile log: %@", vertLog);
                    yuvConversionProgram = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
            }
			
            yuvConversionPositionAttribute = [yuvConversionProgram attributeIndex:@"position"];
            yuvConversionTextureCoordinateAttribute = [yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
            yuvConversionLuminanceTextureUniform = [yuvConversionProgram uniformIndex:@"luminanceTexture"];
            yuvConversionChrominanceTextureUniform = [yuvConversionProgram uniformIndex:@"chrominanceTexture"];
            yuvConversionMatrixUniform = [yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
			
            [OPGPUImageContext setActiveShaderProgram:yuvConversionProgram];
			
            glEnableVertexAttribArray(yuvConversionPositionAttribute);
            glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
			
#if defined(__IPHONE_6_0)
            CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [[OPGPUImageContext sharedImageProcessingContext] context], NULL, &coreVideoTextureCache);
#else
            CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)[[OPGPUImageContext sharedImageProcessingContext] context], NULL, &coreVideoTextureCache);
#endif
            if (err)
            {
                NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", err);
            }
            
            // Need to remove the initially created texture
            [self deleteOutputTexture];
        });
    }
}

- (void)dealloc
{
//    if (audio_queue != nil){
//        dispatch_release(audio_queue);
//    }
    
	runSynchronouslyOnVideoProcessingQueue(^{
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        displayLink = nil;
    });
    if ([OPGPUImageContext supportsFastTextureUpload])
    {
        CFRelease(coreVideoTextureCache);
        [self destroyYUVConversionFBO];
    }
}

#pragma mark -
#pragma mark Movie processing

- (void)enableSynchronizedEncodingUsingMovieWriter:(OPGPUImageMovieWriter *)movieWriter;
{
    synchronizedMovieWriter = movieWriter;
    movieWriter.encodingLiveVideo = NO;
}

- (void)startProcessing
{
    if( self.playerItem ) {
        [self processPlayerItem];
        return;
    }
    
    pausedRendering = NO;
    
    if(self.url == nil)
    {
		[self processAsset];
		return;
    }
    
    if (_shouldRepeat) keepLooping = YES;
    
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:self.url options:inputOptions];
    
    OPGPUImageMovieWithAudio __block *blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        runSynchronouslyOnVideoProcessingQueue(^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (!tracksStatus == AVKeyValueStatusLoaded)
            {
                return;
            }
            blockSelf.asset = inputAsset;
            [blockSelf processAsset];
            blockSelf = nil;
        });
    }];
}

- (void)processAsset
{
    __unsafe_unretained OPGPUImageMovieWithAudio *weakSelf = self;
    NSError *error = nil;
	
	if (self.compositon) {
		reader = [AVAssetReader assetReaderWithAsset:self.compositon error:&error];
	}
	else {
		reader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];
	}
	
    // FUTUREWIZ - Optimiation
    // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange =>kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
	NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
	[outputSettings setObject: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]  forKey: (NSString*)kCVPixelBufferPixelFormatTypeKey];
	// kCVPixelFormatType_32BGRA
//	NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
	
	// Maybe set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
//	AVAssetReaderTrackOutput *readerVideoTrackOutput = nil;
//	AVAssetReaderVideoCompositionOutput *readerVideoCompositionOutput = nil;
	
	id readerVideoTrackOutput = nil;
	
	if (self.compositon) {
		readerVideoTrackOutput = [AVAssetReaderVideoCompositionOutput
								  assetReaderVideoCompositionOutputWithVideoTracks:[_compositon tracksWithMediaType:AVMediaTypeVideo]
								  videoSettings:outputSettings];
		
#if ! TARGET_IPHONE_SIMULATOR
		if( [_videoComposition isKindOfClass:[AVMutableVideoComposition class]] )
			[(AVMutableVideoComposition*)_videoComposition setRenderScale:1.0];
#endif
		
		((AVAssetReaderVideoCompositionOutput *)readerVideoTrackOutput).videoComposition = self.videoComposition;
		((AVAssetReaderVideoCompositionOutput *)readerVideoTrackOutput).alwaysCopiesSampleData = NO;
	}
	else {
		readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
		
		((AVAssetReaderTrackOutput *)readerVideoTrackOutput).alwaysCopiesSampleData = self.alwaysCopiesSampleData;
	}
	
	[reader addOutput:readerVideoTrackOutput];

//	AVAssetReaderTrackOutput *readerAudioTrackOutput = nil;
	
	NSArray *audioTracks = nil;
	if (self.compositon) {
		audioTracks = [self.compositon tracksWithMediaType:AVMediaTypeAudio];
	}
	else {
		audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
	}
	
	BOOL hasAudioTraks = [audioTracks count] > 0;
	BOOL shouldPlayAudio = hasAudioTraks && self.playSound;
	BOOL shouldRecordAudioTrack = (hasAudioTraks && (weakSelf.audioEncodingTarget != nil));
	
	id readerAudioTrackOutput = nil;
	
	if (shouldRecordAudioTrack || shouldPlayAudio) {
		audioEncodingIsFinished = NO;

		// This might need to be extended to handle movies with more than one audio track
		AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
		NSDictionary *audioReadSettings = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
										   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
										   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
										   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
										   [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
										   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
										   nil];
		
		
		
		if (self.compositon) {
			readerAudioTrackOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
			((AVAssetReaderAudioMixOutput *)readerAudioTrackOutput).audioMix = self.audioMix;
			((AVAssetReaderAudioMixOutput *)readerAudioTrackOutput).alwaysCopiesSampleData = NO;
		}
		else {
			readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioReadSettings];
		}
		
		[reader addOutput:readerAudioTrackOutput];
		
		if (shouldPlayAudio){
			if (audio_queue == nil){
				audio_queue = dispatch_queue_create("GPUAudioQueue", nil);
			}
			
			if (audioPlayer == nil){
                NSLog(@"[[OPGPUImageAudioPlayer alloc] init];");
				audioPlayer = [[OPGPUImageAudioPlayer alloc] init];
				[audioPlayer initAudio];
				[audioPlayer startPlaying];
			}
		}
	}

	if (shouldRecordAudioTrack) {
		[self.audioEncodingTarget setShouldInvalidateAudioSampleWhenDone:YES];
	}
	
	// 참조 ->
	// Fatal Exception NSInvalidArgumentException
	// *** -[AVAssetReader startReading] cannot be called again after reading has already started
	
	@try {
		if ([reader startReading] == NO)
		{
			NSLog(@"Error reading from file at URL: %@", weakSelf.url);
			return;
		}
	}
	@catch (NSException *exception) {
		NSLog(@"exception : %@", exception);
		NSLog(@"Error reading from file at URL: %@", weakSelf.url);
		return;
	}
    
    // FUTUREWIZ - Log
    NSLog(@"Filter Play - BEGIN");
	
	if (synchronizedMovieWriter != nil)
	{
		[synchronizedMovieWriter setVideoInputReadyCallback:^{
			return [weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput];
		}];
		
		[synchronizedMovieWriter setAudioInputReadyCallback:^{
			return [weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
		}];
		
		[synchronizedMovieWriter enableSynchronizationCallbacks];
	}
	else
	{
		assetStartTime = 0.0;
		while (reader.status == AVAssetReaderStatusReading && (!_shouldRepeat || keepLooping))
		{
            if (pausedRendering) {
                usleep(1000000.0 * 0.05);
                continue;
            }
            
			//            runSynchronouslyOnVideoProcessingQueue(^{
			[weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput];
			
			if (shouldPlayAudio && (!audioEncodingIsFinished)){
				
				if (audioPlayer.readyForMoreBytes) {
					//process next audio sample if the player is ready to receive it
					[weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
				}
				
			} else if (shouldRecordAudioTrack && (!audioEncodingIsFinished)) {
				[weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
			}
			//            });
		}
		
		if (reader.status == AVAssetWriterStatusCompleted) {
			
			[reader cancelReading];
			
			if (keepLooping) {
				reader = nil;
				dispatch_async(dispatch_get_main_queue(), ^{
					[self startProcessing];
				});
			} else {
				[weakSelf endProcessing];
				//                if ([self.delegate respondsToSelector:@selector(didCompletePlayingMovie)]) {
				//                    [self.delegate didCompletePlayingMovie];
				//                }
			}
			
		}
	}
    
    pausedRendering = NO;
    // FUTUREWIZ - Log
    NSLog(@"Filter Play - END");

}

- (void)processPlayerItem
{
    runSynchronouslyOnVideoProcessingQueue(^{
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [displayLink setPaused:YES];
		
        dispatch_queue_t videoProcessingQueue = [OPGPUImageContext sharedContextQueue];
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        playerItemOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        [playerItemOutput setDelegate:self queue:videoProcessingQueue];
		
        [_playerItem addOutput:playerItemOutput];
        [playerItemOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.1];
    });
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
	// Restart display link.
	[displayLink setPaused:NO];
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
	/*
	 The callback gets called once every Vsync.
	 Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
	 This pixel buffer can then be processed and later rendered on screen.
	 */
	// Calculate the nextVsync time which is when the screen will be refreshed next.
	CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
	
	CMTime outputItemTime = [playerItemOutput itemTimeForHostTime:nextVSync];
	
	if ([playerItemOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        __unsafe_unretained OPGPUImageMovieWithAudio *weakSelf = self;
		CVPixelBufferRef pixelBuffer = [playerItemOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if( pixelBuffer )
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf processMovieFrame:pixelBuffer withSampleTime:outputItemTime];
                CFRelease(pixelBuffer);
            });
	}
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput;
{
    if (reader.status == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];

        if (sampleBufferRef)
        {
            if (_playAtActualSpeed)
            {
				// Do this outside of the video processing queue to not slow that down while waiting
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
                CMTime differenceFromLastFrame = CMTimeSubtract(currentSampleTime, previousFrameTime);
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                
                CGFloat frameTimeDifference = CMTimeGetSeconds(differenceFromLastFrame);
                CGFloat actualTimeDifference = currentActualTime - previousActualFrameTime;
                
                if (frameTimeDifference > actualTimeDifference)
                {
                    usleep(1000000.0 * (frameTimeDifference - actualTimeDifference));
                }
                // FUTUREWIZ - Drop Frame
                else if (resetPreviousFrameTime == NO && (frameTimeDifference + 0.001) < actualTimeDifference) {
//                    NSLog(@"Drop Frame.... %f", actualTimeDifference - frameTimeDifference);
                    CMSampleBufferInvalidate(sampleBufferRef);
                    CFRelease(sampleBufferRef);
                    return NO;
                }
                
                resetPreviousFrameTime = NO;
                previousFrameTime = currentSampleTime;
                previousActualFrameTime = CFAbsoluteTimeGetCurrent();
            }
            
            __unsafe_unretained OPGPUImageMovieWithAudio *weakSelf = self;
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf processMovieFrame:sampleBufferRef];
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            });
			
			return YES;
        }
        else
        {
            if (!keepLooping) {
                videoEncodingIsFinished = YES;
                if( videoEncodingIsFinished && audioEncodingIsFinished )
                    [self endProcessing];
            }
        }
    }
    else if (synchronizedMovieWriter != nil)
    {
        if (reader.status == AVAssetWriterStatusCompleted) 
        {
            [self endProcessing];
        }
    }
	
	return NO;
}

- (BOOL)readNextAudioSampleFromOutput:(AVAssetReaderOutput *)readerAudioTrackOutput {
    if (audioEncodingIsFinished && !self.playSound) {
        return NO;
    }

    if (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef audioSampleBufferRef = [readerAudioTrackOutput copyNextSampleBuffer];
        
        if (audioSampleBufferRef) {
            
            if (self.playSound){
                CFRetain(audioSampleBufferRef);
                dispatch_async(audio_queue, ^{
                    [audioPlayer copyBuffer:audioSampleBufferRef];

                    CMSampleBufferInvalidate(audioSampleBufferRef);
                    CFRelease(audioSampleBufferRef);
                });
                
            } else if (self.audioEncodingTarget != nil && !audioEncodingIsFinished){
//                [self.audioEncodingTarget processAudioBuffer:audioSampleBufferRef];
//                CMSampleBufferInvalidate(audioSampleBufferRef);
				[self.audioEncodingTarget processAudioBuffer:audioSampleBufferRef];
				CFRelease(audioSampleBufferRef);
            }
            
            CFRelease(audioSampleBufferRef);
			
			return YES;
			
        } else {
            audioEncodingIsFinished = YES;
        }
    }
	
	return NO;
}

- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer;
{
	//    CMTimeGetSeconds
	//    CMTimeSubtract
    
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(movieSampleBuffer);
    CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(movieSampleBuffer);
    [self processMovieFrame:movieFrame withSampleTime:currentSampleTime];
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
    int bufferHeight = (int) CVPixelBufferGetHeight(movieFrame);
#if TARGET_IPHONE_SIMULATOR
    int bufferWidth = (int) CVPixelBufferGetBytesPerRow(movieFrame) / 4; // This works around certain movie frame types on the Simulator (see https://github.com/BradLarson/GPUImage/issues/424)
#else
    int bufferWidth = (int) CVPixelBufferGetWidth(movieFrame);
#endif
    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
        _preferredConversion = kOPColorConversion601;
    }
    else {
        _preferredConversion = kOPColorConversion709;
    }
	
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
	
    if ([OPGPUImageContext supportsFastTextureUpload])
    {
        CVOpenGLESTextureRef luminanceTextureRef = NULL;
        CVOpenGLESTextureRef chrominanceTextureRef = NULL;
        CVOpenGLESTextureRef texture = NULL;
		
        //        if (captureAsYUV && [OPGPUImageContext deviceSupportsRedTextures])
        if (CVPixelBufferGetPlaneCount(movieFrame) > 0) // Check for YUV planar inputs to do RGB conversion
        {
			
            if ( (imageBufferWidth != bufferWidth) && (imageBufferHeight != bufferHeight) )
            {
                imageBufferWidth = bufferWidth;
                imageBufferHeight = bufferHeight;
				
                [self destroyYUVConversionFBO];
                [self createYUVConversionFBO];
            }
			
            CVReturn err;
            // Y-plane
            glActiveTexture(GL_TEXTURE4);
            if ([OPGPUImageContext deviceSupportsRedTextures])
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
            }
            else
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
			
            luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, luminanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			
            // UV-plane
            glActiveTexture(GL_TEXTURE5);
            if ([OPGPUImageContext deviceSupportsRedTextures])
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
            }
            else
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
			
            chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			
            if (!allTargetsWantMonochromeData)
            {
                [self convertYUVToRGBOutput];
            }
			
            for (id<OPGPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
				
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
                [currentTarget setInputTexture:outputTexture atIndex:targetTextureIndex];
                [currentTarget setTextureDelegate:self atIndex:targetTextureIndex];
				
                [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
            }
			
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            CVOpenGLESTextureCacheFlush(coreVideoTextureCache, 0);
            CFRelease(luminanceTextureRef);
            CFRelease(chrominanceTextureRef);
        }
        else
        {
            CVPixelBufferLockBaseAddress(movieFrame, 0);
			
            CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &texture);
			
            if (!texture || err) {
                NSLog(@"Movie CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
                NSAssert(NO, @"Camera failure");
                return;
            }
			
            outputTexture = CVOpenGLESTextureGetName(texture);
            //        glBindTexture(CVOpenGLESTextureGetTarget(texture), outputTexture);
            glBindTexture(GL_TEXTURE_2D, outputTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			
            for (id<OPGPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
				
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
                [currentTarget setInputTexture:outputTexture atIndex:targetTextureIndex];
                [currentTarget setTextureDelegate:self atIndex:targetTextureIndex];
				
                [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
            }
			
            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            CVOpenGLESTextureCacheFlush(coreVideoTextureCache, 0);
            CFRelease(texture);
            
            outputTexture = 0;
        }
    }
    else
    {
        // Upload to texture
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        glBindTexture(GL_TEXTURE_2D, outputTexture);
        // Using BGRA extension to pull in video frame data directly
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     self.outputTextureOptions.internalFormat,
                     bufferWidth,
                     bufferHeight,
                     0,
                     self.outputTextureOptions.format,
                     self.outputTextureOptions.type,
                     CVPixelBufferGetBaseAddress(movieFrame));
        
        CGSize currentSize = CGSizeMake(bufferWidth, bufferHeight);
        for (id<OPGPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
			
            [currentTarget setInputSize:currentSize atIndex:targetTextureIndex];
            [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
        }
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    }
    
    if (_runBenchmark)
    {
        CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
    }
}

- (void)endProcessing;
{
    keepLooping = NO;
    [displayLink setPaused:YES];
	
    for (id<OPGPUImageInput> currentTarget in targets)
    {
        [currentTarget endProcessing];
    }
    
    if (synchronizedMovieWriter != nil)
    {
        [synchronizedMovieWriter setVideoInputReadyCallback:^{return NO;}];
        [synchronizedMovieWriter setAudioInputReadyCallback:^{return NO;}];
    }
    
    if (audioPlayer != nil){
        [audioPlayer stopPlaying];
        audioPlayer = nil;
    }
	
	if ([self.delegate respondsToSelector:@selector(didCompletePlayingMovie)]) {
		[self.delegate didCompletePlayingMovie];
	}
	
	self.delegate = nil;
}

- (void)cancelProcessing
{
//    runSynchronouslyOnVideoProcessingQueue(^{
        if (reader) {
            [reader cancelReading];
        }
        [self endProcessing];
//    });
}

// ADD PAUSED FUNCTION BY FUTUREWIZ
- (void)pauseProcessing
{
    if (audioPlayer != nil) {
        [audioPlayer stopPlaying];
    }
    pausedRendering = TRUE;
}

- (void)resumeProcessing
{
    pausedRendering = NO;
    resetPreviousFrameTime = YES; // 일시 정지후 다시 재생할때 비디오/오디오 싱크를 Drop Frame 시간설정을 위해 필요함.
    if (audioPlayer != nil) {
        [audioPlayer startPlaying];
    }
}

- (BOOL)isPausedProcessing
{
    return pausedRendering;
}

- (void)convertYUVToRGBOutput;
{
    [OPGPUImageContext setActiveShaderProgram:yuvConversionProgram];
    [self setYUVConversionFBO];
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
	
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
	
	glActiveTexture(GL_TEXTURE4);
	glBindTexture(GL_TEXTURE_2D, luminanceTexture);
	glUniform1i(yuvConversionLuminanceTextureUniform, 4);
	
    glActiveTexture(GL_TEXTURE5);
	glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
	glUniform1i(yuvConversionChrominanceTextureUniform, 5);
	
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, _preferredConversion);
	
    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
	glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)setYUVConversionFBO;
{
    if (!yuvConversionFramebuffer)
    {
        [self createYUVConversionFBO];
    }
	
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFramebuffer);
	
    glViewport(0, 0, imageBufferWidth, imageBufferHeight);
}

- (void)createYUVConversionFBO;
{
    [self initializeOutputTextureIfNeeded];
	
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &yuvConversionFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, yuvConversionFramebuffer);
	
    glBindTexture(GL_TEXTURE_2D, outputTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageBufferWidth, imageBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, outputTexture, 0);
	
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    [self notifyTargetsAboutNewOutputTexture];
	
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
	
}

- (void)destroyYUVConversionFBO;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [OPGPUImageContext useImageProcessingContext];
		
        if (yuvConversionFramebuffer)
        {
            glDeleteFramebuffers(1, &yuvConversionFramebuffer);
            yuvConversionFramebuffer = 0;
        }
		
        if (outputTexture)
        {
            glDeleteTextures(1, &outputTexture);
            outputTexture = 0;
        }
    });
}

- (AVAssetReader*)assetReader {
    return reader;
}

- (BOOL)audioEncodingIsFinished {
    return audioEncodingIsFinished;
}

- (BOOL)videoEncodingIsFinished {
    return videoEncodingIsFinished;
}

@end
