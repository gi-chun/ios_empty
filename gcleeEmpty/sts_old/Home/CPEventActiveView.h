//
//  CPEventActiveView.h
//  11st
//
//  Created by saintsd on 2015. 6. 8..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPEventActiveViewDelegate;

@interface CPEventActiveView : UIView

@property (nonatomic, weak) id <CPEventActiveViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end

@protocol CPEventActiveViewDelegate <NSObject>
@optional
- (void)reloadAfterLogin;
- (void)touchEventActiveViewItemButton:(NSString *)url;
@end