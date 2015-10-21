//
//  CPTrendAutoBannerCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 28..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPTrendAutoBannerCellDelegate;

@interface CPTrendAutoBannerCell : UITableViewCell

@property (nonatomic, weak) id <CPTrendAutoBannerCellDelegate> delegate;
@property (nonatomic, strong) NSArray *items;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPTrendAutoBannerCellDelegate <NSObject>
@optional

@end