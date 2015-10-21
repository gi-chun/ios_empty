//
//  CPShockingDealView.h
//  11st
//
//  Created by hjcho86 on 2015. 5. 6..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPShockingDealDelegate;

@interface CPShockingDealView : UIView

@property (nonatomic, weak) id<CPShockingDealDelegate> delegate;
- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)goToTopScroll;

@end

@protocol CPShockingDealDelegate <NSObject>
@optional
- (void)onMoviePopup:(NSDictionary *)dic;
- (void)onPopupBrowser:(NSDictionary *)dic;
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
- (void)didTouchTabButton:(id)sender;
@end
