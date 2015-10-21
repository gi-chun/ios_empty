//
//  CPSharePopupView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPSharePopupViewDelegate;

@interface CPSharePopupView : UIView

@property (nonatomic, weak) id<CPSharePopupViewDelegate> delegate;
@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *shareAppScheme;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPSharePopupViewDelegate <NSObject>
@optional
- (void)didTouchFacebookButton;
- (void)didTouchSMSButton;
@end