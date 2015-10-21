//
//  CPTalkTagView.h
//  11st
//
//  Created by saintsd on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTalkTagViewDelegate;

@interface CPTalkTagView : UIView

@property (nonatomic, weak) id <CPTalkTagViewDelegate> delegate;

- (id)initWithItems:(NSArray *)items;

@end


@protocol CPTalkTagViewDelegate <NSObject>
@optional
- (void)touchTalkTagViewItemButton:(NSString *)url;
@end