//
//  CPProductWebView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 14..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductWebViewDelegate;

@interface CPProductWebView : UIView

@property (nonatomic, weak) id<CPProductWebViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame popupInfo:(NSDictionary *)aPopupInfo;

@end

@protocol CPProductWebViewDelegate <NSObject>
@optional
- (void)didSelectedOptions:(NSArray *)selectedOptions;
- (void)productWebViewOpenUrlScheme:(NSString *)urlScheme;
- (void)didTouchWebViewClose;

- (void)smartOptionDidClickedOptionSelectButtonAtOptionName:(NSString *)optionName;
@end