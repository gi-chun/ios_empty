//
//  CPBlurImageView.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPBaseImageView.h"

@interface CPBlurImageView : CPBaseImageView
{
    NSString* key;
}

@property(nonatomic) BOOL blurEnabled;

-(void)setBlurImageWithUrl:(NSString*)url;

@end
