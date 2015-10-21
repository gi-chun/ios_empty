//
//  CPFooterButtonView.h
//  11st
//
//  Created by 조휘준 on 2015. 04. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPString+Formatter.h"

@implementation NSString (StringFormatter)

// 주어진 문자열에서 천단위 콤마를 삭제한다.
- (NSString*)removeThousandComma
{
	if (0 == self.length)
		return nil;
	
	return [self stringByReplacingOccurrencesOfString:@"," withString:@""];
}

// 주어진 문자열에 천단위 콤마를 붙인다.
- (NSString*)formatThousandComma
{
	if (0 == self.length)
		return nil;
	
//	NSLog(@"self = [%@]", self);
	// 이미 천단위 콤마가 존재하는지 여부를 확인한다.
	NSRange rangeFound = [self rangeOfString:@","];
	if (NSNotFound != rangeFound.location)
		return [[NSString alloc] initWithFormat:@"%@", self];
	
	// 소수점 이하 자리수가 존재하는지를 구해놓는다.
	BOOL hasFloatValue = (NSNotFound != [self rangeOfString:@"."].location);
	
	// 천단위 콤마가 존재하지 않으면
	double dValue = [self doubleValue];
	NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko"]];
	[numberFormatter setCurrencySymbol:@""];
	[numberFormatter setAllowsFloats:YES];
	
	NSString* theResult = [[NSString alloc] initWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:dValue]]];
	
//	NSLog(@"theResult = [%@]", theResult);
	if (hasFloatValue)
		return theResult;
	return [theResult substringWithRange:NSMakeRange(0, theResult.length - 3)];
}

- (BOOL)isAllDigits
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

@end
