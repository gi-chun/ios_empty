//
//  CPBlurImageView.h
///  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.

#import <UIKit/UIKit.h>
#import "CPBaseImageView.h"

@interface CPBlurImageView : CPBaseImageView
{
    NSString* key;
}

@property(nonatomic) BOOL blurEnabled;

-(void)setBlurImageWithUrl:(NSString*)url;

@end
