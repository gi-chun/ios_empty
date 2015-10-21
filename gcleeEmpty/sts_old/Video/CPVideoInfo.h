//
//  CPVideoInfo.h
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPVideoInfo : NSObject

@property (nonatomic, strong) NSString *movieImgUrl;
@property (nonatomic, strong) NSString *movieUrl;
@property (nonatomic, strong) NSString *movieNo;
@property (nonatomic, assign) NSInteger moviePlayCount;
@property (nonatomic, assign) NSInteger movieRunningTime;
@property (nonatomic, strong) NSString *movieUpdatePlayCountUrl;
@property (nonatomic, assign) BOOL isLowSpec;

+ (CPVideoInfo *)initWithMovieInfo:(NSDictionary *)movieInfo;

@end