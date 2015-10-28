//
//  CPThumbnailView.h
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.

#import <UIKit/UIKit.h>
#import "CPBlurImageView.h"

@class CPThumbnailView;

@protocol CPThumbnailViewDelegate <NSObject>
@optional
- (void)CPThumbnailView:(CPThumbnailView *)view didFinishedDownloadImage:(UIImage *)image;
@end

@interface CPThumbnailView : UIView <CPBaseImageViewDelegate>

@property (nonatomic, strong) CPBlurImageView *imageView;
@property (nonatomic) BOOL showAnimation;
@property (nonatomic) BOOL isFirstShowAnimation;
@property (nonatomic, weak) id<CPThumbnailViewDelegate> delegate;

@end
