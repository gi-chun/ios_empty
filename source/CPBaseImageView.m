//
//  CPBaseImageView.m
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.

#import "CPBaseImageView.h"

@implementation CPBaseImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = nil;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    if (self.delegate) {
        if([self.delegate respondsToSelector:@selector(imageViewDidUpdated:)]) {
            [self.delegate imageViewDidUpdated:self];
        }
    }
}

@end