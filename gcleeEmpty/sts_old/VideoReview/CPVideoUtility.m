//
//  CPVideoUtility.m
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPVideoUtility.h"
#import "CPVideoCompositionItem.h"
#import "CPVideoPredefined.h"
#import <ImageIO/ImageIO.h>

@implementation CPVideoUtility

- (id)init
{
    self = [super init];
    if (self) {
        self.encodingRetryCount = 0;
        
        self.mergeProgress = 0.f;
        self.applyFilterProgress = 0.f;
    }
    return self;
}

+ (CPVideoUtility *)sharedVideoUtility
{
    static dispatch_once_t pred;
    static CPVideoUtility *sharedVideoUtility = nil;
    
    dispatch_once(&pred, ^{
        sharedVideoUtility = [[CPVideoUtility alloc] init];
    });
    
    return sharedVideoUtility;
}

+ (NSInteger)getRecordClipCount
{
    NSInteger clipCount = 1;
//    if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClips9x2) {
//        clipCount = OutplayMovieRecordClips9x2ClipCount;
//    }
//    else if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClips6x3) {
//        clipCount = OutplayMovieRecordClips6x3ClipCount;
//    }
//    else if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClipsUserDefined) {
//        clipCount = [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClipsUserDefinedClipCount];
//    }
//    else {
//        // do nothing...
//    }
    
    return clipCount;
}

+ (NSTimeInterval)getRecordTimeInterval
{
    //#define OutplayVideo9x2ClipDuration						2.f
    //#define OutplayVideo6x3ClipDuration						3.f
    
    NSTimeInterval timeInterval = 0.f;
//    if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClips9x2) {
//        timeInterval = OutplayVideo9x2ClipDuration;
//    }
//    else if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClips6x3) {
//        timeInterval = OutplayVideo6x3ClipDuration;
//    }
//    else if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClipsUserDefined) {
//        timeInterval = [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClipsUserDefinedClipDuration];
//    }
//    else {
//        // do nothing...
//    }
    
    timeInterval = CPVideo6x3ClipDuration;
    
    return timeInterval;
}

+ (NSTimeInterval)getRecordTotalDuration
{
//    if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClipsUserDefined) {
//        return [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClipsUserDefinedClipCount] * [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClipsUserDefinedClipDuration];
//    }
//    else if ([[OutplayUserDefaults sharedUserDefaults] getMovieRecordClips] == OutplayMovieRecordClipsCustom) {
//        return [[OutplayUserDefaults sharedUserDefaults] getMovieRecordClipsCustomMaxDuration];
//    }
//    else {
//        // do nothing...
//    }
    
    return CPVideoMaximumDuration;
}

#pragma mark - TimeStamp & Directory

+ (NSString *)timestamp
{
    //	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //
    //	NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    //	SAFE_ARC_RELEASE(dateFormatter);
    
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    return timestamp;
}

+ (NSURL *)timestampDocumentDirectoryWithExtension:(NSString *)extension
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    return [[[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:[[self class] timestamp]] URLByAppendingPathExtension:extension];
}

+ (NSURL *)timestampDocumentFileURLWithExtension:(NSString *)extension
{
    //	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //	NSString *documentPath = [searchPaths lastObject];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    
    NSURL *recordURL = [[[[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:CPMovieDocumentExtension] URLByAppendingPathComponent:[[self class] timestamp]] URLByAppendingPathExtension:extension];
    return recordURL;
}

+ (NSURL *)timestampDocumentFileURL
{
    return [[self class] timestampDocumentFileURLWithExtension:@"mov"];
}

+ (NSURL *)createTemporaryDirectory
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSURL *filePathAndDirectory = [[[NSURL fileURLWithPath:applicationSupportDirectory isDirectory:YES] URLByAppendingPathComponent:CPMovieTemporaryExtension] URLByAppendingPathComponent:[[self class] timestamp]];
    
    NSLog(@"filePathAndDirectory : %@", filePathAndDirectory);
    
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:filePathAndDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return nil;
    }
    
    return filePathAndDirectory;
}

+ (NSString *)getMovieItemPlistFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:CPMovieDocumentExtension];
    
    NSString *filePath = [applicationSupportDirectory stringByAppendingPathComponent:CPMovieMyVideoPlistFilename];
    
    return filePath;
}

+ (void)removeMovieItemFromMyVideo:(NSURL *)movieURL
{
    NSMutableDictionary *movieItemData = [NSMutableDictionary dictionaryWithContentsOfFile:[[self class] getMovieItemPlistFilePath]];
    [movieItemData removeObjectForKey:[movieURL lastPathComponent]];
}

+ (BOOL)removeMovie:(NSURL *)movieURL
{
    NSError *error;
    if ([[NSFileManager defaultManager] removeItemAtURL:movieURL error:nil]) {
        // 기존의 앱 내의 Documents에 있는 동영상 파일을 지운다.
        if (error) {
            NSLog(@"File delete failed");
            return NO;
        }
        else {
            NSLog(@"File delete success!!!");
            
            // remove plist
            [CPVideoUtility removeMovieItemFromMyVideo:movieURL];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Movie Size

+ (CGSize)getMovieSizeFromOptions
{
    //1:1 로 고정
    CGSize movieSize = CGSizeMake(CPVideoLandscapeHeight, CPVideoLandscapeHeight);
    
//    CGSize movieSize = CGSizeMake(CPVideoLandscapeWidth, CPVideoLandscapeHeight);
//    if ([CPVideoCompositionItem currentCompositionItem].frameSize == CPMovieFrameSize480x480) {
//        //#define OutplayVideoPortraitWidth							480.f
//        //#define OutplayVideoPortraitHeight							480.f
//        movieSize = CGSizeMake(CPVideoPortraitWidth, CPVideoPortraitHeight);
//    }
    
    return movieSize;
}

#pragma mark - Transform

+ (BOOL)isLandscapeForTransform:(CGAffineTransform)preferredTransform
{
    BOOL isLandscape = NO;
    
    if (preferredTransform.a == 0.f && preferredTransform.b == 1.f && preferredTransform.c == -1.f && preferredTransform.d == 0.f) {
        // Landscape Right
        isLandscape = YES;
    }
    else if (preferredTransform.a == 0.f && preferredTransform.b == -1.f && preferredTransform.c == 1.f && preferredTransform.d == 0.f) {
        // Landscape Left
        isLandscape = YES;
    }
    
    return isLandscape;
}

+ (CGAffineTransform)modifyTransformWithPreferredTransform:(CGAffineTransform)preferredTransform naturalSize:(CGSize)naturalSize
{
    CGAffineTransform modifiedTransform = preferredTransform;
    
    NSLog(@"preferredTransform : %@", NSStringFromCGAffineTransform(preferredTransform));
    
    if (preferredTransform.a == 0.f && preferredTransform.b == 1.f && preferredTransform.c == -1.f && preferredTransform.d == 0.f) {
        // Landscape Right
        if (preferredTransform.tx == 0.f && preferredTransform.ty == 0.f) {
            modifiedTransform.tx = naturalSize.height;
        }
    }
    else if (preferredTransform.a == 0.f && preferredTransform.b == -1.f && preferredTransform.c == 1.f && preferredTransform.d == 0.f) {
        // Landscape Left
        if (preferredTransform.tx == 0.f && preferredTransform.ty == 0.f) {
            modifiedTransform.tx = naturalSize.height;
        }
    }
    else if (preferredTransform.a == 1.f && preferredTransform.b == 0.f && preferredTransform.c == 0.f && preferredTransform.d == 1.f) {
        // Portrait
        // do nothing...
    }
    else if(preferredTransform.a == -1.f && preferredTransform.b == 0.f && preferredTransform.c == 0.f && preferredTransform.d == -1.f) {
        // Upside Down
        if (preferredTransform.tx == 0.f && preferredTransform.ty == 0.f) {
            modifiedTransform.tx = naturalSize.width;
            modifiedTransform.ty = naturalSize.height;
        }
    }
    else if (preferredTransform.a == 0.f && preferredTransform.b == 1.f && preferredTransform.c == 1.f && preferredTransform.d == 0.f) {
        // 480x480 에서 전면 카메라로 직접 촬영시 [0,1,1,0,0,0]
    }
    else if (preferredTransform.a == 1.f && preferredTransform.b == 0.f && preferredTransform.c == 0.f && preferredTransform.d == -1.f) {
        // 640x480 에서 전면 카메라로 직접 촬영시 [1,0,0,-1,0,480]
    }
    else {
        // do nothing???
        // 일단은 결과를 지켜보자.
//        [[OutplayToastViewManager sharedManager] showWithText:[NSString stringWithFormat:@"Weird Transform : \n%@", NSStringFromCGAffineTransform(preferredTransform)]
//                                                     duration:5.f];
        
        //		[0, 1, -1, 0, 720, 0]		front	portrait
        //		[0, -1, 1, 0, 0, 1280]		front	upside down
        //		[-1, 0, 0, -1, 1280, 720]	front	landscape right
        //		[1, 0, 0, 1, 0, 0]			front	landscape left
    }
    
    return modifiedTransform;
}

#pragma mark - Save CurrentCompositionItem

+ (void)saveCurrentCompositionItems
{
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] > 0) {
        NSURL *tmpClipURL = (NSURL *)[[CPVideoCompositionItem currentCompositionItem].clips objectAtIndex:0];
        NSString *filePath = [[[tmpClipURL URLByDeletingLastPathComponent] path] stringByAppendingPathComponent:CPMovieCompostionItemPlistFilename];
        
        [[self class] saveCurrentCompositionItemsWithPath:filePath];
    }
}

+ (void)saveCurrentCompositionItemsWithPath:(NSString *)path
{
    if ([[CPVideoCompositionItem currentCompositionItem].clips count] == 0) {
        // 저장할 정보가 없다. 혹은 클립을 전부 삭제했다.
        // 이미 있는 plist를 지우도록 하자.
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error] == NO) {
                NSLog(@"file remove failed...");
            }
        }
        
        return;
    }
    
    NSLog(@"filePath : %@", path);
    
    NSMutableDictionary *compositionItemData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if (compositionItemData == nil) {
        compositionItemData = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *clipOrders = [NSMutableArray arrayWithCapacity:[[CPVideoCompositionItem currentCompositionItem].clips count]];
    for (NSURL *movieURL in [CPVideoCompositionItem currentCompositionItem].clips) {
        [clipOrders addObject:[movieURL lastPathComponent]];
    }
    
    if ([clipOrders count] > 0) {
        [compositionItemData setObject:clipOrders forKey:CPDraftCompositionItemKeyClips];
    }
    
//    [compositionItemData setObject:[NSString stringWithFormat:@"%d", [CPVideoCompositionItem currentCompositionItem].watermarkPosition] forKey:OutplayDraftCompositionItemKeyWatermark];
    [compositionItemData setObject:[NSString stringWithFormat:@"%ld", (long)[CPVideoCompositionItem currentCompositionItem].frameSize] forKey:CPDraftCompositionItemKeyFrameSize];
    [compositionItemData setObject:[NSString stringWithFormat:@"%ld", (long)[CPVideoCompositionItem currentCompositionItem].recordType] forKey:CPDraftCompositionItemKeyRecordType];
    [compositionItemData setObject:[NSString stringWithFormat:@"%ld", (long)[CPVideoCompositionItem currentCompositionItem].clipMaxCount] forKey:CPDraftCompositionItemKeyClipMaxCount];
    [compositionItemData setObject:[NSString stringWithFormat:@"%ld", (long)[CPVideoCompositionItem currentCompositionItem].clipMaxDuration] forKey:CPDraftCompositionItemKeyClipMaxDuration];
    [compositionItemData setObject:[NSString stringWithFormat:@"%ld", (long)[CPVideoCompositionItem currentCompositionItem].clipTotalDuration] forKey:CPDraftCompositionItemKeyClipTotalDuration];
    
    NSLog(@"file write ? %@", [compositionItemData writeToFile:path atomically:YES] ? @"YES" : @"NO");
}

#pragma mark - Image Generator

- (AVAssetImageGenerator *)assetImageGeneratorWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration
{
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
//    if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//        videoComposition.frameDuration = CMTimeMake(1.f, 24.f);
//    }
//    else {
        videoComposition.frameDuration = CMTimeMake(1.f, 30.f);
//    }
    videoComposition.renderScale = 1.f;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    videoComposition.renderSize = renderSize;
    
    NSTimeInterval elapsedTime = 0.f;
    
    for (NSURL *recordURL in recordURLList) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:recordURL
                                                      options:options];
        
        BOOL successFlag = NO;
        NSError *error = nil;
        
        AVAssetTrack *clipVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        BOOL isLandscape = [[self class] isLandscapeForTransform:clipVideoTrack.preferredTransform];
        
        NSLog(@"%@", isLandscape ? @"Landscape" : @"Portrait");
        NSLog(@"clipVideoTrack.preferredTransform : %@", NSStringFromCGAffineTransform(clipVideoTrack.preferredTransform));
        
        // portrait 동영상
        CGSize naturalSize = CGSizeZero;
        if (isLandscape) {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width);
        }
        else {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height);
        }
        
        CGFloat videoRatio = renderSize.width / naturalSize.width; // width 기준으로 ratio를 정해주자.
        if ((naturalSize.height * videoRatio) < renderSize.height) {
            videoRatio = renderSize.height / naturalSize.height;
        }
        
        NSLog(@"videoRatio : %f", videoRatio);
        NSLog(@"naturalSize : %@", NSStringFromCGSize(naturalSize));
        NSLog(@"resize : %@", NSStringFromCGSize(CGSizeMake(naturalSize.width * videoRatio, naturalSize.height * videoRatio)));
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(videoRatio, videoRatio);
        CGAffineTransform t1;
        
        if ([CPVideoCompositionItem currentCompositionItem].frameSize == CPMovieFrameSize480x480 && CGSizeEqualToSize(naturalSize, CGSizeMake(CPVideoLandscapeHeight, CPVideoLandscapeWidth))) {
            CGRect cropRect = CGRectMake(0.f, (CPVideoLandscapeWidth - CPVideoPortraitHeight) / 2.f + UIKIT_STATUSBAR_DEFAULT_HEIGHT, CPVideoLandscapeWidth, CPVideoLandscapeHeight);
            NSLog(@"cropRect : %@", NSStringFromCGRect(cropRect));
            
            CGFloat cropScaleRatio = renderSize.width / cropRect.size.width;
            CGRect cropScaleRect = CGRectMake(cropRect.origin.x * cropScaleRatio, cropRect.origin.y * cropScaleRatio, cropRect.size.width * cropScaleRatio, cropRect.size.height * cropScaleRatio);
            
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(-cropScaleRect.origin.x, -cropScaleRect.origin.y);
            t1 = CGAffineTransformConcat(scaleTransform, moveTransform);
        }
        else {
            t1 = scaleTransform;
        }
        
        // portrait는 돌리자...
        // 비디오가 가지고 있는 preferredTransform을 concatenation 시켜야 t1이 가지고 있는 transform에 오리엔테이션 정보가 쓰여진다.
        // 야호!!! 된다!!!
        CGAffineTransform preferredTransform = [[self class] modifyTransformWithPreferredTransform:clipVideoTrack.preferredTransform naturalSize:clipVideoTrack.naturalSize];
        NSLog(@"midified preferredTransform : %@", NSStringFromCGAffineTransform(preferredTransform));
        
        t1 = CGAffineTransformConcat(preferredTransform, t1);
        
        [layerInstruction setTransform:t1 atTime:CMTimeMakeWithSeconds(elapsedTime, 30.f)];
        
        CMTimeRange videoTimeRange = clipVideoTrack.timeRange;
        
        //정해진 maxDuration이 없으므로 필요없음
//        if (maxClipDuration > 0.f && CMTimeGetSeconds(clipVideoTrack.timeRange.duration) > maxClipDuration) {
//            // TODO
//            // custom 모드일 때의 정책이 필요할 듯 하다.
//            // 커스텀은 클립당 시간이 정해진 것이 없으므로.......
//            // 일단 잘 생각해보자.
//            videoTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds([CPVideoCompositionItem currentCompositionItem].clipMaxDuration, sourceAsset.duration.timescale));
//        }
        
        // TODO
        // 비디오 트랙을 늘리거나 줄일 수 없을까?
        successFlag = [compositionVideoTrack insertTimeRange:videoTimeRange
                                                     ofTrack:clipVideoTrack
                                                      atTime:CMTimeMakeWithSeconds(elapsedTime, sourceAsset.duration.timescale)
                                                       error:&error];
        
        if (successFlag == NO) {
            // Deal with the error.
            NSLog(@"something went wrong");
        }
        
        NSLog(@"AVAssetImageGenerator\n source asset duration is %f \n source vid track timerange is %f %f \n composition duration is %f \n composition vid track time range is %f %f",
              CMTimeGetSeconds([sourceAsset duration]),
              CMTimeGetSeconds(clipVideoTrack.timeRange.start),
              CMTimeGetSeconds(clipVideoTrack.timeRange.duration),
              CMTimeGetSeconds([composition duration]),
              CMTimeGetSeconds(compositionVideoTrack.timeRange.start),
              CMTimeGetSeconds(compositionVideoTrack.timeRange.duration));
        
        elapsedTime += CMTimeGetSeconds(videoTimeRange.duration);
    }
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    instruction.timeRange = compositionVideoTrack.timeRange;
    
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:composition];
    imageGenerator.videoComposition = videoComposition;
    
    return imageGenerator;
}

#pragma mark - Merge



- (void)mergeMovieWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration bgmURL:(NSURL *)bgmURL completionBlock:(CPMovieCompletion)completionBlock
{
    // merge에서 progress 초기화를 진행한다.
    self.mergeProgress = 0.f;
    self.applyFilterProgress = 0.f;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *compositionBGMTrack = nil;
    if (bgmURL) {
        compositionBGMTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
//    if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//        videoComposition.frameDuration = CMTimeMake(1.f, 24.f);
//    }
//    else {
        videoComposition.frameDuration = CMTimeMake(1.f, 30.f);
//    }
    
    videoComposition.renderScale = 1.f;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    videoComposition.renderSize = renderSize;//sourceVideoTrack.naturalSize;
    
    NSTimeInterval elapsedTime = 0.f;
    
    for (NSURL *recordURL in recordURLList) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:recordURL
                                                      options:options];
        
        BOOL successFlag = NO;
        NSError *error = nil;
        
        AVAssetTrack *clipVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *clipAudioTrack = nil;
        
        if ([sourceAsset tracksWithMediaType:AVMediaTypeAudio] != nil && [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
            clipAudioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        }
        
        BOOL isLandscape = [[self class] isLandscapeForTransform:clipVideoTrack.preferredTransform];
        
        NSLog(@"%@", isLandscape ? @"Landscape" : @"Portrait");
        NSLog(@"clipVideoTrack.preferredTransform : %@", NSStringFromCGAffineTransform(clipVideoTrack.preferredTransform));
        
        // portrait 동영상
        CGSize naturalSize = CGSizeZero;
        if (isLandscape) {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width);
        }
        else {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height);
        }
        
        CGFloat videoRatio = renderSize.width / naturalSize.width; // width 기준으로 ratio를 정해주자.
        if ((naturalSize.height * videoRatio) < renderSize.height) {
            videoRatio = renderSize.height / naturalSize.height;
        }
        
        NSLog(@"videoRatio : %f", videoRatio);
        NSLog(@"naturalSize : %@", NSStringFromCGSize(naturalSize));
        NSLog(@"resize : %@", NSStringFromCGSize(CGSizeMake(naturalSize.width * videoRatio, naturalSize.height * videoRatio)));
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(videoRatio, videoRatio);
        CGAffineTransform t1;
        
        if ([CPVideoCompositionItem currentCompositionItem].frameSize == CPMovieFrameSize480x480 && CGSizeEqualToSize(naturalSize, CGSizeMake(CPVideoLandscapeHeight, CPVideoLandscapeWidth))) {
            CGRect cropRect = CGRectMake(0.f, (CPVideoLandscapeWidth - CPVideoPortraitHeight) / 2.f + UIKIT_STATUSBAR_DEFAULT_HEIGHT, CPVideoLandscapeWidth, CPVideoLandscapeHeight);
            NSLog(@"cropRect : %@", NSStringFromCGRect(cropRect));
            
            CGFloat cropScaleRatio = renderSize.width / cropRect.size.width;
            CGRect cropScaleRect = CGRectMake(cropRect.origin.x * cropScaleRatio, cropRect.origin.y * cropScaleRatio, cropRect.size.width * cropScaleRatio, cropRect.size.height * cropScaleRatio);
            
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(-cropScaleRect.origin.x, -cropScaleRect.origin.y);
            t1 = CGAffineTransformConcat(scaleTransform, moveTransform);
        }
        else {
            t1 = scaleTransform;
        }
        
        // portrait는 돌리자...
        // 비디오가 가지고 있는 preferredTransform을 concatenation 시켜야 t1이 가지고 있는 transform에 오리엔테이션 정보가 쓰여진다.
        // 야호!!! 된다!!!
        CGAffineTransform preferredTransform = [[self class] modifyTransformWithPreferredTransform:clipVideoTrack.preferredTransform naturalSize:clipVideoTrack.naturalSize];
        NSLog(@"midified preferredTransform : %@", NSStringFromCGAffineTransform(preferredTransform));
        
        t1 = CGAffineTransformConcat(preferredTransform, t1);
        
//        if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//            [layerInstruction setTransform:t1 atTime:CMTimeMakeWithSeconds(elapsedTime, 24.f)];
//        }
//        else {
            [layerInstruction setTransform:t1 atTime:CMTimeMakeWithSeconds(elapsedTime, 30.f)];
//        }
        
        CMTimeRange videoTimeRange = clipVideoTrack.timeRange;
        
        if (maxClipDuration > 0.f && CMTimeGetSeconds(clipVideoTrack.timeRange.duration) > maxClipDuration) {
            // TODO
            // custom 모드일 때의 정책이 필요할 듯 하다.
            // 커스텀은 클립당 시간이 정해진 것이 없으므로.......
            // 일단 잘 생각해보자.
            videoTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds([CPVideoCompositionItem currentCompositionItem].clipMaxDuration, sourceAsset.duration.timescale));
        }
        
        // TODO
        // 비디오 트랙을 늘리거나 줄일 수 없을까?
        successFlag = [compositionVideoTrack insertTimeRange:videoTimeRange
                                                     ofTrack:clipVideoTrack
                                                      atTime:CMTimeMakeWithSeconds(elapsedTime, sourceAsset.duration.timescale)
                                                       error:&error];
        
        if (bgmURL == nil && clipAudioTrack) {
            // BGM이 없고 기존 음원 트랙이 있을 경우에만 기존 음원 추가
            NSLog(@"insert real audio");
            successFlag = [compositionAudioTrack insertTimeRange:videoTimeRange
                                                         ofTrack:clipAudioTrack
                                                          atTime:CMTimeMakeWithSeconds(elapsedTime, sourceAsset.duration.timescale)
                                                           error:&error];
        }
        else {
            // BGM이 있으면 기존의 음원 트랙 없앤다.
            // 아니면 원래 음원 트랙이 없는 트랙은 empty range
            NSLog(@"insert empty audio");
            [compositionAudioTrack insertEmptyTimeRange:videoTimeRange];
            successFlag = YES;
        }
        
        if (successFlag == NO) {
            // Deal with the error.
            NSLog(@"something went wrong");
        }
        
        NSLog(@"\n source asset duration is %f \n source vid track timerange is %f %f \n composition duration is %f \n composition vid track time range is %f %f",CMTimeGetSeconds([sourceAsset duration]), CMTimeGetSeconds(clipVideoTrack.timeRange.start),CMTimeGetSeconds(clipVideoTrack.timeRange.duration),CMTimeGetSeconds([composition duration]), CMTimeGetSeconds(compositionVideoTrack.timeRange.start),CMTimeGetSeconds(compositionVideoTrack.timeRange.duration));
        
        elapsedTime += CMTimeGetSeconds(videoTimeRange.duration);
    }
    
    if (bgmURL && compositionBGMTrack) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *bgmAsset = [AVURLAsset URLAssetWithURL:bgmURL
                                                   options:options];
        NSLog(@"bgmAsset : %@", bgmAsset);
        
        NSError *error = nil;
        BOOL successFlag = NO;
        
        AVAssetTrack *clipBGMTrack = [[bgmAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        Float64 bgmDuration = CMTimeGetSeconds(bgmAsset.duration);
        if (bgmDuration > elapsedTime) {
            // bgm이 동영상보다 길 경우
            CMTimeRange bgmTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(elapsedTime, bgmAsset.duration.timescale));
            successFlag = [compositionBGMTrack insertTimeRange:bgmTimeRange
                                                       ofTrack:clipBGMTrack
                                                        atTime:kCMTimeZero error:&error];
        }
        else {
            // bgm이 동영상보다 짧을 경우
            NSTimeInterval elapsedBGMTime = 0.f;
            
            NSInteger count = (NSInteger)(floorf(elapsedTime / bgmDuration));
            for (NSInteger i = 0; i <= count; i++) {
                NSTimeInterval rangeTimeInterval = CMTimeGetSeconds(bgmAsset.duration);
                if (i == count) {
                    rangeTimeInterval = elapsedTime - elapsedBGMTime;
                }
                
                successFlag = [compositionBGMTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(rangeTimeInterval, bgmAsset.duration.timescale))
                                                           ofTrack:clipBGMTrack
                                                            atTime:CMTimeMakeWithSeconds(elapsedBGMTime, bgmAsset.duration.timescale)
                                                             error:&error];
                
                if (successFlag == NO) {
                    // 일단 중지 시키자.
                    break;
                }
                
                elapsedBGMTime += rangeTimeInterval;
            }
        }
        
        if (successFlag == NO) {
            NSLog(@"bgm error");
        }
    }
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    instruction.timeRange = compositionVideoTrack.timeRange;
    
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    NSURL *outputFileURL = [[self class] timestampDocumentFileURL];
    NSLog(@"merge outputFileURL : %@", [outputFileURL absoluteString]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[outputFileURL absoluteString]]) {
        NSLog(@"exits");
    }
    else {
        NSLog(@"no exits");
//        NSArray *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *docDir = [dirPath objectAtIndex:0];
//        NSString *moviePath = [docDir stringByAppendingPathComponent:@"11123.mov"];
//        outputFileURL = [NSURL URLWithString:moviePath];
        
       
            
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths objectAtIndex:0];
        
        outputFileURL = [[[[NSURL fileURLWithPath:applicationSupportDirectory] URLByAppendingPathComponent:@""] URLByAppendingPathComponent:[[self class] timestamp]] URLByAppendingPathExtension:@"mov"];
    }
    
    AVMutableAudioMix *audioMix = nil;
    if (compositionBGMTrack) {
        NSMutableArray *trackMixArray = [NSMutableArray array];
        
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionBGMTrack];
        
        // bgm fade in
        CGFloat curVolume = 0.f;
        for (NSInteger i = 0; i < 10; i++) {
            [trackMix setVolume:curVolume atTime:CMTimeMakeWithSeconds(curVolume, 1)];
            curVolume += 0.1;
        }
        
        // bgm fade out
        for (NSInteger i = 0; i < 10; i++) {
            [trackMix setVolume:curVolume atTime:CMTimeMakeWithSeconds(elapsedTime - curVolume, 1)];
            curVolume -= 0.1;
        }
        
        [trackMixArray addObject:trackMix];
        
        audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = trackMixArray;
    }
    
    // export
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    self.exportSession = exportSession;
    
    self.exportSession.videoComposition = videoComposition;
    self.exportSession.outputURL = outputFileURL;
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    self.exportSession.shouldOptimizeForNetworkUse = NO;
    
    if (audioMix) {
        self.exportSession.audioMix = audioMix;
    }
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch ([self.exportSession status]) {
            case AVAssetExportSessionStatusFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Export failed: %@", [self.exportSession error]);
                    completionBlock(nil);
                });
            }
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Exporting done!");
                    completionBlock(outputFileURL);
                });
            }
                break;
            case AVAssetExportSessionStatusCancelled:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Exporting cancel!");
                    completionBlock(nil);
                });
            }
                break;
            default:
                break;
        }
        
        self.exportSession = nil;
    }];
}

- (void)mergeAndApplyfilterWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration bgmURL:(NSURL *)bgmURL filter:(OPGPUImageOutput<OPGPUImageInput> *)filter completionBlock:(CPMovieCompletion)completionBlock
{
    self.applyFilterProgress = 0.f;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack *compositionBGMTrack = nil;
    if (bgmURL) {
        compositionBGMTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
//    if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//        videoComposition.frameDuration = CMTimeMake(1.f, 24.f);
//    }
//    else {
        videoComposition.frameDuration = CMTimeMake(1.f, 30.f);
//    }
    
    videoComposition.renderScale = 1.f;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    videoComposition.renderSize = renderSize;
    
    NSTimeInterval elapsedTime = 0.f;
    BOOL containsAudio = NO;
    
    for (NSURL *recordURL in recordURLList) {
        
        NSLog(@"record item : %@", recordURL);
        
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:recordURL
                                                      options:options];
        
        BOOL successFlag = NO;
        NSError *error = nil;
        
        AVAssetTrack *clipVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *clipAudioTrack = nil;
        
        if ([sourceAsset tracksWithMediaType:AVMediaTypeAudio] != nil && [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
            clipAudioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            containsAudio = YES;
        }
        
        NSLog(@"containsAudio ? %@", containsAudio ? @"YES" : @"NO");
        
        BOOL isLandscape = [[self class] isLandscapeForTransform:clipVideoTrack.preferredTransform];
        
        NSLog(@"%@", isLandscape ? @"Landscape" : @"Portrait");
        NSLog(@"clipVideoTrack.preferredTransform : %@", NSStringFromCGAffineTransform(clipVideoTrack.preferredTransform));
        
        // portrait 동영상
        CGSize naturalSize = CGSizeZero;
        if (isLandscape) {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width);
        }
        else {
            naturalSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height);
        }
        
        CGFloat videoRatio = renderSize.width / naturalSize.width; // width 기준으로 ratio를 정해주자.
        if ((naturalSize.height * videoRatio) < renderSize.height) {
            videoRatio = renderSize.height / naturalSize.height;
        }
        
        NSLog(@"videoRatio : %f", videoRatio);
        NSLog(@"naturalSize : %@", NSStringFromCGSize(naturalSize));
        NSLog(@"resize : %@", NSStringFromCGSize(CGSizeMake(naturalSize.width * videoRatio, naturalSize.height * videoRatio)));
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(videoRatio, videoRatio);
        CGAffineTransform t1;
        
        if ([CPVideoCompositionItem currentCompositionItem].frameSize == CPMovieFrameSize480x480 && CGSizeEqualToSize(naturalSize, CGSizeMake(CPVideoLandscapeHeight, CPVideoLandscapeWidth))) {
            CGRect cropRect = CGRectMake(0.f, (CPVideoLandscapeWidth - CPVideoPortraitHeight) / 2.f + UIKIT_STATUSBAR_DEFAULT_HEIGHT, CPVideoLandscapeWidth, CPVideoLandscapeHeight);
            NSLog(@"cropRect : %@", NSStringFromCGRect(cropRect));
            
            CGFloat cropScaleRatio = renderSize.width / cropRect.size.width;
            CGRect cropScaleRect = CGRectMake(cropRect.origin.x * cropScaleRatio, cropRect.origin.y * cropScaleRatio, cropRect.size.width * cropScaleRatio, cropRect.size.height * cropScaleRatio);
            
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(-cropScaleRect.origin.x, -cropScaleRect.origin.y);
            t1 = CGAffineTransformConcat(scaleTransform, moveTransform);
        }
        else {
            t1 = scaleTransform;
        }
        
        // portrait는 돌리자...
        // 비디오가 가지고 있는 preferredTransform을 concatenation 시켜야 t1이 가지고 있는 transform에 오리엔테이션 정보가 쓰여진다.
        CGAffineTransform preferredTransform = [[self class] modifyTransformWithPreferredTransform:clipVideoTrack.preferredTransform naturalSize:clipVideoTrack.naturalSize];
        NSLog(@"midified preferredTransform : %@", NSStringFromCGAffineTransform(preferredTransform));
        
        t1 = CGAffineTransformConcat(preferredTransform, t1);
        
//        if ([OutplayUserDefaults sharedUserDefaults].lowSpec) {
//            [layerInstruction setTransform:t1 atTime:CMTimeMakeWithSeconds(elapsedTime, 24.f)];
//        }
//        else {
            [layerInstruction setTransform:t1 atTime:CMTimeMakeWithSeconds(elapsedTime, 30.f)];
//        }
        
        CMTimeRange videoTimeRange = clipVideoTrack.timeRange;
        
        //정해진 maxDuration이 없으므로 필요없음
//        if (maxClipDuration > 0.f && CMTimeGetSeconds(clipVideoTrack.timeRange.duration) > maxClipDuration) {
//            // TODO
//            // custom 모드일 때의 정책이 필요할 듯 하다.
//            // 커스텀은 클립당 시간이 정해진 것이 없으므로.......
//            // 일단 잘 생각해보자.
//            videoTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds([CPVideoCompositionItem currentCompositionItem].clipMaxDuration, sourceAsset.duration.timescale));
//        }
        
        // TODO
        // 비디오 트랙을 늘리거나 줄일 수 없을까?
        successFlag = [compositionVideoTrack insertTimeRange:videoTimeRange
                                                     ofTrack:clipVideoTrack
                                                      atTime:CMTimeMakeWithSeconds(elapsedTime, sourceAsset.duration.timescale)
                                                       error:&error];
        
        // BGM이 없고 기존 음원 트랙이 있을 경우에만 기존 음원 추가
        if (bgmURL == nil && clipAudioTrack) {
            NSLog(@"insert real audio");
            successFlag = [compositionAudioTrack insertTimeRange:videoTimeRange
                                                         ofTrack:clipAudioTrack
                                                          atTime:CMTimeMakeWithSeconds(elapsedTime, sourceAsset.duration.timescale)
                                                           error:&error];
        }
        else {
            // BGM이 있으면 기존의 음원 트랙 없앤다.
            // 아니면 원래 음원 트랙이 없는 트랙은 empty range
            NSLog(@"insert empty audio");
            [compositionAudioTrack insertEmptyTimeRange:videoTimeRange];
            successFlag = YES;
        }
        
        if (successFlag == NO) {
            // Deal with the error.
            NSLog(@"something went wrong");
        }
        
        elapsedTime += CMTimeGetSeconds(videoTimeRange.duration);
        
        NSLog(@"mergeAndApplyfilte\n source asset duration is %f \n source vid track timerange is %f %f \n composition duration is %f \n composition vid track time range is %f %f \n elapsedTime %f",
              CMTimeGetSeconds([sourceAsset duration]),
              CMTimeGetSeconds(clipVideoTrack.timeRange.start),
              CMTimeGetSeconds(clipVideoTrack.timeRange.duration),
              CMTimeGetSeconds([composition duration]),
              CMTimeGetSeconds(compositionVideoTrack.timeRange.start),
              CMTimeGetSeconds(compositionVideoTrack.timeRange.duration),
              elapsedTime);
    }
    
    CMTimeScale bgmTimescale = 0;
    
    if (bgmURL && compositionBGMTrack) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *bgmAsset = [AVURLAsset URLAssetWithURL:bgmURL
                                                   options:options];
        NSLog(@"bgmAsset : %@", bgmAsset);
        
        NSError *error = nil;
        BOOL successFlag = NO;
        
        AVAssetTrack *clipBGMTrack = [[bgmAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        bgmTimescale = bgmAsset.duration.timescale;
        
        Float64 bgmDuration = CMTimeGetSeconds(bgmAsset.duration);
        if (bgmDuration > elapsedTime) {
            // bgm이 동영상보다 길 경우
            CMTimeRange bgmTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(elapsedTime, bgmTimescale));
            successFlag = [compositionBGMTrack insertTimeRange:bgmTimeRange
                                                       ofTrack:clipBGMTrack
                                                        atTime:kCMTimeZero error:&error];
        }
        else {
            // bgm이 동영상보다 짧을 경우
            NSTimeInterval elapsedBGMTime = 0.f;
            
            NSInteger count = (NSInteger)(floorf(elapsedTime / bgmDuration));
            for (NSInteger i = 0; i <= count; i++) {
                NSTimeInterval rangeTimeInterval = CMTimeGetSeconds(bgmAsset.duration);
                if (i == count) {
                    rangeTimeInterval = elapsedTime - elapsedBGMTime;
                }
                
                successFlag = [compositionBGMTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(rangeTimeInterval, bgmTimescale))
                                                           ofTrack:clipBGMTrack
                                                            atTime:CMTimeMakeWithSeconds(elapsedBGMTime, bgmTimescale)
                                                             error:&error];
                
                if (successFlag == NO) {
                    // 일단 중지 시키자.
                    break;
                }
                
                elapsedBGMTime += rangeTimeInterval;
            }
        }
        
        if (successFlag == NO) {
            NSLog(@"bgm error");
        }
    }
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    instruction.timeRange = compositionVideoTrack.timeRange;
    
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    AVMutableAudioMix *audioMix = nil;
    if (compositionBGMTrack) {
        NSMutableArray *trackMixArray = [NSMutableArray array];
        
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionBGMTrack];
        
        // bgm fade in
        CGFloat curVolume = 0.f;
        for (NSInteger i = 0; i < 10; i++) {
            [trackMix setVolume:curVolume atTime:CMTimeMakeWithSeconds(curVolume, bgmTimescale)];
            curVolume += 0.1;
        }
        
        // bgm fade out
        for (NSInteger i = 0; i < 10; i++) {
            [trackMix setVolume:curVolume atTime:CMTimeMakeWithSeconds(elapsedTime - curVolume, bgmTimescale)];
            curVolume -= 0.1;
        }
        
        [trackMixArray addObject:trackMix];
        
        audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = trackMixArray;
    }
    
    if (self.filter) {
        [self.filter removeAllTargets];
        self.filter = nil;
    }
    
    [filter removeAllTargets];
    self.filter = filter;
    
    // isEndProcessing 다시 원래대로...
    OPGPUImageFilterGroup *filterGroup = (OPGPUImageFilterGroup *)self.filter;
    filterGroup.isEndProcessing = NO;
    
    for (int i = 0; i < [filterGroup filterCount]; i++) {
        OPGPUImageFilter *tmpFilter = (OPGPUImageFilter *)[filterGroup filterAtIndex:i];
        tmpFilter.isEndProcessing = NO;
    }
    
    __unsafe_unretained CPVideoUtility *weakSelf = self;
    
    OPGPUImageMovieComposition *movieFile = [[OPGPUImageMovieComposition alloc] initWithComposition:composition
                                                                                andVideoComposition:videoComposition
                                                                                        andAudioMix:audioMix];
    
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = NO;
    movieFile.shouldRepeat = NO;
    movieFile.encodingProgressBlock = ^(float progress) {
        weakSelf.applyFilterProgress = progress;
    };
    
    self.movieFile = movieFile;
    
    [self.movieFile addTarget:self.filter];
    
    //Documents 폴더에 저장. Library/Application Support에 저장하면 알수 없는 오류가 발생
    NSURL *tmpMovieURL = [[self class] timestampDocumentDirectoryWithExtension:@"mp4"];
    
    OPGPUImageMovieWriter *movieWriter = [[OPGPUImageMovieWriter alloc] initWithMovieURL:tmpMovieURL size:renderSize fileType:AVFileTypeMPEG4 outputSettings:nil];
    movieWriter.encodingLiveVideo = YES;
    movieWriter.assetWriter.shouldOptimizeForNetworkUse = YES;
    
    self.movieWriter = movieWriter;
    
    [self.filter addTarget:self.movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    if (containsAudio) {
        self.movieWriter.shouldPassthroughAudio = NO;
        self.movieFile.audioEncodingTarget = self.movieWriter;
        
        [self.movieWriter setHasAudioTrack:YES];
    }
    
    [self.movieWriter setFailureBlock:^(NSError *error) {
        NSLog(@"########## setFailureBlock called / weakSelf.encodingRetryCount : %ld", (long)weakSelf.encodingRetryCount);
        weakSelf.encodingRetryCount += 1;
        
        [weakSelf cancelMovieEncoding];
        [weakSelf mergeAndApplyfilterWithRecordURLList:recordURLList
                                            renderSize:renderSize
                                       maxClipDuration:maxClipDuration
                                                bgmURL:bgmURL
                                                filter:filter
                                       completionBlock:completionBlock];
    }];
    
    [self.movieWriter setCompletionBlock:^{
        NSLog(@"---------- setCompletionBlock called / weakSelf.encodingRetryCount : %ld", (long)weakSelf.encodingRetryCount);
        
        if (weakSelf.encodingRetryCount >= 10) {
            // FOR DEBUG
//            [[OutplayToastViewManager sharedManager] showWithText:[NSString stringWithFormat:@"retry count : %ld", (long)weakSelf.encodingRetryCount]
//                                                         duration:3.f];
        }
        
        [weakSelf.movieFile removeAllTargets];
        [weakSelf.filter removeAllTargets];
        
        [weakSelf.movieWriter finishRecording];
        
        // the end...
        completionBlock(tmpMovieURL);
    }];
    
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
}

#pragma mark - Clear

- (void)cancelMovieEncoding
{
    if (self.exportSession) {
        [self.exportSession cancelExport];
    }
    
    if (self.movieWriter) {
        [self.movieWriter cancelRecording];
    }
    
    if (self.movieFile) {
        [self.movieFile removeAllTargets];
    }
    
    if (self.filter) {
        [self.filter removeAllTargets];
    }
    
    self.exportSession = nil;
    self.movieWriter = nil;
    self.filter = nil;
    self.movieFile = nil;
    self.encodingRetryCount = 0;
}

- (void)clearMovieEncoding
{
    if (self.movieWriter) {
        [self.movieWriter cancelRecording];
    }
    
    if (self.movieFile) {
        [self.movieFile removeAllTargets];
    }
    
    if (self.filter) {
        [self.filter removeAllTargets];
    }
    
    self.movieWriter = nil;
    self.filter = nil;
    self.movieFile = nil;
    self.encodingRetryCount = 0;
}

@end
