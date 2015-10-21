//
//  CPHomeTalkStyleListView.h
//  11st
//
//  Created by saintsd on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPHomeTalkStyleListView : UIView

+ (CGSize)viewSizeWithData:(CGFloat)width;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end
