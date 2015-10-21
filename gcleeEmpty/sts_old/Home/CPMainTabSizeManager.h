//
//  CPMainTabSizeManager.h
//  11st
//
//  Created by saintsd on 2015. 6. 18..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPMainTabSizeManager : NSObject

+ (CGRect)getFrameWithGroupName:(NSString *)groupName item:(id)item;
+ (CGSize)getSizeWithGroupName:(NSString *)groupName item:(id)item;

@end
