//
//  CPEventView.h
//  11st
//
//  Created by saintsd on 2015. 6. 5..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPEventViewDelegate;

@interface CPEventView : UIView

@property (nonatomic, weak) id <CPEventViewDelegate> delegate;
@property (nonatomic, strong) NSString *viewType;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)reloadAfterLogin;
- (void)goToTopScroll;

@end

@protocol CPEventViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
@end
