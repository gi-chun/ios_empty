//
//  CPThumbnailView.m
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.

#import "CPThumbnailView.h"

@implementation CPThumbnailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = YES;
        self.showAnimation = YES;
        self.isFirstShowAnimation = NO;
        
        _imageView = [[CPBlurImageView alloc] init];
        _imageView.delegate = self;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)anImage
{
    _imageView.image = anImage;
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_imageView) {
        if (_imageView.image && _imageView.image.size.height > 0 && _imageView.image.size.width > 0) {
            CGSize imageSize = _imageView.image.size;
            CGSize viewSize = self.frame.size;
            CGFloat ratio = imageSize.height / imageSize.width;
            CGSize imageViewSize;
            
            imageViewSize.width = viewSize.width;
            imageViewSize.height = viewSize.width * ratio;
            _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            
            if (self.showAnimation) {
                _imageView.alpha = 0.0f;
                [UIView animateWithDuration:0.5f
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     _imageView.alpha = 1.0f;
                                 } completion:nil];
                
                if (self.isFirstShowAnimation) {
                    self.showAnimation = NO;
                }
            }
            else {
                _imageView.alpha = 1.0f;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(CPThumbnailView:didFinishedDownloadImage:)]) {
                [self.delegate CPThumbnailView:self didFinishedDownloadImage:_imageView.image];
            }
        }
    }
}

- (void)imageViewDidUpdated:(CPBaseImageView *)imageView
{
    [self setNeedsLayout];
}

@end