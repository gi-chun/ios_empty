//
//  CPProductTabMenuView.h
//  11st
//
//  Created by spearhead on 2015. 6. 29..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductTabMenuViewDelegate;

@interface CPProductTabMenuView : UIView

@property (nonatomic, weak) id<CPProductTabMenuViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;
- (void)touchTabMenuButton:(id)sender;

@end

@protocol CPProductTabMenuViewDelegate <NSObject>
@optional
- (void)didTouchTabMenuButton:(NSInteger)selectedIndex;
@end