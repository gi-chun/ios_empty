//
//  NetFunnelInfoStorage.h
//  NetFUNNEL
//
//  Created by jacojang on 13. 6. 14..
//  Copyright (c) 2013년 jacojang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetFunnelResult.h"
#import "NetFunnelDefine.h"

// ---------------------------------------------------------------------
// NetFunnelInfoStorageItem
// ---------------------------------------------------------------------
@interface NetFunnelInfoStorageItem : NSObject {
    NSMutableDictionary *_config;
    NetFunnelResult *_result;
}
@property (nonatomic) NSMutableDictionary *_config;
@property (nonatomic) NetFunnelResult *_result;

-(void)setDefaultAll;
-(void)clearResult;
@end

// ---------------------------------------------------------------------
// NetFunnelInfoStorage
// ---------------------------------------------------------------------
@interface NetFunnelInfoStorage : NSObject {
    NSMutableDictionary *_data;
}

+(NetFunnelInfoStorage *)sharedObject;
-(NetFunnelInfoStorageItem *)itemForKey:(NSString *)key;
-(void)clearResult:(NSString *)key;
@end

