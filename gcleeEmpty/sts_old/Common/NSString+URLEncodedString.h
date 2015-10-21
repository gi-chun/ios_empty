//
//  NSString+URLEncodedString.h
//  11st
//
//  Created by spearhead on 2015. 6. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncodedString)

- (NSString *)URLEncodedStringWithEncoder:(CFStringEncoding)encoder;
- (NSString *)stringByInsertingComma;
- (int)indexOfBackwardSearch:(NSString *)text;
- (BOOL)compareToken:(NSString *)token;
- (BOOL)isHttpProtocol;

@end
