//
//  leftLoginView.h
//  gcleeEmpty
//
//  Created by gclee on 2015. 11. 10..
//  Copyright © 2015년 gclee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftLoginViewDelegate;

@interface leftLoginView : UIView

@property (nonatomic, weak) id <leftLoginViewDelegate> delegate;

@property (nonatomic) NSInteger loginStatus;
@property (nonatomic) NSString*  mailId;
@property (nonatomic) NSString*  stringId;
@property (nonatomic) NSString*  cardNumber;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)setVisableItem;
@end

@protocol leftLoginViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
- (void)didTouchLogInBtn;
- (void)didTouchLogOutBtn;
@end
