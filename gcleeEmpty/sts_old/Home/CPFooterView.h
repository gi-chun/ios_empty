//
//  CPFooterView.h
//  11st
//
//  Created by 조휘준 on 2015. 04. 08..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPFooterViewDelegate;

@interface CPFooterView : UIView

@property (nonatomic, weak) id<CPFooterViewDelegate> delegate;
@property (nonatomic, strong) UIViewController *parentViewController;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithFrame:(CGRect)frame hasNotice:(BOOL)hasNotice;
- (void)reloadLoginStatus;

@end

@protocol CPFooterViewDelegate <NSObject>
@optional
- (void)reloadAfterLogin;
- (void)reloadWebViewData;

@end
