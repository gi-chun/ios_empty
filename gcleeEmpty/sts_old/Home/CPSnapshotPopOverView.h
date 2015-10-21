//
//  CPSnapshotPopOverView.h
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPSnapshotPopOverViewDelegate;

@interface CPSnapshotPopOverView : UIView

@property (nonatomic, weak) id<CPSnapshotPopOverViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame toolbarType:(CPToolbarType)toolbarType;

@end

@protocol CPSnapshotPopOverViewDelegate <NSObject>
@optional
- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

@end