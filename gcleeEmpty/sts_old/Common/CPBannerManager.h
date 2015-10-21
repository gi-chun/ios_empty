//
//  CPBannerManager.h
//  11st
//
//  Created by spearhead on 2015. 6. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPBannerManagerDelegate;

@interface CPBannerManager : NSObject

@property (nonatomic, weak) id<CPBannerManagerDelegate> delegate;

+ (CPBannerManager *)sharedManager;

- (void)initBanner;
- (UIView *)makeOfferBannerView;
- (void)initBannerView;
- (void)removeBannerView;

@end

@protocol CPBannerManagerDelegate <NSObject>
@optional
- (void)didTouchBannerButton:(NSString *)url;
@end