//
//  CPToolBarView.h
//  11st
//
//  Created by spearhead on 2014. 8. 26..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPToolBarViewDelegate;

@interface CPToolBarView : UIView

@property (nonatomic, weak) id<CPToolBarViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame toolbarType:(CPToolbarType)toolbarType;
- (void)setButtonProperties:(UIButton *)button enable:(BOOL)enable;
- (void)setReloadButtonProperties:(UIButton *)button isReload:(BOOL)isReload;
- (void)touchToggleButton;
- (void)setHiddenPopover:(BOOL)hidden;

@end

@protocol CPToolBarViewDelegate <NSObject>
@optional
//ToolBar
- (void)didTouchToolBarButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//PopOverView
- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//SnapshotPopOverView
- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

@end