//
//  CPVideoModule.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPThumbnailView.h"
#import "CPIndicatorView.h"
#import <AVFoundation/AVFoundation.h>

@class CPVideoModule;
@class CPMoviePlayerViewController;

@protocol CPVideoModuleDelegate <NSObject>
@optional
- (void)videoModuleOnClickPlayButton:(CPVideoModule *)view;
- (void)videoModuleonClickFullScreenButton:(CPMoviePlayerViewController *)player;
@end

typedef NS_ENUM(NSUInteger, CPVideoModuleFinishedPlayStatus) {
    videoModuleNonFinishedPlay = 0,
    videoModuleFinishedPlayOverThirty,
    videoModuleFinishedPlayUnderThirty
};

@interface CPVideoModule : UIView <UIAlertViewDelegate>
{
    UILabel	*_viewCountLabel;
    UILabel	*_timeLabel;
    UILabel	*_errorLabel;
    UIButton *_expandButton;
    UIButton *_playButton;
    UIButton *_replayButton;
    UIButton *_fullverButton;
    UIButton *_pauseButton;
    UIButton *_muteButton;
    
    BOOL _isAutoPlay;
    BOOL _isErrorVideo;
    BOOL _isFinishedPlay;
    BOOL _useMuteSound;
    BOOL _videoPlayStatus;
    BOOL _isUnderIOS6;
}


@property (nonatomic, weak) id <CPVideoModuleDelegate> delegate;
@property (nonatomic, strong) CPIndicatorView *indicatorView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer	*playerLayer;
@property (nonatomic, strong) CPThumbnailView *playerView;
@property (nonatomic, strong) UIView *playUiView;
@property (nonatomic, strong) AVURLAsset *playerAsset;
@property (nonatomic, strong) NSURL *playURL;
@property (nonatomic) CGFloat videoWidth;
@property (nonatomic) CGFloat videoHeight;
@property (nonatomic) BOOL isReady;
@property (nonatomic) BOOL isPauseForDelay;
@property (nonatomic) BOOL isConfirmToPlay;
@property (nonatomic) BOOL isBackGround;
@property (nonatomic) BOOL isExpandVideo;
@property (nonatomic) id timeObserver;
@property (nonatomic, strong) NSString *updateViewCountUrl;
@property (nonatomic) float saveDuration;

//input Value
- (void)setVideoUrl:(NSString *)urlString;
- (void)setThumbnailUrl:(NSString *)urlString;
- (void)setViewCount:(NSString *)countString;
- (void)setViewCountUrl:(NSString *)urlString;
- (void)setDuration:(NSString *)durationString;

//play and stop with parent
- (void)playWithAutoPlay:(BOOL)autoPlay useMuteSound:(BOOL)muteSound;
- (BOOL)pauseUnFocusCell;

@end