//
//  CPPriceDetailSameCategoryItemCellCollectionViewCell.h
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPriceDetailSameCategoryItemCellDelegate;

@interface CPPriceDetailSameCategoryItemCell : UICollectionViewCell

@property (nonatomic, weak) id <CPPriceDetailSameCategoryItemCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *item;
@property (nonatomic, strong) NSString *groupName;

- (void)updateCell;

@end

@protocol CPPriceDetailSameCategoryItemCellDelegate <NSObject>
@optional
- (void)priceDetailSameCategoryItemCell:(CPPriceDetailSameCategoryItemCell *)cell onTouchChangeModel:(NSString *)modelNo;
@end
