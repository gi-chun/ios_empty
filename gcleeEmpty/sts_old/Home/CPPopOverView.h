//
//  CPPopOverView.h
//  11st
//
//  Created by spearhead on 2014. 9. 11..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPopOverViewViewDelegate;

@interface CPPopOverView : UIView

@property (nonatomic, weak) id<CPPopOverViewViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame toolbarType:(CPToolbarType)toolbarType;

@end

@protocol CPPopOverViewViewDelegate <NSObject>
@optional
- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo;

@end