//
//  CPVideoInfo.m
//  11st
//
//  Created by spearhead on 2014. 9. 24..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPVideoInfo.h"
#import "CPCommonInfo.h"

@implementation CPVideoInfo

- (id)init
{
    if (self = [super init]) {
        _movieImgUrl = @"";
        _movieNo = @"";
        _movieUrl = @"";
        _movieUpdatePlayCountUrl = @"";
        _moviePlayCount = 0;
        _movieRunningTime = 0;
        _isLowSpec = NO;
    }
    
    return self;
}

+ (CPVideoInfo *)initWithMovieInfo:(NSDictionary *)movieInfo
{
    CPVideoInfo *videoInfo = [[CPVideoInfo alloc] init];
    
    if (movieInfo) {
        videoInfo.movieImgUrl = movieInfo[@"movieImgUrl"];
        videoInfo.movieNo = movieInfo[@"movieNo"];
        videoInfo.moviePlayCount = [movieInfo[@"moviePlayCnt"] integerValue];
        videoInfo.movieRunningTime = [movieInfo[@"movieRunningTime"] integerValue];
        
        if (movieInfo[@"movieNo"]) {
            NSString *urlPrefix = [[CPCommonInfo sharedInfo] urlInfo][@"updateMoviePlayCntPrefix"];
            videoInfo.movieUpdatePlayCountUrl = [urlPrefix stringByReplacingOccurrencesOfString:@"{{movieNo}}" withString:[movieInfo[@"movieNo"] stringValue]];
        }
        
        NSString *mediumQuilty = movieInfo[@"iMovies"][@"MQ"];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([[Modules getDeviceName] compare:@"iPad2,7" options:NSNumericSearch] != NSOrderedDescending) {
                videoInfo.movieUrl = mediumQuilty;
                videoInfo.isLowSpec = YES;
            }
            else {
                videoInfo.movieUrl = mediumQuilty;
            }
        }
        else {
            if ([[Modules getDeviceName] compare:@"iPhone3,3" options:NSNumericSearch] != NSOrderedDescending) {
                videoInfo.movieUrl = mediumQuilty;
                videoInfo.isLowSpec = YES;
            }
            else {
                videoInfo.movieUrl = mediumQuilty;
            }
        }
        //        videoInfo.movieUrl = @"http://video.11st.co.kr/11stvod/_definst_/TEST/shocking/upload/mp4:123456_test_MQ.mp4/playlist.m3u8";
    }
    else {
//        NSDictionary *movie = @{@"moviePlayCnt":@"5130",@"movieNo":@"20028",@"movieImgUrl":"http://i.011st.com/ex_t/R/640x640/1/90/1/src/movie/image/201409/115359113_B.jpg",@"movieRunningTime":@"30",@"iMovies":{@"HQ":@"http://video.11st.co.kr/11stvod/_definst_/media/Item/mp4:980188505_HQ.mp4/playlist.m3u8",@"MQ":@"http://video.11st.co.kr/11stvod/_definst_/media/Item/mp4:980188505_MQ.mp4/playlist.m3u8","LQ":"http://video.11st.co.kr/11stvod/_definst_/media/Item/mp4:980188505_LQ.mp4/playlist.m3u8",@"C1":@"http://video.11st.co.kr/11stvod/_definst_/media/Item/mp4:980188505_C1.mp4/playlist.m3u8"}};
        
        videoInfo.movieImgUrl = @"http://i.011st.com/ex_t/R/640x640/1/90/1/src/movie/image/201409/115359113_B.jpg";
        videoInfo.movieNo = @"20028";
        videoInfo.moviePlayCount = 5130;
        videoInfo.movieRunningTime = 30;
        videoInfo.movieUpdatePlayCountUrl = @"";
        videoInfo.movieUrl = @"http://video.11st.co.kr/11stvod/_definst_/media/Item/mp4:980188505_MQ.mp4/playlist.m3u8";
        videoInfo.isLowSpec = YES;
    }
    
    return videoInfo;
}

@end