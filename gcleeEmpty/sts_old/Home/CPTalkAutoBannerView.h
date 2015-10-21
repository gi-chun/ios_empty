//
//  CPTalkAutoBanner.h
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTalkAutoBannerViewDelegate;

@interface CPTalkAutoBannerView : UIView

@property (nonatomic, weak) id <CPTalkAutoBannerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end

@protocol CPTalkAutoBannerViewDelegate <NSObject>
@optional

@end