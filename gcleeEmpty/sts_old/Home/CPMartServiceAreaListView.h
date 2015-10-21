//
//  CPMartServiceAreaListView.h
//  11st
//
//  Created by saintsd on 2015. 6. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPMartServiceAreaListView : UIView

+ (CGSize)viewSizeWithData:(NSArray *)items columnCount:(NSInteger)columnCount;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount;

@end
