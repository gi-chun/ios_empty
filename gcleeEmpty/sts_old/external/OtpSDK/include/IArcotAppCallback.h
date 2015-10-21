//
//  IArcotAppCallback.h
//  arcotOTP
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IArcotAppCallback

- (void) callback:(NSString *)status args:(NSMutableDictionary *)dic;

@end
