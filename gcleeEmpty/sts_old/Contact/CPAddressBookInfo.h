//
//  CPAddressBookInfo.h
//  11st
//
//  Created by spearhead on 2014. 12. 1..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPAddressBookInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *recordId;
//@property (nonatomic, readwrite, getter = isSelected) BOOL selected;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) UIImage *thumbnail;

@end