//
//  CPHomeDynamicServiceListView.h
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHomeDynamicServiceListViewDelegate;

@interface CPHomeDynamicServiceListView : UIView

@property (nonatomic, weak) id <CPHomeDynamicServiceListViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount isOpen:(BOOL)isOpen;
- (void)setOpenYn:(BOOL)isOpen;

@end

@protocol CPHomeDynamicServiceListViewDelegate <NSObject>
@optional

@end