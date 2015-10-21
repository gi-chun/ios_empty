//
//  CPVideoCompositionItem.h
//  11st
//
//  Created by spearhead on 2015. 1. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPFilterUtility.h"
#import "OPGPUImage.h"
#import "OPGPUImageMovieComposition.h"

typedef void (^OutplayUploadCompletionBlock)(void);
typedef void (^OutplayUploadFailureBlock)(NSError *error);
typedef void (^OutplayUploadCancelBlock)(NSError *error);

@protocol CPVideoCompositionItemDelegate;

@class OPGPUImageOutput;

@interface CPVideoCompositionItem : NSObject

@property (nonatomic, weak) id<CPVideoCompositionItemDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *clips;
@property (nonatomic, assign, readonly) NSInteger frameSize;
@property (nonatomic, assign, readonly) NSInteger recordType;
@property (nonatomic, assign, readonly) NSInteger clipMaxCount;
@property (nonatomic, assign, readonly) NSInteger clipMaxDuration;
@property (nonatomic, assign, readonly) NSInteger clipTotalDuration;
//@property (nonatomic, assign) OutplayVideoFilterType filterType;
//@property (nonatomic, assign, readonly) OutplayVideoWatermarkPosition watermarkPosition;
@property (nonatomic, strong) OPGPUImageOutput<OPGPUImageInput> *filter;
//@property (nonatomic, SAFE_ARC_PROP_RETAIN) OutplayBGMInfo *bgmInfo;
@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, assign, readonly) BOOL encodingStatus;
@property (nonatomic, assign, readonly) NSTimeInterval encodingStartTimestamp;
@property (nonatomic, assign, readonly) NSTimeInterval encodingEndTimestamp;

@property (nonatomic, assign, readonly) BOOL endedFileEncoding;
@property (nonatomic, strong, readonly) NSURL *encodedURL;

@property (nonatomic, assign, readonly) BOOL endedFileUploading;
@property (nonatomic, assign) BOOL refreshRequired;

@property (nonatomic, strong) NSString *uploadRequestIdentifier;
@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *cancelTimer;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) CGFloat volume;

+ (CPVideoCompositionItem *)currentCompositionItem;

+ (CPVideoCompositionItem *)videoCompositionItemWithClips:(NSArray *)clips;

- (NSArray *)getAssetsFromClips;
- (void)startEncoding;

@end

@protocol CPVideoCompositionItemDelegate <NSObject>
@optional
- (void)mergeCompleted;
- (void)mergeFailed;
@end
