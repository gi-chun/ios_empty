//
//  CPPriceDetailBestProductCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailBestProductCellDelegate;

@interface CPPriceDetailBestProductCell : UITableViewCell

@property (nonatomic, weak) id <CPPriceDetailBestProductCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol CPPriceDetailBestProductCellDelegate <NSObject>
@optional
- (void)priceDetailBestProductCell:(CPPriceDetailBestProductCell *)cell onTouchMoreLink:(NSString *)linkUrl;
@end