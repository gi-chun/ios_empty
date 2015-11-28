//
//  ToolBarView.h
//
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolBarViewDelegate;

@interface ToolBarView : UIView

@property (nonatomic, weak) id<ToolBarViewDelegate> delegate;

//- (id)initWithFrame:(CGRect)frame toolbarType:(CPToolbarType)toolbarType;
- (id)initWithFrame:(CGRect)frame toolbarType:(NSInteger)toolbarType;
- (void)setButtonProperties:(UIButton *)button enable:(BOOL)enable;
- (void)setReloadButtonProperties:(UIButton *)button isReload:(BOOL)isReload;
- (void)touchToggleButton;
- (void)setHiddenPopover:(BOOL)hidden;

@end

@protocol ToolBarViewDelegate <NSObject>
@optional
//ToolBar
- (void)didTouchToolBarButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//PopOverView
- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

//SnapshotPopOverView
- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

@end