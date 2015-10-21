//
//  CPVideoModule.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPVideoModule.h"
#import "CPMoviePlayerViewController.h"
#import "UIImageView+WebCache.h"
#import "SBJSON.h"
#import "HttpRequest.h"

@interface CPVideoModule () <HttpRequestDelegate>
{
	BOOL _isPlayItunesMusic;
}
@end

@implementation CPVideoModule

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initVideoPlayer];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    self.playerLayer.player = nil;
    
    [self removeObserverPlayer];
    [self removePlayerTimeObserver];
    
    if (_player) [_player pause], _player = nil;
    if (_playerAsset) _playerAsset = nil;
    if (_playerItem) _playerItem = nil;
    if (_playerView) _playerView = nil;
    if (_playUiView) _playUiView = nil;
    if (_playerLayer) _playerLayer = nil;
    if (_indicatorView) _indicatorView = nil;
    
    if (_playURL) _playURL = nil;
    if (_updateViewCountUrl) _updateViewCountUrl = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initVideoPlayer
{
    _isErrorVideo = NO;
    self.isConfirmToPlay = YES;
    self.videoWidth = 0;
    self.videoHeight = 0;
    _isUnderIOS6 = ([[[UIDevice currentDevice] systemVersion] intValue] < 7 ? YES : NO);
    
    // 01. Initialize
    self.backgroundColor = UIColorFromRGB(0x545454);
    
    _playerView = [[CPThumbnailView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_playerView setClipsToBounds:YES];
    [_playerView setUserInteractionEnabled:YES];
    [_playerView setContentMode:UIViewContentModeScaleAspectFit];
    [_playerView setBackgroundColor:UIColorFromRGB(0x2c2f34)];
    [_playerView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight];
    [self addSubview:_playerView];
    
    _playerLayer = [[AVPlayerLayer alloc] init];
    [_playerLayer setHidden:YES];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [_playerLayer setFrame:CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height)];
    [self.playerView.layer addSublayer:_playerLayer];
    
    _playUiView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           self.playerView.frame.size.height-32,
                                                           self.playerView.frame.size.width,
                                                           32)];
    _playUiView.backgroundColor = UIColorFromRGB(0x2c2f34);
    _playUiView.userInteractionEnabled = YES;
    [self.playerView addSubview:_playUiView];
    
    UIView *blackLine01 = [[UIView alloc] initWithFrame:CGRectMake(self.playUiView.frame.size.width-45, 0, 1, 32)];
    blackLine01.backgroundColor = UIColorFromRGBA(0x000000, 0.1f);
    [self.playUiView addSubview:blackLine01];
    
    UIView *whiteLine01 = [[UIView alloc] initWithFrame:CGRectMake(self.playUiView.frame.size.width-44, 0, 1, 32)];
    whiteLine01.backgroundColor = UIColorFromRGBA(0xffffff, 0.13f);
    [self.playUiView addSubview:whiteLine01];
    
    if (!_isUnderIOS6) {
        UIView *blackLine02 = [[UIView alloc] initWithFrame:CGRectMake(self.playUiView.frame.size.width-45-45, 0, 1, 32)];
        blackLine02.backgroundColor = UIColorFromRGBA(0x000000, 0.1f);
        [self.playUiView addSubview:blackLine02];
        
        UIView *whiteLine02 = [[UIView alloc] initWithFrame:CGRectMake(self.playUiView.frame.size.width-44-45, 0, 1, 32)];
        whiteLine02.backgroundColor = UIColorFromRGBA(0xffffff, 0.13f);
        [self.playUiView addSubview:whiteLine02];
        
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setFrame:CGRectMake(self.playUiView.frame.size.width-45-33, 4, 24, 24)];
        [_muteButton addTarget:self action:@selector(onClickMuteSound:) forControlEvents:UIControlEventTouchUpInside];
        [self.playUiView addSubview:_muteButton];
        
        AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setMuteImage:app.isMuteSound];
    }
    
    CGFloat timeLabelOriginX = self.playUiView.frame.size.width-39-8-45;
    if (!_isUnderIOS6)	timeLabelOriginX = self.playUiView.frame.size.width-39-8-45-45;
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelOriginX, 6, 39, 19)];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setFont:[UIFont systemFontOfSize:15.f]];
    [_timeLabel setTextColor:UIColorFromRGBA(0xffffff, 1.f)];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    [_timeLabel setText:@"00:00"];
    [self.playUiView addSubview:_timeLabel];
    
    _viewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 0, 19)];
    [_viewCountLabel setBackgroundColor:[UIColor clearColor]];
    [_viewCountLabel setFont:[UIFont systemFontOfSize:15.f]];
    [_viewCountLabel setTextColor:UIColorFromRGBA(0xffffff, 1.f)];
    [_viewCountLabel setTextAlignment:NSTextAlignmentCenter];
    [_viewCountLabel setText:@""];
    [self.playUiView addSubview:_viewCountLabel];
    
    _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_expandButton setFrame:CGRectMake(self.playUiView.frame.size.width-40, 0, 37, 32)];
    [_expandButton setImage:[UIImage imageNamed:@"list_button_video_expand"] forState:UIControlStateNormal];
    [_expandButton addTarget:self action:@selector(onClickFullScreenVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.playUiView addSubview:_expandButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    [_playButton addTarget:self action:@selector(onClickPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setImage:[UIImage imageNamed:@"list_icon_video_play_nor"] forState:UIControlStateNormal];
    [_playerView addSubview:_playButton];
    
    _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replayButton setFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    [_replayButton addTarget:self action:@selector(onClickReplayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_replayButton setImage:[UIImage imageNamed:@"list_button_video_replay"] forState:UIControlStateNormal];
    [_playerView addSubview:_replayButton];
    
    _fullverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullverButton setFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    [_fullverButton addTarget:self action:@selector(onClickFullScreenVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_fullverButton setImage:[UIImage imageNamed:@"list_button_video_fullversion"] forState:UIControlStateNormal];
    [_playerView addSubview:_fullverButton];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pauseButton setFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    [_pauseButton addTarget:self action:@selector(onClickPause:) forControlEvents:UIControlEventTouchUpInside];
    [_pauseButton setImage:[UIImage imageNamed:@"list_button_video_pause"] forState:UIControlStateNormal];
    [_playerView addSubview:_pauseButton];
    
    
    //포즈 버튼은 가려놓는다.
    [_fullverButton setHidden:YES];
    [_replayButton setHidden:YES];
    [_pauseButton setHidden:YES];
    
    //풀스크린 버튼을 위로 올린다.
    [self.playerView bringSubviewToFront:_playUiView];
    
    _indicatorView = [[CPIndicatorView alloc] initWithFrame:CGRectMake(_playerView.frame.size.width/2-20, _playerView.frame.size.height/2-20, 40, 40)];
    [_indicatorView setHidden:YES];
    [_indicatorView setHidesWhenStopped:YES];
    [_playerView addSubview:_indicatorView];
    
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _playerView.frame.size.width, _playerView.frame.size.height)];
    _errorLabel.backgroundColor = [UIColor clearColor];
    _errorLabel.font = [UIFont systemFontOfSize:16.f];
    _errorLabel.text = @"동영상을 재생할 수 없습니다.";
    _errorLabel.textColor = [UIColor whiteColor];
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_errorLabel];
    [_errorLabel setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)willEnterForegroundNotification:(NSNotification *)noti
{
    _videoPlayStatus = videoModuleNonFinishedPlay;
    [self assetFailedToPrepareForPlayback:nil];
    
    if (self.saveDuration > 0) {
        _timeLabel.text = [Modules convertTimeToString:self.saveDuration Minute:YES];
    }
    
    self.isBackGround = NO;
}

- (void)didEnterBackgroundNotification:(NSNotification *)noti
{
    self.isBackGround = YES;
    self.isConfirmToPlay = NO;
}

#pragma -mark input value
- (void)setVideoUrl:(NSString *)urlString
{
    if (self.playURL) self.playURL = nil;
    self.playURL = [NSURL URLWithString:urlString];
}

- (void)setThumbnailUrl:(NSString *)urlString
{
    [self.playerView.imageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)setViewCount:(NSString *)countString
{
    NSString *viewCount = @"";
    viewCount = [Modules numberFormatter:[countString intValue]];
    viewCount = [viewCount stringByAppendingString:@" views"];
    _viewCountLabel.text = viewCount;
    [_viewCountLabel sizeToFitWithVersion];
    
    CGRect countFrame = _viewCountLabel.frame;
    countFrame.size.width = countFrame.size.width + 6;
    _viewCountLabel.frame = countFrame;
}

- (void)setViewCountUrl:(NSString *)urlString
{
    if (self.updateViewCountUrl) {
        self.updateViewCountUrl = nil;
    }
    
    self.updateViewCountUrl = [[NSString alloc] initWithString:urlString];
}

- (void)setDuration:(NSString *)durationString
{
    self.saveDuration = [durationString floatValue];
    _timeLabel.text = [Modules convertTimeToString:[durationString floatValue] Minute:YES];
}

#pragma -mark play and stop with parent
- (void)playWithAutoPlay:(BOOL)autoPlay useMuteSound:(BOOL)muteSound;
{
    if (!self.playURL)	{
        _isErrorVideo = YES;
        [self syncPlayPauseButtons];
        return;
    } else {
        _isErrorVideo = NO;
    }
    
    _isAutoPlay = autoPlay;
    _useMuteSound = muteSound;
    _videoPlayStatus = videoModuleNonFinishedPlay;
    
    self.isConfirmToPlay = YES;
    
    if (_isAutoPlay) [self initWithAssetURL];
    
    if (self.isReady && self.player && ![self isPlaying])
    {
        if (_isAutoPlay)	[self play];
    }
}

- (BOOL)pauseUnFocusCell
{
    if (self.isBackGround == YES)	return NO;
    if (self.isExpandVideo == YES)	return NO;
    
    self.isConfirmToPlay = NO;
    _videoPlayStatus = videoModuleNonFinishedPlay;
    [self syncPlayPauseButtons];
    [self pause];
    
    //동영상 릴리즈
    [self assetFailedToPrepareForPlayback:nil];
    _isErrorVideo = NO;
    self.isConfirmToPlay = YES;
    
    return YES;
}

#pragma -mark ipod Music Controls
- (void)checkiPodMusicStatus
{
	MPMusicPlayerController *itunesPlayer = [MPMusicPlayerController iPodMusicPlayer];
	if ([itunesPlayer playbackState] == MPMusicPlaybackStatePlaying) {
		_isPlayItunesMusic = YES;
		[itunesPlayer pause];
	}
	else {
		_isPlayItunesMusic = NO;
	}
}

- (void)playIPodMusic
{
	if (_isPlayItunesMusic) {
		MPMusicPlayerController *itunesPlayer = [MPMusicPlayerController iPodMusicPlayer];
		[itunesPlayer play];
		_isPlayItunesMusic = NO;
	}
}

#pragma -mark button Status
- (void)syncPlayPauseButtons
{
    if (_isErrorVideo)
    {
        [self.playerView setHidden:YES];
        [_errorLabel setHidden:NO];
        [_playButton setHidden:YES];
        [_replayButton setHidden:YES];
        [_fullverButton setHidden:YES];
        [_pauseButton setHidden:YES];
        [self.playUiView setHidden:YES];
        [self.indicatorView setHidden:YES];
        [self.indicatorView stopAnimating];
        return;
    }
    else
    {
        [self.playerView setHidden:NO];
        [_errorLabel setHidden:YES];
    }
    
    if (!self.isReady)
    {
        [_playButton setHidden:YES];
        [_replayButton setHidden:YES];
        [_fullverButton setHidden:YES];
        [_pauseButton setHidden:YES];
        [self.playUiView setHidden:NO];
        [self.indicatorView setHidden:NO];
        [self.indicatorView startAnimating];
        return;
    }
    else
    {
        [self.indicatorView setHidden:YES];
        [self.indicatorView stopAnimating];
    }
    
    if ([self isPlaying])
    {
        [_playButton setHidden:YES];
        [_replayButton setHidden:YES];
        [_fullverButton setHidden:YES];
        
        if (self.isPauseForDelay)	{
            [_pauseButton setHidden:NO];
            [self.playUiView setHidden:NO];
        }
        else {
            [_pauseButton setHidden:YES];
            [self.playUiView setHidden:YES];
        }
    }
    else
    {
        if (_videoPlayStatus == videoModuleNonFinishedPlay) {
            [_playButton setHidden:NO];
            [_replayButton setHidden:YES];
            [_fullverButton setHidden:YES];
        } else if (_videoPlayStatus == videoModuleFinishedPlayOverThirty) {
            [_playButton setHidden:YES];
            [_replayButton setHidden:YES];
            [_fullverButton setHidden:NO];
        } else if (_videoPlayStatus == videoModuleFinishedPlayUnderThirty) {
            [_playButton setHidden:YES];
            [_replayButton setHidden:NO];
            [_fullverButton setHidden:YES];
        }
        
        [_pauseButton setHidden:YES];
        [self.playUiView setHidden:NO];
    }
}

- (void)setMuteImage:(BOOL)isMute
{
    if (!isMute)	[_muteButton setImage:[UIImage imageNamed:@"list_icon_video_sound_on.png"] forState:UIControlStateNormal];
    else			[_muteButton setImage:[UIImage imageNamed:@"list_icon_video_sound_off.png"] forState:UIControlStateNormal];
}

#pragma -mark onClick Methods
- (void)onClickFullScreenVideo:(id)sender
{
    if (self.playURL == nil) {
        [self alertVideoError:@"일시적인 오류가 발생하였습니다. 잠시후 다시 시도해주세요."];
    }
    
    //동영상이 로드되기전에 풀스크린창이 나타나면 pause 명령을 무시함.
    //따라서 isConfirmToPlay를 NO로 만들어서 동영상이 재생되도 바로 멈추게 만든다.
    self.isExpandVideo = YES;
    self.isConfirmToPlay = NO;
    [self pause];
    
    [self fullScreenVideoPlayWithAutoPlay:YES];
}

- (void)fullScreenVideoPlayWithAutoPlay:(BOOL)autoPlay
{
	//풀스크린 재생시 음악을 듣고 있다면, 음악을 멈추고 동영상을 소리를 내보낸다.
	[self checkiPodMusicStatus];
	
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    CPMoviePlayerViewController *mPlayer = [[CPMoviePlayerViewController alloc] initWithContentURL:self.playURL];
    
    if ([mPlayer respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
        [mPlayer setWantsFullScreenLayout:YES];
    }
    
    mPlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    mPlayer.moviePlayer.shouldAutoplay = autoPlay;
    mPlayer.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [mPlayer.moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    if ([self.delegate respondsToSelector:@selector(videoModuleonClickFullScreenButton:)]) {
        [self.delegate videoModuleonClickFullScreenButton:mPlayer];
    }
}

- (void)playbackDidFinish:(NSNotification *)noti
{
	//동영상 재생이 끝나면 오디오 세션 설정을 원복시킨다.
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    if (self.isBackGround) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        app.isReadyFullScreenVideoForeground = YES;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.isExpandVideo = NO;
	
	[self playIPodMusic];
}

- (void)onClickPause:(id)sender
{
    self.isPauseForDelay = NO;
    
    [self pause];
    [self syncPlayPauseButtons];
}

- (void)onClickPauseForDelay
{
    self.isPauseForDelay = YES;
    [self syncPlayPauseButtons];
    
    [self performSelector:@selector(cancelPauseForDelay) withObject:nil afterDelay:3.f];
}

- (void)cancelPauseForDelay
{
    self.isPauseForDelay = NO;
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _pauseButton.alpha = 0.f;
        self.playUiView.alpha = 0.f;
    } completion:^(BOOL isComplete){
        _pauseButton.alpha = 1.f;
        self.playUiView.alpha = 1.f;
        [self syncPlayPauseButtons];
    }];
}

- (void)onClickPlayVideo:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoModuleOnClickPlayButton:)]) {
        [self.delegate videoModuleOnClickPlayButton:self];
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL isWarning = [app isShowAlertWarningDataNetworkingMessage];
    
    if (isWarning)
    {
        UIAlertView *pAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ShockingDealTitle", @"쇼킹딜")
                                                          message:@"이동통신망(3G/4G LTE)를 이용하여 동영상을 재생하면 별도의 데이터 통화료가 부과될 수 있습니다."
                                                         delegate:self
                                                cancelButtonTitle:@"취소"
                                                otherButtonTitles:@"재생", nil];
        
        [pAlert setTag:ALERT_TAG_WARNING_USEDATA];
        [pAlert show];
        return;
    }
    else
    {
        [self confirmToPlayWithCheckAlertMsg];
    }
}

- (void)onClickReplayVideo:(id)sender
{
    _videoPlayStatus = videoModuleNonFinishedPlay;
    [self confirmToPlayWithCheckAlertMsg];
}

- (void)onClickMuteSound:(id)sender
{
    //iOS 6이하에서는 작동하지 않도록 한다.
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) return;
    
    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isMuteSound = !app.isMuteSound;
    
    if ([self.player respondsToSelector:@selector(setMuted:)]) {
        [self.player setMuted:app.isMuteSound];
    }
    
    [self setMuteImage:app.isMuteSound];
}

#pragma -mark video Methods
- (void)initWithAssetURL
{
    if (!self.playURL)
    {
        _isErrorVideo = YES;
        [self syncPlayPauseButtons];
        
        [self.playerView.imageView setImage:[UIImage imageWithColor:[UIColor blackColor]
                                                              width:self.playerView.frame.size.width
                                                             height:self.playerView.frame.size.height]];
        return;
    }
    else
    {
        _isErrorVideo = NO;
        [_errorLabel setHidden:YES];
    }
    
    if (!self.playerAsset)
    {
        [self syncPlayPauseButtons];
        
        self.playerAsset = [[AVURLAsset alloc] initWithURL:self.playURL options:nil];
        
        if (!self.playerAsset)	return;
        
        //동영상 ViewCount올리기
        if (self.updateViewCountUrl && [[self.updateViewCountUrl trim] length] > 0)
        {
            [self updateViewCount];
        }
        
        NSArray *requestedKeys = [NSArray arrayWithObjects:SHMoviePlayerViewObserverTracksKey, SHMoviePlayerViewObserverPlayableKey, nil];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [self.playerAsset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
            dispatch_async( dispatch_get_main_queue(),
                           ^{
                               /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                               [self prepareToPlayAsset:self.playerAsset withKeys:requestedKeys];
                           });
        }];
    }
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        return;
    }
    
    [self initScrubberTimer];
    
    if (!self.playerItem)
    {
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.playerAsset];
        
        if (self.playerItem)
        {
            [self.playerItem addObserver:self
                              forKeyPath:SHMoviePlayerViewObserverStatusKey
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
        }
    }
    else
    {
        [self.playerItem removeObserver:self forKeyPath:SHMoviePlayerViewObserverStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    if (!self.player)
    {
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        
        [self.player addObserver:self
                      forKeyPath:SHMoviePlayerViewObserverCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerCurrentItemObservationContext];
        
        [self.player addObserver:self
                      forKeyPath:SHMoviePlayerLayerObserverkTimeMetadataKey
                         options:0
                         context:MyStreamingMovieViewControllerTimedMetadataObserverContext];
        
        [self.player addObserver:self
                      forKeyPath:SHMoviePlayerViewObserverRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerRateObservationContext];
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removeObserverPlayer];
    
    [self removePlayerTimeObserver];
    [self syncScrubber];
    
    [self.indicatorView stopAnimating];
    [_replayButton setHidden:YES];
    [_fullverButton setHidden:YES];
    [_pauseButton setHidden:YES];
    [_playButton setHidden:NO];
    [self.playUiView setHidden:NO];
    self.isReady = NO;
    
    [_playerLayer setHidden:YES];

    [self.playerView.imageView setHidden:NO];
    
    if (self.playerAsset)	self.playerAsset = nil;
    if (self.playerItem)	self.playerItem = nil;
    if (self.player)		self.player = nil;
}

- (void)confirmToPlayWithCheckAlertMsg
{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayToButton:)])
//    {
//        [self.delegate performSelector:@selector(videoPlayToButton:) withObject:self];
//    }
    
    if (!self.isReady)
    {
        [self initWithAssetURL];
        return;
    }
    
    if (self.isReady)
    {
        self.isConfirmToPlay = YES;
    }
    
    [self play];
}

- (void)play
{
    if (self.player && self.isReady && ![self isPlaying] && self.isConfirmToPlay)
    {
        if (_isFinishedPlay)
        {
            [self seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
            _isFinishedPlay = NO;
        }
        
        _videoPlayStatus = videoModuleNonFinishedPlay;
        
        [self.player play];
        [_playButton setHidden:YES];
        
        [_playerLayer setHidden:NO];

        [self.playerView.imageView setHidden:YES];
    }
}

- (void)pause
{
    self.isPauseForDelay = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPauseForDelay) object:nil];
    
    if (self.player && self.isReady && [self isPlaying])
    {
        [self.player pause];
        [self syncPlayPauseButtons];
    }
}

- (BOOL)isPlaying
{
    if (!self.player) return NO;
    
    return [self.player rate] != 0.f;
}

- (void)seekToTime:(CMTime)time
{
    if (self.player && self.isReady)
    {
        [self.player seekToTime:time];
    }
}

- (void)playerItemDidReachEnd:(NSNotification*) aNotification
{
    _isFinishedPlay = YES;
    _videoPlayStatus = videoModuleFinishedPlayUnderThirty;
    
    [self pause];
    [_playerLayer setHidden:YES];

    [self.playerView.imageView setHidden:NO];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                [self removePlayerTimeObserver];
                [self syncScrubber];
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                if (self.isReady) return;
                
                self.isReady = YES;
                self.isConfirmToPlay = YES;
                self.playerLayer.hidden = NO;
                
                [self initScrubberTimer];
                [self syncPlayPauseButtons];
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                [self.playerLayer setPlayer:self.player];
                [self play];
                
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [self setMuteImage:app.isMuteSound];
                    
                    if ([self.player respondsToSelector:@selector(setVolume:)]) {
                        [self.player setVolume:1.f];
                    }
                    
                    if ([self.player respondsToSelector:@selector(setMuted:)]) {
                        [self.player setMuted:app.isMuteSound];
                    }
                }
                else {
                    if (_useMuteSound)
                    {
                        AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [app mutePlaySound];
                    }
                }
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == MyStreamingMovieViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* New player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
        }
        else /* Replacement of player currentItem has occurred */
        {
            [self.playerLayer setPlayer:self.player];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [self syncPlayPauseButtons];
        }
    }
    /* Observe the AVPlayer "currentItem.timedMetadata" property to parse the media stream
     timed metadata. */
    else if (context == MyStreamingMovieViewControllerTimedMetadataObserverContext)
    {
        //메타데이터를 표현할 때..
        //NSArray* array = [[self.player currentItem] timedMetadata];
        //for (AVMetadataItem *metadataItem in array)
        //{
        //	apple sample code : stitchedStreamPlayer 참조할 것..
        //	[self handleTimedMetadata:metadataItem];
        //}
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
    
    return;
}

- (CMTime)getPlayItemDuration
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return [self.player.currentItem duration];
    }
    
    return kCMTimeInvalid;
}

- (void)initScrubberTimer
{
    double interval = .1f;
    
    CMTime playerDuration = [self getPlayItemDuration];
    
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    /* Update the scrubber during normal playback. */
	__weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                   queue:NULL
                                                              usingBlock:^(CMTime time) {
                                                                  [weakSelf syncScrubber];
                                                              }];
}

- (void)syncScrubber
{
    CMTime playerDuration = [self getPlayItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        //CMTime : 0.0
        return;
    }
    
    //실행 중지 명령이 들어온 상태면 플레이하지않는다..
    if (!self.isConfirmToPlay)
    {
        [self pause];
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        double time = CMTimeGetSeconds([self.player currentTime]);
        _timeLabel.text = [Modules convertTimeToString:(float)time Minute:YES];
        
        //30초 이상인 동영상일 경우 30초에서 멈춘다.
        int iDuration = (int)duration;
        if (time >= 30.f && iDuration > 30) {
            _videoPlayStatus = videoModuleFinishedPlayOverThirty;
            [self pause];
        }
    }
}

/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (self.timeObserver)
    {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)removeObserverPlayer
{
    [self.playerItem removeObserver:self forKeyPath:SHMoviePlayerViewObserverStatusKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];
    
    [self.player removeObserver:self forKeyPath:SHMoviePlayerViewObserverCurrentItemKey];
    [self.player removeObserver:self forKeyPath:SHMoviePlayerLayerObserverkTimeMetadataKey];
    [self.player removeObserver:self forKeyPath:SHMoviePlayerViewObserverRateKey];
}

#pragma -mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_WARNING_USEDATA)
    {
        if (buttonIndex == 0)
        {
            //취소
        }
        else
        {
            //재생
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.isNotiVideoPlayAlertMsg = YES;
            
            [self confirmToPlayWithCheckAlertMsg];
        }
    }
}

#pragma -mark touch method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] == 1)
    {
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] == 1)
    {
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] == 1)
    {
        [self onClickPauseForDelay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] == 1)
    {
    }
}

- (void)alertVideoError:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ShockingDealTitle", nil)
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles:nil, nil];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

#pragma mark HttpRequest

- (void)updateViewCount
{
//    NSString *url = [[Modules urlWithQueryString:self.updateViewCountUrl] stringByAppendingFormat:@"&requestTime=%@", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHH"]];
    
    HttpRequest *request = [[HttpRequest alloc] initWithSynchronous:NO];
    
    [request setEncoding:DEFAULT_ENCODING];
    [request setDelegate:self];
    [request setRequestParameterType:RequestActionUPdateViewCount];
    [request sendGet:self.updateViewCountUrl data:nil];
}

- (void)request:(HttpRequest *)request didSuccessWithReceiveData:(NSString *)data
{
    //
}

- (void)request:(HttpRequest *)request didFailWithError:(NSError *)error
{
    //
}

@end