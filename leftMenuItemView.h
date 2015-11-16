//
//  leftMenuItemView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 6..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftMenuItemViewDelegate;

@interface leftMenuItemView : UIView

@property (nonatomic, weak) id<leftMenuItemViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title viewType:(NSInteger)viewType;

@end
	
@protocol leftMenuItemViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
- (void)didTouchMenuItem:(NSInteger)menuType;
@end