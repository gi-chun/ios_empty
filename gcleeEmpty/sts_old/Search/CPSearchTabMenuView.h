//
//  CPSearchTabMenuView.h
//  11st
//
//  Created by spearhead on 2014. 9. 29..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPSearchTabMenuViewDelegate;

@interface CPSearchTabMenuView : UIView

@property (nonatomic, weak) id<CPSearchTabMenuViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame tabTitleItems:(NSArray *)tabTitleItems tabContentsItems:(NSArray *)tabContentsItems;
- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index;

@end

@protocol CPSearchTabMenuViewDelegate <NSObject>
@optional
- (void)didTouchTabMenuButton:(NSInteger)index;

@end