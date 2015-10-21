//
//  CPThumbnailView.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

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
