//
//  CPBaseImageView.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPBaseImageView;

@protocol CPBaseImageViewDelegate <NSObject>
- (void)imageViewDidUpdated:(CPBaseImageView *)imageView;
@end

@interface CPBaseImageView : UIImageView

@property (nonatomic, weak) id<CPBaseImageViewDelegate> delegate;

@end