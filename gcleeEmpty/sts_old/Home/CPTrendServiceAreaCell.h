//
//  CPTrendServiceAreaCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendServiceAreaCellDelegate;

@interface CPTrendServiceAreaCell : UITableViewCell

@property (nonatomic, weak) id <CPTrendServiceAreaCellDelegate> delegate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger columnCount;


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendServiceAreaCellDelegate <NSObject>
@optional

@end