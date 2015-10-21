//
//  CPPowerLinkView.h
//  11st
//
//  Created by hjcho86 on 2015. 6. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPowerLinkViewDelegate;

@interface CPPowerLinkView : UIView

@property (nonatomic, weak) id<CPPowerLinkViewDelegate> delegate;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithFrame:(CGRect)frame powerLinkInfo:(NSDictionary *)powerLinkData listingType:(NSString *)listingType;

@end

@protocol CPPowerLinkViewDelegate <NSObject>
@optional

@end