//
//  CPVideoPopupView.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CPVideoInfo.h"

@class CPMoviePlayerViewController;

@protocol CPVideoPopupViewDelegate;

@interface CPVideoPopupView : UIView

@property (nonatomic, weak) id<CPVideoPopupViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame productInfo:(NSDictionary *)productInfo urlInfo:(NSDictionary *)urlInfo videoInfo:(CPVideoInfo *)videoInfo;
- (void)setMovieWithVideoInfo:(CPVideoInfo *)videoInfo;
- (void)playWithVideoInfo:(CPVideoInfo *)videoInfo;
- (void)playWithVideoInfo:(CPVideoInfo *)videoInfo autoPlay:(BOOL)autoPlay;

@end

@protocol CPVideoPopupViewDelegate <NSObject>
@optional

- (void)didTouchFullScreenButton:(CPMoviePlayerViewController *)player;
- (void)didTouchProductButton:(NSString *)productUrl;

@end