//
//  CPBannerView.h
//  11st
//
//  Created by spearhead on 2015. 6. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPBannerViewDelegate;

@interface CPBannerView : UIView

@property (nonatomic, weak) id<CPBannerViewDelegate> delegate;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithFrame:(CGRect)frame bannerInfo:(NSMutableDictionary *)aBannerInfo;

@end

@protocol CPBannerViewDelegate <NSObject>
@optional
- (void)didTouchLineBannerButton:(NSString *)url;
@end