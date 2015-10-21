//
//  NSString+URLEncodedString.m
//  11st
//
//  Created by spearhead on 2015. 6. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "NSString+URLEncodedString.h"
#import "RegexKitLite.h"

@implementation NSString (URLEncodedString)

- (NSString *)URLEncodedStringWithEncoder:(CFStringEncoding)encoder
{
    CFStringRef escapedRef = CFURLCreateStringByAddingPercentEscapes(
                                                                     kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)self,
                                                                     NULL,
                                                                     (__bridge CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                                                                     encoder);
    
    return (NSString *)CFBridgingRelease(escapedRef);
}

- (NSString *)stringByInsertingComma
{
    if (self.length > 3)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:self.integerValue]];
        
        return numberAsString;
    }
    
    return [NSString stringWithFormat:@"%@", self];
}

- (int)indexOfBackwardSearch:(NSString *)text
{
    NSRange range = [self rangeOfString:text options:NSBackwardsSearch];
    
    if (range.length > 0) return (int)range.location;
    
    return -1;
}

//문자열 비교
- (BOOL)compareToken:(NSString *)token
{
    NSRange pRange = [self rangeOfString:token];
    if(pRange.location != NSNotFound)	return YES;
    
    return NO;
}

- (BOOL)isHttpProtocol
{
    NSString *lowerStr = [self lowercaseString];
    
    return ([lowerStr isMatchedByRegex:@"^http://.*"] || [lowerStr isMatchedByRegex:@"^https://.*"]);
}

@end
