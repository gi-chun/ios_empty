//
//  CPBlurImageView.m
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.
#import "CPBlurImageView.h"
//#import "UIImageView+WebCache.h"
//#import "SDImageCache.h"
#import <CoreImage/CoreImage.h>

@implementation CPBlurImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _blurEnabled = NO;
        key = nil;
    }
    return self;
}

- (void)setBlurImageWithUrl:(NSString*)url
{
    self.blurEnabled = YES;
    
//    SDImageCache *imgCache = [SDImageCache sharedImageCache];
//    
//    key = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@_blur",url]];
//    UIImage* img = [imgCache imageFromDiskCacheForKey:key];
//    
//    if (img == nil) {
////        [self setImageWithURL:[NSURL URLWithString:url]];
//        [self sd_setImageWithURL:[NSURL URLWithString:url]];
//    }
//    else {
//        self.image = img;
//        [self setNeedsLayout];
//    }
}

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    
//    if(self.blurEnabled){
//        
////        SDImageCache* imgCache = [SDImageCache sharedImageCache];
////        UIImage* img = [imgCache imageFromDiskCacheForKey:key];
////        
////        if (img == nil) {
////            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
////            
////            if (version < 6.0)	return;
////            
////            if ([[Modules platform]isEqualToString:@"iPhone2,1"]||
////                [[Modules platform]isEqualToString:@"iPod1,1"]||
////                [[Modules platform]isEqualToString:@"iPod2,1"]) {
////                return;
////            }
////            
////            CIImage *ciImage = [CIImage imageWithCGImage:self.image.CGImage];
////            
////            
////            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
////            [filter setValue:ciImage forKey:kCIInputImageKey];
////            [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputRadius"];
////            CIImage* ciResultImage = [filter valueForKey:kCIOutputImageKey];
////            CIContext *context = [CIContext contextWithOptions:nil];
////            [self setImage:[UIImage imageWithCGImage:[context createCGImage:ciResultImage fromRect:[ciImage extent]]]];
////            [imgCache storeImage:self.image forKey:key];
//        }
//        else {
//            self.image = img;
//        }
//    }
}

@end
