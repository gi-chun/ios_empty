//
//  CPEventServiceView.h
//  11st
//
//  Created by saintsd on 2015. 6. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPEventServiceViewDelegate;

@interface CPEventServiceView : UIView

@property (nonatomic, weak) id <CPEventServiceViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end

@protocol CPEventServiceViewDelegate <NSObject>
@optional
- (void)touchEventServiceViewItemButton:(NSString *)url;
@end