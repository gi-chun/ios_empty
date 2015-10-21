//
//  CPTabMenuView.h
//  11st
//
//  Created by spearhead on 2014. 8. 28..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTabMenuViewDelegate;

@interface CPTabMenuView : UIView

@property (nonatomic, weak) id<CPTabMenuViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame menuTitleItems:(NSArray *)menuTitleItems menuContentsItems:(NSArray *)menuContentsItems;
- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index;

@end

@protocol CPTabMenuViewDelegate <NSObject>
@optional
- (void)didTouchTabMenuButton:(NSInteger)index;

@end