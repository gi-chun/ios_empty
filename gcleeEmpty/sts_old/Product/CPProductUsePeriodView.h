//
//  CPProductUsePeriodView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductUsePeriodViewDelegate;

@interface CPProductUsePeriodView : UIView

@property (nonatomic, weak) id<CPProductUsePeriodViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPProductUsePeriodViewDelegate <NSObject>
@optional
- (void)didTouchSeriesDetailButton:(NSString *)url;
@end