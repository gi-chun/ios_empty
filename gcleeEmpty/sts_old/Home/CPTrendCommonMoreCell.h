//
//  CPTrendCommonMoreCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendCommonMoreCellDelegate;

@interface CPTrendCommonMoreCell : UITableViewCell

@property (nonatomic, weak) id <CPTrendCommonMoreCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendCommonMoreCellDelegate <NSObject>
@optional

@end