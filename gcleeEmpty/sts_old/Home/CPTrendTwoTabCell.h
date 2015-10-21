//
//  CPTrendTwoTabCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendTwoTabCellDelegate;

@interface CPTrendTwoTabCell : UITableViewCell

@property (nonatomic, weak) id <CPTrendTwoTabCellDelegate> delegate;
@property (nonatomic, strong) NSArray *items;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendTwoTabCellDelegate <NSObject>
@optional

@end
