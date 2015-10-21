//
//  CPPriceDetailSaleGraphCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailSaleGraphCellDelegate;

@interface CPPriceDetailSaleGraphCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailSaleGraphCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailSaleGraphCellDelegate <NSObject>
@optional
- (void)saleGraphCellSelectedIndex:(NSInteger)index;

@end

