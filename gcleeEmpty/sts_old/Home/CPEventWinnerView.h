//
//  CPEventWinnerView.h
//  11st
//
//  Created by saintsd on 2015. 6. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPEventWinnerViewDelegate;

@interface CPEventWinnerView : UIView

@property (nonatomic, weak) id <CPEventWinnerViewDelegate> delegate;

+ (CGFloat)getViewHeight:(NSArray *)items;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end

@protocol CPEventWinnerViewDelegate <NSObject>
@optional
- (void)touchEventWinnerViewItemButton:(NSString *)url;
@end