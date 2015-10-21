//
//  CPTrendLineBannerCell.h
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendLineBannerCellDelegate;

@interface CPTrendLineBannerCell : UITableViewCell

@property (nonatomic, weak) id <CPTrendLineBannerCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendLineBannerCellDelegate <NSObject>
@optional

@end