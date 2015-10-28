//
//  CPBaseImageView.h
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.

#import <UIKit/UIKit.h>

@class CPBaseImageView;

@protocol CPBaseImageViewDelegate <NSObject>
- (void)imageViewDidUpdated:(CPBaseImageView *)imageView;
@end

@interface CPBaseImageView : UIImageView

@property (nonatomic, weak) id<CPBaseImageViewDelegate> delegate;

@end