//
//  CPHomeTotalBillBannerView.h
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHomeTotalBillBannerViewDelegate;

@interface CPHomeTotalBillBannerView : UIView

@property (nonatomic, weak) id <CPHomeTotalBillBannerViewDelegate> delegate;
@property (nonatomic, strong) NSArray *items;

@end

@protocol CPHomeTotalBillBannerViewDelegate <NSObject>
@optional

@end
