//
//  CPTalkView.h
//  11st
//
//  Created by saintsd on 2015. 6. 2..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTalkViewDelegate;

@interface CPTalkView : UIView

@property (nonatomic, weak) id <CPTalkViewDelegate> delegate;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)goToTopScroll;

@end

@protocol CPTalkViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end
