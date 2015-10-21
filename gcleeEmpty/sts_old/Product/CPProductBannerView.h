//
//  CPProductBannerView.h
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductBannerViewDelegate;

@interface CPProductBannerView : UIView

@property (nonatomic, weak) id<CPProductBannerViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPProductBannerViewDelegate <NSObject>
@optional
- (void)didTouchLineBannerButton:(NSString *)url;
@end