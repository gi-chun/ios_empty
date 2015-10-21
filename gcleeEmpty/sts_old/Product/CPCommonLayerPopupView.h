//
//  CPCommonLayerPopupView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPCommonLayerPopupViewDelegate;

@interface CPCommonLayerPopupView : UIView

@property (nonatomic, weak) id<CPCommonLayerPopupViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame title:(NSString *)aTitle linkUrl:(NSString *)aLinkUrl;

- (void)openUrl:(NSString *)url;
- (void)stopLoading;
- (void)setScrollTop;
- (void)setScrollEnabled:(BOOL)isEnable;
- (void)setShowsHorizontalScrollIndicator:(BOOL)isShow;
- (void)setShowsVerticalScrollIndicator:(BOOL)isShow;

@end

@protocol CPCommonLayerPopupViewDelegate <NSObject>
@optional
- (void)productExchangeView:(CPCommonLayerPopupView *)view isLoading:(NSNumber *)loading;
- (void)productExchangeView:(CPCommonLayerPopupView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
@end