//
//  CPVideoUtility.h
//  11st
//
//  Created by spearhead on 2015. 1. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPGPUImage.h"
#import "OPGPUImageMovieComposition.h"

@interface CPVideoUtility : NSObject

typedef void (^CPMovieCompletion)(NSURL *outputFileURL);
//typedef void (^CPLoadMovieCompletion)(OPQBAssetCollectionViewController *imgPicker, NSURL *outputFileURL);
//typedef void (^CPLoadPhotosCompletion)(OPQBAssetCollectionViewController *imgPicker, NSArray *assets);
typedef void (^CPLoadMovieFailure)(NSError *error, NSString *formattedMessage, double requiredDuration);
typedef void (^CPGetThumbnailCompletion)(UIImage *thumbnailImage);

typedef enum {
    CPPhotoClipsAnimationTypeNone				= 0,
    CPPhotoClipsAnimationTypeZoom				= 1,
    CPPhotoClipsAnimationTypeFade				= 2,
    CPPhotoClipsAnimationTypeRotate             = 3,
} CPPhotoClipsAnimationType;

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) OPGPUImageMovieComposition *movieFile;
@property (nonatomic, strong) OPGPUImageOutput<OPGPUImageInput> *filter;
//@property (nonatomic, assign) CPVideoFilterType filterType;
@property (nonatomic, strong) OPGPUImageMovieWriter *movieWriter;

@property (nonatomic, assign) NSInteger encodingRetryCount;
@property (nonatomic, assign) CGFloat mergeProgress;
@property (nonatomic, assign) CGFloat applyFilterProgress;

+ (CPVideoUtility *)sharedVideoUtility;

+ (NSInteger)getRecordClipCount;
+ (NSTimeInterval)getRecordTimeInterval;
+ (NSTimeInterval)getRecordTotalDuration;

+ (NSString *)timestamp;
+ (NSURL *)timestampDocumentDirectoryWithExtension:(NSString *)extension;
+ (NSURL *)timestampDocumentFileURLWithExtension:(NSString *)extension;
+ (NSURL *)timestampDocumentFileURL;
+ (NSURL *)createTemporaryDirectory;
+ (NSString *)getMovieItemPlistFilePath;
+ (void)removeMovieItemFromMyVideo:(NSURL *)movieURL;
+ (BOOL)removeMovie:(NSURL *)movieURL;

+ (CGSize)getMovieSizeFromOptions;

+ (void)saveCurrentCompositionItems;
+ (void)saveCurrentCompositionItemsWithPath:(NSString *)path;

+ (BOOL)isLandscapeForTransform:(CGAffineTransform)preferredTransform;
+ (CGAffineTransform)modifyTransformWithPreferredTransform:(CGAffineTransform)preferredTransform naturalSize:(CGSize)naturalSize;

- (AVAssetImageGenerator *)assetImageGeneratorWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration;

- (void)mergeMovieWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration bgmURL:(NSURL *)bgmURL completionBlock:(CPMovieCompletion)completionBlock;
- (void)mergeAndApplyfilterWithRecordURLList:(NSArray *)recordURLList renderSize:(CGSize)renderSize maxClipDuration:(double)maxClipDuration bgmURL:(NSURL *)bgmURL filter:(OPGPUImageOutput<OPGPUImageInput> *)filter completionBlock:(CPMovieCompletion)completionBlock;

- (void)cancelMovieEncoding;
- (void)clearMovieEncoding;

@end
