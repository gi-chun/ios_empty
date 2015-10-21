//
//  CPBaseImageView.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

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