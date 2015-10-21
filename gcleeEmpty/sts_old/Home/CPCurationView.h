//
//  CPCurationView.h
//  11st
//
//  Created by saintsd on 2015. 6. 11..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPCurationViewDelegate;

@interface CPCurationView : UIView

@property (nonatomic, weak) id <CPCurationViewDelegate> delegate;
@property (nonatomic, assign) BOOL isMale;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)goToTopScroll;

@end

@protocol CPCurationViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)url;
@end