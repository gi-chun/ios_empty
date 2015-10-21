//
//  CPVideoCompositionItem.m
//  11st
//
//  Created by spearhead on 2015. 1. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPVideoCompositionItem.h"
#import "CPVideoUtility.h"
#import "CPVideoPredefined.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CPVideoCompositionItem

- (id)init
{
    self = [super init];
    if (self) {
        self.clips = [NSMutableArray array];
        
//        _frameSize = [[OutplayUserDefaults sharedUserDefaults] getMovieFrameSize];
//        _recordType = [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips];
//        _clipMaxCount = [OutplayVideoUtility getRecordClipCount];
        _clipMaxDuration = [CPVideoUtility getRecordTimeInterval];
//        _clipTotalDuration = [OutplayVideoUtility getRecordTotalDuration];
//        _watermarkPosition = (int)[[OutplayUserDefaults sharedUserDefaults] getWatermarkPosition];
        
//        self.filter = nil;
//        self.filterType = OutplayVideoFilterTypeNone;
//        self.bgmInfo = nil;
        self.coverImage = nil;
        
        _encodingStatus = NO;
        _encodingStartTimestamp = 0.f;
        _encodingEndTimestamp = 0.f;
        
        _endedFileEncoding = NO;
        _encodedURL = nil;
        
        _endedFileUploading = NO;
        
        self.refreshRequired = NO;
        
        self.started = NO;
        self.cancelled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (self.startTimer) {
        [self.startTimer invalidate];
        self.startTimer = nil;
    }
    
    if (self.cancelTimer) {
        [self.cancelTimer invalidate];
        self.cancelTimer = nil;
    }
}

- (void)enterBackground
{
    if (_encodingStatus) {
        [self cancelEncoding];
        _encodingStatus = YES;
    }
}

- (void)enterForeground
{
    if (_encodingStatus) {
        [self startEncoding];
    }
}

+ (CPVideoCompositionItem *)currentCompositionItem
{
    static dispatch_once_t pred;
    static CPVideoCompositionItem *currentCompositionItem = nil;
    
    dispatch_once(&pred, ^{
        currentCompositionItem = [[CPVideoCompositionItem alloc] init];
    });
    
    return currentCompositionItem;
}

+ (CPVideoCompositionItem *)videoCompositionItemWithClips:(NSArray *)clips
{
    CPVideoCompositionItem *videoCompositionItem = [[CPVideoCompositionItem alloc] init];
    
    if (clips != nil && [clips count] > 0) {
        videoCompositionItem.clips = [NSMutableArray arrayWithArray:clips];
    }
    
    return videoCompositionItem;
}

- (NSArray *)getAssetsFromClips
{
    NSMutableArray *assets = [NSMutableArray array];
    
    for (NSURL *url in self.clips) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        [assets addObject:asset];
    }
    
    if ([assets count] > 0) {
        return assets;
    }
    
    return nil;
}

#pragma mark - Encoding

- (void)startEncoding
{
    NSLog(@"startEncoding called");
    
    self.started = NO;
    
    if (self.startTimer) {
        [self.startTimer invalidate];
        self.startTimer = nil;
    }
    
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                       target:self
                                                     selector:@selector(startTimerCalled:)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.startTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelEncoding
{
    NSLog(@"cancelEncoding called");
    
    self.cancelled = NO;
    
    if (self.cancelTimer) {
        [self.cancelTimer invalidate];
        self.cancelTimer = nil;
    }
    
    self.cancelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(cancelTimerCalled:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.cancelTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTimerCalled:(NSTimer *)timer
{
    if (self.started) {
        NSLog(@"cancelled in timer...");
        if (self.cancelTimer) {
            [self.cancelTimer invalidate];
            self.cancelTimer = nil;
        }
        
        [self cancelMovieEncoding];
    }
}

- (void)startMovieEncoding
{
    NSLog(@"startMovieEncoding called");
    
    _encodingStartTimestamp = [[NSDate date] timeIntervalSince1970];
    _encodingStatus = YES;
    
    if (self.filter) {
        [self.filter removeAllTargets];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.clips != nil && [self.clips count] > 0) {
            // composition과 비디오 내보내기는 이때 하자...
            // 바뀔 수도 있음.
            
            CGSize renderSize = [CPVideoUtility getMovieSizeFromOptions];
            
            if (self.filter == nil) {
                self.filter = [[CPFilterUtility sharedFilterUtility] getFilter:CPVideoFilterTypeNone showWatermark:NO isEncoding:YES];
            }
            
            CPMovieCompletion completionBlock = ^(NSURL *outputFileURL) {
                _encodingEndTimestamp = [[NSDate date] timeIntervalSince1970];
                _encodingStatus = NO;
                
                NSLog(@"encoding start : %f", self.self.encodingStartTimestamp);
                NSLog(@"encoding end : %f", self.encodingEndTimestamp);
                NSLog(@"encoding time : %f", self.encodingEndTimestamp - self.encodingStartTimestamp);
                
                _endedFileEncoding = YES;
                _encodedURL = outputFileURL;
                
                // 여기는 추후에 변경하자.
                // AVAssetExportSession을 cancel하는 메서드 호출하는 방식으로...
                // 일단 임시!
                
                if (outputFileURL == nil) {
                    if ([self.delegate respondsToSelector:@selector(mergeFailed)]) {
                        [self.delegate mergeFailed];
                    }
                    return;
                }
                
                NSLog(@"merge complete!! : %@", outputFileURL);
                
                if ([self.delegate respondsToSelector:@selector(mergeCompleted)]) {
                    [self.delegate mergeCompleted];
                }
                
                double delayInSeconds = 2.f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[CPVideoUtility sharedVideoUtility] clearMovieEncoding];
                });
            };
            
//            NSLog(@"self.bgmInfo : %@", self.bgmInfo.title);
            
//            [[CPVideoUtility sharedVideoUtility] mergeMovieWithRecordURLList:self.clips
//                                                                  renderSize:renderSize
//                                                             maxClipDuration:self.clipMaxDuration
//                                                                      bgmURL:nil
//                                                             completionBlock:completionBlock];
            
            [[CPVideoUtility sharedVideoUtility] mergeAndApplyfilterWithRecordURLList:self.clips
                                                                                renderSize:renderSize
                                                                           maxClipDuration:CPVideoMaximumDuration
                                                                                    bgmURL:nil
                                                                                    filter:self.filter
                                                                           completionBlock:completionBlock];
            
            self.started = YES;
        }
    });
}

- (void)cancelMovieEncoding
{
    _encodingStartTimestamp = 0.f;
    _encodingEndTimestamp = 0.f;
    _encodingStatus = NO;
    
    if (self.encodedURL) {
        [CPVideoUtility removeMovie:self.encodedURL];
    }
    
    _endedFileEncoding = NO;
    _encodedURL = nil;
    
    [[CPVideoUtility sharedVideoUtility] cancelMovieEncoding];
    
    [OPGPUImageContext resetSharedContextQueue];
    
    self.cancelled = YES;
}

#pragma mark - Timer

- (void)startTimerCalled:(NSTimer *)timer
{
    if (self.cancelled) {
        NSLog(@"cancelled in timer...");
        if (self.startTimer) {
            [self.startTimer invalidate];
            self.startTimer = nil;
        }
        
        [self startMovieEncoding];
    }
}

@end
