//
//  CPTrendBannerCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 15..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendBannerCellDelegate;

@interface CPTrendBannerCell : UITableViewCell

@property (nonatomic, weak) id < CPTrendBannerCellDelegate > delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendBannerCellDelegate <NSObject>
@optional
- (void)setTrendBannerCellImageHeightWithInfo:(NSDictionary *)info;
@end