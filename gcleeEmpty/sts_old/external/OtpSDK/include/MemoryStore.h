//
//  MemoryStore.h
//  ArcotOTPFrameWork
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Store.h"

#define MemoryStore AIDOTP_MemoryStore

@interface AIDOTP_MemoryStore : AIDOTP_Store {
	NSMutableDictionary *aiddic;

}

@property (nonatomic,retain) NSMutableDictionary *aiddic;


@end
